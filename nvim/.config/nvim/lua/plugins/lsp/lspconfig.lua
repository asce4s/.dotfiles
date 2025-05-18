return {
	"neovim/nvim-lspconfig",
	event = { "BufReadPre", "BufNewFile" },
	dependencies = {
		--	"hrsh7th/cmp-nvim-lsp",
		{ "saghen/blink.cmp" },
		{ "antosha417/nvim-lsp-file-operations", config = true },
		{ "folke/neodev.nvim", opts = {} },
	},
	opts = {
		servers = {
			lua_ls = {},
			ts_ls = {},
		},
	},
	config = function(_, opts)
		-- import lspconfig plugin
		local lspconfig = require("lspconfig")
		lspconfig.lua_ls.setup({ settings = { diagnostics = { globals = { "vim" } } } })
		local keymap = vim.keymap -- for conciseness

		for server, config in pairs(opts.servers) do
			-- passing config.capabilities to blink.cmp merges with the capabilities in your
			-- `opts[server].capabilities, if you've defined it
			config.capabilities = require("blink.cmp").get_lsp_capabilities(config.capabilities)
			lspconfig[server].setup(config)
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
				keymap.set("n", "[d", vim.diagnostic.goto_prev, opts_l) -- jump to previous diagnostic in buffer

				opts_l.desc = "Go to next diagnostic"
				keymap.set("n", "]d", vim.diagnostic.goto_next, opts_l) -- jump to next diagnostic in buffer

				opts_l.desc = "Show documentation for what is under cursor"
				keymap.set("n", "K", vim.lsp.buf.hover, opts_l) -- show documentation for what is under cursor

				opts_l.desc = "Restart LSP"
				keymap.set("n", "<leader>rs", ":LspRestart<CR>", opts_l) -- mapping to restart lsp if necessary
			end,
		})

		-- used to enable autocompletion (assign to every lsp server config)

		-- local signs = { Error = " ", Warn = " ", Hint = "󰠠 ", Info = " " }
		-- for type, icon in pairs(signs) do
		-- 	local hl = "DiagnosticSign" .. type
		-- 	vim.fn.sign_define(hl, { text = icon, texthl = hl, numhl = "" })
		-- end
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
