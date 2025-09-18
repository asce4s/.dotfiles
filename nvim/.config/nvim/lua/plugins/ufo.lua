return {
	"kevinhwang91/nvim-ufo",
	dependencies = {
		"kevinhwang91/promise-async",
	},
	event = "BufReadPost",
	config = function()
		-- Folding settings
		vim.o.foldcolumn = "1" -- show fold column
		vim.o.foldlevel = 99 -- keep folds open by default
		vim.o.foldlevelstart = 99
		vim.o.foldenable = true

		-- Use Treesitter + LSP as providers
		require("ufo").setup({
			provider_selector = function(_, _, _)
				return { "treesitter", "indent" }
			end,
		})

		-- Keymaps
		vim.keymap.set("n", "zR", require("ufo").openAllFolds, { desc = "Open all folds" })
		vim.keymap.set("n", "zM", require("ufo").closeAllFolds, { desc = "Close all folds" })
		vim.keymap.set("n", "zr", require("ufo").openFoldsExceptKinds, { desc = "Open folds except comments" })
		vim.keymap.set("n", "zm", require("ufo").closeFoldsWith, { desc = "Close folds with kind" })
		vim.keymap.set("n", "zp", function()
			local winid = require("ufo").peekFoldedLinesUnderCursor()
			if not winid then
				vim.lsp.buf.hover()
			end
		end, { desc = "Peek fold or hover" })
	end,
}
