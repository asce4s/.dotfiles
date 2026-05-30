-- Static visual settings (border colors come from wallust/wallust-hyprland.lua)

local config = require("config")

hl.config({
	input = {
		kb_layout = table.concat(config.kbLayouts, ","),
	},
	general = {
		gaps_in = 2,
		gaps_out = 5,
		border_size = 2,
		layout = "dwindle",
	},

	scrolling = {
		fullscreen_on_one_column = true,
		column_width = 0.7,
		focus_fit_method = 1,
		follow_focus = true,
		follow_min_visible = 0.4,
		explicit_column_widths = "0.333, 0.5, 0.667, 1.0",
		direction = "right",
	},

	animations = {
		enabled = false,
	},
})

-- Animation curves and presets (used when animations.enabled = true)
hl.curve("overshoot", { type = "bezier", points = { { 0.05, 0.9 }, { 0.1, 1.1 } } })
hl.curve("smoothOut", { type = "bezier", points = { { 0.16, 1.0 }, { 0.2, 1.0 } } })
hl.curve("smoothIn", { type = "bezier", points = { { 0.1, 0.0 }, { 0.2, 1.0 } } })

hl.animation({ leaf = "windows", enabled = true, speed = 5, bezier = "overshoot", style = "popin 80%" })
hl.animation({ leaf = "windowsIn", enabled = true, speed = 5, bezier = "smoothOut", style = "popin 80%" })
hl.animation({ leaf = "windowsOut", enabled = true, speed = 5, bezier = "smoothIn", style = "popin 80%" })
hl.animation({ leaf = "workspaces", enabled = true, speed = 4, bezier = "smoothOut" })
hl.animation({ leaf = "fade", enabled = true, speed = 6, bezier = "smoothOut" })
hl.animation({ leaf = "fadeIn", enabled = true, speed = 6, bezier = "smoothOut" })
hl.animation({ leaf = "fadeOut", enabled = true, speed = 5, bezier = "smoothIn" })
hl.animation({ leaf = "windowsMove", enabled = true, speed = 4, bezier = "smoothOut" })
