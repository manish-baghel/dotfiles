return {
	"b0o/schemastore.nvim",
	event = {
		"BufReadPost",
		"BufNewFile",
	},
	ft = "json",
	config = function(_, opts)
		require("lspconfig").jsonls.setup({
			settings = {
				json = {
					schemas = require("schemastore").json.schemas(),
					validate = { enable = true },
				},
			},
		})
	end,
}
