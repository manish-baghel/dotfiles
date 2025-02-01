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
				require("conform").formatters.ruff_format = {
					args = {
						"format",
						"--config",
						"line-length=100",
						"--force-exclude",
						"--stdin-filename",
						"$FILENAME",
						"-",
					},
				}
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
			python = function(bufnr)
				if require("conform").get_formatter_info("ruff_format", bufnr).available then
					return {
						-- To fix auto-fixable lint errors.
						"ruff_fix",
						-- To run the Ruff formatter.
						"ruff_format",
						-- To organize the imports.
						"ruff_organize_imports",
					}
				else
					return { "isort", "black" }
				end
			end,
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
			yaml = { "yamlfix" },
			yml = { "yamlfix" },
		},

		format_on_save = {
			timeout_ms = 1000,
			lsp_fallback = true,
		},
	},
}
