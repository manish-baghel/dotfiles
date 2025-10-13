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
	opts = {
		formatters_by_ft = {
			lua = { "stylua" },
			go = function(bufnr)
				return { "golines", "goimports", first(bufnr, "gofumpt", "gofmt") }
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
				return { first(bufnr, "prettier") }
			end,
			javascriptreact = function(bufnr)
				return { first(bufnr, "prettier") }
			end,
			typescript = function(bufnr)
				return { first(bufnr, "prettier") }
			end,
			typescriptreact = function(bufnr)
				return { first(bufnr, "prettier") }
			end,
			-- sh = { "shfmt" },
			json = { "jq" },
			jsonc = { "jq" },
			markdown = { "markdownlint" },
			tex = { "latexindent" },
			xml = { "xmlformat" },
			yaml = { "yamlfix" },
			yml = { "yamlfix" },
		},
		keys = {
			{
				"<leader>ff",
				function()
					require("conform").format({ async = true, lsp_format = "fallback" })
				end,
				mode = { "n", "v" },
				desc = "Format Injected Langs",
			},
		},
		format_on_save = {
			timeout_ms = 2000,
			lsp_format = "fallback",
		},
	},
}
