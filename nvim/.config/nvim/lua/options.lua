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
	vim.o.colorcolumn = "80"
	vim.opt.list = true
	vim.opt.listchars = { tab = "» ", trail = "·", nbsp = "␣" }
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
	-- g command output to new scratch buffer
	-- vim.api.nvim_create_user_command(
	--	"g",
	--	"command! -nargs=? Gst let @a='' | execute 'g/<args>/y A' | new | setlocal bt=nofile | put! a",
	--	{}
	--)

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

	vim.cmd([[
		vnoremap <silent> <leader>r :<C-u>call ReplaceVisualSelection()<CR>

		function! ReplaceVisualSelection() range
		  let l:saved_reg = @"
		  execute "normal! vgvy"

		  let l:pattern = escape(@", "\\/.*'$^~[]")
		  let l:pattern = substitute(l:pattern, "\n$", "", "")

		  call CmdLine("%s" . '/'. l:pattern . '/')

		  let @/ = l:pattern
		  let @" = l:saved_reg
		endfunction
		" Restart i3 on config update in linux
		if has('linux')
		  autocmd! bufwritepost ~/.i3/config :call system('i3-msg restart')
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
end

return M
