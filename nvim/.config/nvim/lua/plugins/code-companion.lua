return {
	{
		"olimorris/codecompanion.nvim",
		dependencies = {
			"nvim-lua/plenary.nvim",
			"nvim-treesitter/nvim-treesitter",
		},
		event = { "VeryLazy" },
		keys = {
			{
				"<space>cc",
				function()
					vim.cmd("CodeCompanionChat Toggle")
				end,
			},
		},
		config = function()
			require("codecompanion").setup({
				adapters = {
					gemini = function()
						return require("codecompanion.adapters").extend("gemini", {
							schema = {
								model = {
									default = "gemini-2.5-pro",
								},
							},
							env = {
								api_key = "cmd:gpg --batch --quiet --decrypt ~/google_ai_studio_api_key.gpg",
							},
						})
					end,
				},
				strategies = {
					chat = {
						adapter = "gemini",
					},
					inline = {
						adapter = "gemini",
					},
					cmd = {
						adapter = "gemini",
					},
				},
			})
		end,
	},
}
