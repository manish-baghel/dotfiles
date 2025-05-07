return {
	{
		"huggingface/llm.nvim",
		opts = {
			backend = "ollama",
			model = "deepseek-coder-v2:16b-lite-base-q4_0",
			url = "http://localhost:11434/api/generate",
			request_body = {
				options = {
					max_new_tokens = 100,
					temperature = 0.2,
					top_p = 0.95,
				},
			},
			fim = {
				enabled = true,
				prefix = "<｜fim▁begin｜>",
				middle = "<｜fim▁end｜>",
				suffix = "<｜fim▁hole｜>",
			},
		},
	},
}
