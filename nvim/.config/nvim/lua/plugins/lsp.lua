return {
  {
    "folke/neodev.nvim",
    config = true,
  },
  {
    "williamboman/mason.nvim",
    cmd = { "Mason", "MasonInstall", "MasonUpdate", "MasonUninstall", "MasonLog" },
    config = true,
  },
  {
    "williamboman/mason-lspconfig.nvim",
    opts = {
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
  },
  {
    "nvimtools/none-ls.nvim",
    dependencies = {
      "ThePrimeagen/refactoring.nvim",
    },
    config = function()
      local nls = require("null-ls")
      nls.setup({
        nls.builtins.formatting.stylua,
        nls.builtins.formatting.prettierd,
        nls.builtins.diagnostics.eslint_d,
        nls.builtins.code_actions.eslint_d,
        nls.builtins.completion.spell,
        nls.builtins.formatting.gofumpt,
        nls.builtins.formatting.goimports,
        nls.builtins.formatting.goimports_reviser,
        nls.builtins.code_actions.gomodifytags,
        nls.builtins.completion.vsnip,
      })
    end
  },
  {
    "nvimdev/lspsaga.nvim",
    opts = {
      lightbulb = {
        sign = false,
      },
      diagnostic = {
        extend_relatedInformation = true,
        keys = {
          quit = { "q", "<ESC>" },
        },
      },
    },
    event = "LspAttach",
  },
  {
    "lvimuser/lsp-inlayhints.nvim",
    event = "LspAttach",
  },
  {
    "neovim/nvim-lspconfig",
    dependencies = {
      "lvimuser/lsp-inlayhints.nvim"
    },
    config = function()
      local capabilities = require("cmp_nvim_lsp").default_capabilities()
      capabilities.textDocument.completion.completionItem.snippetSupport = true

      local nvim_lsp = require("lspconfig")
      require("lsp-inlayhints").setup({
        inlay_hints = {
          max_len_align_padding = 1,
          highlight = "LspInlayHint",
          priority = 0,
        },
        enabled_at_startup = true,
        debug_mode = false,
      })

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
            vim.keymap.set("n", "ff",
              '<cmd>lua print("formatting is not supported by this lsp server")<CR>',
              opts)
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

          require("lsp-inlayhints").on_attach(client, bufnr)

          -- missing semantic tokens support for gopls
          if client.name == "gopls" and not client.server_capabilities.semanticTokensProvider then
            local semantic = client.config.capabilities.textDocument.semanticTokens
            client.server_capabilities.semanticTokensProvider = {
              full = true,
              legend = {
                tokenModifiers = semantic.tokenModifiers,
                tokenTypes = semantic.tokenTypes
              },
              range = true,
            }
          end
        end,
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
            client.config.settings = vim.tbl_deep_extend("force",
              client.config.settings, {
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

            client.notify("workspace/didChangeConfiguration",
              { settings = client.config.settings })
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
        capabilities = capabilities,
      })
    end
  },
  {
    "sourcegraph/sg.nvim",
    build = "nvim -l build/init.lua",
    config = function()
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
      vim.api.nvim_set_hl(0, "CmpItemKindCody", { fg = vim.g.color_palette.red })

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
    end
  },
  "onsails/lspkind.nvim",
  "gbrlsnchs/telescope-lsp-handlers.nvim",
}
