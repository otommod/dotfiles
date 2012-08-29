" vim:fdm=marker:
set nocompatible

" Encoding {{{
    set encoding=utf-8
    set fileencoding=utf-8
    set termencoding=utf-8
" }}}

filetype off
set runtimepath+=~/.vim/bundle/vundle/
set runtimepath+=~/.vim/bundle/tmux/
set runtimepath+=~/.vim/bundle/dircolors/
call vundle#rc()

" Bundle {{{
    " Brief help
    " :BundleList          - list configured bundles
    " :BundleInstall(!)    - install(update) bundles
    " :BundleSearch(!) foo - search(or refresh cache first) for foo
    " :BundleClean(!)      - confirm(or auto-approve) removal of unused bundles
    "
    " see :h vundle for more details or wiki for FAQ
    " NOTE: comments after Bundle command are not allowed.

    " Let vundle handle itself
    Bundle 'gmarik/vundle'

    Bundle 'fholgado/minibufexpl.vim'
    Bundle 'nathanaelkane/vim-indent-guides'
    Bundle 'ervandew/supertab'
    Bundle 'Lokaltog/vim-powerline'
    Bundle 'altercation/vim-colors-solarized'

    " Python {{{
        Bundle 'Townk/vim-autoclose'
        Bundle 'vim-scripts/pythoncomplete'
        "Bundle 'sontek/rope-vim'
    " }}}

    " Syntax {{{
        Bundle 'satyrius/python.vim'
        Bundle 'rainux/vim-vala'
        Bundle 'smancill/conky-syntax.vim'
        Bundle 'vim-scripts/cue.vim'
    " }}}

    Bundle 'Townk/vim-autoclose'
    Bundle 'vim-scripts/taglist.vim'
    Bundle 'vim-scripts/TaskList.vim'
    Bundle 'wincent/Command-T'
    Bundle 'tpope/vim-fugitive'
    Bundle 'tpope/vim-surround'
    Bundle 'scrooloose/nerdtree'
    Bundle 'jistr/vim-nerdtree-tabs'
    "Bundle 'Raimondi/delimitMate'
    Bundle 'sjl/gundo.vim'
    Bundle 'kien/ctrlp.vim'
    Bundle 'MarcWeber/vim-addon-mw-utils'
    Bundle 'tomtom/tlib_vim'
"    Bundle 'honza/snipmate-snippets'
    Bundle 'garbas/vim-snipmate'
    Bundle 'kien/rainbow_parentheses.vim'
    Bundle 'tmhedberg/matchit'
    Bundle 'scrooloose/nerdcommenter'
" }}}

filetype on
filetype plugin on
filetype indent on

syntax enable

" Files {{{
    set swapfile
    set undofile
    set backup
    set undodir=~/.vim/directories/undo
    set backupdir=~/.vim/directories/backup//
    set directory=~/.vim/directories/swap//
    set viminfo+=n~/.vim/directories/viminfo
" }}}

set history=50    " keep 50 commands in history
set number        " display line numbers
set ruler         " whatever
set showmatch     " show matching pairs, like parentheses
set matchtime=2   " 
set wildmenu      " 
set wildmode=longest:full,full
set autoread      " re-read the file when opened from the outside
set incsearch     " search while you type
set hlsearch      " highlight matched strings
set wrapscan      " searches wrap around the end of file
set laststatus=2  " always show status line
set t_Co=256      " 
set backspace=indent,eol,start
set equalalways   " make splits equal size
set shellslash    " always use forward slash
set modeline      " 
set mouse=a      " 
set ignorecase    " ignores case when searching
set smartcase     " 
set magic         " 
set autoread      " 
set lazyredraw    " 
set equalalways   " 
set showcmd       " 
set ttyfast       " 
set showcmd       " 
set mousehide     " 
set showmode      " 
set equalalways   " 
set listchars=tab:▸\ ,eol:¬ " 

" Python {{{
    autocmd FileType python set textwidth=78
    autocmd FileType python set tabstop=4
    autocmd FileType python set softtabstop=4
    autocmd FileType python set shiftwidth=4
    autocmd FileType python set expandtab
    autocmd FileType python set autoindent
    autocmd FileType python set omnifunc=pythoncomplete#Complete
" }}}

set completeopt=menuone,longest,preview
set hidden         " 
set title          " 
set scrolloff=5  " 
set foldcolumn=2 " 

set tabstop=8     " 
set shiftwidth=4  " 
set shiftround    " use multiple of shiftwidth when indenting with '<' and '>'
set expandtab     " 
set softtabstop=4 " 
set autoindent    " 

" Plugins {{{
    " Solarized {{{
        let g:solarized_hitrail = 1
        call togglebg#map("")
    " }}}

    " MiniBufExplorer {{{
        let g:miniBufExplMapWindowNavVim = 1
        let g:miniBufExplMapWindowNavArrows = 1
    " }}}

    " Powerline {{{
        let g:Powerline_symbols = 'fancy'
        let g:Powerline_stl_path_style = 'short'
        "let g:Powerline_colorscheme = 'skwp'
        "let g:Powerline_theme = 'skwp'
    " }}}

    " NERDTreeTabs {{{
        let g:nerdtree_tabs_open_on_gui_startup = 0
    "}}}

    " SuperTab {{{
        let g:SuperTabDefaultCompletionType = 'context'
        let g:SuperTabLongestEnhanced = 1
        let g:SuperTabLongestHighlight = 1
    " }}}

    " Indent Guides {{{
        let g:indent_guides_enable_on_vim_startup = 1
        let g:indent_guides_start_level = 2
        let g:indent_guides_guide_size = 1
    " }}}

    " Ropevim {{{
        let ropevim_vim_completion = 1
        let ropevim_extended_complete = 1
    " }}}

    " Python.vim {{{
        let python_highlight_all = 1
    " }}}        
" }}}

au! BufWritePost .vimrc source %

if has('gui_running')
    set lines=50
    set columns=100
    set guifont=Inconsolata
    set background=dark
    colorscheme solarized
endif
