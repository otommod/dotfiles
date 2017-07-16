" vim:fdm=marker:
" Author: Otto Modinos <ottomodinos@gmail.com>

set nocompatible   " be ViM, not vi
set shellslash     " always use forward slash as path separator
if has('multi_byte')
    set encoding=utf-8       " Use UTF-8 as ViM's internal encoding
    scriptencoding utf-8     " Specify that this file is UTF-8
endif


" Helper functions {{{1
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

function! s:has(...)                   " {{{2
    return s:every(map(copy(a:000), 'has(v:val)'))
endfunction

function! s:executable(...)            " {{{2
    return s:every(map(copy(a:000), 'executable(v:val) > 0'))
endfunction

function! s:has_plugin(plugname)       " {{{2
    return has_key(g:plugs, a:plugname)
endfunction

function! s:path_exists(path)          " {{{2
    return !empty(glob(a:path, 1, 1))
endfunction

function! s:makedirs(path)             " {{{2
    if !exists("*mkdir")
        echoerr "This ViM doesn't support '*mkdir'" | return
    endif

    let path = resolve(a:path)
    if isdirectory(path) | return | endif
    try
        call mkdir(path, 'p')
    catch /E739/
        let [_, exc, errmsg; rest] = split(v:exception, ': ')
        let excpath = join(rest, ': ')
        let [path, excpath] = [substitute(path, "/*$", "", ""),
                             \ substitute(excpath, "/*$", "", "")]

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

" }}}2
" TODO: consider a cross-platform s:download function, perhaps using netrw

" Pre-Preamble     {{{1
if s:has('win32') | let $VIMDIR = expand('~/vimfiles')  |
else              | let $VIMDIR = expand('~/.vim')      | endif

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
Plug 'editorconfig/editorconfig-vim'

" Sidepanes             {{{2
    Plug 'majutsushi/tagbar'
    Plug 'mbbill/undotree'
    Plug 'mtth/scratch.vim'
" File explorers        {{{2
    " Plug 'idbrii/renamer.vim'
    " Plug 'tpope/vim-vinegar'
    " Plug 'jeetsukumaran/vim-filebeagle'
    Plug 'justinmk/vim-dirvish'
    " Plug 'Shougo/vimfiler.vim'
    " Plug 'scrooloose/nerdtree'
    " Plug 'jistr/vim-nerdtree-tabs'
" Eye candy             {{{2
    Plug 'myusuf3/numbers.vim'
    Plug 'ntpeters/vim-better-whitespace'
    Plug 'Yggdroot/indentLine'
    " Plug 'itchyny/vim-cursorword'
    " Plug 'qstrahl/vim-matchmaker'
    Plug 'chrisbra/Colorizer'
    " Plug 'boucherm/ShowMotion'
" Rainbow parentheses   {{{2
    " Plug 'kien/rainbow_parentheses.vim'
    " Plug 'amdt/vim-niji'
    Plug 'luochen1990/rainbow'
" Window management     {{{2
    " Plug 'spolu/dwm.vim'
    " Plug 'roman/golden-ratio'
    " Plug 't9md/vim-choosewin'
    Plug 'dr-chip-vim-scripts/ZoomWin'
" Buffer management     {{{2
    Plug 'moll/vim-bbye'
" Fixes                 {{{2
    Plug 'Konfekt/FastFold'
    Plug 'ConradIrwin/vim-bracketed-paste'
    " Plug 'ap/vim-you-keep-using-that-word'
    " Plug 'drmikehenry/vim-fixkey'
" Distraction-free      {{{2
    " Plug 'junegunn/goyo.vim'
    " Plug 'junegunn/limelight.vim'
" Colorschemes          {{{2
    " Light {{{3
        " Plug 'daddye/soda.vim'
        Plug 'notpratheek/vim-sol'
    " Dark {{{3
        Plug 'sjl/badwolf'
        Plug 'fneu/breezy'
        " Plug 'tomasr/molokai'
        " Plug 'sstallion/vim-wtf'
        " Plug 'abra/vim-obsidian'
        " Plug 'notpratheek/vim-luna'
        " Plug 'kabbamine/yowish.vim'
        " Plug 'joshdick/onedark.vim'
        " Plug 'nanotech/jellybeans.vim'
        " Plug 'mitsuhiko/fruity-vim-colorscheme'
    " Both {{{3
        Plug 'w0ng/vim-hybrid'
        " Plug 'morhetz/gruvbox'
        " Plug 'jacoborus/tender.vim'
        " Plug 'junegunn/seoul256.vim'
        " Plug 'chriskempson/base16-vim'
        " Plug 'noahfrederick/vim-hemisu'
        " Plug 'reedes/vim-colors-pencil'
        " Plug 'NLKNguyen/papercolor-theme'
        Plug 'chriskempson/vim-tomorrow-theme'
        Plug 'altercation/vim-colors-solarized'
" Syntax                {{{2
    Plug 'justinmk/vim-syntax-extra'
    Plug 'hdima/python-syntax'
    Plug 'mgrabovsky/vim-cuesheet'
    " Plug 'baskerville/vim-sxhkdrc'
    " Plug 'smancill/conky-syntax.vim'
    Plug 'otommod/twee-sugarcube.vim'
    Plug 'vim-pandoc/vim-pandoc-syntax'
    " Needs to be last so it won't override the previous ones
    Plug 'sheerun/vim-polyglot'
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
    " Plug 'jreybert/vimagit'
    " Plug 'lambdalisue/vim-gita'
    " Plug 'junegunn/gv.vim'
    " Plug 'gregsexton/gitv'
    " Plug 'kablamo/vim-git-log'
    " Plug 'mhinz/vim-signify'
    Plug 'airblade/vim-gitgutter'
" Search enhancements   {{{2
    " Plug 'wincent/ferret'
    " Plug 'idbrii/vim-searchsavvy'
    Plug 'vasconcelloslf/vim-interestingwords'
    Plug 'henrik/vim-indexed-search'
    " Plug 'haya14busa/incsearch.vim'
" Statusline            {{{2
    " Plug 'ap/vim-buftabline'
    " Plug 'itchyny/lightline.vim'
    Plug 'vim-airline/vim-airline'
    Plug 'vim-airline/vim-airline-themes'
    " Plug 'powerline/powerline', {'rtp': 'powerline/bindings/vim'}
" Text Objects          {{{2
    " Plug 'wellle/targets.vim'
    " TODO: I like the 'next' object stuff, dunno about the rest

    " Plug 'kana/vim-textobj-user'
    " Plug 'kana/vim-textobj-indent'
    " Plug 'bps/vim-textobj-python'
    " Plug 'glts/vim-textobj-comment'
    " Plug 'reedes/vim-textobj-quote'
    " Plug 'thinca/vim-textobj-between'
    " Plug 'rbonvall/vim-textobj-latex'
    " Plug 'adriaanzon/vim-textobj-matchit'
    " Plug 'lucapette/vim-textobj-underscore'
    " Plug 'coderifous/textobj-word-column.vim'
" CtrlP                 {{{2
    " Plug 'junegunn/fzf'
    " Plug 'junegunn/fzf.vim'

    Plug 'ctrlpvim/ctrlp.vim'
    " Plug 'nixprime/cpsm', {'do': './install.sh'}
    Plug 'FelikZ/ctrlp-py-matcher'
    Plug 'ivalkeen/vim-ctrlp-tjump'
    " Plug 'mattn/ctrlp-mark'
    Plug 'mattn/ctrlp-register'
    " Plug 'kshenoy/vim-ctrlp-args'
    Plug 'fisadev/vim-ctrlp-cmdpalette'
" Alignment             {{{2
    " Plug 'tommcdo/vim-lion'
    " Plug 'godlygeek/tabular'
    " Plug 'junegunn/vim-easy-align'
" Autocompletion        {{{2
    Plug 'ajh17/VimCompletesMe'
    " Plug 'ervandew/supertab'
    " Plug 'Shougo/neocomplete.vim'
    " Plug 'Shougo/deoplete.nvim'
    " Plug 'Valloric/YouCompleteMe'
" Filetype Specific     {{{2
" C/C++                      {{{3
    Plug 'Rip-Rip/clang_complete', {'for': ['c', 'cpp']}
" Python                     {{{3
    Plug 'fisadev/vim-isort',            {'for': 'python'}
    Plug 'davidhalter/jedi-vim',         {'for': 'python'}
    " Plug 'python-rope/ropevim',          {'for': 'python'}
    " Plug 'tweekmonster/django-plus.vim'
    Plug 'vim-scripts/python_match.vim', {'for': 'python'}
    " TODO: Consider writing a folding plugin
    " Plug 'tmhedberg/SimpylFold'
    " Plug 'vim-scripts/Efficient-python-folding'
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

    Plug 'metakirby5/codi.vim'

    Plug 'reedes/vim-thematic'
    " Plug 'scrooloose/syntastic'
    Plug 'w0rp/ale'
    " Plug 'szw/vim-ctrlspace'
    " Plug 'terryma/vim-multiple-cursors'
    " Plug 'Shougo/denite.nvim'

    runtime macros/matchit.vim
    " Plug 'benjifisher/matchit.zip'

    Plug 'tpope/vim-unimpaired'
    Plug 'tpope/vim-repeat'
    Plug 'tpope/vim-surround'
    Plug 'tpope/vim-commentary'
    Plug 'justinmk/vim-sneak'
    Plug 'tommcdo/vim-exchange'
    " Plug 'AndrewRadev/sideways.vim'
    Plug 'PeterRincker/vim-argumentative'
    " Plug 'Lokaltog/vim-easymotion'
    Plug 'jeetsukumaran/vim-indentwise'

    " TODO: check if needed and make mappings
    " Plug 'zirrostig/vim-schlepp'
    " Plig 'fisadev/dragvisuals.vim'
    " XXX: Plug 'atweiden/vim-dragvisuals'

    " Plug 'bruno-/vim-man'
    " Plug 'freitass/todo.txt-vim'
    " Plug 'vim-pandoc/vim-pandoc'
    " Plug 'dhruvasagar/vim-table-mode'

    " Plug 'xuhdev/SingleCompile'
    Plug 'ludovicchabant/vim-gutentags'

    " Plug 'takac/vim-hardtime'
    Plug 'lyokha/vim-xkbswitch'
    Plug 'drmikehenry/vim-fontdetect'

    " TODO: I could leverage this
    " Plug 'romgrk/lib.kom'

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

    set viminfo+=n$VIMDIR/tmp/viminfo

    call s:makedirs(&backupdir)
    call s:makedirs(&undodir)
    call s:makedirs(&directory)

" Wildcompltetion       {{{2
    set wildmode=longest:full,full     " command-line completion
if s:has('wildmenu')
    set wildmenu                       " enhanced command-line completion
endif
if s:has('wildignore')
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
    set wildignore+=~/.cache/*
    set wildignore+=~/.local/share/Steam/*
endif
" }}}2

set history=500    " keep 500 commands in history
set number         " display line numbers
set showmatch      " show matching pairs, like parentheses
set matchtime=5    " tenths of seconds to show the matching paren
set autoread       " re-read the file when changed outside of vim
set wrapscan       " searches wrap around the end of file
set laststatus=2   " always show status line
set backspace=indent,eol,start                   " backspace over everything!
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

" XXX: fix these
set tabstop=8      " 
set shiftwidth=4   " 
set shiftround     " use multiple of shiftwidth when indenting with < and >
set expandtab      " 
set softtabstop=4  " 
set autoindent     " 

set lazyredraw     " do not redraw while executing commands
set ttyfast        " I have a fast connection to my tty

" FIXME:
if $TERM =~ 'st'
    set ttymouse=xterm
    let &t_8f = "\<Esc>[38;2;%lu;%lu;%lum"
    let &t_8b = "\<Esc>[48;2;%lu;%lu;%lum"
endif

if s:executable('ag')
    set grepprg=ag\ --vimgrep\ $*
    set grepformat=%f:%l:%c:%m
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

if s:has('title')            | set title             | endif
if s:has('cmdline_info')     | set showcmd           | endif
if s:has('extra_search')     | set incsearch         | set hlsearch       | endif
if s:has('vertsplit')        | set splitright        | endif
if s:has('virtualedit')      | set virtualedit=block | endif
if s:has('syntax')           | set cursorline        | set colorcolumn=80 | endif
if s:has('linebreak')        | set showbreak=↪\      | endif
if s:has('folding')          | set foldcolumn=2      | endif
if s:has('windows','folding')| set fillchars=vert:│  | endif
if s:has('insert_expand')    | set completeopt=menu,menuone,longest       | endif
if s:has('conceal')          | set concealcursor=nc  | endif

" GUI Options      {{{1
function! SetupGUI()
if s:has('gui_mac')
    set antialias  " antialized goodness
    set fuoptions=maxvert,maxhorz
endif

set mousehide      " hide the mouse pointer when typing on the GUI
set guioptions+=c  " use console dialogs
set guioptions-=e  " text tabs
set guioptions-=m  " no menu
set guioptions-=t  " no tearoff menus
set guioptions-=T  " no toolbar (the one with the icons)
endfunction

" Plugin Options   {{{1
" buftabline            {{{2
let g:buftabline_show = 1
let g:buftabline_numbers = 1
let g:buftabline_indicators = 1
let g:buftabline_separators = 1

" bufline               {{{2
let g:bufline_separator = '  '
" let g:bufline_fnamemodify = ':p:~:.:gs#\v/(.)[^/]*\ze/#/\1#'

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

" CtrlP                 {{{2
" s:add_ctrlp_vcs -- adds a vcs in g:ctrlp_user_command    {{{3
function! s:add_ctrlp_vcs(rootdir, cmd, ...)
    let prog = get(a:000, 0, a:rootdir[1:])
    let n = len(g:ctrlp_user_command.types)
    if s:executable(prog)
        " ensure the vcs exist, otherwise CtrlP kindly would report NO ENTRIES
        let g:ctrlp_user_command.types[n] = [a:rootdir, a:cmd]
    endif
endfunction
" }}}3

let g:ctrlp_lazy_update = 100  " refresh the results every 100ms

let g:ctrlp_max_files = 0
let g:ctrlp_show_hidden = 1
let g:ctrlp_use_caching = 1
let g:ctrlp_clear_cache_on_exit = 0

if s:has_plugin("ctrlp-py-matcher")
    let g:ctrlp_match_func = {'match': 'pymatcher#PyMatch'}
endif

let g:ctrlp_user_command = {'types': {}}
if s:executable('ag')
    " https://robots.thoughtbot.com/faster-grepping-in-vim
    let g:ctrlp_user_command.fallback = 'ag --nocolor -l -g "" %s'
    " let g:ctrlp_use_caching = 0          " no need to cache, ag is fast
    let g:ctrlp_clear_cache_on_exit = 1

    " XXX:
    " let g:ctrlp_user_command = "ag %s -i --nocolor --nogroup "
    "     \ . "--ignore '.git' --ignore '.DS_Store' --ignore 'node_modules' "
    "     \ . "--hidden -g ''"
endif

call s:add_ctrlp_vcs(".git", "cd %s && git ls-files -co --exclude-standard")
call s:add_ctrlp_vcs(".hg",  "hg --cwd %s locate -I .")

let g:ctrlp_extensions = ["tag", "quickfix", "tjump"]

let g:ctrlp_tjump_only_silent = 1
let g:ctrlp_tjump_skip_tag_name = 1

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

" indexed-search        {{{2
let g:indexed_search_dont_move = 1
let g:indexed_search_unfold = 1
let g:indexed_search_center = 1

" better-whitespace     {{{2
let g:better_whitespace_filetypes_blacklist = ['help', 'vim-plug']

" interestingWords      {{{2
let g:interestingWordsRandomiseColors = 1

" indentLine            {{{2
let g:indentLine_char = '┊'
let g:indentLine_concealcursor = 'nc'  " XXX: this sets 'concealcursor'

" cursorword            {{{2
" let g:cursorword = 1

" Matchmaker            {{{2
let g:matchmaker_enable_startup = 1

" Python.vim            {{{2
let python_highlight_all = 1

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


function! ToggleBackground()           " {{{2
    let &background = ( &background == 'dark' ? 'light' : 'dark' )
    if exists('g:colors_name')
        exec 'colorscheme' g:colors_name
    endif
endfunction


function! FoldText()                   " {{{2
" https://coderwall.com/p/usd_cw

    function! s:unicode_len(s)              " {{{3
        return strlen(substitute(a:s, '.', 'x', 'g'))
    endfunction

    function! s:real_numberwidth()          " {{{3
        let width = 0

        if (&number || &relativenumber)
            if (&number)
                let lnum = line('$')
            elseif (&relativenumber && ! &number)
                let lnum = winheight(0)
            endif

            let width += max([&numberwidth, strlen(lnum) + 1])
        endif

        return width
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
    let width = min([80, winwidth(0) - lpadding - s:unicode_len(lines_num)])

    let start = strpart(start, 0, width - s:unicode_len(end)
                                      \ - s:unicode_len(' … '))
    let text = start . ' … ' . end

    return text
         \ . repeat(' ', width - s:unicode_len(text))
         \ . lines_num
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
    if !s:executable('tput')
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
    " There can be multiple lists open at the same time: at most one quickfix
    " and many loclists, each one associated with a window.  ViM provides no
    " means to tell which is which.  We do the following: try and close the
    " requested list and see if the total number of windows changed.
    let last_winnr = winnr('$')
    exec a:list.'close'
    if last_winnr != winnr('$') | return | endif

    let current_winnr = winnr()
    if a:list == 'l' && !len(getloclist(0))
        call s:echohl('WarningMsg', "Location List is empty")
        return
    endif
    exec a:list.'open'

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

call s:def_option('g:bufline_modified', '+')
call s:def_option('g:bufline_fnamemodify', ':t')
call s:def_option('g:bufline_fmt', '%s:%s%s')
call s:def_option('g:bufline_active_fmt', '[%s:%s%s]')


function! s:get_bufnrs()
    let ft_exclude = {}
    for ft in g:bufline_ft_exclude
        ft_exclude[ft] = 1
    endfor

    return filter(range(1,bufnr('$')),
                \ 'buflisted(v:val) && !get(ft_exclude, getbufvar(v:val, "&ft"), 0)')
endfunction

function! s:get_buffer_info(bufnr)
    let has_view = bufwinnr(a:bufnr) > 0
    let is_current = a:bufnr == bufnr('%')
    return {
        \ "name": bufname(a:bufnr),
        \ "state": has_view + is_current,
        \ "modified": getbufvar(a:bufnr, '&mod')
    \ }
endfunction

function! s:generate_buffer_labels(bufnrs)
    return map(copy(a:bufnrs),
             \ g:bufline_formatter.'(v:val, s:get_buffer_info(v:val))')
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


function! s:default_formatter(bufnr, info)
    return printf(a:info.state == 2 ? g:bufline_active_fmt : g:bufline_fmt,
                \ a:bufnr,
                \ fnamemodify(a:info.name, g:bufline_fnamemodify),
                \ a:info.modified ? g:bufline_modified : '')
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


function! s:delayed_echo_bufline(millis)
    if exists('s:save_ut') | return | endif
    let s:save_ut = &ut
    let &ut = a:millis

    augroup bufline_delayed_autocmds
        autocmd!
        autocmd CursorHold *
            \ let &ut = s:save_ut    |
            \ unlet s:save_ut        |
            \ call s:echo_bufline()  |
            \ autocmd! bufline_delayed_autocmds
    augroup END
endfunction

augroup bufline_autocmds
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
    let line = winview["lnum"]

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
    for id in s:matchids
        call matchdelete(id)
    endfor
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


" MoveLine              {{{2
" TODO: consider 'matze/vim-move'
" Simple plugin for moving lines up and down
function! s:move_up_or_down(move_arg)
    let col = col('.')
    exec 'silent!' a:move_arg
    call cursor(0, col)
endfunction

function! s:move_up(line_getter, range)
    let line_num = line(a:line_getter)
    if line_num - v:count1 - 1 < 0
        return
    else
        let move_arg = a:line_getter." -".(v:count1 + 1)
        call s:move_up_or_down(a:range."move ".move_arg)
    endif
endfunction

function! s:move_down(line_getter, range)
    let line_num = line(a:line_getter)
    if line_num + v:count1 > line("$")
        return
    else
        let move_arg = a:line_getter." +".v:count1
        call s:move_up_or_down(a:range."move ".move_arg)
    endif
endfunction

function! MoveLine(direction, visual)
    let range = a:visual ? "'<,'>" : ""
    if a:direction == 'k'
        let line = a:visual ? "'<" : "."
        call s:move_up(line, range)
    elseif a:direction == 'j'
        let line = a:visual ? "'>" : "."
        call s:move_down(line, range)
    endif
    if a:visual
        normal! gv
    endif
endfunction


" Autocomplete     {{{1
set complete-=i    " don't use included files for completion, too slow

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

" SuperTab              {{{2
" XXX: This NEEDS to be last in the autocomplete section, since it needs to
" know the omnifunc that the previous filetype-specific sections set.

" let g:SuperTabCrMapping = 1         " <CR> puts the word, ends the completion
let g:SuperTabLongestEnhanced = 1
" let g:SuperTabLongestHighlight = 1  " preselect the first entry
let g:SuperTabDefaultCompletionType = "context"
" let g:SuperTabRetainCompletionDuration = "completion"  " immidately forget the completion type

" autocmd FileType *
"     \ if &omnifunc != '' | call SuperTabChain(&omnifunc, "<c-n>") | endif

" or perhaps
" autocmd FileType *
"     \ if &omnifunc != '' |
"     \   call SuperTabChain(&omnifunc, "<c-p>") |
"     \   call SuperTabSetDefaultCompletionType("<c-x><c-u>") |
"     \ endif

" Neocomplete           {{{2
if !exists('g:neocomplete#force_omni_input_patterns')
    let g:neocomplete#force_omni_input_patterns = {}
endif
let g:neocomplete#force_omni_input_patterns.python =
    \ '\%([^. \t]\.\|^\s*@\|^\s*from\s.\+import \|^\s*from \|^\s*import \)\w*'
" alternative pattern: '\h\w*\|[^. \t]\.\w*'

" Appearance       {{{1
" let &t_ZH = Terminfo('sitm', 1)
" let &t_ZR = Terminfo('ritm', 1)

let g:molokai_original = 1

let g:thematic#defaults = {
    \   'typeface':
    \       fontdetect#firstFontFamily([ "Anonymous Pro",
    \                                    "monofur",
    \                                    "Fantasque Sans Mono",
    \                                    "Inconsolata",
    \                                    "Consolas",
    \                                    "Monaco" ]),
    \   'font-size': 13,
    \   'linespace': 0,
    \
    \   'fullscreen': 0,
    \   'laststatus': 2,
    \   'ruler': 0,
    \   'airline-theme': 'bubblegum',
    \ }

let g:thematic#themes = {
    \ 'badwolf': {'airline-theme': 'bubblegum'},
    \
    \ 'solarized': {'background':  'light',
    \               'airline-theme': 'solarized'},
    \
    \ 'hemisu': {'background': 'light'},
    \
    \ 'iawriter': {
    \     'colorscheme': 'pencil',
    \     'background': 'light',
    \     'columns': 90,
    \     'font-size': 14,
    \     'fullscreen': 1,
    \     'laststatus': 0,
    \     'linespace': 8,
    \     'typeface': 'Cousine',
    \ },
    \ }
let g:thematic#theme_name = 'badwolf'

function! Highlights()
" Diff                  {{{2
highlight DiffAdd     cterm=bold ctermbg=none ctermfg=119
highlight DiffDelete  cterm=bold ctermbg=none ctermfg=167
highlight DiffChange  cterm=bold ctermbg=none ctermfg=227

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
    " TODO: consider using OptionSet event to check for options like
    " termguicolors and reset the colorscheme
    au ColorScheme * call Highlights()
augroup END

" Autocommands     {{{1
augroup general    "    {{{2
    au!

    " Make Alt work in terminal
    " au VimEnter * call Tput('smm', 1)
    " au VimLeave * call Tput('rmm', 1)

    au GUIEnter * nested call SetupGUI()
    " au GUIEnter * nested call thematic#init(g:thematic#theme_name)

    " Don't highlight the line of the cursor in other windows
    au WinEnter * set   cursorline
    au WinLeave * set nocursorline

    " Turn off the relative numbering in other windows
    " au WinEnter * call RestoreRelNum()
    " au WinLeave * call OffRelNumPreserve()

    " Automaticaly destroy fugitive buffers when hidden
    au BufReadPost fugitive://* set bufhidden=delete
    au User fugitive
        \ if fugitive#buffer().type() =~# '^\%(tree\|blob\)$'   |
        \     nnoremap <buffer> .. :edit %:h<CR>                |
        \ endif

    " Re-source .vimrc on save
    au BufWritePost $MYVIMRC nested source $MYVIMRC
augroup END

augroup ft_vim     "    {{{2
    au!
    au FileType vim setlocal keywordprg=:help
augroup END

augroup ft_python  "    {{{2
    au!

    au FileType python setlocal suffixesadd=.py
    au FileType python setlocal includeexpr=PythonIncludeExpr(v:fname)
    au FileType python let &l:path = join(['.', PythonPath(3), PythonPath(2)], ',')
    au FileType python let &l:include = join([
                \ '^\s*import\s\+\zs[_.[:alnum:]]\+\ze',
                \ '^\s*from\s\+\zs[_.[:alnum:]]\+\ze\s\+import'], '\|')
    " au FileType python let &l:isfname = '_,@,48-57,.'

    " This next pattern, courtesy of wushee on #vim on freenode, can find
    " multi-import lines, matching each package separately, i.e. in:
    "     import foo, bar
    " it would match both foo and bar.  However, it can't work like that as
    " the value of 'include'.  AFAICT (from vim's code), vim will only ever
    " consider the first match on each a line to be an include.  Pity.
    " au FileType python let &l:include = join([
    "             \ '\(^\s*import .*\)\@<=\zs[_.[:alnum:]]\+\ze',
    "             \ '^\s*from\s\+\zs[_.[:alnum:]]\+\ze\s\+import'], '\|')

    au FileType python setlocal
        \ tabstop=8
        \ softtabstop=4
        \ shiftwidth=4
        \ textwidth=79
        \ expandtab
        \ autoindent
        \ fileformat=unix
augroup END

augroup ft_cpt  "       {{{2
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
            exec join(['normal!', a:default])
        endif
    else
        exec join(['normal! ', v:count, a:default], '')
    endif
endfunction


function! s:all_mode_map(key, ...)     " {{{2
    let cmd = join(a:000)
    exec 'nnoremap' '<silent>' a:key ':'.cmd.'<CR>'
    exec 'inoremap' '<silent>' a:key '<C-o>:'.cmd.'<CR>'
    exec 'vnoremap' '<silent>' a:key ':<C-u>'.cmd.'<CR>gv'
endfunction

command! -nargs=+ Anoremap call s:all_mode_map(<f-args>)

function! s:operator_map(key, ...)     " {{{2
    let cmd = join(a:000)
    exec 'nmap' a:key cmd
    exec 'xmap' a:key cmd
    exec 'omap' a:key cmd
endfunction

command! -nargs=+ OperatorMap call s:operator_map(<f-args>)
" }}}2

noremap j gj
noremap k gk
noremap H ^
noremap L $
noremap Y y$
noremap gj j
noremap gk k
noremap gV `[v`]
vnoremap < <gv
vnoremap > >gv
nnoremap <BS> <C-^>
nnoremap gb :ls<CR>:b<Space>

" TODO: put this somewhere proper
function! SyntaxInfo()
    return printf('hi<%s> trans<%s> lo<%s>',
        \ synIDattr(synID(line("."),col("."),1),"name"),
        \ synIDattr(synID(line("."),col("."),0),"name"),
        \ synIDattr(synIDtrans(synID(line("."),col("."),1)),"name"))
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

if s:has_plugin('vim-sneak')
    " call Omap('f', '<Plug>Sneak_f')
    " call Omap('F', '<Plug>Sneak_F')
    " call Omap('t', '<Plug>Sneak_t')
    " call Omap('T', '<Plug>Sneak_T')
    OperatorMap f <Plug>Sneak_f
    OperatorMap F <Plug>Sneak_F
    OperatorMap t <Plug>Sneak_t
    OperatorMap T <Plug>Sneak_T
endif

if s:has_plugin('SplitJoin')
    " TODO: use SplitJoin plugin
    nnoremap <silent> J :<C-u>call <SID>try_cmd('SplitjoinJoin',  'J')<CR>
    nnoremap <silent> S :<C-u>call <SID>try_cmd('SplitjoinSplit', "r\015")<CR>
endif

" can't use Anoremap because there's no way to get the current mode
nnoremap <silent> <A-j> :<C-u>call MoveLine('j', 0)<CR>
inoremap <silent> <A-j> <C-o>:call MoveLine('j', 0)<CR>
vnoremap <silent> <A-j> :<C-u>call MoveLine('j', 1)<CR>
" Anoremap <A-j> call MoveLine('j', mode() =~ 'v')

nnoremap <silent> <A-k> :<C-u>call MoveLine('k', 0)<CR>
inoremap <silent> <A-k> <C-o>:call MoveLine('k', 0)<CR>
vnoremap <silent> <A-k> :<C-u>call MoveLine('k', 1)<CR>
" Anoremap <A-k> call MoveLine('k', mode() =~ 'v')

nnoremap <silent> <leader>l :call ToggleQuickFix('l')<CR>
nnoremap <silent> <leader>e :call ToggleQuickFix('c')<CR>

if s:has_plugin('ctrlp.vim')
    nnoremap gb :CtrlPBuffer<CR>
endif

if s:has_plugin('vim-ctrlp-tjump')
    nnoremap <C-]> :CtrlPtjump<CR>
    vnoremap <C-]> :CtrlPtjumpVisual<CR>
endif

if s:executable('fzy', 'ag')
    " nnoremap <C-p> :call FzyDo(":e",  "ag -l -g ''")<CR>
    " nnoremap <C-s> :call FzyDo(":vs", "ag -l -g ''")<CR>
    " nnoremap <C-S-v> :call FzyDo(":sp", "ag -l -g ''")<CR>
elseif s:executable('fzy')
    " nnoremap <C-p> :call FzyDo(":e",  "find -type f")<CR>
    " nnoremap <C-s> :call FzyDo(":sp", "find -type f")<CR>
    " nnoremap <C-S-v> :call FzyDo(":vs", "find -type f")<CR>
endif

Anoremap <F5>a AirlineToggle
Anoremap <F5>b call ToggleBackground()
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

" s:zip                 {{{2
function! s:zip(...)
    let lists = a:000
    let length = min(map(copy(lists), 'len(v:val)'))

    let i = 0
    let zipped = []
    while i < length
        let tuple = []

        let j = 0
        while j < len(lists)
            call add(tuple, lists[j][i])
            let j += 1
        endwhile

        call add(zipped, tuple)
        let i += 1
    endwhile

    return zipped
endfunction

" FzyDo                 {{{2
function! FzyDo(choice_command, vim_command)
    try
        let output = system(a:choice_command . " | fzy ")
    catch /Vim:Interrupt/
        " Swallow errors from ^C, allow redraw! below
    endtry
    redraw!
    if v:shell_error == 0 && !empty(output)
        exec a:vim_command output
    endif
endfunction

" Colors                {{{2
function! Hex2rgb(hex)
    return map(matchlist(a:hex, '\v\#(..)(..)(..)')[1:3], '0 + ("0x".v:val)')
endfunction!

function! Namedcolor2rgb(name)
    return lightline#colortable#name_to_rgb(a:name)
endfunction

function! Color2rgb(color)
    let rgb = Hex2rgb(a:color)
    if !len(rgb) | let rgb = Namedcolor2rgb(a:color) | endif
    if !len(rgb) | throw printf("NotAColor: %s", a:color) | endif
    return rgb
endfunction

function! Rgb2hex(rgb)
    return printf('#%02x%02x%02x', a:rgb[0], a:rgb[1], a:rgb[2])
endfunction


" Lightline             {{{2
" TODO: move this to the Appearance section
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
        \     'left': [ [ 'mode', 'paste' ],
        \               [ 'fugitive', 'filename', 'modified' ],
        \               [ 'ctrlpmark' ] ],
        \     'right': [ [ 'syntastic', 'lineinfo' ],
        \                [ 'percent' ],
        \                [ 'fileformat', 'fileencoding', 'filetype' ] ],
        \ },
        \ 'components': {
        \   'modified': '%{&filetype=="help"?"":&modified?"+":&modifiable?"":"-"}'
        \ },
        \ 'component_expand': {
        \   'syntastic': 'SyntasticStatuslineFlag',
        \ },
        \ 'component_type': {
        \   'syntastic': 'error',
        \ },
        \ }, 'keep')
endfunction!

" function! SyntasticCheckHook(errors)
"     " Needed to make 'component_expand' work
"     if !exists('g:lightline_loaded') | return | endif
"     call lightline#update_once()
" endfunction

" call SetupLightline('wombat')

function! AirlineCustom()    " {{{3
    function! Fenc()
        if &fenc !=# 'utf-8'
            return &fenc
        endif
        return ''
    endfunction

    call airline#parts#define_raw('filename', '%<%f%{&modified ? " +" : ""}')
    call airline#parts#define_function('fenc', 'Fenc')

    let g:airline_section_b = airline#section#create_left(['filename', 'branch'])
    let g:airline_section_c = 0
    let g:airline_section_x = airline#section#create_right(['fenc', 'tagbar'])
    let g:airline_section_y = airline#section#create_right(['filetype'])
    let g:airline_section_z = airline#section#create_right(['%p%%', ' %l:%c'])
endfunction


" Airline               {{{2
" TODO: move this to the Appearance section
function! Airline_GetFileInfo()
    return (&l:bomb ? '[BOM]' : '')
        \ .(&fenc !=# 'utf-8' ? &fenc : '')
        \ .(&ff !=# 'unix' ? '['.&ff.']' : '')
endfunction

function! AirlineCustom()    " {{{3
    call airline#parts#define_function('finfo', 'Airline_GetFileInfo')

    let g:airline_section_y = airline#section#create(['finfo'])
endfunction

function! AirlineCustomTheme(palette)  " {{{3
    " colors are [guifg, guibg, ctermfg, ctermbg, styles]

    let white = 231
    let brightpurple = 189
    let mediumpurple = 98
    let darkestpurple = 55

    " Use the style for CtrlP that powerline used
    let a:palette.ctrlp = airline#extensions#ctrlp#generate_color_map(
        \ ['', '', brightpurple, darkestpurple, ''],
        \ ['', '', white, mediumpurple, ''],
        \ ['', '', darkestpurple, white, 'bold'])

    " Give the right side the same style as the left in replace mode.  This
    " may just be a bug in the bubblegum theme but whatever.
    let a:palette.replace.airline_z = a:palette.replace.airline_a
    let a:palette.replace.airline_x = a:palette.replace.airline_c
endfunction
" }}}3

" au VimEnter * call AirlineCustom()
call AirlineCustom()
let g:airline_theme_patch_func = 'AirlineCustomTheme'

" Mode-aware cursor     {{{2
" TODO: move this to the Appearance section
set gcr=a:block

" mode aware cursors
set gcr+=o:hor50-Cursor
set gcr+=n:Cursor
set gcr+=i-ci-sm:InsertCursor
set gcr+=r-cr:ReplaceCursor-hor20
set gcr+=c:CommandCursor
set gcr+=v-ve:VisualCursor

set gcr+=a:blinkon0

hi InsertCursor  ctermfg=15 guifg=#fdf6e3 ctermbg=37  guibg=#2aa198
hi VisualCursor  ctermfg=15 guifg=#fdf6e3 ctermbg=125 guibg=#d33682
hi ReplaceCursor ctermfg=15 guifg=#fdf6e3 ctermbg=65  guibg=#dc322f
hi CommandCursor ctermfg=15 guifg=#fdf6e3 ctermbg=166 guibg=#cb4b16

" Automake directory    {{{2
function! EnsureDirExists()
    let basedir = expand("%:h")
    if !s:path_exists(basedir)
        if confirm("Some directories in the filepath don't exist.",
                 \ "&Create them?")
            call s:makedirs(basedir)
        endif
    endif
endfunction

augroup AutoMkdir
    autocmd!
    autocmd  BufNewFile * :call EnsureDirExists()
augroup END

" TimeIt                {{{2
function! TimeIt(start)
    " Use it like this:
    "   :let s = reltime()
    "   :sleep 100m
    "   :let time_passed = s:milli_since(s)
    " This would result in a Float which represents the milliseconds passed.

    let rel_time = reltimestr(reltime(a:start))
    let [sec, milli] = map(split(rel_time, '\ze\.'), 'str2float(v:val)')
    return (sec + milli) * 1000
endfunction

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

" Add useful buffer-local mappings for help windows                        {{{2
" Like, q for exit and stuff like that.  Help windows are readonly so anything
" editing related (like macros) are probably not that useful.

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

" Consider switching to fzf                                                {{{2
" Ctrl-P is awesome but fzf is more general, can be used in the shell as well.
" If it's not installed though, it can't be used (think Wndows).  fzf can be
" combined with ripgrep as shown here
"   * https://www.reddit.com/r/linux/comments/5rrpyy/turbo_charge_bash_with_fzf_ripgrep/

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

" Replace/rewrite thematic                                                 {{{2
"   * reedes/vim-thematic

" Consider Unite/Denite again                                              {{{2
"   * Shougo/unite.vim
"   * Shougo/denite.nvim
" I don't have to write these really but whatever.  Denite is the successor.

" Checkout http://howivim.com/2016/tyru/ for ideas                         {{{2
" Has some stuff about visualstar and mappings and whatnot.

" diffopt                                                                  {{{2
