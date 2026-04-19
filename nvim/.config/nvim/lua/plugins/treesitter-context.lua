return {
	"nvim-treesitter/nvim-treesitter-context",
	branch = "master",
	event = "VeryLazy",
	config = function()
		require("treesitter-context").setup({
			enable = true, -- Enable this plugin (Can be disabled via command)
			max_lines = 0, -- How many lines the window should span. Values <= 0 mean no limit.
			trim_scope = "outer", -- Which context lines to discard if `max_lines` is exceeded. Options: 'inner', 'outer'
			mode = "cursor", -- Line used to calculate context. Choices: 'cursor', 'topline'
			separator = nil, -- Separator between context and content. String like '―'.
			zindex = 20, -- The Z-index of the context window
			on_attach = nil, -- (fun(buf: integer): boolean) return false to disable attaching
		})
	end,
}
