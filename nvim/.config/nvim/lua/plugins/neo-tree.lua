return {
	"nvim-neo-tree/neo-tree.nvim",
	branch = "v3.x",
	dependencies = {
		"nvim-lua/plenary.nvim",
		"nvim-tree/nvim-web-devicons", -- optional
		"MunifTanjim/nui.nvim",
	},
	keys = {
		{ "<leader>et", ":Neotree toggle float<CR>", desc = "Toggle Neo-tree (float)" },
	},
	config = function()
		require("neo-tree").setup({
			filesystem = {
				hijack_netrw_behavior = "disabled", -- don't replace netrw
			},
			window = {
				position = "float", -- always float
			},
		})
	end,
}
