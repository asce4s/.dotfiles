return {
	"nvimtools/none-ls.nvim",
	enabled = false,
	event = { "BufReadPre", "BufNewFile" },
	dependencies = { "nvim-lua/plenary.nvim", "nvimtools/none-ls-extras.nvim" , "gbprod/none-ls-shellcheck.nvim"},
	config = function()
		local null_ls = require("null-ls")
		local formatting = null_ls.builtins.formatting
		local diagnostics = null_ls.builtins.diagnostics

		local function has_eslint_config(utils)
			return utils.root_has_file({
				".eslintrc",
				".eslintrc.cjs",
				".eslintrc.js",
				".eslintrc.json",
				"eslint.config.cjs",
				"eslint.config.js",
				"eslint.config.mjs",
			})
		end

	null_ls.setup({
		sources = {
			-- Diagnostics
			diagnostics.pylint,
			diagnostics.zsh,
			require("none-ls-shellcheck.diagnostics"),
			require("none-ls.diagnostics.eslint_d").with({ condition = has_eslint_config }),
			-- Code actions (need eslint diagnostics above for "fix all" to work)
			require("none-ls-shellcheck.code_actions"),
			require("none-ls.code_actions.eslint_d").with({ condition = has_eslint_config }),
		},
	})
	end,
}
