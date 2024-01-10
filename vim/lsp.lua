-- Providers
require("mason").setup()
require("mason-lspconfig").setup({
  ensure_installed = {
    "cssls",
    "docker_compose_language_service",
    "dockerls",
    "emmet_ls",
    "gopls",
    "html",
    "htmx",
    "jqls",
    "lua_ls",
    "rust_analyzer",
    "sqlls",
    "tailwindcss",
    "tsserver",
    "vimls",
  },
})

local null_ls = require("null-ls")

null_ls.setup({
  sources = {
    null_ls.builtins.formatting.stylua,
    null_ls.builtins.formatting.prettierd,
    null_ls.builtins.diagnostics.eslint_d,
    null_ls.builtins.code_actions.eslint_d,
    null_ls.builtins.completion.spell,
    null_ls.builtins.formatting.gofumpt,
    null_ls.builtins.formatting.goimports,
    null_ls.builtins.formatting.goimports_reviser,
    null_ls.builtins.code_actions.gomodifytags,
    null_ls.builtins.completion.vsnip,
  },
})

-- """"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
-- " => Completion
-- """"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
-- Setup nvim-cmp.
local cmp = require("cmp")
local lspkind = require("lspkind") -- fancy icons in the completion menu
cmp.setup({
  formatting = {
    format = lspkind.cmp_format({
      mode = "symbol_text",
      maxwidth = 50,
      ellipsis_char = "...",
      menu = {
        cody = "[AI]",
        buffer = "[Buffer]",
        nvim_lsp = "[LSP]",
        vsnip = "[VSnip]",
        latex_symbols = "[Latex]",
        cmp_yanky = "[Yanky]",
      },
    }),
  },
  snippet = {
    expand = function(args)
      vim.fn["vsnip#anonymous"](args.body)
    end,
  },
  window = {
    border = "rounded",
    completion = cmp.config.window.bordered(),
    documentation = cmp.config.window.bordered(),
  },
  completion = {
    border = "rounded",
  },
  mapping = cmp.mapping.preset.insert({
    ["<C-b>"] = cmp.mapping.scroll_docs(-4),
    ["<C-f>"] = cmp.mapping.scroll_docs(4),
    ["<C-Space>"] = cmp.mapping.complete(),
    ["<C-e>"] = cmp.mapping.abort(),
    ["<CR>"] = cmp.mapping.confirm({ select = true }), -- Accept currently selected item. Set `select` to `false` to only confirm explicitly selected items.
  }),
  sources = cmp.config.sources({
    { name = "nvim_lsp" },
    { name = "cody" },    -- sg.nvim
    { name = "vsnip" },
    { name = "cmp_yanky" }, -- yanky.nvim
    {
      { name = "buffer" },
    },
  }),
})

-- Use buffer source for `/` (if you enabled `native_menu`, this won't work anymore).
cmp.setup.cmdline({ "/", "?" }, {
  mapping = cmp.mapping.preset.cmdline(),
  sources = {
    { name = "buffer" },
  },
})

-- Use cmdline & path source for ':' (if you enabled `native_menu`, this won't work anymore).
cmp.setup.cmdline({ ":" }, {
  mapping = cmp.mapping.preset.cmdline(),
  sources = cmp.config.sources({
    { name = "path" },
  }, {
    { name = "cmdline" },
  }),
})

-- IMPORTANT: make sure to setup neodev BEFORE lspconfig
require("neodev").setup({
  -- add any options here, or leave empty to use the default settings
})

-- Lspsaga improves neovim lsp with a bunch of features
local lspsaga = require("lspsaga")
lspsaga.setup({
  lightbulb = {
    sign = false,
  },
  diagnostic = {
    extend_relatedInformation = true,
    keys = {
      quit = { "q", "<ESC>" },
    },
  },
})
-- Setup lspconfig.
local capabilities = require("cmp_nvim_lsp").default_capabilities()
local nvim_lsp = require("lspconfig")
capabilities.textDocument.completion.completionItem.snippetSupport = true

-- Global mappings.
-- See `:help vim.diagnostic.*` for documentation on any of the below functions
vim.keymap.set("n", "<space>e", vim.diagnostic.open_float)
vim.keymap.set("n", "[d", vim.diagnostic.goto_prev)
vim.keymap.set("n", "]d", vim.diagnostic.goto_next)
vim.keymap.set("n", "<space>q", vim.diagnostic.setloclist)

-- Use LspAttach autocommand to only map the following keys
-- after the language server attaches to the current buffer
vim.api.nvim_create_autocmd("LspAttach", {
  group = vim.api.nvim_create_augroup("UserLspConfig", {}),
  callback = function(ev)
    local bufnr = ev.buf
    if not (ev.data and ev.data.client_id) then
      return
    end

    local client = vim.lsp.get_client_by_id(ev.data.client_id)
    if not client then
      return
    end

    if client.server_capabilities.completionProvider then
      vim.bo[bufnr].omnifunc = "v:lua.vim.lsp.omnifunc"
    end
    if client.server_capabilities.definitionProvider then
      vim.bo[bufnr].tagfunc = "v:lua.vim.lsp.tagfunc"
    end

    local opts = { buffer = ev.buf }
    vim.keymap.set("n", "gD", vim.lsp.buf.declaration, opts)
    vim.keymap.set("n", "gd", vim.lsp.buf.definition, opts)
    vim.keymap.set("n", "K", vim.lsp.buf.hover, opts)
    vim.keymap.set({ "n", "v" }, "ga", ":Lspsaga code_action<CR>", opts)
    vim.keymap.set("n", "gr", vim.lsp.buf.references, opts)
    vim.keymap.set("n", "gi", vim.lsp.buf.implementation, opts)
    vim.keymap.set("n", "<C-k>", vim.lsp.buf.signature_help, opts)
    vim.keymap.set("n", "<leader>D", vim.lsp.buf.type_definition, opts)
    vim.keymap.set("n", "<leader>rn", vim.lsp.buf.rename, opts)

    if client.server_capabilities.documentFormattingProvider then
      local function format_fn()
        vim.lsp.buf.format({ async = true })
      end
      vim.keymap.set("n", "<leader>ff", format_fn, opts)
      vim.api.nvim_create_autocmd("BufWritePre", {
        pattern = { "*" },
        callback = format_fn,
      })
    else
      vim.keymap.set("n", "ff", '<cmd>lua print("formatting is not supported by this lsp server")<CR>', opts)
    end
    --
    -- Set autocommands conditional on server_capabilities
    if client.server_capabilities.documentHighlightProvider then
      local group = vim.api.nvim_create_augroup("LSPDocumentHighlight", {})

      vim.api.nvim_create_autocmd({ "CursorHold", "CursorHoldI" }, {
        buffer = bufnr,
        group = group,
        callback = vim.lsp.buf.document_highlight,
      })

      vim.api.nvim_create_autocmd({ "CursorMoved" }, {
        buffer = bufnr,
        group = group,
        callback = vim.lsp.buf.clear_references,
      })
    end

    require("lsp-inlayhints").on_attach(client, bufnr, true)

    -- missing semantic tokens support for gopls
    if client.name == "gopls" and not client.server_capabilities.semanticTokensProvider then
      local semantic = client.config.capabilities.textDocument.semanticTokens
      client.server_capabilities.semanticTokensProvider = {
        full = true,
        legend = { tokenModifiers = semantic.tokenModifiers, tokenTypes = semantic.tokenTypes },
        range = true,
      }
    end
  end,
})

-- Sourcegraph configuration. All keys are optional
-- Toggle cody chat
vim.keymap.set("n", "<space>cc", function()
  require("sg.cody.commands").toggle()
end)

local function get_current_visual_selection_rows()
  local start_row = vim.fn.getpos("v")[2] - 1
  local end_row = vim.fn.getpos(".")[2]
  -- non brainer just consider smaller one as start row
  if start_row > end_row then
    local tmp = start_row
    start_row = end_row
    end_row = tmp
  end
  return start_row, end_row
end

vim.keymap.set("v", "<space>ca", function()
  local buf = vim.api.nvim_get_current_buf()
  local start_row, end_row = get_current_visual_selection_rows()

  vim.ui.input({ prompt = "Ask: " }, function(input)
    require("sg.cody.commands").ask_range(buf, start_row, end_row, input)
  end)
end)

-- Cody text highlights for cmp
vim.api.nvim_set_hl(0, "CmpItemKindCody", { fg = "Red" })

vim.keymap.set("n", "<space>cn", function()
  local name = vim.fn.input("chat name: ")
  require("sg.cody.commands").chat(name)
end)

vim.keymap.set("n", "<space>ss", function()
  require("sg.extensions.telescope").fuzzy_search_results()
end)

local ok, msg = pcall(require, "sg")
if not ok then
  print("sg failed to load with:", msg)
  return
end

local node_executable = vim.fn.expand("/home/manish/.nvm/versions/node/v19.6.1/bin/node")
require("sg").setup({
  enable_cody = true,
  node_executable = node_executable,
})

nvim_lsp.tsserver.setup({
  capabilities = capabilities,
  cmd = { "typescript-language-server", "--stdio" },
  filetypes = {
    "javascript",
    "javascriptreact",
    "javascript.jsx",
    "typescript",
    "typescriptreact",
    "typescript.tsx",
  },
  settings = {
    typescript = {
      inlayHints = {
        includeInlayParameterNameHints = "all",
        includeInlayParameterNameHintsWhenArgumentMatchesName = true,
        includeInlayFunctionParameterTypeHints = true,
        includeInlayVariableTypeHints = true,
        includeInlayVariableTypeHintsWhenTypeMatchesName = false,
        includeInlayPropertyDeclarationTypeHints = true,
        includeInlayFunctionLikeReturnTypeHints = true,
        includeInlayEnumMemberValueHints = true,
      },
    },
    javascript = {
      inlayHints = {
        includeInlayParameterNameHints = "all",
        includeInlayParameterNameHintsWhenArgumentMatchesName = true,
        includeInlayFunctionParameterTypeHints = true,
        includeInlayVariableTypeHints = true,
        includeInlayVariableTypeHintsWhenTypeMatchesName = true,
        includeInlayPropertyDeclarationTypeHints = true,
        includeInlayFunctionLikeReturnTypeHints = true,
        includeInlayEnumMemberValueHints = true,
      },
    },
  },
})

nvim_lsp.gopls.setup({
  settings = {
    gopls = {
      gofumpt = true,
      semanticTokens = true,
      experimentalPostfixCompletions = true,
      analyses = {
        unusedparams = true,
        shadow = true,
      },
      staticcheck = true,
      hints = {
        assignVariableTypes = true,
        compositeLiteralFields = true,
        constantValues = true,
        functionTypeParameters = true,
        parameterNames = true,
        rangeVariableTypes = true,
      },
    },
  },
  init_options = {
    usePlaceholders = true,
  },
})

nvim_lsp.lua_ls.setup({
  capabilities = capabilities,
  on_init = function(client)
    local path = client.workspace_folders[1].name
    if not vim.loop.fs_stat(path .. "/.luarc.json") and not vim.loop.fs_stat(path .. "/.luarc.jsonc") then
      client.config.settings = vim.tbl_deep_extend("force", client.config.settings, {
        Lua = {
          completion = {
            callSnippet = "Replace",
          },
          runtime = {
            version = "LuaJIT",
          },
          -- Make the server aware of Neovim runtime files
          workspace = {
            checkThirdParty = false,
            library = {
              vim.env.VIMRUNTIME,
            },
          },
        },
      })

      client.notify("workspace/didChangeConfiguration", { settings = client.config.settings })
    end
    return true
  end,
})

nvim_lsp.sqlls.setup({
  capabilities = capabilities,
})
nvim_lsp.vimls.setup({
  capabilities = capabilities,
})
nvim_lsp.rust_analyzer.setup({
  capabilities = capabilities,
})
nvim_lsp.cssls.setup({
  capabilities = capabilities,
})
nvim_lsp.docker_compose_language_service.setup({
  capabilities = capabilities,
})
nvim_lsp.dockerls.setup({
  capabilities = capabilities,
})
nvim_lsp.emmet_ls.setup({
  capabilities = capabilities,
})
nvim_lsp.html.setup({
  capabilities = capabilities,
})
nvim_lsp.htmx.setup({
  capabilities = capabilities,
})
nvim_lsp.jqls.setup({
  capabilities = capabilities,
})
nvim_lsp.nginx_language_server.setup({
  capabilities = capabilities,
})
nvim_lsp.tailwindcss.setup({
  bilities = capabilities,
})
