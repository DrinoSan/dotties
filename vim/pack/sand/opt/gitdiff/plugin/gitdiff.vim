" gitdiff.vim - diff the current buffer against a git revision

if exists('g:loaded_gitdiff') || &compatible
  finish
endif
let g:loaded_gitdiff = 1

command! -nargs=? -complete=customlist,sand#gitdiff#complete
      \ GitDiff call sand#gitdiff#open(<q-args>)
command! -nargs=0 GitDiffOff call sand#gitdiff#close()

nnoremap <silent> <Plug>GitDiff    :<C-u>GitDiff<CR>
nnoremap <silent> <Plug>GitDiffOff :<C-u>GitDiffOff<CR>

if get(g:, 'gitdiff_no_mappings', 0)
  finish
endif

nmap <leader>gd <Plug>GitDiff
nmap <leader>gD <Plug>GitDiffOff
