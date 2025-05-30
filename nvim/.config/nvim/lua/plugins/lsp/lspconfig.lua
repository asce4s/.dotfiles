return {
	"neovim/nvim-lspconfig",
	event = { "BufReadPre", "BufNewFile" },
	dependencies = {
		-- "hrsh7th/nvim-cmp", -- Core completion engine (Reverted)
		-- "hrsh7th/cmp-nvim-lsp", -- LSP source for nvim-cmp (Reverted)
		{ "antosha417/nvim-lsp-file-operations", config = true },
		{
			"folke/lazydev.nvim",
			ft = "lua", -- only load on lua files
			opts = {
				library = {
					-- See the configuration section for more details
					-- Load luvit types when the `vim.uv` word is found
					{ path = "${3rd}/luv/library", words = { "vim%.uv" } },
				},
			},
			dependencies = {
				{
					"saghen/blink.cmp",
					opts = { sources = { default = { "lazydev" } } },
				},
			},
		},
	},
	opts = {
		servers = {
			lua_ls = {
				settings = {
					Lua = {
						diagnostics = {
							globals = { "vim" },
						},
					},
				},
			},
			tsserver = {}, 
			html = {},
			cssls = {},
			tailwindcss = {},
			graphql = {},
			emmet_ls = {},
			prismals = {},
			pyright = {},
		},
	},
	config = function(_, opts)
		-- import lspconfig plugin
		local lspconfig = require("lspconfig")
		local keymap = vim.keymap -- for conciseness

		-- import lspconfig plugin
		local lspconfig = require("lspconfig")
		local keymap = vim.keymap -- for conciseness

		for server_name, server_config in pairs(opts.servers) do
			-- Ensure server_config is a table if it's coming from opts.servers
			local current_config = type(server_config) == "table" and server_config or {}
			-- Assign blink.cmp capabilities
			current_config.capabilities = require("blink.cmp").get_lsp_capabilities(current_config.capabilities)
			
			if lspconfig[server_name] and lspconfig[server_name].setup then
				lspconfig[server_name].setup(current_config)
			else
				vim.notify("LSP server '" .. server_name .. "' not found in lspconfig. Skipping setup.", vim.log.levels.WARN)
			end
		end

		vim.api.nvim_create_autocmd("LspAttach", {
			group = vim.api.nvim_create_augroup("UserLspConfig", {}),
			callback = function(ev)
				-- Buffer local mappings.
				-- See `:help vim.lsp.*` for documentation on any of the below functions
				local opts_l = { buffer = ev.buf, silent = true }

				-- set keybinds
				opts_l.desc = "Show LSP references"
				keymap.set("n", "gR", "<cmd>Telescope lsp_references<CR>", opts_l) -- show definition, references

				opts_l.desc = "Go to declaration"
				keymap.set("n", "gD", vim.lsp.buf.declaration, opts_l) -- go to declaration

				opts_l.desc = "Show LSP definitions"
				keymap.set("n", "gd", "<cmd>Telescope lsp_definitions<CR>", opts_l) -- show lsp definitions

				opts_l.desc = "Show LSP implementations"
				keymap.set("n", "gi", "<cmd>Telescope lsp_implementations<CR>", opts_l) -- show lsp implementations

				opts_l.desc = "Show LSP type definitions"
				keymap.set("n", "gt", "<cmd>Telescope lsp_type_definitions<CR>", opts_l) -- show lsp type definitions

				opts_l.desc = "See available code actions"
				keymap.set({ "n", "v" }, "<leader>ca", vim.lsp.buf.code_action, opts_l) -- see available code actions, in visual mode will apply to selection

				opts_l.desc = "Smart rename"
				keymap.set("n", "<leader>rn", vim.lsp.buf.rename, opts_l) -- smart rename

				opts_l.desc = "Show buffer diagnostics"
				keymap.set("n", "<leader>D", "<cmd>Telescope diagnostics bufnr=0<CR>", opts_l) -- show  diagnostics for file

				opts_l.desc = "Show line diagnostics"
				keymap.set("n", "<leader>d", vim.diagnostic.open_float, opts_l) -- show diagnostics for line

				opts_l.desc = "Go to previous diagnostic"
				keymap.set("n", "[d", function()
					vim.diagnostic.jump({ count = -1, float = true })
				end) -- jump to previous diagnostic in buffer

				opts_l.desc = "Go to next diagnostic"
				keymap.set("n", "]d", function()
					vim.diagnostic.jump({ count = 1, float = true })
				end) -- jump to next diagnostic in buffer

				opts_l.desc = "Show documentation for what is under cursor"
				keymap.set("n", "K", vim.lsp.buf.hover, opts_l) -- show documentation for what is under cursor

				opts_l.desc = "Restart LSP"
				keymap.set("n", "<leader>rs", ":LspRestart<CR>", opts_l) -- mapping to restart lsp if necessary
			end,
		})

		vim.diagnostic.config({
			signs = {
				text = {
					[vim.diagnostic.severity.ERROR] = " ",
					[vim.diagnostic.severity.WARN] = " ",
					[vim.diagnostic.severity.INFO] = "󰋼 ",
					[vim.diagnostic.severity.HINT] = "󰌵 ",
				},
				numhl = {
					[vim.diagnostic.severity.ERROR] = "",
					[vim.diagnostic.severity.WARN] = "",
					[vim.diagnostic.severity.HINT] = "",
					[vim.diagnostic.severity.INFO] = "",
				},
			},
		})
	end,
}
