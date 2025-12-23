require("mormesher/globals")

--
-- Install LSP packages
--

local mason_ok, mason = check_plugin("mason")
local mason_tools_ok, mason_tools = check_plugin("mason-tool-installer")
if (mason_ok and mason_tools_ok) then
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
    },
    auto_update = true,
    run_on_start = true,
  })
end

--
-- Actual LSP setup
-- Note: most config comes from neovim/lspconfig, these are just specific overrides
--

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
})

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

--
-- Auto completion
--

local cmp_ok, cmp = check_plugin("cmp")
local luasnip_ok, luasnip = check_plugin("luasnip")
if (cmp_ok and luasnip_ok) then
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
        keyword_length = 5, -- trigger completion on Nth character
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

  cmd("set completeopt=menuone,noinsert,noselect")
end

--
-- LSP actions via lspsaga
--

local lsp_saga_ok, lsp_saga = check_plugin("lspsaga")
if (lsp_saga_ok) then
  lsp_saga.setup({
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
  keymap.set("n", "<c-space>", "<cmd>Lspsaga term_toggle<cr>")
  keymap.set("t", "<c-space>", "<cmd>Lspsaga term_toggle<cr>")
  keymap.set("n", "<c-s>", "<cmd>Lspsaga term_toggle<cr>")
  keymap.set("t", "<c-s>", "<cmd>Lspsaga term_toggle<cr>")

  -- show documentation snippet
  keymap.set("n", "K", "<cmd>Lspsaga hover_doc<cr>")

  -- find definition and uses
  keymap.set("n", "<leader>f", "<cmd>Lspsaga finder<cr>")

  -- rename synbol
  keymap.set("n", "<leader>rn", "<cmd>Lspsaga rename<cr>")

  -- code actions
  keymap.set("n", "<leader> ", "<cmd>Lspsaga code_action<cr>")

  -- jump to next/prev issue
  keymap.set("n", "[e", "<cmd>Lspsaga diagnostic_jump_prev<cr>")
  keymap.set("n", "]e", "<cmd>Lspsaga diagnostic_jump_next<cr>")
end

--
-- Diagnostic settings
--

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
