return {
	{
		"olimorris/codecompanion.nvim",
		dependencies = {
			"nvim-lua/plenary.nvim",
			"nvim-treesitter/nvim-treesitter",
			"ravitemer/codecompanion-history.nvim",
			"j-hui/fidget.nvim",
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
		init = function()
			require("plugins.code-companion.fidget-spinner"):init()
			require("plugins.code-companion.status-spinner"):init()
		end,
		config = function()
			require("codecompanion").setup({
				display = {
					chat = {
						icons = {
							chat_fold = " ",
						},
						fold_reasoning = true,
						show_reasoning = false,
					},
				},
				interactions = {
					chat = {
						adapter = "gemini",
						tools = {
							["grep_search"] = {
								---@param adapter CodeCompanion.HTTPAdapter
								---@return boolean
								enabled = function(adapter)
									return vim.fn.executable("rg") == 1
								end,
							},
						},
					},
					inline = {
						adapter = "gemini",
					},
					cmd = {
						adapter = "gemini",
					},
				},
				send = {
					callback = function(chat)
						vim.cmd("stopinsert")
						chat:submit()
						chat:add_buf_message({ role = "llm", content = "" })
					end,
					index = 1,
					description = "Send",
				},
				extensions = {
					history = {
						enabled = true,
						opts = {
							auto_generate_title = true,
							title_generation_opts = {
								adapter = "gemini_non_reasoning",
								model = "gemini-2.5-flash-lite",
								refresh_every_n_prompts = 5,
								max_refreshes = 3,
								format_title = function(original_title)
									-- this can be a custom function that applies some custom
									-- formatting to the title.
									return original_title
								end,
							},
							summary = {
								create_summary_keymap = "gcs",
								browse_summaries_keymap = "gbs",
								generation_opts = {
									adapter = "gemini_non_reasoning",
									model = "gemini-2.5-flash-lite",
									context_size = 1000000,
									include_references = true,
									include_tool_outputs = true,
									system_prompt = nil,
									format_summary = nil,
								},
							},
						},
					},
				},
				adapters = {
					http = {
						gemini = function()
							return require("codecompanion.adapters").extend("gemini", {
								schema = {
									model = {
										default = "gemini-3.1-pro-preview",
									},
									reasoning_effort = {
										default = "high",
									},
								},
								env = {
									api_key = "cmd:gpg --batch --quiet --decrypt ~/google_ai_studio_old_key.gpg",
								},
							})
						end,
						gemini_non_reasoning = function()
							return require("codecompanion.adapters").extend("gemini", {
								schema = {
									model = {
										default = "gemini-2.5-flash-lite",
									},
									reasoning_effort = {
										default = "none",
									},
								},
								env = {
									api_key = "cmd:gpg --batch --quiet --decrypt ~/google_ai_studio_api_key.gpg",
								},
							})
						end,
						groq = function()
							return require("codecompanion.adapters").extend("openai_compatible", {
								env = {
									url = "https://api.groq.com/openai",
									api_key = "cmd:gpg --batch --quiet --decrypt ~/groq_api_key.gpg",
									chat_url = "/v1/chat/completions",
									models_endpoint = "/v1/models",
								},
								schema = {
									model = {
										default = "moonshotai/kimi-k2-instruct",
									},
									temperature = {
										default = 0.6,
									},
									max_completion_tokens = {
										default = 16384,
									},
									stop = {
										default = nil,
									},
									logit_bias = {
										default = nil,
									},
								},
							})
						end,
					},
				},
			})
		end,
	},
}
