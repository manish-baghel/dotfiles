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
			"b0o/schemastore.nvim",
		},
		lazy = false,
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
				ts_ls = {},
				oxfmt = {}, -- JS/TS
				oxlint = {},
				jsonls = {},
				gopls = {
					settings = {
						gopls = {
							gofumpt = false,
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
				clangd = {},
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
				jinja_lsp = {
					filetypes = { "jinja" },
				},
			},
		},
		config = function(_, opts)
			if type(opts.diagnostics.virtual_text) == "table" and opts.diagnostics.virtual_text.prefix == "icons" then
				opts.diagnostics.virtual_text.prefix = "●"
			end
			vim.diagnostic.config(vim.deepcopy(opts.diagnostics))

			local has_cmp, cmp_nvim_lsp = pcall(require, "cmp_nvim_lsp")
			local capabilities = vim.tbl_deep_extend(
				"force",
				vim.lsp.protocol.make_client_capabilities(),
				has_cmp and cmp_nvim_lsp.default_capabilities() or {},
				opts.capabilities or {}
			) or {}
			capabilities.textDocument = capabilities.textDocument or {}
			capabilities.textDocument.completion = capabilities.textDocument.completion or {}
			capabilities.textDocument.completion.completionItem = capabilities.textDocument.completion.completionItem or {}
			capabilities.textDocument.completion.completionItem.snippetSupport = true

			vim.lsp.config("*", { capabilities = capabilities })

			local servers = opts.servers
			servers.jsonls = vim.tbl_deep_extend("force", {
				settings = {
					json = {
						schemas = require("schemastore").json.schemas(),
						validate = { enable = true },
					},
				},
			}, servers.jsonls or {})

			for server, server_opts in pairs(servers) do
				vim.lsp.config(server, server_opts)
				vim.lsp.enable(server)
			end

			local methods = vim.lsp.protocol.Methods
			vim.g.diagnostics_active = vim.diagnostic.is_enabled()
			function _G.Toggle_diagnostics()
				local enabled = not vim.diagnostic.is_enabled()
				vim.diagnostic.enable(enabled)
				vim.g.diagnostics_active = enabled
			end

			local function symbol_range_at_cursor(bufnr)
				local row, col = unpack(vim.api.nvim_win_get_cursor(0))
				row = row - 1

				local line = vim.api.nvim_buf_get_lines(bufnr, row, row + 1, false)[1] or ""
				local function is_symbol_char(char)
					return char:match("[%w_]") ~= nil
				end

				local start_col = col
				while start_col > 0 and is_symbol_char(line:sub(start_col, start_col)) do
					start_col = start_col - 1
				end

				local end_col = col
				while end_col < #line and is_symbol_char(line:sub(end_col + 1, end_col + 1)) do
					end_col = end_col + 1
				end

				return row, col, start_col, end_col
			end

			local function get_inlay_hint_at_cursor(bufnr)
				local row, col, start_col, end_col = symbol_range_at_cursor(bufnr)
				local hints = vim.lsp.inlay_hint.get({
					bufnr = bufnr,
					range = {
						start = { line = row, character = start_col },
						["end"] = { line = row, character = end_col },
					},
				})

				if #hints == 0 then
					return
				end

				table.sort(hints, function(a, b)
					return math.abs(a.inlay_hint.position.character - col)
						< math.abs(b.inlay_hint.position.character - col)
				end)

				return hints[1]
			end

			local function extend_markdown(contents, input)
				if not input then
					return
				end

				local ok = pcall(vim.lsp.util.convert_input_to_markdown_lines, input, contents)
				if not ok and type(input) == "string" then
					vim.list_extend(contents, vim.split(input, "\n", { plain = true }))
				end
			end

			local function inlay_hint_tooltip_lines(hint)
				local contents = {}
				extend_markdown(contents, hint.tooltip)
				if #contents > 0 then
					return contents
				end

				if type(hint.label) == "table" then
					for _, part in ipairs(hint.label) do
						if part.tooltip then
							if #contents > 0 then
								table.insert(contents, "")
							end
							extend_markdown(contents, part.tooltip)
						end
					end
				end

				return contents
			end

			local function first_inlay_hint_location(hint)
				if type(hint.label) ~= "table" then
					return
				end

				for _, part in ipairs(hint.label) do
					if part.location then
						return part.location
					end
				end
			end

			local function show_inlay_hint_hover()
				local bufnr = vim.api.nvim_get_current_buf()
				local hint_item = get_inlay_hint_at_cursor(bufnr)
				if not hint_item then
					return false
				end

				local client = vim.lsp.get_client_by_id(hint_item.client_id)
				if not client then
					return false
				end

				local hint = vim.deepcopy(hint_item.inlay_hint)
				if client:supports_method(methods.inlayHint_resolve, bufnr) then
					local response = client:request_sync(methods.inlayHint_resolve, hint, 500, bufnr)
					if response and not response.err and response.result then
						hint = response.result
					end
				end

				local contents = inlay_hint_tooltip_lines(hint)
				if #contents > 0 then
					vim.lsp.util.open_floating_preview(contents, "markdown", {
						border = "rounded",
						focus_id = "inlay_hint_hover",
					})
					return true
				end

				local location = first_inlay_hint_location(hint)
				if not location then
					return false
				end

				local response = client:request_sync(methods.textDocument_hover, {
					textDocument = { uri = location.uri },
					position = location.range.start,
				}, 500, bufnr)

				if not (response and not response.err and response.result and response.result.contents) then
					return false
				end

				contents = {}
				extend_markdown(contents, response.result.contents)
				if #contents == 0 then
					return false
				end

				vim.lsp.util.open_floating_preview(contents, "markdown", {
					border = "rounded",
					focus_id = "inlay_hint_hover",
				})
				return true
			end

			-- Use LspAttach autocommand to only map the following keys
			-- after the language server attaches to the current buffer
			local userLspGroup = vim.api.nvim_create_augroup("UserLspConfig", { clear = true })
			local documentHighlightGroup = vim.api.nvim_create_augroup("UserLspDocumentHighlight", { clear = false })
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

					if client:supports_method(methods.textDocument_inlayHint, bufnr) then
						vim.lsp.inlay_hint.enable(true, { bufnr = bufnr })
					end

					if client:supports_method(methods.textDocument_codeLens, bufnr) then
						vim.lsp.codelens.enable(true, { bufnr = bufnr, client_id = client.id })
					end

					-- Set autocommands conditional on server_capabilities
					if client:supports_method(methods.textDocument_documentHighlight, bufnr) then
						vim.api.nvim_clear_autocmds({ group = documentHighlightGroup, buffer = bufnr })

						vim.api.nvim_create_autocmd({ "CursorHold", "CursorHoldI" }, {
							buffer = bufnr,
							group = documentHighlightGroup,
							callback = vim.lsp.buf.document_highlight,
						})

						vim.api.nvim_create_autocmd({ "CursorMoved", "CursorMovedI", "BufLeave" }, {
							buffer = bufnr,
							group = documentHighlightGroup,
							callback = vim.lsp.buf.clear_references,
						})
					end

					if vim.b[bufnr].user_lsp_keymaps_set then
						return
					end
					vim.b[bufnr].user_lsp_keymaps_set = true

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
					vim.keymap.set("n", "K", function()
						if not show_inlay_hint_hover() then
							vim.lsp.buf.hover()
						end
					end, keymap_opts)
					vim.keymap.set({ "n", "v" }, "ga", vim.lsp.buf.code_action, keymap_opts)
					vim.keymap.set("n", "gi", vim.lsp.buf.implementation, keymap_opts)
					vim.keymap.set("n", "<C-k>", vim.lsp.buf.signature_help, keymap_opts)
					vim.keymap.set("n", "<leader>D", vim.lsp.buf.type_definition, keymap_opts)
					vim.keymap.set("n", "<leader>rn", vim.lsp.buf.rename, keymap_opts)

					-- Diagnostic keymaps
					vim.keymap.set("n", "[d", function()
						vim.diagnostic.jump({ count = -1, float = true })
					end, { desc = "Go to previous diagnostic message" })
					vim.keymap.set("n", "]d", function()
						vim.diagnostic.jump({ count = 1, float = true })
					end, { desc = "Go to next diagnostic message" })
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

			-- https://docs.astral.sh/ruff/editors/setup/#neovim
			vim.api.nvim_create_autocmd("LspAttach", {
				group = vim.api.nvim_create_augroup("lsp_attach_disable_ruff_hover", { clear = true }),
				callback = function(args)
					local client = vim.lsp.get_client_by_id(args.data.client_id)
					if client == nil then
						return
					end
					if client.name == "ruff" then
						-- Disable hover in favor of Pyright
						client.server_capabilities.hoverProvider = false
					end
				end,
				desc = "LSP: Disable hover capability from Ruff",
			})
		end,
	},
}
