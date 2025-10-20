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
				adapters = {
					http = {
						gemini = function()
							return require("codecompanion.adapters").extend("gemini", {
								schema = {
									model = {
										default = "gemini-2.5-pro",
									},
									reasoning_effort = {
										default = "high",
									},
								},
								env = {
									api_key = "cmd:gpg --batch --quiet --decrypt ~/google_ai_studio_api_key.gpg",
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
										order = 2,
										mapping = "parameters",
										type = "number",
										optional = true,
										default = 0.6,
										desc =
										"What sampling temperature to use, between 0 and 2. Higher values like 0.8 will make the output more random, while lower values like 0.2 will make it more focused and deterministic. We generally recommend altering this or top_p but not both.",
										validate = function(n)
											return n >= 0 and n <= 2, "Must be between 0 and 2"
										end,
									},
									max_completion_tokens = {
										order = 3,
										mapping = "parameters",
										type = "integer",
										optional = true,
										default = 16384,
										desc = "An upper bound for the number of tokens that can be generated for a completion.",
										validate = function(n)
											return n > 0, "Must be greater than 0"
										end,
									},
									stop = {
										order = 4,
										mapping = "parameters",
										type = "string",
										optional = true,
										default = nil,
										desc =
										"Sets the stop sequences to use. When this pattern is encountered the LLM will stop generating text and return. Multiple stop patterns may be set by specifying multiple separate stop parameters in a modelfile.",
										validate = function(s)
											return s:len() > 0, "Cannot be an empty string"
										end,
									},
									logit_bias = {
										order = 5,
										mapping = "parameters",
										type = "map",
										optional = true,
										default = nil,
										desc =
										"Modify the likelihood of specified tokens appearing in the completion. Maps tokens (specified by their token ID) to an associated bias value from -100 to 100. Use https://platform.openai.com/tokenizer to find token IDs.",
										subtype_key = {
											type = "integer",
										},
										subtype = {
											type = "integer",
											validate = function(n)
												return n >= -100 and n <= 100, "Must be between -100 and 100"
											end,
										},
									},
								},
							})
						end
					}
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
			})
		end,
	},
}
