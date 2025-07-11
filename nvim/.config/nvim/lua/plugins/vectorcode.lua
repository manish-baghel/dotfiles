return {
	"Davidyz/VectorCode",
	version = "*", -- optional, depending on whether you're on nightly or release
	build = "uv tool upgrade vectorcode",
	dependencies = { "nvim-lua/plenary.nvim" },
	cmd = "VectorCode", -- if you're lazy-loading VectorCode
}
