; vim:fdm=marker:

; {{{1 Prelude
(import-macros {: augroup
                : def-keymap : def-keymap-n : def-keymap-v
                : def-rec-keymap
                } :vim-macros)

(fn _G.compile_fennel_file [fnl-filename lua-filename]
  (assert (not= fnl-filename lua-filename))
  (let [compiler (require :fennel)]
    (set debug.traceback compiler.traceback)
    (with-open [fnl-file (io.open fnl-filename)
                lua-file (io.open lua-filename :w)]
      (->> (fnl-file:read "*a")
           (compiler.compileString)
           (pick-values 1)
           (lua-file:write)))))

(augroup rc-reload
  (autocmd BufWritePost "init.fnl"
           "++nested call v:lua.compile_fennel_file(stdpath('config') .. '/init.fnl', stdpath('config') .. '/init.lua') | source $MYVIMRC"))

(let [packer-install-path (.. (vim.fn.stdpath :data) "/site/pack/packer/start/packer.nvim")]
  (when (not= (vim.fn.isdirectory packer-install-path) 1)
    (vim.fn.system ["git" "clone" "--depth" "1" "https://github.com/wbthomason/packer.nvim" packer-install-path])))

(let [packer (require :packer)
      use packer.use]
  (packer.startup
    (fn []
      (use :wbthomason/packer.nvim)

      ; {{{1 Plugins
      (use :editorconfig/editorconfig-vim)

      ; {{{2 Fixes
      (use :tpope/vim-rsi)
      ; " call minpac#add('Konfekt/FastFold')
      (use :ap/vim-you-keep-using-that-word)

      ; {{{2 File explorers
      (use :tpope/vim-vinegar)
      ; (use :justinmk/vim-dirvish)

      ; {{{2 Window management
      ; " call minpac#add('szw/vim-ctrlspace')
      ; " call minpac#add('t9md/vim-choosewin')
      ; " call minpac#add('dhruvasagar/vim-zoom')
      (use :troydm/zoomwintab.vim)

      ; {{{2 Eye candy
      ; " call minpac#add('Yggdroot/indentLine')
      ; " call minpac#add('thaerkh/vim-indentguides')
      ; (use :lukas-reineke/indent-blankline.nvim)

      ; " call minpac#add('chrisbra/Colorizer')
      ; " call minpac#add('RRethy/vim-hexokinase')
      (use :norcalli/nvim-colorizer.lua)

      ; " TODO: I could write one of those (vim-illuminate, vim-cursorword, vim-matchmaker) and combine it with wordhl
      ; call minpac#add('RRethy/vim-illuminate')
      ; " call minpac#add('itchyny/vim-cursorword')
      ; " call minpac#add('qstrahl/vim-matchmaker')

      ; {{{2 VCSs
      (use :tpope/vim-fugitive)
      (use :tpope/vim-rhubarb)

      ; " call minpac#add('mhinz/vim-signify')
      (use {1 :lewis6991/gitsigns.nvim
            :requires [:nvim-lua/plenary.nvim]
            :config (fn [] ((. (require :gitsigns) :setup)))})

      ; {{{2 Search enhancements
      ; " call minpac#add('wincent/ferret')
      ; " call minpac#add('mhinz/vim-grepper')
      ; " call minpac#add('pelodelfuego/vim-swoop')
      ; " call minpac#add('romainl/vim-cool')
      ; " call minpac#add('junegunn/vim-slash')

      ; {{{2 Objects & Operators
      ; " call minpac#add('tpope/vim-surround')
      ; " call minpac#add('machakann/vim-sandwich')
      (use {1 :rhysd/vim-operator-surround
            :requires [:kana/vim-textobj-user
                       :kana/vim-operator-user]})

      ; Text objects
      ; " call minpac#add('kana/vim-textobj-indent')
      ; " call minpac#add('glts/vim-textobj-comment')
      ; " call minpac#add('reedes/vim-textobj-quote')
      ; " call minpac#add('thinca/vim-textobj-between')
      ; " call minpac#add('AndrewRadev/sideways.vim')
      (use :PeterRincker/vim-argumentative)
      ; " call minpac#add('adriaanzon/vim-textobj-matchit')
      ; " call minpac#add('lucapette/vim-textobj-underscore')
      ; " call minpac#add('coderifous/textobj-word-column.vim')
      ; " call minpac#add('jeetsukumaran/vim-pythonsense')
      ; " call minpac#add('bps/vim-textobj-python')
      ; " call minpac#add('rbonvall/vim-textobj-latex')
      ; " XXX: I like the 'next' object stuff, dunno about the rest
      ; " call minpac#add('wellle/targets.vim')

      ; {{{2 Warm and fuzzy
      ; (use :junegunn/fzf)
      (use :junegunn/fzf.vim)
      (use :brettbuddin/fzf-quickfix)

      ; {{{2 Alignment
      ; " call minpac#add('tommcdo/vim-lion')
      ; " call minpac#add('godlygeek/tabular')
      ; " call minpac#add('junegunn/vim-easy-align')

      ; {{{2 Autocompletion
      ; (use :ajh17/VimCompletesMe)
      ; (use :lifepillar/vim-mucomplete)

      (use :hrsh7th/nvim-cmp)
      (use :hrsh7th/cmp-buffer)
      (use :hrsh7th/cmp-nvim-lsp)
      ; (use :hrsh7th/cmp-path)
      ; (use :hrsh7th/cmp-cmdline)
      (use :hrsh7th/vim-vsnip)

      ; {{{2 LSP
      (use :neovim/nvim-lspconfig)
      ; (use :glepnir/lspsaga.nvim)
      (use :kosayoda/nvim-lightbulb)
      (use :ray-x/lsp_signature.nvim)
      ; (use :weilbith/nvim-lsp-smag)
      ; (use :nvim-lua/lsp-status.nvim)
      (use :jose-elias-alvarez/null-ls.nvim)

      ; {{{2 Treesitter
      (use :nvim-treesitter/nvim-treesitter)
      (use :nvim-treesitter/nvim-treesitter-textobjects)
      ; (use :p00f/nvim-ts-rainbow)
      (use :nvim-treesitter/playground)

      ; {{{2 Filetype specific
      ; XXX: Needs to be after all the other syntax plugins
      ; NeoViM, at least, as of February 2020, loads package plugins in the
      ; reverse order that it finds them.  That's why I give it a weird name to
      ; force it to the top when sorted lexicographically.
      ; (use :sheerun/vim-polyglot {:name :00-vim-polyglot})

      ; {{{3 Go
      ; (use :fatih/vim-go {:for :go})
      ; (use :arp242/gopher.vim {:for :go})
      ; (use :rhysd/vim-goyacc)

      ; {{{3 Lisps
      (let [lisp-filetypes [:clojure :fennel]]
        (use {1 :guns/vim-sexp :ft lisp-filetypes}))

      ; {{{3 XML/HTML
      (let [xml-filetypes [:xml :html :htmldjango :jinja2]]
        (use {1 :gregsexton/MatchTag :ft xml-filetypes}))

      ; }}}2

      ; (use :liuchengxu/vim-which-key)
      (use :tpope/vim-unimpaired)

      ; " call minpac#add('metakirby5/codi.vim')
      ; " call minpac#add('simnalamburt/vim-mundo')
      (use :mbbill/undotree)

      (use :sainnhe/sonokai)
      (use :sainnhe/everforest)
      (use :lifepillar/vim-solarized8)
      (use :joshdick/onedark.vim)
      ; (use :rafi/awesome-vim-colorschemes)

      (use :Olical/conjure)
      (use :mg979/vim-visual-multi)

      (use :liuchengxu/vista.vim)

      ; " call minpac#add('mtth/scratch.vim')
      ; " call minpac#add('tpope/vim-projectionist')
      ; " call minpac#add('tpope/vim-dispatch')
      ; " call minpac#add('neomake/neomake')

      ; " call minpac#add('romainl/vim-qf')
      ; " call minpac#add('romainl/vim-qlist')

      ; runtime macros/matchit.vim
      ; " call minpac#add('andymass/vim-matchup')

      (use :tpope/vim-repeat)
      (use :tpope/vim-commentary)

      ; " call minpac#add('justinmk/vim-sneak')
      ; (use :unblevable/quick-scope)
      ; " call minpac#add('Lokaltog/vim-easymotion')
      ; " call minpac#add('jeetsukumaran/vim-indentwise')

      ; " call minpac#add('tommcdo/vim-exchange')
      ; " call minpac#add('matze/vim-move')
      ; " call minpac#add('zirrostig/vim-schlepp')
      ; " call minpac#add('natemaia/DragVisuals')

      ; call minpac#add('vim-pandoc/vim-pandoc-syntax')
      ; call minpac#add('vim-pandoc/vim-pandoc')
      ; call minpac#add('vim-pandoc/vim-pandoc-after')
      ; " call minpac#add('dhruvasagar/vim-table-mode')
      ; " call minpac#add('clarke/vim-renumber')

      (use {1 :nvim-neorg/neorg
            :requires [:nvim-lua/plenary.nvim
                       :nvim-treesitter/nvim-treesitter]})

      ; " call minpac#add('vimoutliner/vimoutliner')
      ; " call minpac#add('lukaszkorecki/workflowish')
      ; " call minpac#add('fmoralesc/vim-pad')

      ; " call minpac#add('vimwiki/vimwiki')
      ; " call minpac#add('tbabej/taskwiki')
      ; " let g:vimwiki_list = [{'path': '~/Documens/notes', 'syntax': 'markdown', 'ext': '.md'}]
      ; " let g:vimwiki_global_ext = 0

      ; call minpac#add('fcpg/vim-waikiki')
      ; let g:waikiki_wiki_roots = ['~/Documents/notes']
      ; let g:waikiki_default_maps = 1
      ; let g:waikiki_conceal_markdown_url = 0
      ; let g:waikiki_space_replacement = '-'
      ; augroup Waikiki
      ;     au!
      ;     au User setup echomsg 'in a Waikiki buffer'
      ; augroup end

      ; " call minpac#add('lervag/wiki.vim')
      ; " call minpac#add('lervag/wiki-ft.vim')
      ; let g:wiki_root = '~/Documents/notes'

      ; " call minpac#add('LucHermitte/lh-tags')
      ; " call minpac#add('xuhdev/SingleCompile')
      ; call minpac#add('ludovicchabant/vim-gutentags')

      (use :takac/vim-hardtime))))

; {{{1 Personal plugins
; {{{2 askmkdir
; See also: http://code.arp242.net/auto_mkdir2.vim

(global askmkdir {})

(fn askmkdir.mkdir [dir confirm?]
  (when
    (and
      (not= (vim.fn.isdirectory dir) 1)
      (or
        (not= confirm? 1)
        (= (vim.fn.confirm (.. dir ": No such file or directory.  Creating...")) 1)))
    (vim.fn.mkdir dir :p)))

(augroup rc-askmkdir
  (autocmd BufWritePre FileWritePre "*" "lua askmkdir.mkdir(vim.fn.expand('<afile>:p:h'), vim.v.cmdbang == 0)"))

; {{{2 wordhl
; Simple plugin to highlight specific words or sentences
(global wordhl {})

(fn wordhl.get-visual-selection []
  ; TODO: look into `vim.region`
  (let [[_ visual-line visual-column _] (vim.fn.getpos :v)
        [_ cursor-line cursor-column _ _] (vim.fn.getcurpos)

        (start-line start-column end-line end-column)
        (if (or (> visual-line cursor-line)
                (and (= visual-line cursor-line) (> visual-column cursor-column)))
          (values cursor-line cursor-column visual-line visual-column)
          (values visual-line visual-column cursor-line cursor-column))

        ; Vim (and Neovim) signifies the last column using a very large number.
        ; MAX-INT to be exact.  Adding 1 to that will overflow a 32-bit signed
        ; int. While I don't know the exact ranges of Lua's numbers, in LuaJIT,
        ; `string.sub` explicitly uses a 32-bit int for its second parameter
        ; (the length) and so chokes on MAX-INT + 1
        MAX-INT 2147483647
        end-column (if
                     (= end-column MAX-INT) -1
                     (= vim.o.selection :inclusive) end-column
                     (- end-column 1))

        (start-column end-column)
        (if (string.find (vim.fn.mode) "[VS]")
          (values 1 -1)
          (values start-column end-column))

        lines (vim.api.nvim_buf_get_lines 0 (- start-line 1) end-line true)]

    ; Trim the last line up to its selected column...
    (tset lines (length lines)
          (string.sub (. lines (length lines)) 1 end-column))
    (tset lines 1
          (string.sub (. lines 1) start-column))
    (table.concat lines "\n")))

(fn wordhl.hl-group? [hlgrp] (vim.startswith hlgrp :WordHL))

(fn wordhl.pattern [pattern]
  (var match-add? true)
  (var hl-defs (vim.api.nvim__get_hl_defs 0))
  (each [_ m (ipairs (vim.fn.getmatches))]
    (tset hl-defs m.group nil)
    (when (and (wordhl.hl-group? m.group) (= m.pattern pattern))
      (set match-add? false)
      (vim.fn.matchdelete m.id)))
  (when match-add?
    (let [wordhls (icollect [hl (pairs hl-defs)]
                    (when (wordhl.hl-group? hl) hl))]
      (table.sort wordhls)
      (vim.fn.matchadd (. wordhls 1) pattern))))

(fn wordhl.highlight [mode]
  (let [visual-mode? (= mode :v)
        word (if visual-mode? (wordhl.get-visual-selection) (vim.fn.expand :<cword>))
        ignore-case? (and vim.o.ignorecase (or (not vim.o.smartcase) (< (vim.fn.match word :\u) 0)))
        pattern (if visual-mode?
                  (.. (if ignore-case? :\c "") :\V\zs (vim.fn.escape word :\) :\ze)
                  (.. (if ignore-case? :\c "") :\V\< (vim.fn.escape word :\) :\>))]
    (wordhl.pattern pattern)))

(fn wordhl.unhighlight []
  (each [_ m (ipairs (vim.fn.getmatches))]
    (when (wordhl.hl-group? m.group)
      (vim.fn.matchdelete m.id))))

; {{{1 Settings
(set vim.opt.number true)   ; display line numbers
; (set vim.opt.relativenumber true)

(set vim.opt.mouse :a)      ; enable mouse for all modes (Normal, Insert, etc)

(set vim.opt.ignorecase true)   ; ignores case when searching
(set vim.opt.smartcase true)    ; only match case when it exists

(set vim.opt.list true)     ; show nice little characters
(set vim.opt.listchars
     {:eol "¬" :tab "» " :trail "·" :extends "❯" :precedes "❮" :nbsp "␣"})
(set vim.opt.showbreak "↪ ")    ; shows up on a wrapped line
(set vim.opt.breakindent true)

(set vim.opt.scrolloff 5)       ; always keep the cursor 5 lines from the end of the screen
(set vim.opt.sidescrolloff 8)   ; XXX: ???

(vim.opt.nrformats:append :alpha)   ; incr/decr alphabetic characters

(set vim.opt.undofile true)     ; save undos (persistent undo)
(set vim.opt.backup true)
(vim.opt.backupdir:remove ".")

(set vim.opt.shiftwidth 2)
(set vim.opt.tabstop 8)
(set vim.opt.softtabstop 4)

(set vim.opt.smartindent true)
(set vim.opt.expandtab true)
(set vim.opt.shiftround true)   ; use multiple of shiftwidth when indenting with < and >

; Wildcompltetion
(set vim.opt.wildmode [:longest:full :full])    ; command-line completion
(vim.opt.wildignore:append
  [
   "*/.git/*" "*/.hg/*" "*/.svn/*"  ; version control directories
   "*.DS_Store"                     ; OS X things
   "*.sw?"                          ; vim swap files

   ; Binary files
   "*.o" "*.obj" "*.exe" "*.dll"        ; object files
   "*.pyc" "*.pyo" "*/__pycache__/*"    ; Python bytecode
   "*.class"                            ; Java bytecode

   "*.mp3" "*.flac"                 ; music files
   "*.jp?g" "*.png" "*.gif" "*.bmp" ; images
   "*.mkv" "*.mp4" "*.avi"          ; videos

   ; Archives
   "*.tar"                      ; tar archives
   "*.tar.gz" "*.tgz"           ; gzip compresser archives
   "*.tar.bz2" "*.tbz" "*.tbz2" ; bzip2 compressed archives
   "*.tar.xz" "*.txz"           ; xz compressed archives
   "*.zip" "*.rar"              ; other archives
   ])

; Terminal settings
(set vim.opt.title true)       ; set the terminal title
(set vim.opt.lazyredraw true)  ; do not redraw while executing commands
(when (or (= vim.env.COLORTERM :truecolor)
          (= vim.env.COLORTERM :24bit))
  (set vim.opt.termguicolors true))

(set vim.opt.splitright true)     ; new vertical splits are put on the right
(set vim.opt.virtualedit :block)  ; allow virtual-block past the line end
(set vim.opt.colorcolumn "80")    ; a highlighted column at the 80 char mark
(set vim.opt.cursorline true)     ; highlights the screen line of the cursor
(set vim.opt.concealcursor "nc")  ; don't conceal the cursor line in visual and insert mode
(set vim.opt.foldcolumn "2")      ; a 2-char wide column indicating open and closed folds
(set vim.opt.signcolumn "auto:2") ; at most 2-char wide sign column only when there's signs

; (set vim.opt.completeopt [:menuone :longest])
(set vim.opt.completeopt [:noinsert :menuone :noselect])

(set vim.opt.diffopt [:filler :internal :algorithm:histogram :indent-heuristic])

(if
  (= (vim.fn.executable :rg) 1)
  (do
    (set vim.opt.grepprg "rg --vimgrep")
    (set vim.opt.grepformat "%f:%l:%c:%m,%f:%l:%m"))
  (= (vim.fn.executable :ag) 1)
  (do
    (set vim.opt.grepprg "ag --vimgrep")
    (set vim.opt.grepformat "%f:%l:%c:%m,%f:%l:%m"))
  (and
    ; `pcall` protects against the command not existing
    (pcall vim.fn.system ["grep" "--version"])
    (= vim.v.shell_error 0))
  (do
    (set vim.opt.grepprg "grep -nH -r")
    (set vim.opt.grepformat "%f:%l:%m")))

; {{{1 Plugin options
; {{{2 netrw
(set vim.g.netrw_altfile true)
(augroup rc-netrw
  (autocmd FileType :netrw "nnoremap <buffer><silent> gq <Cmd>Rexplore<CR>"))

; {{{2 bufline
(set vim.g.bufline_separator "  ")
; (set vim.g.bufline_fmt_fnamemodify ":p:~:.:gs#\v/(.)[^/]*\ze/#/\1#")

; {{{1 Appearance
(fn _G.rc_highlights []
  (vim.cmd "colorscheme solarized8_flat")

  (vim.cmd "hi WhitespaceEOL ctermfg=white ctermbg=red guibg=#592929")

  ; (vim.cmd "hi! def WordHL01 gui=bold guifg=white guibg=#e6261f")
  ; (vim.cmd "hi! def WordHL02 gui=bold guifg=white guibg=#eb7532")
  ; (vim.cmd "hi! def WordHL03 gui=bold guifg=white guibg=#f7d038")
  ; (vim.cmd "hi! def WordHL04 gui=bold guifg=white guibg=#a3e048")
  ; (vim.cmd "hi! def WordHL05 gui=bold guifg=white guibg=#49da9a")
  ; (vim.cmd "hi! def WordHL06 gui=bold guifg=white guibg=#34bbe6")
  ; (vim.cmd "hi! def WordHL07 gui=bold guifg=white guibg=#4355db")
  ; (vim.cmd "hi! def WordHL08 gui=bold guifg=white guibg=#d23be7")

  ; XXX: add cterm fallbacks
  (vim.cmd "hi! def WordHL01 gui=bold guifg=white guibg=#d53e4f")
  (vim.cmd "hi! def WordHL02 gui=bold guifg=white guibg=#f46d43")
  (vim.cmd "hi! def WordHL03 gui=bold guifg=black guibg=#fdae61")
  (vim.cmd "hi! def WordHL04 gui=bold guifg=black guibg=#fee08b")
  (vim.cmd "hi! def WordHL05 gui=bold guifg=black guibg=#ffffbf")
  (vim.cmd "hi! def WordHL06 gui=bold guifg=black guibg=#e6f598")
  (vim.cmd "hi! def WordHL07 gui=bold guifg=black guibg=#abdda4")
  (vim.cmd "hi! def WordHL08 gui=bold guifg=white guibg=#66c2a5")
  (vim.cmd "hi! def WordHL09 gui=bold guifg=white guibg=#3288bd")

  ; XXX: https://github.com/norcalli/nvim-colorizer.lua/issues/35#issuecomment-725850831
  (set package.loaded.colorizer nil)
  (let [colorizer (require :colorizer)]
    (colorizer.setup)
    (each [_ bufnr (ipairs (vim.api.nvim_list_bufs))]
      (colorizer.attach_to_buffer bufnr))))

(rc_highlights)
(augroup rc-highlights
  (autocmd ColorScheme "*" "lua rc_highlights()")
  (autocmd OptionSet :termguicolors "lua rc_highlights()"))

(augroup rc-yank
  (autocmd TextYankPost "*" "lua vim.highlight.on_yank {timeout = 600}"))

(augroup rc-whitespace
  (autocmd VimEnter WinNew "*" "call matchadd('WhitespaceEOL', '\\s\\+$')"))

(augroup rc-terminal
  (autocmd TermOpen "*" "setlocal foldcolumn=0 signcolumn=no"))

(vim.fn.sign_define :DiagnosticSignError {:text "" :texthl :DiagnosticSignError :numhl :DiagnosticError})
(vim.fn.sign_define :DiagnosticSignWarn {:text "" :texthl :DiagnosticSignWarn :numhl :DiagnosticWarn})
(vim.fn.sign_define :DiagnosticSignInfo {:text "" :texthl :DiagnosticSignInfo :numhl :DiagnosticInfo})
(vim.fn.sign_define :DiagnosticSignHint {:text "" :texthl :DiagnosticSignHint :numhl :DiagnosticHint})

; set default diagnostics virtual text prefix
(set vim.lsp.handlers.textDocument/publishDiagnostics
     (vim.lsp.with
       vim.lsp.diagnostic.on_publish_diagnostics
       {:virtual_text {:prefix ""} :signs true :update_in_insert false}))

; {{{1 Mappings
; fixes
(def-keymap-v :> :>gv)
(def-keymap-v :< :<gv)

(def-keymap expr :j "(v:count? 'j' : 'gj')")
(def-keymap expr :k "(v:count? 'k' : 'gk')")
(def-keymap :gV "`[v`]")
(def-keymap-n :<BS> :<C-^>)
(def-keymap-n :gb "<Cmd>ls<CR>:b<Space>")

; Use :tjump instead of :tag
(def-keymap-n "<C-]>" "g<C-]>")
(def-keymap-v "<C-]>" "g<C-]>")
(def-keymap-n "<C-W><C-]>" "<C-W>g<C-]>")

; (def-keymap-n expr :<Space> "foldlevel('.') ? 'za': ' '")

; bookmarks
(def-keymap-n :<leader>.v "<Cmd>e $MYVIMRC<CR>")
(def-keymap-n :<leader>.b "<Cmd>e ~/.bashrc<CR>")
(def-keymap-n :<leader>.z "<Cmd>e ~/.zshrc<CR>")
(def-keymap-n :<leader>.t "<Cmd>e ~/.tmux.conf<CR>")
(def-keymap-n :<leader>.g "<Cmd>e ~/.gitconfig<CR>")

; XXX: Neovim cannot handle this
; (set-keymap :c :w!! "w !sudo tee % >/dev/null")

; {{{1 Plugin Mappings
(def-rec-keymap :sa "<Plug>(operator-surround-append)")
(def-rec-keymap :sd "<Plug>(operator-surround-delete)")
(def-rec-keymap :sr "<Plug>(operator-surround-replace)")

; (def-rec-keymap :w "<Plug>(motioncounts-w)")
; (def-rec-keymap :b "<Plug>(motioncounts-b)")

(def-keymap-n :<C-p> "<Cmd>FZF<CR>")
(def-keymap-n :gb "<Cmd>Buffers<CR>")

; (def-keymap-n :<leader>q "<Cmd>lua ToggleQuickFix('c')<CR>")
; (def-keymap-n :<leader>l "<Cmd>lua ToggleQuickFix('l')<CR>")

(def-keymap-n :<leader>k "<Cmd>lua wordhl.highlight 'n'<CR>")
(def-keymap-v :<leader>k "<Cmd>lua wordhl.highlight 'v'<CR>")
(def-keymap-n :<leader>K "<Cmd>lua wordhl.unhighlight()<CR>")

; {{{1 Treesittter
(let [ts-config (require :nvim-treesitter.configs)]
  (ts-config.setup {:ensure_installed :maintained
                    :highlight {:enable true}
                    ; :indent {:enable true}
                    ; :rainbow {:enable true :extended_mode true}
                    :textobjects
                    {
                     ; :textobjects {:select {:enable true
                     ;                        :keymaps {:af "@function.outer"
                     ;                                  :if "@function.inner"
                     ;                                  :ac "@call.outer"
                     ;                                  :ic "@call.inner"
                     ;                                  :ab "@block.outer"
                     ;                                  :ib "@block.inner"
                     ;                                  :as "@statement.outer"
                     ;                                  :is "@statement.inner"}} }
                     :move {:enable true
                            :set_jumps true  ; whether to set jumps in the jumplist
                            :goto_next_start {"]m" "@function.outer"
                                              "]]" "@class.outer"}
                            :goto_next_end {"]M" "@function.outer"
                                            "][" "@class.outer"}
                            :goto_previous_start {"[m" "@function.outer"
                                                  "[[" "@class.outer"}
                            :goto_previous_end {"[M" "@function.outer"
                                               "[]" "@class.outer"}}
                    }}))

; {{{1 LSP
(let [lsp-config (require :lspconfig)
      null-ls (require :null-ls)
      lsp-signature (require :lsp_signature)
      lsp-cmp (require :cmp_nvim_lsp)
      flags {:debounce_text_changes 150}
      capabilities (-> (vim.lsp.protocol.make_client_capabilities)
                       (lsp-cmp.update_capabilities))]

  (fn on_attach [client bufnr]
    (lsp-signature.on_attach)

    (set vim.opt_local.omnifunc :v:lua.vim.lsp.omnifunc)
    (set vim.opt_local.tagfunc :v:lua.vim.lsp.tagfunc)
    (set vim.opt_local.formatexpr "v:lua.vim.lsp.formatexpr()")

    (def-keymap-n (buffer bufnr) :K "<Cmd>lua vim.lsp.buf.hover()<CR>")
    (def-keymap-n (buffer bufnr) :<C-k> "<Cmd>lua vim.lsp.buf.signature_help()<CR>")
    (def-keymap-n (buffer bufnr) :gD "<Cmd>lua vim.lsp.buf.declaration()<CR>")
    (def-keymap-n (buffer bufnr) :gd "<Cmd>lua vim.lsp.buf.definition()<CR>")
    (def-keymap-n (buffer bufnr) :<space>D "<Cmd>lua vim.lsp.buf.type_definition()<CR>")
    (def-keymap-n (buffer bufnr) :gi "<Cmd>lua vim.lsp.buf.implementation()<CR>")
    (def-keymap-n (buffer bufnr) :gr "<Cmd>lua vim.lsp.buf.references()<CR>")
    (def-keymap-n (buffer bufnr) :<space>wa "<Cmd>lua vim.lsp.buf.add_workspace_folder()<CR>")
    (def-keymap-n (buffer bufnr) :<space>wr "<Cmd>lua vim.lsp.buf.remove_workspace_folder()<CR>")
    (def-keymap-n (buffer bufnr) :<space>wl "<Cmd>lua print(vim.inspect(vim.lsp.buf.list_workspace_folders()))<CR>")
    (def-keymap-n (buffer bufnr) :<space>rn "<Cmd>lua vim.lsp.buf.rename()<CR>")
    (def-keymap-n (buffer bufnr) :<space>e "<Cmd>lua vim.diagnostic.open_float()<CR>")
    (def-keymap-n (buffer bufnr) "[w" "<Cmd>lua vim.diagnostic.goto_prev()<CR>")
    (def-keymap-n (buffer bufnr) "]w" "<Cmd>lua vim.diagnostic.goto_next()<CR>")
    (def-keymap-n (buffer bufnr) :<space>q "<Cmd>lua vim.diagnostic.setloclist()<CR>")
    (def-keymap-n (buffer bufnr) :<space>f "<Cmd>lua vim.lsp.buf.formatting()<CR>")
    (def-keymap-n (buffer bufnr) :<space>ca "<Cmd>lua vim.lsp.buf.code_action()<CR>")
    (def-keymap-n (buffer bufnr) :gA "<Cmd>lua vim.lsp.buf.code_action()<CR>")
    (def-keymap (mode x) (buffer bufnr) :gA "<Cmd>lua vim.lsp.buf.range_code_action()<CR>")

    (augroup rc-lsp-lightbulb
      (autocmd CursorHold CursorHoldI "*" "lua require 'nvim-lightbulb'.update_lightbulb()"))

    (let [caps client.resolved_capabilities]
      (when caps.code_lens
        (augroup rc-lsp-codelens
          (autocmd InsertLeave :<buffer> "lua vim.lsp.codelens.refresh()")
          (autocmd InsertLeave :<buffer> "lua vim.lsp.codelens.display()")))
      (when caps.document_highlight
        (augroup rc-lsp-document-highlight
          (autocmd CursorHold CursorHoldI "*" "lua vim.lsp.buf.document_highlight() ")
          (autocmd CursorMoved "*" "lua vim.lsp.buf.clear_references() ")))
      (when caps.document_formatting
        (vim.cmd "command! -buffer LspFormat lua vim.lsp.buf.formatting()"))
      (when caps.rename
        (vim.cmd "command! -buffer -nargs=? LspRename lua vim.lsp.buf.rename(<f-args>)"))
      (when caps.find_references
        (vim.cmd "command! -buffer LspReferences lua vim.lsp.buf.references()"))
      (when caps.workspace_symbol
        (vim.cmd "command! -buffer -nargs=? LspWorkspaceSymbol lua vim.lsp.buf.workspace_symbol(<f-args>)"))
      (when caps.call_hierarchy
        (vim.cmd "command! -buffer LspIncomingCalls lua vim.lsp.buf.incoming_calls()")
        (vim.cmd "command! -buffer LspOutgoingCalls lua vim.lsp.buf.outgoing_calls()"))
      (when caps.workspace_folder_properties.supported
        (vim.cmd "command! -buffer LspListWorkspaceFolders lua print(vim.inspect(vim.lsp.buf.list_workspace_folders()))")
        (vim.cmd "command! -buffer -nargs=? -complete=dir LspAddWorkspaceFolder lua vim.lsp.buf.add_workspace_folder(<f-args>)")
        (vim.cmd "command! -buffer -nargs=? -complete=dir LspRemoveWorkspaceFolder lua vim.lsp.buf.remove_workspace_folder(<f-args>)"))
      (when caps.document_symbol
        (vim.cmd "command! -buffer LspDocumentSymbol lua vim.lsp.buf.document_symbol()"))
      (when caps.goto_definition
        (vim.cmd "command! -buffer LspDefinition lua vim.lsp.buf.definition()"))
      (when caps.type_definition
        (vim.cmd "command! -buffer LspTypeDefinition lua vim.lsp.buf.type_definition()"))
      (when caps.declaration
        (vim.cmd "command! -buffer LspDeclaration lua vim.lsp.buf.declaration()"))
      (when caps.implementation
        (vim.cmd "command! -buffer LspImplementation lua vim.lsp.buf.implementation()"))
      ))

  (null-ls.setup {: on_attach
                  :sources [; null-ls.builtins.diagnostics.eslint
                            ; null-ls.builtins.code_actions.eslint
                            null-ls.builtins.diagnostics.shellcheck
                            null-ls.builtins.code_actions.shellcheck
                            null-ls.builtins.code_actions.gitrebase
                            ]})

  (lsp-config.clangd.setup {: on_attach : capabilities : flags})
  (lsp-config.pyright.setup {: on_attach : capabilities : flags})
  (lsp-config.gopls.setup {: on_attach : capabilities : flags})
  (lsp-config.ocamllsp.setup {: on_attach : capabilities : flags})
  (lsp-config.tsserver.setup {: on_attach : capabilities : flags})
  )

; {{{1 Autocomplete
(let [cmp (require :cmp)]
  (fn add-newline []
    (let [[row column] (vim.api.nvim_win_get_cursor 0)]
      (vim.api.nvim_buf_set_lines 0 row row true [""])
      (vim.api.nvim_win_set_cursor 0 [(+ row 1) 0])))

  (fn cmp-cr [fallback]
    (when (not (cmp.confirm {:behavior cmp.ConfirmBehavior.Insert} add-newline))
      (fallback)))

  (cmp.setup {:snippet {:expand #(vim.fn.vsnip#anonymous $.body)}
              :mapping {:<CR> cmp-cr
                        :<Tab> (cmp.mapping.select_next_item)
                        :<S-Tab> (cmp.mapping.select_prev_item)}
              :preselect cmp.PreselectMode.None
              :sources (cmp.config.sources [{:name :nvim_lsp}]
                                           [{:name :buffer}])})

  ; Set configuration for specific filetype.
  (cmp.setup.filetype :norg
                      {:sources (cmp.config.sources
                                  [{:name :neorg}])}))

; {{{1 Neorg
(let [neorg (require :neorg)]
  (neorg.setup
    {:load {:core.defaults {}
            :core.norg.concealer {}
            :core.norg.completion {:config {:engine :nvim-cmp}}
            :core.norg.dirman {:config
                               {:workspaces
                                {:home_neorg "~/neorg"}
                                }}
            :core.gtd.base {:config {:workspace :home_neorg}}
            }}))

(let [parsers (require :nvim-treesitter.parsers)
      parser-configs (parsers.get_parser_configs)]
  (set parser-configs.norg_meta
       {:install_info {:url "https://github.com/nvim-neorg/tree-sitter-norg-meta"
                       :files ["src/parser.c"]
                       :branch :main}})
  (set parser-configs.norg_table
       {:install_info {:url "https://github.com/nvim-neorg/tree-sitter-norg-table"
                       :files ["src/parser.c"]
                       :branch :main}}))

; {{{1 Python
(fn _G.rc_ft_python []
  (let [py-cmd "import sys\nfor p in sys.path:\n if p: print(p)"
        (ok? py-path) (pcall vim.fn.systemlist ["python3" "-c" py-cmd])]
    (when ok?
      (set vim.opt_local.path ["." (unpack py-path)]))))

(augroup rc-ft-python
  (autocmd FileType :python "lua rc_ft_python()"))

; {{{1 Fennel
(fn _G.rc_ft_fennel []
  (set vim.opt_local.shiftwidth 2)
  (set vim.opt_local.expandtab true)
  (set vim.opt_local.suffixesadd :.fnl)
  ; XXX: (set vim.opt_local.include "require")
  (set vim.opt_local.lisp true)
  (set vim.opt_local.iskeyword
       ["33-255" "^(" "^)" "^{" "^}" "^[" "^]" "^\"" "^'" "^~" "^;" "^," "^@-@" "^`" "^." "^:"])
  (set vim.opt_local.lispwords
       [:fn :let :if :when :for :each :while :match :do :collect :icollect :accumulate :with-open])
  (set vim.opt_local.comments ":;")
  (set vim.opt_local.commentstring "; %s"))

(augroup rc-ft-fennel
  (autocmd FileType :fennel "lua rc_ft_fennel()"))

(set vim.g.sexp_filetypes :fennel)

; {{{1 TODO
; {{{2 Finalize on some TODO file format
;   * todo.txt
;   * Taskwarrior
;   * TaskPaper
;   * org-mode
;   * or even my very own!
; Afterwards, convert this TODO as well as any others that I have to the
; chosen format.  Right now I'm using todo.txt for some files, but I'm not
; really that invested.
;
; {{{2 Consider providing documentation for keybindings
; Kind of like what GNOME does nowadays, or guide-key in emacsland.
;   * hecal3/vim-leader-guide
;   * sunaku/vim-shortcut
;
; {{{2 Functions' arglist 'expansion'
;   * FooSoft/vim-argwrap
;   * jakobwesthoff/argumentrewrap
;   * mnussbaum/args_split.vim
; Take a look at them and perhaps make my own version.  The most important
; thing I guess is getting the indentation the way I want it.  This plugin
; seems close to what I want,
;   * vim-scripts/Scala-argument-formatter
;
; {{{2 Find and replace
;   * hauleth/sad.vim
; It's like :s only less powerful but more intuitive.  Here's something similar
;     nnoremap § *``gn<C-g>
;     inoremap § <C-o>gn<C-g>
;     snoremap <expr> . @.
; The nmap enters select (yes, select) mode with the word under the cursor
; selected.  The imap jumps to the next same word and the smap allows you to
; quickly reenter the same text if wanted.  Almost the same as the plugin
; really.
;
; {{{2 Mapping to act on whole function calls, eg with surround
; Consider writing a textobject for that.  I saw this
;   * https://github.com/tpope/vim-surround/pull/118
; A simpler replacement would be just
;     nmap dsf ds)db
; This won't handle methods though, e.g. foo.bar(baz)
;
; {{{2 Do tags as git hooks
;   * rafi/vim-tagabana
; Does some weird 'hashing' that's supposed to be 'caching'.  I don't know.
; Compared to gutentags that I'm using now it is Linux-only and also,
; git-only.  Considering that I do not always tend to use git for my projects,
; this could be a serious limitation.  I could either suck it up and use git
; everywhere, or continue using guttentags.
;
; {{{2 Documentation viewer
;   * thinca/vim-ref
; I already have my Pydoc function, which I don't use because jedi-vim
; overrides K in favor of its own documentation viewer which kind of sucks.
;
; {{{2 Statusline
;   * itchyny/lightline.vim
;   * vim-airline/vim-airline
;   * rafi/vim-tinyline
; I'll probably just continue using airline, it's the easiest and does most of
; what I need and like.
;
; {{{2 Get slimey
;   * julienr/vim-cellmode
;   * jpalardy/vim-slime
;   * jgdavey/tslime.vim/
;   * epeli/slimux
; Presumably, I want something that can send either one (whole) expression or a
; selection.  One expression can be more than just a line.  Perhaps jedi has
; some relevant APIs.  Otherwise, Python itself has means to access the AST and
; stuff, I could look into that.  One of this days I should also try PyCharm,
; to see what a real IDE offers and get some ideas.
;
; {{{2 http://howivim.com/2016/tyru/
; Has some stuff about visualstar and mappings and whatnot.
;
; {{{2 http://github.com/unblevable/quick-scope
; Perhaps I could do something similar with my motioncounts.  His code is kind
; of big to just embed in my vimrc, though I don't know how much of it can be
; refactored/compressed.
;
; {{{2 diffopt
; {{{2 cscope
; {{{2 fzf-tjump
; Right now I'm using Vim's own tjump mappings and these may be enough.
;   * ivalkeen/vim-ctrlp-tjump
;
; {{{2 Replace/rewrite thematic
; {{{2 " Multiple change
; let g:mc = "y/\\V\<C-r>=escape(@\", '/')\<CR>\<CR>"

; nnoremap cn *``cgn
; nnoremap cN *``cgN

; vnoremap <expr> cn g:mc . "``cgn"
; vnoremap <expr> cN g:mc . "``cgN"

; function! SetupCR()
;   nnoremap <Enter> :nnoremap <lt>Enter> n@z<CR>q:<C-u>let @z=strpart(@z,0,strlen(@z)-1)<CR>n@z
; endfunction

; nnoremap cq :call SetupCR()<CR>*``qz
; nnoremap cQ :call SetupCR()<CR>#``qz

; vnoremap <expr> cq ":\<C-u>call SetupCR()\<CR>" . "gv" . g:mc . "``qz"
; vnoremap <expr> cQ ":\<C-u>call SetupCR()\<CR>" . "gv" . substitute(g:mc, '/', '?', 'g') . "``qz"
