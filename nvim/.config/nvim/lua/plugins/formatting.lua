---@param bufnr integer
---@param ... string
---@return string
local function first(bufnr, ...)
	local conform = require("conform")
	for i = 1, select("#", ...) do
		local formatter = select(i, ...)
		if conform.get_formatter_info(formatter, bufnr).available then
			return formatter
		end
	end
	return select(1, ...)
end

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
						"line-length=120",
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
			go = function(bufnr)
				return { "golines", "goimports", "goimports-reviser", first(bufnr, "gofumpt", "gofmt") }
			end,
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
			javascript = function(bufnr)
				return { first(bufnr, "prettierd", "prettier") }
			end,
			javascriptreact = function(bufnr)
				return { first(bufnr, "prettierd", "prettier") }
			end,
			typescript = function(bufnr)
				return { first(bufnr, "prettierd", "prettier") }
			end,
			typescriptreact = function(bufnr)
				return { first(bufnr, "prettierd", "prettier") }
			end,
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
			lsp_format = "fallback",
		},
	},
}
