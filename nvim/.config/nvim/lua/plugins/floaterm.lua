return {
  "voldikss/vim-floaterm",
  keys = {
    { "<leader>f",  "<cmd>FloatermToggle --height=0.9 --width=0.9<CR>" },
    { "<leader>lg", "<cmd>FloatermNew --height=0.9 --width=0.9 lazygit<CR>" },
  },
  config = function()
    vim.cmd([[ tnoremap <silent> <leader>f <C-\><C-n>:FloatermToggle<CR> ]])
  end,
}
