require("mormesher/globals")

local ensure_packer = function()
  local fn = vim.fn
  local install_path = fn.stdpath("data").."/site/pack/packer/start/packer.nvim"
  if fn.empty(fn.glob(install_path)) > 0 then
    fn.system({"git", "clone", "--depth", "1", "https://github.com/wbthomason/packer.nvim", install_path})
    cmd("packadd packer.nvim")
    return true
  end
  return false
end

local packer_bootstrap = ensure_packer()

require("packer").startup(function(use)
  use("wbthomason/packer.nvim")

  --
  -- UI
  --

  -- colourscheme
  use("dracula/vim")

  -- notifications
  use("rcarriga/nvim-notify")

  -- status line
  use({
    "nvim-lualine/lualine.nvim",
    requires = {
      { "nvim-tree/nvim-web-devicons" }
    },
    config = function()
      require("lualine").setup({
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
          lualine_c = { "filename" },
          lualine_x = { "filetype" },
          lualine_y = { "searchcount" },
          lualine_z = { "progress", "location" }
        }
      })
    end
  })

  -- show marks in the gutter
  use("kshenoy/vim-signature")

  --
  -- language integration
  --

  -- tree-sitter abstraction layer
  use({
    "nvim-treesitter/nvim-treesitter",
    run = function()
      local ts_update = require("nvim-treesitter.install").update({ with_sync = true })
      ts_update()
    end,
    config = function()
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
          "jsonnet",
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
    end
  })

  use("williamboman/mason.nvim")
  use("williamboman/mason-lspconfig.nvim")
  use("neovim/nvim-lspconfig")
  use("jose-elias-alvarez/null-ls.nvim")
  use("glepnir/lspsaga.nvim")

  -- autocompletion
  use({
    "hrsh7th/nvim-cmp",
    requires = {
      -- snippet engine
      {
        "L3MON4D3/LuaSnip",
        requires = {
          { "saadparwaiz1/cmp_luasnip" }
        }
      },

      -- completion sources
      { "hrsh7th/cmp-buffer" },
      { "hrsh7th/cmp-path" },
      { "hrsh7th/cmp-nvim-lsp" },
    }
  });

  --
  -- general typing tools
  --

  -- gcc to (un)comment a line, gc to (un)comment a visual selection
  use("tpope/vim-commentary")

  -- detect indentation style and adjust settings
  use("tpope/vim-sleuth")

  -- highlight trailing spaces and provides :StripWhitespace helper
  use({
    "ntpeters/vim-better-whitespace",
    config = function()
      vim.api.nvim_create_autocmd("BufWritePre", {
        command = ":StripWhitespace"
      })
    end
  })

  -- highlight good options for navigation within a line
  -- note: formatting overrides are applied in ./options.lua where the colourscheme is set
  use("unblevable/quick-scope")

  --
  -- tools
  --

  -- file browser
  use({
    "nvim-tree/nvim-tree.lua",
    requires = {
      { "nvim-tree/nvim-web-devicons" }
    },
    config = function()
      require("nvim-tree").setup({
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
      keymap.set("n", "<leader>m", function() tree_api.tree.toggle({ update_root = true }) end)
      keymap.set("n", "<leader>n", function() tree_api.tree.toggle({ update_root = true, find_file = true }) end)
    end,
  })

  -- fuzzy search
  use({
    "ibhagwan/fzf-lua",
    requires = {
      { "nvim-tree/nvim-web-devicons" },
      {
        "junegunn/fzf",
        run = "./install --bin"
      }
    },
    config = function()
      keymap.set("n", "<leader>,", "<cmd>:FzfLua files<cr>")
      keymap.set("n", "<leader>.", "<cmd>:FzfLua live_grep<cr>")
    end
  })

  --
  -- package management (keep at the bottom)
  --

  -- automatically set up configuration after cloning packer.nvim
  if packer_bootstrap then
    require("packer").sync()
  end
end)
