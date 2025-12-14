return {
	"stevearc/oil.nvim",
	opts = {
		default_file_explorer = true, -- replace netrw
		view_options = {
			-- Show files and directories that start with "."
			show_hidden = true,
		},
	},
	dependencies = { "nvim-tree/nvim-web-devicons" },
	config = function(_, opts)
		require("oil").setup(opts)
		vim.keymap.set("n", "<leader>ee", function()
			-- require('oil').open(vim.fn.getcwd())
			require("oil").open_float(vim.fn.getcwd())
		end, { noremap = true, silent = true })

		vim.keymap.set("n", "<leader>ec", function()
			require("oil").open_float()
		end, { noremap = true, silent = true })

		-- Auto-open Oil if starting nvim without a file
		-- vim.api.nvim_create_autocmd("VimEnter", {
		-- 	callback = function()
		-- 		local arg = vim.fn.argv(0)
		-- 		if arg == "" or vim.fn.isdirectory(arg) == 1 then
		-- 			require("oil").open()
		-- 		end
		-- 	end,
		-- })
	end,
}
