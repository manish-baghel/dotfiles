return {
	{
		"olimorris/codecompanion.nvim",
		dependencies = {
			"nvim-lua/plenary.nvim",
			"nvim-treesitter/nvim-treesitter",
			"ravitemer/codecompanion-history.nvim",
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
				extensions = {
					history = {
						enabled = true,
						opts = {
							auto_generate_title = true,
							title_generation_opts = {
								adapter = "gemini",
								model = "gemini-2.5-flash-lite-preview-06-17",
								refresh_every_n_prompts = 5,
								max_refreshes = 3,
								format_title = function(original_title)
									-- this can be a custom function that applies some custom
									-- formatting to the title.
									return original_title
								end,
							},
						},
					},
				},
			})
		end,
	},
}
