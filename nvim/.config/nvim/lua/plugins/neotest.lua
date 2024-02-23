return {
	{
		"nvim-neotest/neotest-go",
		ft = "go",
		event = "BufReadPost",
	},
	{
		"nvim-neotest/neotest",
		dependencies = {
			"nvim-lua/plenary.nvim",
			"nvim-treesitter/nvim-treesitter",
		},
		cmd = { "Neotest" },
		event = "BufReadPost",
		keys = {
			{
				"<leader>tr",
				function()
					require("neotest").run.run()
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
			---@diagnostic disable-next-line: missing-fields
			require("neotest").setup({
				adapters = {
					require("neotest-go")({
						experimental = {
							test_table = true,
						},
						args = { "-count=1", "-timeout=60s" },
					}),
				},
			})
		end,
	},
}
