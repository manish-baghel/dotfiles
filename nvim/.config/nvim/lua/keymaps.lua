local utils = require("utils")
local M = {}

M.setup = function()
	-- Keymaps for better default experience
	vim.keymap.set("n", "<leader>w", ":w<cr>", { desc = "Save file" })
	vim.keymap.set({ "n", "v" }, "<Space>", "<Nop>", { silent = true })

	-- Remap for dealing with word wrap
	vim.keymap.set("n", "k", "v:count == 0 ? 'gk' : 'k'", { expr = true, silent = true })
	vim.keymap.set("n", "j", "v:count == 0 ? 'gj' : 'j'", { expr = true, silent = true })

	-- Diagnostic keymaps
	vim.keymap.set("n", "[d", vim.diagnostic.goto_prev, { desc = "Go to previous diagnostic message" })
	vim.keymap.set("n", "]d", vim.diagnostic.goto_next, { desc = "Go to next diagnostic message" })
	vim.keymap.set("n", "<space>e", vim.diagnostic.open_float, { desc = "Open floating diagnostic message" })
	vim.keymap.set("n", "<space>q", vim.diagnostic.setloclist, { desc = "Open diagnostics list" })

	vim.keymap.set("t", "<esc><esc>", "<c-\\><c-n>", { desc = "Escape Escape exits terminal mode" })

	vim.keymap.set(
		"n",
		"<leader>e",
		"<CMD>e ~/dotfiles/nvim/.config/nvim/init.lua<CR><CMD>cd %:p:h<CR>",
		{ silent = true }
	)
	vim.keymap.set("n", "<leader><CR>", "<CMD>noh<CR>", { desc = "clear highlights" })
	vim.keymap.set("n", "<leader>/", "<CMD>bnext<CR>")
	vim.keymap.set("n", "<leader>.", "<CMD>bprevious<CR>")

	vim.keymap.set("n", "<leader>q", "<CMD>e ~/buffer<CR>")

	vim.keymap.set("i", "<C-u>", "<ESC>O<BS><TAB>")

	vim.keymap.set("n", "<leader>cp", utils.toggle_color_palette)
end

return M
