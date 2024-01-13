return {
  "stevearc/conform.nvim",
  dependencies = {
    "mason.nvim"
  },
  cmd = "ConformInfo",
  event = "BufWritePre",
  keys = {
    {
      "<leader>ff",
      function()
        require("conform").format({ async = true, lsp_fallback = true, formatters = { "injected" } })
      end,
      mode = { "n", "v" },
      desc = "Format Injected Langs",
    },
  },
  opts = {
    -- format = {
    --   timeout_ms = 3000,
    --   async = false, -- not recommended to change
    --   quiet = false, -- not recommended to change
    -- },
    formatters_by_ft = {
      lua = { "stylua" },
      go = { "goimports", "goimports-reviser", { "gofumpt", "gofmt" } },
      python = { "isort", "black" },
      javascript = { { "prettierd", "prettier" } },
      sh = { "shfmt" },
    },

    format_on_save = {
      timeout_ms = 500,
      lsp_fallback = true,
    },
  },
}
