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

Plug 'scrooloose/nerdtree'
Plug 'junegunn/fzf', { 'dir': '~/.fzf', 'do': './install --all' }
Plug 'junegunn/fzf.vim'
Plug 'jlanzarotta/bufexplorer'
Plug 'yegappan/mru'
Plug 'maxbrunsfeld/vim-yankstack'
Plug 'tpope/vim-surround'
Plug 'vim-airline/vim-airline'
Plug 'vim-airline/vim-airline-themes'
Plug 'junegunn/goyo.vim'
Plug 'airblade/vim-gitgutter'
Plug 'mileszs/ack.vim'
Plug 'neoclide/coc.nvim', {'branch': 'release'}
Plug 'tpope/vim-commentary'
Plug 'pangloss/vim-javascript'
Plug 'leafgarland/typescript-vim'
Plug 'maxmellon/vim-jsx-pretty'
Plug 'mattn/emmet-vim'
Plug 'honza/vim-snippets'
Plug 'norcalli/nvim-colorizer.lua' 
Plug 'chemzqm/macdown.vim'
Plug 'gruvbox-community/gruvbox'
Plug 'glacambre/firenvim', {'do': { _ -> firenvim#install(0)}}
Plug 'NLKNguyen/papercolor-theme'
Plug 'ryanoasis/vim-devicons'



call plug#end()

""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" General Config
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

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

" Fast editing and reloading of vimrc
map <leader>e :e! ~/dotfiles/vim/ultimate_rc.vim<cr>
map <leader>E :e! ~/dotfiles/vim/plugins_config.vim<cr>
autocmd! bufwritepost ~/dotfiles/vim/ultimate_rc.vim source ~/.vimrc
autocmd! bufwritepost ~/dotfiles/vim/plugins_config.vim source ~/.vimrc

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

set termguicolors
set t_Co=256
" colorscheme simple-dark
" colorscheme gruvbox
" let g:gruvbox_contrast_dark='hard'
colorscheme PaperColor
set background=dark
let $NVIM_TUI_ENABLE_TRUE_COLOR=1

" Toggle below two comments for transparency in nvim

highlight Normal guibg=None
highlight NonText guibg=None


" Syntax Highlighting but in browser 
" From the AWESOME GUY ->  The Primagean
augroup AWESOME
    autocmd!
    au BufEnter github.com_*.txt set filetype=markdown
    au BufEnter txti.es_*.txt set filetype=typescript
augroup END



" Colorizer in lua [ sets for filetype *]
lua require'colorizer'.setup() 

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

set encoding=utf8 " utf8 as standard encoding
set fileformats=unix,dos,mac " unix as standard file type

" persistent undo
try
    set undodir=~/.vim/temp_dirs/
    set undofile
catch
endtry

" find on steroids [ this is a crazy option]
set path+=**

" c++ header
set path+=/usr/local/include

" ctags if needed
command! MakeTags !ctags -R --exclude=.git --exclude=node_modules --exclude=dist

" Crazy OSC52 escape sequence for yanking directly to system clipboard
" This even works through ssh and stuff
function! Osc52Yank()
    let buffer=system("base64 -w0", @0)
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
vnoremap <silent> * :<C-u>call VisualSelection(''.'')<CR>/<C-R>=@/<CR><CR>
vnoremap <silent> # :<C-u>call VisualSelection(''.'')<CR>/<C-R>=@/<CR><CR>

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
  set switchbuf=useopen,usetab,newtab
  set showtabline=2
catch
endtry

" return to last edit position after opening a file
au BufReadPost * if line("'\"") > 1 && line("'\"") <= line("$") | exe "normal! g`\"" | endif

""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Editing Config
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

" Remap 0 to first non-blank character
map 0 ^

" Delete trailing white space on save, useful for some filetypes ;)
fun! CleanExtraSpaces()
    let save_cursor = getpos(".")
    let old_query = getreg('/')
    silent! %s/\s\+$//e
    call setpos('.', save_cursor)
    call setreg('/', old_query)
endfun

if has("autocmd")
    autocmd BufWritePre *.txt,*.js,*.py,*.wiki,*.sh :call CleanExtraSpaces()
endif

imap <C-u> <ESC>O<BS>

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

let g:python3_host_prog = '/Library/Frameworks/Python.framework/Versions/3.7/bin/python3'




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


