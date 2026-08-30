" Turns a dictionary of project paths into :find mappings.

" Each entry is  key : [path, description]
function! s:table() abort
  return get(g:, 'projectfind_paths', {})
endfunction

function! sand#projectfind#apply() abort
  let prefix = get(g:, 'projectfind_prefix', '<leader>')
  for [key, entry] in items(s:table())
    let path = type(entry) == v:t_list ? entry[0] : entry
    let lhs  = prefix . key
    " No <CR> on purpose: the path is left on the command line so that
    " wildmenu completion takes over from there.
    execute 'nnoremap' lhs ':find ' . escape(path, '|" ')

    " Hand the description to keyclue if that plugin is loaded.
    if type(entry) == v:t_list && len(entry) > 1
      let g:keyclue_desc = get(g:, 'keyclue_desc', {})
      let g:keyclue_desc[lhs] = entry[1]
    endif
  endfor
endfunction

function! sand#projectfind#list() abort
  let table = s:table()
  if empty(table)
    echo 'projectfind: g:projectfind_paths is empty'
    return
  endif
  let prefix = get(g:, 'projectfind_prefix', '<leader>')
  for key in sort(keys(table))
    let entry = table[key]
    let path  = type(entry) == v:t_list ? entry[0] : entry
    let desc  = type(entry) == v:t_list && len(entry) > 1 ? entry[1] : ''
    echo printf('%-14s %-24s %s', prefix . key, desc, path)
  endfor
endfunction

" :ProjectFind {key} - same as pressing the mapping.
function! sand#projectfind#go(key) abort
  let table = s:table()
  if !has_key(table, a:key)
    echohl ErrorMsg | echomsg 'projectfind: unknown key ' . a:key | echohl None
    return
  endif
  let entry = table[a:key]
  let path  = type(entry) == v:t_list ? entry[0] : entry
  call feedkeys(':find ' . path, 'nt')
endfunction

function! sand#projectfind#complete(A, L, P) abort
  return filter(sort(keys(s:table())), 'stridx(v:val, a:A) == 0')
endfunction
