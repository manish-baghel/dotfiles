local utils = require("utils")
return {
	{
		"sourcegraph/sg.nvim",
		build = "nvim -l build/init.lua",
		event = { "BufReadPost", "BufNewFile", "BufWritePre" },
		keys = {
			{
				"<space>cc",
				function()
					require("sg.cody.commands").toggle()
				end,
			},
			{
				"<space>cn",
				function()
					local name = vim.fn.input("chat name: ")
					require("sg.cody.commands").chat(name, {})
				end,
			},
			{
				"<space>ss",
				function()
					require("sg.extensions.telescope").fuzzy_search_results()
				end,
			},
			{
				"<space>ca",
				function()
					local buf = vim.api.nvim_get_current_buf()
					local start_row, end_row = utils.get_visual_selection_rows()

					vim.ui.input({ prompt = "Task/Ask: " }, function(input)
						if input == nil or input == "" then
							return
						end
						require("sg.cody.commands").do_task(buf, start_row, end_row, input)
					end)
				end,
				mode = "v",
			},
		},
		config = function()
			-- Do not load on .env, credentials files
			local exclusionList = { ".env", "credentials", "secret" }
			local filename = vim.fn.expand("%:t"):lower()
			for _, excluded in ipairs(exclusionList) do
				if string.find(filename, excluded) then
					vim.notify("sg.nvim: Skipping loading on " .. filename)
					return
				end
			end

			-- Cody text highlights for cmp
			vim.api.nvim_set_hl(0, "CmpItemKindCody", { fg = vim.g.color_palette.peach })

			require("sg").setup({
				accept_tos = true,
				enable_cody = true,
				chat = {
					default_model = "anthropic/claude-3-7-sonnet-latest",
					-- accounts/fireworks/models/deepseek-v3
				},
			})
		end,
	},
}
