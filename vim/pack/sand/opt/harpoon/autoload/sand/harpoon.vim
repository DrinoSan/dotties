" harpoon - a tiny, ordered set of files per project, reachable by number.

let s:marks  = {}    " root -> list of {file, lnum, col}
let s:loaded = 0

function! s:err(msg) abort
  echohl ErrorMsg | echomsg 'harpoon: ' . a:msg | echohl None
endfunction

function! s:store() abort
  return expand(get(g:, 'harpoon_file', '~/.cache/vim/harpoon.json'))
endfunction

" --------------------------------------------------------------- project root

function! s:root() abort
  let dir = empty(expand('%')) ? getcwd() : expand('%:p:h')
  let out = systemlist('git -C ' . shellescape(dir) . ' rev-parse --show-toplevel')
  if !v:shell_error && !empty(out)
    return out[0]
  endif
  return getcwd()
endfunction

function! s:rel(path, root) abort
  let p = fnamemodify(a:path, ':p')
  return stridx(p, a:root . '/') == 0 ? strpart(p, len(a:root) + 1) : p
endfunction

function! s:abs(file, root) abort
  return a:file[0] ==# '/' ? a:file : a:root . '/' . a:file
endfunction

" ------------------------------------------------------------------ persistence

function! s:load() abort
  if s:loaded
    return
  endif
  let s:loaded = 1
  let f = s:store()
  if !filereadable(f) || !exists('*json_decode')
    return
  endif
  try
    let data = json_decode(join(readfile(f), "\n"))
    if type(data) == v:t_dict
      let s:marks = data
    endif
  catch
    call s:err('could not read ' . f . ', starting empty')
  endtry
endfunction

function! sand#harpoon#save() abort
  if !exists('*json_encode')
    return
  endif
  let f = s:store()
  let dir = fnamemodify(f, ':h')
  if !isdirectory(dir)
    call mkdir(dir, 'p')
  endif
  call writefile([json_encode(s:marks)], f)
endfunction

" ----------------------------------------------------------------- mark list

function! s:list(root) abort
  call s:load()
  if !has_key(s:marks, a:root)
    let s:marks[a:root] = []
  endif
  return s:marks[a:root]
endfunction

function! s:index_of(list, file) abort
  let i = 0
  for m in a:list
    if m.file ==# a:file
      return i
    endif
    let i += 1
  endfor
  return -1
endfunction

" -------------------------------------------------------------------- actions

function! sand#harpoon#add() abort
  if empty(expand('%'))
    call s:err('buffer has no file name')
    return
  endif
  let root = s:root()
  let list = s:list(root)
  let file = s:rel(expand('%:p'), root)

  let at = s:index_of(list, file)
  if at >= 0
    echo printf('harpoon: already marked (%d)', at + 1)
    return
  endif
  call add(list, {'file': file, 'lnum': line('.'), 'col': col('.')})
  call sand#harpoon#save()
  echo printf('harpoon: marked %d  %s', len(list), file)
endfunction

function! sand#harpoon#remove() abort
  let root = s:root()
  let list = s:list(root)
  let at = s:index_of(list, s:rel(expand('%:p'), root))
  if at < 0
    call s:err('this file is not marked')
    return
  endif
  call remove(list, at)
  call sand#harpoon#save()
  echo 'harpoon: unmarked, ' . len(list) . ' left'
endfunction

function! sand#harpoon#clear() abort
  let root = s:root()
  call s:load()
  let s:marks[root] = []
  call sand#harpoon#save()
  echo 'harpoon: cleared'
endfunction

function! sand#harpoon#go(n) abort
  let root = s:root()
  let list = s:list(root)
  if a:n < 1 || a:n > len(list)
    call s:err(printf('no mark %d (have %d)', a:n, len(list)))
    return
  endif
  call s:jump(list[a:n - 1], root)
endfunction

function! s:jump(mark, root) abort
  let path = s:abs(a:mark.file, a:root)
  if !filereadable(path)
    call s:err('gone: ' . a:mark.file)
    return
  endif
  execute 'edit' fnameescape(path)
  call cursor(max([1, get(a:mark, 'lnum', 1)]), max([1, get(a:mark, 'col', 1)]))
  normal! zz
endfunction

function! sand#harpoon#cycle(step) abort
  let root = s:root()
  let list = s:list(root)
  if empty(list)
    call s:err('no marks yet')
    return
  endif
  let at = s:index_of(list, s:rel(expand('%:p'), root))
  " Not on a marked file: start at the first one.
  let next = at < 0 ? 0 : (at + a:step + len(list)) % len(list)
  call s:jump(list[next], root)
endfunction

" Remember where we were, so jumping back lands on the right line.
function! sand#harpoon#track() abort
  if empty(expand('%')) || !s:loaded
    return
  endif
  let root = s:root()
  if !has_key(s:marks, root)
    return
  endif
  let at = s:index_of(s:marks[root], s:rel(expand('%:p'), root))
  if at >= 0
    let s:marks[root][at].lnum = line('.')
    let s:marks[root][at].col  = col('.')
  endif
endfunction

function! sand#harpoon#list() abort
  let root = s:root()
  let list = s:list(root)
  if empty(list)
    echo 'harpoon: no marks in ' . root
    return
  endif
  echo root
  let i = 1
  for m in list
    echo printf('  %d  %s:%d', i, m.file, get(m, 'lnum', 1))
    let i += 1
  endfor
endfunction

" ---------------------------------------------------------------------- menu

" An ordinary, editable buffer: delete lines to unmark, move them to reorder,
" :w to keep it. That is the whole editing model.
function! sand#harpoon#menu() abort
  let root = s:root()
  let list = s:list(root)
  let name = 'harpoon://' . fnamemodify(root, ':t')

  let win = bufwinnr(name)
  if win > 0
    execute win . 'wincmd w'
    return
  endif

  execute 'silent keepalt botright' max([5, len(list) + 2]) 'new' fnameescape(name)
  setlocal buftype=acwrite bufhidden=wipe noswapfile nobuflisted
  setlocal nonumber norelativenumber nowrap signcolumn=no
  let b:harpoon_root = root

  if !empty(list)
    call setline(1, map(copy(list), 'v:val.file'))
  endif
  setlocal nomodified

  nnoremap <buffer> <silent> <CR> :<C-u>call <SID>menu_open()<CR>
  " 'nomodified' first: the buffer is bufhidden=wipe, so closing it while
  " modified would be refused with E37 instead of discarding.
  nnoremap <buffer> <silent> q    :<C-u>setlocal nomodified <Bar> close<CR>

  augroup harpoon_menu
    autocmd! * <buffer>
    autocmd BufWriteCmd <buffer> call <SID>menu_save()
  augroup END
endfunction

function! s:menu_save() abort
  let root = b:harpoon_root
  let old  = s:list(root)
  let new  = []

  for line in getline(1, '$')
    let file = trim(line)
    if empty(file)
      continue
    endif
    " Carry the remembered position over for files that were already marked.
    let at = s:index_of(old, file)
    call add(new, at >= 0 ? old[at]
          \ : {'file': file, 'lnum': 1, 'col': 1})
  endfor

  let s:marks[root] = new
  call sand#harpoon#save()
  setlocal nomodified
  echo printf('harpoon: %d mark%s', len(new), len(new) == 1 ? '' : 's')
endfunction

function! s:menu_open() abort
  let root = b:harpoon_root
  let file = trim(getline('.'))
  if empty(file)
    return
  endif
  " Opening with pending edits keeps them rather than dropping them silently.
  if &modified
    call s:menu_save()
  endif
  let old = s:list(root)
  let at  = s:index_of(old, file)
  close
  call s:jump(at >= 0 ? old[at] : {'file': file, 'lnum': 1, 'col': 1}, root)
endfunction
