local DP1 = "2560x1440@144.00"
local HDMI_A_1 = "1920x1080@60.00"
local EDP1 = "1920x1080@144.00"

local function allOnMonitor(monitor)
	return {
		{ workspace = "1", monitor = monitor, layout = "master" },
		{ workspace = "2", monitor = monitor, layout = "scrolling" },
		{ workspace = "3", monitor = monitor, layout = "scrolling" },
		{ workspace = "4", monitor = monitor },
		{ workspace = "5", monitor = monitor },
		{ workspace = "6", monitor = monitor },
		{ workspace = "7", monitor = monitor, layout = "scrolling" },
		{ workspace = "8", monitor = monitor },
		{ workspace = "9", monitor = monitor },
		{ workspace = "10", monitor = monitor },
	}
end

return {
	docked = {
		monitors = {
			{ output = "eDP-1", disabled = true },
			{ output = "HDMI-A-1", mode = HDMI_A_1, position = "0x0", scale = 1, transform = 1 },
			{ output = "DP-1", mode = DP1, position = "1080x95", scale = 1, vrr = 1 },
			-- { output = "DP-1", mode = "1920x1080@100.09", position = "1920x0", scale = 1 },
		},
		workspaces = {
			{ workspace = "1", monitor = "DP-1", layout = "master" },
			{ workspace = "2", monitor = "DP-1", layout = "scrolling" },
			{ workspace = "3", monitor = "DP-1", layout = "scrolling" },
			{ workspace = "4", monitor = "DP-1" },
			{ workspace = "5", monitor = "DP-1" },
			{ workspace = "6", monitor = "DP-1" },
			{ workspace = "7", monitor = "HDMI-A-1", layout = "scrolling", layout_opts = { direction = "down" } },
			{ workspace = "8", monitor = "HDMI-A-1" },
			{ workspace = "9", monitor = "HDMI-A-1" },
			{ workspace = "10", monitor = "HDMI-A-1" },
		},
	},

	laptop = {
		monitors = {
			{ output = "eDP-1", mode = EDP1, position = "0x0", scale = 1 },
			{ output = "HDMI-A-1", disabled = true },
			{ output = "DP-1", disabled = true },
		},
		workspaces = allOnMonitor("eDP-1"),
	},

	external_hdmi = {
		monitors = {
			{ output = "eDP-1", disabled = true },
			{ output = "HDMI-A-1", mode = HDMI_A_1, position = "0x0", scale = 1 },
			{ output = "DP-1", disabled = true },
		},
		workspaces = allOnMonitor("HDMI-A-1"),
	},

	external_dp = {
		monitors = {
			{ output = "eDP-1", disabled = true },
			{ output = "HDMI-A-1", disabled = true },
			{ output = "DP-1", mode = DP1, position = "0x0", scale = 1 },
		},
		workspaces = allOnMonitor("DP-1"),
	},
}
