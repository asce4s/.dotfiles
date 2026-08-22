local config = require("config")
local mainMod = config.mainMod
local libDir = config.libDir
local scriptsDir = config.scriptsDir

-- System
hl.bind("SUPER + Q", hl.dsp.window.close())
hl.bind("SUPER + SHIFT + R", hl.dsp.exec_cmd("hyprctl reload"))

-- Switch / move workspaces with mainMod + [0-9]
for ws = 1, 10 do
	local key = "code:" .. (9 + ws)
	hl.bind(mainMod .. " + " .. key, hl.dsp.focus({ workspace = ws }))
	hl.bind(mainMod .. " + SHIFT + " .. key, hl.dsp.window.move({ workspace = ws, follow = true }))
	hl.bind(mainMod .. " + CTRL + " .. key, hl.dsp.window.move({ workspace = ws, follow = false }))
end

hl.bind(mainMod .. " + SHIFT + bracketleft", hl.dsp.window.move({ workspace = "-1", follow = true }))
hl.bind(mainMod .. " + SHIFT + bracketright", hl.dsp.window.move({ workspace = "+1", follow = true }))
hl.bind(mainMod .. " + CTRL + bracketleft", hl.dsp.window.move({ workspace = "-1", follow = false }))
hl.bind(mainMod .. " + CTRL + bracketright", hl.dsp.window.move({ workspace = "+1", follow = false }))

-- Scroll through existing workspaces with mainMod + scroll
hl.bind(mainMod .. " + mouse_down", hl.dsp.focus({ workspace = "e+1" }))
hl.bind(mainMod .. " + mouse_up", hl.dsp.focus({ workspace = "e-1" }))
hl.bind(mainMod .. " + period", hl.dsp.focus({ workspace = "e+1" }))
hl.bind(mainMod .. " + comma", hl.dsp.focus({ workspace = "e-1" }))

-- Move/resize windows with mainMod + LMB/RMB and dragging
hl.bind(mainMod .. " + mouse:272", hl.dsp.window.drag(), { mouse = true })
hl.bind(mainMod .. " + mouse:273", hl.dsp.window.resize(), { mouse = true })

-- Focus movement
hl.bind("SUPER + H", hl.dsp.focus({ direction = "l" }))
hl.bind("SUPER + L", hl.dsp.focus({ direction = "r" }))
hl.bind("SUPER + K", hl.dsp.focus({ direction = "u" }))
hl.bind("SUPER + J", hl.dsp.focus({ direction = "d" }))

-- Window resizing
hl.bind("SUPER + CTRL + H", hl.dsp.window.resize({ x = -20, y = 0, relative = true }), { repeating = true })
hl.bind("SUPER + CTRL + L", hl.dsp.window.resize({ x = 20, y = 0, relative = true }), { repeating = true })
hl.bind("SUPER + CTRL + K", hl.dsp.window.resize({ x = 0, y = -20, relative = true }), { repeating = true })
hl.bind("SUPER + CTRL + J", hl.dsp.window.resize({ x = 0, y = 20, relative = true }), { repeating = true })

-- Window swap
hl.bind("SUPER + LEFT", hl.dsp.window.swap({ direction = "l" }))
hl.bind("SUPER + RIGHT", hl.dsp.window.swap({ direction = "r" }))
hl.bind("SUPER + UP", hl.dsp.window.swap({ direction = "u" }))
hl.bind("SUPER + DOWN", hl.dsp.window.swap({ direction = "d" }))

-- Scroll layout
hl.bind("ALT + period", hl.dsp.layout("move +col"))
hl.bind("ALT + comma", hl.dsp.layout("move -col"))
hl.bind("ALT + SHIFT + period", hl.dsp.layout("swapcol r"))
hl.bind("ALT + SHIFT + comma", hl.dsp.layout("swapcol l"))
hl.bind("ALT + equal", hl.dsp.layout("colresize +conf"))
hl.bind("ALT + minus", hl.dsp.layout("colresize -conf"))
hl.bind("ALT + F1", hl.dsp.layout("fit active"))
hl.bind("ALT + F2", hl.dsp.layout("fit visible"))
hl.bind("ALT + F3", hl.dsp.layout("fit all"))
hl.bind("ALT + P", hl.dsp.layout("promote"))
hl.bind("ALT + F5", hl.dsp.layout("togglefit"))

-- Common shortcuts
hl.bind(
	mainMod .. " + SPACE",
	hl.dsp.exec_cmd("pkill rofi || true && uwsm app -- " .. config.rofiScriptsDir .. "/launcher_t1")
)
hl.bind(mainMod .. " + B", hl.dsp.exec_cmd('uwsm app -- xdg-open "https://"'))
hl.bind(mainMod .. " + SHIFT + V", hl.dsp.exec_cmd("pkill rofi || true && " .. config.rofiScriptsDir .. "/cliphist"))
hl.bind(mainMod .. " + Return", function()
	hl.dispatch(hl.dsp.exec_cmd("uwsm app -- " .. os.getenv("TERMINAL")))
end)
hl.bind(mainMod .. " + E", function()
	hl.dispatch(hl.dsp.exec_cmd("uwsm app -- " .. os.getenv("FILE_MANAGER")))
end)
hl.bind(mainMod .. " + slash", hl.dsp.exec_cmd("uwsm app -- " .. os.getenv("TERMINAL")))

hl.bind("ALT + CTRL + L", hl.dsp.exec_cmd("hyprlock"))
hl.bind("ALT + CTRL + Return", hl.dsp.exec_cmd("uwsm app -- " .. config.rofiScriptsDir .. "/powermenu_t1"))

hl.bind(mainMod .. " + SHIFT + F", hl.dsp.window.fullscreen({ action = "toggle" }))
hl.bind(mainMod .. " + CTRL + F", hl.dsp.window.fullscreen({ mode = "maximized", action = "toggle" }))
hl.bind(mainMod .. " + V", hl.dsp.window.float({ action = "toggle" }))
hl.bind(mainMod .. " + ALT + SPACE", hl.dsp.exec_raw("hyprctl dispatch workspaceopt allfloat"))
hl.bind(mainMod .. " + SHIFT + Return", function()
	hl.dispatch(hl.dsp.exec_cmd(os.getenv("TERMINAL"), {
		float = true,
		move = { "15%", "5%" },
		size = { "70%", "60%" },
	}))
end)

-- Desktop zooming / magnifier
hl.bind(
	mainMod .. " + ALT + mouse_down",
	hl.dsp.exec_cmd(
		[[hyprctl keyword cursor:zoom_factor "$(hyprctl getoption cursor:zoom_factor | awk 'NR==1 {factor = $2; if (factor < 1) {factor = 1}; print factor * 2.0}')"]]
	)
)
hl.bind(
	mainMod .. " + ALT + mouse_up",
	hl.dsp.exec_cmd(
		[[hyprctl keyword cursor:zoom_factor "$(hyprctl getoption cursor:zoom_factor | awk 'NR==1 {factor = $2; if (factor < 1) {factor = 1}; print factor / 2.0}')"]]
	)
)

hl.bind(mainMod .. " + F", hl.dsp.exec_cmd('grim -g "$(slurp)" - | satty -f - --early-exit --copy-command=wl-copy'))

-- Wallpaper
hl.bind(mainMod .. " + W", hl.dsp.exec_cmd("WGPU_BACKEND=gl wallity"))
hl.bind(mainMod .. " + SHIFT + W", hl.dsp.exec_cmd(config.rofiScriptsDir .. "/wallpaper"))

-- Volume / power
hl.bind(
	"XF86AudioRaiseVolume",
	hl.dsp.exec_cmd("lua " .. libDir .. "/volume_cli.lua --inc"),
	{ locked = true, repeating = true }
)
hl.bind(
	"XF86AudioLowerVolume",
	hl.dsp.exec_cmd("lua " .. libDir .. "/volume_cli.lua --dec"),
	{ locked = true, repeating = true }
)
hl.bind("XF86AudioMicMute", hl.dsp.exec_cmd("lua " .. libDir .. "/volume_cli.lua --toggle-mic"), { locked = true })
hl.bind("XF86AudioMute", hl.dsp.exec_cmd("lua " .. libDir .. "/volume_cli.lua --toggle"), { locked = true })
hl.bind("XF86Sleep", hl.dsp.exec_cmd("systemctl suspend"), { locked = true })
hl.bind("XF86RFKill", hl.dsp.exec_cmd(scriptsDir .. "/AirplaneMode.sh"), { locked = true })

-- Monitor power (DPMS toggle)
hl.bind(mainMod .. " + ALT + 1", hl.dsp.dpms({ action = "toggle", monitor = "eDP-1" }))
hl.bind(mainMod .. " + ALT + 2", hl.dsp.dpms({ action = "toggle", monitor = "HDMI-A-1" }))
hl.bind(mainMod .. " + ALT + 3", hl.dsp.dpms({ action = "toggle", monitor = "DP-1" }))
hl.bind(mainMod .. " + ALT + 0", hl.dsp.dpms({ action = "toggle" }))

-- Media controls (no XF86AudioPlayPause — not a valid xkbcommon keysym)
hl.bind("XF86AudioPause", hl.dsp.exec_cmd("lua " .. libDir .. "/media_cli.lua --pause"), { locked = true })
hl.bind("XF86AudioPlay", hl.dsp.exec_cmd("lua " .. libDir .. "/media_cli.lua --pause"), { locked = true })
hl.bind("XF86AudioNext", hl.dsp.exec_cmd("lua " .. libDir .. "/media_cli.lua --nxt"), { locked = true })
hl.bind("XF86AudioPrev", hl.dsp.exec_cmd("lua " .. libDir .. "/media_cli.lua --prv"), { locked = true })
hl.bind("XF86AudioStop", hl.dsp.exec_cmd("lua " .. libDir .. "/media_cli.lua --stop"), { locked = true })
