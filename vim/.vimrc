let mapleader=" "

set path+=**
set wildmenu

syntax on
filetype plugin on

set tabstop=3
set shiftwidth=3
set smartindent
set number
set relativenumber
set nohlsearch
set expandtab
set undodir=~/.vim/undodir
set undofile
set nocompatible
set ruler
set laststatus=2
set noswapfile
set showcmd
set nowrap
set ignorecase
set smartcase

" Man pages it is
runtime ftplugin/man.vim
set keywordprg=:Man

" Remove whitespace on space of each line
autocmd BufWritePre * :%s/\s\+$//e

"## LSP FAKE
"\<CR\> = CTRL
"CTAGS "LSP"
"`<CR>]` to jump to a tag under the cursor
"`g<CR>]` to get a listing of all matching tags
"`<CR>t` to jump _back_ up the tag stack

"nnoremap <leader>f :!git-clang-format -f %<CR> source %
nnoremap <leader>f :!git-clang-format -f %<CR> \| source % \| normal! <Esc>


" Using vimgrep to find stuff if ctags doesnot work
" vimgrep /FunctionName/gjf *
" :help vimgrep
" Slash wird benutzt um den such string mit den falgs zu trennen * für alle
" folder
" Dann normal mit :copen :cnext :cprev arbeiten
"
" Wenn es notwendig ist folder zu ignorieren:
"     :set wildignore+=objd/**,obj/**,*.tmp,test.c
" :help wildignore

set wildignore+=objd/**,obj/**,*.tmp,*.o,*.d

" For more stuff:
" :help netrw-browse-maps
let g:netrw_banner=0        " disable annoying banner
let g:netrw_browse_split=4  " open in prior window
let g:netrw_liststyle=3     " tree view
"let g:netrw_list_hide=netrw_gitignore#Hide()
"let g:netrw_list_hide.=',\(^\|\s\s\)\zs\.\S\+'


nnoremap <leader>x *``cgn
nnoremap <leader>X #``cgn

nnoremap <leader>n :cnext<CR>
nnoremap <leader>p :cprev<CR>

vnoremap <silent> <C-j> :move '>+1<CR>gv=gv
vnoremap <silent> <C-k> :move '<-2<CR>gv=gv


nnoremap <silent> <C-d> <C-d>zz
nnoremap <silent> <C-u> <C-u>zz


nnoremap <leader>bg :find /opt/homebrew/include/**/
