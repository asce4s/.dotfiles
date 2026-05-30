local config = require("config")

math.randomseed(os.time())

local function random_color()
	return string.format("0xff%06x", math.random(0, 0xFFFFFF))
end

local function apply_rainbow()
	local colors = {}
	for _ = 1, 10 do
		colors[#colors + 1] = random_color()
	end
	hl.config({
		general = {
			col = {
				active_border = table.concat(colors, " ") .. " 270deg",
			},
		},
	})
end

local timer = hl.timer(apply_rainbow, { timeout = 100, type = "repeat" })
timer:set_enabled(false)

hl.bind(config.mainMod .. " + SHIFT + B", function()
	timer:set_enabled(not timer:is_enabled())
end)
