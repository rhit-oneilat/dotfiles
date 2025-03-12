-- Install packer if not installed
local install_path = vim.fn.stdpath('data') .. '/site/pack/packer/start/packer.nvim'
if vim.fn.empty(vim.fn.glob(install_path)) > 0 then
  vim.fn.system({'git', 'clone', '--depth', '1', 'https://github.com/wbthomason/packer.nvim', install_path})
  vim.cmd('packadd packer.nvim')
end

-- disable netrw at the very start of your init.lua
vim.g.loaded_netrw = 1
vim.g.loaded_netrwPlugin = 1

-- optionally enable 24-bit colour
vim.opt.termguicolors = true
-- Set leader key
vim.g.mapleader = " "

-- Plugins
require('packer').startup(function(use)
  -- Package manager
  use 'wbthomason/packer.nvim'

  -- Markdown files
  use 'henriklovhaug/Preview.nvim'

  -- Tree
  use {'nvim-tree/nvim-tree.lua', requires = { 'nvim-tree/nvim-web-devicons'}
    
  -- LSP and completion
  use 'neovim/nvim-lspconfig'
  use 'hrsh7th/nvim-cmp'
  use 'hrsh7th/cmp-nvim-lsp'
  use 'hrsh7th/cmp-buffer'
  use 'L3MON4D3/LuaSnip'
  use 'saadparwaiz1/cmp_luasnip'
  use {'tzachar/cmp-tabnine', run='./install.sh', requires = 'hrsh7th/nvim-cmp'}
  
  -- Treesitter for better syntax highlighting
  use {'nvim-treesitter/nvim-treesitter', run = ':TSUpdate'}

  -- LaTeX
  use { "lervag/vimtex" }

  -- Theme
  use { "ellisonleao/gruvbox.nvim" }
  
  -- Navigation and search
  use {'nvim-telescope/telescope.nvim', requires = {{'nvim-lua/plenary.nvim'}}}
  use 'nvim-telescope/telescope-project.nvim'
  use 'karb94/neoscroll.nvim'
  use 'sharkdp/fd'
  
  -- UI enhancements
  use 'nvim-lualine/lualine.nvim'
  use 'kyazdani42/nvim-tree.lua'
  use 'kyazdani42/nvim-web-devicons'
  use 'akinsho/bufferline.nvim'
  
  -- Git integration
  use 'tpope/vim-fugitive'
  use 'lewis6991/gitsigns.nvim'
  
  -- Quality of life
  use 'rmagatti/auto-session'
  use 'windwp/nvim-autopairs'
  use 'akinsho/toggleterm.nvim'
  use {'CRAG666/code_runner.nvim', requires = 'nvim-lua/plenary.nvim'}
  
  -- Language specific
  use 'simrat39/rust-tools.nvim'
  use 'mfussenegger/nvim-dap'
  use 'jbyuki/one-small-step-for-vimkind'
  use 'lervag/vimtex'
  use 'julialang/julia-vim'
  use 'Olical/conjure'
  use 'jupyter-vim/jupyter-vim'
  use 'maxmellon/vim-graphql'
  use 'aklt/plantuml-syntax'
  
  -- AI assistance
  use 'github/copilot.vim'
  
  -- REPL tools
  use 'dccsillag/magma-nvim'
  use 'hkupty/iron.nvim'
  
  -- Theme
  use 'folke/tokyonight.nvim'
end)

require('preview').setup()

require("nvim-tree").setup()

-- Editor Settings
vim.opt.number = true
vim.opt.relativenumber = true
vim.opt.tabstop = 4
vim.opt.shiftwidth = 4
vim.opt.expandtab = true
vim.opt.smartindent = true
vim.opt.termguicolors = true
vim.opt.cursorline = true
vim.opt.scrolloff = 8
vim.opt.sidescrolloff = 8
vim.opt.signcolumn = "yes"
vim.opt.wrap = false
vim.opt.incsearch = true
vim.opt.ignorecase = true
vim.opt.smartcase = true
vim.opt.mouse = "a"
vim.opt.clipboard = "unnamedplus"
vim.opt.splitright = true
vim.opt.splitbelow = true
vim.opt.updatetime = 250
vim.opt.timeoutlen = 300
vim.opt.undofile = true
vim.opt.backup = false
vim.opt.swapfile = false

-- Theme setup - simplified to just use TokyoNight
vim.cmd([[colorscheme tokyonight]])

-- Error handling utility
local function setup_safe(name, setup_func)
  local status_ok, module = pcall(require, name)
  if status_ok then
    pcall(setup_func, module)
  else
    vim.notify("Failed to load " .. name, vim.log.levels.WARN)
  end
end

-- LSP Config
local function setup_lsp(server, config)
  config = config or {}
  
  local status_ok, lsp = pcall(require, 'lspconfig')
  if not status_ok then
    vim.notify("Failed to load lspconfig", vim.log.levels.ERROR)
    return
  end
  
  lsp[server].setup(config)
end

-- Setup common LSP servers
setup_lsp('pyright')
setup_lsp('rust_analyzer')
setup_lsp('ts_ls', {
  filetypes = { "javascript", "javascriptreact", "javascript.jsx", "typescript", "typescriptreact", "typescript.tsx" },
  init_options = {
    hostInfo = "neovim"
  },
})

-- Rust Tools
setup_safe('rust-tools', function(rt)
  rt.setup({
    server = {
      settings = {
        ['rust-analyzer'] = {
          checkOnSave = {
            command = "clippy"
          }
        }
      }
    }
  })
end)

-- Autocompletion
setup_safe('cmp', function(cmp)
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
    }),
    window = {
      completion = cmp.config.window.bordered(),
      documentation = cmp.config.window.bordered(),
    },
    formatting = {
      format = function(entry, vim_item)
        vim_item.menu = ({
          nvim_lsp = "[LSP]",
          luasnip = "[Snippet]",
          buffer = "[Buffer]",
          cmp_tabnine = "[TN]",
        })[entry.source.name]
        return vim_item
      end
    }
  }
end)

-- Treesitter
setup_safe('nvim-treesitter.configs', function(treesitter)
  treesitter.setup {
    ensure_installed = { 'python', 'rust', 'javascript', 'typescript', 'lua', 'bash', 'julia', 'markdown', 'json', 'yaml', 'vim' },
    sync_install = false,
    auto_install = true,
    highlight = { 
      enable = true,
      additional_vim_regex_highlighting = false,
      disable = {'latex'},
    },
    indent = { enable = true }, 
    incremental_selection = { enable = true },
    context_commentstring = { enable = true, enable_autocmd = false },
  }
end)

-- Telescope Setup
setup_safe('telescope', function(telescope)
  telescope.setup {
    defaults = {
      prompt_prefix = " ",
      selection_caret = " ",
      path_display = { "smart" },
      file_ignore_patterns = { "node_modules", ".git/", "dist/", "build/" },
      layout_strategy = "horizontal",
      layout_config = {
        horizontal = {
          preview_width = 0.55,
        },
      },
    },
    extensions = {
      project = {
        hidden_files = true,
        theme = "dropdown",
      }
    }
  }
  
  telescope.load_extension('project')
end)

-- Nvim-tree Setup
setup_safe('nvim-tree', function(nvim_tree)
  nvim_tree.setup {
    sort_by = "case_sensitive",
    view = {
      width = 30,
    },
    filters = {
      dotfiles = false,
    },
    git = {
      enable = true,
      ignore = false,
    },
    renderer = {
      group_empty = true,
      icons = {
        show = {
          git = true,
          folder = true,
          file = true,
          folder_arrow = true,
        },
      },
    },
  }
end)

-- Bufferline Setup
setup_safe('bufferline', function(bufferline)
  bufferline.setup {
    options = {
      close_command = "bdelete! %d",
      right_mouse_command = "bdelete! %d",
      diagnostics = "nvim_lsp",
      diagnostics_indicator = function(_, _, diagnostics_dict, _)
        local s = " "
        for e, n in pairs(diagnostics_dict) do
          local sym = e == "error" and " " or (e == "warning" and " " or "")
          s = s .. sym .. n
        end
        return s
      end,
      offsets = {
        {
          filetype = "NvimTree",
          text = "File Explorer",
          highlight = "Directory",
          text_align = "left"
        }
      },
      show_buffer_icons = true,
      show_buffer_close_icons = true,
      show_close_icon = true,
      separator_style = "thin",
    }
  }
end)

-- LaTeX Setup
vim.g.vimtex_view_method = 'zathura' -- Change to 'skim' if on macOS
vim.g.vimtex_compiler_method = 'latexmk'
vim.g.tex_flavor = 'latex'
vim.g.vimtex_quickfix_mode = 0


-- Code Runner Setup
setup_safe('code_runner', function(code_runner)
  code_runner.setup {
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
      typescript = "ts-node",
      julia = "julia",
      lua = "lua",
      sh = "bash",
    },
  }
end)

-- Autoformat on save (with safety)
vim.cmd[[
  augroup FormatOnSave
    autocmd!
    autocmd BufWritePre * lua vim.lsp.buf.format({timeout_ms = 1000})
  augroup END
]]

-- Better window navigation
vim.keymap.set('n', '<C-h>', '<C-w>h', { noremap = true })
vim.keymap.set('n', '<C-j>', '<C-w>j', { noremap = true })
vim.keymap.set('n', '<C-k>', '<C-w>k', { noremap = true })
vim.keymap.set('n', '<C-l>', '<C-w>l', { noremap = true })

-- Resize with arrows
vim.keymap.set('n', '<C-Up>', ':resize -2<CR>', { noremap = true, silent = true })
vim.keymap.set('n', '<C-Down>', ':resize +2<CR>', { noremap = true, silent = true })
vim.keymap.set('n', '<C-Left>', ':vertical resize -2<CR>', { noremap = true, silent = true })
vim.keymap.set('n', '<C-Right>', ':vertical resize +2<CR>', { noremap = true, silent = true })

-- Stay in indent mode when indenting
vim.keymap.set('v', '<', '<gv', { noremap = true })
vim.keymap.set('v', '>', '>gv', { noremap = true })

-- Move text up and down
vim.keymap.set('v', '<A-j>', ":m .+1<CR>==", { noremap = true })
vim.keymap.set('v', '<A-k>', ":m .-2<CR>==", { noremap = true })
vim.keymap.set('x', '<A-j>', ":move '>+1<CR>gv-gv", { noremap = true })
vim.keymap.set('x', '<A-k>', ":move '<-2<CR>gv-gv", { noremap = true })

-- Common keybindings
vim.keymap.set('n', '<Leader>ff', ':Telescope find_files<CR>', { noremap = true })
vim.keymap.set('n', '<Leader>fg', ':Telescope live_grep<CR>', { noremap = true })
vim.keymap.set('n', '<Leader>fb', ':Telescope buffers<CR>', { noremap = true })
vim.keymap.set('n', '<Leader>fh', ':Telescope help_tags<CR>', { noremap = true })
vim.keymap.set('n', '<Leader>fp', ':Telescope project<CR>', { noremap = true })
vim.keymap.set('n', '<Leader>r', ':RunCode<CR>', { noremap = true, silent = true })
vim.keymap.set('n', '<Leader>e', ':NvimTreeToggle<CR>', { noremap = true, silent = true })
vim.keymap.set('n', '<Leader>q', ':bdelete<CR>', { noremap = true, silent = true })
vim.keymap.set('n', '<Leader>h', ':nohlsearch<CR>', { noremap = true, silent = true })
vim.keymap.set('n', '<Leader>w', ':w<CR>', { noremap = true })
vim.keymap.set('n', '<Leader>c', ':RunClose<CR>', { noremap = true, silent = true })

-- LSP keybindings
vim.keymap.set('n', 'gD', vim.lsp.buf.declaration, { noremap = true, silent = true })
vim.keymap.set('n', 'gd', vim.lsp.buf.definition, { noremap = true, silent = true })
vim.keymap.set('n', 'K', vim.lsp.buf.hover, { noremap = true, silent = true })
vim.keymap.set('n', 'gi', vim.lsp.buf.implementation, { noremap = true, silent = true })
vim.keymap.set('n', '<Leader>k', vim.lsp.buf.signature_help, { noremap = true, silent = true })
vim.keymap.set('n', '<Leader>rn', vim.lsp.buf.rename, { noremap = true, silent = true })
vim.keymap.set('n', '<Leader>ca', vim.lsp.buf.code_action, { noremap = true, silent = true })
vim.keymap.set('n', 'gr', vim.lsp.buf.references, { noremap = true, silent = true })
vim.keymap.set('n', '<Leader>d', vim.diagnostic.open_float, { noremap = true, silent = true })
vim.keymap.set('n', '[d', vim.diagnostic.goto_prev, { noremap = true, silent = true })
vim.keymap.set('n', ']d', vim.diagnostic.goto_next, { noremap = true, silent = true })

-- Status Line
setup_safe('lualine', function(lualine)
  lualine.setup {
    options = { 
      theme = 'tokyonight',
      component_separators = { left = '', right = ''},
      section_separators = { left = '', right = ''},
      disabled_filetypes = { "NvimTree", "toggleterm" }
    },
    sections = {
      lualine_a = {'mode'},
      lualine_b = {'branch', 'diff', 'diagnostics'},
      lualine_c = {'filename'},
      lualine_x = {'encoding', 'fileformat', 'filetype'},
      lualine_y = {'progress'},
      lualine_z = {'location'}
    },
    inactive_sections = {
      lualine_a = {},
      lualine_b = {},
      lualine_c = {'filename'},
      lualine_x = {'location'},
      lualine_y = {},
      lualine_z = {}
    }
  }
end)

-- Floating Terminal
setup_safe('toggleterm', function(toggleterm)
  toggleterm.setup {
    open_mapping = [[<C-\>]],
    direction = 'float',
    shade_terminals = true,
    shell = vim.o.shell,
    float_opts = {
      border = "curved",
      width = function() 
        return math.floor(vim.o.columns * 0.85)
      end,
      height = function() 
        return math.floor(vim.o.lines * 0.8)
      end
    },
    highlights = {
      FloatBorder = { link = "FloatBorder" },
      NormalFloat = { link = "NormalFloat" }
    }
  }
end)

-- Git Blame in Status Line
setup_safe('gitsigns', function(gitsigns)
  gitsigns.setup {
    signs = {
      add = { text = '│' },
      change = { text = '│' },
      delete = { text = '_' },
      topdelete = { text = '‾' },
      changedelete = { text = '~' },
    },
    current_line_blame = true,
    current_line_blame_opts = {
      virt_text = true,
      virt_text_pos = 'eol',
      delay = 300,
    },
    on_attach = function(bufnr)
      local gs = package.loaded.gitsigns

      -- Navigation
      vim.keymap.set('n', ']c', function()
        if vim.wo.diff then return ']c' end
        vim.schedule(function() gs.next_hunk() end)
        return '<Ignore>'
      end, {expr=true, buffer=bufnr})

      vim.keymap.set('n', '[c', function()
        if vim.wo.diff then return '[c' end
        vim.schedule(function() gs.prev_hunk() end)
        return '<Ignore>'
      end, {expr=true, buffer=bufnr})

      -- Actions
      vim.keymap.set('n', '<Leader>hs', gs.stage_hunk, {buffer=bufnr})
      vim.keymap.set('n', '<Leader>hr', gs.reset_hunk, {buffer=bufnr})
      vim.keymap.set('n', '<Leader>hu', gs.undo_stage_hunk, {buffer=bufnr})
      vim.keymap.set('n', '<Leader>hp', gs.preview_hunk, {buffer=bufnr})
      vim.keymap.set('n', '<Leader>hb', function() gs.blame_line{full=true} end, {buffer=bufnr})
    end
  }
end)

-- Auto-close Brackets and Quotes
setup_safe('nvim-autopairs', function(autopairs)
  autopairs.setup {
    check_ts = true,
    ts_config = {
      lua = {'string'},
      javascript = {'template_string'},
      typescript = {'template_string'},
    },
    disable_filetype = { "TelescopePrompt" },
    fast_wrap = {
      map = "<M-e>",
      chars = { "{", "[", "(", '"', "'" },
      pattern = [=[%'%"%)%>%]%)%}%,=%]]=],
      end_key = "$",
      keys = "qwertyuiopzxcvbnmasdfghjkl",
      check_comma = true,
      highlight = "Search",
      highlight_grey = "Comment"
    },
  }
  
  -- Integration with cmp
  local cmp_autopairs = require('nvim-autopairs.completion.cmp')
  local cmp_status_ok, cmp = pcall(require, 'cmp')
  if cmp_status_ok then
    cmp.event:on('confirm_done', cmp_autopairs.on_confirm_done())
  end
end)

-- Smooth Scrolling
setup_safe('neoscroll', function(neoscroll)
  neoscroll.setup({
    mappings = {'<C-u>', '<C-d>', '<C-b>', '<C-f>', '<C-y>', '<C-e>', 'zt', 'zz', 'zb'},
    hide_cursor = true,
    stop_eof = true,
    respect_scrolloff = false,
    cursor_scrolls_alone = true,
    easing_function = "sine",
    pre_hook = nil,
    post_hook = nil,
  })
end)

-- Session Management
setup_safe('auto-session', function(auto_session)
  auto_session.setup {
    log_level = "error",
    auto_session_enable_last_session = true,
    auto_session_enabled = true,
    auto_save_enabled = true,
    auto_restore_enabled = true,
    auto_session_suppress_dirs = nil,
    bypass_session_save_file_types = { "NvimTree", "toggleterm" },
  }
end)

-- Jupyter Notebook Support
local magma_exists, _ = pcall(require, 'magma-nvim')
if magma_exists then
  vim.g.magma_automatically_open_output = false
  vim.g.magma_image_provider = "none"
  vim.keymap.set('n', '<Leader>me', ':MagmaEvaluateOperator<CR>', { noremap = true, silent = true })
  vim.keymap.set('n', '<Leader>ml', ':MagmaEvaluateLine<CR>', { noremap = true, silent = true })
  vim.keymap.set('n', '<Leader>mc', ':MagmaEvaluateCell<CR>', { noremap = true, silent = true })
  vim.keymap.set('n', '<Leader>mo', ':MagmaShowOutput<CR>', { noremap = true, silent = true })
  vim.keymap.set('n', '<Leader>md', ':MagmaDelete<CR>', { noremap = true, silent = true })
end

-- REPL Support
setup_safe('iron.core', function(iron)
  iron.setup({
    config = {
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
        javascript = {
          command = {"node"}
        },
        rust = {
          command = {"cargo", "run"}
        },
      },
      highlight = {
        italic = true
      },
      ignore_blank_lines = true,
    },
    keymaps = {
      send_motion = "<Leader>is",
      visual_send = "<Leader>is",
      send_line = "<Leader>il",
      send_file = "<Leader>if",
      send_mark = "<Leader>im",
      send_until_cursor = "<Leader>iu",
      clear = "<Leader>ic",
      cr = "<Leader>i<CR>",
      interrupt = "<Leader>ii",
      exit = "<Leader>iq",
      clear_console = "<Leader>ix",
    },
  })
end)

-- Set up diagnostics appearance
vim.diagnostic.config({
  virtual_text = true,
  signs = true,
  underline = true,
  update_in_insert = false,
  severity_sort = true,
  float = {
    border = "rounded",
    source = "always",
    header = "",
    prefix = "",
  },
})

-- Add diagnostic symbols
local signs = { Error = " ", Warn = " ", Hint = " ", Info = " " }
for type, icon in pairs(signs) do
  local hl = "DiagnosticSign" .. type
  vim.fn.sign_define(hl, { text = icon, texthl = hl, numhl = hl })
end

-- Configure language-specific settings
vim.cmd([[
  augroup language_specific
    autocmd!
    " Python
    autocmd FileType python setlocal tabstop=4 shiftwidth=4 expandtab
    
    " Web development
    autocmd FileType javascript,typescript,html,css,json setlocal tabstop=2 shiftwidth=2 expandtab
    
    " Rust
    autocmd FileType rust setlocal tabstop=4 shiftwidth=4 expandtab
    
    " Julia
    autocmd FileType julia setlocal tabstop=4 shiftwidth=4 expandtab
    
    " Lua
    autocmd FileType lua setlocal tabstop=2 shiftwidth=2 expandtab
  augroup END
]])

-- Theme setup
require("gruvbox").setup({
  terminal_colors = true, -- add neovim terminal colors
  undercurl = true,
  underline = true,
  bold = true,
  italic = {
    strings = true,
    emphasis = true,
    comments = true,
    operators = false,
    folds = true,
  },
  strikethrough = true,
  invert_selection = false,
  invert_signs = false,
  invert_tabline = false,
  invert_intend_guides = false,
  inverse = true, -- invert background for search, diffs, statuslines and errors
  contrast = "", -- can be "hard", "soft" or empty string
  palette_overrides = {},
  overrides = {},
  dim_inactive = false,
  transparent_mode = false,
})
vim.cmd("colorscheme gruvbox")

vim.o.background = "dark" -- or "light" for light mode
vim.cmd([[colorscheme gruvbox]])
  

-- Other useful commands
vim.cmd([[
  " Trim trailing whitespace on save
  autocmd BufWritePre * :%s/\s\+$//e
  
  " Highlight yanked text
  autocmd TextYankPost * silent! lua vim.highlight.on_yank {higroup="IncSearch", timeout=200}
]])
