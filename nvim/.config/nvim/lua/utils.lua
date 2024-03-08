local M = {}

---@param name string
---@return integer
M.find_buffer_by_name = function(name)
	for _, buf in ipairs(vim.api.nvim_list_bufs()) do
		local buf_name = vim.api.nvim_buf_get_name(buf)
		if string.find(buf_name, name) ~= nil then
			return buf
		end
	end
	return -1
end

M.toggle_color_palette = function()
	local existing_buf = M.find_buffer_by_name("ColorPalette")
	if existing_buf ~= -1 then
		vim.api.nvim_buf_delete(existing_buf, { force = true })
		return
	end

	local buf = vim.api.nvim_create_buf(false, true)
	vim.api.nvim_buf_set_name(buf, "ColorPalette")

	local lines = { "🌈 Color Palette" }
	for k, v in pairs(vim.g.color_palette) do
		table.insert(lines, k .. ": " .. v)
	end
	vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)

	vim.api.nvim_open_win(buf, true, {
		relative = "editor",
		width = 30,
		height = 60,
		row = 0,
		col = vim.o.columns - 30,
		style = "minimal",
		border = "rounded",
	})
	vim.cmd("ColorizerToggle")
end

return M
