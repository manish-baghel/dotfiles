local alpha = require("alpha")
local alpha_dashboard_theme = require("alpha.themes.dashboard")
local logo = [[
                                             
      ████ ██████           █████      ██
     ███████████             █████ 
     █████████ ███████████████████ ███   ███████████
    █████████  ███    █████████████ █████ ██████████████
   █████████ ██████████ █████████ █████ █████ ████ █████
 ███████████ ███    ███ █████████ █████ █████ ████ █████
██████  █████████████████████ ████ █████ █████ ████ ██████
]]
alpha_dashboard_theme.section.header.val = vim.split(logo, "\n")
alpha_dashboard_theme.section.buttons.val = {
  alpha_dashboard_theme.button("f", " " .. " Find file", ":Telescope find_files<CR>"),
  alpha_dashboard_theme.button("r", " " .. " Recent files", ":Telescope oldfiles <CR>"),
  alpha_dashboard_theme.button("g", " " .. " Find text", ":norm% ,g<CR>i"),
  alpha_dashboard_theme.button("c", "⚙️" .. " Config", ":e ~/dotfiles/vim/plugins_config.lua<CR> :cd %:p:h<CR>"),
  alpha_dashboard_theme.button("l", "" .. " LazyGit", ":norm% ,lg<CR>"),
  alpha_dashboard_theme.button("q", " " .. " Quit", ":qa<CR>"),
}
alpha_dashboard_theme.section.header.opts.hl = "AlphaHeader"
alpha_dashboard_theme.opts.layout[1].val = 6
alpha.setup(alpha_dashboard_theme.config)

vim.cmd([[
""""""""""""""""""""""""""""""
"    => Easy Align
""""""""""""""""""""""""""""""
"    Start interactive EasyAlign in visual mode (e.g. vipga)
xmap <leader>al <Plug>(EasyAlign)

"    Start interactive EasyAlign for a motion/text object (e.g. gaip)
"    For eg. <leader>al<space>
nmap <leader>al <Plug>(EasyAlign)

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" => Vimroom
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
let g:goyo_width=140
let g:goyo_margin_top = 2
let g:goyo_margin_bottom = 2
nnoremap <silent> <leader>z :Goyo<cr>


vnoremap <silent> gv :call VisualSelection('gv', '')<CR>
vnoremap <silent> <leader>r :call VisualSelection('replace', '')<CR>

map <leader>cc :botright cope<cr>
map <leader>co ggVGy:tabnew<cr>:set syntax=qf<cr>pgg
map <leader>n :cn<cr>
map <leader>p :cp<cr>

" Make sure that enter is never overriden in the quickfix window
autocmd BufReadPost quickfix nnoremap <buffer> <CR> <CR>

" Don't pass messages to |ins-completion-menu|.
set shortmess+=c

" Always show the signcolumn, otherwise it would shift the text each time
" diagnostics appear.
if has('nvim')
    set signcolumn=auto:1
else
    set signcolumn=number
end


" hrsh7th/vsnip keymaps
" Expand
imap <expr> <C-j>   vsnip#expandable()  ? '<Plug>(vsnip-expand)'         : '<C-j>'
smap <expr> <C-j>   vsnip#expandable()  ? '<Plug>(vsnip-expand)'         : '<C-j>'

" Expand or jump
imap <expr> <C-l>   vsnip#available(1)  ? '<Plug>(vsnip-expand-or-jump)' : '<C-l>'
smap <expr> <C-l>   vsnip#available(1)  ? '<Plug>(vsnip-expand-or-jump)' : '<C-l>'

" Jump forward or backward
imap <expr> <Tab>   vsnip#jumpable(1)   ? '<Plug>(vsnip-jump-next)'      : '<Tab>'
smap <expr> <Tab>   vsnip#jumpable(1)   ? '<Plug>(vsnip-jump-next)'      : '<Tab>'
imap <expr> <S-Tab> vsnip#jumpable(-1)  ? '<Plug>(vsnip-jump-prev)'      : '<S-Tab>'
smap <expr> <S-Tab> vsnip#jumpable(-1)  ? '<Plug>(vsnip-jump-prev)'      : '<S-Tab>'

" Select or cut text to use as $TM_SELECTED_TEXT in the next snippet.
" See https://github.com/hrsh7th/vim-vsnip/pull/50
nmap        s   <Plug>(vsnip-select-text)
xmap        s   <Plug>(vsnip-select-text)
nmap        S   <Plug>(vsnip-cut-text)
xmap        S   <Plug>(vsnip-cut-text)

" If you want to use snippet for multiple filetypes, you can `g:vsnip_filetypes` for it.
let g:vsnip_filetypes = {}
let g:vsnip_filetypes.javascriptreact = ['javascript']
let g:vsnip_filetypes.typescriptreact = ['typescript']
]])

vim.cmd([[ tnoremap <silent> <leader>f <C-\><C-n>:FloatermToggle<CR> ]])
vim.api.nvim_set_keymap("n", "<leader>f", ":FloatermToggle --height=0.9 --width=0.9 lazygit<CR>", { noremap = true })
vim.api.nvim_set_keymap("n", "<leader>lg", ":FloatermNew --height=0.9 --width=0.9 lazygit<CR>", { noremap = true })

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

-- """""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
-- " => lualine
-- """""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
local function filepath()
  return vim.fn.expand("%:p:h")
end
---@diagnostic disable-next-line: undefined-field
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
-- " => yanky.nvim
-- """"""""""""""""""""""""""""""""""""""""""""""""""""""""""""
require("yanky").setup()
vim.keymap.set({ "n", "x" }, "y", "<Plug>(YankyYank)")
vim.keymap.set({ "n", "x" }, "p", "<Plug>(YankyPutAfter)")
vim.keymap.set({ "n", "x" }, "P", "<Plug>(YankyPutBefore)")
vim.keymap.set({ "n", "x" }, "gp", "<Plug>(YankyGPutAfter)")
vim.keymap.set({ "n", "x" }, "gP", "<Plug>(YankyGPutBefore)")
vim.keymap.set("n", "<c-p>", "<Plug>(YankyPreviousEntry)")
vim.keymap.set("n", "<c-n>", "<Plug>(YankyNextEntry)")

-- """"""""""""""""""""""""""""""""""""""""""""""""""""""""""""
-- " => telescope
-- """"""""""""""""""""""""""""""""""""""""""""""""""""""""""""
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

local trouble = require("trouble")
trouble.setup({})
local function toggle_trouble()
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
  textobjects = {
    lsp_interop = {
      enable = true,
      border = "none",
      floating_preview_opts = {},
      peek_definition_code = {
        ["<leader>df"] = "@function.outer",
        ["<leader>dF"] = "@class.outer",
      },
    },
    select = {
      enable = true,
      lookahead = true,
      keymaps = {
        ["af"] = "@function.outer",
        ["if"] = "@function.inner",
        ["ac"] = "@class.outer",
        ["ic"] = { query = "@class.inner", desc = "Select inner part of a class region" },
        ["as"] = { query = "@scope", query_group = "locals", desc = "Select language scope" },
      },
      selection_modes = {
        ["@parameter.outer"] = "v", -- charwise
        ["@function.outer"] = "V", -- linewise
        ["@class.outer"] = "<c-v>", -- blockwise
      },
      include_surrounding_whitespace = true,
    },
  },
  playground = {},
})

require("treesitter-context").setup()

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
vim.api.nvim_set_keymap("n", "<leader>d", ":Noice dismiss<CR>", { noremap = true })

-- keep this at the bottom
-- enable for all filetypes
require("colorizer").setup()
