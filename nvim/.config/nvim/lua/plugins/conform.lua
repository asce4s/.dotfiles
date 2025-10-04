return {
	"stevearc/conform.nvim",
	event = { "BufReadPre", "BufNewFile" },
	cmd = { "ConformInfo" },
	keys = {
		{
			"<leader>f",
			function()
				require("conform").format({ async = true, lsp_format = "fallback" })
			end,
			mode = "",
			desc = "[F]ormat buffer",
		},
	},
	opts = function()
		-- Cache for formatter selection per root directory
		local formatter_cache = {}

		-- Helper function to select formatter based on project config
		local function select_js_formatter(bufnr)
			-- Get the root directory of the current buffer
			local root_dir = vim.fs.root(bufnr, { "package.json", ".git" })
			if not root_dir then
				root_dir = vim.fn.getcwd()
			end

			-- Check cache first
			if formatter_cache[root_dir] then
				return formatter_cache[root_dir]
			end

			-- Check if biome config exists
			local has_biome = vim.uv.fs_stat(root_dir .. "/biome.json")
				or vim.uv.fs_stat(root_dir .. "/biome.jsonc")

			local formatters
			if has_biome then
				formatters = { "biome" }
			else
				formatters = { "prettierd", "prettier", stop_after_first = true }
			end

			-- Cache the result
			formatter_cache[root_dir] = formatters
			return formatters
		end

		return {
			notify_on_error = false,
			format_on_save = function(bufnr)
				local disable_filetypes = { c = true, cpp = true }
				if disable_filetypes[vim.bo[bufnr].filetype] then
					return nil
				else
					return {
						timeout_ms = 500,
						lsp_format = "fallback",
					}
				end
			end,
			formatters_by_ft = {
				lua = { "stylua" },
				python = { "black" },

				-- Use conditional logic for JS/TS/JSON
				javascript = select_js_formatter,
				javascriptreact = select_js_formatter,
				typescript = select_js_formatter,
				typescriptreact = select_js_formatter,
				json = select_js_formatter,
				jsonc = select_js_formatter,

				markdown = { "prettierd", "prettier", stop_after_first = true },
				yaml = { "prettierd", "prettier", stop_after_first = true },
				html = { "prettierd", "prettier", stop_after_first = true },
				css = { "prettierd", "prettier", stop_after_first = true },
				scss = { "prettierd", "prettier", stop_after_first = true },

				sh = { "shfmt" },
				bash = { "shfmt" },
				zsh = { "shfmt" },
				go = { "goimports", "gofmt" },
				rust = { "rustfmt" },
			},
		}
	end,
}
