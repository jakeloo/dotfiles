let is_windows=has("win32")
if is_windows
  let g:python3_host_prog = 'C:\Windows\py.exe'
  call plug#begin('~\AppData\Local\nvim\plugged')
else
  if empty(glob('~/.config/nvim/autoload/plug.vim'))
    silent !curl -fLo ~/.config/nvim/autoload/plug.vim --create-dirs https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
    autocmd VimEnter * PlugInstall --sync | source $MYVIMRC
  endif
  call plug#begin('~/.config/nvim/plugged')
endif

" Neobundle
Plug 'tpope/vim-fugitive'
Plug 'gregsexton/gitv'
Plug 'scrooloose/nerdtree'
Plug 'Xuyuanp/nerdtree-git-plugin'
Plug 'kien/ctrlp.vim'
Plug 'rking/ag.vim'
Plug 'bling/vim-airline'
Plug 'yegappan/greplace'
Plug 'sheerun/vim-polyglot'
Plug 'Shougo/deoplete.nvim', { 'do': ':UpdateRemotePlugins' }
Plug 'w0rp/ale'

" colors
Plug 'chriskempson/base16-vim'
Plug 'owickstrom/vim-colors-paramount'
Plug 'nightsense/vimspectr'


call plug#end()

 " Required:
filetype plugin indent on

" colorsss
"set termguicolors                " true color
"colorscheme paramount
colorscheme base16-ocean
set background=dark

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
nmap ,n :NERDTreeToggle<CR>
nmap ,m :NERDTreeFind<CR>

let g:ctrlp_user_command = ['.git', 'cd %s && git ls-files -co --exclude-standard']
let g:ctrlp_custom_ignore = '\v[\/](node_modules|target|dist|virtualenv)|(\.(swp|ico|git|svn))$'

" greplace
set grepprg=ag
let g:grep_cmd_opts = '--line-numbers --noheading'

" Language Server (ALE)
if is_windows
  let $PATH .= expand(';$APPDATA/npm')

endif
let g:airline#extensions#ale#enabled = 1
let g:ale_sign_column_always = 1
let g:ale_lint_on_text_changed = 0
let g:ale_completion_enabled = 1
let g:ale_linters = {
\ 'javascript': ['eslint'],
\ 'python': ['pylint']
\ }
let g:ale_fixers = {
\   '*': ['remove_trailing_lines', 'trim_whitespace'],
\}


" Deoplete
let g:deoplete#enable_at_startup = 1
