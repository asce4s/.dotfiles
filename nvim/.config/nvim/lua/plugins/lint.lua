return {
	{ -- Linting
		"mfussenegger/nvim-lint",
		event = { "BufReadPre", "BufNewFile" },
		config = function()
			local lint = require("lint")

		-- Define available linters (ESLint handled by LSP)
		lint.linters_by_ft = {
			markdown = { "markdownlint" },
			python = { "pylint" },
			-- Note: JS/TS linting is handled by ESLint LSP
		}

		-- Autocmd to run linting
		local lint_augroup = vim.api.nvim_create_augroup("lint", { clear = true })
		vim.api.nvim_create_autocmd({ "BufEnter", "BufWritePost", "InsertLeave" }, {
			group = lint_augroup,
			callback = function()
				if vim.bo.modifiable then
					lint.try_lint()
				end
			end,
		})
		end,
	},
}
