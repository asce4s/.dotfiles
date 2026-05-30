#!/usr/bin/env lua

local cli = dofile(os.getenv("HOME") .. "/.config/hypr/lib/cli.lua")

local music_icon = cli.iconsDir .. "/music.png"

local function show_music_notification()
	local status = cli.capture("playerctl status")
	if status == "Playing" then
		local title = cli.capture("playerctl metadata title")
		local artist = cli.capture("playerctl metadata artist")
		cli.notify(title .. " by " .. artist, "Now Playing:", { icon = music_icon })
	elseif status == "Paused" then
		cli.notify(" Paused", " Playback:", { icon = music_icon })
	end
end

local actions = {
	["--nxt"] = function()
		cli.run("playerctl next")
		show_music_notification()
	end,
	["--prv"] = function()
		cli.run("playerctl previous")
		show_music_notification()
	end,
	["--pause"] = function()
		cli.run("playerctl play-pause")
		show_music_notification()
	end,
	["--stop"] = function()
		cli.run("playerctl stop")
		cli.notify(" Stopped", " Playback:", { icon = music_icon })
	end,
}

local action = arg[1]
if actions[action] then
	actions[action]()
else
	io.stderr:write("Usage: media_cli.lua [--nxt|--prv|--pause|--stop]\n")
	os.exit(1)
end
