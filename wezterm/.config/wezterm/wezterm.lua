local wezterm = require("wezterm")
local config = wezterm.config_builder()

config.default_prog = { "/usr/bin/fish" }

config.color_scheme = "Catppuccin Mocha"
config.window_background_opacity = 1.0

config.enable_scroll_bar = false
config.enable_tab_bar = false

config.adjust_window_size_when_changing_font_size = false
config.window_padding = {
	left = 0,
	right = 0,
	top = 6,
	bottom = 0,
}

return config
