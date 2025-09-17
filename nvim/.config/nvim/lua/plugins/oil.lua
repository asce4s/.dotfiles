return {
	"stevearc/oil.nvim",
	opts = {
		default_file_explorer = true, -- replace netrw
	},
	dependencies = { "nvim-tree/nvim-web-devicons" },
	config = function(_, opts)
		require("oil").setup(opts)

		-- Auto-open Oil if starting nvim without a file
		vim.api.nvim_create_autocmd("VimEnter", {
			callback = function()
				local arg = vim.fn.argv(0)
				if arg == "" or vim.fn.isdirectory(arg) == 1 then
					require("oil").open()
				end
			end,
		})
	end,
}
