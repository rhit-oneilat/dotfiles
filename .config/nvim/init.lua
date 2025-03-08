-- Install packer if not installed
local install_path = vim.fn.stdpath('data') .. '/site/pack/packer/start/packer.nvim'
if vim.fn.empty(vim.fn.glob(install_path)) > 0 then
  vim.fn.system({'git', 'clone', '--depth', '1', 'https://github.com/wbthomason/packer.nvim', install_path})
  vim.cmd('packadd packer.nvim')
end
-- Set leader key
vim.g.mapleader = " "
-- Plugins
require('packer').startup(function(use)
  use 'wbthomason/packer.nvim'
  use {'neovim/nvim-lspconfig'}
  use {'hrsh7th/nvim-cmp'}
  use {'hrsh7th/cmp-nvim-lsp'}
  use {'hrsh7th/cmp-buffer'} 
  use {'L3MON4D3/LuaSnip'}
  use {'saadparwaiz1/cmp_luasnip'} 
  use {'nvim-treesitter/nvim-treesitter', run = ':TSUpdate'}
  use {'nvim-telescope/telescope.nvim', requires = {{'nvim-lua/plenary.nvim'}}}
  use {'nvim-lualine/lualine.nvim'}
  use {'kyazdani42/nvim-tree.lua'}
  use {'kyazdani42/nvim-web-devicons'} 
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
  -- Theme-related plugins
  use 'folke/tokyonight.nvim'     
  use 'rktjmp/lush.nvim'          
  use 'norcalli/nvim-colorizer.lua' 
  use 'xiyaowong/nvim-transparent' 
end)
  
-- Editor Settings
vim.o.number = true
vim.o.relativenumber = true
vim.o.tabstop = 4
vim.o.shiftwidth = 4
vim.o.expandtab = true
vim.o.smartindent = true
vim.o.termguicolors = true

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
-- FIXED: Using correct LSP server name "tsserver" instead of "typescript"
setup_lsp('ts_ls', {
  filetypes = { "javascript", "javascriptreact", "javascript.jsx", "typescript", "typescriptreact", "typescript.tsx" },
  init_options = {
    hostInfo = "neovim"
  },
})

-- Rust Tools
local status_ok, rust_tools = pcall(require, 'rust-tools')
if status_ok then
  rust_tools.setup({})
else
  vim.notify("Failed to load rust-tools", vim.log.levels.WARN)
end

-- Debugging
local status_ok, dap = pcall(require, 'dap')
if not status_ok then
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
    ensure_installed = { 'python', 'rust', 'javascript', 'typescript', 'lua', 'bash', 'julia' },
    highlight = { enable = true },
    indent = { enable = true }, 
    incremental_selection = { enable = true }, 
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
      typescript = "ts-node", -- Added TypeScript support
      julia = "julia",
    },
  }
else
  vim.notify("Failed to load code_runner", vim.log.levels.WARN)
end

-- Autoformat on save
vim.cmd[[autocmd BufWritePre * lua vim.lsp.buf.format()]]

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
vim.api.nvim_set_keymap('n', '<Leader>e', ':NvimTreeToggle<CR>', { noremap = true, silent = true })

-- Status Line (initial setup, will be overridden later)
local status_ok, lualine = pcall(require, 'lualine')
if status_ok then
  lualine.setup {
    options = { theme = 'tokyonight' },
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
      typescript = {'template_string'},
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

-- FIXED: Improved Jupyter Notebook Support with better error handling
local magma_exists, magma = pcall(require, 'magma-nvim')
if magma_exists then
  pcall(function() magma.setup() end)
else
  vim.notify("magma-nvim not available - install or remove from config", vim.log.levels.INFO)
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
      },
      typescript = {
        command = {"ts-node"}
      },
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

-- Update the theme configuration
local function configure_theme()
  -- Check if required plugins are available
  local tokyonight_ok, tokyonight = pcall(require, "tokyonight")
  local transparent_ok, transparent = pcall(require, "transparent")
  local colorizer_ok, colorizer = pcall(require, "colorizer")
  
  if not tokyonight_ok then
    vim.notify("TokyoNight theme not found - installing theme may be required", vim.log.levels.WARN)
    vim.cmd("colorscheme default") -- Fallback
    return
  end
  
  -- Configure TokyoNight with amber customizations
  -- Let's use the correct API for the version you have
  vim.g.tokyonight_style = "night"
  vim.g.tokyonight_transparent = true
  vim.g.tokyonight_terminal_colors = true
  vim.g.tokyonight_italic_comments = true
  vim.g.tokyonight_italic_keywords = true
  vim.g.tokyonight_italic_functions = false
  vim.g.tokyonight_italic_variables = false
  vim.g.tokyonight_dark_sidebar = true
  vim.g.tokyonight_dark_float = true
  
  -- Custom color overrides using vim global variables
  vim.g.tokyonight_colors = {
    bg = "#0f0f0f",
    bg_dark = "#121212",
    bg_float = "#121212",
    bg_highlight = "#1a1a1a",
    fg = "#e0e0e0",
    orange = "#ff9e00",
    yellow = "#ffb74d",
    comment = "#756d66",
    blue = "#ff7a00",     -- Use orange instead of blue
    cyan = "#ffb74d",     -- Use light amber instead of cyan
    purple = "#ff9e00",   -- Use amber instead of purple
    green = "#50fa7b",    -- Keep green but adjust
    red = "#ff4500",      -- Adjust red to be red-orange
    border = "#ff9e00"
  }
  
  -- Try to apply the theme with error handling
  local theme_ok, theme_err = pcall(vim.cmd, "colorscheme tokyonight")
  if not theme_ok then
    vim.notify("Failed to apply TokyoNight theme: " .. tostring(theme_err), vim.log.levels.WARN)
    vim.cmd("colorscheme default") -- Fallback
    return
  end
  
  -- Configure transparency plugin if available
  if transparent_ok then
    transparent.setup({
      enable = true,
      extra_groups = {
        "NormalFloat",
        "NvimTreeNormal",
        "TelescopeNormal",
      },
    })
  end
  
  -- Configure colorizer for showing colors in code if available
  if colorizer_ok then
    colorizer.setup({
      '*', -- Enable for all filetypes
      css = { css = true },
    })
  end
  
  -- Apply key highlight customizations directly
  vim.api.nvim_set_hl(0, "Function", { fg = "#ff9e00", bold = true })
  vim.api.nvim_set_hl(0, "Cursor", { bg = "#ff9e00", fg = "#000000" })
  vim.api.nvim_set_hl(0, "CursorLine", { bg = "#1a1a1a" })
  vim.api.nvim_set_hl(0, "LineNr", { fg = "#3d3522" })
  vim.api.nvim_set_hl(0, "CursorLineNr", { fg = "#ff9e00" })
  
  -- NvimTree highlights
  vim.api.nvim_set_hl(0, "NvimTreeFolderName", { fg = "#ff9e00" })
  vim.api.nvim_set_hl(0, "NvimTreeFolderIcon", { fg = "#ff9e00" })
  vim.api.nvim_set_hl(0, "NvimTreeOpenedFolderName", { fg = "#ffb74d", bold = true })
  vim.api.nvim_set_hl(0, "NvimTreeIndentMarker", { fg = "#3d3522" })
  vim.api.nvim_set_hl(0, "NvimTreeGitDirty", { fg = "#ff7a00" })
  vim.api.nvim_set_hl(0, "NvimTreeGitNew", { fg = "#50fa7b" })
  vim.api.nvim_set_hl(0, "NvimTreeGitDeleted", { fg = "#ff4500" })
  
  -- Terminal highlights
  vim.api.nvim_set_hl(0, "ToggleTerm", { bg = "#0f0f0f" })
  vim.api.nvim_set_hl(0, "ToggleTermBorder", { fg = "#ff9e00", bg = "#0f0f0f" })
end
