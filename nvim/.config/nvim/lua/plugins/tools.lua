return {
	{
		"NvChad/nvim-colorizer.lua",
		event = "BufReadPost",
		cmd = "ColorizerToggle",
		config = true,
	},
	{
		"iamcco/markdown-preview.nvim",
		cmd = { "MarkdownPreviewToggle", "MarkdownPreview", "MarkdownPreviewStop" },
		ft = { "markdown" },
		build = function()
			vim.fn["mkdp#util#install"]()
		end,
	},
	{
		"weirongxu/plantuml-previewer.vim",
		ft = "plantuml",
	},
	{
		"christoomey/vim-tmux-navigator",
		event = "BufReadPost",
	},
	{
		"tpope/vim-commentary",
		event = "BufReadPost",
	},
	{
		"tpope/vim-sleuth", -- detect tabstop and shiftwitdh automatically
	},
	{
		"f-person/git-blame.nvim",
		event = "BufReadPost",
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
		opts = {
			{
				snippet_engine = "vsnip",
			},
		},
		cmd = "Neogen",
	},
}
