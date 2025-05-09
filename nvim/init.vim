
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
Plug 'rking/ag.vim'
Plug 'bling/vim-airline'
Plug 'yegappan/greplace'
Plug 'preservim/nerdcommenter'
Plug 'nvim-tree/nvim-tree.lua'
Plug 'nvim-tree/nvim-web-devicons'
Plug 'nvim-treesitter/nvim-treesitter', {'do': ':TSUpdate'}
Plug 'pantharshit00/vim-prisma'
Plug 'vyperlang/vim-vyper'
Plug 'github/copilot.vim'

"companion.nvim
Plug 'nvim-lua/plenary.nvim'
Plug 'hrsh7th/nvim-cmp'
Plug 'nvim-telescope/telescope.nvim'
Plug 'stevearc/dressing.nvim'
Plug 'MeanderingProgrammer/render-markdown.nvim'
Plug 'olimorris/codecompanion.nvim'

" lsp
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

" treesitter
let g:loaded_netrw       = 1
let g:loaded_netrwPlugin = 1

" mason
lua << EOF
require("mason").setup()
require("mason-lspconfig").setup {
  ensure_installed = { "solidity_ls_nomicfoundation", "biome", "ts_ls", "ruff", "pyright" },
  automatic_installation = true
}
EOF

" lsp config
lua << EOF
require('lspconfig').solidity_ls_nomicfoundation.setup {}
require('lspconfig').biome.setup {}
require('lspconfig').ts_ls.setup {}
require('lspconfig').ruff.setup {}
require('lspconfig').pyright.setup{}
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
-- vim.api.nvim_create_autocmd("BufWritePre", {
--  buffer = buffer,
--  callback = function()
--  vim.lsp.buf.format { async = false }
--  end
-- })
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


lua << EOF
require("codecompanion").setup({
  strategies = {
    chat = {
      adapter = "copilot",
    },
    inline = {
      adapter = "copilot",
    },
  },
  display = {
    diff = {
      provider = "mini_diff",
    },
  },
  opts = {
    log_level = "INFO",
  },
})

vim.api.nvim_set_keymap("v", "<LocalLeader>ce", "", {
  callback = function()
    require("codecompanion").prompt("explain")
  end,
  noremap = true,
  silent = true,
})
vim.api.nvim_set_keymap("n", "<C-a>", "<cmd>CodeCompanionActions<cr>", { noremap = true, silent = true })
vim.api.nvim_set_keymap("v", "<C-a>", "<cmd>CodeCompanionActions<cr>", { noremap = true, silent = true })
vim.api.nvim_set_keymap("n", "<LocalLeader>a", "<cmd>CodeCompanionChat Toggle<cr>", { noremap = true, silent = true })
vim.api.nvim_set_keymap("v", "<LocalLeader>a", "<cmd>CodeCompanionChat Toggle<cr>", { noremap = true, silent = true })
vim.api.nvim_set_keymap("v", "ga", "<cmd>CodeCompanionChat Add<cr>", { noremap = true, silent = true })

-- Expand 'cc' into 'CodeCompanion' in the command line
vim.cmd([[cab cc CodeCompanion]])
EOF


"telescope
lua << EOF
require('telescope').setup{
  defaults = {
    -- Default configuration for telescope goes here:
    -- config_key = value,
    mappings = {
      -- i = {
        -- map actions.which_key to <C-h> (default: <C-/>)
        -- actions.which_key shows the mappings for your picker,
        -- e.g. git_{create, delete, ...}_branch for the git_branches picker
        -- ["<C-h>"] = "which_key"
      -- }
    }
  },
  pickers = {
    -- Default configuration for builtin pickers goes here:
    -- picker_name = {
    --   picker_config_key = value,
    --   ...
    -- }
    -- Now the picker_config_key will be applied every time you call this
    -- builtin picker
  },
  extensions = {
    -- Your extension configuration goes here:
    -- extension_name = {
    --   extension_config_key = value,
    -- }
    -- please take a look at the readme of the extension you want to configure
  }
}

local builtin = require('telescope.builtin')
vim.keymap.set('n', '<C-p>', builtin.find_files, { desc = 'Telescope find files' })
vim.keymap.set('n', '<leader>ff', builtin.find_files, { desc = 'Telescope find files' })
vim.keymap.set('n', '<leader>fg', builtin.live_grep, { desc = 'Telescope live grep' })
vim.keymap.set('n', '<leader>fb', builtin.buffers, { desc = 'Telescope buffers' })
vim.keymap.set('n', '<leader>fh', builtin.help_tags, { desc = 'Telescope help tags' })
EOF

" nvim-tree
lua << EOF
require("nvim-tree").setup({
  view = {
    width = 30,
  },
  filters = {
    dotfiles = false,
  },
  renderer = {
    group_empty = true,
    icons = {
      show = {
        git = true,
        file = false,
        folder = false,
        folder_arrow = true,
      },
      glyphs = {
        folder = {
          arrow_closed = "⏵",
          arrow_open = "⏷",
        },
        git = {
          unstaged = "✗",
          staged = "✓",
          unmerged = "⌥",
          renamed = "➜",
          untracked = "★",
          deleted = "⊖",
          ignored = "◌",
        },
      },
    },
  },
})

vim.api.nvim_set_keymap("n", ",n", "<cmd>NvimTreeToggle<cr>", { noremap = true, silent = true })
vim.api.nvim_set_keymap("n", ",m", "<cmd>NvimTreeFindFile<cr>", { noremap = true, silent = true })
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
autocmd FocusGained,BufEnter,CursorHold,CursorHoldI * if mode() != 'c' | checktime | endif
" notification after file change
autocmd FileChangedShellPost *
      \ echohl WarningMsg | echo "File changed on disk. Buffer reloaded." | echohl None


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

" greplace
set grepprg=ag
let g:grep_cmd_opts = '--line-numbers --noheading'

"treesitter
lua << EOF
require'nvim-treesitter.configs'.setup {
  ensure_installed = { "solidity", "lua", "markdown", "markdown_inline", "yaml", "go", "html", "javascript", "python", "rust", "sql", "typescript" },
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
