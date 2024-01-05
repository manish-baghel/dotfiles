"  _   _                 _
" | \ | | ___  _____   _(_)_ __ ___
" |  \| |/ _ \/ _ \ \ / / | '_ ` _ \
" | |\  |  __/ (_) \ V /| | | | | | |
" |_| \_|\___|\___/ \_/ |_|_| |_| |_|

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Author:
"       Manish Baghel - @manish-baghel
"
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Plugins
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

" This is a life saver
" it should work but for some reason
" holding down arrow still act as inserting B in vim
" Works fine in nvim [ but there are .1 or .2% cases where it fails]
set nocompatible

call plug#begin('~/.vim/plugged')
Plug 'airblade/vim-gitgutter'
Plug 'andrewferrier/debugprint.nvim'
Plug 'antoinemadec/FixCursorHold.nvim'
Plug 'catppuccin/nvim', { 'as': 'catppuccin' }
Plug 'chemzqm/macdown.vim'
Plug 'christoomey/vim-tmux-navigator'
Plug 'craftzdog/solarized-osaka.nvim'
Plug 'folke/neodev.nvim'
Plug 'folke/tokyonight.nvim'
Plug 'folke/trouble.nvim'
Plug 'f-person/git-blame.nvim'
Plug 'gbrlsnchs/telescope-lsp-handlers.nvim'
Plug 'glepnir/lspsaga.nvim'
Plug 'hrsh7th/cmp-buffer'
Plug 'hrsh7th/cmp-cmdline'
Plug 'hrsh7th/cmp-nvim-lsp'
Plug 'hrsh7th/cmp-path'
Plug 'hrsh7th/cmp-vsnip'
Plug 'hrsh7th/nvim-cmp'
Plug 'hrsh7th/vim-vsnip'
Plug 'iamcco/markdown-preview.nvim', { 'do': 'cd app && npm install' }
Plug 'junegunn/goyo.vim'
Plug 'junegunn/vim-easy-align'
Plug 'kyazdani42/nvim-web-devicons'
Plug 'leafgarland/typescript-vim'
Plug 'mattn/emmet-vim'
Plug 'maxbrunsfeld/vim-yankstack'
Plug 'maxmellon/vim-jsx-pretty'
Plug 'mileszs/ack.vim'
Plug 'neovim/nvim-lspconfig'
Plug 'norcalli/nvim-colorizer.lua'
Plug 'nvim-lualine/lualine.nvim'
Plug 'nvim-lua/plenary.nvim'
Plug 'nvim-neotest/neotest'
Plug 'nvim-neotest/neotest-go'
Plug 'nvim-telescope/telescope-file-browser.nvim'
Plug 'nvim-telescope/telescope.nvim' | Plug 'nvim-telescope/telescope-live-grep-args.nvim'
Plug 'nvim-telescope/telescope-ui-select.nvim'
Plug 'nvimtools/none-ls.nvim'
Plug 'nvim-treesitter/nvim-treesitter' | Plug 'nvim-treesitter/nvim-treesitter-context' | Plug 'nvim-treesitter/playground'
Plug 'pangloss/vim-javascript'
Plug 'rafamadriz/friendly-snippets'
Plug 'sainnhe/everforest'
Plug 'sourcegraph/sg.nvim', { 'do': 'nvim -l build/init.lua' }
Plug 'stevearc/dressing.nvim'
Plug 'tpope/vim-commentary'
Plug 'tpope/vim-surround'
Plug 'tyru/open-browser.vim'
Plug 'utkarshgupta137/lsp-inlayhints.nvim'
Plug 'weirongxu/plantuml-previewer.vim'
Plug 'williamboman/mason.nvim'
call plug#end()

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" General Config
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
set clipboard=unnamedplus

"leader key mapping
let mapleader = ","

let g:tty=$tty
set history=500

" Filetype plugins
filetype plugin on
filetype indent on

" Autoread when a file is changed from outside
set autoread
au FocusGained,BufEnter * checktime

" save configs
"   - fast save
"   - :W sudo save
nmap <leader>w :w!<cr>
command! W execute 'w !sudo tee % > /dev/null' <bar> edit!
command! Q execute 'q'
command! Y execute 'yy'

" g command output to new scratch buffer
command! -nargs=? Gst let @a='' | execute 'g/<args>/y A' | new | setlocal bt=nofile | put! a


" Fast editing and reloading of vimrc
map <leader>e :e! ~/dotfiles/vim/ultimate_rc.vim<cr>
" map <leader>E :e! ~/dotfiles/vim/plugins_config.vim<cr>
map <leader>E :e! ~/dotfiles/vim/plugins_config.lua<cr>
autocmd! bufwritepost ~/dotfiles/vim/ultimate_rc.vim source ~/.vimrc
" autocmd! bufwritepost ~/dotfiles/vim/plugins_config.vim source ~/.vimrc
autocmd! bufwritepost ~/dotfiles/vim/plugins_config.lua source ~/.vimrc

""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" VIM UI Config
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

" Wild Menu
set wildmenu
set wildignore+=*.o,*~,*pyc,*/.DS_Store,*/.git,**/node_modules/**

" Current position, cmd bar height, statusline
set ruler
set colorcolumn=100
set cmdheight=1
set laststatus=2
" set statusline=\ %{HasPaste()}%F%m%r%h\ %w\ \ CWD:\ %r%{getcwd()}%h\ \ \ Line:\ %l\ \ Column:\ %c

" backspace config as it should be
set backspace=eol,start,indent
set whichwrap+=<,>,h,l

" Ignore case while searching, smart searching, highlight in
" searching, incremental searching
set ignorecase
set smartcase
set hlsearch
set incsearch

" Avoid redraw while executing macros [ performance boost ]
set lazyredraw

" Matching brackets
set showmatch
set mat=2

set magic " Regex magic

"disabling annoying sounds on error
set noerrorbells
set novisualbell
set t_vb=
set tm=500

" relative numbering auto switch on insert mode
set number relativenumber
augroup numbertoggle
  autocmd!
  autocmd BufEnter,FocusGained,InsertLeave * set relativenumber
  autocmd BufLeave,FocusLost,InsertEnter * set norelativenumber
augroup END

""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Colorscheme and stuff
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

" Syntax Highlighting
syntax enable

" Toggle below two comments for transparency in nvim
" highlight Normal guibg=None
" highlight NonText guibg=None


" Syntax Highlighting but in browser
augroup AWESOME
  autocmd!
  au BufEnter github.com_*.txt set filetype=markdown
  au BufEnter txti.es_*.txt set filetype=typescript
augroup END



" Colorizer in lua [ sets for filetype *]
" lua require'colorizer'.setup()

""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Files, backups and undo
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

" Prevent unloading a buffer when it is abandoned
set hidden

" set nobackup
set noswapfile
set backupcopy=yes " this is a useful option while using watchers in js projects
" for eg - parcel-bundler or webpack
" it helps them detecting changes in files

set encoding=UTF-8 " utf8 as standard encoding
set fileformats=unix,dos,mac " unix as standard file type

" persistent undo
try
  set undodir=~/.vim/temp_dirs/
  set undofile
catch
endtry

" Fix for stupid shift  key hits
command! -bang -nargs=* -complete=file E e<bang> <args>
command! -bang -nargs=* -complete=file W w<bang> <args>
command! -bang -nargs=* -complete=file Wq wq<bang> <args>
command! -bang -nargs=* -complete=file WQ wq<bang> <args>
command! -bang Wa wa<bang>
command! -bang WA wa<bang>
command! -bang Q q<bang>
command! -bang QA qa<bang>
command! -bang Qa qa<bang>
vnoremap <S-Down> <Nop>

" find on steroids [ this is a crazy option]
set path+=**

" c++ header
set path+=/usr/local/include

" ctags if needed
command! MakeTags !ctags -R --exclude=.git --exclude=node_modules --exclude=dist

" Crazy OSC52 escape sequence for yanking directly to system clipboard
" This even works through ssh and stuff
" Mac -> base64 -b 0
" Linux -> base64 -w 0
function! Osc52Yank()
  if has('mac')
    let buffer=system("base64 -b 0", @0)
  else
    let buffer=system("base64 -w 0", @0)
  endif
  let buffer=substitute(buffer, "\n$", "", "")
  let buffer='\e]52;c;'.buffer.'\x07'
  silent exe "!echo -ne ".shellescape(buffer)." > ".shellescape(g:tty)
endfunction
command! Osc52CopyYank call Osc52Yank()

augroup GlobalYank
  autocmd!
  autocmd TextYankPost * if v:event.operator ==# 'y' | call Osc52Yank() | endif
augroup END

""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Text indentation
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

set expandtab
set smarttab

set shiftwidth=2
set tabstop=2

set linebreak
set textwidth=500

set autoindent
set smartindent
set wrap


""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Visual Mode Stuff
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

" Visual mode * or # searches for current selection
vnoremap <silent> * :<C-u>call VisualSelection('', '')<CR>/<C-R>=@/<CR><CR>
vnoremap <silent> # :<C-u>call VisualSelection('', '')<CR>/<C-R>=@/<CR><CR>

vnoremap <silent> <leader>r :<C-u>call VisualSelection('replace', '')<CR>

" Disable highlight when <leader><cr> is pressed
map <silent> <leader><cr> :noh<cr>


""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Tabs, windows and buffers
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

" remove <C-W> from moving between splits
map <C-h> <C-W>h
map <C-j> <C-W>j
map <C-k> <C-W>k
map <C-l> <C-W>l

" buffer movements
map <leader>/ :bnext<cr>
map <leader>. :bprevious<cr>

" closing buffers - current and all
map <leader>bd :Bclose<cr>:tabclose<cr>gT
map <leader>ba :bufdo bd<cr>

" Quickly open a buffer for scribble
map <leader>q :e ~/buffer<cr>
map <leader>x :e ~/buffer.md<cr>

" Managing tabs
map <leader>tn :tabnew<cr>
map <leader>to :tabonly<cr>
map <leader>tc :tabclose<cr>
map <leader>tm :tabmove
map <F1> :tabp<cr>
map <F2> :tabn<cr>

nnoremap <silent> <F3> :redir @a<CR>:g//<CR>:redir END<CR>:new<CR>:put! a<CR>


" move to last accessed tab with <leader>tl
let g:lasttab=1
nmap <leader>tl :exe "tabn ".g:lasttab<cr>
au TabLeave * let g:lasttab = tabpagenr()

" open a file in new tab in current buffer's path
map <leader>te :tabedit <C-r>=expand("%:p:h")<cr>/

" switch cwd to the directory of open buffer
" useful with gf
map <leader>cd :cd %:p:h<cr>:pwd<cr>

" Specify the behavior when switching between buffers
try
  set switchbuf=useopen,usetab
  set showtabline=2
catch
endtry

" return to last edit position after opening a file
au BufReadPost * if line("'\"") > 1 && line("'\"") <= line("$") | exe "normal! g`\"" | endif

""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Editing Config
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

" Remap 0 to first non-blank character
" map 0 ^


" Delete trailing white space on save, useful for some filetypes ;)
fun! CleanExtraSpaces()
  let save_cursor = getpos(".")
  let old_query = getreg('/')
  silent! %s/\s\+$//e
  call setpos('.', save_cursor)
  call setreg('/', old_query)
endfun

if has("autocmd")
  autocmd BufWritePre *.txt,*.js,*.py,*.wiki,*.sh,*.go :call CleanExtraSpaces()
endif

imap <C-u> <ESC>O<BS><TAB>

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Custom commands
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

" For sorting methods in golang
" set custom word ordering in <F2> map and revert the replace op in <F3> map
"

" This pushes the comment above methods inside the methods
" nnoremap <F1> :silent!g/\/\/.*\nfunc/normal ddp<cr>

" This replaces method names with given order and collpases them
" so every new line is diff. function/method
" nnoremap <F2> :silent!%s/^\(func.*\)\( admin\)\(.*\)$/\1 2@\3/g<cr>:silent!%s/^\(func.*\)\( consumer\)\(.*\)$/\1 1@\3/g<cr>:silent!%s/^\(func.*\)\( internal\)\(.*\)$/\1 3@\3/g<cr>:silent!%s/^\(func.*\)\( global\)\(.*\)$/\1 4@\3/g<cr>:silent!g/func /,/^}$/ s/$\n/@@@<cr>

" EXTRA MANUAL STEP TO PERFORM
" VisualSelection on all the methods and call :sort /func /
" This will sort them accordingly

" This reverts back the functions/methods to orginal state
" nnoremap<F3> :silent!%s/@@@/\r/g<cr>:silent!%s/ 1@/ consumer/g<cr>:silent!%s/ 2@/ admin/g<cr>:silent!%s/ 3@/ internal/g<cr>:silent!%s/ 4@/ global/g<cr>

" This pusshes the comments back to original position i.e above the functions/methods
" nnoremap<F4> :silent!g/^func.*\n\/\// normal ddp<cr>


"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Filetype stuff
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

" Python section
let python_highlight_all = 1
au FileType python syn keyword pythonDecorator True None False self

au BufNewFile,BufRead *.jinja set syntax=htmljinja
au BufNewFile,BufRead *.mako set ft=mako

" au FileType python map <buffer> F :set foldmethod=indent<cr>

au FileType python inoremap <buffer> $r return
au FileType python inoremap <buffer> $i import
au FileType python inoremap <buffer> $p print
au FileType python inoremap <buffer> $f # --- <esc>a
au FileType python map <buffer> <leader>1 /class
au FileType python map <buffer> <leader>2 /def
au FileType python map <buffer> <leader>C ?class
au FileType python map <buffer> <leader>D ?def


" JavaScript section
" au BufNewFile,BufRead *.js set syntax=javascriptreact
au BufNewFile,BufRead *.js set filetype=javascriptreact

au FileType javascript map <leader>k :call JavaScriptFold()<CR>
au FileType javascript setl fen
au FileType javascript setl nocindent

au FileType javascript imap <C-t> $log();<esc>hi
au FileType javascript imap <C-a> alert();<esc>hi

au FileType javascript inoremap <buffer> $r return
au FileType javascript inoremap <buffer> $f // --- PH<esc>FP2xi

function! JavaScriptFold()
  setl foldmethod=syntax
  setl foldlevelstart=1
  syn region foldBraces start=/{/ end=/}/ transparent fold keepend extend

  function! FoldText()
    return substitute(getline(v:foldstart), '{.*', '{...}', '')
  endfunction
  setl foldtext=FoldText()
endfunction

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Nvim providers
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

let g:python3_host_prog = '/usr/local/bin/python3'

" Restart i3 on config update in linux
if has('linux')
  autocmd! bufwritepost ~/.i3/config :call system('i3-msg restart')
endif




"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Helper functions
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" returns true when paste mode is on
function! HasPaste()
  if &paste
    return 'PASTE MODE  '
  endif
  return ''
endfunction

" Don't close window, when deleting a buffer
command! Bclose call <SID>BufcloseCloseIt()
function! <SID>BufcloseCloseIt()
  let l:currentBufNum = bufnr("%")
  let l:alternateBufNum = bufnr("#")

  if buflisted(l:alternateBufNum)
    buffer #
  else
    bnext
  endif

  if bufnr("%") == l:currentBufNum
    new
  endif

  if buflisted(l:currentBufNum)
    execute("bdelete! ".l:currentBufNum)
  endif
endfunction

function! CmdLine(str)
  call feedkeys(":" . a:str)
endfunction

function! VisualSelection(direction, extra_filter) range
  let l:saved_reg = @"
  execute "normal! vgvy"

  let l:pattern = escape(@", "\\/.*'$^~[]")
  let l:pattern = substitute(l:pattern, "\n$", "", "")

  if a:direction == 'gv'
    call CmdLine("Ack '" . l:pattern . "' " )
  elseif a:direction == 'replace'
    call CmdLine("%s" . '/'. l:pattern . '/')
  endif

  let @/ = l:pattern
  let @" = l:saved_reg
endfunction


" Copy matches of the last search to a register (default is the clipboard).
" Accepts a range (default is whole file).
" 'CopyMatches'   copy matches to clipboard (each match has \n added).
" 'CopyMatches x' copy matches to register x (clears register first).
" 'CopyMatches X' append matches to register x.
" We skip empty hits to ensure patterns using '\ze' don't loop forever.
command! -range=% -register CopyMatches call s:CopyMatches(<line1>, <line2>, '<reg>')
function! s:CopyMatches(line1, line2, reg)
  let hits = []
  for line in range(a:line1, a:line2)
    let txt = getline(line)
    let idx = match(txt, @/)
    while idx >= 0
      let end = matchend(txt, @/, idx)
      if end > idx
        call add(hits, strpart(txt, idx, end-idx))
      else
        let end += 1
      endif
      if @/[0] == '^'
        break  " to avoid false hits
      endif
      let idx = match(txt, @/, end)
    endwhile
  endfor
  if len(hits) > 0
    let reg = empty(a:reg) ? '+' : a:reg
    execute 'let @'.reg.' = join(hits, "\n") . "\n"'
  else
    echo 'No hits'
  endif
endfunction

nnoremap <leader>ai :HFccSuggestion<cr>
