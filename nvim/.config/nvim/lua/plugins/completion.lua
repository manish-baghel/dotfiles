return {
	"hrsh7th/nvim-cmp",
	dependencies = {
		"hrsh7th/cmp-buffer",
		"hrsh7th/cmp-cmdline",
		"hrsh7th/cmp-nvim-lsp",
		"hrsh7th/cmp-path",
		"chrisgrieser/cmp_yanky",
		"hrsh7th/vim-vsnip",
		"hrsh7th/vim-vsnip-integ",
		"hrsh7th/cmp-vsnip",
		"rafamadriz/friendly-snippets",
		"onsails/lspkind.nvim",
	},
	event = "InsertEnter",
	config = function()
		local cmp = require("cmp")
		local lspkind = require("lspkind") -- fancy icons in the completion menu
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
				["<C-n>"] = cmp.mapping.select_next_item(),
				["<C-p>"] = cmp.mapping.select_prev_item(),
				["<C-b>"] = cmp.mapping.scroll_docs(-4),
				["<C-f>"] = cmp.mapping.scroll_docs(4),
				["<C-Space>"] = cmp.mapping.complete(),
				["<C-y>"] = cmp.mapping.confirm({ select = true }),
				["<C-e>"] = cmp.mapping.abort(),
				-- ["<CR>"] = cmp.mapping(function(fallback)
				-- 	if cmp.visible() and cmp.get_active_entry() then
				-- 		cmp.confirm({ behavior = cmp.ConfirmBehavior.Replace, select = false })
				-- 	else
				-- 		fallback()
				-- 	end
				-- end, { "i", "s", "c" }),
			}),
			sources = cmp.config.sources({
				{ name = "nvim_lsp" },
				{ name = "cody" }, -- sg.nvim
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
	end,
}
