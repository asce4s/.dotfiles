local config = require("config")
local terminal = os.getenv("TERMINAL") or "ghostty"
local dropdownClass = config.dropdownClass

hl.workspace_rule({
	workspace = "special:dropdown",
	on_created_empty = string.format("[float] uwsm app -- %s --class=%s", terminal, dropdownClass),
})

hl.window_rule({
	match = { class = "^" .. dropdownClass:gsub("%.", "%%.") .. "$" },
	float = true,
	size = { "100%", "35%" },
	move = { "0%", "65%" },
})

hl.bind(config.mainMod .. " + grave", hl.dsp.workspace.toggle_special("dropdown"))
