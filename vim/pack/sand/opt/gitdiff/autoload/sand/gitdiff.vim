" Diff the current buffer against a git revision, in a scratch split.

function! s:err(msg) abort
  echohl ErrorMsg | echomsg 'GitDiff: ' . a:msg | echohl None
endfunction

" Absolute directory of the current file, shell escaped.
function! s:dir() abort
  return shellescape(expand('%:p:h'))
endfunction

function! s:git(args) abort
  return systemlist('git -C ' . s:dir() . ' ' . a:args)
endfunction

" Path of the current file relative to the repository root.
function! s:repo_path() abort
  let prefix = s:git('rev-parse --show-prefix')
  if v:shell_error
    return ''
  endif
  return (empty(prefix) ? '' : prefix[0]) . expand('%:t')
endfunction

function! sand#gitdiff#open(...) abort
  let rev = a:0 && !empty(a:1) ? a:1 : 'HEAD'

  if empty(expand('%')) || !filereadable(expand('%:p'))
    call s:err('current buffer is not a file on disk')
    return
  endif
  if exists('b:gitdiff_scratch')
    call s:err('this buffer is already showing a diff, use :GitDiffOff')
    return
  endif

  let path = s:repo_path()
  if empty(path)
    call s:err('not inside a git repository')
    return
  endif

  let lines = s:git('show ' . shellescape(rev . ':' . path))
  if v:shell_error
    call s:err(printf('%s does not exist at %s', path, rev))
    return
  endif

  let ft     = &filetype
  let source = bufnr('%')

  " Scratch buffer holding the old revision. nomodifiable so the diff cannot
  " be edited by accident - it does not correspond to anything on disk.
  vertical new
  let scratch = bufnr('%')
  setlocal buftype=nofile bufhidden=wipe noswapfile nobuflisted
  call setline(1, lines)
  let &l:filetype = ft
  setlocal nomodifiable nomodified
  silent! execute 'file' fnameescape(printf('%s @ %s', fnamemodify(path, ':t'), rev))

  diffthis
  let b:gitdiff_scratch = 1
  wincmd p
  diffthis
  let b:gitdiff_scratch = scratch
  let b:gitdiff_rev = rev
endfunction

function! sand#gitdiff#close() abort
  " Works from either side of the diff.
  if exists('b:gitdiff_scratch') && type(b:gitdiff_scratch) == v:t_number
        \ && bufexists(b:gitdiff_scratch)
    execute 'bwipeout' b:gitdiff_scratch
    unlet! b:gitdiff_scratch b:gitdiff_rev
  endif
  diffoff!
endfunction

function! sand#gitdiff#complete(A, L, P) abort
  let revs = ['HEAD', 'HEAD~1', 'HEAD~2', 'main', 'master']
  let branches = systemlist('git -C ' . s:dir()
        \ . " for-each-ref --format='%(refname:short)' refs/heads refs/remotes")
  if !v:shell_error
    call extend(revs, branches)
  endif
  return filter(revs, 'stridx(v:val, a:A) == 0')
endfunction
