return {
  "nvim-telescope/telescope.nvim",

  dependencies = {
    "nvim-lua/plenary.nvim",
    {
      "nvim-telescope/telescope-live-grep-args.nvim",
      config = function()
        require("telescope").load_extension("live_grep_args")
        vim.keymap.set("n", "<leader>g", ":lua require('telescope').extensions.live_grep_args.live_grep_args()<CR>")
      end,
    },

    {
      "nvim-telescope/telescope-file-browser.nvim",
      keys = {
        {
          "<leader>nn",
          ":Telescope file_browser path=%:p:h select_buffer=true<CR>",
          noremap = true,
        },
      },
      config = function()
        require("telescope").load_extension("file_browser")
      end,
    },
    {
      "nvim-telescope/telescope-ui-select.nvim",
      event = "VeryLazy",
      config = function()
        require("telescope").load_extension("ui-select")
      end,
    },
  },
  config = function()
    local telescope = require("telescope")
    telescope.load_extension("live_grep_args")
    -- handlers for using telescope for various windows like reference window, code action, etc.
    telescope.load_extension("lsp_handlers")
    telescope.load_extension("ui-select")
    telescope.load_extension("file_browser")
    telescope.load_extension("yank_history") -- yanky.nvim
    local lga_actions = require("telescope-live-grep-args.actions")
    local trouble_ts_provider = require("trouble.providers.telescope")
    telescope.setup({
      defaults = {
        mappings = {
          i = { ["<c-t>"] = trouble_ts_provider.open_with_trouble },
          n = { ["<c-t>"] = trouble_ts_provider.open_with_trouble },
        },
        file_ignore_patterns = {
          "node_modules",
          "webpack",
          "build",
          "**/package-lock.json",
        },
      },
      pickers = {
        buffers = {
          sort_mru = true,
        },
        find_files = {
          hidden = true,
        },
      },
      extensions = {
        live_grep_args = {
          auto_quoting = true,
          mappings = {
            i = {
              ["<C-k>"] = lga_actions.quote_prompt(),
              ["<C-i>"] = lga_actions.quote_prompt({ postfix = " --iglob " }),
            },
          },
        },
        lsp_handlers = {
          code_action = {
            telescope = require("telescope.themes").get_dropdown({}),
          },
        },
        ["ui-select"] = {
          require("telescope.themes").get_dropdown({}),
        },
        file_browser = {
          hijack_netrw = false,
          auto_depth = true,
        },
      },
    })

    local builtin = require("telescope.builtin")
    vim.keymap.set("n", "<leader>s", builtin.find_files, {})
    vim.keymap.set("n", "<leader>g", ":lua require('telescope').extensions.live_grep_args.live_grep_args()<CR>")
    vim.keymap.set("n", "<leader>gs", builtin.grep_string, {})
    vim.keymap.set("n", "<leader>rs", builtin.resume, {}) -- resumes last picker(find_file, live_grep, etc.) with cached keywords
    vim.keymap.set("n", "<leader>o", builtin.buffers, {})
    vim.keymap.set("n", "<leader>h", builtin.help_tags, {})
    vim.api.nvim_set_var("telescope#buffer#open_file_in_current_window", true)
    vim.api.nvim_set_var("telescope#live_grep#open_file_in_current_window", true)
    vim.keymap.set("n", "<leader>nn", ":Telescope file_browser path=%:p:h select_buffer=true<CR>", { noremap = true })
  end

}
