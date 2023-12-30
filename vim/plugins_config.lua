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

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" => Ack searching and cope displaying
"    requires ack.vim - it's much better than vimgrep/grep
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" When you press gv you Ack after the selected text
vnoremap <silent> gv :call VisualSelection('gv', '')<CR>


" When you press <leader>r you can search and replace the selected text
vnoremap <silent> <leader>r :call VisualSelection('replace', '')<CR>

 " Do :help cope if you are unsure what cope is. It's super useful!

 " When you search with Ack, display your results in cope by doing:
   " <leader>cc

 " To go to the next search result do:
   " <leader>n

 " To go to the previous search results do:
   " <leader>p

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
" diagnostics appear/become resolved.
if has('nvim')
    set signcolumn=auto:1
else
    set signcolumn=number
end

]])

vim.opt.termguicolors = true
vim.cmd([[colorscheme tokyonight-storm]])
vim.cmd([[
highlight Normal guibg=none
highlight NonText guibg=none
highlight Normal ctermbg=none
highlight NonText ctermbg=none
]])

require("mason").setup()
local null_ls = require("null-ls")

null_ls.setup({
  sources = {
    null_ls.builtins.formatting.stylua,
    null_ls.builtins.formatting.prettierd,
    null_ls.builtins.formatting.gofmt,
    null_ls.builtins.formatting.golines,
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
-- " => Nvim Tree
-- """""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
vim.g.loaded_netrw = 1
vim.g.loaded_netrwPlugin = 1
local function my_on_attach(bufnr)
  local api = require("nvim-tree.api")

  local function opts(desc)
    return { desc = "nvim-tree: " .. desc, buffer = bufnr, noremap = true, silent = true, nowait = true }
  end

  -- default mappings
  api.config.mappings.default_on_attach(bufnr)

  -- custom mappings
  vim.keymap.set("n", "<C-t>", api.tree.change_root_to_parent, opts("Up"))
  vim.keymap.set("n", "?", api.tree.toggle_help, opts("Help"))
end

require("nvim-tree").setup({
  sort_by = "case_sensitive",
  renderer = {
    group_empty = true,
    highlight_git = true,
    highlight_modified = "icon",
  },
  hijack_directories = {
    enable = false,
    auto_open = true,
  },
  update_focused_file = {
    enable = true,
  },
  on_attach = my_on_attach,
})
local diffmode = vim.api.nvim_win_get_option(0, "diff")
vim.keymap.set("n", "<leader>nn", "<CMD>:NvimTreeToggle<CR>", {})

-- """""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
-- " => lualine
-- """""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
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
    lualine_a = { "buffers" },
    lualine_b = { "branch" },
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
local lga_actions = require("telescope-live-grep-args.actions")
telescope.setup({
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

-- """"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
-- " => LSP
-- """"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

-- Setup nvim-cmp.
local cmp = require("cmp")

cmp.setup({
  snippet = {
    -- REQUIRED - you must specify a snippet engine
    expand = function(args)
      vim.fn["vsnip#anonymous"](args.body)
      -- require('luasnip').lsp_expand(args.body) -- For `luasnip` users.
    end,
  },
  window = {
    border = "rounded",
    completion = cmp.config.window.bordered(),
    documentation = cmp.config.window.bordered(),
  },
  completion = {
    border = "rounded",
  },
  mapping = cmp.mapping.preset.insert({
    ["<C-b>"] = cmp.mapping.scroll_docs(-4),
    ["<C-f>"] = cmp.mapping.scroll_docs(4),
    ["<C-Space>"] = cmp.mapping.complete(),
    ["<C-e>"] = cmp.mapping.abort(),
    ["<CR>"] = cmp.mapping.confirm({ select = true }), -- Accept currently selected item. Set `select` to `false` to only confirm explicitly selected items.
  }),
  sources = cmp.config.sources({
    { name = "cody" },
    { name = "nvim_lsp" },
    { name = "vsnip" },
    -- { name = 'luasnip' }, -- For luasnip users.
  }, {
    { name = "buffer" },
  }),
})

-- Set configuration for specific filetype.
cmp.setup.filetype("gitcommit", {
  sources = cmp.config.sources({
    { name = "cmp_git" }, -- You can specify the `cmp_git` source if you were installed it.
  }, {
    { name = "buffer" },
  }),
})

-- Use buffer source for `/` (if you enabled `native_menu`, this won't work anymore).
cmp.setup.cmdline({ "/" }, {
  mapping = cmp.mapping.preset.cmdline(),
  sources = {
    { name = "path" },
  },
})

-- Use cmdline & path source for ':' (if you enabled `native_menu`, this won't work anymore).
cmp.setup.cmdline({ ":", "~", "/" }, {
  mapping = cmp.mapping.preset.cmdline(),
  sources = cmp.config.sources({
    { name = "path" },
  }, {
    { name = "cmdline" },
  }),
})

-- IMPORTANT: make sure to setup neodev BEFORE lspconfig
require("neodev").setup({
  -- add any options here, or leave empty to use the default settings
})

-- Setup lspconfig.
local capabilities = require("cmp_nvim_lsp").default_capabilities()
local nvim_lsp = require("lspconfig")
local util = require("lspconfig/util")
--
-- local capabilities = vim.lsp.protocol.make_client_capabilities()
capabilities.textDocument.completion.completionItem.snippetSupport = true
--
local on_attach = function(client, bufnr)
  local function buf_set_keymap(...)
    vim.api.nvim_buf_set_keymap(bufnr, ...)
  end
  local function buf_set_option(...)
    vim.api.nvim_buf_set_option(bufnr, ...)
  end
  --
  buf_set_option("omnifunc", "v:lua.vim.lsp.omnifunc")

  vim.o.updatetime = 250
  vim.cmd([[autocmd! CursorHold,CursorHoldI * lua vim.diagnostic.open_float(nil, {focus=false})]])
  vim.cmd([[autocmd! CursorHold,CursorHoldI * lua vim.diagnostic.open_float(nil, {focus=false, scope="cursor"})]])
  vim.api.nvim_create_autocmd("CursorHold", {
    buffer = bufnr,
    callback = function()
      local opts = {
        focusable = false,
        close_events = { "BufLeave", "CursorMoved", "InsertEnter", "FocusLost" },
        border = "rounded",
        source = "always",
        prefix = " ",
        scope = "cursor",
      }
      vim.diagnostic.open_float(nil, opts)
    end,
  })
  --
  --  -- Mappings.
  local opts = { noremap = true, silent = true }
  buf_set_keymap("n", "gD", "<Cmd>lua vim.lsp.buf.declaration()<CR>", opts)
  buf_set_keymap("n", "gd", "<Cmd>lua vim.lsp.buf.definition()<CR>", opts)
  buf_set_keymap("n", "gi", "<cmd>lua vim.lsp.buf.implementation()<CR>", opts)
  buf_set_keymap("n", "ga", "<Cmd>lua vim.lsp.buf.code_action()<CR>", opts)
  buf_set_keymap("n", "K", "<Cmd>lua vim.lsp.buf.hover()<CR>", opts)
  buf_set_keymap("n", "<C-k>", "<cmd>lua vim.lsp.buf.signature_help()<CR>", opts)
  buf_set_keymap("n", "<leader>wa", "<cmd>lua vim.lsp.buf.add_workspace_folder()<CR>", opts)
  buf_set_keymap("n", "<leader>wr", "<cmd>lua vim.lsp.buf.remove_workspace_folder()<CR>", opts)
  buf_set_keymap("n", "<leader>wl", "<cmd>lua print(vim.inspect(vim.lsp.buf.list_workspace_folders()))<CR>", opts)
  buf_set_keymap("n", "<leader>D", "<cmd>lua vim.lsp.buf.type_definition()<CR>", opts)
  buf_set_keymap("n", "<leader>rn", "<cmd>lua vim.lsp.buf.rename()<CR>", opts)
  buf_set_keymap("n", "gr", "<Cmd>lua vim.lsp.buf.references()<CR>", opts)
  buf_set_keymap("n", "<space>e", "<cmd>lua vim.lsp.diagnostic.show_line_diagnostics()<CR>", opts)
  buf_set_keymap("n", "[d", "<cmd>lua vim.lsp.diagnostic.goto_prev()<CR>", opts)
  buf_set_keymap("n", "]d", "<cmd>lua vim.lsp.diagnostic.goto_next()<CR>", opts)
  buf_set_keymap("n", "<space>q", "<cmd>lua vim.lsp.diagnostic.set_loclist()<CR>", opts)
  --
  -- Set some keybinds conditional on server capabilities
  if client.server_capabilities.documentFormattingProvider then
    buf_set_keymap("n", "ff", "<cmd>lua vim.lsp.buf.format()<CR>", opts)
  elseif client.server_capabilities.documentRangeFormattingProvider then
    buf_set_keymap("n", "ff", "<cmd>lua vim.lsp.buf.range_formatting()<CR>", opts)
  else
    buf_set_keymap("n", "ff", '<cmd>lua print("formatting is not supported by this lsp server")<CR>', opts)
  end
  --
  -- Set autocommands conditional on server_capabilities
  if client.server_capabilities.documentHighlightProvider then
    local group = vim.api.nvim_create_augroup("LSPDocumentHighlight", {})

    vim.api.nvim_create_autocmd({ "CursorHold", "CursorHoldI" }, {
      buffer = bufnr,
      group = group,
      callback = function()
        vim.lsp.buf.document_highlight()
      end,
    })
    vim.api.nvim_create_autocmd({ "CursorMoved" }, {
      buffer = bufnr,
      group = group,
      callback = function()
        vim.lsp.buf.clear_references()
      end,
    })
  end

  require("lsp-inlayhints").on_attach(client, bufnr, true)

  if client.name == "gopls" and not client.server_capabilities.semanticTokensProvider then
    local semantic = client.config.capabilities.textDocument.semanticTokens
    client.server_capabilities.semanticTokensProvider = {
      full = true,
      legend = { tokenModifiers = semantic.tokenModifiers, tokenTypes = semantic.tokenTypes },
      range = true,
    }
  end
end                           -- on_attach end
require("dressing").setup({}) -- better ui

-- Sourcegraph configuration. All keys are optional
-- Toggle cody chat
vim.keymap.set("n", "<space>cc", function()
  require("sg.cody.commands").toggle()
end)

vim.keymap.set("v", "<space>ca", function()
  local bufnr = vim.api.nvim_get_current_buf()
  local start_row = vim.fn.getpos("v")[2] - 1
  local end_row = vim.fn.getpos(".")[2]
  vim.ui.input({ prompt = "Ask: " }, function(input)
    require("sg.cody.commands").ask_range(bufnr, start_row, end_row, input)
  end)
end)

-- Cody text highlights for cmp
vim.api.nvim_set_hl(0, "CmpItemKindCody", { fg = "Red" })

vim.keymap.set("n", "<space>cn", function()
  local name = vim.fn.input("chat name: ")
  require("sg.cody.commands").chat(name)
end)

vim.keymap.set("n", "<space>ss", function()
  require("sg.extensions.telescope").fuzzy_search_results()
end)

local ok, msg = pcall(require, "sg")
if not ok then
  print("sg failed to load with:", msg)
  return
end

local node_executable = vim.fn.expand("/home/manish/.nvm/versions/node/v19.6.1/bin/node")
require("sg").setup({
  on_attach = on_attach,
  enable_cody = true,
  node_executable = node_executable,
})

nvim_lsp.tsserver.setup({
  cmd = { "typescript-language-server", "--stdio" },
  filetypes = { "javascript", "javascriptreact", "javascript.jsx", "typescript", "typescriptreact", "typescript.tsx" },
  settings = {
    typescript = {
      inlayHints = {
        includeInlayParameterNameHints = "all",
        includeInlayParameterNameHintsWhenArgumentMatchesName = true,
        includeInlayFunctionParameterTypeHints = true,
        includeInlayVariableTypeHints = true,
        includeInlayVariableTypeHintsWhenTypeMatchesName = false,
        includeInlayPropertyDeclarationTypeHints = true,
        includeInlayFunctionLikeReturnTypeHints = true,
        includeInlayEnumMemberValueHints = true,
      },
    },
    javascript = {
      inlayHints = {
        includeInlayParameterNameHints = "all",
        includeInlayParameterNameHintsWhenArgumentMatchesName = true,
        includeInlayFunctionParameterTypeHints = true,
        includeInlayVariableTypeHints = true,
        includeInlayVariableTypeHintsWhenTypeMatchesName = true,
        includeInlayPropertyDeclarationTypeHints = true,
        includeInlayFunctionLikeReturnTypeHints = true,
        includeInlayEnumMemberValueHints = true,
      },
    },
  },
  on_attach = on_attach,
})
nvim_lsp.sqlls.setup({
  filetypes = { "sql" },
  on_attach = on_attach,
})

nvim_lsp.gopls.setup({
  cmd = { "gopls", "serve" },
  filetypes = { "go", "gomod" },
  root_dir = util.root_pattern("go.work", "go.mod", ".git"),
  -- for postfix snippets and analyzers
  capabilities = capabilities,
  settings = {
    gopls = {
      semanticTokens = true,
      experimentalPostfixCompletions = true,
      analyses = {
        unusedparams = true,
        shadow = true,
      },
      staticcheck = true,
      hints = {
        assignVariableTypes = true,
        compositeLiteralFields = true,
        constantValues = true,
        functionTypeParameters = true,
        parameterNames = true,
        rangeVariableTypes = true,
      },
    },
  },
  init_options = {
    usePlaceholders = true,
  },
  on_attach = on_attach,
})

nvim_lsp.vimls.setup({
  on_attach = on_attach,
})
nvim_lsp.lua_ls.setup({
  settings = {
    Lua = {
      runtime = {
        -- Tell the language server which version of Lua you're using (most likely LuaJIT in the case of Neovim)
        version = "LuaJIT",
      },
      diagnostics = {
        -- Get the language server to recognize the `vim` global
        globals = { "vim" },
      },
      workspace = {
        -- Make the server aware of Neovim runtime files
        library = vim.api.nvim_get_runtime_file("", true),
        checkThirdParty = true,
      },
      -- Do not send telemetry data containing a randomized but unique identifier
      telemetry = {
        enable = false,
      },
      -- inlay hints
      hints = {
        enabled = true,
        method = true,
        field = true,
        variable = true,
        setType = true,
      },
    },
  },
  on_attach = on_attach,
})

nvim_lsp.rust_analyzer.setup({
  settings = {
    ["rust-analyzer"] = {
      imports = {
        granularity = {
          group = "module",
        },
        prefix = "self",
      },
      cargo = {
        buildScripts = {
          enable = true,
        },
      },
      procMacro = {
        enable = true,
      },
    },
  },
  on_attach = on_attach,
})

if vim.g.dbs == nil then
  vim.g.dbs = vim.empty_dict()
end

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
  log_level = vim.log.levels.DEBUG,
  quickfix = {
    open = false,
  },
  status = {
    virtual_text = true,
    signs = true,
  },
  output = {
    open_on_run = false,
  },
  icons = {
    running_animated = { "⠋", "⠙", "⠹", "⠸", "⠼", "⠴", "⠦", "⠧", "⠇", "⠏" },
  },
  strategies = {
    integrated = {
      width = 180,
    },
  },
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
      prefix = "| ",
      separator = ", ",
      remove_colon_start = false,
      remove_colon_end = true,
    },
    type_hints = {
      -- type and other hints
      show = true,
      prefix = ": ",
      separator = ", ",
      remove_colon_start = false,
      remove_colon_end = false,
    },
    only_current_line = false,
    -- separator between types and parameter hints. Note that type hints are
    -- shown before parameter
    labels_separator = "  ",
    -- whether to align to the length of the longest line in the file
    -- max_len_align = true,
    -- padding from the left if max_len_align is true
    -- max_len_align_padding = 10,
    -- experimental (from gupta)
    position = {
      align = "fixed_col",
      padding = 100,
    },
    -- highlight group
    highlight = "Comment",
    -- virt_text priority
    priority = 0,
  },
  enabled_at_startup = true,
  debug_mode = false,
})

require("debugprint").setup({})

-- keep this at the bottom
-- enable for all filetypes
require("colorizer").setup()
