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

function! InstallCocExtensions(info)
  if a:info.status == 'installed' || a:info.force
    call coc#util#install()

    let extensions = [
          \   'coc-css',
          \   'coc-rls',
          \   'coc-html',
          \   'coc-json',
          \   'coc-python',
          \   'coc-yaml',
          \   'coc-tsserver',
          \ ]

    for ext in extensions
      call coc#add_extension(ext)
    endfor
  endif
endfunction

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
Plug 'neoclide/coc.nvim', {'branch': 'release', 'do': function('InstallCocExtensions')}

" colors
Plug 'chriskempson/base16-vim'
Plug 'owickstrom/vim-colors-paramount'
Plug 'nightsense/vimspectr'

call plug#end()

 " Required:
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
nmap ,n :NERDTreeToggle<CR>
nmap ,m :NERDTreeFind<CR>

let g:ctrlp_user_command = ['.git', 'cd %s && git ls-files -co --exclude-standard']
let g:ctrlp_custom_ignore = '\v[\/](node_modules|target|dist|virtualenv)|(\.(swp|ico|git|svn))$'

" greplace
set grepprg=ag
let g:grep_cmd_opts = '--line-numbers --noheading'

" coc.nvim
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

" Use `:Format` to format current buffer
command! -nargs=0 Format :call CocAction('format')
" Use `:Fold` to fold current buffer
command! -nargs=? Fold :call     CocAction('fold', <f-args>)
" Use `:OR` for organize import of current buffer
command! -nargs=0 OR   :call     CocAction('runCommand', 'editor.action.organizeImport')

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
nnoremap <silent> K :call <SID>show_documentation()<CR>
" Remap for rename current word
nmap <leader>rn <Plug>(coc-rename)
" Remap for format selected region
xmap <leader>f  <Plug>(coc-format-selected)
nmap <leader>f  <Plug>(coc-format-selected)


