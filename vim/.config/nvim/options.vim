filetype plugin indent on
filetype plugin on

colorscheme gruvbox
hi! LineNrBelow guifg=#a89984 guibg=NONE guisp=NONE gui=NONE
hi! LineNrAbove guifg=#b0a390 guibg=NONE guisp=NONE gui=NONE
" call s:HL('Cursor', s:none, s:none, s:inverse)
" function! GruvboxHlsShowCursor()
"   call s:HL('Cursor', s:bg0, s:hls_cursor)
" endfunction
" 
" function! GruvboxHlsHideCursor()
"   call s:HL('Cursor', s:none, s:none, s:inverse)
" endfunction
" "
"   " Match paired bracket under the cursor
"   call s:HL('MatchParen', s:none, s:bg3, s:bold)

set termguicolors

syntax on

if executable('ag')
  " Use ag over grep
  set grepprg=ag\ --nogroup\ --nocolor
endif

set cursorline
set backspace=indent,eol,start " allow backspacing over everything in insert mode
set expandtab                  " Always uses spaces instead of tabs
set tabstop=2                  " A tab is X spaces
set softtabstop=2              " Insert X spaces when tab is pressed
set shiftwidth=2               " An indent is X spaces
set smarttab                   " Indent instead of tab at start of line
set shiftround                 " Round spaces to nearest shiftwidth multiple
set nojoinspaces               " Don't convert spaces to tabs
set autoindent                 " automatic indentation

set history=10000              " keep X lines of command line history
set nobackup                   " do not keep a backup file
set ruler                      " show the cursor position all the time
set showcmd                    " display incomplete commands
set number                     " show line numbers
set relativenumber             " relative line numbers
set hidden                     " hides files instead of closing
set wildmenu                   " Encganced <Tab> in command mode
set wildmode=longest,list,full " Make <Tab> behave more bash-like
set ignorecase                 " ignore case while searching
set smartcase                  " ignore case if search pattern is all lowercase, case-sensitive otherwise
set autoread                   " automaticaly reread files change outside vim
set undolevels=10000            " set maximum number of changes than can be undone
set autowrite                  " save file on external commands

set formatoptions+=croqlj
set foldcolumn=1
set encoding=utf-8

set matchpairs+=<:>
" set keymap=ukrainian-jcuken
" set keymap=magyar_utf-8
set iminsert=0
set imsearch=-1

set incsearch                   " do incremental searching
set hlsearch                    " highlight search results

" Hightlight tabs and trailing spaces
set list listchars=tab:>-,trail:Ħ

" set completition opetions in insert mode
set completeopt=longest,menuone

" set statusline=%<%f%h%m%r%=char=%b=0x%B\ \ %l,%c%V\ %P
set statusline=%<%f\ %h%m%r%{FugitiveStatusline()}%=%-14.(%l,%c%V%)\ %P
set laststatus=2

set modeline
set noequalalways
set noswapfile

command! -bang -nargs=* Ag call fzf#vim#ag(<q-args>, '--ignore=node_modules', fzf#vim#with_preview(), <bang>0)

let g:rustfmt_autosave = 1
