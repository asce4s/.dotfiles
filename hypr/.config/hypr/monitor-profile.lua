local profiles = require("profiles")

local STATE_FILE = "/tmp/hypr-monitor-profile-lua"
local DEBOUNCE_MS = 1000

local debounceTimer = nil

local function drmConnected(output)
	local cmd = string.format(
		"path=$(echo /sys/class/drm/card*-%s/status 2>/dev/null | head -n1); "
			.. '[ -f "$path" ] && cat "$path" || echo disconnected',
		output
	)
	local handle = io.popen(cmd)
	if not handle then
		return false
	end

	local status = handle:read("*a"):gsub("%s+", "")
	handle:close()
	return status == "connected"
end

local function detectProfile()
	local dp = drmConnected("DP-1")
	local hdmi = drmConnected("HDMI-A-1")

	if dp and hdmi then
		return "docked"
	elseif not dp and not hdmi then
		return "laptop"
	elseif dp then
		return "external_dp"
	else
		return "external_hdmi"
	end
end

local function getSavedProfile()
	local handle = io.open(STATE_FILE, "r")
	if not handle then
		return nil
	end

	local name = handle:read("*l")
	handle:close()
	return name
end

local function saveProfile(name)
	local handle = io.open(STATE_FILE, "w")
	if not handle then
		return
	end

	handle:write(name)
	handle:close()
end

local function applyProfile(name)
	local profile = profiles[name]
	if not profile then
		return
	end

	for _, spec in ipairs(profile.monitors) do
		hl.monitor(spec)
	end

	for _, rule in ipairs(profile.workspaces) do
		hl.workspace_rule(rule)
	end
end

local function detectAndApply()
	local name = detectProfile()
	applyProfile(name)
	saveProfile(name)
	return name
end

local function scheduleProfileReload()
	if debounceTimer then
		debounceTimer:set_enabled(false)
	end

	debounceTimer = hl.timer(function()
		local name = detectProfile()
		if name == getSavedProfile() then
			return
		end

		saveProfile(name)
		hl.exec_cmd("hyprctl reload")
	end, { timeout = DEBOUNCE_MS, type = "oneshot" })
end

detectAndApply()

hl.on("hyprland.start", function()
	detectAndApply()
end)

hl.on("monitor.added", scheduleProfileReload)
hl.on("monitor.removed", scheduleProfileReload)
