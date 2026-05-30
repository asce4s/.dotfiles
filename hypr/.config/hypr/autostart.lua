hl.on("hyprland.start", function()
	hl.exec_cmd("dbus-update-activation-environment --systemd WAYLAND_DISPLAY XDG_CURRENT_DESKTOP")
	hl.exec_cmd("systemctl --user import-environment WAYLAND_DISPLAY XDG_CURRENT_DESKTOP")

	hl.exec_cmd("awww-daemon")

	hl.exec_cmd("uwsm app -- nm-applet --indicator")
	hl.exec_cmd("uwsm app -- swaync")
	hl.exec_cmd("uwsm app -- blueman-applet")

	hl.exec_cmd("uwsm app -- wl-paste --type text --watch cliphist store")
	hl.exec_cmd("uwsm app -- wl-paste --type image --watch cliphist store")

	hl.exec_cmd("gnome-keyring-daemon --start --components=secrets")
	hl.exec_cmd("uwsm app -- zen-browser", { workspace = "1 silent" })

	hl.exec_cmd("uwsm app -- hypridle")
end)
