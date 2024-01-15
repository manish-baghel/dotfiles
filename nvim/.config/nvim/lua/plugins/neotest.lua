return {
	{
		"nvim-neotest/neotest-go",
		lazy = true,
	},
	{
		"nvim-neotest/neotest",
		keys = {
			{
				"<leader>tr",
				function()
					require("neotest").run.run({ vim.fn.expand("%:p") })
				end,
			},
			{
				"<leader>ts",
				function()
					for _, adapter_id in ipairs(require("neotest").state.adapter_ids()) do
						require("neotest").run.run({ suite = true, adapter = adapter_id })
					end
				end,
			},
			{
				"<leader>ta",
				function()
					require("neotest").run.attach()
				end,
			},
			{
				"<leader>to",
				function()
					require("neotest").output.open({ enter = true, last_run = true })
				end,
			},
			{
				"<leader>tp",
				function()
					require("neotest").summary.toggle()
				end,
			},
			{
				"<leader>te",
				function()
					require("neotest").output_panel.toggle()
				end,
			},
		},
		config = function()
			require("neotest").setup({
				adapters = {
					require("neotest-go"),
				},
			})
		end,
	},
}
