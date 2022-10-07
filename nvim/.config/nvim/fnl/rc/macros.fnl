(fn nil? [x] (= x nil))
(fn string? [x] (= (type x) :string))

(fn even? [x] (= (% x 2) 0))
(fn odd? [x] (not (even? x)))

(fn set-opt [name ?value]
  `(tset vim.opt ,(tostring name) ,(if (nil? ?value) true ?value)))
(fn set-opt-local [name ?value]
  `(tset vim.opt_local ,(tostring name) ,(if (nil? ?value) true ?value)))

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
  (assert (even? (select :# ...)) "augroup: an autocmd is missing its command/callback")
  `(let [group-id# (vim.api.nvim_create_augroup ,(tostring name) ,opts)]
     ,(icollect [_ event-filter callback (group-by 2 [...])]
        (create-autocmd event-filter callback `group-id#))))

(fn def-autocmd [event-filter callback] (create-autocmd event-filter callback))
(fn def-augroup [name ...] (create-augroup name {} ...))
(fn def-augroup* [name ...] (create-augroup name {:clean false} ...))

(fn def-rec-keymap [...]
  (let [args [...]
        num-args (length args)
        opts {:lhs (. args (- num-args 1)) :rhs (. args num-args) :opts {}}]
    (assert (>= num-args 2) (string.format "lhs and rhs not given args:%d" num-args))
    (each [i a (ipairs args) :until (>= i (- num-args 1))]
      (if
        (= (type a) :string)
        (tset opts.opts a true)
        (sym? a)
        (tset opts.opts (tostring a) true)
        (and (list? a) (= (. a 1) `buffer))
        (set opts.buffer (. a 2))
        (and (list? a) (= (. a 1) `mode))
        (set opts.mode (tostring (. a 2)))))
    (if opts.buffer
      (list `vim.api.nvim_buf_set_keymap opts.buffer (or opts.mode "") opts.lhs opts.rhs opts.opts)
      (list `vim.api.nvim_set_keymap (or opts.mode "") opts.lhs opts.rhs opts.opts))))

(fn def-keymap [...] (def-rec-keymap `noremap ...))
(fn def-keymap-n [...] (def-keymap `(mode n) ...))
(fn def-keymap-v [...] (def-keymap `(mode v) ...))

(fn create-package [package-spec]
  (if (string? package-spec) package-spec
      (list? package-spec)
      (do
        (assert (odd? (length package-spec)) "a package specification is incomplete")
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

{: set-opt : set-opt-local : set-hl
 : def-augroup : def-augroup* : def-autocmd
 : def-rec-keymap : def-keymap : def-keymap-n : def-keymap-v
 : def-packer-plugins
 }
