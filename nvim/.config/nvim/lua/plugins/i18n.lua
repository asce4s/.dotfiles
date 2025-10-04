return {
	"yelog/i18n.nvim",
	enabled = false,
	dependencies = {
		"ibhagwan/fzf-lua",
		"nvim-treesitter/nvim-treesitter",
	},
	config = function()
		require("i18n").setup({
			-- Locales to parse; first is the default locale
			-- Use I18nNextLocale command to switch the default locale in real time
			locales = { "en", "zh" },
			-- sources can be string or table { pattern = "...", prefix = "..." }
			sources = {
				"src/locales/{locales}.json",
				{ pattern = "public/locales/{locales}/{module}.json", prefix = "{module}:" },
				-- { pattern = "src/views/{bu}/locales/lang/{locales}/{module}.ts", prefix = "{bu}.{module}." },
			},
		})
	end,
}
