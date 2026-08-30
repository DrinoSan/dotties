" tmux-navigate.vim - move between vim windows and tmux panes with one keymap
" Maintainer:  Sandi
"
" Sourced automatically once the package is on 'runtimepath'.

if exists('g:loaded_tmux_navigate') || &compatible
  finish
endif
let g:loaded_tmux_navigate = 1

" Commands are the public API - mappings are just sugar on top of them.
command! TmuxNavigateLeft  call sand#tmux#navigate('h')
command! TmuxNavigateDown  call sand#tmux#navigate('j')
command! TmuxNavigateUp    call sand#tmux#navigate('k')
command! TmuxNavigateRight call sand#tmux#navigate('l')

" <Plug> mappings let you rebind without touching this file.
nnoremap <silent> <Plug>TmuxNavigateLeft  :<C-u>TmuxNavigateLeft<CR>
nnoremap <silent> <Plug>TmuxNavigateDown  :<C-u>TmuxNavigateDown<CR>
nnoremap <silent> <Plug>TmuxNavigateUp    :<C-u>TmuxNavigateUp<CR>
nnoremap <silent> <Plug>TmuxNavigateRight :<C-u>TmuxNavigateRight<CR>

" Set g:tmux_navigate_no_mappings = 1 in your vimrc to define your own.
if get(g:, 'tmux_navigate_no_mappings', 0)
  finish
endif

nmap <A-h> <Plug>TmuxNavigateLeft
nmap <A-j> <Plug>TmuxNavigateDown
nmap <A-k> <Plug>TmuxNavigateUp
nmap <A-l> <Plug>TmuxNavigateRight
