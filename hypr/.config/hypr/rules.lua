-- Window tags

hl.window_rule({ match = { class = "^(zen-alpha|zen)$" }, tag = "+browser" })
hl.window_rule({ match = { class = "^(swaync-control-center|swaync-notification-window|swaync-client)$" }, tag = "+notif" })
hl.window_rule({ match = { class = "^ghostty$" }, tag = "+terminal" })
hl.window_rule({ match = { class = "^([Tt]hunar)$" }, tag = "+file-manager" })
hl.window_rule({ match = { class = "^cursor$" }, tag = "+projects" })
hl.window_rule({ match = { class = "^([Ss]team)$" }, tag = "+gamestore" })
hl.window_rule({ match = { class = "^(com.obsproject.Studio)$" }, tag = "+screenshare" })
hl.window_rule({ match = { class = "^(mpv|vlc)$" }, tag = "+multimedia_video" })

hl.window_rule({ match = { class = "^(pavucontrol|org.pulseaudio.pavucontrol|com.saivert.pwvucontrol)$" }, tag = "+settings" })
hl.window_rule({ match = { class = "^(qt5ct|qt6ct|[Yy]ad)$" }, tag = "+settings" })
hl.window_rule({ match = { class = "^(nm-applet|nm-connection-editor|blueman-manager)$" }, tag = "+settings" })
hl.window_rule({ match = { class = "^(org.kde.polkit-kde-authentication-agent-1)$" }, tag = "+settings" })
hl.window_rule({ match = { class = "^(file-roller|org.gnome.FileRoller)$" }, tag = "+settings" })
hl.window_rule({ match = { class = "^(xdg-desktop-portal-gtk)$" }, tag = "+settings" })

hl.window_rule({ match = { class = "^(gnome-system-monitor|org.gnome.SystemMonitor|io.missioncenter.MissionCenter)$" }, tag = "+viewer" })

-- Workspace assignment

hl.window_rule({ match = { class = "^(zen-alpha|zen)$" }, workspace = "1" })
hl.window_rule({ match = { class = "^cursor$" }, workspace = "3" })
hl.window_rule({ match = { tag = "gamestore*" }, workspace = "5" })
hl.window_rule({ match = { tag = "screenshare*" }, workspace = "4 silent" })
hl.window_rule({ match = { class = "^Slack$" }, workspace = "8 silent" })

-- Zen-specific (no opacity rules for browser/zen)

hl.window_rule({ match = { class = "^(zen-alpha|zen)$", fullscreen = true }, idle_inhibit = "always" })
hl.window_rule({ match = { class = "^(zen-alpha|zen)$", title = "^Extension:" }, float = true, center = true })

-- Position and floating

hl.window_rule({ match = { class = "[Tt]hunar", title = "negative:.*[Tt]hunar.*" }, float = true, center = true })
hl.window_rule({ match = { class = "^(pavucontrol|org.pulseaudio.pavucontrol|com.saivert.pwvucontrol)$" }, center = true })

hl.window_rule({
	match = { title = "^(Picture-in-Picture)$" },
	float = true,
	center = true,
	pin = true,
	keep_aspect_ratio = true,
	opacity = "0.95 0.75",
})
hl.window_rule({
	match = { class = "^(zen-alpha|zen)$", title = "^(Picture-in-Picture)$" },
	move = { "monitor_w*0.72", "monitor_h*0.07" },
})

hl.window_rule({ match = { title = "^(Authentication Required)$" }, float = true, center = true })
hl.window_rule({ match = { class = "^cursor$", title = "negative:.*[Cc]ursor.*" }, float = true })
hl.window_rule({ match = { class = "^([Ss]team)$", title = "negative:^([Ss]team)$" }, float = true })
hl.window_rule({
	match = { title = "^(Add Folder to Workspace)$" },
	float = true,
	size = { "monitor_w*0.7", "monitor_h*0.6" },
	center = true,
})
hl.window_rule({
	match = { title = "^(Save As)$" },
	float = true,
	size = { "monitor_w*0.7", "monitor_h*0.6" },
	center = true,
})
hl.window_rule({
	match = { initial_title = "^(Open Files)$" },
	float = true,
	size = { "monitor_w*0.7", "monitor_h*0.6" },
})

hl.window_rule({
	match = { tag = "settings*" },
	float = true,
	opacity = "0.8 0.7",
	size = { "monitor_w*0.7", "monitor_h*0.7" },
})
hl.window_rule({ match = { tag = "viewer*" }, float = true, opacity = "0.82 0.75" })
hl.window_rule({ match = { class = "^(mpv|com.github.rafostar.Clapper)$" }, float = true })
hl.window_rule({ match = { class = "^(org.gnome.Calculator)$", title = "^(Calculator)$" }, float = true })

-- Opacity (browser/zen intentionally excluded)

hl.window_rule({ match = { tag = "projects*" }, opacity = "0.9 0.8" })
hl.window_rule({ match = { tag = "file-manager*" }, opacity = "0.9 0.8" })
hl.window_rule({ match = { tag = "terminal*" }, opacity = "0.8 0.7" })
hl.window_rule({ match = { tag = "multimedia_video*" }, no_blur = true, opacity = "1.0" })

-- Layer rules

hl.layer_rule({ match = { namespace = "rofi" }, blur = true, ignore_alpha = 0.5 })
hl.layer_rule({ match = { namespace = "notifications" }, blur = true, ignore_alpha = 0.5 })
