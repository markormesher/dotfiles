--
-- install plugins
--

vim.pack.add({
  -- colourscheme
  "https://github.com/dracula/vim",

  -- notifications
  "https://github.com/rcarriga/nvim-notify",

  -- show marks in the gutter
  "https://github.com/kshenoy/vim-signature",

  -- status line
  "https://github.com/nvim-lualine/lualine.nvim",
  "https://github.com/nvim-tree/nvim-web-devicons",

  -- code outline
  "https://github.com/stevearc/aerial.nvim",

  -- highlight trailing spaces and provide :StripWhitespace helper
  "https://github.com/ntpeters/vim-better-whitespace",

  -- file browser
  "https://github.com/nvim-tree/nvim-tree.lua",
  "https://github.com/nvim-tree/nvim-web-devicons",

  -- fuzzy search
  "https://github.com/junegunn/fzf",
  "https://github.com/ibhagwan/fzf-lua",
  "https://github.com/nvim-tree/nvim-web-devicons",

  -- tree-sitter abstraction layer
  -- TODO: replace/upgrade this
  { src = "https://github.com/nvim-treesitter/nvim-treesitter", version = "master" },

  -- autocompletion
  "https://github.com/hrsh7th/nvim-cmp",
  "https://github.com/hrsh7th/cmp-path",
  "https://github.com/hrsh7th/cmp-buffer",
  "https://github.com/hrsh7th/cmp-nvim-lsp",

  -- snippet engine
  "https://github.com/L3MON4D3/LuaSnip",
  "https://github.com/saadparwaiz1/cmp_luasnip",

  -- LSP tools
  "https://github.com/williamboman/mason.nvim",
  "https://github.com/WhoIsSethDaniel/mason-tool-installer.nvim",
  "https://github.com/nvimdev/lspsaga.nvim",
  "https://github.com/neovim/nvim-lspconfig",

  -- highlight jump targets
  "https://github.com/unblevable/quick-scope",

  -- detect indentation style and adjust settings
  "https://github.com/tpope/vim-sleuth",

  -- gcc to (un)comment a line, gc to (un)comment a visual selection
  "https://github.com/tpope/vim-commentary",
})

with_plugin = function(name, func)
  plugin_ok, plugin = pcall(require, name)
  if (not plugin_ok) then
    vim.notify("Plugin '" .. name .. "' is not available", "error")
  end
  pcall(func, plugin)
end

--
-- general config
--

vim.g.mapleader = ","

-- better colour support
vim.opt.termguicolors = true

-- no mouse
vim.opt.mouse = ""

-- allow backspacing over everything
vim.opt.backspace = "indent,eol,start"

-- keep undo history even after exiting
vim.opt.undofile = true

-- dont re-draw during macros
vim.opt.lazyredraw = true

-- highlight changes/replacements using `s` as they're typed
vim.opt.inccommand = "nosplit"

-- make searches without caps case-insensitive
vim.opt.smartcase = true
vim.opt.ignorecase = true

-- some servers have issues with backup files
vim.opt.backup = false
vim.opt.writebackup = false

-- default tab size of 2 spaces (may be overwritten by vim-sleuth)
vim.opt.expandtab = true
vim.opt.tabstop = 2
vim.opt.softtabstop = 2
vim.opt.shiftwidth = 2

-- hide buffers when abandoned
vim.opt.hidden = true

-- show current line number and relative numbers on other lines
vim.opt.number = true
vim.opt.relativenumber = true

-- always show the sign column to avoid janky changes when signs appear/disappear
vim.opt.signcolumn = "yes"

-- keep the cursor X lines away from the top and bottom of the window (except for the start and end of files)
vim.opt.scrolloff = 10

-- hide bottom command bar
vim.opt.cmdheight = 0

-- don't pass messages to |ins-completion-menu|
vim.opt.shortmess:append "c"

-- colours
vim.cmd("colorscheme dracula")

vim.api.nvim_set_hl(0, "QuickScopePrimary", { underline = true })
vim.api.nvim_set_hl(0, "QuickScopeSecondary", { underline = true, italic = true })

-- diagnostic appearance
vim.diagnostic.config({
  severity_sort = true,
  virtual_text = {
    enable = true,
  },
  update_in_insert = false,
  signs = {
    text = {
      [vim.diagnostic.severity.ERROR] = "✘",
      [vim.diagnostic.severity.WARN] = "▲",
      [vim.diagnostic.severity.INFO] = "⚑",
      [vim.diagnostic.severity.HINT] = "»",
    },
    numhl = {
      [vim.diagnostic.severity.ERROR] = "",
      [vim.diagnostic.severity.WARN] = "",
      [vim.diagnostic.severity.HINT] = "",
      [vim.diagnostic.severity.INFO] = "",
    },
  },
})

--
-- non-plugin shortcuts
--

local silent_opts = { silent = true, noremap = true }

-- <leader>-c clears highlights
vim.keymap.set("n", "<leader>c", "<cmd>:nohl<cr>", silent_opts)

-- <leader>-q to quit, <leader>-w to save, <leader>-x to save and quit
vim.keymap.set("n", "<leader>q", "<cmd>:qa<cr>", silent_opts)
vim.keymap.set("n", "<leader>w", "<cmd>:wa<cr>", silent_opts)
vim.keymap.set("n", "<leader>x", "<cmd>:xa<cr>", silent_opts)

-- type u# to insert a uuid
vim.cmd("inoreabbrev <expr> u# system('uuid 2>/dev/null \\|\\| uuidgen 2>/dev/null \\|\\| echo No UUID generator installed')->trim()")

--
-- ui/tools plugin configuration
--

with_plugin("notify", function(p)
  p.setup({
    stages = "slide"
  })
  vim.notify = p
end)

with_plugin("lualine", function(p)
  p.setup({
    inactive_sections = {
      lualine_a = {},
      lualine_b = {},
      lualine_c = { "filename" },
      lualine_x = {},
      lualine_y = {},
      lualine_z = {}
    },
    sections = {
      lualine_a = { "mode" },
      lualine_b = { "branch", "diagnostics" },
      lualine_c = { "aerial" },
      lualine_x = { "filetype" },
      lualine_y = { "searchcount" },
      lualine_z = { "progress", "location" }
    }
  })
end)

with_plugin("aerial", function(p)
  p.setup({
    layout = {
      default_direction = "float",
      max_width = { 0.8 },
      min_width = { 0.3 },
    },
    float = {
      relative = "editor",
    },
    close_on_select = true,
    highlight_on_jump = 600, -- ms
    highlight_on_hover = true,
    autojump = true,
  })

  vim.keymap.set("n", "<leader>a", "<cmd>:AerialToggle<cr>")
end)

with_plugin("nvim-tree", function(p)
  p.setup({
    git = {
      enable = false,
    },
    actions = {
      open_file = {
        quit_on_open = true
      }
    }
  })

  local tree_api = require("nvim-tree.api");
  vim.keymap.set("n", "<leader>m", function() tree_api.tree.toggle({ update_root = true }) end)
  vim.keymap.set("n", "<leader>n", function() tree_api.tree.toggle({ update_root = true, find_file = true }) end)
end)

with_plugin("fzf-lua", function(p)
  p.setup({
    "hide",
  })

  vim.keymap.set("n", "<leader>,", "<cmd>:FzfLua files<cr>")
  vim.keymap.set("n", "<leader>.", "<cmd>:FzfLua live_grep resume=true<cr>")
end)

--
-- language integration
--

-- per-language overrides
vim.api.nvim_create_autocmd("FileType", {
  pattern = "openscad",
  callback = function()
    vim.opt_local.commentstring = "// %s"
  end,
})

-- TODO: upgrade or replace this
with_plugin("nvim-treesitter", function(p)
  require("nvim-treesitter.configs").setup({
    auto_install = true,
    ensure_installed = {
      "css",
      "go",
      "gomod",
      "hcl",
      "html",
      "javascript",
      "json",
      "lua",
      "markdown",
      "markdown_inline",
      "scss",
      "typescript",
      "vim",
      "vimdoc",
      "yaml",
    },
    highlight = {
      enabled = true
    },
    indent = {
      enabled = true
    }
  })
end)

-- install lsp servers with mason
with_plugin("mason", function(mason)
  with_plugin("mason-tool-installer", function(mason_tools)
    mason.setup()
    mason_tools.setup({
      ensure_installed = {
        -- JS/TS
        "eslint-lsp",
        "typescript-language-server",

        -- CSS
        "css-lsp",

        -- Go
        "gopls",

        -- General
        "typos-lsp",
      },
      auto_update = true,
      run_on_start = true,
    })
  end)
end)

-- LSP setup (most config comes from neovim/lspconfig, these are just specific overrides)
vim.api.nvim_create_augroup("lsp_custom", { clear = true })

vim.lsp.config("gopls", {
  settings = {
    gopls = {
      staticcheck = true,
    },
  },
})

vim.lsp.config("ts_ls", {
  init_options = {
    preferences = {
      importModuleSpecifierPreference = "relative",
      jsxAttributeCompletionStyle = "braces",
    },
  },
})

vim.lsp.config("eslint", {
  settings = {
    format = { enable = true },
    workingDirectory = { mode = "auto" },
    codeActionOnSave = { enable = true, mode = "problems" },
  },
})

vim.lsp.enable({
  "gopls",
  "ts_ls",
  "eslint",
  "cssls",
  "openscad_lsp",
  "typo_lsp",
})

-- LSP-backed actions
with_plugin("lspsaga", function(p)
  p.setup({
    symbol_in_winbar = {
      enable = false
    },
    lightbulb = {
      enable = false
    },
    rename = {
      quit = "<esc>",
      in_select = false,
    },
  })

  -- floating terminal
  vim.keymap.set("n", "<c-space>", "<cmd>Lspsaga term_toggle<cr>")
  vim.keymap.set("t", "<c-space>", "<cmd>Lspsaga term_toggle<cr>")
  vim.keymap.set("n", "<c-s>", "<cmd>Lspsaga term_toggle<cr>")
  vim.keymap.set("t", "<c-s>", "<cmd>Lspsaga term_toggle<cr>")

  -- show documentation snippet
  vim.keymap.set("n", "K", "<cmd>Lspsaga hover_doc<cr>")

  -- find definition and uses
  vim.keymap.set("n", "<leader>f", "<cmd>Lspsaga finder<cr>")

  -- rename synbol
  vim.keymap.set("n", "<leader>rn", "<cmd>Lspsaga rename<cr>")

  -- code actions
  vim.keymap.set("n", "<leader> ", "<cmd>Lspsaga code_action<cr>")

  -- jump to next/prev issue
  vim.keymap.set("n", "[e", "<cmd>Lspsaga diagnostic_jump_prev<cr>")
  vim.keymap.set("n", "]e", "<cmd>Lspsaga diagnostic_jump_next<cr>")
end)

vim.api.nvim_create_autocmd("LspAttach", {
  group = "lsp_custom",
  callback = function(args)
    local client = assert(vim.lsp.get_client_by_id(args.data.client_id))

    -- format on save
    if client:supports_method("textDocument/formatting") then
      vim.api.nvim_create_autocmd("BufWritePre", {
        group = "lsp_custom",
        buffer = args.buf,
        callback = function()
          vim.lsp.buf.format({
            async = false,
            bufnr = args.buf,
            timeout_ms = 1000,
          })
        end
      })
    end
  end,
})

-- trim trailing whitespace on save
vim.api.nvim_create_autocmd("BufWritePre", {
  callback = function()
    if vim.fn.exists(":StripWhitespace") > 0 then
      vim.cmd("StripWhitespace")
    end
  end
})

-- auto completion
with_plugin("cmp", function(cmp)
  with_plugin("luasnip", function(luasnip)
    cmp.setup({
      snippet = {
        expand = function(args)
          luasnip.lsp_expand(args.body)
        end
      },
      mapping = {
        ["<C-e>"] = cmp.mapping.abort(),
        ["<cr>"] = cmp.mapping(function(fallback)
          if cmp.visible() then
            cmp.confirm({ select = true })
          else
            fallback()
          end
        end, { "i", "c" }),
        ["<Down>"] = cmp.mapping(cmp.mapping.select_next_item({ behavior = cmp.SelectBehavior.Select }), { "i", "c" }),
        ["<up>"] = cmp.mapping(cmp.mapping.select_prev_item({ behavior = cmp.SelectBehavior.Select }), { "i", "c" }),
      },
      sources = {
        { name = "nvim_lsp" },
        { name = "path" },
        { name = "luasnip" },
        {
          name = "buffer",
          keyword_length = 4, -- trigger completion on Nth character
          max_item_count = 5,
          option = {
            keyword_length = 5, -- minimum length for candidates
            get_bufnrs = function()
              return vim.api.nvim_list_bufs()
            end,
          }
        },
      },
      formatting = {
        format = function(entry, vim_item)
          -- show the completion source for debugging
          -- vim_item.menu = entry.source.name

          return vim_item
        end,
      },
    })

    vim.cmd("set completeopt=menuone,noinsert,noselect")
  end)
end)
