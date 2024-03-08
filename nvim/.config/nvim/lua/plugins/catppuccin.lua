local utils = require("utils")
return {
	"catppuccin/nvim",
	lazy = false,
	priority = 1000,
	opts = {
		flavour = "mocha", -- latte, frappe, macchiato, mocha
		transparent_background = true, -- disables setting the background color.
		show_end_of_buffer = false, -- shows the '~' characters after the end of buffers
		color_overrides = {},
		custom_highlights = {},
		integrations = {
			cmp = true,
			gitsigns = true,
			treesitter = true,
			notify = true,
			mini = {
				enabled = true,
				indentscope_color = "",
			},
		},
	},
	config = function(_, opts)
		require("catppuccin").setup(opts)
		vim.opt.termguicolors = true
		vim.cmd([[colorscheme catppuccin]])
		vim.g.color_palette = require("catppuccin.palettes").get_palette(opts.flavour) -- just for checking color values, not needed for the plugin itself
	end,
}
