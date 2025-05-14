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
		"danymat/neogen",
		opts = {
			{
				snippet_engine = "vsnip",
			},
		},
		cmd = "Neogen",
	},
	{
		"folke/todo-comments.nvim",
		event = "BufReadPost",
		dependencies = { "nvim-lua/plenary.nvim" },
		opts = { signs = false },
	},
}
