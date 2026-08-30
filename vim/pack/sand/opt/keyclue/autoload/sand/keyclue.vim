" keyclue - show which keys can follow a prefix, and what they do.

let s:popup = 0

function! s:err(msg) abort
  echohl ErrorMsg | echomsg 'keyclue: ' . a:msg | echohl None
endfunction

" ---------------------------------------------------------------- key codes

" "<Space>kb" -> the actual bytes vim would receive.
function! s:key2char(m) abort
  try
    return eval('"\' . a:m . '"')
  catch
    return a:m
  endtry
endfunction

function! s:raw(disp) abort
  return substitute(a:disp, '<[^<>]\{-}>', '\=s:key2char(submatch(0))', 'g')
endfunction

" Raw bytes -> the <> notation a human (and :map) understands.
function! s:disp(keys) abort
  return exists('*keytrans') ? keytrans(a:keys) : a:keys
endfunction

" First whole key of a raw string. Special keys arrive as a 3 byte sequence
" introduced by K_SPECIAL (0x80), everything else is one character.
function! s:first_key(s) abort
  if empty(a:s)
    return ''
  endif
  if strpart(a:s, 0, 1) ==# "\x80"
    return strpart(a:s, 0, 3)
  endif
  return strcharpart(a:s, 0, 1)
endfunction

function! s:getkey() abort
  if exists('*getcharstr')
    return getcharstr()
  endif
  let c = getchar()
  return type(c) == v:t_number ? nr2char(c) : c
endfunction

function! sand#keyclue#raw(disp) abort
  return s:raw(substitute(a:disp, '<leader>',
        \ escape(get(g:, 'mapleader', '\'), '\&~'), 'g'))
endfunction

" -------------------------------------------------------------- the mappings

function! s:mappings() abort
  if exists('*maplist')
    let out = []
    for m in maplist()
      if get(m, 'abbr', 0) || !(m.mode ==# ' ' || m.mode =~# 'n')
        continue
      endif
      call add(out, {'lhs': m.lhs, 'lhsraw': get(m, 'lhsraw', s:raw(m.lhs)),
            \ 'rhs': get(m, 'rhs', '')})
    endfor
    return out
  endif

  " Older vim: parse :nmap output. Mode flags occupy the first three columns.
  let out = []
  for line in split(execute('nmap'), "\n")
    let m = matchlist(line, '^\(.\{3}\)\(\S\+\)\s\+\(.*\)$')
    if empty(m)
      continue
    endif
    call add(out, {'lhs': m[2], 'lhsraw': s:raw(m[2]),
          \ 'rhs': substitute(m[3], '^[*&@ ]\+', '', '')})
  endfor
  return out
endfunction

" g:keyclue_desc is written with <leader>; index it by raw keys instead.
function! s:descriptions() abort
  let out = {}
  for [k, v] in items(get(g:, 'keyclue_desc', {}))
    let out[sand#keyclue#raw(k)] = v
  endfor
  return out
endfunction

function! s:candidates(all, keys) abort
  let n = len(a:keys)
  return filter(copy(a:all),
        \ 'len(v:val.lhsraw) > n && strpart(v:val.lhsraw, 0, n) ==# a:keys')
endfunction

function! s:exact(all, keys) abort
  let hit = filter(copy(a:all), 'v:val.lhsraw ==# a:keys')
  return empty(hit) ? {} : hit[0]
endfunction

" ------------------------------------------------------------------ display

function! s:trim(s, width) abort
  let s = substitute(a:s, '\_s\+', ' ', 'g')
  return len(s) > a:width ? strpart(s, 0, a:width - 1) . '~' : s
endfunction

function! s:lines(keys, cands, desc, exact) abort
  let groups = {}
  for c in a:cands
    let rest = strpart(c.lhsraw, len(a:keys))
    let key  = s:disp(s:first_key(rest))
    if !has_key(groups, key)
      let groups[key] = {'n': 0, 'label': ''}
    endif
    let groups[key].n += 1
    " This key completes a mapping rather than opening a submenu.
    if len(rest) == len(s:first_key(rest))
      let groups[key].label = get(a:desc, c.lhsraw, s:trim(c.rhs, 46))
    endif
  endfor

  let lines = []
  if !empty(a:exact)
    call add(lines, printf('%-7s %s', '<CR>',
          \ get(a:desc, a:exact.lhsraw, s:trim(a:exact.rhs, 46))))
  endif
  for key in sort(keys(groups))
    let g = groups[key]
    let label = !empty(g.label) ? g.label : printf('+%d mappings', g.n)
    call add(lines, printf('%-7s %s', key, label))
  endfor
  return lines
endfunction

function! s:show(keys, lines) abort
  call s:close()
  let title = ' ' . s:disp(a:keys) . ' '

  if has('popupwin') && get(g:, 'keyclue_popup', 1)
    let s:popup = popup_create(a:lines, {
          \ 'title': title,
          \ 'line': &lines - 1, 'col': 1, 'pos': 'botleft',
          \ 'border': [], 'padding': [0, 1, 0, 1],
          \ 'minwidth': 24, 'maxheight': max([5, &lines / 2]),
          \ 'zindex': 300, 'highlight': 'Pmenu',
          \ })
    redraw
    return
  endif

  " No popup support: fall back to echoing the list.
  echohl Title | echo title | echohl None
  for l in a:lines[0 : &lines - 4]
    echo l
  endfor
endfunction

function! s:close() abort
  if s:popup
    call popup_close(s:popup)
    let s:popup = 0
  endif
endfunction

" ------------------------------------------------------------------ execute

" Resolve the mapping ourselves. Feeding the raw key sequence back would
" re-enter the trigger mapping and loop forever.
function! s:execute(keys) abort
  let m = maparg(s:disp(a:keys), 'n', 0, 1)
  if empty(m) || !has_key(m, 'rhs')
    call feedkeys(a:keys, 'nt')
    return
  endif

  let rhs = m.rhs
  if get(m, 'expr', 0)
    try
      let rhs = eval(rhs)
    catch
      call s:err('<expr> mapping failed: ' . v:exception)
      return
    endtry
  endif
  let rhs = substitute(rhs, '<SID>', '<SNR>' . get(m, 'sid', 0) . '_', 'g')
  " noremap -> feed literally; map -> allow <Plug> and friends to resolve.
  call feedkeys(s:raw(rhs), get(m, 'noremap', 0) ? 'nt' : 'mt')
endfunction

" -------------------------------------------------------------------- driver

function! sand#keyclue#start(prefix) abort
  let all   = s:mappings()
  let desc  = s:descriptions()
  let stack = [a:prefix]

  try
    while 1
      let keys  = join(stack, '')
      let cands = s:candidates(all, keys)

      if empty(cands)
        " Nothing follows this prefix. Run it if it is a mapping by itself.
        if len(stack) > 1
          call s:close()
          call s:execute(keys)
        endif
        return
      endif

      let exact = s:exact(all, keys)
      call s:show(keys, s:lines(keys, cands, desc, exact))

      let c = s:getkey()
      if empty(c) || c ==# "\<Esc>" || c ==# "\<C-c>"
        return
      endif

      if (c ==# "\<BS>" || c ==# "\<C-h>") && len(stack) > 1
        call remove(stack, -1)
        continue
      endif

      " <CR> disambiguates "run the prefix itself" from "keep drilling down".
      if c ==# "\<CR>" && !empty(exact)
        call s:close()
        call s:execute(keys)
        return
      endif

      call add(stack, c)
      let keys = join(stack, '')
      if empty(s:candidates(all, keys))
        call s:close()
        call s:execute(keys)
        return
      endif
    endwhile
  finally
    call s:close()
    redraw
  endtry
endfunction

" ------------------------------------------------------------------- on/off

function! s:triggers() abort
  return get(g:, 'keyclue_triggers', ['<leader>'])
endfunction

function! sand#keyclue#enable() abort
  for t in s:triggers()
    execute printf('nnoremap <silent> %s :<C-u>call sand#keyclue#start(%s)<CR>',
          \ t, string(sand#keyclue#raw(t)))
  endfor
  let g:keyclue_enabled = 1
endfunction

function! sand#keyclue#disable() abort
  for t in s:triggers()
    execute 'silent! nunmap' t
  endfor
  let g:keyclue_enabled = 0
endfunction

function! sand#keyclue#toggle() abort
  if get(g:, 'keyclue_enabled', 0)
    call sand#keyclue#disable()
    echo 'keyclue off'
  else
    call sand#keyclue#enable()
    echo 'keyclue on'
  endif
endfunction
