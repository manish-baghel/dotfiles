local M = {}

M.setup = function()
	vim.g.mapleader = ","
	vim.g.maplocalleader = ","

	vim.o.hlsearch = true
	vim.o.clipboard = "unnamedplus"
	vim.o.mouse = "a" -- all modes
	vim.o.breakindent = true
	vim.o.tabstop = 2
	vim.o.shiftwidth = 2

	-- Case-insensitive searching UNLESS \C or capital in search
	vim.o.ignorecase = true
	vim.o.smartcase = true

	vim.wo.signcolumn = "yes"
	vim.o.colorcolumn = "120"
	-- vim.opt.list = true
	-- vim.opt.listchars = { tab = "» ", trail = "·", nbsp = "␣" }
	vim.opt.inccommand = "split"

	vim.o.updatetime = 250
	vim.o.timeoutlen = 300

	vim.o.termguicolors = true

	vim.o.splitright = true
	vim.o.splitbelow = true

	vim.o.backspace = "indent,eol,start"
	vim.o.showmatch = true
	vim.o.swapfile = false

	-- this is a useful option while using watchers in js projects
	-- for eg - parcel-bundler or webpack
	-- it helps them detect changes in files
	vim.o.backupcopy = "yes"

	vim.o.fileformats = "unix,dos,mac"
	vim.o.undofile = true

	local highlight_group = vim.api.nvim_create_augroup("YankHighlight", { clear = true })
	vim.api.nvim_create_autocmd("TextYankPost", {
		group = highlight_group,
		callback = function()
			vim.highlight.on_yank()
		end,
	})

	vim.o.autoread = true
	vim.api.nvim_create_autocmd({ "FocusGained", "BufEnter" }, {
		pattern = "*",
		callback = function()
			vim.cmd([[checktime]])
		end,
	})

	-- W command sudo saves the file
	vim.api.nvim_create_user_command("W", "w !sudo tee % > /dev/null | edit!", {})
	vim.api.nvim_create_user_command("Q", "q", {})
	vim.api.nvim_create_user_command("Y", "yy", {})
	vim.api.nvim_create_user_command("G", function(args)
		if args.args then
			local cmd = "g/" .. args.args .. "/y A"
			vim.cmd(cmd)
			vim.cmd("new | setlocal bt=nofile | put! a")
		else
			vim.cmd("echom 'Usage: G <pattern>'")
		end
	end, { nargs = "*" })

	-- Relative numbering with absolute numbering for current line in normal mode and absolute numbering in insert mode
	vim.wo.number = true
	local nt_group_id = vim.api.nvim_create_augroup("RelativeNumberToggle", { clear = true })
	vim.api.nvim_create_autocmd({ "BufEnter", "FocusGained", "InsertLeave" }, {
		group = nt_group_id,
		pattern = "*",
		callback = function()
			vim.wo.relativenumber = true
		end,
	})
	vim.api.nvim_create_autocmd({ "BufLeave", "FocusLost", "InsertEnter" }, {
		group = nt_group_id,
		pattern = "*",
		callback = function()
			vim.wo.relativenumber = false
		end,
	})

	-- Restore last cursor position when opening a file
	vim.api.nvim_create_autocmd("BufReadPost", {
		pattern = "*",
		callback = function()
			vim.cmd(
				[[if line("'\"") >= 1 && line("'\"") <= line("$") && &ft !~# 'commit' | exe "normal! g`\"" | endif]]
			)
		end,
	})

	vim.keymap.set("v", "<leader>r", function()
		local start_row = vim.fn.getpos("v")[2]
		local start_col = vim.fn.getpos("v")[3]
		local end_row = vim.fn.getpos(".")[2]
		local end_col = vim.fn.getpos(".")[3]

		local bufnr = vim.api.nvim_get_current_buf()
		local text =
			table.concat(vim.api.nvim_buf_get_text(bufnr, start_row - 1, start_col - 1, end_row - 1, end_col, {}), "")

		local pattern = vim.fn.escape(text, "\\/.*'$^~[]")
		pattern = vim.fn.substitute(pattern, "\n$", "", "")

		local replace_with = vim.fn.input("Replace with: ")
		vim.cmd("%s/" .. pattern .. "/" .. replace_with .. "/g")
		vim.api.nvim_win_set_cursor(0, { end_row, end_col })
		vim.api.nvim_input("<Esc>")
	end, { noremap = true, desc = "Replace visual selection" })

	vim.cmd([[
		" Restart i3 on config update in linux
		if has('linux')
		  autocmd! bufwritepost ~/.config/i3/config :call system('i3-msg restart')
		endif


	    command! -bang -nargs=* -complete=file E e<bang> <args>
	    command! -bang -nargs=* -complete=file W w<bang> <args>
	    command! -bang -nargs=* -complete=file Wq wq<bang> <args>
	    command! -bang -nargs=* -complete=file WQ wq<bang> <args>
	    command! -bang Wa wa<bang>
	    command! -bang WA wa<bang>
	    command! -bang Q q<bang>
	    command! -bang QA qa<bang>
	    command! -bang Qa qa<bang>
	    command! -bang Wqa wqa<bang>
	    command! -bang WQa wqa<bang>
	    command! -bang WqA wqa<bang>
	    command! -bang WQA wqa<bang>
	    vnoremap <S-Down> <Nop>
	]])

	vim.filetype.add({
		extension = {
			j2 = "jinja",
		},
	})
end

return M
