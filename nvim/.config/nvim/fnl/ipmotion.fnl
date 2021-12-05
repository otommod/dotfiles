; Improved paragraph motion
;
; A simple utility improve the "{" and "}" motion in normal / visual mode.
; In vim, a blank line only containing white space is NOT a paragraph
; boundary, this utility remap the key "{" and "}" to handle that.
;
; The utility uses a custom regexp to define paragraph boundaries, the
; matched line will be treated as paragraph boundary.
; Note that the regexp will be enforced to match from the start of line, to
; avoid strange behaviour when moving.
;
; It supports in normal and visual mode, and able to handle with count. It
; also support redefine the regexp for boundary, or local definition of
; boundary.
;
; Based on a vim-script by Luke Ng <kalokng@gmail.com>
;
; Configuration Variables:
; g:ip_skipfold     Set as 1 will make the "{" and "}" motion skip paragraph
;                   boundaries in closed fold.
;                   Default is 0.
;
; g:ip_boundary     The global definition of paragraph boundary.
;                   Default value is "\s*$".
;                   It can be changed in .vimrc or anytime. Defining
;                   b:ip_boundary will override this setting.
;
;                   Example:
;                       :let g:ip_boundary = '"\?\s*$'
;                   Setting that will make empty lines, and lines only
;                   contains '"' as boundaries.
;
;                   Note that there is no need adding a "^" sign at the
;                   beginning. It is enforced by the script.
;
; b:ip_boundary     Local definition of paragraph boundary. It will override
;                   g:ip_boundary if set. Useful when customize boundary for
;                   local buffer or only apply to particular file type.
;                   Default is unset.

(set vim.g.ip_boundary "\\s*$")
(set vim.g.ip_skipfold false)

(fn unfold []
  (when (or (vim.tbl_contains (vim.opt.foldopen:get) :block)
            (vim.tbl_contains (vim.opt.foldopen:get) :all))
    (vim.cmd "normal! zv")))

(fn move_paragraph_forwards []
  (let [skip-folds? (= vim.g.ip_skipfold 1)
        empty-line (.. "^\\%(" (or vim.b.ip_boundary vim.g.ip_boundary) "\\)")
        not-empty-line (.. empty-line "\\@!")]
    (var count vim.v.count1)
    (var at-end-of-file? false)
    (var is-line-empty?
      (not= 0 (vim.fn.search empty-line :bcn (vim.fn.line "."))))

    (vim.fn.setpos "''" (vim.fn.getpos "."))
    (while (and (> count 0)
                (not at-end-of-file?))
      (set at-end-of-file?
           (or (and is-line-empty?
                    (= 0 (vim.fn.search not-empty-line :cW)))
               (= 0 (vim.fn.search empty-line :W))))
      (set is-line-empty? true)
      (match [skip-folds? (vim.fn.foldclosedend ".")]
        [false _] (set count (- count 1))
        [true -1] (set count (- count 1))
        [true end-of-fold] (vim.fn.cursor end-of-fold 1)))

    (when at-end-of-file?
      (let [last-line (vim.fn.line "$")
            last-column (vim.fn.col [last-line "$"])]
        (vim.fn.cursor last-line last-column)))

    (unfold)))

(fn move_paragraph_backwards []
  (let [skip-folds? (= vim.g.ip_skipfold 1)
        empty-line (.. "^\\%(" (or vim.b.ip_boundary vim.g.ip_boundary) "\\)")
        not-empty-line (.. empty-line "\\@!")]
    (var count vim.v.count1)
    (var at-start-of-file? false)

    (vim.fn.setpos "''" (vim.fn.getpos "."))
    (while (and (> count 0)
                (not at-edge-of-file?))
      (set at-start-of-file?
           (or (= 0 (vim.fn.search not-empty-line :bcW))
               (= 0 (vim.fn.search empty-line :bW))))
      (match [skip-folds? (vim.fn.foldclosed ".")]
        [false _] (set count (- count 1))
        [true -1] (set count (- count 1))
        [true start-of-fold] (vim.fn.cursor start-of-fold 1)))

    (when at-start-of-file?
      (vim.fn.cursor 1 1))

    (unfold)))

(fn setup []
  (vim.api.nvim_set_keymap "" "}" "<Cmd>lua require 'ipmotion'.move_paragraph_forwards()<CR>" {})
  (vim.api.nvim_set_keymap "" "{" "<Cmd>lua require 'ipmotion'.move_paragraph_backwards()<CR>" {}))

{: setup
 : move_paragraph_forwards
 : move_paragraph_backwards}
