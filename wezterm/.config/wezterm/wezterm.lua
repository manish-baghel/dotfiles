local wezterm = require("wezterm")
local config = wezterm.config_builder()

config.default_prog = { "/usr/bin/fish", "-i" }

config.color_scheme = "Catppuccin Mocha"
config.window_background_opacity = 0.90

config.enable_scroll_bar = true
config.enable_tab_bar = false

return config
