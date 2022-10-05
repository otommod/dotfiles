; vim:fdm=marker:

; {{{1 Prelude
(import-macros {: set-opt : set-hl
                : augroup
                : def-keymap : def-keymap-n : def-keymap-v
                : def-rec-keymap
                } :rc.macros)

(let [packer (require :packer)
      use packer.use]
  (packer.startup
    (fn []
      (use :wbthomason/packer.nvim)
      (use :rktjmp/hotpot.nvim)

      ; {{{1 Plugins
      (use :editorconfig/editorconfig-vim)

      (use :tpope/vim-repeat)
      (use :tpope/vim-unimpaired)
      (use :tpope/vim-commentary)
      ; " call minpac#add('tpope/vim-projectionist')
      ; " call minpac#add('tpope/vim-dispatch')

      ; " call minpac#add('simnalamburt/vim-mundo')
      (use :mbbill/undotree)

      (use :folke/tokyonight.nvim)
      (use :lifepillar/vim-solarized8)
      ; low-color themes
      ; https://github.com/mcchrish/vim-no-color-collections
      (use :pbrisbin/vim-colors-off)
      (use :jeffkreeftmeijer/vim-dim)

      ; (use :Olical/conjure)
      ; " call minpac#add('metakirby5/codi.vim')

      ; (use :mg979/vim-visual-multi)
      ; " call minpac#add('mtth/scratch.vim')

      ; " call minpac#add('romainl/vim-qf')
      ; " call minpac#add('romainl/vim-qlist')
      ; " call minpac#add('kevinhwang91/nvim-bqf')

      ; runtime macros/matchit.vim
      ; " call minpac#add('andymass/vim-matchup')

      ; " call minpac#add('justinmk/vim-sneak')
      ; " call minpac#add('unblevable/quick-scope')
      ; " call minpac#add('Lokaltog/vim-easymotion')
      ; " call minpac#add('jeetsukumaran/vim-indentwise')

      ; " call minpac#add('tommcdo/vim-exchange')
      ; " call minpac#add('matze/vim-move')
      ; " call minpac#add('zirrostig/vim-schlepp')
      ; " call minpac#add('natemaia/DragVisuals')

      ; " call minpac#add('LucHermitte/lh-tags')
      ; " call minpac#add('xuhdev/SingleCompile')
      ; call minpac#add('ludovicchabant/vim-gutentags')

      ; call minpac#add('vim-pandoc/vim-pandoc-syntax')
      ; call minpac#add('vim-pandoc/vim-pandoc')
      ; call minpac#add('vim-pandoc/vim-pandoc-after')
      ; " call minpac#add('dhruvasagar/vim-table-mode')
      ; " call minpac#add('clarke/vim-renumber')

      (use :takac/vim-hardtime)

      ; {{{2 Fixes
      (use :tpope/vim-rsi)
      ; " call minpac#add('Konfekt/FastFold')
      (use :ap/vim-you-keep-using-that-word)

      ; XXX: see https://github.com/neovim/neovim/issues/12587
      (use :antoinemadec/FixCursorHold.nvim)

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
      ; (use :junegunn/fzf.vim)
      ; (use :brettbuddin/fzf-quickfix)
      (use {1 :ibhagwan/fzf-lua
            :requires [:kyazdani42/nvim-web-devicons]})

      ; {{{2 Alignment
      ; " call minpac#add('tommcdo/vim-lion')
      ; " call minpac#add('godlygeek/tabular')
      ; " call minpac#add('junegunn/vim-easy-align')

      ; {{{2 Org-mode-like/Wiki
      (use {1 :nvim-neorg/neorg
            :requires [:nvim-lua/plenary.nvim
                       :nvim-treesitter/nvim-treesitter]})

      ; " call minpac#add('fmoralesc/vim-pad')
      ; " call minpac#add('vimoutliner/vimoutliner')

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

      (use :liuchengxu/vista.vim)

      ; {{{2 Treesitter
      (use {1 :nvim-treesitter/nvim-treesitter
            :run ":TSUpdate"})
      (use :nvim-treesitter/nvim-treesitter-textobjects)
      ; (use :p00f/nvim-ts-rainbow)
      (use :nvim-treesitter/playground)

      ; {{{2 Filetype specific
      ; XXX: Needs to be after all the other syntax plugins
      ; NeoViM, at least, as of February 2020, loads package plugins in the
      ; reverse order that it finds them.  That's why I give it a weird name to
      ; force it to the top when sorted lexicographically.
      ; (use {1 :sheerun/vim-polyglot :as :00-vim-polyglot})

      ; XML/HTML
      (use :gregsexton/MatchTag)

      ; Lisps
      (use :guns/vim-sexp)

      ; Go
      ; (use {1 :fatih/vim-go :ft :go})
      ; (use {1 :arp242/gopher.vim :ft :go})
      ; (use :rhysd/vim-goyacc)
      )))

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
(set-opt number)   ; display line numbers
; (set-opt relativenumber)

(set-opt ignorecase)   ; ignores case when searching
(set-opt smartcase)    ; only match case when it exists

(set-opt list)     ; show nice little characters
(set-opt listchars
         {:eol "¬" :tab "» " :trail "·" :extends "❯" :precedes "❮" :nbsp "␣"})
(set-opt showbreak "↪ ")    ; shows up on a wrapped line
(set-opt breakindent)

(set-opt scrolloff 5)       ; always keep the cursor 5 lines from the end of the screen
(set-opt sidescrolloff 8)   ; XXX: ???

(vim.opt.nrformats:append :alpha)   ; incr/decr alphabetic characters

(set-opt undofile)     ; save undos (persistent undo)
(set-opt backup)
(vim.opt.backupdir:remove ".")

(set-opt shiftwidth 2)
(set-opt tabstop 8)
(set-opt softtabstop 4)

(set-opt smartindent)
(set-opt expandtab)
(set-opt shiftround)   ; use multiple of shiftwidth when indenting with < and >

; Wildcompltetion
(set-opt wildmode [:longest:full :full])    ; command-line completion
(set-opt wildignore
         [
          "*/.git/*" "*/.hg/*" "*/.svn/*"     ; version control directories
          "*.sw?"                             ; vim swap files

          ; Binary files
          "*.o" "*.obj" "*.exe" "*.dll"       ; object files
          "*.pyc" "*.pyo" "*/__pycache__/*"   ; Python bytecode
          "*.class"                           ; Java bytecode

          ; Media files
          "*.mp3" "*.flac"                    ; music files
          "*.jp?g" "*.png" "*.gif" "*.bmp"    ; images
          "*.mkv" "*.mp4" "*.avi"             ; videos

          ; Archives
          "*.tar"                             ; tar archives
          "*.tar.gz" "*.tgz"                  ; gzip compresser archives
          "*.tar.bz2" "*.tbz" "*.tbz2"        ; bzip2 compressed archives
          "*.tar.xz" "*.txz"                  ; xz compressed archives
          "*.zip" "*.rar" "*.7z"              ; other archives
          ])

; Terminal settings
(set-opt title)       ; set the terminal title
(set-opt lazyredraw)  ; do not redraw while executing commands
(when (or (= vim.env.COLORTERM :truecolor)
          (= vim.env.COLORTERM :24bit))
  (set-opt termguicolors))

(set-opt splitright)          ; new vertical splits are put on the right
(set-opt virtualedit :block)  ; allow virtual-block past the line end
(set-opt colorcolumn "80")    ; a highlighted column at the 80 char mark
(set-opt cursorline)          ; highlights the screen line of the cursor
(set-opt concealcursor :nc)   ; don't conceal the cursor line in visual and insert mode
(set-opt foldcolumn "2")      ; a 2-char wide column indicating open and closed folds
(set-opt signcolumn "auto:2") ; at most 2-char wide sign column only when there's signs

; (set-opt completeopt [:menuone :longest])
(set-opt completeopt [:noinsert :menuone :noselect])

(set-opt diffopt [:filler :internal :algorithm:histogram :indent-heuristic])

(if
  (= (vim.fn.executable :rg) 1)
  (do
    (set-opt grepprg "rg --vimgrep")
    (set-opt grepformat "%f:%l:%c:%m,%f:%l:%m"))
  (and
    ; `pcall` protects against the command not existing
    (pcall vim.fn.system ["grep" "--version"])
    (= vim.v.shell_error 0))
  (do
    (set-opt grepprg "grep -nH -r")
    (set-opt grepformat "%f:%l:%m")))

; {{{1 Plugin options
(set vim.g.cursorhold_updatetime 100)

; {{{2 netrw
(set vim.g.netrw_altfile true)
(augroup rc-netrw
  (autocmd FileType :netrw "nnoremap <buffer><silent> gq <Cmd>Rexplore<CR>"))

; {{{2 bufline
(set vim.g.bufline_separator "  ")
; (set vim.g.bufline_fmt_fnamemodify ":p:~:.:gs#\v/(.)[^/]*\ze/#/\1#")

; {{{1 Appearance
(fn _G.rc_highlights []
  (vim.cmd.colorscheme :solarized8_flat)

  (set-hl WhitespaceEOL {:fg :White :bg :Firebrick :ctermbg :Red})

  ; XXX: add cterm fallbacks
  ; https://colorbrewer2.org/#type=qualitative&scheme=Paired&n=9
  (set-hl WordHL01 {:fg :Black :bg :#a6cee3 :bold 1})
  (set-hl WordHL02 {:fg :White :bg :#1f78b4 :bold 1})
  (set-hl WordHL03 {:fg :Black :bg :#b2df8a :bold 1})
  (set-hl WordHL04 {:fg :White :bg :#33a02c :bold 1})
  (set-hl WordHL05 {:fg :Black :bg :#fb9a99 :bold 1})
  (set-hl WordHL06 {:fg :White :bg :#e31a1c :bold 1})
  (set-hl WordHL07 {:fg :Black :bg :#fdbf6f :bold 1})
  (set-hl WordHL08 {:fg :Black :bg :#ff7f00 :bold 1})
  (set-hl WordHL09 {:fg :Black :bg :#cab2d6 :bold 1})

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

(let [bufline (require :bufline)]
  (bufline.setup))

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
(def-keymap expr :j "(v:count ? 'j' : 'gj')")
(def-keymap expr :k "(v:count ? 'k' : 'gk')")
(def-keymap :gV "`[v`]")
(def-keymap-n :<BS> :<C-^>)

; fixes
(def-keymap-v :> :>gv)
(def-keymap-v :< :<gv)

; use :tjump instead of :tag
(def-keymap-n "<C-]>" "g<C-]>")
(def-keymap-v "<C-]>" "g<C-]>")
(def-keymap-n "<C-W><C-]>" "<C-W>g<C-]>")

; XXX: Neovim cannot handle this
; (set-keymap :c :w!! "w !sudo tee % >/dev/null")

(set vim.g.mapleader " ")

(def-keymap-n :<C-p> "<Cmd>FzfLua files<CR>")
(def-keymap-n :gb "<Cmd>FzfLua buffers<CR>")

(def-keymap-n :<leader>b "<Cmd>FzfLua buffers<CR>")
(def-keymap-n :<leader>f "<Cmd>FzfLua files<CR>")
(def-keymap-n :<leader>o "<Cmd>FzfLua oldfiles<CR>")

; (def-keymap-n :<leader>q "<Cmd>lua ToggleQuickFix('c')<CR>")
; (def-keymap-n :<leader>l "<Cmd>lua ToggleQuickFix('l')<CR>")

(def-keymap-n :<leader>q "<Cmd>FzfLua quickfix<CR>")
(def-keymap-n :<leader>l "<Cmd>FzfLua loclist<CR>")

(def-keymap-n :<leader>k "<Cmd>lua wordhl.highlight 'n'<CR>")
(def-keymap-v :<leader>k "<Cmd>lua wordhl.highlight 'v'<CR>")
(def-keymap-n :<leader>K "<Cmd>lua wordhl.unhighlight()<CR>")

; bookmarks
(def-keymap-n :<leader>.v "<Cmd>e ~/.config/nvim/fnl/rc.fnl<CR>")
(def-keymap-n :<leader>.b "<Cmd>e ~/.bashrc<CR>")
(def-keymap-n :<leader>.z "<Cmd>e ~/.zshrc<CR>")
(def-keymap-n :<leader>.t "<Cmd>e ~/.tmux.conf<CR>")
(def-keymap-n :<leader>.g "<Cmd>e ~/.gitconfig<CR>")

(def-rec-keymap :sa "<Plug>(operator-surround-append)")
(def-rec-keymap :sd "<Plug>(operator-surround-delete)")
(def-rec-keymap :sr "<Plug>(operator-surround-replace)")

; {{{1 Treesittter
(let [ts-config (require :nvim-treesitter.configs)]
  (ts-config.setup {:ensure_installed
                    [:bash :fish :make :c :cpp :python
                     :html :css :javascript :jsdoc :json :http
                     :go :gomod :gowork
                     :ocaml :ocaml_interface :ocamllex
                     :fennel :lua :vim :query
                     :norg :norg_meta :norg_table
                     :comment :regex :ledger
                     ]
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

    (let [bulb (require :nvim-lightbulb)]
      (vim.api.nvim_create_autocmd [:CursorHold :CursorHoldI] {:buffer bufnr :callback bulb.update_lightbulb}))

    (let [caps client.server_capabilities]
      (when caps.documentHighlightProvider
        (vim.api.nvim_create_autocmd [:CursorHold :CursorHoldI] {:buffer bufnr :callback vim.lsp.buf.document_highlight})
        (vim.api.nvim_create_autocmd :CursorMoved {:buffer bufnr :callback vim.lsp.buf.clear_references}))
      (when caps.codeLensProvider
        (vim.api.nvim_create_autocmd [:BufEnter :CursorHold :InsertLeave] {:buffer bufnr :callback vim.lsp.codelens.refresh}))
      (when caps.definitionProvider
        (vim.cmd "command! -buffer LspDefinition lua vim.lsp.buf.definition()"))
      (when caps.typeDefinitionProvider
        (vim.cmd "command! -buffer LspTypeDefinition lua vim.lsp.buf.type_definition()"))
      (when caps.declarationProvider
        (vim.cmd "command! -buffer LspDeclaration lua vim.lsp.buf.declaration()"))
      (when caps.implementationProvider
        (vim.cmd "command! -buffer LspImplementation lua vim.lsp.buf.implementation()"))
      (when caps.referencesProvider
        (vim.cmd "command! -buffer LspReferences lua vim.lsp.buf.references()"))
      (when caps.callHierarchyProvider
        (vim.cmd "command! -buffer LspIncomingCalls lua vim.lsp.buf.incoming_calls()")
        (vim.cmd "command! -buffer LspOutgoingCalls lua vim.lsp.buf.outgoing_calls()"))
      (when caps.documentFormattingProvider
        (vim.cmd "command! -buffer LspFormat lua vim.lsp.buf.formatting()"))
      (when caps.renameProvider
        (vim.cmd "command! -buffer -nargs=? LspRename lua vim.lsp.buf.rename(<f-args>)"))
      (when caps.documentSymbolProvider
        (def-keymap-n :<leader>s "<Cmd>FzfLua lsp_document_symbols<CR>")
        (def-keymap-n :<leader>S "<Cmd>FzfLua lsp_live_workpace_symbols<CR>")
        (vim.cmd "command! -buffer LspDocumentSymbol lua vim.lsp.buf.document_symbol()"))
      (when caps.workspaceSymbolProvider
        (vim.cmd "command! -buffer -nargs=? LspWorkspaceSymbol lua vim.lsp.buf.workspace_symbol(<f-args>)"))
      (when (?. caps :workspace :workspaceFolders)
        (vim.cmd "command! -buffer -nargs=? -complete=dir LspAddWorkspaceFolder lua vim.lsp.buf.add_workspace_folder(<f-args>)")
        (vim.cmd "command! -buffer -nargs=? -complete=dir LspRemoveWorkspaceFolder lua vim.lsp.buf.remove_workspace_folder(<f-args>)")
        (vim.cmd "command! -buffer LspListWorkspaceFolders lua print(vim.inspect(vim.lsp.buf.list_workspace_folders()))"))
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
(do
  (local delimiters {")" "(" "]" "[" "}" "{"})
  (local specials {"let" true "fn" true "lambda" true "λ" true "when" true
                   "eval-compiler" true "for" true "each" true "while" true
                   "macro" true "match" true "doto" true "with-open" true
                   "collect" true "icollect" true "accumulate" true})

  (fn symbol-at [line pos]
    (: (line:sub pos) :match "[^%s]+"))

  (fn find-string-start [line end-quote-pos]
    (var quote-pos nil)
    (var state :in-string)
    (for [i (- end-quote-pos 1) 1 -1 :until (= state :none)]
      (match (values (line:sub i i) state)
        ("\"" _) (do (set quote-pos (- i 1))
                     (set state :maybe-quote))
        ("\\" :maybe-quote) (set state :escaped-quote)
        ("\\" :escaped-quote) (set state :maybe-quote)
        (_ :maybe-quote) (set state :none)
        _ (set state :in-string)))
    quote-pos)

  (fn line-indent-type [line i stack]
    (let [c (line:sub i i)
          delimiter (. stack (length stack))]
      (if (= i 0) nil
          (= c "\"") (let [string-start (find-string-start line i)]
                       (when string-start
                         (line-indent-type line string-start stack)))
          ;; if we find the delimiter we're looking for, stop looking
          (= c delimiter) (do (table.remove stack)
                              (line-indent-type line (- i 1) stack))
          ;; if we find a new form, start looking for the delimiter that begins it
          (. delimiters c) (do (table.insert stack (. delimiters c))
                               (line-indent-type line (- i 1) stack))
          ;; if we're looking for a delimiter, skip everything till we find it
          delimiter (line-indent-type line (- i 1) stack)
          ;; if we hit an opening table char, we're in a table!
          (or (= c "[") (= c "{")) (values :table i)
          ;; if we hit an open paren, we're in a call!
          (= c "(") (values :call i (symbol-at line (+ i 1)))
          (line-indent-type line (- i 1) stack))))

  (fn find-comment-start [line]
    (var semicolon-pos nil)
    (var state :none)
    (for [i 1 (length line) :until semicolon-pos]
      (match (values (line:sub i i) state)
        (";" :none) (set semicolon-pos (- i 1))
        (_ :escaping) (set state :in-string)
        ("\\" :in-string) (set state :escaping)
        ("\"" :in-string) (set state :none)
        ("\"" :none) (set state :in-string)))
    semicolon-pos)

  (fn indent-type [lines line-num stack]
    (let [line (. lines line-num)
          line-length (or (find-comment-start line) (length line))]
      (match (line-indent-type line line-length stack)
        (:table i) (values :table i)
        (:call i fn-name) (if (. specials fn-name)
                              (values :special (- i 1))
                              (values :call (- i 1) fn-name))
        (where _ (> line-num 1)) (indent-type lines (- line-num 1) stack))))

  (fn _G.rc_ft_fennel_indentexpr [line-num]
    (let [lines (vim.api.nvim_buf_get_lines 0 0 line-num true)]
      (match (indent-type lines (- line-num 1) [])
        (:table delimiter-pos) delimiter-pos
        (:special prev-indent) (+ prev-indent 2)
        (:call prev-indent fn-name) (+ prev-indent (length fn-name) 2)
        _ 0))))

(fn _G.rc_ft_fennel []
  (set vim.opt_local.softtabstop 2)
  (set vim.opt_local.shiftwidth 2)
  (set vim.opt_local.expandtab true)
  (set vim.opt_local.indentkeys ["!" :o :O])
  (set vim.opt_local.suffixesadd :.fnl)
  ; XXX: (set vim.opt_local.include "require")
  (set vim.opt_local.iskeyword
       ["33-255" "^(" "^)" "^{" "^}" "^[" "^]" "^\"" "^'" "^~" "^;" "^," "^@-@" "^`" "^." "^:"])
  (vim.opt_local.formatoptions:remove :t)
  (set vim.opt_local.comments "n:;")
  (set vim.opt_local.commentstring "; %s")
  (set vim.opt_local.indentexpr "v:lua.rc_ft_fennel_indentexpr(v:lnum)")
  )

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
