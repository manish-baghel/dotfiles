return {
	"goolord/alpha-nvim",
	event = "VimEnter",
	config = function()
		local alpha = require("alpha")
		local alpha_dashboard_theme = require("alpha.themes.dashboard")
		local logo = [[
                                             
      ████ ██████           █████      ██
     ███████████             █████ 
     █████████ ███████████████████ ███   ███████████
    █████████  ███    █████████████ █████ ██████████████
   █████████ ██████████ █████████ █████ █████ ████ █████
 ███████████ ███    ███ █████████ █████ █████ ████ █████
██████  █████████████████████ ████ █████ █████ ████ ██████
]]
		alpha_dashboard_theme.section.header.val = vim.split(logo, "\n")
		alpha_dashboard_theme.section.buttons.val = {
			alpha_dashboard_theme.button("s", " " .. " Search/Find file", "<CMD>Telescope find_files<CR>"),
			alpha_dashboard_theme.button("r", " " .. " Recent files", "<CMD>Telescope oldfiles <CR>"),
			alpha_dashboard_theme.button("g", " " .. " Find text", "<CMD>norm% ,g<CR>i"),
			alpha_dashboard_theme.button(
				"c",
				"⚙" .. "  Config",
				"<CMD>e ~/dotfiles/nvim/.config/nvim/init.lua<CR><CMD>cd %:p:h<CR>"
			),
			alpha_dashboard_theme.button("l", "" .. "  LazyGit", "<CMD>norm% ,lg<CR>"),
			alpha_dashboard_theme.button("q", " " .. " Quit", "<CMD>qa<CR>"),
		}
		alpha_dashboard_theme.section.header.opts.hl = "AlphaHeader"
		alpha_dashboard_theme.opts.layout[1].val = 6
		alpha.setup(alpha_dashboard_theme.config)
	end,
}
