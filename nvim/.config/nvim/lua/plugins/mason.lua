return {
	"mason-org/mason-lspconfig.nvim",
	dependencies = {
		{
			"williamboman/mason.nvim",
			cmd = { "Mason", "MasonInstall", "MasonUnistall", "MasonUpdate", "MasonLog", "MasonUnistallAll" },
			config = true,
		},
	},
}
