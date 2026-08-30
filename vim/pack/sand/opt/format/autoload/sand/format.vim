" Run a formatter over the buffer without destroying it when the tool fails.

function! s:err(msg) abort
  echohl ErrorMsg | echomsg 'Format: ' . a:msg | echohl None
endfunction

" A name to hand the formatter so it can find the project style file even
" though the text arrives on stdin.
function! s:name() abort
  let p = expand('%:p')
  return !empty(p) ? p : getcwd() . '/buffer' . (empty(&filetype) ? '' : '.' . &filetype)
endfunction

function! s:expand(cmd) abort
  return substitute(a:cmd, '%s', escape(shellescape(s:name()), '\&~'), 'g')
endfunction

" stdin -> stdout over lines [first, last]. Preferred: keeps undo history and
" never touches the disk.
function! s:filter(cmd, first, last) abort
  let old = getline(a:first, a:last)
  " systemlist() puts no NL after the last item. A trailing empty item adds
  " one, so the formatter sees what it would have read from the file.
  let out = systemlist(a:cmd, &endofline ? old + [''] : old)

  if v:shell_error
    " systemlist() left the buffer untouched, so there is nothing to undo.
    call s:err(printf('exit %d: %s', v:shell_error, join(out[0:1], ' ')))
    return 0
  endif
  if empty(out)
    call s:err('formatter produced no output, buffer left alone')
    return 0
  endif
  if out ==# old
    return 1
  endif

  let view    = winsaveview()
  let emptied = (a:first == 1 && a:last == line('$'))
  silent execute a:first . ',' . a:last . ' delete _'
  call append(a:first - 1, out)
  " Deleting every line in a buffer leaves one empty line behind.
  if emptied
    silent execute (len(out) + 1) . ' delete _'
  endif
  call winrestview(view)
  return 1
endfunction

" For tools that insist on rewriting the file themselves (clang-format -i,
" workflowUtil -F -f). Write first, format, then reload.
function! s:inplace(cmd) abort
  if &modified
    silent write
  endif
  let out = systemlist(a:cmd)
  if v:shell_error
    call s:err(printf('exit %d: %s', v:shell_error, join(out[0:1], ' ')))
    return 0
  endif
  let view = winsaveview()
  silent edit!
  call winrestview(view)
  return 1
endfunction

function! s:run(spec, first, last) abort
  let cmd = s:expand(get(a:spec, 'cmd', ''))
  if empty(cmd)
    call s:err('no command configured')
    return 0
  endif

  let mode = get(a:spec, 'mode', 'filter')
  if mode ==# 'inplace'
    return s:inplace(cmd)
  endif

  let whole = (a:first == 1 && a:last == line('$'))
  let range = get(a:spec, 'range', '')

  " The tool can format a sub range itself. It still wants the whole file on
  " stdin - it needs the surrounding context - and returns the whole file.
  if !empty(range) && !whole
    return s:filter(cmd . ' ' . printf(range, a:first, a:last), 1, line('$'))
  endif

  " Otherwise send just the selected lines through, like :'<,'>!cmd does.
  return s:filter(cmd, a:first, a:last)
endfunction

" :Format
function! sand#format#run(first, last) abort
  let table = get(g:, 'format_by_filetype', {})
  if !has_key(table, &filetype)
    call s:err('no formatter for filetype ' . string(&filetype))
    return
  endif
  call s:run(table[&filetype], a:first, a:last)
endfunction

" :FormatWith {cmd}
function! sand#format#with(cmd, first, last) abort
  call s:run({'cmd': a:cmd}, a:first, a:last)
endfunction

 " :FormatFile {cmd} - for tools that only know how to rewrite a file.
function! sand#format#file(cmd) abort
  call s:run({'cmd': a:cmd, 'mode': 'inplace'}, 1, line('$'))
endfunction

function! sand#format#on_save() abort
  let table = get(g:, 'format_by_filetype', {})
  if index(get(g:, 'format_on_save', []), &filetype) < 0
        \ || !has_key(table, &filetype)
    return
  endif
  " Only stdin formatters are safe here: an in-place one would recurse
  " through BufWritePre.
  if get(table[&filetype], 'mode', 'filter') !=# 'filter'
    return
  endif
  call s:run(table[&filetype], 1, line('$'))
endfunction
