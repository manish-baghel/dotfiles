return {
	{
		"neovim/nvim-lspconfig",
		dependencies = {
			{
				-- `lazydev` configures Lua LSP for your Neovim config, runtime and plugins
				-- used for completion, annotations and signatures of Neovim apis
				"folke/lazydev.nvim",
				ft = "lua",
			},
		},
		event = { "BufReadPost", "BufNewFile", "BufWritePre" },
		opts = {
			diagnostics = {
				update_in_insert = false,
				virtual_text = {
					severity = vim.diagnostic.severity.WARN,
					spacing = 4,
					source = "if_many",
					prefix = "icons",
				},
				severity_sort = true,
			},

			servers = {
				ts_ls = {
					filetypes = {
						"javascript",
						"javascriptreact",
						"javascript.jsx",
						"typescript",
						"typescriptreact",
						"typescript.tsx",
					},
					settings = {
						typescript = {},
						javascript = {},
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
					settings = {
						Lua = {
							runtime = { version = "LuaJIT" },
							workspace = {
								checkThirdParty = false,
								library = {
									"${3rd}/luv/library",
									vim.fn.expand("~/dotfiles/lua/types"), -- custom user-defined types
									unpack(vim.api.nvim_get_runtime_file("", true)),
								},
							},
							completion = {
								callSnippet = "Replace",
							},
							hint = {
								enable = true,
							},
						},
					},
				},
				pyright = {
					settings = {
						pyright = {
							-- Using Ruff's import organizer
							disableOrganizeImports = true,
						},
						python = {
							analysis = {
								-- Ignore all files for analysis to exclusively use Ruff for linting
								ignore = { "*" },
							},
						},
					},
				},
				ruff = {},
				sqlls = {},
				vimls = {},
				rust_analyzer = {},
				cssls = {},
				docker_compose_language_service = {},
				dockerls = {},
				html = {},
				jqls = {},
				nginx_language_server = {},
				tailwindcss = {},
				bashls = {},
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

			-- Use LspAttach autocommand to only map the following keys
			-- after the language server attaches to the current buffer
			local userLspGroup = vim.api.nvim_create_augroup("UserLspConfig", {})
			vim.api.nvim_create_autocmd("LspAttach", {
				group = userLspGroup,
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

					vim.g["diagnostics_active"] = true
					function Toggle_diagnostics()
						if vim.g.diagnostics_active then
							vim.g.diagnostics_active = false
							vim.diagnostic.enable(false)
						else
							vim.g.diagnostics_active = true
							vim.diagnostic.enable()
						end
					end

					local function filterDuplicates(array)
						local uniqueArray = {}
						for _, tableA in ipairs(array) do
							local isDuplicate = false
							for _, tableB in ipairs(uniqueArray) do
								if vim.deep_equal(tableA, tableB) then
									isDuplicate = true
									break
								end
							end
							if not isDuplicate then
								table.insert(uniqueArray, tableA)
							end
						end
						return uniqueArray
					end

					local pickers = require("telescope.pickers")
					local finders = require("telescope.finders")
					local conf = require("telescope.config").values
					local make_entry = require("telescope.make_entry")
					local function on_list(options)
						options.items = filterDuplicates(options.items)
						if #options.items == 1 then
							vim.fn.setqflist({}, " ", options)
							vim.cmd.cfirst()
						else
							local opts = {}
							local previewer = conf.qflist_previewer(opts)
							pickers
								.new(opts, {
									prompt_title = options.title,
									finder = finders.new_table({
										results = options.items,
										entry_maker = make_entry.gen_from_quickfix(opts),
									}),
									previewer = previewer,
									sorter = conf.generic_sorter(opts),
								})
								:find()
						end
					end

					local keymap_opts = { buffer = ev.buf }
					vim.keymap.set("n", "gD", vim.lsp.buf.declaration, keymap_opts)
					vim.keymap.set("n", "gd", function()
						vim.lsp.buf.definition({ on_list = on_list })
					end, keymap_opts)
					vim.keymap.set("n", "gr", require("telescope.builtin").lsp_references, keymap_opts)
					vim.keymap.set("n", "K", vim.lsp.buf.hover, keymap_opts)
					vim.keymap.set({ "n", "v" }, "ga", vim.lsp.buf.code_action, keymap_opts)
					vim.keymap.set("n", "gi", vim.lsp.buf.implementation, keymap_opts)
					vim.keymap.set("n", "<C-k>", vim.lsp.buf.signature_help, keymap_opts)
					vim.keymap.set("n", "<leader>D", vim.lsp.buf.type_definition, keymap_opts)
					vim.keymap.set("n", "<leader>rn", vim.lsp.buf.rename, keymap_opts)

					-- Diagnostic keymaps
					vim.keymap.set("n", "[d", vim.diagnostic.get_prev, { desc = "Go to previous diagnostic message" })
					vim.keymap.set("n", "]d", vim.diagnostic.get_next, { desc = "Go to next diagnostic message" })
					vim.keymap.set(
						"n",
						"<space>e",
						vim.diagnostic.open_float,
						{ desc = "Open floating diagnostic message" }
					)
					vim.keymap.set("n", "<space>q", vim.diagnostic.setloclist, { desc = "Open diagnostics list" })

					vim.keymap.set(
						"n",
						"<leader>xd",
						Toggle_diagnostics,
						{ noremap = true, silent = true, desc = "Toggle vim diagnostics" }
					)
				end,
			})
		end,
	},
}
