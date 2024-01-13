return {
  {
    "nvim-neotest/neotest-go",
    ft = "go",
    config = function()
      require("neotest").setup({
        adapters = {
          require("neotest-go").adapter,
        },
      })
    end,
  },
  {
    "nvim-neotest/neotest",
    cmd = "Neotest"
    -- keys = {
    --   { "<leader>tr", require("neotest").run.run({ vim.fn.expand("%:p") }) },
    --   {
    --     "<leader>ts",
    --     function()
    --       for _, adapter_id in ipairs(require("neotest").state.adapter_ids()) do
    --         require("neotest").run.run({ suite = true, adapter = adapter_id })
    --       end
    --     end,
    --   },
    --   { "<leader>ta", require("neotest").run.attach },
    --   { "<leader>to", require("neotest").output.open({ enter = true, last_run = true }) },
    --   { "<leader>tp", require("neotest").summary.toggle },
    --   { "<leader>te", require("neotest").output_panel.toggle },
    -- },
  },
}
