return {
	"mason-org/mason-lspconfig.nvim",
	-- This plugin integrates mason.nvim with nvim-lspconfig.
	-- It ensures that the LSPs specified in ensure_installed are installed via mason.
	opts = {
		ensure_installed = {
			"html",
			"cssls",
			"tailwindcss",
			"lua_ls",
			"graphql",
			"emmet_ls",
			"prismals",
			"tsserver", -- Matches lspconfig.lua and mason's package name for typescript-language-server
			"pyright",
		},
		-- automatic_installation = true, -- You might want to enable this
	},
	dependencies = {
		{
			"mason-org/mason.nvim",
			opts = { -- Moved UI configuration here
				ui = {
					icons = {
						package_installed = "✓",
						package_pending = "➜",
						package_uninstalled = "✗",
					},
				},
			},
		},
		"neovim/nvim-lspconfig", -- Dependency for mason-lspconfig
		{
			"WhoIsSethDaniel/mason-tool-installer.nvim",
			opts = { -- Moved tool list here
				ensure_installed = {
					"prettier", -- prettier formatter
					"stylua", -- lua formatter
					"isort", -- python formatter
					"black", -- python formatter
					"pylint", -- python linter
					"eslint_d", -- js/ts linter
					"biome", -- js/ts formatter/linter
				},
			},
		},
	},
	-- The config function is no longer needed here as opts handle the setup for dependencies.
	-- Mason-lspconfig itself is configured by its opts.
}
