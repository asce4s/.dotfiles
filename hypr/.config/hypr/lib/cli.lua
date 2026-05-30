local M = {}

M.iconsDir = os.getenv("HOME") .. "/.config/swaync/icons"

function M.capture(cmd)
	local handle = io.popen(cmd .. " 2>/dev/null")
	if not handle then
		return ""
	end
	local out = handle:read("*a") or ""
	handle:close()
	return out:gsub("%s+$", "")
end

function M.run(cmd)
	return os.execute(cmd)
end

function M.notify(body, summary, opts)
	opts = opts or {}
	local args = { "notify-send", "-e", "-u", opts.urgency or "low" }
	if opts.icon then
		table.insert(args, "-i")
		table.insert(args, opts.icon)
	end
	if opts.value then
		table.insert(args, "-h")
		table.insert(args, "int:value:" .. opts.value)
	end
	if opts.sync then
		table.insert(args, "-h")
		table.insert(args, "string:x-canonical-private-synchronous:" .. opts.sync)
	end
	table.insert(args, summary or "")
	table.insert(args, body or "")
	M.run(table.concat(args, " "))
end

return M
