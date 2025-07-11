return { -- Collection of various small independent plugins/modules
	"echasnovski/mini.nvim",
	event = "BufReadPost",
	config = function()
		-- Better Around/Inside textobjects
		--
		-- Examples:
		--  - ya)  - [Y]ank [A]round [)]parenthen
		--  - yinq - [Y]ank [I]nside [N]ext [']quote
		--  - ci'  - [C]hange [I]nside [']quote
		require("mini.ai").setup({ n_lines = 500 })

		-- Add/delete/replace surroundings (brackets, quotes, etc.)
		-- - saiw) - [S]urround [A]dd [I]nner [W]ord [)]Paren
		-- - sd'   - [S]urround [D]elete [']quotes
		-- - sr)'  - [S]urround [R]eplace [)] [']
		require("mini.surround").setup()

		local diff = require("mini.diff")
		diff.setup({
			-- Disabled by default
			source = diff.gen_source.none(),
		})

		local statusline = require("mini.statusline")
		statusline.setup({ use_icons = true })

		---@diagnostic disable-next-line: duplicate-set-field
		statusline.section_location = function()
			return "%2l:%-2v"
		end
	end,
}
