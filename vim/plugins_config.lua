vim.cmd([[
""""""""""""""""""""""""""""""
"    => Easy Align
""""""""""""""""""""""""""""""
"    Start interactive EasyAlign in visual mode (e.g. vipga)
xmap <leader>al <Plug>(EasyAlign)

"    Start interactive EasyAlign for a motion/text object (e.g. gaip)
"    For eg. <leader>al<space>
nmap <leader>al <Plug>(EasyAlign)

""""""""""""""""""""""""""""""
" => YankStack
""""""""""""""""""""""""""""""
let g:yankstack_yank_keys = ['y', 'd']


nmap <C-p> <Plug>yankstack_substitute_older_paste
nmap <C-n> <Plug>yankstack_substitute_newer_paste


"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" => surround.vim config
" Annotate strings with gettext
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
vmap Si S(i_<esc>f)
au FileType mako vmap Si S"i${ _(<esc>2f"a) }<esc>

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" => Vimroom
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
let g:goyo_width=140
let g:goyo_margin_top = 2
let g:goyo_margin_bottom = 2
nnoremap <silent> <leader>z :Goyo<cr>


"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" => Git gutter (Git diff)
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
let g:gitgutter_enabled=0
nnoremap <silent> <leader>d :GitGutterToggle<cr>

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" => Emmet
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

let g:user_emmet_mode='a'    "enable all function in all mode
let g:user_emmet_settings = {
\  'html': {
\    'snippets': {
\      'html:5': '!!!+html>(head>(meta[charset=${charset}]+meta[name="viewport" content="width=device-width,initial-scale=1.0"]+meta[http-equiv="X-UA-Compatible" content="ie=edge"]+title +body'
            \}
 \},
\  'javascript' : {
\      'extends' : 'jsx',
\  },
\}

vnoremap <silent> gv :call VisualSelection('gv', '')<CR>
vnoremap <silent> <leader>r :call VisualSelection('replace', '')<CR>

map <leader>cc :botright cope<cr>
map <leader>co ggVGy:tabnew<cr>:set syntax=qf<cr>pgg
map <leader>n :cn<cr>
map <leader>p :cp<cr>

" Make sure that enter is never overriden in the quickfix window
autocmd BufReadPost quickfix nnoremap <buffer> <CR> <CR>


" Give more space for displaying messages.
set cmdheight=1

" Having longer updatetime (default is 4000 ms = 4 s) leads to noticeable
" delays and poor user experience.
set updatetime=300

" Don't pass messages to |ins-completion-menu|.
set shortmess+=c

" Always show the signcolumn, otherwise it would shift the text each time
" diagnostics appear.
if has('nvim')
    set signcolumn=auto:1
else
    set signcolumn=number
end

]])

vim.api.nvim_set_keymap("n", "<leader>lg", ":terminal lazygit<CR>", { noremap = true })

require("catppuccin").setup({
  flavour = "mocha",            -- latte, frappe, macchiato, mocha
  transparent_background = true, -- disables setting the background color.
  show_end_of_buffer = false,   -- shows the '~' characters after the end of buffers
  color_overrides = {},
  custom_highlights = {},
  integrations = {
    cmp = true,
    gitsigns = true,
    treesitter = true,
    notify = true,
    mini = {
      enabled = true,
      indentscope_color = "",
    },
  },
})
vim.opt.termguicolors = true
vim.cmd([[colorscheme catppuccin]])
-- Transparent background
-- vim.cmd([[
-- highlight Normal guibg=none
-- highlight NonText guibg=none
-- highlight Normal ctermbg=none
-- highlight NonText ctermbg=none
-- ]])

require("nvim-web-devicons").setup({})
require("mason").setup()

local null_ls = require("null-ls")

null_ls.setup({
  sources = {
    null_ls.builtins.formatting.stylua,
    null_ls.builtins.formatting.prettierd,
    null_ls.builtins.formatting.gofmt,
    -- null_ls.builtins.formatting.golines,
    null_ls.builtins.formatting.goimports,
    null_ls.builtins.formatting.goimports_reviser,
    null_ls.builtins.diagnostics.eslint_d,
    null_ls.builtins.code_actions.eslint_d,
    null_ls.builtins.completion.spell,
    null_ls.builtins.code_actions.gomodifytags,
  },
})

vim.api.nvim_create_autocmd("BufWritePre", {
  pattern = { "*" },
  callback = function()
    vim.lsp.buf.format()
  end,
})

-- """""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
-- " => lualine
-- """""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
local function filepath()
  return vim.fn.expand("%:p:h")
end
require("lualine").setup({
  options = {
    icons_enabled = true,
    theme = "tokyonight",
    component_separators = { left = "", right = "" },
    section_separators = { left = "", right = "" },
    disabled_filetypes = {
      statusline = {},
      winbar = {},
    },
    ignore_focus = {},
    always_divide_middle = true,
    globalstatus = false,
    refresh = {
      statusline = 1000,
      tabline = 1000,
      winbar = 1000,
    },
  },
  sections = {
    lualine_a = { "mode" },
    lualine_b = { "diff", "diagnostics" },
    lualine_c = { "filename" },
    lualine_x = { "encoding", "fileformat", "filetype" },
    lualine_y = { "progress" },
    lualine_z = { "location" },
  },
  inactive_sections = {
    lualine_a = {},
    lualine_b = {},
    lualine_c = { "filename" },
    lualine_x = { "location" },
    lualine_y = {},
    lualine_z = {},
  },
  tabline = {
    lualine_a = { "branch" },
    lualine_b = { filepath },
    lualine_c = { "filename" },
    lualine_x = {},
    lualine_y = {},
    lualine_z = {},
  },
  winbar = {},
  inactive_winbar = {},
  extensions = {},
})

-- """"""""""""""""""""""""""""""""""""""""""""""""""""""""""""
-- " => telescope
-- """"""""""""""""""""""""""""""""""""""""""""""""""""""""""""
local telescope = require("telescope")
telescope.load_extension("live_grep_args")
-- handlers for using telescope for various windows like reference window, code action, etc.
telescope.load_extension("lsp_handlers")
telescope.load_extension("ui-select")
telescope.load_extension("file_browser")
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
      hijack_netrw = true,
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
vim.api.nvim_set_keymap(
  "n",
  "<leader>nn",
  ":Telescope file_browser path=%:p:h select_buffer=true<CR>",
  { noremap = true }
)

local trouble = require("trouble")
trouble.setup({})
function toggle_trouble()
  trouble.toggle()
end

vim.keymap.set("n", "<leader>xx", toggle_trouble)

require("dressing").setup({}) -- better ui

require("nvim-treesitter.configs").setup({
  ensure_installed = "all",
  sync_install = false,
  auto_install = true,
  highlight = {
    enable = true,
    additional_vim_regex_highlighting = false,
  },
  incremental_selection = {
    enable = true,
    keymaps = {
      init_selection = "gnn", -- set to `false` to disable one of the mappings
      node_incremental = "grn",
      scope_incremental = "grc",
      node_decremental = "grm",
    },
  },
  indent = {
    enable = true,
  },
  playground = {
    enable = true,
    disable = {},
    updatetime = 25,       -- Debounced time for highlighting nodes in the playground from source code
    persist_queries = false, -- Whether the query persists across vim sessions
    keybindings = {
      toggle_query_editor = "o",
      toggle_hl_groups = "i",
      toggle_injected_languages = "t",
      toggle_anonymous_nodes = "a",
      toggle_language_display = "I",
      focus_language = "f",
      unfocus_language = "F",
      update = "R",
      goto_node = "<cr>",
      show_help = "?",
    },
  },
})

require("treesitter-context").setup({
  enable = true,           -- Enable this plugin (Can be enabled/disabled later via commands)
  max_lines = 0,           -- How many lines the window should span. Values <= 0 mean no limit.
  min_window_height = 0,   -- Minimum editor window height to enable context. Values <= 0 mean no limit.
  line_numbers = true,
  multiline_threshold = 20, -- Maximum number of lines to show for a single context
  trim_scope = "outer",    -- Which context lines to discard if `max_lines` is exceeded. Choices: 'inner', 'outer'
  mode = "cursor",         -- Line used to calculate context. Choices: 'cursor', 'topline'
  -- Separator between context and content. Should be a single character string, like '-'.
  -- When separator is set, the context will only show up when there are at least 2 lines above cursorline.
  separator = nil,
  zindex = 20,    -- The Z-index of the context window
  on_attach = nil, -- (fun(buf: integer): boolean) return false to disable attaching
})

vim.keymap.set("n", "[c", function()
  require("treesitter-context").go_to_context(vim.v.count1)
end, { silent = true })

-- run tests
local neotest = require("neotest")
local lib = require("neotest.lib")
local get_env = function()
  local env = {}
  local file = ".env"
  if not lib.files.exists(file) then
    return {}
  end

  ---@diagnostic disable-next-line: param-type-mismatch
  for _, line in ipairs(vim.fn.readfile(file)) do
    for name, value in string.gmatch(line, "(%S+)=['\"]?(.*)['\"]?") do
      local str_end = string.sub(value, -1, -1)
      if str_end == "'" or str_end == '"' then
        value = string.sub(value, 1, -2)
      end

      env[name] = value
    end
  end
  return env
end
neotest.setup({
  adapters = {
    require("neotest-go")({
      experimental = {
        test_table = true,
      },
      args = { "-count=1", "-timeout=60s" },
    }),
  },
})
local mappings = {
  ["<leader>tr"] = function()
    neotest.run.run({ vim.fn.expand("%:p"), env = get_env() })
  end,
  ["<leader>ts"] = function()
    for _, adapter_id in ipairs(neotest.state.adapter_ids()) do
      neotest.run.run({ suite = true, adapter = adapter_id, env = get_env() })
    end
  end,
  ["<leader>tx"] = function()
    neotest.run.stop()
  end,
  ["<leader>tn"] = function()
    neotest.run.run({ env = get_env() })
  end,
  ["<leader>td"] = function()
    neotest.run.run({ strategy = "dap", env = get_env() })
  end,
  ["<leader>tl"] = neotest.run.run_last,
  ["<leader>tD"] = function()
    neotest.run.run_last({ strategy = "dap" })
  end,
  ["<leader>ta"] = neotest.run.attach,
  ["<leader>to"] = function()
    neotest.output.open({ enter = true, last_run = true })
  end,
  ["<leader>ti"] = function()
    neotest.output.open({ enter = true })
  end,
  ["<leader>tO"] = function()
    neotest.output.open({ enter = true, short = true })
  end,
  ["<leader>tp"] = neotest.summary.toggle,
  ["<leader>tm"] = neotest.summary.run_marked,
  ["<leader>te"] = neotest.output_panel.toggle,
  ["[n"] = function()
    neotest.jump.prev({ status = "failed" })
  end,
  ["]n"] = function()
    neotest.jump.next({ status = "failed" })
  end,
}

for keys, mapping in pairs(mappings) do
  vim.api.nvim_set_keymap("n", keys, "", { callback = mapping, noremap = true })
end

require("lsp-inlayhints").setup({
  inlay_hints = {
    parameter_hints = {
      show = true,
      prefix = "<- ",
      separator = ", ",
      remove_colon_start = false,
      remove_colon_end = true,
    },
    type_hints = {
      -- type and other hints
      show = true,
      prefix = "",
      separator = ", ",
      remove_colon_start = false,
      remove_colon_end = false,
    },
    only_current_line = false,
    -- separator between types and parameter hints. Note that type hints are
    -- shown before parameter
    labels_separator = "  ",
    -- whether to align to the length of the longest line in the file
    max_len_align = false,
    -- padding from the left if max_len_align is true
    max_len_align_padding = 1,
    -- experimental (from gupta)
    -- position = {
    --   align = "fixed_col",
    --   padding = 80,
    -- },
    -- highlight group
    highlight = "LspInlayHint",
    -- virt_text priority
    priority = 0,
  },
  enabled_at_startup = true,
  debug_mode = false,
})

-- this modifies UI of cmdline, messages, notify and popupmenu
require("noice").setup({
  lsp = {
    -- override markdown rendering so that **cmp** and other plugins use **Treesitter**
    override = {
      ["vim.lsp.util.convert_input_to_markdown_lines"] = true,
      ["vim.lsp.util.stylize_markdown"] = true,
      ["cmp.entry.get_documentation"] = true,
    },
  },
  -- you can enable a preset for easier configuration
  presets = {
    bottom_search = true,       -- use a classic bottom cmdline for search
    command_palette = true,     -- position the cmdline and popupmenu together
    long_message_to_split = true, -- long messages will be sent to a split
    inc_rename = false,         -- enables an input dialog for inc-rename.nvim
    lsp_doc_border = false,     -- add a border to hover docs and signature help
  },
})

-- keep this at the bottom
-- enable for all filetypes
require("colorizer").setup()
