""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" => Colorscheme
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
lua <<EOF
require("monokai-pro").setup({
  transparent_background = true,
  terminal_colors = true,
  devicons = true, -- highlight the icons of `nvim-web-devicons`
  italic_comments = true,
  filter = "pro", -- classic | octagon | pro | machine | ristretto | spectrum
  -- Enable this will disable filter option
  day_night = {
    enable = false, -- turn off by default
    day_filter = "pro", -- classic | octagon | pro | machine | ristretto | spectrum
    night_filter = "spectrum", -- classic | octagon | pro | machine | ristretto | spectrum
  },
  inc_search = "background", -- underline | background
  background_clear = {
    "float_win",
    "toggleterm",
    "telescope",
    "which-key",
    "renamer"
  },-- "float_win", "toggleterm", "telescope", "which-key", "renamer", "neo-tree"
  plugins = {
    bufferline = {
      underline_selected = false,
      underline_visible = false,
    },
    indent_blankline = {
      context_highlight = "default", -- default | pro
      context_start_underline = false,
    },
  },
  ---@param c Colorscheme
  override = function(c) end,
})

require("catppuccin").setup({
		flavour = "mocha", -- Can be one of: latte, frappe, macchiato, mocha
		background = { light = "latte", dark = "mocha" },
		dim_inactive = {
			enabled = false,
			-- Dim inactive splits/windows/buffers.
			-- NOT recommended if you use old palette (a.k.a., mocha).
			shade = "dark",
			percentage = 0.15,
		},
		transparent_background = false,
		show_end_of_buffer = false, -- show the '~' characters after the end of buffers
		term_colors = true,
		compile_path = vim.fn.stdpath("cache") .. "/catppuccin",
		styles = {
			comments = { "italic" },
			properties = { "italic" },
			functions = { "bold" },
			keywords = { "italic" },
			operators = { "bold" },
			conditionals = { "bold" },
			loops = { "bold" },
			booleans = { "bold", "italic" },
			numbers = {},
			types = {},
			strings = {},
			variables = {},
		},
		integrations = {
			treesitter = true,
			native_lsp = {
				enabled = true,
				virtual_text = {
					errors = { "italic" },
					hints = { "italic" },
					warnings = { "italic" },
					information = { "italic" },
				},
				underlines = {
					errors = { "underline" },
					hints = { "underline" },
					warnings = { "underline" },
					information = { "underline" },
				},
			},
			aerial = false,
			barbar = false,
			beacon = false,
			cmp = true,
			coc_nvim = false,
			dap = { enabled = true, enable_ui = true },
			dashboard = false,
			fern = false,
			fidget = true,
			gitgutter = false,
			gitsigns = true,
			harpoon = false,
			hop = true,
			illuminate = true,
			indent_blankline = { enabled = true, colored_indent_levels = false },
			leap = false,
			lightspeed = false,
			lsp_saga = true,
			lsp_trouble = true,
			markdown = true,
			mason = true,
			mini = false,
			navic = { enabled = false },
			neogit = false,
			neotest = false,
			neotree = { enabled = false, show_root = true, transparent_panel = false },
			noice = false,
			notify = true,
			nvimtree = true,
			overseer = false,
			pounce = false,
			semantic_tokens = false,
			symbols_outline = false,
			telekasten = false,
			telescope = true,
			treesitter_context = true,
			ts_rainbow = true,
			vim_sneak = false,
			vimwiki = false,
			which_key = true,
		},
		color_overrides = {
			mocha = {
        rosewater = "#EA6962",
        flamingo = "#EA6962",
        pink = "#D3869B",
        mauve = "#D3869B",
        red = "#EA6962",
        maroon = "#EA6962",
        peach = "#BD6F3E",
        yellow = "#D8A657",
        green = "#A9B665",
        teal = "#89B482",
        sky = "#89B482",
        sapphire = "#89B482",
        blue = "#7DAEA3",
        lavender = "#7DAEA3",
        text = "#E4CEA8",
        subtext1 = "#BDAE8B",
        subtext0 = "#D6C3A2",
        overlay2 = "#8C7A58",
        overlay1 = "#735F3F",
        overlay0 = "#DAC5A5",
        surface2 = "#4B4F51",
--        blue = "#9DCEF3",
--        lavender = "#9DCEF3",
--        text = "#F4DEC8",
--        subtext1 = "#CDBEAB",
--        subtext0 = "#B6A382",
--        overlay2 = "#AC9A78",
--        overlay1 = "#937F5F",
--        overlay0 = "#7A6545",
--        surface2 = "#6B6F71",
        surface1 = "#2A2D2E",
        surface0 = "#232728",

        base = "#1D2021",
        mantle = "#191C1D",
        crust = "#151819",
			},
		},
    custom_highlights = function(colors)
    return {
        NormalFloat = { bg = colors.crust },
        FloatBorder = { bg = colors.crust, fg = colors.crust },
        VertSplit = { bg = colors.base, fg = colors.surface0 },
        CursorLineNr = { fg = colors.mauve, style = { "bold" } },
        LineNr = { fg = colors.surface2 },
        Pmenu = { bg = colors.crust, fg = "" },
        PmenuSel = { bg = colors.surface0, fg = "" },
--        TelescopeSelection = { bg = colors.surface0 },
--        TelescopePromptCounter = { fg = colors.mauve, style = { "bold" } },
--        TelescopePromptPrefix = { bg = colors.surface0 },
--        TelescopePromptNormal = { bg = colors.surface0 },
--        TelescopeResultsNormal = { bg = colors.mantle },
--        TelescopePreviewNormal = { bg = colors.crust },
--        TelescopePromptBorder = { bg = colors.surface0, fg = colors.surface0 },
--        TelescopeResultsBorder = { bg = colors.mantle, fg = colors.mantle },
--        TelescopePreviewBorder = { bg = colors.crust, fg = colors.crust },
--        TelescopePromptTitle = { fg = colors.surface0, bg = colors.surface0 },
--        TelescopeResultsTitle = { fg = colors.mantle, bg = colors.mantle },
--        TelescopePreviewTitle = { fg = colors.crust, bg = colors.crust },
        IndentBlanklineChar = { fg = colors.surface0 },
        IndentBlanklineContextChar = { fg = colors.surface2 },
        GitSignsChange = { fg = colors.peach },
        NvimTreeIndentMarker = { link = "IndentBlanklineChar" },
        NvimTreeExecFile = { fg = colors.text },
        }
    end,
})
EOF
colorscheme catppuccin

""""""""""""""""""""""""""""""
" => Easy Align
""""""""""""""""""""""""""""""
" Start interactive EasyAlign in visual mode (e.g. vipga)
xmap ga <Plug>(EasyAlign)

" Start interactive EasyAlign for a motion/text object (e.g. gaip)
nmap ga <Plug>(EasyAlign)

""""""""""""""""""""""""""""""
" => YankStack
""""""""""""""""""""""""""""""
let g:yankstack_yank_keys = ['y', 'd']


nmap <C-p> <Plug>yankstack_substitute_older_paste
nmap <C-n> <Plug>yankstack_substitute_newer_paste

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" => Nvim Tree
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
lua <<EOF
local function open_nvim_tree()
-- open the tree
require("nvim-tree.api").tree.open()
end
vim.g.loaded_netrw = 1
vim.g.loaded_netrwPlugin = 1
-- set termguicolors to enable highlight groups
vim.opt.termguicolors = true
require("nvim-tree").setup({
  sort_by = "case_sensitive",
  renderer = {
    group_empty = true,
    highlight_git = true,
    highlight_modified = "icon",
  },
})
vim.api.nvim_create_autocmd({ "VimEnter" }, { callback = open_nvim_tree })
EOF
nmap <leader>nn :NvimTreeToggle<CR>
nmap <leader>nf :NvimTreeFindFile<CR>

""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" => Neoformat
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
let g:neoformat_try_node_exe = 1
autocmd BufWritePre *.js,*.ts Neoformat


"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" => surround.vim config
" Annotate strings with gettext
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
vmap Si S(i_<esc>f)
au FileType mako vmap Si S"i${ _(<esc>2f"a) }<esc>


"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" => lualine
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
lua << END
require('lualine').setup {
  options = {
    icons_enabled = true,
    theme = 'auto',
    component_separators = { left = '', right = ''},
    section_separators = { left = '', right = ''},
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
    lualine_a = {'mode'},
    lualine_b = {'branch', 'diff', 'diagnostics'},
    lualine_c = {'filename'},
    lualine_x = {'encoding', 'fileformat', 'filetype'},
    lualine_y = {'progress'},
    lualine_z = {'location'}
  },
  inactive_sections = {
    lualine_a = {},
    lualine_b = {},
    lualine_c = {'filename'},
    lualine_x = {'location'},
    lualine_y = {},
    lualine_z = {}
  },
  tabline = {},
  winbar = {},
  inactive_winbar = {},
  extensions = {}
}
END

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

""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" => telescope
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
lua << EOF
require('telescope').setup({
  defaults = { 
    file_ignore_patterns = { 
      "node_modules" 
    }
  },
  pickers = {
    buffers = {
      sort_mru = true
    }
  }
})
local builtin = require('telescope.builtin')
vim.keymap.set('n', '<leader>s', builtin.find_files, {})
vim.keymap.set('n', '<leader>g', builtin.live_grep, {})
vim.keymap.set('n', '<leader>o', builtin.buffers, {})
vim.keymap.set('n', '<leader>h', builtin.help_tags, {})
EOF


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


""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" => AutoComplete 
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" => LSP
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
lua <<EOF

  -- Setup nvim-cmp.
  local cmp = require'cmp'

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
  local opts = { noremap=true, silent=true }
  buf_set_keymap('n', 'gD', '<Cmd>lua vim.lsp.buf.declaration()<CR>', opts)
  buf_set_keymap('n', 'gd', '<Cmd>lua vim.lsp.buf.definition()<CR>', opts)
  buf_set_keymap('n', 'ga', '<Cmd>lua vim.lsp.buf.code_action()<CR>', opts)
  buf_set_keymap('n', 'K', '<Cmd>lua vim.lsp.buf.hover()<CR>', opts)
  buf_set_keymap('n', 'gi', '<cmd>lua vim.lsp.buf.implementation()<CR>', opts)
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
 if client.server_capabilities.document_formatting then
   buf_set_keymap("n", "ff", "<cmd>lua vim.lsp.buf.formatting()<CR>", opts)
 elseif client.server_capabilities.document_range_formatting then
   buf_set_keymap("n", "ff", "<cmd>lua vim.lsp.buf.range_formatting()<CR>", opts)
 end
 --
 -- Set autocommands conditional on server_capabilities
 if client.server_capabilities.document_highlight then
   vim.api.nvim_exec([[
     hi LspReferenceRead cterm=bold ctermfg=Black ctermbg=LightYellow guibg=LightYellow
     hi LspReferenceText cterm=bold ctermfg=Black ctermbg=LightYellow guibg=LightYellow
     hi LspReferenceWrite cterm=bold ctermfg=Black ctermbg=LightYellow guibg=LightYellow
     augroup lsp_document_highlight
       autocmd! * <buffer>
       autocmd CursorHold <buffer> lua vim.lsp.buf.document_highlight()
       autocmd CursorMoved <buffer> lua vim.lsp.buf.clear_references()
     augroup END
   ]], false)
 end

end -- on_attach end

nvim_lsp.tsserver.setup{
  cmd = { "typescript-language-server", "--stdio" },
  filetypes = { "javascript", "javascriptreact", "javascript.jsx", "typescript", "typescriptreact", "typescript.tsx" },
  on_attach = on_attach,
}
nvim_lsp.sqlls.setup{
  filetypes = { "sql" },
}

nvim_lsp.gopls.setup{
	cmd = {'gopls', 'serve'},
  filetypes = {"go", "gomod"},
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
    },
  },
  init_options = {
    usePlaceholders = true,
  },
	on_attach = on_attach,
}
vim.api.nvim_create_autocmd('BufWritePre', {
  pattern = { "*.go", ".tsx" },
  callback = function()
    vim.lsp.buf.code_action({ context = { only = { 'source.organizeImports' } }, apply = true })
    vim.lsp.buf.formatting()
  end
})

nvim_lsp.vimls.setup{}
nvim_lsp.lua_ls.setup {
  settings = {
    Lua = {
      runtime = {
        -- Tell the language server which version of Lua you're using (most likely LuaJIT in the case of Neovim)
        version = 'LuaJIT',
      },
      diagnostics = {
        -- Get the language server to recognize the `vim` global
        globals = {'vim'},
      },
      workspace = {
        -- Make the server aware of Neovim runtime files
        library = vim.api.nvim_get_runtime_file("", true),
      },
      -- Do not send telemetry data containing a randomized but unique identifier
      telemetry = {
        enable = false,
      },
    },
  },
}


require'nvim-treesitter.configs'.setup {
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

require'treesitter-context'.setup{
  enable = true, -- Enable this plugin (Can be enabled/disabled later via commands)
  max_lines = 0, -- How many lines the window should span. Values <= 0 mean no limit.
  min_window_height = 0, -- Minimum editor window height to enable context. Values <= 0 mean no limit.
  line_numbers = true,
  multiline_threshold = 20, -- Maximum number of lines to collapse for a single context line
  trim_scope = 'outer', -- Which context lines to discard if `max_lines` is exceeded. Choices: 'inner', 'outer'
  mode = 'cursor',  -- Line used to calculate context. Choices: 'cursor', 'topline'
  -- Separator between context and content. Should be a single character string, like '-'.
  -- When separator is set, the context will only show up when there are at least 2 lines above cursorline.
  separator = nil,
  zindex = 20, -- The Z-index of the context window
}

-- keep this at the bottom
-- enable for all filetypes
require'colorizer'.setup()

EOF
