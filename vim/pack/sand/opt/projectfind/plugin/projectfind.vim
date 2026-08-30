" projectfind.vim - :find shortcuts for the directories you actually live in
"
" Configure g:projectfind_paths in your vimrc, see :help projectfind

if exists('g:loaded_projectfind') || &compatible
  finish
endif
let g:loaded_projectfind = 1

command! -nargs=0 ProjectFindList call sand#projectfind#list()
command! -nargs=1 -complete=customlist,sand#projectfind#complete
      \ ProjectFind call sand#projectfind#go(<q-args>)

if get(g:, 'projectfind_no_mappings', 0)
  finish
endif

" packadd! defers sourcing plugin files until after the vimrc has run, so
" g:projectfind_paths is already set by the time we get here.
call sand#projectfind#apply()

" Safety net for the other case: configured later, or packadd'ed by hand.
augroup projectfind_apply
  autocmd!
  autocmd VimEnter * call sand#projectfind#apply()
augroup END
