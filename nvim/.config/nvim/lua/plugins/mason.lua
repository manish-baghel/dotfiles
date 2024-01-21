return {
	"williamboman/mason-lspconfig.nvim",
	dependencies = {
		{
			"williamboman/mason.nvim",
			cmd = { "Mason", "MasonInstall", "MasonUnistall", "MasonUpdate", "MasonLog", "MasonUnistallAll" },
			config = true,
		},
	},
	event = "BufReadPost",
	opts = {
		ensure_installed = {
			"cssls",
			"docker_compose_language_service",
			"dockerls",
			"emmet_ls",
			"gopls",
			"html",
			"htmx",
			"jqls",
			"lua_ls",
			"rust_analyzer",
			"sqlls",
			"tailwindcss",
			"tsserver",
			"vimls",
		},
	},
}
