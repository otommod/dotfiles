;; A minimal bufferline replacement

(local M {:separator " "
          :highlight :None
          :fmt "%s:%s%s"
          :fmt-active "[%s:%s%s]"
          :fmt-modified "+"
          :fmt-fnamemodify ":t"})

(fn default-formatter [bufnr]
  (let [name (vim.api.nvim_buf_get_name bufnr)
        basename (vim.fn.fnamemodify name M.fmt-fnamemodify)
        fugitive? (vim.startswith name "fugitive://")
        modified? (vim.api.nvim_buf_get_option bufnr :modified)
        focused? (= bufnr (vim.api.nvim_get_current_buf))]
    (-> (if focused? M.fmt-active M.fmt)
        (: :format bufnr
           (if fugitive? (.. "fugitive://.../" basename) basename)
           (if modified? M.fmt-modified "")))))

(fn default-positioner [bufs max-width]
  (let [cur-bufnr (vim.api.nvim_get_current_buf)
        width-till-cur-bufnr
        (accumulate [w 0 _ b (ipairs bufs) :until (> b.nr cur-bufnr)]
          (+ w (vim.api.nvim_strwidth b.label)))
        labels (icollect [_ b (ipairs bufs)] b.label)]
    (let [line (table.concat labels "")]
      (if (< width-till-cur-bufnr max-width)
          line
          (line:sub (- width-till-cur-bufnr max-width) width-till-cur-bufnr)))))

(fn render [formatter positioner]
  ;; if the message is longer than '&columns - 12' you get the 'Press ENTER or
  ;; type command to continue' prompt
  (let [max-width (- (vim.api.nvim_get_option :columns) 12)
        output
        (-> (icollect [_ nr (ipairs (vim.api.nvim_list_bufs))]
              (when (vim.api.nvim_buf_is_loaded nr)
                {: nr :label (.. (formatter nr) M.separator)}))
            (default-positioner max-width)
            (: :sub 1 max-width))]
    (vim.api.nvim_echo [[output M.highlight]] false {})))

(fn setup []
  ;; TODO: make the formatter and positioner configurable
  (let [renderer #(render default-formatter default-positioner)
        callback #(vim.schedule renderer)
        group (vim.api.nvim_create_augroup :bufline {})]
    (vim.api.nvim_create_autocmd [:BufWinEnter :WinEnter :InsertLeave :VimResized :CursorHold]
                                 {: group : callback})))

{: render : setup}
