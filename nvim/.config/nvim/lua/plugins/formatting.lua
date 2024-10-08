return {
	"stevearc/conform.nvim",
	dependencies = {
		"mason.nvim",
	},
	cmd = "ConformInfo",
	event = "BufWritePre",
	keys = {
		{
			"<leader>ff",
			function()
				require("conform").format({ async = true, lsp_fallback = true, formatters = { "injected" } })
			end,
			mode = { "n", "v" },
			desc = "Format Injected Langs",
		},
	},
	opts = {
		formatters_by_ft = {
			lua = { "stylua" },
			go = { "golines", "goimports", "goimports-reviser", { "gofumpt", "gofmt" } },
			python = { "isort", "black" },
			javascript = { { "prettier", "prettierd" } },
			javascriptreact = { { "prettier", "prettierd" } },
			typescript = { { "prettier", "prettierd" } },
			typescriptreact = { { "prettier", "prettierd" } },
			sh = { "shfmt" },
			json = { "jq" },
			jsonc = { "jq" },
			markdown = { "markdownlint" },
			tex = { "latexindent" },
			xml = { "xmlformat" },
		},

		format_on_save = {
			timeout_ms = 1000,
			lsp_fallback = true,
		},
	},
}
