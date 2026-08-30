" pick.vim - fuzzy file / grep / buffer picker in a popup

if exists('g:loaded_pick') || &compatible
  finish
endif
let g:loaded_pick = 1

command! -nargs=? -complete=dir Files   call sand#pick#files(<q-args>)
command! -nargs=? Grep                  call sand#pick#grep(<q-args>)
command! -nargs=0 Buffers               call sand#pick#buffers()
command! -nargs=0 Lines                 call sand#pick#lines()

nnoremap <silent> <Plug>PickFiles   :<C-u>Files<CR>
nnoremap <silent> <Plug>PickGrep    :<C-u>Grep<CR>
nnoremap <silent> <Plug>PickBuffers :<C-u>Buffers<CR>
nnoremap <silent> <Plug>PickLines   :<C-u>Lines<CR>

if get(g:, 'pick_no_mappings', 0)
  finish
endif

nmap <leader>sf <Plug>PickFiles
nmap <leader>sg <Plug>PickGrep
nmap <leader>sb <Plug>PickBuffers
nmap <leader>sl <Plug>PickLines
