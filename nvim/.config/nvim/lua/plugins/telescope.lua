return {
	"nvim-telescope/telescope.nvim",
	dependencies = {
		"nvim-lua/plenary.nvim",
		"nvim-telescope/telescope-live-grep-args.nvim",
		"nvim-telescope/telescope-file-browser.nvim",
		"gbrlsnchs/telescope-lsp-handlers.nvim",
		"nvim-telescope/telescope-ui-select.nvim",
	},
	cmd = "Telescope",
	keys = {
		{ "<leader>s", "<CMD>Telescope find_files<CR>" },
		{ "<leader>g", "<CMD>Telescope live_grep_args<CR>" },
		{ "<leader>gs", "<CMD>Telescope grep_string<CR>" },
		{ "<leader>rs", "<CMD>Telescope resume<CR>" },
		{ "<leader>o", "<CMD>Telescope buffers<CR>" },
		{ "<leader>h", "<CMD>Telescope help_tags<CR>" },
		{ "<leader>nn", "<CMD>Telescope file_browser path=%:p:h select_buffer=true<CR>" },
	},
	opts = {
		defaults = {
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
			},
			file_browser = {
				hijack_netrw = false,
				auto_depth = true,
			},
		},
	},
	config = function(_, opts)
		local telescope = require("telescope")
		telescope.load_extension("live_grep_args")
		telescope.load_extension("lsp_handlers")
		telescope.load_extension("ui-select")
		telescope.load_extension("file_browser")
		telescope.load_extension("yank_history") -- yanky.nvim
		vim.api.nvim_set_var("telescope#buffer#open_file_in_current_window", true)
		vim.api.nvim_set_var("telescope#live_grep#open_file_in_current_window", true)

		local lga_actions = require("telescope-live-grep-args.actions")
		local trouble_ts_provider = require("trouble.providers.telescope")
		local additional_opts = {
			defaults = {
				mappings = {
					i = { ["<c-t>"] = trouble_ts_provider.open_with_trouble },
					n = { ["<c-t>"] = trouble_ts_provider.open_with_trouble },
				},
			},
			extensions = {
				live_grep_args = {
					mappings = {
						i = {
							["<c-k>"] = lga_actions.quote_prompt(),
							["<c-i>"] = lga_actions.quote_prompt({ postfix = " --iglob " }),
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
			},
		}
		local extended_opts = vim.tbl_deep_extend("force", additional_opts, opts or {})

		telescope.setup(extended_opts)
	end,
}
