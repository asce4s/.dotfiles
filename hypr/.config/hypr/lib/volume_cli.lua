#!/usr/bin/env lua

local cli = dofile(os.getenv("HOME") .. "/.config/hypr/lib/cli.lua")

local step = 5

local function get_volume()
	local out = cli.capture("pamixer --get-volume")
	local volume = tonumber(out) or 0
	if volume == 0 then
		return "Muted", 0
	end
	return tostring(volume) .. " %", volume
end

local function get_icon(volume)
	if volume == 0 then
		return cli.iconsDir .. "/volume-mute.png"
	elseif volume <= 30 then
		return cli.iconsDir .. "/volume-low.png"
	elseif volume <= 60 then
		return cli.iconsDir .. "/volume-mid.png"
	end
	return cli.iconsDir .. "/volume-high.png"
end

local function notify_volume()
	local label, volume = get_volume()
	if label == "Muted" then
		cli.notify(" Muted", " Volume:", {
			icon = cli.iconsDir .. "/volume-mute.png",
			sync = "volume_notif",
		})
	else
		cli.notify(" " .. label, " Volume Level:", {
			icon = get_icon(volume),
			value = tostring(volume),
			sync = "volume_notif",
		})
	end
end

local function toggle_mute()
	if cli.capture("pamixer --get-mute") == "true" then
		cli.run("pamixer -u")
		cli.notify(" Switched ON", " Volume:", { icon = get_icon(tonumber(cli.capture("pamixer --get-volume")) or 50) })
	else
		cli.run("pamixer -m")
		cli.notify("", " Mute", { icon = cli.iconsDir .. "/volume-mute.png" })
	end
end

local function inc_volume()
	if cli.capture("pamixer --get-mute") == "true" then
		toggle_mute()
	else
		cli.run("pamixer -i " .. step .. " --allow-boost --set-limit 150")
		notify_volume()
	end
end

local function dec_volume()
	if cli.capture("pamixer --get-mute") == "true" then
		toggle_mute()
	else
		cli.run("pamixer -d " .. step)
		notify_volume()
	end
end

local function get_mic_volume()
	local out = cli.capture("pamixer --default-source --get-volume")
	local volume = tonumber(out) or 0
	if volume == 0 then
		return "Muted", 0
	end
	return volume .. " %", volume
end

local function get_mic_icon(volume)
	if volume == 0 then
		return cli.iconsDir .. "/microphone-mute.png"
	end
	return cli.iconsDir .. "/microphone.png"
end

local function notify_mic()
	local label, volume = get_mic_volume()
	cli.notify(" " .. label, " Mic Level:", {
		icon = get_mic_icon(volume),
		value = tostring(volume),
		sync = "volume_notif",
	})
end

local function toggle_mic()
	if cli.capture("pamixer --default-source --get-mute") == "true" then
		cli.run("pamixer --default-source -u")
		cli.notify(" Switched ON", " Microphone:", { icon = cli.iconsDir .. "/microphone.png" })
	else
		cli.run("pamixer --default-source -m")
		cli.notify(" Switched OFF", " Microphone:", { icon = cli.iconsDir .. "/microphone-mute.png" })
	end
end

local function inc_mic_volume()
	if cli.capture("pamixer --default-source --get-mute") == "true" then
		toggle_mic()
	else
		cli.run("pamixer --default-source -i " .. step)
		notify_mic()
	end
end

local function dec_mic_volume()
	if cli.capture("pamixer --default-source --get-mute") == "true" then
		toggle_mic()
	else
		cli.run("pamixer --default-source -d " .. step)
		notify_mic()
	end
end

local actions = {
	["--get"] = function()
		print((get_volume()))
	end,
	["--inc"] = inc_volume,
	["--dec"] = dec_volume,
	["--toggle"] = toggle_mute,
	["--toggle-mic"] = toggle_mic,
	["--get-icon"] = function()
		local _, volume = get_volume()
		print(get_icon(volume))
	end,
	["--get-mic-icon"] = function()
		local _, volume = get_mic_volume()
		print(get_mic_icon(volume))
	end,
	["--mic-inc"] = inc_mic_volume,
	["--mic-dec"] = dec_mic_volume,
}

local action = arg[1]
if actions[action] then
	actions[action]()
else
	print((get_volume()))
end
