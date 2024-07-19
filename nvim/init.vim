
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
Plug 'preservim/nerdcommenter'
Plug 'nvim-treesitter/nvim-treesitter', {'do': ':TSUpdate'}
Plug 'pantharshit00/vim-prisma'
Plug 'vyperlang/vim-vyper'
Plug 'github/copilot.vim'

Plug 'williamboman/mason.nvim'
Plug 'williamboman/mason-lspconfig.nvim'
Plug 'neovim/nvim-lspconfig'
Plug 'mfussenegger/nvim-lint'
Plug 'mhartington/formatter.nvim'


" colors
Plug 'chriskempson/base16-vim'
Plug 'owickstrom/vim-colors-paramount'
Plug 'nightsense/vimspectr'

call plug#end()

filetype plugin on
filetype plugin indent on

" mason
lua << EOF
require("mason").setup()
require("mason-lspconfig").setup {
  ensure_installed = { "solidity_ls_nomicfoundation" },
  automatic_installation = true
}
EOF

" lsp config
lua << EOF
require('lspconfig').solidity_ls_nomicfoundation.setup {}
EOF

"formatter
nnoremap <silent> <leader>f :Format<CR>
nnoremap <silent> <leader>F :FormatWrite<CR>

lua << EOF
local util = require "formatter.util"
local defaults = require "formatter.defaults"

require("formatter").setup {
  filetype = {
    solidity = {
      function()
        return {
          exe = "forge",
          args = {
            "fmt",
            "--raw",
            "-"
          },
          stdin = true,
        }
      end
    },

    ["*"] = {
      require("formatter.filetypes.any").remove_trailing_whitespace
    }
  }
}

-- Format After Save
vim.api.nvim_create_augroup("FormatAutogroup", { clear = true })

vim.api.nvim_create_autocmd({ "BufWritePost" }, {
  group = "FormatAutogroup",
  callback = function()
    local ft = vim.bo.filetype
    if true then
      vim.cmd("FormatWrite")
    end
  end,
})
EOF


lua << EOF
local lsp_util = vim.lsp.util

function code_action_listener()
  local context = { diagnostics = vim.lsp.diagnostic.get_line_diagnostics() }
  local params = lsp_util.make_range_params()
  params.context = context
  vim.lsp.buf_request(0, 'textDocument/codeAction', params, function(err, result, ctx, config)
    -- do something with result - e.g. check if empty and show some indication such as a sign
  end)
end

vim.api.nvim_create_autocmd({"CursorHold", "CursorHoldI"}, {
  group = vim.api.nvim_create_augroup("code_action_sign", { clear = true }),
  callback = function()
    -- code_action_listener()
  end,
})
EOF


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
let g:ctrlp_custom_ignore = '\v[\/](node_modules|target|dist|virtualenv|out|build|artifacts|artifacts_forge)|(\.(swp|ico|git|svn|o))$'

" greplace
set grepprg=ag
let g:grep_cmd_opts = '--line-numbers --noheading'

"treesitter
lua << EOF
require'nvim-treesitter.configs'.setup {
  ensure_installed = { "solidity" },
  sync_install = false,
  higlight = {
    enable = true
  }
}
EOF
autocmd VimEnter * TSEnable highlight

" Some servers have issues with backup files, see #649
set nobackup
set nowritebackup

set updatetime=300
set shortmess+=c
set signcolumn=yes

" commenter
nmap <silent> <C-c> <plug>NERDCommenterInvert<CR>
xmap <silent> <C-c> <plug>NERDCommenterInvert<CR>
