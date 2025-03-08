lua << EOF
-- Install packer if not installed
local install_path = vim.fn.stdpath('data') .. '/site/pack/packer/start/packer.nvim'
if vim.fn.empty(vim.fn.glob(install_path)) > 0 then
  vim.fn.system({'git', 'clone', '--depth', '1', 'https://github.com/wbthomason/packer.nvim', install_path})
  vim.cmd 'packadd packer.nvim'
end

-- Plugins
require('packer').startup(function()
  use 'wbthomason/packer.nvim'
  use {'neovim/nvim-lspconfig'}
  use {'hrsh7th/nvim-cmp'}
  use {'hrsh7th/cmp-nvim-lsp'}
  use {'L3MON4D3/LuaSnip'}
  use {'nvim-treesitter/nvim-treesitter', run = ':TSUpdate'}
  use {'nvim-telescope/telescope.nvim', requires = {{'nvim-lua/plenary.nvim'}}}
  use {'nvim-lualine/lualine.nvim'}
  use {'kyazdani42/nvim-tree.lua'}
  use {'akinsho/bufferline.nvim'}
  use {'tpope/vim-fugitive'}
  use {'lewis6991/gitsigns.nvim'}
  use {'rmagatti/auto-session'}
  use {'windwp/nvim-autopairs'}
  use {'nvim-telescope/telescope-project.nvim'}
  use {'akinsho/toggleterm.nvim'}
  use {'karb94/neoscroll.nvim'}
  use {'CRAG666/code_runner.nvim'}
  use {'github/copilot.vim'}
  use {'tzachar/cmp-tabnine', run='./install.sh', requires = 'hrsh7th/nvim-cmp'}
  use {'dccsillag/magma-nvim'}
  use {'hkupty/iron.nvim'}
  use {'sharkdp/fd'}
  use {'simrat39/rust-tools.nvim'}
  use {'mfussenegger/nvim-dap'}
  use {'jbyuki/one-small-step-for-vimkind'}
  use {'lervag/vimtex'}
  use {'julialang/julia-vim'}
  use {'Olical/conjure'}
  use {'jupyter-vim/jupyter-vim'}
  use {'maxmellon/vim-graphql'}
  use {'aklt/plantuml-syntax'}
end)

-- LSP Config
local lspconfig = require('lspconfig')
lspconfig.pyright.setup{}
lspconfig.rust_analyzer.setup{}
lspconfig.tsserver.setup{}

-- Rust Tools
require('rust-tools').setup({})

-- Debugging
require('dap').setup({})

-- Autocompletion
local cmp = require('cmp')
cmp.setup {
  mapping = cmp.mapping.preset.insert({
    ['<C-Space>'] = cmp.mapping.complete(),
    ['<CR>'] = cmp.mapping.confirm({ select = true }),
  }),
  sources = cmp.config.sources({
    { name = 'nvim_lsp' },
    { name = 'buffer' },
    { name = 'cmp_tabnine' }
  })
}

-- Treesitter
require('nvim-treesitter.configs').setup {
  ensure_installed = { 'python', 'rust', 'javascript', 'lua', 'bash', 'julia' },
  highlight = { enable = true },
}

-- Autoformat on save
vim.cmd [[autocmd BufWritePre * lua vim.lsp.buf.format()]]

-- Better window navigation
vim.api.nvim_set_keymap('n', '<C-h>', '<C-w>h', { noremap = true })
vim.api.nvim_set_keymap('n', '<C-j>', '<C-w>j', { noremap = true })
vim.api.nvim_set_keymap('n', '<C-k>', '<C-w>k', { noremap = true })
vim.api.nvim_set_keymap('n', '<C-l>', '<C-w>l', { noremap = true })

-- Keybindings
vim.api.nvim_set_keymap('n', '<Leader>ff', ':Telescope find_files<CR>', { noremap = true })
vim.api.nvim_set_keymap('n', '<Leader>fg', ':Telescope live_grep<CR>', { noremap = true })
vim.api.nvim_set_keymap('n', '<Leader>fb', ':Telescope buffers<CR>', { noremap = true })
vim.api.nvim_set_keymap('n', '<Leader>fh', ':Telescope help_tags<CR>', { noremap = true })
vim.api.nvim_set_keymap('n', '<Leader>fp', ':Telescope project<CR>', { noremap = true })
vim.api.nvim_set_keymap('n', '<Leader>r', ':RunCode<CR>', { noremap = true, silent = true })

-- Status Line
require('lualine').setup {
  options = { theme = 'gruvbox' },
  sections = {
    lualine_b = { 'branch', 'diff', 'diagnostics' },
  }
}

-- Floating Terminal
require('toggleterm').setup {
  open_mapping = [[<C-\>]],
  direction = 'float'
}

-- Git Blame in Status Line
require('gitsigns').setup {
  current_line_blame = true
}

-- Auto-close Brackets and Quotes
require('nvim-autopairs').setup {}

-- Smooth Scrolling
require('neoscroll').setup()

-- Session Management
require('auto-session').setup {}

-- Jupyter Notebook Support
require('magma-nvim').setup()
require('jupyter-vim').setup()

-- REPL Support
require('iron.core').setup({
  repl_definition = {
    python = {
      command = {"ipython", "--no-autoindent"}
    },
    julia = {
      command = {"julia"}
    }
  }
})

-- Editor Settings
vim.o.number = true
vim.o.relativenumber = true
vim.o.tabstop = 4
vim.o.shiftwidth = 4
vim.o.expandtab = true
vim.o.smartindent = true

EOF
