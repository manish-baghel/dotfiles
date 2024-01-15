return {
	{
		"norcalli/nvim-colorizer.lua",
		event = "VeryLazy",
	},
	{
		"chemzqm/macdown.vim",
		ft = "markdown",
	},
	{
		"weirongxu/plantuml-previewer.vim",
		ft = "plantuml",
	},
	{
		"tyru/open-browser.vim",
		lazy = true,
	},
	{
		"christoomey/vim-tmux-navigator",
		event = "VeryLazy",
	},
	{
		"tpope/vim-commentary",
		event = { "BufReadPost" },
	},
	{
		"tpope/vim-surround",
		event = { "BufReadPost" },
	},
	{
		"f-person/git-blame.nvim",
		event = { "BufReadPost" },
	},
	{
		"junegunn/goyo.vim",
		keys = {
			{ "<leader>z", "<CMD>Goyo<CR>" },
		},
		config = function()
			vim.g.goyo_width = 140
			vim.g.goyo_margin_top = 2
			vim.g.goyo_margin_bottom = 2
		end,
	},
	{
		"danymat/neogen",
		dependencies = "nvim-treesitter/nvim-treesitter",
		event = { "InsertEnter" },
		opts = {
			{
				snippet_engine = "vsnip",
			},
		},
		config = true,
	},
}
