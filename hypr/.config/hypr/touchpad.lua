local config = require("config")

local status_file = os.getenv("XDG_RUNTIME_DIR") .. "/touchpad.status"

local function read_state()
	local file = io.open(status_file, "r")
	if not file then
		return true
	end
	local state = file:read("*l")
	file:close()
	return state == "true"
end

local function write_state(enabled)
	local file = io.open(status_file, "w")
	if not file then
		return
	end
	file:write(enabled and "true" or "false")
	file:close()
end

local function apply_state(enabled)
	for _, name in ipairs(config.touchpads) do
		hl.device({ name = name, enabled = enabled })
	end
end

local function notify(enabled)
	hl.exec_cmd(string.format(
		"notify-send -u low 'Touchpad' '%s'",
		enabled and "Enabled" or "Disabled"
	))
end

local function toggle()
	local enabled = not read_state()
	apply_state(enabled)
	write_state(enabled)
	notify(enabled)
end

apply_state(read_state())

hl.bind(config.mainMod .. " + SHIFT + T", toggle)
