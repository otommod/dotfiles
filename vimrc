" vim:fdm=marker:
" Author: Otto Modinos <ottomodinos@gmail.com>

set shellslash     " always use forward slash as path separator
if has('multi_byte')
    set encoding=utf-8       " Use UTF-8 as ViM's internal encoding
    scriptencoding utf-8     " Specify that this file is UTF-8
endif


" Helper functions {{{1
" TODO: consider a cross-platform s:download function, perhaps using netrw

function! s:echohl(hl, msg)            " {{{2
    exec 'echohl' a:hl
    echo a:msg
    echohl None
endfunction

function! s:some(arr)                  " {{{2
    for elem in a:arr
        if elem | return 1 | endif
    endfor
    return 0
endfunction

function! s:every(arr)                 " {{{2
    for elem in a:arr
        if !elem | return 0 | endif
    endfor
    return 1
endfunction

function! s:has_plugin(...)            " {{{2
    return s:every(map(copy(a:000), 'has_key(g:plugs, v:val)'))
endfunction

function! s:path_exists(path)          " {{{2
    return !empty(glob(a:path, 1, 1))
endfunction

function! s:makedirs(path)             " {{{2
    if !exists('*mkdir')
        echoerr "This ViM doesn't support '*mkdir'" | return
    endif

    let path = resolve(a:path)
    if isdirectory(path) | return | endif
    try
        call mkdir(path, 'p')
    catch /E739/
        let [_, exc, errmsg; rest] = split(v:exception, ': ')
        let excpath = join(rest, ': ')
        let [path, excpath] = [substitute(path, '/*$', '', ''),
                             \ substitute(excpath, '/*$', '', '')]

        " If the exception was raised for the path we are trying to create
        " that means it exists but it is not a directory.  If it was not, that
        " means that some subpath exists but is not a directory
        if path ==# excpath
            echoerr "cannot create '".path."': File exists"
        else
            echoerr "cannot create '".path."': Not a directory"
        endif
    endtry
endfunction

" Pre-Preamble     {{{1
if has('win32') | let $VIMDIR = expand('~/vimfiles')  |
else            | let $VIMDIR = expand('~/.vim')      | endif

" Auto-install plug.vim if needed
if !s:path_exists('$VIMDIR/autoload/plug.vim')
    call s:makedirs(expand('$VIMDIR/autoload'))
    silent !curl -fL
        \ -o "$VIMDIR/autoload/plug.vim"
        \ "https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim"

    au VimEnter * PlugInstall
endif

call plug#begin('$VIMDIR/plugged')

" Plugins          {{{1
" Plug 'editorconfig/editorconfig-vim'
Plug 'sgur/vim-editorconfig'

" File explorers        {{{2
    " Plug 'tpope/vim-vinegar'

    " XXX: disable netrw
    let g:loaded_netrw       = 1
    let g:loaded_netrwPlugin = 1

    Plug 'justinmk/vim-dirvish'
    " Plug 'scrooloose/nerdtree'
    " Plug 'Xuyuanp/nerdtree-git-plugin'
" Window management     {{{2
    " Plug 'szw/vim-ctrlspace'
    " Plug 'spolu/dwm.vim'
    " Plug 'zhamlin/tiler.vim'
    " Plug 'roman/golden-ratio'
    " Plug 't9md/vim-choosewin'
    " Plug 'troydm/zoomwintab.vim'
    Plug 'dr-chip-vim-scripts/ZoomWin'
" Buffer management     {{{2
    Plug 'moll/vim-bbye'
" Fixes                 {{{2
    " Plug 'tpope/vim-rsi'
    " Plug 'Konfekt/FastFold'
    " Plug 'justinmk/vim-ipmotion'
    " Plug 'drmikehenry/vim-fixkey'
    Plug 'ConradIrwin/vim-bracketed-paste'
    " Plug 'ap/vim-you-keep-using-that-word'
" Distraction-free      {{{2
    " Plug 'junegunn/goyo.vim'
    " Plug 'junegunn/limelight.vim'
" Rainbow parentheses   {{{2
    " Plug 'kien/rainbow_parentheses.vim'
    " Plug 'losingkeys/vim-niji'
    Plug 'luochen1990/rainbow'
" Eye candy             {{{2
    Plug 'myusuf3/numbers.vim'
    Plug 'ntpeters/vim-better-whitespace'
    " Plug 'Yggdroot/indentLine'
    Plug 'thaerkh/vim-indentguides'
    " Plug 'itchyny/vim-cursorword'
    " Plug 'qstrahl/vim-matchmaker'
    Plug 'chrisbra/Colorizer'
    " Plug 'RRethy/vim-hexokinase'
    " Plug 'boucherm/ShowMotion'
" Colorschemes          {{{2
    " Light {{{3
        " Plug 'daddye/soda.vim'
        Plug 'notpratheek/vim-sol'
    " Dark {{{3
        Plug 'sjl/badwolf'
        Plug 'fneu/breezy'
        " Plug 'tomasr/molokai'
        Plug 'gregsexton/Muon'
        " Plug 'sstallion/vim-wtf'
        " Plug 'abra/vim-obsidian'
        " Plug 'dikiaap/minimalist'
        " Plug 'notpratheek/vim-luna'
        " Plug 'kabbamine/yowish.vim'
        " Plug 'joshdick/onedark.vim'
        " Plug 'nanotech/jellybeans.vim'
        " Plug 'AlessandroYorba/Despacio'
        Plug 'drewtempelmeyer/palenight.vim'
        " Plug 'mitsuhiko/fruity-vim-colorscheme'
    " Both {{{3
        Plug 'w0ng/vim-hybrid'
        " Plug 'morhetz/gruvbox'
        " Plug 'josuegaleas/jay'
        " Plug 'jacoborus/tender.vim'
        " Plug 'junegunn/seoul256.vim'
        " Plug 'chriskempson/base16-vim'
        " Plug 'noahfrederick/vim-hemisu'
        " Plug 'reedes/vim-colors-pencil'
        " Plug 'NLKNguyen/papercolor-theme'
        Plug 'chriskempson/vim-tomorrow-theme'
        " Plug 'owickstrom/vim-colors-paramount'
        Plug 'altercation/vim-colors-solarized'
" Syntax                {{{2
    " Plug 'justinmk/vim-syntax-extra'
    Plug 'hdima/python-syntax'
    Plug 'mgrabovsky/vim-cuesheet'
    " Plug 'baskerville/vim-sxhkdrc'
    " Plug 'smancill/conky-syntax.vim'
    Plug 'otommod/twee-sugarcube.vim'
" Autoclose pairs       {{{2
    " Plug 'Raimondi/delimitMate'
    " Plug 'kana/vim-smartinput'
    " Plug 'jiangmiao/auto-pairs'
    " Plug 'tpope/vim-endwise'
" Snippets              {{{2
    " Plug 'SirVer/ultisnips'
    " Plug 'honza/snipmate-snippets'
" VCSs                  {{{2
    Plug 'tpope/vim-fugitive'
    Plug 'tpope/vim-rhubarb'
    " Plug 'jreybert/vimagit'
    " Plug 'lambdalisue/vim-gita'
    " Plug 'junegunn/gv.vim'
    " Plug 'gregsexton/gitv'
    " Plug 'kablamo/vim-git-log'
    " Plug 'mhinz/vim-signify'
    Plug 'airblade/vim-gitgutter'
" Search enhancements   {{{2
    " Plug 'ramele/agrep'
    " Plug 'wincent/ferret'
    " Plug 'mhinz/vim-grepper'
    " Plug 'pelodelfuego/vim-swoop'
    " Plug 'google/vim-searchindex'
    Plug 'henrik/vim-indexed-search'
    " Plug 'romainl/vim-cool'
    " Plug 'junegunn/vim-slash'
    " Plug 'haya14busa/incsearch.vim'
" Statusline            {{{2
    " Plug 'ap/vim-buftabline'
    " Plug 'itchyny/lightline.vim'
    Plug 'vim-airline/vim-airline'
    Plug 'vim-airline/vim-airline-themes'
    " Plug 'powerline/powerline', {'rtp': 'powerline/bindings/vim'}
" Objects & Operators   {{{2
    " Dependencies
    " Plug 'kana/vim-textobj-user'
    Plug 'kana/vim-operator-user'

    " Operators
    " Plug 'tpope/vim-surround'
    " Plug 'machakann/vim-sandwich'
    Plug 'rhysd/vim-operator-surround'

    " Text objects
    " Plug 'kana/vim-textobj-indent'
    " Plug 'glts/vim-textobj-comment'
    " Plug 'reedes/vim-textobj-quote'
    " Plug 'thinca/vim-textobj-between'
    " Plug 'AndrewRadev/sideways.vim'
    Plug 'PeterRincker/vim-argumentative'
    " Plug 'adriaanzon/vim-textobj-matchit'
    " Plug 'lucapette/vim-textobj-underscore'
    " Plug 'coderifous/textobj-word-column.vim'
    " XXX: I like the 'next' object stuff, dunno about the rest
    " Plug 'wellle/targets.vim'

    " Plug 'bps/vim-textobj-python'
    " Plug 'rbonvall/vim-textobj-latex'
" Warm and fuzzy        {{{2
    Plug 'junegunn/fzf'
    Plug 'junegunn/fzf.vim'
    " Plug 'Shougo/denite.nvim'
" Alignment             {{{2
    " Plug 'tommcdo/vim-lion'
    " Plug 'godlygeek/tabular'
    " Plug 'junegunn/vim-easy-align'
" Autocompletion        {{{2
    " Plug 'ajh17/VimCompletesMe'
    Plug 'lifepillar/vim-mucomplete'
    " Plug 'Shougo/deoplete.nvim'
    " Plug 'Valloric/YouCompleteMe'
" Filetype Specific     {{{2
" Python                     {{{3
    Plug 'fisadev/vim-isort',            {'for': 'python'}
    Plug 'davidhalter/jedi-vim',         {'for': 'python'}
    " Plug 'python-rope/ropevim',          {'for': 'python'}
    " Plug 'tweekmonster/django-plus.vim'
    " TODO: Consider writing a folding plugin
    " Plug 'tmhedberg/SimpylFold'
    " Plug 'vim-scripts/Efficient-python-folding'
" Go                         {{{3
    Plug 'fatih/vim-go'
    " Plug 'arp242/gopher.vim', {'for': 'go'}
    Plug 'rhysd/vim-goyacc'
" C/C++                      {{{3
    Plug 'Rip-Rip/clang_complete', {'for': ['c', 'cpp']}
" Elixir                     {{{3
    " Plug 'slashmili/alchemist.vim', {'for': 'elixir'}
" OCaml                      {{{3
    " Plug 'vim-scripts/omlet.vim', {'for': 'ocaml'}
" Clojure                    {{{3
    " Plug 'guns/vim-clojure-static',    {'for': 'clojure'}
    " Plug 'guns/vim-clojure-highlight', {'for': 'clojure'}
    " Plug 'guns/vim-sexp',              {'for': 'clojure'}
    " Plug 'tpope/vim-sexp-mappings-for-regular-people', {'for': 'clojure'}
    " Plug 'tpope/vim-fireplace',        {'for': 'clojure'}
    " Plug 'tpope/vim-leiningen',        {'for': 'clojure'}
" XML/HTML                   {{{3
    let XMLFiletypes = [
        \ 'xml',
        \ 'html',
        \ 'htmldjango',
        \ 'jinja2'
    \ ]
    Plug 'gregsexton/MatchTag', {'for': XMLFiletypes}
" }}}2

    Plug 'liuchengxu/vim-which-key'

    Plug 'metakirby5/codi.vim'
    Plug 'majutsushi/tagbar'
    " Plug 'simnalamburt/vim-mundo'
    Plug 'mbbill/undotree'
    Plug 'mtth/scratch.vim'

    " Plug 'tpope/vim-projectionist'
    " Plug 'terryma/vim-multiple-cursors'
    Plug 'tpope/vim-unimpaired'

    " Plug 'tpope/vim-dispatch/'
    " Plug 'skywind3000/asyncrun.vim'
    " Plug 'neomake/neomake'
    Plug 'w0rp/ale'

    runtime macros/matchit.vim
    " Plug 'andymass/vim-matchup'

    Plug 'tpope/vim-repeat'
    Plug 'tpope/vim-commentary'
    Plug 'justinmk/vim-sneak'
    Plug 'unblevable/quick-scope'
    " Plug 'Lokaltog/vim-easymotion'
    " Plug 'jeetsukumaran/vim-indentwise'

    Plug 'tommcdo/vim-exchange'
    Plug 'matze/vim-move'
    " Plug 'zirrostig/vim-schlepp'
    " Plug 'natemaia/DragVisuals'

    let g:markdown_fenced_languages = ["viml=vim"]

    " Plug 'vim-pandoc/vim-pandoc-syntax'
    Plug 'vim-pandoc/vim-pandoc'
    Plug 'vim-pandoc/vim-pandoc-after'
    " Plug 'dhruvasagar/vim-table-mode'
    " Plug 'clarke/vim-renumber'
    " Plug 'JamshedVesuna/vim-markdown-preview'
    " Plug 'previm/previm'

    " Plug 'jceb/vim-orgmode'
    " Plug 'vimoutliner/vimoutliner'
    " Plug 'lukaszkorecki/workflowish'
    " Plug 'fmoralesc/vim-pad'

    " Plug 'xolox/vim-misc'
    " Plug 'xolox/vim-notes'

    " Plug 'vimwiki/vimwiki'
    " Plug 'tbabej/taskwiki'
    " Plug 'lervag/wiki.vim'
    " Plug 'lervag/wiki-ft.vim'
    " Plug 'fcpg/vim-waikiki'
   let g:wiki_root = '~/vimwiki'

    " Plug 'bruno-/vim-man'
    " Plug 'LucHermitte/lh-tags'
    " Plug 'xuhdev/SingleCompile'
    Plug 'ludovicchabant/vim-gutentags'

    " Plug 'takac/vim-hardtime'
    Plug 'lyokha/vim-xkbswitch'
    Plug 'drmikehenry/vim-fontdetect'

    " XXX: Needs to be after all the other syntax plugins
    Plug 'sheerun/vim-polyglot'
    let g:polyglot_disabled = ["markdown"]

    " Vimscript libraries
    " Plug 'romgrk/lib.kom'
    " Plug 'prabirshrestha/async.vim'

" Preamble         {{{1
call plug#end()

filetype on
filetype plugin on
filetype indent on

syntax enable

" ViM Options      {{{1
" Swap, undo, etc       {{{2
    set backup     " save backups
    set undofile   " save undos (persistent undo)
    set swapfile   " use swapfiles

    set backupdir=$VIMDIR/tmp/backup//
    set undodir=$VIMDIR/tmp/undo//
    set directory=$VIMDIR/tmp/swap//

    if !has('nvim')
    set viminfo+=n$VIMDIR/tmp/viminfo
    endif

    call s:makedirs(&backupdir)
    call s:makedirs(&undodir)
    call s:makedirs(&directory)

" Wildcompltetion       {{{2
    set wildmode=longest:full,full     " command-line completion
if has('wildmenu')
    set wildmenu                       " enhanced command-line completion
endif
if has('wildignore')
    set wildignore+=*/.git/*,*/.hg/*,*/.svn/*    " version control directories
    set wildignore+=*.DS_Store                   " OS X things
    set wildignore+=*.sw?                        " vim swap files

    " Binary files           {{{3
    set wildignore+=*.o,*.obj,*.exe,*.dll        " object files
    set wildignore+=*.pyc,*.pyo,*/__pycache__/*  " Python bytecode
    set wildignore+=*.class                      " Java bytecode

    set wildignore+=*.mp3,*.flac                 " music files
    set wildignore+=*.jp?g,*.png,*.gif,*.bmp     " images
    set wildignore+=*.mkv,*.mp4,*.avi            " videos

    " Archives               {{{3
    set wildignore+=*.tar                        " tar archives
    set wildignore+=*.tar.gz,*.tgz               " gzip compresser archives
    set wildignore+=*.tar.bz2,*.tbz,*.tbz2       " bzip2 compressed archives
    set wildignore+=*.tar.xz,*.txz               " xz compressed archives
    set wildignore+=*.zip,*.rar                  " other archives

    " Large directories      {{{3
    " set wildignore+=~/.cache/*
    " set wildignore+=~/.local/share/Steam/*

    let g:large_directories = [
                \ '~/.cache',
                \ '~/.local/share/Steam',
                \ ]

    " for dir in g:large_directories
    "     let &wildignore .= ','.expand(dir).'/*'
    " endfor
endif
" }}}2

set history=500    " keep 500 commands in history
set number         " display line numbers
set showmatch      " show matching pairs, like parentheses
set matchtime=5    " tenths of seconds to show the matching paren
set autoread       " re-read the file when changed outside of vim
set wrapscan       " searches wrap around the end of file
set laststatus=2   " always show status line
set backspace=indent,eol,start         " backspace over everything!
set equalalways    " make new splits equal size
set modeline       " allow modeline execution
set mouse=a        " enable mouse for all modes (Normal, Insert, etc)
set ignorecase     " ignores case when searching
set smartcase      " only match case when it exists
set magic          " allow 'magic' regexps
set noshowmode     " have powerline for that
set hidden         " unshown buffers are not closed when hidden
set list           " show nice little characters
set listchars=eol:¬,tab:»\ ,trail:·,extends:❯,precedes:❮,nbsp:␣
set scrolloff=5    " always keep the cursor 5 lines from the end of the screen

set nrformats+=alpha    " incr/decr alphabetic characters
set nrformats-=octal    " numbers starting with zero aren't octal
set formatoptions+=j    " remove comment leaders when joining lines

" XXX: fix these
set tabstop=8      " 
set softtabstop=4  " 
set expandtab      " 
set shiftwidth=4   " 
set shiftround     " use multiple of shiftwidth when indenting with < and >
set autoindent     " 

set lazyredraw     " do not redraw while executing commands
set ttyfast        " I have a fast connection to my tty

" FIXME:
if $TERM =~ 'st'
    if !has('nvim')
    set ttymouse=xterm
    endif

    " termguicolors
    " set termguicolors
    let &t_8f = "\<Esc>[38;2;%lu;%lu;%lum"
    let &t_8b = "\<Esc>[48;2;%lu;%lu;%lum"

    " guicursor-like
    " let &t_EI = "\<Esc>[0 q"
    " let &t_SI = "\<Esc>[5 q"
    " let &t_SR = "\<Esc>[3 q"
endif

if executable('rg')
    set grepprg=rg\ --vimgrep
    set grepformat=%f:%l:%c:%m,%f:%l:%m
elseif executable('ag')
    set grepprg=ag\ --vimgrep
    set grepformat=%f:%l:%c:%m,%f:%l:%m
elseif executable('grep')
    call system('grep --version')
    if !v:shell_error   " GNU grep
        set grepprg=grep\ -nH\ -r
        set grepformat=%f:%l:%m
    endif
endif

" title            " set the terminal title
" showcmd          " show command in the last line of the screen
" incsearch        " search while you type
" hlsearch         " highlight matched strings
" splitright       " new vertical splits are put on the right
" virtualedit=block" allow virtual-block past the line end
" colorcolumn=80   " a highlighted column at the 80 char mark
" cursorline       " highlights the screen line of the cursor
" showbreak=↪\     " shows up on a wrapped line
" fillchars=vert:│ " used to separate vertical splits
" completeopt=menuone,longest,preview
" foldcolumn=2     " a 2-char wide column indicating open and closed folds
" concealcursor=nc " don't conceal the cursor line in visual and insert mode

if has('title')            | set title             | endif
if has('cmdline_info')     | set showcmd           | endif
if has('extra_search')     | set incsearch         | set hlsearch       | endif
if has('vertsplit')        | set splitright        | endif
if has('virtualedit')      | set virtualedit=block | endif
if has('syntax')           | set cursorline        | set colorcolumn=80 | endif
if has('linebreak')        | set showbreak=↪\      | endif
if has('folding')          | set foldcolumn=2      | endif
if has('windows') && has('folding') | set fillchars=vert:│              | endif
if has('insert_expand')    | set completeopt=menu,menuone,longest       | endif
if has('conceal')          | set concealcursor=nc  | endif

if has('patch-8.1.0360') || has('nvim-0.3.2')
    set diffopt=filler,internal,algorithm:histogram,indent-heuristic
endif

" GUI Options      {{{1
" TODO: move this
function! ComposeGuifont(fontsize, typeface)
    if has('gui_macvim')
        return escape(a:typeface, ',') . ':h' . a:fontsize
    elseif has('win32') || has('win64') "|| has('gui_win32') || has('gui_win64')
        return escape(a:typeface, ',') . ':h' . a:fontsize
    elseif has('gui_gtk') || has('gui_gnome')
        return escape(a:typeface, ',') . ' ' . a:fontsize
    endif
    return ''
endfunction

function! SetupGUI()
if has('gui_mac')
    set antialias  " antialized goodness
endif

set mousehide      " hide the mouse pointer when typing on the GUI
set guicursor+=n-v-c:blinkon0          " un-blink the cursor in some modes
set guioptions+=c  " use console dialogs
set guioptions-=e  " text tabs
set guioptions-=m  " no menu
set guioptions-=t  " no tearoff menus
set guioptions-=T  " no toolbar (the one with the icons)

let &guifont = ComposeGuifont(
    \   13,
    \   fontdetect#firstFontFamily(['Inconsolata',
    \                               'Anonymous Pro',
    \                               'Fantasque Sans Mono',
    \                               'Cousine',
    \                               'monofur',
    \                               'Monaco',
    \                               'Consolas' ]))
endfunction

" Plugin Options   {{{1
" bufline               {{{2
let g:bufline_separator = '  '
" let g:bufline_fmt_fnamemodify = ':p:~:.:gs#\v/(.)[^/]*\ze/#/\1#'

" buftabline            {{{2
let g:buftabline_show = 1
let g:buftabline_numbers = 1
let g:buftabline_indicators = 1
let g:buftabline_separators = 1

" airline               {{{2
let g:airline_powerline_fonts = 1
let g:airline_mode_map = {
    \ '__' : '-',
    \ 'n'  : 'n',
    \ 'i'  : 'i',
    \ 'R'  : 'R',
    \ 'v'  : 'v',
    \ 'V'  : 'V',
    \ '' : '^v',
    \ 'c'  : 'c',
    \ 's'  : 's',
    \ 'S'  : 'S',
    \ '' : '^s',
\ }

let g:airline#parts#ffenc#skip_expected_string = 'utf-8[unix]'


" Extensions
let g:airline#extensions#whitespace#enabled = 1

" quickfix
let g:airline#extensions#quickfix#enabled = 1
let g:airline#extensions#quickfix#quickfix_text = 'Quickfix'

" tabline
let g:airline#extensions#tabline#enabled = 0

let g:airline#extensions#tabline#right_alt_sep = '|'

let g:airline#extensions#tabline#show_tabs = 0
let g:airline#extensions#tabline#buffers_label = 'b'
let g:airline#extensions#tabline#buffer_min_count = 2
" let g:airline#extensions#tabline#formatter = 'unique_tail_improved'
let g:airline#extensions#tabline#formatter = 'unique_tail'
let g:airline#extensions#tabline#buffer_nr_show = 1
let g:airline#extensions#tabline#buffer_nr_format = '%s:'
let g:airline#extensions#tabline#fnamecollapse = 1
let g:airline#extensions#xkblayout#enabled = 0

" hunks
let g:airline#extensions#hunks#enabled = 1

" CtrlSpace             {{{2
let g:ctrlspace_use_tabline = 1
let g:ctrlspace_unicode_font = 1
let g:ctrlspace_show_unnamed = 1

" Tagbar                {{{2
let g:tagbar_sort = 0
let g:tagbar_singleclick = 1
let g:tagbar_iconchars = ['▸', '▾']
" let g:tagbar_expand = 2  " FIXME: Doesn't work in terminal

" NERDTree              {{{2
let NERDTreeMinimalUI = 1
let g:nerdtree_tabs_open_on_gui_startup = 0

" fzf                   {{{2
if executable('rg')
    let $FZF_DEFAULT_COMMAND = "rg --files --hidden --glob '!.git'"
endif

" indexed-search        {{{2
let g:indexed_search_dont_move = 1
let g:indexed_search_center = 1
let g:indexed_search_n_always_searches_forward = 1

" better-whitespace     {{{2
let g:better_whitespace_filetypes_blacklist = ['help', 'vim-plug']

" interestingWords      {{{2
let g:interestingWordsRandomiseColors = 0

" indentLine            {{{2
let g:indentLine_faster = 1
let g:indentLine_char = '┊'
let g:indentLine_concealcursor = 'nc'  " XXX: this sets 'concealcursor'

" cursorword            {{{2
let g:cursorword = 1

" Matchmaker            {{{2
let g:matchmaker_enable_startup = 1

" gitgutter             {{{2
let g:gitgutter_sign_added = '∙'
let g:gitgutter_sign_modified = '∙'
let g:gitgutter_sign_removed = '∙'
let g:gitgutter_sign_modified_removed = '∙'

" python-syntax         {{{2
let python_highlight_all = 1

" go-mode               {{{2
let g:go_highlight_types = 1
let g:go_highlight_extra_types = 1
let g:go_highlight_functions = 1
" let g:go_highlight_function_parameters = 1
" let g:go_highlight_function_calls = 1
" let g:go_highlight_fields = 1
" let g:go_highlight_operators = 1
" let g:go_highlight_variable_declerations = 1
" let g:go_highlight_variable_assignments = 1
let g:go_highlight_build_constraints = 1
let g:go_highlight_generate_tags = 1

let g:go_auto_sameids = 1
let g:go_auto_type_info = 1

" vim-javascript        {{{2
let g:javascript_plugin_jsdoc = 1
let g:javascript_plugin_flow = 1

" vim-xkbswitc          {{{2
let g:XkbSwitchEnabled = 1

" Rainbow               {{{2
let g:rainbow_active = 0  " stupid dev

" Functions        {{{1
function! Pydoc(query)                 " {{{2
    let not_found_msg = printf("no Python documentation found for '%s'\n\n",
                             \ a:query)
    let cmd = 'pydoc ' . shellescape(a:query)
    if system(cmd) !=# not_found_msg
        exec "silent" "!" cmd
        redraw!
    else
        call s:echohl('ErrorMsg', not_found_msg[:-3])
    endif
endfunction


function! PythonPath(...)              " {{{2
    let pythoncmd = 'python'. get(a:000, 0, '') .' -c '
    return join(systemlist(pythoncmd
        \ . shellescape('from __future__ import print_function; import sys;'
                    \ . '[print(p) for p in sys.path if p];')), ',')
endfunction


function! PythonIncludeExpr(module)    " {{{2
    let [module, relative] = [a:module, '']

    if a:module[0] == '.'
        let i = match(a:module, '\.[^.]')  " the end of the leading dots
        let [dots, module] = [strpart(module, 1, i), strpart(module, i+1)]
        let relative = substitute(dots, '\v(^\.*)@<=\.', '../', 'g')
    endif

    return relative . substitute(module, '\.', '/', 'g')
endfunction


function! RelativeTo(path, ...)        " {{{2
    " XXX: Doesn't work!
    let path = a:path
    let start = get(a:000, 0, '.')
    let cwd = getcwd()

    exec 'noautocmd cd '.start
    let rel_path = fnamemodify(path, ':.')
    exec 'noautocmd cd '.cwd

    let i = 0
    while stridx(start, rel_path, i) == i
        let i += 2
        let rel_path = substitute(rel_path, '^/[^/]*', '..', '')
    endwhile

    return rel_path
endfunction


function! AskMakeDirs(dir)             " {{{2
    let msg = "Some directories in the filepath don't exist.  Create them?"
    if !s:path_exists(a:dir) && confirm(msg, "&Yes\n&No") == 1
        call s:makedirs(a:dir)
    endif
endfunction


function! FoldText()                   " {{{2
" https://coderwall.com/p/usd_cw

    function! s:real_numberwidth()          " {{{3
        if (&number || &relativenumber)
            if (&number)
                let lnum = line('$')
            elseif (&relativenumber && ! &number)
                let lnum = winheight(0)
            endif
            return max([&numberwidth, strlen(lnum) + 1])
        endif
        return 0
    endfunction

    function! s:expand_tabs(str)            " {{{3
        let tab_spaces = repeat(' ', &tabstop)
        return substitute(a:str, '\t', tab_spaces, 'g')
    endfunction
    " }}}3

    redir => signs
        exec 'silent sign place buffer='.bufnr('%')
    redir END

    let lpadding  = &foldcolumn
    let lpadding += (signs =~ 'id=') ? 2 : 0
    let lpadding += s:real_numberwidth()

    let start = s:expand_tabs(getline(v:foldstart))
    let end = substitute(s:expand_tabs(getline(v:foldend)), '^\s*', '', 'g')

    let lines_num = '('.(v:foldend - v:foldstart).')'
    let width = min([80, winwidth(0) - lpadding - strwidth(lines_num)])

    let start = strpart(start, 0, width - strwidth(end) - strwidth(' … '))
    let text = start . ' … ' . end

    return text . repeat(' ', width - strwidth(text)) . lines_num
endfunction


function! Term(...)                    " {{{2
    if exists('$TMUX') && get(a:000, 0, 0)  " pass-through
        return exists('$TMUX_TERM') ? $TMUX_TERM : 'xterm'
    else
        return $TERM
    endif
endfunction


function! TmuxEscape(seq)              " {{{2
    if !exists('$TMUX') | return a:seq | endif
    return printf("\<Esc>Ptmux;%s\<Esc>\\",
                \ substitute(a:seq, "\<Esc>", "\<Esc>\<Esc>", 'g'))
endfunction!


function! Terminfo(cap, ...)           " {{{2
    if !executable('tput')
        echomsg "Could not find 'tput' in $PATH" | return
    endif

    let pass_through = get(a:000, 0, 0)
    if &term !=# 'builtin_gui'
        return TmuxEscape(system(printf("tput -T %s %s",
                                      \ shellescape(Term(pass_through)),
                                      \ shellescape(a:cap))))
    endif
endfunction


function! Tput(cap, ...)               " {{{2
    silent exec '!echo' shellescape(Terminfo(a:cap, get(a:000, 0, 0)))
endfunction


" My Plugins       {{{1
function! s:def_option(optname, default)
    if !exists(a:optname)
        let {a:optname} = a:default
    endif
endfunction

" ExecRange             {{{2
" Super minimal plugin to execute a line of vimscript
function! ExecRange(line1, line2)
    exec substitute(join(getline(a:line1, a:line2), "\n"), '\n\s*\\', ' ', 'g')
    echom string(a:line2 - a:line1 + 1) . "L executed"
endfunction

command! -range ExecRange call ExecRange(<line1>, <line2>)


" ToggleQuickFix        {{{2
" A simple plugin for toggling the quickfix and location list
" http://vim.wikia.com/wiki/Toggle_to_open_or_close_the_quickfix_window
function! ToggleQuickFix(list, ...)
    " The only way to identify if any list windows are open is through the
    " functions `getqflist()` and `getloclist()`, specifically the `winid`
    " property.  We don't do that though, we just try and close the requested
    " list and see if the total number of windows changed.
    let last_winnr = winnr('$')
    exec a:list.'close'
    if last_winnr != winnr('$') | return | endif

    let current_winnr = winnr()
    exec a:list.'window'

    let go_back = get(a:000, 0, 0)
    if go_back && winnr() != current_winnr | wincmd p | endif
endfunction


" bufline               {{{2
" A minimal bufferline replacement
call s:def_option('g:bufline_ft_exclude', [])
call s:def_option('g:bufline_separator', ' ')
call s:def_option('g:bufline_highlight', 'None')
call s:def_option('g:bufline_formatter', 's:default_formatter')
call s:def_option('g:bufline_positioner', 's:default_positioner')

call s:def_option('g:bufline_fmt', '%s:%s%s')
call s:def_option('g:bufline_fmt_active', '[%s:%s%s]')
call s:def_option('g:bufline_fmt_modified', '+')
call s:def_option('g:bufline_fmt_fnamemodify', ':t')


function! s:get_bufnrs()
    let ft_exclude = g:bufline_ft_exclude
    return filter(range(1, bufnr('$')),
                \ 'buflisted(v:val) && index(ft_exclude, getbufvar(v:val, "&ft")) < 0')
endfunction

function! s:generate_buffer_labels(bufnrs)
    return map(copy(a:bufnrs), 'call(g:bufline_formatter, [v:val])')
endfunction

function! s:echo_bufline()
    let nums = s:get_bufnrs()
    let names = s:generate_buffer_labels(nums)

    let lastbuf = bufnr('$')
    let buffers = []
    for i in range(len(nums))
        let label = names[i] . (nums[i] == lastbuf ? '' : g:bufline_separator)
        call add(buffers, {'num': nums[i],
                         \ 'label': label,
                         \ 'width': strwidth(label)})
    endfor

    let columns = &columns - 12
    let line = call(g:bufline_positioner, [buffers, columns])
    let line = strpart(line, 0, columns)

    " TODO: add an option for this
    if bufname('') == 'ControlP' | return | endif

    call s:echohl(g:bufline_highlight, line)
endfunction


function! s:default_formatter(bufnr)
    let name = bufname(a:bufnr)
    let modified = getbufvar(a:bufnr, '&mod')
    let has_window = bufwinnr(a:bufnr) > 0
    let is_current = a:bufnr == bufnr('%')

    return printf(has_window && is_current ? g:bufline_fmt_active : g:bufline_fmt,
                \ a:bufnr,
                \ fnamemodify(name, g:bufline_fmt_fnamemodify),
                \ modified ? g:bufline_fmt_modified : '')
endfunction

function! s:default_positioner(buffers, max_width)
    " vim-buftabline also has some relevant code though more complex
    let curbuf = bufnr('%')
    let cum_width = 0
    for buf in a:buffers
        let cum_width += buf.width
        if buf.num == curbuf | let curbuf = buf | break | endif
    endfor
    let names = map(copy(a:buffers), 'v:val.label')
    let line = join(names, '')
    if cum_width > a:max_width
        let line = strpart(line, cum_width - a:max_width, a:max_width)
    endif
    return line
endfunction!


function! s:delayed_echo_bufline(delay)
    if exists('s:save_ut') | return | endif
    let s:save_ut = &ut

    let &ut = a:delay
    augroup bufline_delayed
        autocmd CursorHold *
            \ let &ut = s:save_ut    |
            \ unlet s:save_ut        |
            \ call s:echo_bufline()  |
            \ autocmd! bufline_delayed
    augroup END
endfunction

augroup bufline
    autocmd!

    autocmd CursorHold * call s:echo_bufline()
    " events which output a message which should be immediately overwritten
    autocmd BufWinEnter,WinEnter,InsertLeave,VimResized * call s:delayed_echo_bufline(1)
augroup END


" motioncounts          {{{2
" An easymotion-like plugin, shows the count needed to reach each word in the line
let s:MOTION_PATTERNS = {
    \ 'w': '\v(<\k|>\S|\s\zs\S)',
    \ 'b': '\v(<\k|>\S|\s\zs\S)',
    \ 'e': '\v(\k>|\S<|\S\ze\s)',
    \ 'W': '\v(\s)@<=\S',
    \ 'B': '\v(\s)@<=\S',
    \ 'E': '\v(\S\ze\s)',
\ }
let s:MOTION_FLAGS = {'w':'z', 'W':'z', 'e':'z', 'E':'z', 'b':'b', 'B':'b'}

let s:matchids = []

function! s:get_next_word(motion, line)
    return searchpos(s:MOTION_PATTERNS[a:motion], s:MOTION_FLAGS[a:motion], a:line)
endfunction

function! s:get_next_words(motion, maxwords)
    let winview = winsaveview()
    let line = winview['lnum']

    let words = []
    let word = s:get_next_word(a:motion, line)
    while len(words) < a:maxwords && word != [0, 0]
        call add(words, word)
        let word = s:get_next_word(a:motion, line)
    endwhile

    call winrestview(winview)
    return words
endfunction

function! s:clear_motion_counts()
    call map(s:matchids, 'matchdelete(v:val)')
    let s:matchids = []
endfunction

function! ShowMotionCounts(motion)
    call extend(s:matchids, map(s:get_next_words(a:motion, 9),
                         \ 'matchaddpos("Conceal", [v:val], 10, -1, {"conceal": v:key+1})'))
endfunction


augroup motioncounts_autocmds
    autocmd!
    autocmd WinLeave,InsertEnter,CursorMoved,CursorHold * call s:clear_motion_counts()
augroup END


nnoremap <silent> <Plug>(motioncounts-w)  w:call ShowMotionCounts('w')<CR>
nnoremap <silent> <Plug>(motioncounts-b)  b:call ShowMotionCounts('b')<CR>
nnoremap <silent> <Plug>(motioncounts-e)  e:call ShowMotionCounts('e')<CR>
nnoremap <silent> <Plug>(motioncounts-W)  W:call ShowMotionCounts('W')<CR>
nnoremap <silent> <Plug>(motioncounts-B)  B:call ShowMotionCounts('B')<CR>
nnoremap <silent> <Plug>(motioncounts-E)  E:call ShowMotionCounts('E')<CR>


" wordhl                {{{2
" Simple plugin to highlight specific words or sentences
function! s:get_visual_selection()
    " FIXME: does not work for multibyte; consider registers
    let [lnum1, col1] = getpos("'<")[1:2]
    let [lnum2, col2] = getpos("'>")[1:2]
    let lines = getline(lnum1, lnum2)
    let lines[-1] = lines[-1][: col2 - (&selection == 'inclusive' ? 1 : 2)]
    let lines[0] = lines[0][col1 - 1:]
    return join(lines, "\n")
endfunction

function! s:wordhl_groups()
    redir => hls
        silent! highlight
    redir END
    let wordhls = map(split(hls, "\n"), 'matchstr(v:val, "^WordHL\\S*")')
    return filter(wordhls, '!empty(v:val)')
endfunction

function! s:next_wordhl_group()
    let matchgroups = map(getmatches(), 'v:val.group')
    let wordhls = filter(s:wordhl_groups(), 'index(matchgroups, v:val) < 0')
    return get(wordhls, 0, '')
endfunction

function! HighlightPattern(pattern, group)
    let matches = filter(getmatches(),
                \ 'has_key(v:val, "pattern") && v:val.pattern == a:pattern')
    if empty(matches) && !empty(a:pattern) && !empty(a:group)
        call matchadd(a:group, a:pattern)
    else
        call map(matches, 'matchdelete(v:val.id)')
    endif
endfunction

function! HighlightWord(mode)
    let word = a:mode == 'v' ? s:get_visual_selection() : expand('<cword>')
    let ic = (&ic && (!&scs || match(word, '\u') < 0)) ? '\c' : ''
    let pattern = a:mode == 'v'
                \ ? ic.'\V\zs'.escape(word, '\').'\ze'
                \ : ic.'\V\<'.escape(word, '\').'\>'
    call HighlightPattern(pattern, s:next_wordhl_group())
endfunction

function! UnHighlightAllWords()
    call map(getmatches(), 'v:val.group =~ "^WordHL\\S*" && matchdelete(v:val.id)')
endfunction


" hi! def WordHL1  ctermbg=154  guibg=#aeee00  ctermfg=black  guifg=black
" hi! def WordHL2  ctermbg=121  guibg=#ff0000  ctermfg=black  guifg=black
" hi! def WordHL3  ctermbg=211  guibg=#0000ff  ctermfg=black  guifg=black
" hi! def WordHL4  ctermbg=137  guibg=#b88823  ctermfg=black  guifg=black
" hi! def WordHL5  ctermbg=214  guibg=#ffa724  ctermfg=black  guifg=black
" hi! def WordHL6  ctermbg=222  guibg=#ff2c4b  ctermfg=black  guifg=black

hi! def WordHL1  cterm=bold ctermfg=16 ctermbg=153 gui=bold guibg=#0a7383 guifg=white
hi! def WordHL2  cterm=bold ctermfg=7  ctermbg=1   gui=bold guibg=#a07040 guifg=white
hi! def WordHL3  cterm=bold ctermfg=7  ctermbg=2   gui=bold guibg=#4070a0 guifg=white
hi! def WordHL4  cterm=bold ctermfg=7  ctermbg=3   gui=bold guibg=#40a070 guifg=white
hi! def WordHL5  cterm=bold ctermfg=7  ctermbg=4   gui=bold guibg=#70a040 guifg=white
hi! def WordHL6  cterm=bold ctermfg=7  ctermbg=5   gui=bold guibg=#0070e0 guifg=white
hi! def WordHL7  cterm=bold ctermfg=7  ctermbg=6   gui=bold guibg=#007020 guifg=white
hi! def WordHL8  cterm=bold ctermfg=7  ctermbg=21  gui=bold guibg=#d4a00d guifg=white
hi! def WordHL9  cterm=bold ctermfg=7  ctermbg=22  gui=bold guibg=#06287e guifg=white
hi! def WordHL10 cterm=bold ctermfg=7  ctermbg=45  gui=bold guibg=#5b3674 guifg=white
hi! def WordHL11 cterm=bold ctermfg=7  ctermbg=16  gui=bold guibg=#4c8f2f guifg=white
hi! def WordHL12 cterm=bold ctermfg=7  ctermbg=50  gui=bold guibg=#1060a0 guifg=white
hi! def WordHL13 cterm=bold ctermfg=7  ctermbg=56  gui=bold guibg=#a0b0c0 guifg=black

" Autocomplete     {{{1
set complete-=i    " don't use included files for completion, too slow

" let g:mucomplete#can_complete.python = {
"             \ 'omni': { t -> t =~# '\%([^. \t]\.\|^\s*@\|^\s*from\s.\+import \|^\s*from \|^\s*import \)\w*' },
"             \ }
" alternative pattern: '\h\w*\|[^. \t]\.\w*'


" Jedi-Vim              {{{2
" let g:jedi#auto_initialization = 0
let g:jedi#auto_vim_configuration = 0
let g:jedi#popup_select_first = 0
let g:jedi#show_call_signatures = 2
let g:jedi#completions_enabled = 0
let g:jedi#smart_auto_mappings = 0

au FileType python setlocal omnifunc=jedi#completions

" Eclim                 {{{2
let g:EclimCompletionMethod = 'omnifunc'

" Appearance       {{{1
" let &t_ZH = Terminfo('sitm', 1)
" let &t_ZR = Terminfo('ritm', 1)

colorscheme badwolf
let g:airline_theme = 'bubblegum'

let g:molokai_original = 1

function! Highlights()
" Diff                  {{{2
highlight DiffAdd     cterm=bold ctermbg=none ctermfg=119
highlight DiffDelete  cterm=bold ctermbg=none ctermfg=167
highlight DiffChange  cterm=bold ctermbg=none ctermfg=227

" hi! DiffAdd    ctermfg=DarkGreen  guifg=DarkGreen  guibg=bg
" hi! DiffDelete ctermfg=DarkRed    guifg=DarkRed    guibg=bg
" hi! DiffChange ctermfg=DarkYellow guifg=DarkYellow guibg=bg
" hi! DiffText   ctermfg=DarkCyan   guifg=DarkCyan   guibg=bg

" Matchmaker            {{{2
highlight Matchmaker  term=underline cterm=underline gui=underline

" better-whitespace     {{{2
highlight ExtraWhitespace  cterm=underline ctermfg=Red gui=underline guifg=Red

" ShowMotion            {{{2
highlight ShowMotion_SmallMotionGroup                      ctermbg=53                    guibg=#5f005f
highlight ShowMotion_BigMotionGroup   cterm=bold,underline ctermbg=54 gui=bold,underline guibg=#5f0087
highlight ShowMotion_CharSearchGroup  cterm=bold           ctermbg=4  gui=bold           guibg=#3f6691
" }}}2
endfunction
call Highlights()

augroup rc_colors
    au!
    au ColorScheme * call Highlights()
    " TODO: consider using OptionSet event to check for options like
    "       termguicolors and reset the colorscheme
augroup END

" Lightline             {{{2
function! SetupLightline(colorscheme)
    let mode_map = {
        \ "n":      'n',
        \ "i":      'i',
        \ "R":      'R',
        \ "c":      'c',
        \ "v":      'v',
        \ "V":      'V',
        \ "\<C-v>": '^v',
        \ "s":      's',
        \ "S":      'S',
        \ "\<C-s>": '^s',
        \ }

    let symbols = {
        \    'linenr':     '',
        \    'paste':      'PASTE',
        \    'readonly':   '',
        \    'modified':   '+',
        \    'space':      ' ',
        \    'whitespace': '✹',
        \    'branch':     '',
        \    'separators':    { 'left': '', 'right': '' },
        \    'subseparators': { 'left': '', 'right': '' },
        \ }

    let g:lightline = extend(get(g:, 'lightline', {}), {
        \ 'colorscheme': a:colorscheme,
        \ 'mode_map':  mode_map,
        \ 'separator':    symbols.separators,
        \ 'subseparator': symbols.subseparators,
        \
        \ 'active': {
        \   'left': [ [ 'mode', 'paste' ],
        \             [ 'fugitive', 'filename', 'modified' ] ],
        \   'right': [ [ 'lineinfo' ],
        \              [ 'percent' ],
        \              [ 'linter_warnings', 'linter_errors', 'linter_ok' ],
        \              [ 'fileformat', 'fileencoding', 'filetype' ] ],
        \ },
        \ 'components': {
        \   'modified': '%{&ft=="help"?"":&modified?"+":&modifiable?"":"-"}'
        \ },
        \ 'component_function': {
        \   'fugitive': 'LightlineFugitive',
        \ },
        \ 'component_expand': {
        \   'linter_warnings': 'LightlineAleWarnings',
        \   'linter_errors': 'LightlineAleErrors',
        \   'linter_ok': 'LightlineAleOK'
        \ },
        \ 'component_type': {
        \   'linter_warnings': 'warning',
        \   'linter_errors': 'error',
        \   'linter_ok': 'ok'
        \ },
        \ }, 'keep')
endfunction!

function! LightlineFugitive()
    try
        if exists('*fugitive#head') && buflisted('.')
            return fugitive#head()
        endif
    catch
    endtry
    return ''
endfunction

function! LightlineAleCounts() abort
    let counts = ale#statusline#Count(bufnr(''))
    let errors = counts.error + counts.style_error
    let warnings = counts.total - errors
    return [counts.total, errors, warnings]
endfunction

function! LightlineAleWarnings() abort
    let [total, _, warnings] = LightlineAleCounts()
    return total == 0 ? '' : printf('%d ◆', warnings)
endfunction

function! LightlineAleErrors() abort
    let [total, errors, _] = LightlineAleCounts()
    return total == 0 ? '' : printf('%d ✗', errors)
endfunction

function! LightlineAleOK() abort
    let [total; _] = LightlineAleCounts()
    return total == 0 ? '✓' : ''
endfunction

" augroup rc_lightline
"     au!
"     au User ALELint call lightline#update()
" augroup END

" call SetupLightline('wombat')

" Airline               {{{2
" TODO: move this to the Appearance section
function! Airline_GetFileInfo()
    return (&l:bomb ? '[BOM]' : '')
        \ .(&fenc !=# 'utf-8' ? &fenc : '')
        \ .(&ff !=# 'unix' ? '['.&ff.']' : '')
endfunction

function! IsQfWindow(win)
    return getwinvar(a:win, '&filetype') == 'qf' && empty(getloclist(a:win))
endfunction

function! IsQfWindowOpen()
    return s:some(map(range(1, winnr('$')), 'IsQfWindow(v:val)'))
endfunction

function! Airline_QfPending()
    return get(g:, 'qf_pending') ? '[Q] ' : ''
endfunction

function! AirlineCustom()              " {{{3
    call airline#parts#define_function('finfo', 'Airline_GetFileInfo')

    augroup rc_qf
        au!
        au QuickFixCmdPost [^l]*    let g:qf_pending = !IsQfWindowOpen()
        au Filetype qf              let g:qf_pending = 0
    augroup END
    call airline#parts#define_function('qf_pending', 'Airline_QfPending')

    let g:airline_section_y = airline#section#create(['finfo'])
    let g:airline_section_warning = airline#section#create(['qf_pending', 'ale_warning_count', 'whitespace'])
endfunction

function! AirlineCustomTheme(palette)  " {{{3
    " colors are [guifg, guibg, ctermfg, ctermbg, styles]

    let white = 231
    let brightpurple = 189
    let mediumpurple = 98
    let darkestpurple = 55

    " Use the style for CtrlP that powerline used
    " let a:palette.ctrlp = airline#extensions#ctrlp#generate_color_map(
    "     \ ['', '', brightpurple, darkestpurple, ''],
    "     \ ['', '', white, mediumpurple, ''],
    "     \ ['', '', darkestpurple, white, 'bold'])

    " Give the right side the same style as the left in replace mode.  This
    " may just be a bug in the bubblegum theme but whatever.
    let a:palette.replace.airline_z = a:palette.replace.airline_a
    let a:palette.replace.airline_x = a:palette.replace.airline_c
endfunction
" }}}3

let g:airline_theme_patch_func = 'AirlineCustomTheme'
augroup rc_airline
    au!
    au User AirlineAfterInit call AirlineCustom()
augroup END

" Filetypes        {{{1
" Markdown              {{{2
let g:pandoc#filetypes#handled = ["pandoc", "markdown"]
let g:pandoc#filetypes#pandoc_markdown = 0
let g:pandoc#folding#fastfolds = 1
let g:pandoc#folding#fold_fenced_codeblocks = 1  " doesn't seem to work :/
let g:pandoc#after#modules#enabled = ["tablemode"]

" Autocommands     {{{1
augroup rc_general      " {{{2
    au!

    " Make Alt work in terminal
    " au VimEnter * call Tput('smm', 1)
    " au VimLeave * call Tput('rmm', 1)

    au GUIEnter * nested call SetupGUI()

    " Don't highlight the line of the cursor in other windows
    au WinEnter * set   cursorline
    au WinLeave * set nocursorline

    " Automake directory
    au BufNewFile * call AskMakeDirs(expand('%:h'))

    " Automaticaly destroy fugitive buffers when hidden
    au BufReadPost fugitive://* setlocal bufhidden=delete
    au User fugitive
        \ if fugitive#buffer().type() =~# '^\%(tree\|blob\)$'   |
        \     nnoremap <buffer> .. :edit %:h<CR>                |
        \ endif

    " I just can't seem to be able to make netrw buffers disappear
    " autocmd FileType netrw setlocal bufhidden=wipe
    " autocmd FileType netrw nnoremap <buffer> q :bdelete<CR>
    " autocmd OptionSet bufhidden
    "     \ if &filetype == 'netrw' |
    "     \     echomsg 'netrw changed bufhidden=' v:option_new |
    "     \     setlocal bufhidden=delete |
    "     \     echomsg 'netrw changed back to bufhidden=' &bufhidden |
    "     \ endif
    let g:netrw_altfile = 1

    " Re-source .vimrc on save
    au BufWritePost $MYVIMRC nested source $MYVIMRC
augroup END

augroup ft_help         " {{{2
    au!
    au FileType help setlocal keywordprg=:help

    " These ones are only meant for help windows
    au FileType help if &buftype == 'help' | call s:ft_help() | endif
augroup END

function! s:ft_help()
    nnoremap <buffer> q :echohl WarningMsg<Bar>echo "q is deprecated, use gq instead"<Bar>echohl NONE<CR>
    nnoremap <buffer> gq :close<CR>
endfunction

augroup ft_vim          " {{{2
    au!
    au FileType vim setlocal keywordprg=:help
augroup END

augroup ft_python       " {{{2
    au!

    au FileType python setlocal
                \ tabstop=8
                \ softtabstop=4
                \ shiftwidth=4
                \ textwidth=79
                \ expandtab
                \ autoindent

    au FileType python setlocal suffixesadd=.py
    au FileType python setlocal includeexpr=PythonIncludeExpr(v:fname)
    au FileType python let &l:path = join(['.', PythonPath(3), PythonPath(2)], ',')
    au FileType python let &l:include = join([
                \ '^\s*import\s\+\zs[_.[:alnum:]]\+\ze',
                \ '^\s*from\s\+\zs[_.[:alnum:]]\+\ze\s\+import'], '\|')

    " This next pattern, courtesy of wushee on #vim on freenode, can find
    " multi-import lines, matching each package separately, i.e. in:
    "     import foo, bar
    " it would match both foo and bar.  However, it can't work like that as
    " the value of 'include'.  AFAICT (from vim's code), vim will only ever
    " consider the first match on each a line to be an include.  Pity.
    " au FileType python let &l:include = join([
    "             \ '\(^\s*import .*\)\@<=\zs[_.[:alnum:]]\+\ze',
    "             \ '^\s*from\s\+\zs[_.[:alnum:]]\+\ze\s\+import'], '\|')

    " matchit.vim support for Python
    " Unfortunately, this is not so easy for Python because it doesn't use
    " explicit end-block delimiters; see https://vi.stackexchange.com/q/13209
    " au FileType python let b:match_words = join([
    "             \ '\<def\>:\<return\>',
    "             \ '\<\(while\|for\)\>:\<break\>:\<continue\>',
    "             \ '\<if\>:\<elif\>:\<else\>',
    "             \ '\<try\>:\<except\>:\<finally\>'], ',')
augroup END

augroup ft_go           " {{{2
    au!

    au FileType go setlocal
                \ tabstop=4
                \ softtabstop=4
                \ shiftwidth=4
                \ noexpandtab
augroup END

augroup ft_cpt          " {{{2
    au!

    au BufReadPre *.cpt set bin
    au BufReadPre *.cpt set viminfo=
    au BufReadPre *.cpt set noswapfile

    au BufReadPost *.cpt let $vimpass = inputsecret("Password: ")
    au BufReadPost *.cpt silent '[,']!ccrypt -cb -E vimpass
    au BufReadPost *.cpt set nobin

    au BufWritePre *.cpt set bin
    au BufWritePre *.cpt '[,']!ccrypt -e -E vimpass

    au BufWritePost *.cpt u
    au BufWritePost *.cpt set nobin
augroup END


" Mappings         {{{1
function! s:try_cmd(cmd, default)      " {{{2
    if exists(':' . a:cmd) && !v:count
        let tick = b:changedtick
        exec a:cmd
        if tick == b:changedtick
            exec 'normal!' a:default
        endif
    else
        exec 'normal!' v:count.a:default
    endif
endfunction


function! s:all_mode_map(key, ...)     " {{{2
    let cmd = join(a:000)
    exec 'nnoremap' '<silent>' a:key ':'.cmd.'<CR>'
    exec 'inoremap' '<silent>' a:key '<C-o>:'.cmd.'<CR>'
    exec 'vnoremap' '<silent>' a:key ':<C-u>'.cmd.'<CR>gv'
endfunction

command! -nargs=+ Anoremap call s:all_mode_map(<f-args>)

" }}}2

" fixes
noremap j gj
noremap k gk
noremap gj j
noremap gk k
noremap Y y$
vnoremap < <gv
vnoremap > >gv

noremap H ^
noremap L $
noremap gV `[v`]
" nnoremap <BS> <C-^>
nnoremap gb :ls<CR>:b<Space>

" Use :tjump instead of :tag
nnoremap <C-]> g<C-]>
vnoremap <C-]> g<C-]>
nnoremap <C-W><C-]> <C-W>g<C-]>

" TODO: put this somewhere proper
function! SyntaxInfo()
    let names = map(synstack(line('.'), col('.')), 'synIDattr(v:val, "name")')
    return join(names, ' : ')
endfunction

nnoremap Q :ExecRange<CR>
vnoremap Q :ExecRange<CR>
noremap <F10> :echo SyntaxInfo()<CR>

map <Tab> %

" TODO: make a window mappings fold
" FIXME: this is a plugin mapping
nnoremap <silent> <A-m> :ZoomWin<CR>
nnoremap <A-q> <C-w>q

nnoremap <silent> <Space> @=(foldlevel(".")?"za":"\<Space>")<CR>

nnoremap <leader>.b :e ~/.bashrc<CR>
nnoremap <leader>.g :e ~/.gitconfig<CR>
nnoremap <leader>.v :e $MYVIMRC<CR>
nnoremap <leader>.t :e ~/.tmux.conf<CR>
nnoremap <leader>.z :e ~/.zshrc<CR>

cnoremap w!! w !sudo tee % >/dev/null

" Plugin Mappings  {{{1
" nmap w <Plug>(motioncounts-w)
" nmap b <Plug>(motioncounts-b)

if s:has_plugin('ShowMotion')
    nmap w <Plug>(show-motion-w)
    nmap W <Plug>(show-motion-W)
    nmap b <Plug>(show-motion-b)
    nmap B <Plug>(show-motion-B)
    nmap e <Plug>(show-motion-e)
    nmap E <Plug>(show-motion-E)
endif

if s:has_plugin('vim-operator-surround')
    map <silent>sa <Plug>(operator-surround-append)
    map <silent>sd <Plug>(operator-surround-delete)
    map <silent>sr <Plug>(operator-surround-replace)
endif

if s:has_plugin('vim-sneak')
    map f <Plug>Sneak_f
    map F <Plug>Sneak_F
    map t <Plug>Sneak_t
    map T <Plug>Sneak_T
endif

if s:has_plugin('SplitJoin')
    " TODO: use SplitJoin plugin
    nnoremap <silent> J :<C-u>call <SID>try_cmd('SplitjoinJoin',  'J')<CR>
    nnoremap <silent> S :<C-u>call <SID>try_cmd('SplitjoinSplit', "a\n")<CR>
endif

nnoremap <silent> <leader>l :call ToggleQuickFix('l')<CR>
nnoremap <silent> <leader>q :call ToggleQuickFix('c')<CR>

nnoremap <silent> <leader>k :call HighlightWord('n')<CR>
vnoremap <silent> <leader>k :call HighlightWord('v')<CR>
nnoremap <silent> <leader>K :call UnHighlightAllWords()<CR>

if s:has_plugin('fzf.vim')
    nnoremap <C-p> :FZF<CR>
    nnoremap gb :Buffers<CR>
endif

if s:has_plugin('ale')
    nmap <silent> [w <Plug>(ale_previous)
    nmap <silent> ]w <Plug>(ale_next)
    nmap <silent> [W <Plug>(ale_first)
    nmap <silent> ]W <Plug>(ale_last)
endif

Anoremap <F5>a AirlineToggle
Anoremap <F5>i IndentLinesToggle
if s:has_plugin("vim-matchmaker")
    Anoremap <F5>m MatchmakerToggle
elseif s:has_plugin("vim-cursorword")
    Anoremap <F5>m let g:cursorword = !g:cursorword
endif
Anoremap <F5>r RainbowToggle
Anoremap <F5>w ToggleWhitespace

Anoremap <F6>t TagbarToggle
Anoremap <F6>u UndotreeToggle


" Misc             {{{1
function! s:zip(...)                   " {{{2
    let lists = a:000
    let length = min(map(copy(lists), 'len(v:val)'))

    let i = 0
    let zipped = []
    while i < length
        " map(copy()) is faster than a loop; hardly a surprise.  However, a
        " map() without a copy() is far far slower; weird.
        call add(zipped, map(copy(lists), 'v:val[i]'))
        let i += 1
    endwhile

    return zipped
endfunction


" Random Numbers        {{{2
function! s:_Random()                  " {{{3
    " Base (abstract) class for an RNG.  Provides random() and shuffle().
    " Subclasses only need to provide a next() method.
    let this = {}

    " random({expr} [, {max}])
    " Returns a random number in the range:
    " - If only {expr} is specified: [0, 1, ..., {expr} - 1]
    " - If {max} is specified: [{expr}, {expr} + 1, ..., {max}]
    " This mimics the |range()| function.
    "
    " Based on the implementation in the python standard library.
    function! this.random(a, ...)
        if a:0 > 1 | throw 'too many arguments' | endif
        let a = a:0 ? a:a : 0
        let n = a:0 ? a:1 - a:a + 1 : a:a

        if n >= self.max
            " FIXME: This may overflow.  How can I avoid it?
            return a + n*y / self.max
        endif
        let y = self.next()
        while y >= self.max - (self.max % n)
            let y = self.next()
        endwhile
        return a + (y % n)
    endfunction

    " shuffle({list})
    " Shuffles the items in {list} in-place.  Returns {list}.
    " Uses a standard Fisher-Yates/Knuth shuffle.
    function! this.shuffle(arr)
        let i = len(a:arr) - 1
        while i > 0
            let j = self.random(i + 1)
            let [a:arr[i], a:arr[j]] = [a:arr[j], a:arr[i]]
            let i -= 1
        endwhile
        return a:arr
    endfunction

    return this
endfunction

function! s:xorshift16(seed)           " {{{3
    " A simple 16bit xorshift RNG.
    " I used 16bits because 32bit Vim builds use, obviously, signed integers.
    " So instead of trying to implement unsigned shifts in vimscript, I just
    " use parts of the number.
    "
    " https://en.wikipedia.org/wiki/Xorshift
    " http://xoroshiro.di.unimi.it/
    " http://www.arklyffe.com/main/2010/08/29/xorshift-pseudorandom-number-generator/
    if a:seed == 0 || a:seed > 0xffff
        throw a:seed ? 'too large seed value' : 'seed 0'
    endif

    let this = s:_Random()
    call extend(this, {'max': 0xffff, 'state': a:seed})

    function! this.next()
        let y = self.state
        let y = xor(y, (y * 0x2000) % 0x10000)  " 2^13
        let y = xor(y, (y / 0x200)  % 0x10000)  " 2^9
        let y = xor(y, (y * 0x80)   % 0x10000)  " 2^7
        let self.state = y
        return y
    endfunction

    return this
endfunction


" Colors                {{{2
function! s:read_rgb_txt(fname)
    silent! let rgbfile = readfile(a:fname)

    let table = {}
    for line in rgbfile
        let colr = matchlist(line, '^\s*\(\d\+\)\s\+\(\d\+\)\s\+\(\d\+\)\s\+\(.*\)')
        if !empty(colr)
            let [r, g, b, name] = colr[1:4]
            let table[tolower(name)] = [str2nr(r), str2nr(g), str2nr(b)]
        endif
    endfor

    return table
endfunction

let s:named_colors = s:read_rgb_txt(expand('$VIMRUNTIME/rgb.txt'))

function! Hex2rgb(hex)
    return map(matchlist(a:hex, '\v\#(..)(..)(..)')[1:3], '0 + ("0x".v:val)')
endfunction!

function! Namedcolor2rgb(name)
    return get(s:named_colors, tolower(a:name), [])
endfunction

function! Color2rgb(color)
    let rgb = Hex2rgb(a:color)
    if empty(rgb) | let rgb = Namedcolor2rgb(a:color) | endif
    if empty(rgb) | throw printf("NotAColor: %s", a:color) | endif
    return rgb
endfunction

function! Rgb2hex(rgb)
    return printf('#%02x%02x%02x', a:rgb[0], a:rgb[1], a:rgb[2])
endfunction


" " Multiple change     {{{2
" let g:mc = "y/\\V\<C-r>=escape(@\", '/')\<CR>\<CR>"

" nnoremap cn *``cgn
" nnoremap cN *``cgN

" vnoremap <expr> cn g:mc . "``cgn"
" vnoremap <expr> cN g:mc . "``cgN"

" function! SetupCR()
"   nnoremap <Enter> :nnoremap <lt>Enter> n@z<CR>q:<C-u>let @z=strpart(@z,0,strlen(@z)-1)<CR>n@z
" endfunction

" nnoremap cq :call SetupCR()<CR>*``qz
" nnoremap cQ :call SetupCR()<CR>#``qz

" vnoremap <expr> cq ":\<C-u>call SetupCR()\<CR>" . "gv" . g:mc . "``qz"
" vnoremap <expr> cQ ":\<C-u>call SetupCR()\<CR>" . "gv" . substitute(g:mc, '/', '?', 'g') . "``qz"

" " FzyDo                 {{{2
" function! FzyDo(vimcmd, listing)
"     try
"         let output = system(a:listing . " | fzy ")
"     catch /Vim:Interrupt/
"         " Swallow errors from ^C, allow redraw! below
"     endtry
"     redraw!
"     if v:shell_error == 0 && !empty(output)
"         exec a:vimcmd output
"     endif
" endfunction

" if executable('fzy', 'ag')
"     nnoremap <C-p> :call FzyDo(":e",  "ag -l -g ''")<CR>
"     nnoremap <C-s> :call FzyDo(":vs", "ag -l -g ''")<CR>
"     nnoremap <C-S-v> :call FzyDo(":sp", "ag -l -g ''")<CR>
" elseif executable('fzy')
"     nnoremap <C-p> :call FzyDo(":e",  "find -type f")<CR>
"     nnoremap <C-s> :call FzyDo(":sp", "find -type f")<CR>
"     nnoremap <C-S-v> :call FzyDo(":vs", "find -type f")<CR>
" endif

" TODO             {{{1
" Finalize on some TODO file format                                        {{{2
"   * todo.txt
"   * Taskwarrior
"   * TaskPaper
"   * org-mode
"   * or even my very own!
" Afterwards, convert this TODO as well as any others that I have to the
" chosen format.  Right now I'm using todo.txt for some files, but I'm not
" really that invested.

" Consider providing documentation for keybindings                         {{{2
" Kind of like what GNOME does nowadays, or guide-key in emacsland.
"   * hecal3/vim-leader-guide
"   * sunaku/vim-shortcut

" Solve autocomplete once and for all!                                     {{{2
" Here's the usual suspects
"   * ervandew/supertab
"   * Valloric/YouCompleteMe
"   * Shougo/neocomplete.vim
"   * Shougo/deoplete.nvim
" And here's some less well known ones
"   * ajh17/VimCompletesMe
"   * maralla/completor.vim
"   * roxma/nvim-completion-manager

" Functions' arglist 'expansion'                                           {{{2
"   * FooSoft/vim-argwrap
"   * jakobwesthoff/argumentrewrap
"   * mnussbaum/args_split.vim
" Take a look at them and perhaps make my own version.  The most important
" thing I guess is getting the indentation the way I want it.  This plugin
" seems close to what I want,
"   * vim-scripts/Scala-argument-formatter

" Find and replace                                                         {{{2
"   * hauleth/sad.vim
" It's like :s only less powerful but more intuitive.  Here's something similar
"     nnoremap § *``gn<C-g>
"     inoremap § <C-o>gn<C-g>
"     snoremap <expr> . @.
" The nmap enters select (yes, select) mode with the word under the cursor
" selected.  The imap jumps to the next same word and the smap allows you to
" quickly reenter the same text if wanted.  Almost the same as the plugin
" really.

" Mapping to act on whole function calls, eg with surround                 {{{2
" Consider writing a textobject for that.  I saw this
"   * https://github.com/tpope/vim-surround/pull/118
" A simpler replacement would be just
"     nmap dsf ds)db
" This won't handle methods though, e.g. foo.bar(baz)

" Do tags as git hooks                                                     {{{2
"   * rafi/vim-tagabana
" Does some weird 'hashing' that's supposed to be 'caching'.  I don't know.
" Compared to gutentags that I'm using now it is Linux-only and also,
" git-only.  Considering that I do not always tend to use git for my projects,
" this could be a serious limitation.  I could either suck it up and use git
" everywhere, or continue using guttentags.

" Documentation viewer                                                     {{{2
"   * thinca/vim-ref
" I already have my Pydoc function, which I don't use because jedi-vim
" overrides K in favor of its own documentation viewer which kind of sucks.

" Statusline                                                               {{{2
"   * itchyny/lightline.vim
"   * vim-airline/vim-airline
"   * rafi/vim-tinyline
" I'll probably just continue using airline, it's the easiest and does most of
" what I need and like.

" Get slimey                                                               {{{2
"   * julienr/vim-cellmode
"   * jpalardy/vim-slime
"   * jgdavey/tslime.vim/
"   * epeli/slimux
" Presumably, I want something that can send either one (whole) expression or
" a selection.  One expression can be more than just a line.  Perhaps jedi has
" some relevant APIs.  Otherwise, Python itself has means to access the AST
" and stuff, I could look into that.  One of this days I should also try
" PyCharm, to see what a real IDE offers and get some ideas.

" Consider Unite/Denite again                                              {{{2
"   * Shougo/unite.vim
"   * Shougo/denite.nvim
" I don't have to write these really but whatever.  Denite is the successor.

" http://howivim.com/2016/tyru/                                            {{{2
" Has some stuff about visualstar and mappings and whatnot.

" http://github.com/unblevable/quick-scope                                 {{{2
" Perhaps I could do something similar with my motioncounts.  His code is kind
" of big to just embed in my vimrc, though I don't know how much of it can be
" refactored/compressed.

" diffopt                                                                  {{{2
" cscope                                                                   {{{2
" fzf-tjump                                                                {{{2
" Right now I'm using Vim's own tjump mappings and these may be enough.
"   * ivalkeen/vim-ctrlp-tjump

" Replace/rewrite thematic                                                 {{{2
