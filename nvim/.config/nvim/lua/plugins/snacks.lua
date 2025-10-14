return {
	"folke/snacks.nvim",
	priority = 1000,
	lazy = false,
	---@type snacks.Config
	opts = {
		bigfile = { enabled = true },
		dashboard = { enabled = true },
		explorer = {
			enabled = true,
			replace_netrw = false,
			open_on_start = false,
			layout = {
				position = "float", -- makes it full screen
				width = 1.0, -- full width
				height = 1.0, -- full height
			},
		},
		indent = { enabled = true },
		input = { enabled = true },
		notifier = {
			enabled = true,
			timeout = 3000,
		},
		picker = { enabled = false },
		quickfile = { enabled = true },
		scope = { enabled = false },
		scroll = { enabled = true },
		statuscolumn = { enabled = false },
		words = { enabled = true },
		styles = {
			notification = {
				-- wo = { wrap = true } -- Wrap notifications
			},
		},
		image = {
			enabled = true,
		},
	},
	keys = {
		{
			"<leader>et",
			function()
				Snacks.explorer()
			end,
			desc = "File Explorer",
		},
	},
}
