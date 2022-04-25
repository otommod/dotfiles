;; An easymotion-like plugin, shows the count needed to reach each word in the line

(local motion-flags {:w :z :W :z :e :z :E :z :b :b :B :b})
(local motion-patterns {:w "\\v(<\\k|>\\S|\\s\\zs\\S)"
                        :b "\\v(<\\k|>\\S|\\s\\zs\\S)"
                        :e "\\v(\\k>|\\S<|\\S\\ze\\s)"
                        :W "\\v(\\s)@<=\\S"
                        :B "\\v(\\s)@<=\\S"
                        :E "\\v(\\S\\ze\\s)"})

(fn words [motion line-nr]
  (fn iter-f [_ index]
    (let [flags (. motion-flags motion)
          pattern (. motion-patterns motion)
          [row col] (vim.fn.searchpos pattern flags line-nr)]
      (when (not (and (= row 0) (= col 0)))
        (values (+ index 1) [row col]))))
  (values iter-f nil 0))

(var match-ids [])

(fn clear []
  (each [_ id (ipairs match-ids)] (vim.fn.matchdelete id))
  (set match-ids []))

(fn show [motion]
  (let [view (vim.fn.winsaveview)]
    (icollect [i word (words motion view.lnum) :into match-ids :until (> i 9)]
      (vim.fn.matchaddpos :Conceal [word] 10 -1 {:conceal i}))
    (vim.fn.winrestview view)))

(fn do-motion [motion]
  (vim.api.nvim_feedkeys motion :n false)
  (vim.schedule (partial show motion)))

(fn setup []
  (each [motion (pairs motion-patterns)]
    (vim.api.nvim_set_keymap :n motion "" {:callback (partial do-motion motion)
                                           :desc (.. :motioncounts- motion)}))
  (let [gid (vim.api.nvim_create_augroup :motioncounts {})]
    (vim.api.nvim_create_autocmd [:WinLeave :InsertEnter :CursorMoved]
                                 {:group gid :callback clear})))

{: setup : show : clear}
