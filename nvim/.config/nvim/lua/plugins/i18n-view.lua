return {
	"asce4s/i18n-view.nvim",
	-- dir = "~/projects/i18n-view.nvim",
	config = function()
		require("i18n-view").setup({
			locale = "en", -- default locale
			path = "public/locales", -- path to locale files (relative to cwd)
			verbose = false, -- show error messages
			prefix = "🌐 ", -- prefix for virtual text
			debounce_ms = 150, -- debounce delay
			max_text_length = 80, -- truncate long translations
			highlight = {
				fg = "#a9b1d6",
				bg = "#1a1b26",
			},
		})

		vim.keymap.set("n", "<leader>it", ":I18nToggle<CR>", { desc = "Toggle i18n view" })
		vim.keymap.set("n", "<leader>ir", ":I18nReload<CR>", { desc = "Reload i18n" })
		vim.keymap.set("n", "<leader>is", ":I18nStatus<CR>", { desc = "i18n status" })
		vim.keymap.set("n", "<leader>im", ":I18nDisplayMode<CR>", { desc = "Toggle display mode" })

		-- Or more explicit bindings
		vim.keymap.set("n", "<leader>io", ":I18nDisplayMode overlay<CR>", { desc = "Overlay mode" })
		vim.keymap.set("n", "<leader>ie", ":I18nDisplayMode eol<CR>", { desc = "EOL mode" })
	end,
}
