(fn string-or-sym [x msg]
  (if
    (= (type x) :string) x
    (sym? x) (tostring x)
    (error msg)))

(fn autocmd [...]
  (let [given-args [...]]
    (assert (>= (length given-args) 3) "autocmd events, pattern or cmd missing")
    (let [cmd (table.remove given-args)
          pattern (table.remove given-args)
          events (icollect [_ ev (ipairs given-args)]
                           (string-or-sym ev "autocmd event must be string, symbol"))]
    (table.concat ["autocmd" (table.concat events ",") pattern cmd] " "))))

(fn augroup [name ...]
  (var cmd [(.. "augroup " (string-or-sym name "augroup name must be string or symbol"))])
  (table.insert cmd "autocmd!")
  (each [_ aucmd (ipairs [...])]
    (assert (and (list? aucmd) (= (. aucmd 1) 'autocmd)) "augroup expected autocmds")
    (table.insert cmd (autocmd (unpack aucmd 2))))
  (table.insert cmd "augroup end")
  (list 'vim.cmd (table.concat cmd "\n")))

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
        (and (list? a) (= (. a 1) 'buffer))
        (set opts.buffer (. a 2))
        (and (list? a) (= (. a 1) 'mode))
        (set opts.mode (string-or-sym (. a 2) "mode must be string or symbol"))))
    (if opts.buffer
      (list 'vim.api.nvim_buf_set_keymap opts.buffer (or opts.mode "") opts.lhs opts.rhs opts.opts)
      (list 'vim.api.nvim_set_keymap (or opts.mode "") opts.lhs opts.rhs opts.opts))))

(fn def-keymap [...] (def-rec-keymap 'noremap ...))
(fn def-keymap-n [...] (def-keymap `(mode n) ...))
(fn def-keymap-v [...] (def-keymap `(mode v) ...))

{: augroup
 : def-keymap : def-keymap-n : def-keymap-v
 : def-rec-keymap
 }
