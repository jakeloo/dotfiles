let is_windows=has("win32")
if is_windows
  let g:python3_host_prog = 'C:\Windows\py.exe'
  if empty(glob('$LOCALAPPDATA\nvim\autoload\plug.vim'))
    silent !powershell (md "$env:LOCALAPPDATA\nvim\autoload")
    silent !powershell (New-Object Net.WebClient).DownloadFile(
          \ 'https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim', 
          \ $env:LOCALAPPDATA + '\nvim\autoload\plug.vim')
    autocmd VimEnter * PlugInstall --sync | source $MYVIMRC
  endif
  call plug#begin('$LOCALAPPDATA\nvim\plugged')
else
  let g:python3_host_prog = '/usr/bin/python3'
  if empty(glob('~/.config/nvim/autoload/plug.vim'))
    silent !curl -fLo ~/.config/nvim/autoload/plug.vim --create-dirs https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
    autocmd VimEnter * PlugInstall --sync | source $MYVIMRC
  endif
  call plug#begin('~/.config/nvim/plugged')
endif

" Neobundle
Plug 'tpope/vim-fugitive'
Plug 'tpope/vim-obsession'
Plug 'gregsexton/gitv'
Plug 'scrooloose/nerdtree'
Plug 'Xuyuanp/nerdtree-git-plugin'
Plug 'kien/ctrlp.vim'
Plug 'rking/ag.vim'
Plug 'bling/vim-airline'
Plug 'yegappan/greplace'
Plug 'sheerun/vim-polyglot'
Plug 'lervag/vimtex'
Plug 'preservim/nerdcommenter'
Plug 'neoclide/coc.nvim', {'branch': 'release'}
Plug 'pantharshit00/vim-prisma'
Plug 'TovarishFin/vim-solidity'

" colors
Plug 'chriskempson/base16-vim'
Plug 'owickstrom/vim-colors-paramount'
Plug 'nightsense/vimspectr'

call plug#end()

filetype plugin on
filetype plugin indent on

" colorsss
set background=dark
set termguicolors                " true color
silent! colorscheme base16-ocean

" Required for operations modifying multiple buffers like rename.
set hidden

" Show programming syntax
syntax on

" Show lines
set number

" show spaces / tabs
set list

" config to soft tab
set softtabstop=2 shiftwidth=2 expandtab

" Set outside file
set autoread

"Copy indent from current line when starting a new line
set autoindent
"when we autoindent, backspace will delete the entire tab width, not just individual spaces
set smarttab
set smartindent

" Always show status
set laststatus=2

"searching
set hlsearch                    " highlight matches
set incsearch                   " incremental searching
set ignorecase                  " searches are case insensitive...
set smartcase                   " ... unless they contain at least one capital letter

" Remap arrow keys
noremap <Left> <NOP>
noremap <Right> <NOP>
noremap <Up> <NOP>
noremap <Down> <NOP>
" Remap arrow keys for insert mode
inoremap <Left> <NOP>
inoremap <Right> <NOP>
inoremap <Up> <NOP>
inoremap <Down> <NOP>
" Remap arrow keys for visual mode
vnoremap <Left> <NOP>
vnoremap <Right> <NOP>
vnoremap <Up> <NOP>
vnoremap <Down> <NOP>

" Copy to clipboard
vnoremap  <leader>y  "+y
nnoremap  <leader>Y  "+yg_
nnoremap  <leader>y  "+y
nnoremap  <leader>yy  "+yy

" Paste from clipboard
nnoremap <leader>p "+p
nnoremap <leader>P "+P
vnoremap <leader>p "+p
vnoremap <leader>P "+P

" terminal esc
tnoremap <Esc> <C-\><C-n>

" mouse selection
set mouse=a

" copy + paste
if is_windows
  source $VIMRUNTIME/mswin.vim
endif

" Nerdtree
let g:nerdtree_tabs_open_on_gui_startup=0
let NERDTreeShowHidden=1
autocmd StdinReadPre * let s:std_in=1
autocmd VimEnter * if argc() == 0 && !exists("s:std_in") | NERDTree | endif
nmap ,n :NERDTreeToggle<CR>
nmap ,m :NERDTreeFind<CR>

" ctrlp
let g:ctrlp_user_command = ['.git', 'cd %s && git ls-files -co --exclude-standard']
let g:ctrlp_custom_ignore = '\v[\/](node_modules|target|dist|virtualenv|build)|(\.(swp|ico|git|svn|o))$'

" greplace
set grepprg=ag
let g:grep_cmd_opts = '--line-numbers --noheading'

" coc.nvim
let g:coc_global_extensions = [
  \ 'coc-clangd',
  \ 'coc-go',
  \ 'coc-rls',
  \ 'coc-pyright',
  \ 'coc-java',
  \ 'coc-vimtex',
  \ 'coc-tsserver',
  \ 'coc-html',
  \ 'coc-css',
  \ 'coc-json',
  \ 'coc-yaml',
  \ 'coc-prisma',
  \ 'coc-eslint',
  \ 'coc-prettier',
  \ 'coc-styled-components',
\ ]

" Some servers have issues with backup files, see #649
set nobackup
set nowritebackup

set updatetime=300
set shortmess+=c
set signcolumn=yes
set statusline^=%{coc#status()}%{get(b:,'coc_current_function','')}

function! s:check_back_space() abort
  let col = col('.') - 1
  return !col || getline('.')[col - 1]  =~# '\s'
endfunction

function! s:show_documentation()
  if (index(['vim','help'], &filetype) >= 0)
    execute 'h '.expand('<cword>')
  else
    call CocAction('doHover')
  endif
endfunction

" Highlight symbol under cursor on CursorHold
autocmd CursorHold * silent call CocActionAsync('highlight')
autocmd FileType json syntax match Comment +\/\/.\+$+
inoremap <silent><expr> <TAB>
      \ pumvisible() ? "\<C-n>" :
      \ <SID>check_back_space() ? "\<TAB>" :
      \ coc#refresh()
inoremap <expr><S-TAB> pumvisible() ? "\<C-p>" : "\<C-h>"
" Use <c-space> to trigger completion.
inoremap <silent><expr> <c-space> coc#refresh()
" Remap for rename current word
nmap <silent> <F2> <Plug>(coc-rename)
" Remap for format selected region
nmap <silent> gd <Plug>(coc-definition)
nmap <silent> gy <Plug>(coc-type-definition)
nmap <silent> gi <Plug>(coc-implementation)
nmap <silent> gr <Plug>(coc-references)

" commenter
nmap <silent> <C-c> <plug>NERDCommenterInvert<CR>
xmap <silent> <C-c> <plug>NERDCommenterInvert<CR>

" vimtex
let g:vimtex_compiler_latexmk = {
      \ 'options' : [
      \   '-xelatex',
      \   '-shell-escape',
      \   '-silent',
      \   '-synctex=1',
      \   '-interaction=nonstopmode',
      \ ]
      \}

let g:polyglot_disabled = ['solidity']

