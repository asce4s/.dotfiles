-- Compatibility shim for plugins still using deprecated Neovim LSP helper.
if vim.lsp and vim.lsp.get_client_by_id then
	vim.lsp.get_buffers_by_client_id = function(client_id)
		local client = vim.lsp.get_client_by_id(client_id)
		return client and vim.tbl_keys(client.attached_buffers or {}) or {}
	end
end

require("core.options")
require("core.keymaps")
require("core.lazy")
