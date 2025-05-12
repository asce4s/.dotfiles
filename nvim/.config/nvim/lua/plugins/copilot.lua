return {
	"github/copilot.vim",
	enabled = false,
	config = function()
		vim.g.copilot_filetypes = {
			["gitcommit"] = true,
		}
	end,
}
