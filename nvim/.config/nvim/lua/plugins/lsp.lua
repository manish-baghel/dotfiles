return {
	{
		"neovim/nvim-lspconfig",
		event = { "BufReadPost", "BufNewFile", "BufWritePre" },
		dependencies = {
			{
				"lvimuser/lsp-inlayhints.nvim",
				event = "LspAttach",
				opts = {
					inlay_hints = {
						max_len_align_padding = 1,
						highlight = "LspInlayHint",
						priority = 0,
					},
					enabled_at_startup = true,
					debug_mode = false,
				},
			},
			{
				"folke/neodev.nvim",
				opts = {
					library = {
						plugins = {
							"neotest",
						},
						types = true,
					},
				},
				ft = "lua",
			},
		},
		opts = {
			diagnostics = {
				underline = true,
				update_in_insert = false,
				virtual_text = {
					spacing = 4,
					source = "if_many",
					prefix = "icons",
				},
				severity_sort = true,
			},
			inlay_hints = {
				enabled = true,
			},

			servers = {
				tsserver = {
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
				},
				gopls = {
					settings = {
						gopls = {
							gofumpt = true,
							analyses = {
								fieldalignment = true,
								nilness = true,
								unusedwrite = true,
								useany = true,
								unusedparams = true,
								shadow = true,
							},
							codelenses = {
								gc_details = false,
								generate = true,
								regenerate_cgo = true,
								run_govulncheck = true,
								test = true,
								tidy = true,
								upgrade_dependency = true,
								vendor = true,
							},
							hints = {
								assignVariableTypes = true,
								compositeLiteralFields = true,
								compositeLiteralTypes = true,
								constantValues = true,
								functionTypeParameters = true,
								parameterNames = true,
								rangeVariableTypes = true,
							},
							staticcheck = true,
							semanticTokens = true,
							usePlaceholders = true,
							completeUnimported = true,
						},
					},
				},
				lua_ls = {
					on_init = function(client)
						local path = client.workspace_folders[1].name
						if
							not vim.loop.fs_stat(path .. "/.luarc.json")
							and not vim.loop.fs_stat(path .. "/.luarc.jsonc")
						then
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

									telemetry = {
										enable = false,
									},
								},
							})

							client.notify("workspace/didChangeConfiguration", { settings = client.config.settings })
						end
						return true
					end,
				},
				sqlls = {},
				vimls = {},
				rust_analyzer = {},
				cssls = {},
				docker_compose_language_service = {},
				dockerls = {},
				emmet_ls = {},
				html = {},
				htmx = {},
				jqls = {},
				nginx_language_server = {},
				tailwindcss = {},
				bashls = {},
				marksman = {},
				texlab = {},
			},
		},
		config = function(_, opts)
			local has_cmp, cmp_nvim_lsp = pcall(require, "cmp_nvim_lsp")
			local capabilities = vim.tbl_deep_extend(
				"force",
				vim.lsp.protocol.make_client_capabilities(),
				has_cmp and cmp_nvim_lsp.default_capabilities() or {},
				opts.capabilities or {}
			) or {}
			if capabilities then
				capabilities.textDocument.completion.completionItem.snippetSupport = true
			end
			-- update capabilities of all servers
			local servers = opts.servers
			local lspconfig = require("lspconfig")
			for server, server_opts in pairs(servers) do
				local server_opts_with_capabilities =
					vim.tbl_deep_extend("force", { capabilities = vim.deepcopy(capabilities) }, server_opts)
				lspconfig[server].setup(server_opts_with_capabilities)
			end

			if type(opts.diagnostics.virtual_text) == "table" and opts.diagnostics.virtual_text.prefix == "icons" then
				opts.diagnostics.virtual_text.prefix = vim.fn.has("nvim-0.10.0") == 0 and "●"
					or function(diagnostic)
						local icons = require("lazyvim.config").icons.diagnostics
						for d, icon in pairs(icons) do
							if diagnostic.severity == vim.diagnostic.severity[d:upper()] then
								return icon
							end
						end
					end
			end
			vim.diagnostic.config(vim.deepcopy(opts.diagnostic))

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
					-- missing semantic tokens support for gopls
					if client.name == "gopls" and not client.server_capabilities.semanticTokensProvider then
						local semantic = client.config.capabilities.textDocument.semanticTokens
						client.server_capabilities.semanticTokensProvider = {
							full = true,
							legend = {
								tokenModifiers = semantic.tokenModifiers,
								tokenTypes = semantic.tokenTypes,
							},
							range = true,
						}
					end

					require("lsp-inlayhints").on_attach(client, bufnr)

					local keymap_opts = { buffer = ev.buf }
					vim.keymap.set("n", "gD", vim.lsp.buf.declaration, keymap_opts)
					vim.keymap.set("n", "gd", vim.lsp.buf.definition, keymap_opts)
					vim.keymap.set("n", "K", vim.lsp.buf.hover, keymap_opts)
					vim.keymap.set({ "n", "v" }, "ga", vim.lsp.buf.code_action, keymap_opts)
					vim.keymap.set("n", "gr", vim.lsp.buf.references, keymap_opts)
					vim.keymap.set("n", "gi", vim.lsp.buf.implementation, keymap_opts)
					vim.keymap.set("n", "<C-k>", vim.lsp.buf.signature_help, keymap_opts)
					vim.keymap.set("n", "<leader>D", vim.lsp.buf.type_definition, keymap_opts)
					vim.keymap.set("n", "<leader>rn", vim.lsp.buf.rename, keymap_opts)
				end,
			})
		end,
	},
	{
		"sourcegraph/sg.nvim",
		build = "nvim -l build/init.lua",
		event = { "BufReadPost", "BufNewFile", "BufWritePre" },
		keys = {
			{
				"<space>cc",
				function()
					require("sg.cody.commands").toggle()
				end,
			},
			{
				"<space>cn",
				function()
					local name = vim.fn.input("chat name: ")
					require("sg.cody.commands").chat(name)
				end,
			},
			{
				"<space>ss",
				function()
					require("sg.extensions.telescope").fuzzy_search_results()
				end,
			},
			{
				"<space>ca",
				function()
					--- get current visual selection rows
					--- @return integer start_row beginning of visual selection
					--- @return integer end_row end of visual selection
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

					local buf = vim.api.nvim_get_current_buf()
					local start_row, end_row = get_current_visual_selection_rows()

					vim.ui.input({ prompt = "Ask: " }, function(input)
						require("sg.cody.commands").ask_range(buf, start_row, end_row, input)
					end)
				end,
				mode = "v",
			},
		},
		config = function()
			-- Do not load on .env, credentials files
			local exclusionList = { ".env", "credentials", "secret" }
			local filename = vim.fn.expand("%:t"):lower()
			for _, excluded in ipairs(exclusionList) do
				if string.find(filename, excluded) then
					vim.notify("sg.nvim: Skipping loading on " .. filename)
					return
				end
			end

			-- Cody text highlights for cmp
			vim.api.nvim_set_hl(0, "CmpItemKindCody", { fg = vim.g.color_palette.peach })

			require("sg").setup({
				enable_cody = true,
			})
		end,
	},
}
