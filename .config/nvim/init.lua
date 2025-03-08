-- Install packer if not installed
local install_path = vim.fn.stdpath('data') .. '/site/pack/packer/start/packer.nvim'
if vim.fn.empty(vim.fn.glob(install_path)) > 0 then
  vim.fn.system({'git', 'clone', '--depth', '1', 'https://github.com/wbthomason/packer.nvim', install_path})
  vim.cmd 'packadd packer.nvim'
end

-- Set leader key
vim.g.mapleader = " "

-- Plugins
require('packer').startup(function(use)
  use 'wbthomason/packer.nvim'
  use {'neovim/nvim-lspconfig'}
  use {'hrsh7th/nvim-cmp'}
  use {'hrsh7th/cmp-nvim-lsp'}
  use {'hrsh7th/cmp-buffer'} -- Added missing buffer source
  use {'L3MON4D3/LuaSnip'}
  use {'saadparwaiz1/cmp_luasnip'} -- Added for LuaSnip integration
  use {'nvim-treesitter/nvim-treesitter', run = ':TSUpdate'}
  use {'nvim-telescope/telescope.nvim', requires = {{'nvim-lua/plenary.nvim'}}}
  use {'nvim-lualine/lualine.nvim'}
  use {'kyazdani42/nvim-tree.lua'}
  use {'kyazdani42/nvim-web-devicons'} -- Added for file icons
  use {'akinsho/bufferline.nvim', requires = 'kyazdani42/nvim-web-devicons'}
  use {'tpope/vim-fugitive'}
  use {'lewis6991/gitsigns.nvim'}
  use {'rmagatti/auto-session'}
  use {'windwp/nvim-autopairs'}
  use {'nvim-telescope/telescope-project.nvim'}
  use {'akinsho/toggleterm.nvim'}
  use {'karb94/neoscroll.nvim'}
  use {'CRAG666/code_runner.nvim', requires = 'nvim-lua/plenary.nvim'}
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
  
  -- Added colorscheme
  use {'morhetz/gruvbox'}
end)

-- Editor Settings
vim.o.number = true
vim.o.relativenumber = true
vim.o.tabstop = 4
vim.o.shiftwidth = 4
vim.o.expandtab = true
vim.o.smartindent = true
vim.o.termguicolors = true -- Added for better color support

-- Apply colorscheme
vim.cmd [[colorscheme gruvbox]]

-- LSP Config
local lspconfig = require('lspconfig')

-- Add basic setup with error handling
local function setup_lsp(server, config)
  config = config or {}
  
  local status_ok, lsp = pcall(require, 'lspconfig')
  if not status_ok then
    vim.notify("Failed to load lspconfig", vim.log.levels.ERROR)
    return
  end
  
  lsp[server].setup(config)
end

setup_lsp('pyright')
setup_lsp('rust_analyzer')
setup_lsp('tsserver')

-- Rust Tools
local status_ok, rust_tools = pcall(require, 'rust-tools')
if status_ok then
  rust_tools.setup({})
else
  vim.notify("Failed to load rust-tools", vim.log.levels.WARN)
end

-- Debugging
local status_ok, dap = pcall(require, 'dap')
if status_ok then
  dap.setup({})
else
  vim.notify("Failed to load dap", vim.log.levels.WARN)
end

-- Autocompletion
local status_ok, cmp = pcall(require, 'cmp')
if status_ok then
  local luasnip_ok, luasnip = pcall(require, 'luasnip')
  
  cmp.setup {
    snippet = {
      expand = function(args)
        if luasnip_ok then
          luasnip.lsp_expand(args.body)
        end
      end,
    },
    mapping = cmp.mapping.preset.insert({
      ['<C-Space>'] = cmp.mapping.complete(),
      ['<CR>'] = cmp.mapping.confirm({ select = true }),
      ['<Tab>'] = cmp.mapping(function(fallback)
        if cmp.visible() then
          cmp.select_next_item()
        elseif luasnip_ok and luasnip.expand_or_jumpable() then
          luasnip.expand_or_jump()
        else
          fallback()
        end
      end, { 'i', 's' }),
      ['<S-Tab>'] = cmp.mapping(function(fallback)
        if cmp.visible() then
          cmp.select_prev_item()
        elseif luasnip_ok and luasnip.jumpable(-1) then
          luasnip.jump(-1)
        else
          fallback()
        end
      end, { 'i', 's' }),
    }),
    sources = cmp.config.sources({
      { name = 'nvim_lsp' },
      { name = 'luasnip' },
      { name = 'buffer' },
      { name = 'cmp_tabnine' }
    })
  }
else
  vim.notify("Failed to load nvim-cmp", vim.log.levels.WARN)
end

-- Treesitter
local status_ok, treesitter = pcall(require, 'nvim-treesitter.configs')
if status_ok then
  treesitter.setup {
    ensure_installed = { 'python', 'rust', 'javascript', 'lua', 'bash', 'julia' },
    highlight = { enable = true },
    indent = { enable = true }, -- Added indentation support
    incremental_selection = { enable = true }, -- Added selection features
  }
else
  vim.notify("Failed to load nvim-treesitter", vim.log.levels.WARN)
end

-- Telescope Setup
local status_ok, telescope = pcall(require, 'telescope')
if status_ok then
  telescope.setup{}
  
  -- Load telescope extensions
  pcall(telescope.load_extension, 'project')
else
  vim.notify("Failed to load telescope", vim.log.levels.WARN)
end

-- Nvim-tree Setup
local status_ok, nvim_tree = pcall(require, 'nvim-tree')
if status_ok then
  nvim_tree.setup{}
else
  vim.notify("Failed to load nvim-tree", vim.log.levels.WARN)
end

-- Bufferline Setup
local status_ok, bufferline = pcall(require, 'bufferline')
if status_ok then
  bufferline.setup{}
else
  vim.notify("Failed to load bufferline", vim.log.levels.WARN)
end

-- Code Runner Setup
local status_ok, code_runner = pcall(require, 'code_runner')
if status_ok then
  code_runner.setup{
    mode = "term",
    focus = true,
    term = {
      position = "bot",
      size = 15,
    },
    filetype = {
      python = "python3 -u",
      rust = "cargo run",
      javascript = "node",
      julia = "julia",
    },
  }
else
  vim.notify("Failed to load code_runner", vim.log.levels.WARN)
end

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
vim.api.nvim_set_keymap('n', '<Leader>e', ':NvimTreeToggle<CR>', { noremap = true, silent = true }) -- Added NvimTree toggle

-- Status Line
local status_ok, lualine = pcall(require, 'lualine')
if status_ok then
  lualine.setup {
    options = { theme = 'gruvbox' },
    sections = {
      lualine_b = { 'branch', 'diff', 'diagnostics' },
    }
  }
else
  vim.notify("Failed to load lualine", vim.log.levels.WARN)
end

-- Floating Terminal
local status_ok, toggleterm = pcall(require, 'toggleterm')
if status_ok then
  toggleterm.setup {
    open_mapping = [[<C-\>]],
    direction = 'float',
    shade_terminals = true,
    shell = vim.o.shell,
    float_opts = {
      border = "curved",
    }
  }
else
  vim.notify("Failed to load toggleterm", vim.log.levels.WARN)
end

-- Git Blame in Status Line
local status_ok, gitsigns = pcall(require, 'gitsigns')
if status_ok then
  gitsigns.setup {
    current_line_blame = true,
    current_line_blame_opts = {
      delay = 300,
    }
  }
else
  vim.notify("Failed to load gitsigns", vim.log.levels.WARN)
end

-- Auto-close Brackets and Quotes
local status_ok, autopairs = pcall(require, 'nvim-autopairs')
if status_ok then
  autopairs.setup {
    check_ts = true,
    ts_config = {
      lua = {'string'},
      javascript = {'template_string'},
    }
  }
else
  vim.notify("Failed to load nvim-autopairs", vim.log.levels.WARN)
end

-- Smooth Scrolling
local status_ok, neoscroll = pcall(require, 'neoscroll')
if status_ok then
  neoscroll.setup()
else
  vim.notify("Failed to load neoscroll", vim.log.levels.WARN)
end

-- Session Management
local status_ok, auto_session = pcall(require, 'auto-session')
if status_ok then
  auto_session.setup {
    auto_session_enable_last_session = true,
    auto_session_enabled = true,
    auto_save_enabled = true,
    auto_restore_enabled = true,
  }
else
  vim.notify("Failed to load auto-session", vim.log.levels.WARN)
end

-- Jupyter Notebook Support
local status_ok, magma = pcall(require, 'magma-nvim')
if status_ok then
  magma.setup()
else
  vim.notify("Failed to load magma-nvim", vim.log.levels.WARN)
end

-- REPL Support
local status_ok, iron = pcall(require, 'iron.core')
if status_ok then
  iron.setup({
    repl_definition = {
      python = {
        command = {"ipython", "--no-autoindent"}
      },
      julia = {
        command = {"julia"}
      }
    },
    highlight = {
      italic = true
    },
    ignore_blank_lines = true,
  })
else
  vim.notify("Failed to load iron.nvim", vim.log.levels.WARN)
end

-- Set up diagnostics appearance
vim.diagnostic.config({
  virtual_text = true,
  signs = true,
  underline = true,
  update_in_insert = false,
  severity_sort = true,
})

-- Add diagnostic symbols
local signs = { Error = " ", Warn = " ", Hint = " ", Info = " " }
for type, icon in pairs(signs) do
  local hl = "DiagnosticSign" .. type
  vim.fn.sign_define(hl, { text = icon, texthl = hl, numhl = hl })
end
