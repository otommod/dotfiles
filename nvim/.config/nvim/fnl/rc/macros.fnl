(fn nil? [x] (= x nil))
(fn string? [x] (= (type x) :string))

(fn even? [x] (= (% x 2) 0))
(fn odd? [x] (not (even? x)))

(fn error-compile [msg ast] (assert-compile false msg ast))

(fn set-opt* [scope name ...]
  (assert-compile (sym? name) "name must be a symbol" name)
  (let [n (select :# ...)
        opt (tostring name)]
    (if (= n 0) `(tset ,scope ,opt ,(not= (opt:sub 1 2) :no))
        (= n 1) `(tset ,scope ,opt ,...)
        (= n 2)
        (let [[meth & vals] [...]]
          (icollect [_ v (ipairs vals) &into `(do)]
            (if (= meth `&remove) `(: (. ,scope ,opt) :remove ,v)
                (= meth `&append) `(: (. ,scope ,opt) :append ,v)
                (= meth `&prepend) `(: (. ,scope ,opt) :prepend ,v)
                (error-compile (: "unknown method '%s'" :format meth) meth)))))))

(fn set-opt [name ...] (set-opt* `vim.opt name ...))
(fn set-opt-local [name ...] (set-opt* `vim.opt_local name ...))

(fn set-hl [name value]
  `(vim.api.nvim_set_hl 0 ,(tostring name) ,value))

(fn create-autocmd [event-filter callback ?group-id]
  (var events event-filter)
  (var opts {})
  (when (list? event-filter)
    (set events (. event-filter 1))
    (let [pattern (. event-filter 2)]
      (if (and (list? pattern) (= (. pattern 1) `buffer))
          (set opts.buffer (. pattern 2))
          (set opts.pattern pattern))))
  (if (string? callback)
      (set opts.command callback)
      (set opts.callback callback))
  (when (not (nil? ?group-id))
    (set opts.group ?group-id))
  `(vim.api.nvim_create_autocmd ,events ,opts))

(fn group-by [n seq ?from]
  (fn f [seq i]
    (let [i (+ i n)
          j (+ i n -1)]
      (when (< i (length seq))
        (values i (unpack seq i j)))))
  (let [start-idx (if (nil? ?from) 1 ?from)]
    (values f seq (- start-idx n))))

(fn create-augroup [name opts ...]
  (assert-compile (even? (select :# ...))
                  "augroup: an autocmd is missing its command/callback" ...)
  `(let [group-id# (vim.api.nvim_create_augroup ,(tostring name) ,opts)]
     ,(icollect [_ event-filter callback (group-by 2 [...]) &into `(do)]
        (create-autocmd event-filter callback `group-id#))))

(fn def-autocmd [event-filter callback] (create-autocmd event-filter callback))
(fn def-augroup [name ...] (create-augroup name {} ...))
(fn def-augroup* [name ...] (create-augroup name {:clean false} ...))

(fn def-keymap-rec [...]
  (let [args [...]
        n (length args)
        keymap-args {:modes [] :opts {}}]
    (assert-compile (>= n 2) "lhs and/or rhs not given")
    (set keymap-args.lhs (. args (- n 1)))
    (if (string? (. args n))
        (set keymap-args.rhs (. args n))
        (do (set keymap-args.rhs "")
            (set keymap-args.opts.callback (. args n))))
    (each [i a (ipairs args) &until (>= i (- n 1))]
      (if (and (list? a) (= (. a 1) `buffer))
          (do (assert-compile (nil? keymap-args.buf) "buffer given more than once")
              (set keymap-args.buf (. a 2)))
          (and (list? a) (= (. a 1) `mode))
          (let [modes (tostring (. a 2))]
            (fcollect [i 1 (length modes) &into keymap-args.modes]
                      (modes:sub i i)))
          (tset keymap-args.opts (tostring a) true)))
    (when (= (length keymap-args.modes) 0)
      (table.insert keymap-args.modes ""))
    (icollect [_ m (ipairs keymap-args.modes) &into `(do)]
      (if (nil? keymap-args.buf)
        `(vim.api.nvim_set_keymap ,m ,keymap-args.lhs ,keymap-args.rhs ,keymap-args.opts)
        `(vim.api.nvim_buf_set_keymap ,keymap-args.buf ,m ,keymap-args.lhs ,keymap-args.rhs ,keymap-args.opts)))))

(fn def-keymap [...] (def-keymap-rec `noremap ...))

(fn create-package [package-spec]
  (if (string? package-spec) package-spec
      (list? package-spec)
      (do
        (assert-compile (odd? (length package-spec))
                        "a package specification is incomplete" package-spec)
        (let [package-name (. package-spec 1)
              package-packer-spec
              (collect [_ key value (group-by 2 package-spec 2)] (values key value))]
          (tset package-packer-spec 1 package-name)
          package-packer-spec))))

(fn def-packer-plugins [packer ...]
  `((. ,packer :startup)
    (fn [use#]
      (use# :wbthomason/packer.nvim)
      (use# ,(icollect [_ pkg (ipairs [...])] (create-package pkg))))))

{: def-augroup
 : def-autocmd
 : def-keymap
 : def-keymap-rec
 : def-packer-plugins
 : set-hl
 : set-opt
 : set-opt-local
 }
