vim.cmd([[
	set path+=**
	set cc=120
	set wildignore+=**/node_modules/*
	set wildignore+=**/.git/*
	set wildignore+=*.log*
	set wildignore+=*.map*
	set tabstop=4
	set softtabstop=4
	set shiftwidth=4
	set scrolloff=8
	set relativenumber nu
	set wrap
	set linebreak
	set breakindent
	set smartindent
	set autoindent
	set hidden
	set nobackup
	set noexpandtab
	set noerrorbells
	set cursorline
	set noswapfile
	set undofile
	set incsearch
	set splitbelow
	set splitright
	set undodir=~/.local/share/undo
	set mouse=a
	set iskeyword=@,48-57,_,192-255,$
	autocmd FileType * setlocal formatoptions-=c formatoptions-=r formatoptions-=o
	autocmd FileType json setlocal expandtab
	filetype plugin indent on
]])
