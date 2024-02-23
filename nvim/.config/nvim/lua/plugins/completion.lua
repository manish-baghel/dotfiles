return {
	"hrsh7th/nvim-cmp",
	dependencies = {
		"hrsh7th/cmp-buffer",
		"hrsh7th/cmp-cmdline",
		"hrsh7th/cmp-nvim-lsp",
		"hrsh7th/cmp-path",
		"chrisgrieser/cmp_yanky",
		"onsails/lspkind.nvim",
		{
			"L3MON4D3/LuaSnip",
			build = (function()
				if vim.fn.has("win32") == 1 then
					return
				end
				return "make install_jsregexp"
			end)(),
		},
		"saadparwaiz1/cmp_luasnip",
		"rafamadriz/friendly-snippets",
	},
	event = "InsertEnter",
	config = function()
		local cmp = require("cmp")
		local lspkind = require("lspkind") -- fancy icons in the completion menu
		local luasnip = require("luasnip")
		require("luasnip.loaders.from_vscode").lazy_load()
		luasnip.config.setup({})
		cmp.setup({
			---@diagnostic disable-next-line: missing-fields
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
					symbol_map = {
						Cody = "🧠",
					},
				}),
			},
			snippet = {
				expand = function(args)
					luasnip.lsp_expand(args.body)
				end,
			},
			window = {
				border = "rounded",
				completion = cmp.config.window.bordered(),
				documentation = cmp.config.window.bordered(),
			},
			completion = {
				border = "rounded",
				completeopt = "menu,menuone,noinsert,noselect",
			},
			mapping = cmp.mapping.preset.insert({
				["<C-n>"] = cmp.mapping.select_next_item(),
				["<C-p>"] = cmp.mapping.select_prev_item(),
				["<C-y>"] = cmp.mapping.confirm({ select = true }),
				["<C-b>"] = cmp.mapping.scroll_docs(-4),
				["<C-f>"] = cmp.mapping.scroll_docs(4),
				["<C-Space>"] = cmp.mapping.complete(),
				["<C-e>"] = cmp.mapping.abort(),
				["<C-l>"] = cmp.mapping(function()
					if luasnip.expand_or_locally_jumpable() then
						luasnip.expand_or_jump()
					end
				end, { "i", "s" }),
				["<C-k>"] = cmp.mapping(function()
					if luasnip.expand_or_locally_jumpable() then
						luasnip.expand_or_jump()
					end
				end, { "i", "s" }),
				["<C-h>"] = cmp.mapping(function()
					if luasnip.locally_jumpable(-1) then
						luasnip.jump(-1)
					end
				end, { "i", "s" }),
				["<C-j>"] = cmp.mapping(function()
					if luasnip.locally_jumpable(-1) then
						luasnip.jump(-1)
					end
				end, { "i", "s" }),
			}),
			sources = cmp.config.sources({
				{ name = "nvim_lsp" },
				{ name = "path" },
				{ name = "cody" }, -- sg.nvim
				{ name = "luasnip" },
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
	end,
}
