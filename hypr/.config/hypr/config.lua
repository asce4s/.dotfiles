local home = os.getenv("HOME")

return {
	mainMod = "SUPER",
	hyprDir = home .. "/.config/hypr",
	libDir = home .. "/.config/hypr/lib",
	scriptsDir = home .. "/.config/hypr/scripts",
	rofiScriptsDir = home .. "/.config/rofi/scripts",
	iconsDir = home .. "/.config/swaync/icons",
	kbLayoutCache = home .. "/.cache/kb_layout",
	kbLayouts = { "us" },
	kbLayoutIgnorePatterns = {
		"%(avrcp%)",
		"Bluetooth Speaker",
	},
	touchpads = {
		"cust0001:00-04f3:30fa-touchpad",
		"etps/2-elantech-touchpad",
	},
	mice = {
		"keychron-keychron-q11-mouse",
		"keychron-keychron-q11-consumer-control-1",
		"cust0001:00-04f3:30fa-mouse",
		"mx-ergo-s-mouse",
	},
	dropdownClass = "com.supun.dropdown",
}
