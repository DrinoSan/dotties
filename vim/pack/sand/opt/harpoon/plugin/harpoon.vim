" harpoon.vim - a small ordered set of files per project, reached by number

if exists('g:loaded_harpoon') || &compatible
  finish
endif
let g:loaded_harpoon = 1

let g:harpoon_file = get(g:, 'harpoon_file', '~/.cache/vim/harpoon.json')

command! -nargs=0 HarpoonAdd    call sand#harpoon#add()
command! -nargs=0 HarpoonRemove call sand#harpoon#remove()
command! -nargs=0 HarpoonClear  call sand#harpoon#clear()
command! -nargs=0 HarpoonMenu   call sand#harpoon#menu()
command! -nargs=0 HarpoonList   call sand#harpoon#list()
command! -nargs=0 HarpoonNext   call sand#harpoon#cycle(1)
command! -nargs=0 HarpoonPrev   call sand#harpoon#cycle(-1)
command! -nargs=1 HarpoonGo     call sand#harpoon#go(str2nr(<q-args>))

" Keep each mark's line number up to date as you move around, and make sure
" that survives quitting.
augroup harpoon_track
  autocmd!
  autocmd BufLeave    * call sand#harpoon#track()
  autocmd VimLeavePre * call sand#harpoon#track() | call sand#harpoon#save()
augroup END

nnoremap <silent> <Plug>HarpoonAdd    :<C-u>HarpoonAdd<CR>
nnoremap <silent> <Plug>HarpoonMenu   :<C-u>HarpoonMenu<CR>
nnoremap <silent> <Plug>HarpoonRemove :<C-u>HarpoonRemove<CR>
nnoremap <silent> <Plug>HarpoonNext   :<C-u>HarpoonNext<CR>
nnoremap <silent> <Plug>HarpoonPrev   :<C-u>HarpoonPrev<CR>

if get(g:, 'harpoon_no_mappings', 0)
  finish
endif

nmap <leader>a <Plug>HarpoonAdd
nmap <leader>h <Plug>HarpoonMenu

" <leader>1 .. <leader>9 jump straight to a mark.
for s:i in range(1, 9)
  execute printf('nnoremap <silent> <leader>%d :<C-u>HarpoonGo %d<CR>', s:i, s:i)
endfor
unlet s:i
