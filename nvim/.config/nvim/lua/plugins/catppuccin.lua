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
		vim.g.color_palette = require("catppuccin.palettes").get_palette(opts.flavour)

		local function open_color_palette()
			local buf = vim.api.nvim_create_buf(false, true)
			vim.api.nvim_buf_set_option(buf, "buftype", "nofile")
			vim.api.nvim_buf_set_option(buf, "swapfile", false)
			vim.api.nvim_buf_set_option(buf, "modifiable", true)

			local lines = { "🌈 Color Palette" }
			for k, v in pairs(vim.g.color_palette) do
				table.insert(lines, k .. ": " .. v)
			end
			vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)

			vim.api.nvim_open_win(buf, true, {
				relative = "editor",
				width = 30,
				height = 60,
				row = 0,
				col = vim.o.columns - 30,
				style = "minimal",
				border = "rounded",
			})
			vim.cmd("ColorizerToggle")
		end

		vim.keymap.set("n", "<leader>cp", open_color_palette)
	end,
}
