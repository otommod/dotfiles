; vim:fdm=marker:

; {{{1 Prelude
(import-macros {: def-augroup : def-autocmd : def-keymap : def-keymap-rec
                : def-packer-plugins : set-hl : set-opt : set-opt-local
                } :rc.macros)

; {{{1 Plugins
(def-packer-plugins (require :packer)
  :rktjmp/hotpot.nvim
  :editorconfig/editorconfig-vim

  :tpope/vim-repeat
  :tpope/vim-unimpaired
  :tpope/vim-commentary
  ; :tpope/vim-projectionist
  ; :tpope/vim-dispatch

  ; :mbbill/undotree
  ; :simnalamburt/vim-mundo

  ; :Olical/conjure
  ; :metakirby5/codi.vim

  ; :mg979/vim-visual-multi
  ; :mtth/scratch.vim

  ; :romainl/vim-qf
  ; :romainl/vim-qlist
  ; :kevinhwang91/nvim-bqf

  ; runtime macros/matchit.vim
  ; :andymass/vim-matchup

  ; :justinmk/vim-sneak
  ; :unblevable/quick-scope
  ; :Lokaltog/vim-easymotion
  ; :jeetsukumaran/vim-indentwise

  ; :tommcdo/vim-exchange
  ; :matze/vim-move
  ; :zirrostig/vim-schlepp
  ; :natemaia/DragVisuals

  ; :LucHermitte/lh-tags
  ; :xuhdev/SingleCompile
  ; :ludovicchabant/vim-gutentags

  ; :vim-pandoc/vim-pandoc-syntax
  ; :vim-pandoc/vim-pandoc
  ; :vim-pandoc/vim-pandoc-after
  ; :dhruvasagar/vim-table-mode
  ; :clarke/vim-renumber

  :takac/vim-hardtime

  ; {{{2 Fixes
  :tpope/vim-rsi
  :ap/vim-you-keep-using-that-word

  ; {{{2 File explorers
  :tpope/vim-vinegar
  ; :justinmk/vim-dirvish

  ; {{{2 Window management
  ; :szw/vim-ctrlspace
  ; :t9md/vim-choosewin
  ; :dhruvasagar/vim-zoom
  :troydm/zoomwintab.vim

  ; {{{2 Eye candy
  :ishan9299/nvim-solarized-lua

  ; low-color themes
  ; see https://github.com/mcchrish/vim-no-color-collections
  :pbrisbin/vim-colors-off
  :jeffkreeftmeijer/vim-dim

  ; (:NvChad/nvim-colorizer.lua
  ;  :config #((. (require :colorizer) :setup)))
  ; TODO: add mappings for the color picker
  (:uga-rosa/ccc.nvim
   :config #((. (require :ccc) :setup) {:highlighter {:auto_enable true}}))

  ; TODO: I could write one of those and combine it with wordhl
  ; :RRethy/vim-illuminate
  ; :itchyny/vim-cursorword
  ; :qstrahl/vim-matchmaker

  ; {{{2 VCSs
  :tpope/vim-fugitive
  :tpope/vim-rhubarb

  ; :mhinz/vim-signify
  (:lewis6991/gitsigns.nvim
   :config
   (fn []
     (let [gitsigns (require :gitsigns)]
       (gitsigns.setup {:numhl true})
       (vim.api.nvim_set_keymap :n "]c" "" {:callback gitsigns.next_hunk})
       (vim.api.nvim_set_keymap :n "[c" "" {:callback gitsigns.prev_hunk}))))

  ; {{{2 Search enhancements
  ; :wincent/ferret
  ; :mhinz/vim-grepper
  ; :pelodelfuego/vim-swoop
  ; :romainl/vim-cool

  ; {{{2 Objects & Operators
  ; :tpope/vim-surround
  ; :machakann/vim-sandwich
  (:rhysd/vim-operator-surround
   :requires [:kana/vim-textobj-user :kana/vim-operator-user])

  ; Text objects
  ; :kana/vim-textobj-indent
  ; :glts/vim-textobj-comment
  ; :reedes/vim-textobj-quote
  ; :thinca/vim-textobj-between
  ; :AndrewRadev/sideways.vim
  :PeterRincker/vim-argumentative
  ; :adriaanzon/vim-textobj-matchit
  ; :lucapette/vim-textobj-underscore
  ; :coderifous/textobj-word-column.vim
  ; :jeetsukumaran/vim-pythonsense
  ; :bps/vim-textobj-python
  ; :rbonvall/vim-textobj-latex
  ; XXX: I like the 'next' object stuff, dunno about the rest
  ; :wellle/targets.vim

  ; {{{2 Warm and fuzzy
  ; :junegunn/fzf
  ; :junegunn/fzf.vim
  ; :brettbuddin/fzf-quickfix
  (:ibhagwan/fzf-lua
   :requires [:kyazdani42/nvim-web-devicons])

  ; {{{2 Alignment
  ; :tommcdo/vim-lion
  ; :godlygeek/tabular
  ; :junegunn/vim-easy-align

  ; {{{2 Org-mode-like/Wiki
  (:nvim-neorg/neorg
   :run ":Neorg sync-parsers"
   :requires [:nvim-lua/plenary.nvim :nvim-treesitter/nvim-treesitter])

  ; :fmoralesc/vim-pad
  ; :vimoutliner/vimoutliner

  ; (:vimwiki/vimwiki
  ;  :config (fn []
  ;    (set vim.g.vimwiki_list [{:path "~/Documents/notes" :syntax :markdown :ext ".md"}])
  ;    (set vim.g.vimwiki_global_ext 0)))
  ; :tbabej/taskwiki

  ; (:fcpg/vim-waikiki
  ;  :config (fn []
  ;    (set vim.g.waikiki_wiki_roots ["~/Documents/notes"])
  ;    (set vim.g.waikiki_default_maps 1)
  ;    (set vim.g.waikiki_conceal_markdown_url 0)
  ;    (set vim.g.waikiki_space_replacement "-")
  ;    (def-autocmd (:User :setup) "echomsg 'in a Waikiki buffer")))

  ; :lervag/wiki-ft.vim
  ; (:lervag/wiki.vim
  ;  :config (fn []
  ;    (set vim.g.wiki_root "~/Documents/notes")))

  ; {{{2 Autocompletion
  ; :ajh17/VimCompletesMe
  ; :lifepillar/vim-mucomplete

  :hrsh7th/nvim-cmp
  :hrsh7th/cmp-buffer
  :hrsh7th/cmp-nvim-lsp
  ; :hrsh7th/cmp-path
  ; :hrsh7th/cmp-cmdline
  :hrsh7th/vim-vsnip

  ; {{{2 LSP
  :neovim/nvim-lspconfig
  ; :glepnir/lspsaga.nvim
  :kosayoda/nvim-lightbulb
  :ray-x/lsp_signature.nvim
  ; :nvim-lua/lsp-status.nvim
  :jose-elias-alvarez/null-ls.nvim

  :liuchengxu/vista.vim

  ; {{{2 Treesitter
  (:nvim-treesitter/nvim-treesitter
   :run ":TSUpdate")
  :nvim-treesitter/playground

  ; {{{2 Filetype specific
  ; XXX: Needs to be after all the other syntax plugins
  ; NeoViM, at least, as of February 2020, loads package plugins in the
  ; reverse order that it finds them.  That's why I give it a weird name to
  ; force it to the top when sorted lexicographically.
  ; (:sheerun/vim-polyglot :as :00-vim-polyglot)

  ; XML/HTML
  :gregsexton/MatchTag

  ; Lisps
  :guns/vim-sexp
  :tpope/vim-sexp-mappings-for-regular-people

  ; Go
  ; (:fatih/vim-go :ft :go)
  ; (:arp242/gopher.vim :ft :go)
  ; :rhysd/vim-goyacc
  )

; {{{1 Personal plugins
; {{{2 askmkdir
; See also: http://code.arp242.net/auto_mkdir2.vim

(do
  (fn user-accepts? [question] (= 1 (vim.fn.confirm question)))
  (fn directory-exists? [path] (= 1 (vim.fn.isdirectory path)))
  (fn ask-to-make-missing-dir [{: file}]
    (let [force-create? (= vim.v.cmdbang 1)
          dirname (vim.fn.fnamemodify file ":p:h")]
      (when (and (not (directory-exists? dirname))
                 (or force-create?
                     (user-accepts? (.. dirname ": No such file or directory.  Creating..."))))
        (vim.fn.mkdir dirname :p))))
  (def-augroup rc-askmkdir [:BufWritePre :FileWritePre] ask-to-make-missing-dir))

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

(set-opt nrformats &append :alpha)  ; incr/decr alphabetic characters

(set-opt undofile)     ; save undos (persistent undo)
(set-opt backup)
(set-opt backupdir &remove ".")

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
(def-augroup rc-netrw
             (:FileType :netrw) "nnoremap <buffer><silent> gq <Cmd>Rexplore<CR>")

; {{{2 bufline
(set vim.g.bufline_separator "  ")
; (set vim.g.bufline_fmt_fnamemodify ":p:~:.:gs#\v/(.)[^/]*\ze/#/\1#")

; {{{1 Appearance
(fn highlights []
  (vim.cmd.colorscheme :solarized-flat)

  (set-hl WhitespaceEOL {:fg :White :bg :Firebrick :ctermbg :Red})

  ; TODO: add cterm fallbacks
  ; https://colorbrewer2.org/#type=qualitative&scheme=Paired&n=9
  (set-hl WordHL01 {:fg :Black :bg :#a6cee3 :bold 1})
  (set-hl WordHL02 {:fg :White :bg :#1f78b4 :bold 1})
  (set-hl WordHL03 {:fg :Black :bg :#b2df8a :bold 1})
  (set-hl WordHL04 {:fg :White :bg :#33a02c :bold 1})
  (set-hl WordHL05 {:fg :Black :bg :#fb9a99 :bold 1})
  (set-hl WordHL06 {:fg :White :bg :#e31a1c :bold 1})
  (set-hl WordHL07 {:fg :Black :bg :#fdbf6f :bold 1})
  (set-hl WordHL08 {:fg :Black :bg :#ff7f00 :bold 1})
  (set-hl WordHL09 {:fg :Black :bg :#cab2d6 :bold 1}))

(def-augroup rc-highlights
             :VimEnter highlights
             :ColorScheme highlights
             (:OptionSet :termguicolors) highlights)

(let [bufline (require :bufline)]
  (bufline.setup))

(def-augroup rc-yank
             :TextYankPost #(vim.highlight.on_yank {:timeout 600}))

(def-augroup rc-whitespace
             [:VimEnter :WinNew] #(vim.fn.matchadd :WhitespaceEOL "\\s\\+$"))

(def-augroup rc-terminal
             :TermOpen "setlocal foldcolumn=0 signcolumn=no")

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
(def-keymap (mode n) :<BS> :<C-^>)

; fixes
(def-keymap (mode v) :> :>gv)
(def-keymap (mode v) :< :<gv)

; use :tjump instead of :tag
(def-keymap (mode n) "<C-]>" "g<C-]>")
(def-keymap (mode v) "<C-]>" "g<C-]>")
(def-keymap (mode n) "<C-W><C-]>" "<C-W>g<C-]>")

; XXX: Neovim cannot handle this
; (set-keymap :c :w!! "w !sudo tee % >/dev/null")

(set vim.g.mapleader " ")

(let [fzf (require :fzf-lua)]
  (def-keymap (mode n) :<C-p> fzf.files)
  (def-keymap (mode n) :gb fzf.buffers)

  (def-keymap (mode n) :<leader>b fzf.buffers)
  (def-keymap (mode n) :<leader>f fzf.files)
  (def-keymap (mode n) :<leader>o fzf.oldfiles)

  ; (def-keymap (mode n) :<leader>q (partial ToggleQuickFix :c))
  ; (def-keymap (mode n) :<leader>l (partial ToggleQuickFix :l))

  (def-keymap (mode n) :<leader>q fzf.quickfix)
  (def-keymap (mode n) :<leader>l fzf.loclist))

(def-keymap (mode n) :<leader>k (partial wordhl.highlight :n))
(def-keymap (mode v) :<leader>k (partial wordhl.highlight :v))
(def-keymap (mode n) :<leader>K wordhl.unhighlight)

; bookmarks
(def-keymap (mode n) :<leader>.v "<Cmd>e ~/.config/nvim/fnl/rc.fnl<CR>")
(def-keymap (mode n) :<leader>.b "<Cmd>e ~/.bashrc<CR>")
(def-keymap (mode n) :<leader>.z "<Cmd>e ~/.zshrc<CR>")
(def-keymap (mode n) :<leader>.t "<Cmd>e ~/.tmux.conf<CR>")
(def-keymap (mode n) :<leader>.g "<Cmd>e ~/.gitconfig<CR>")

(def-keymap-rec :sa "<Plug>(operator-surround-append)")
(def-keymap-rec :sd "<Plug>(operator-surround-delete)")
(def-keymap-rec :sr "<Plug>(operator-surround-replace)")

; {{{1 Treesittter
(let [ts-config (require :nvim-treesitter.configs)]
  (ts-config.setup {:ensure_installed
                    [:fennel :lua :vim :help :query
                     :fish :bash :make :c :cpp :python :regex :comment
                     :html :css :javascript :jsdoc :json :http :sql
                     :go :gomod :gowork
                     :ocaml :ocaml_interface :ocamllex
                     ]
                    ; XXX: https://github.com/neovim/tree-sitter-vimdoc/issues/23
                    :highlight {:enable true :disable [:help]}
                    ; :indent {:enable true}
                    }))

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
    (local fzf (require :fzf-lua))

    (def-keymap (mode n) (buffer bufnr) "[w" vim.diagnostic.goto_prev)
    (def-keymap (mode n) (buffer bufnr) "]w" vim.diagnostic.goto_next)
    (def-keymap (mode n) (buffer bufnr) :K vim.lsp.buf.hover)
    (def-keymap (mode n) (buffer bufnr) :<C-k> vim.lsp.buf.signature_help)
    (def-keymap (mode n) (buffer bufnr) :gD vim.lsp.buf.declaration)
    (def-keymap (mode n) (buffer bufnr) :gd vim.lsp.buf.definition)
    (def-keymap (mode n) (buffer bufnr) :<leader>D vim.lsp.buf.type_definition)
    (def-keymap (mode n) (buffer bufnr) :<leader>I vim.lsp.buf.implementation)
    (def-keymap (mode n) (buffer bufnr) :<leader>R vim.lsp.buf.references)
    (def-keymap (mode n) (buffer bufnr) :<leader>e vim.diagnostic.open_float)
    (def-keymap (mode n) (buffer bufnr) :<leader>q vim.diagnostic.setloclist)
    (def-keymap (mode n) (buffer bufnr) :<leader>r vim.lsp.buf.rename)
    (def-keymap (mode n) (buffer bufnr) :<leader>a vim.lsp.buf.code_action)
    (def-keymap (mode x) (buffer bufnr) :<leader>a vim.lsp.buf.range_code_action)
    (def-keymap (mode n) (buffer bufnr) :<leader>wa vim.lsp.buf.add_workspace_folder)
    (def-keymap (mode n) (buffer bufnr) :<leader>wr vim.lsp.buf.remove_workspace_folder)
    (def-keymap (mode n) (buffer bufnr) :<leader>wl #(print (vim.inspect (vim.lsp.buf.list_workspace_folders))))
    (def-keymap (mode n) (buffer bufnr) :<leader>s fzf.lsp_document_symbols)
    (def-keymap (mode n) (buffer bufnr) :<leader>S fzf.lsp_live_workpace_symbols)

    (let [bulb (require :nvim-lightbulb)]
      (def-autocmd ([:CursorHold :CursorHoldI] (buffer bufnr)) bulb.update_lightbulb))

    (let [caps client.server_capabilities]
      (when caps.documentHighlightProvider
        (def-autocmd ([:CursorHold :CursorHoldI] (buffer bufnr)) vim.lsp.buf.document_highlight)
        (def-autocmd (:CursorMoved (buffer bufnr)) vim.lsp.buf.clear_references))
      (when caps.codeLensProvider
        (def-autocmd ([:BufEnter :CursorHold :InsertLeave] (buffer bufnr)) vim.lsp.codelens.refresh))
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
  (lsp-config.sumneko_lua.setup {: on_attach : capabilities : flags})
  (lsp-config.tsserver.setup {: on_attach : capabilities : flags})
  (lsp-config.texlab.setup {: on_attach : capabilities : flags})
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
            ; :core.norg.dirman {:config {:workspaces
            ;                             {:home "~/Documents/neorg"}
            ;                             }}
            ; :core.gtd.base {:config {:workspace :home}}
            }}))

; {{{1 C / C++
(def-augroup rc-ft-c-cpp
             (:FileType [:c :cpp]) #(set-opt-local cinoptions &append ":0"  "(0"))

; {{{1 Python
(fn ft-python []
  (let [py-cmd "import sys\nfor p in sys.path:\n if p: print(p)"
        (ok? py-path) (pcall vim.fn.systemlist ["python3" "-c" py-cmd])]
    (when ok?
      (set-opt-local path ["." (unpack py-path)]))))

(def-augroup rc-ft-python (:FileType :python) ft-python)

; {{{1 Fennel
(do
  (local delimiters {")" "(" "]" "[" "}" "{"})
  (local specials {"let" true "fn" true "lambda" true "λ" true "when" true
                   "eval-compiler" true "for" true "each" true "while" true
                   "macro" true "match" true "doto" true "with-open" true
                   "collect" true "icollect" true "accumulate" true})

  (fn symbol-at [line pos]
    (-> line
        (: :sub pos)
        (: :match "[^%s]+")))

  (fn find-string-start [line end-quote-pos]
    (var quote-pos nil)
    (var state :in-string)
    (for [pos (- end-quote-pos 1) 1 -1 &until (= state :end)]
      (match (values (line:sub pos pos) state)
        ("\"" _) (do (set quote-pos (- pos 1))
                     (set state :maybe-quote))
        ("\\" :maybe-quote) (set state :escaped-quote)
        ("\\" :escaped-quote) (set state :maybe-quote)
        (_ :maybe-quote) (set state :end)
        _ (set state :in-string)))
    quote-pos)

  (fn line-indent-type [stack line pos]
    (let [c (line:sub pos pos)
          delimiter (. stack (length stack))]
      (if (= pos 0) nil
          ;; if we find a new string, try finding its starting quote
          (= c "\"") (let [string-start (find-string-start line pos)]
                       (when string-start
                         (line-indent-type stack line string-start)))
          ;; if we find the delimiter we're looking for, stop looking
          (= c delimiter) (do (table.remove stack)
                              (line-indent-type stack line (- pos 1)))
          ;; if we find a new form, start looking for the delimiter that begins it
          (. delimiters c) (do (table.insert stack (. delimiters c))
                               (line-indent-type stack line (- pos 1)))
          ;; if we're looking for a delimiter, skip everything till we find it
          delimiter (line-indent-type stack line (- pos 1))
          ;; if we hit an opening table char, we're in a table!
          (or (= c "[") (= c "{")) (values :table pos)
          ;; if we hit an open paren, we're in a call!
          (= c "(") (values :call pos (symbol-at line (+ pos 1)))
          (line-indent-type stack line (- pos 1)))))

  (fn find-comment-start [line]
    (var semicolon-pos nil)
    (var state :normal)
    (for [pos 1 (length line) &until semicolon-pos]
      (match (values (line:sub pos pos) state)
        (";" :normal) (set semicolon-pos (- pos 1))
        (_ :escaping) (set state :in-string)
        ("\\" :in-string) (set state :escaping)
        ("\"" :in-string) (set state :normal)
        ("\"" :normal) (set state :in-string)))
    semicolon-pos)

  (fn indent-type [stack lines line-num]
    (let [line (. lines line-num)
          line-length (or (find-comment-start line) (length line))]
      (match (line-indent-type stack line line-length)
        (:table pos) (values :table pos)
        (:call pos fn-name) (if (. specials fn-name)
                              (values :special (- pos 1))
                              (values :call (- pos 1) fn-name))
        (where _ (> line-num 1)) (indent-type stack lines (- line-num 1)))))

  (fn _G.rc_ft_fennel_indentexpr [line-num]
    (let [lines (vim.api.nvim_buf_get_lines 0 0 line-num true)]
      (match (indent-type [] lines (- line-num 1))
        (:table delimiter-pos) delimiter-pos
        (:special prev-indent) (+ prev-indent 2)
        (:call prev-indent fn-name) (+ prev-indent (length fn-name) 2)
        _ 0))))

(fn ft-fennel []
  (set-opt-local expandtab)
  (set-opt-local shiftwidth 2)
  (set-opt-local softtabstop 2)
  (set-opt-local suffixesadd ".fnl")
  (set-opt-local iskeyword
                 ["33-255" "^(" "^)" "^{" "^}" "^[" "^]" "^\"" "^'" "^~" "^;" "^," "^@-@" "^`" "^." "^:"])
  (set-opt-local include "(\\s*require")
  (set-opt-local comments "n:;")
  (set-opt-local commentstring "; %s")
  (set-opt-local indentkeys ["!^F" :o :O])
  (set-opt-local indentexpr "v:lua.rc_ft_fennel_indentexpr(v:lnum)"))

(set vim.g.sexp_filetypes :fennel)
(def-augroup rc-ft-fennel (:FileType :fennel) ft-fennel)

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
