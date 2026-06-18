return {
	"mason-org/mason-lspconfig.nvim",
	cmd = { "LspInstall", "LspUninstall" },
	opts = {
		automatic_enable = false,
	},
	dependencies = {
		{
			"williamboman/mason.nvim",
			cmd = { "Mason", "MasonInstall", "MasonUninstall", "MasonUpdate", "MasonLog", "MasonUninstallAll" },
			opts = {},
		},
		"neovim/nvim-lspconfig",
	},
}
