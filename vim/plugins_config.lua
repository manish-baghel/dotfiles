-- setup must be called before loading
vim.cmd("colorscheme kanagawa-wave")

-- """""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
-- " => Nvim Tree
-- """""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
-- local function open_nvim_tree()
--   -- open the tree
--   require("nvim-tree.api").tree.open()
-- end
vim.g.loaded_netrw = 1
vim.g.loaded_netrwPlugin = 1
-- -- set termguicolors to enable highlight groups
vim.opt.termguicolors = true
require("nvim-tree").setup({
  open_on_setup = false,
  sort_by = "case_sensitive",
  renderer = {
    group_empty = true,
    highlight_git = true,
    highlight_modified = "icon",
  },
  hijack_directories = {
    enable = false,
    auto_open = false,
  },
})
-- vim.api.nvim_create_autocmd({ "VimEnter" }, { callback = open_nvim_tree })

-- """""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
-- " => lualine
-- """""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
require('lualine').setup {
  options = {
    icons_enabled = true,
    theme = 'auto',
    component_separators = { left = '', right = '' },
    section_separators = { left = '', right = '' },
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
    }
  },
  sections = {
    lualine_a = { 'mode' },
    lualine_b = { 'branch', 'diff', 'diagnostics' },
    lualine_c = { 'filename' },
    lualine_x = { 'encoding', 'fileformat', 'filetype' },
    lualine_y = { 'progress' },
    lualine_z = { 'location' }
  },
  inactive_sections = {
    lualine_a = {},
    lualine_b = {},
    lualine_c = { 'filename' },
    lualine_x = { 'location' },
    lualine_y = {},
    lualine_z = {}
  },
  tabline = {},
  winbar = {},
  inactive_winbar = {},
  extensions = {}
}

-- """"""""""""""""""""""""""""""""""""""""""""""""""""""""""""
-- " => telescope
-- """"""""""""""""""""""""""""""""""""""""""""""""""""""""""""
local telescope = require("telescope")
telescope.load_extension("live_grep_args")
local lga_actions = require("telescope-live-grep-args.actions")
telescope.setup {
  defaults = {
    file_ignore_patterns = {
      "node_modules"
    },
  },
  pickers = {
    buffers = {
      sort_mru = true
    }
  },
  extensions = {
    live_grep_args = {
      auto_quoting = true, -- enable/disable auto-quoting
      -- define mappings, e.g.
      mappings = {
        -- extend mappings
        i = {
          ["<C-k>"] = lga_actions.quote_prompt(),
          ["<C-i>"] = lga_actions.quote_prompt({ postfix = " --iglob " }),
        },
      },
      -- ... also accepts theme settings, for example:
      -- theme = "dropdown", -- use dropdown theme
      -- theme = { }, -- use own theme spec
      -- layout_config = { mirror=true }, -- mirror preview pane
    }
  }
}

local builtin = require('telescope.builtin')
vim.keymap.set('n', '<leader>s', builtin.find_files, {})
vim.keymap.set("n", "<leader>g", ":lua require('telescope').extensions.live_grep_args.live_grep_args()<CR>")
vim.keymap.set('n', '<leader>gs', builtin.grep_string, {})
vim.keymap.set('n', '<leader>rs', builtin.resume, {}) -- resumes last picker(find_file, live_grep, etc.) with cached keywords
vim.keymap.set('n', '<leader>o', builtin.buffers, {})
vim.keymap.set('n', '<leader>h', builtin.help_tags, {})
vim.api.nvim_set_var('telescope#buffer#open_file_in_current_window', true)
vim.api.nvim_set_var('telescope#live_grep#open_file_in_current_window', true)

-- """"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
-- " => LSP
-- """"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

-- Setup nvim-cmp.
local cmp = require 'cmp'

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
    ['<C-b>'] = cmp.mapping.scroll_docs(-4),
    ['<C-f>'] = cmp.mapping.scroll_docs(4),
    ['<C-Space>'] = cmp.mapping.complete(),
    ['<C-e>'] = cmp.mapping.abort(),
    ['<CR>'] = cmp.mapping.confirm({ select = true }), -- Accept currently selected item. Set `select` to `false` to only confirm explicitly selected items.
  }),
  sources = cmp.config.sources({
    { name = 'nvim_lsp' },
    { name = 'vsnip' },
    -- { name = 'luasnip' }, -- For luasnip users.
  }, {
    { name = 'buffer' },
  })
})

-- Set configuration for specific filetype.
cmp.setup.filetype('gitcommit', {
  sources = cmp.config.sources({
    { name = 'cmp_git' }, -- You can specify the `cmp_git` source if you were installed it.
  }, {
    { name = 'buffer' },
  })
})

-- Use buffer source for `/` (if you enabled `native_menu`, this won't work anymore).
cmp.setup.cmdline('/', {
  mapping = cmp.mapping.preset.cmdline(),
  sources = {
    { name = 'buffer' }
  }
})

-- Use cmdline & path source for ':' (if you enabled `native_menu`, this won't work anymore).
cmp.setup.cmdline(':', {
  mapping = cmp.mapping.preset.cmdline(),
  sources = cmp.config.sources({
    { name = 'path' }
  }, {
    { name = 'cmdline' }
  })
})

-- IMPORTANT: make sure to setup neodev BEFORE lspconfig
require("neodev").setup({
  -- add any options here, or leave empty to use the default settings
})

-- Setup lspconfig.
local capabilities = require('cmp_nvim_lsp').default_capabilities()
--require'navigator'.setup()
local nvim_lsp = require('lspconfig')
local util = require('lspconfig/util')
--
-- local capabilities = vim.lsp.protocol.make_client_capabilities()
capabilities.textDocument.completion.completionItem.snippetSupport = true
--
local on_attach = function(client, bufnr)
  local function buf_set_keymap(...) vim.api.nvim_buf_set_keymap(bufnr, ...) end
  local function buf_set_option(...) vim.api.nvim_buf_set_option(bufnr, ...) end
  --
  buf_set_option('omnifunc', 'v:lua.vim.lsp.omnifunc')

  vim.o.updatetime = 250
  vim.cmd [[autocmd! CursorHold,CursorHoldI * lua vim.diagnostic.open_float(nil, {focus=false})]]
  vim.cmd [[autocmd! CursorHold,CursorHoldI * lua vim.diagnostic.open_float(nil, {focus=false, scope="cursor"})]]
  vim.api.nvim_create_autocmd("CursorHold", {
    buffer = bufnr,
    callback = function()
      local opts = {
        focusable = false,
        close_events = { "BufLeave", "CursorMoved", "InsertEnter", "FocusLost" },
        border = "rounded",
        source = 'always',
        prefix = ' ',
        scope = 'cursor',
      }
      vim.diagnostic.open_float(nil, opts)
    end
  })
  --
  --  -- Mappings.
  local opts = { noremap = true, silent = true }
  buf_set_keymap('n', 'gD', '<Cmd>lua vim.lsp.buf.declaration()<CR>', opts)
  buf_set_keymap('n', 'gd', '<Cmd>lua vim.lsp.buf.definition()<CR>', opts)
  buf_set_keymap('n', 'gi', '<cmd>lua vim.lsp.buf.implementation()<CR>', opts)
  buf_set_keymap('n', 'ga', '<Cmd>lua vim.lsp.buf.code_action()<CR>', opts)
  buf_set_keymap('n', 'K', '<Cmd>lua vim.lsp.buf.hover()<CR>', opts)
  buf_set_keymap('n', '<C-k>', '<cmd>lua vim.lsp.buf.signature_help()<CR>', opts)
  buf_set_keymap('n', '<leader>wa', '<cmd>lua vim.lsp.buf.add_workspace_folder()<CR>', opts)
  buf_set_keymap('n', '<leader>wr', '<cmd>lua vim.lsp.buf.remove_workspace_folder()<CR>', opts)
  buf_set_keymap('n', '<leader>wl', '<cmd>lua print(vim.inspect(vim.lsp.buf.list_workspace_folders()))<CR>', opts)
  buf_set_keymap('n', '<leader>D', '<cmd>lua vim.lsp.buf.type_definition()<CR>', opts)
  buf_set_keymap('n', '<leader>rn', '<cmd>lua vim.lsp.buf.rename()<CR>', opts)
  buf_set_keymap('n', 'gr', '<Cmd>lua vim.lsp.buf.references()<CR>', opts)
  buf_set_keymap('n', '<space>e', '<cmd>lua vim.lsp.diagnostic.show_line_diagnostics()<CR>', opts)
  buf_set_keymap('n', '[d', '<cmd>lua vim.lsp.diagnostic.goto_prev()<CR>', opts)
  buf_set_keymap('n', ']d', '<cmd>lua vim.lsp.diagnostic.goto_next()<CR>', opts)
  buf_set_keymap('n', '<space>q', '<cmd>lua vim.lsp.diagnostic.set_loclist()<CR>', opts)
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

    vim.opt.updatetime = 1000

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

  require "lsp-inlayhints".on_attach(client, bufnr, true)
end -- on_attach end

nvim_lsp.tsserver.setup {
  cmd = { "typescript-language-server", "--stdio" },
  filetypes = { "javascript", "javascriptreact", "javascript.jsx", "typescript", "typescriptreact", "typescript.tsx" },
  on_attach = on_attach,
}
nvim_lsp.sqlls.setup {
  filetypes = { "sql" },
  on_attach = on_attach
}

nvim_lsp.gopls.setup {
  cmd = { 'gopls', 'serve' },
  filetypes = { "go", "gomod" },
  root_dir = util.root_pattern("go.work", "go.mod", ".git"),
  -- for postfix snippets and analyzers
  capabilities = capabilities,
  settings = {
    gopls = {
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
}
vim.api.nvim_create_autocmd('BufWritePre', {
  pattern = { "*.go", "*.tsx", "*.lua" },
  callback = function()
    --    vim.lsp.buf.code_action({ context = { only = { 'source.organizeImports' } }, apply = true })
    vim.lsp.buf.format()
  end
})

nvim_lsp.vimls.setup {}
nvim_lsp.lua_ls.setup {
  settings = {
    Lua = {
      runtime = {
        -- Tell the language server which version of Lua you're using (most likely LuaJIT in the case of Neovim)
        version = 'LuaJIT',
      },
      diagnostics = {
        -- Get the language server to recognize the `vim` global
        globals = { 'vim' },
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
      hint = {
        enabled = true,
        setType = true,
      },
    },
  },
  on_attach = on_attach,
}


require 'nvim-treesitter.configs'.setup {
  -- A list of parser names, or "all"
  ensure_installed = { "go", "typescript", "yaml", "json", "sql", "lua", "bash", "vim" },
  -- Install parsers synchronously (only applied to `ensure_installed`)
  sync_install = false,
  -- List of parsers to ignore installing (for "all")
  -- ignore_install = { "javascript" },
  highlight = {
    -- `false` will disable the whole extension
    enable = true,
    -- NOTE: these are the names of the parsers and not the filetype. (for example if you want to
    -- disable highlighting for the `tex` filetype, you need to include `latex` in this list as this is

    -- the name of the parser)
    -- list of language that will be disabled
    --disable = { "c", "rust" },

    -- Setting this to true will run `:h syntax` and tree-sitter at the same time.
    -- Set this to `true` if you depend on 'syntax' being enabled (like for indentation).
    -- Using this option may slow down your editor, and you may see some duplicate highlights.
    -- Instead of true it can also be a list of languages
    additional_vim_regex_highlighting = false,
  },
}

require 'treesitter-context'.setup {
  enable = true,            -- Enable this plugin (Can be enabled/disabled later via commands)
  max_lines = 0,            -- How many lines the window should span. Values <= 0 mean no limit.
  min_window_height = 0,    -- Minimum editor window height to enable context. Values <= 0 mean no limit.
  line_numbers = true,
  multiline_threshold = 20, -- Maximum number of lines to collapse for a single context line
  trim_scope = 'outer',     -- Which context lines to discard if `max_lines` is exceeded. Choices: 'inner', 'outer'
  mode = 'cursor',          -- Line used to calculate context. Choices: 'cursor', 'topline'
  -- Separator between context and content. Should be a single character string, like '-'.
  -- When separator is set, the context will only show up when there are at least 2 lines above cursorline.
  separator = nil,
  zindex = 20, -- The Z-index of the context window
}

-- run tests
local neotest = require('neotest')
local lib = require("neotest.lib")
local get_env = function()
  local env = {}
  local file = ".env"
  if not lib.files.exists(file) then
    return {}
  end

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
      args = { "-count=1", "-timeout=60s" }
    })
  }
})
local mappings = {
  ["<leader>nr"] = function()
    neotest.run.run({ vim.fn.expand("%:p"), env = get_env() })
  end,
  ["<leader>ns"] = function()
    for _, adapter_id in ipairs(neotest.state.adapter_ids()) do
      neotest.run.run({ suite = true, adapter = adapter_id, env = get_env() })
    end
  end,
  ["<leader>nx"] = function()
    neotest.run.stop()
  end,
  ["<leader>nn"] = function()
    neotest.run.run({ env = get_env() })
  end,
  ["<leader>nd"] = function()
    neotest.run.run({ strategy = "dap", env = get_env() })
  end,
  ["<leader>nl"] = neotest.run.run_last,
  ["<leader>nD"] = function()
    neotest.run.run_last({ strategy = "dap" })
  end,
  ["<leader>na"] = neotest.run.attach,
  ["<leader>no"] = function()
    neotest.output.open({ enter = true, last_run = true })
  end,
  ["<leader>ni"] = function()
    neotest.output.open({ enter = true })
  end,
  ["<leader>nO"] = function()
    neotest.output.open({ enter = true, short = true })
  end,
  ["<leader>np"] = neotest.summary.toggle,
  ["<leader>nm"] = neotest.summary.run_marked,
  ["<leader>ne"] = neotest.output_panel.toggle,
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


-- hugging face code completion model
require('hfcc').setup({
  api_token = "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",
  model = "bigcode/starcoder",
  -- parameters that are added to the request body
  query_params = {
    max_new_tokens = 60,
    temperature = 0.2,
    top_p = 0.95,
    stop_token = "<|endoftext|>",
  },
  -- set this if the model supports fill in the middle
  fim = {
    enabled = true,
    prefix = "<fim_prefix>",
    middle = "<fim_middle>",
    suffix = "<fim_suffix>",
  },
})
vim.keymap.set("n", "<leader>ai", "<cmd>HFccSuggestion<CR>", {})

-- keep this at the bottom
-- enable for all filetypes
require 'colorizer'.setup()

require("lsp-inlayhints").setup({
  inlay_hints = {
    parameter_hints = {
      show = true,
      prefix = ": ",
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
    -- highlight group
    highlight = "Comment",
    -- virt_text priority
    priority = 0,
  },
  enabled_at_startup = true,
  debug_mode = false,
}
)

require("debugprint").setup {}
