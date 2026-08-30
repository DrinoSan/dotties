" pick - an interactive fuzzy picker built out of a popup and getchar().

let s:winid = 0

function! s:err(msg) abort
  echohl ErrorMsg | echomsg 'pick: ' . a:msg | echohl None
endfunction

function! s:exists(bin) abort
  return executable(a:bin)
endfunction

function! s:in_repo() abort
  call system('git rev-parse --is-inside-work-tree')
  return !v:shell_error
endfunction

" ------------------------------------------------------------------ sources

" Fastest available way to list the files of this project.
function! s:files_command() abort
  if !empty(get(g:, 'pick_files_command', ''))
    return g:pick_files_command
  endif
  if s:exists('rg')
    return 'rg --files --hidden --glob !.git'
  endif
  if s:in_repo()
    return 'git ls-files --cached --others --exclude-standard'
  endif
  return "find . -type f -not -path '*/.git/*'"
endfunction

" Grep backends all normalise to  file:line[:col]:text
function! s:grep_command(query) abort
  let pat = shellescape(a:query)
  if !empty(get(g:, 'pick_grep_command', ''))
    return substitute(g:pick_grep_command, '%s', escape(pat, '\&~'), 'g')
  endif
  if s:exists('rg')
    return 'rg --vimgrep --smart-case --no-heading --color=never -- ' . pat
  endif
  if s:in_repo()
    return 'git grep -I -n --column --no-color -e ' . pat
  endif
  " Portable enough for both GNU and BSD grep.
  return 'grep -rIn --exclude-dir=.git -e ' . pat . ' .'
endfunction

function! s:parse_grep(line) abort
  " file:line:col:text  or  file:line:text
  let m = matchlist(a:line, '^\(.\{-}\):\(\d\+\):\(\d\+\):\(.*\)$')
  if !empty(m)
    return {'text': a:line, 'file': m[1], 'lnum': str2nr(m[2]), 'col': str2nr(m[3])}
  endif
  let m = matchlist(a:line, '^\(.\{-}\):\(\d\+\):\(.*\)$')
  if !empty(m)
    return {'text': a:line, 'file': m[1], 'lnum': str2nr(m[2]), 'col': 1}
  endif
  return {'text': a:line, 'file': '', 'lnum': 0, 'col': 1}
endfunction

" ---------------------------------------------------------------- filtering

function! s:filter(items, query) abort
  if empty(a:query)
    return a:items
  endif
  if exists('*matchfuzzy')
    return matchfuzzy(a:items, a:query, {'key': 'text'})
  endif
  " Fallback: every whitespace separated word must appear, case insensitive.
  let words = split(tolower(a:query))
  return filter(copy(a:items),
        \ 's:all_in(tolower(v:val.text), words)')
endfunction

function! s:all_in(hay, words) abort
  for w in a:words
    if stridx(a:hay, w) < 0
      return 0
    endif
  endfor
  return 1
endfunction

" ------------------------------------------------------------------- render

function! s:height() abort
  return max([5, min([get(g:, 'pick_height', 15), &lines - 6])])
endfunction

function! s:render(st) abort
  let h     = s:height()
  let shown = a:st.matches[0 : get(g:, 'pick_max', 500) - 1]
  let lines = empty(shown) ? ['  (no matches)'] : map(copy(shown), 'v:val.text')

  if !s:winid
    let s:winid = popup_create(lines, {
          \ 'line': &lines - 3, 'col': 2, 'pos': 'botleft',
          \ 'minwidth': &columns - 6, 'maxwidth': &columns - 6,
          \ 'minheight': h, 'maxheight': h,
          \ 'border': [], 'padding': [0, 1, 0, 1],
          \ 'wrap': 0, 'cursorline': 1, 'scrollbar': 1,
          \ 'zindex': 200, 'highlight': 'Normal',
          \ })
  else
    call popup_settext(s:winid, lines)
  endif

  " Keep the selection inside the visible window ourselves; a popup has no
  " cursor of its own to scroll for us.
  let idx   = a:st.index + 1
  let first = max([1, min([idx - h / 2, len(lines) - h + 1])])
  call popup_setoptions(s:winid, {
        \ 'title': printf(' %s  %d/%d ', a:st.prompt,
        \                 empty(a:st.matches) ? 0 : idx, len(a:st.matches)),
        \ 'firstline': first,
        \ })
  call win_execute(s:winid, 'call cursor(' . idx . ', 1)')

  redraw
  echohl Question | echo '> ' . a:st.query | echohl None
endfunction

function! s:close() abort
  if s:winid
    call popup_close(s:winid)
    let s:winid = 0
  endif
  redraw
  echo ''
endfunction

" -------------------------------------------------------------------- open

function! s:open(item, how) abort
  let nr = get(a:item, 'bufnr', 0)

  " Prefer the buffer number when we have one: :buffer keeps the position we
  " left it at, and it works for buffers with no file name at all.
  if nr > 0 && bufexists(nr)
    execute {'edit': 'buffer', 'split': 'sbuffer',
          \ 'vsplit': 'vertical sbuffer', 'tab': 'tab sbuffer'}[a:how] nr
  elseif !empty(get(a:item, 'file', ''))
    execute {'edit': 'edit', 'split': 'split',
          \ 'vsplit': 'vsplit', 'tab': 'tabedit'}[a:how] fnameescape(a:item.file)
  else
    return
  endif

  if get(a:item, 'lnum', 0) > 0
    call cursor(a:item.lnum, max([1, get(a:item, 'col', 1)]))
    normal! zz
  endif
endfunction

function! s:to_quickfix(items, what) abort
  let qf = []
  for it in a:items
    if empty(get(it, 'file', ''))
      continue
    endif
    call add(qf, {'filename': it.file, 'lnum': get(it, 'lnum', 1),
          \ 'col': get(it, 'col', 1), 'text': get(it, 'text', '')})
  endfor
  call setqflist([], ' ', {'title': a:what, 'items': qf})
  copen
endfunction

" ------------------------------------------------------------------- driver

function! s:getkey() abort
  if exists('*getcharstr')
    return getcharstr()
  endif
  let c = getchar()
  return type(c) == v:t_number ? nr2char(c) : c
endfunction

" A single printable character, i.e. something the user meant to type into
" the query rather than a control or special key.
function! s:printable(c) abort
  return strchars(a:c) == 1 && a:c =~# '^\%(\p\|[^\x00-\x7f]\)$'
endfunction

" getchar(1) peeks without consuming, but returns a String for special keys.
function! s:pending() abort
  let peek = getchar(1)
  return type(peek) == v:t_number ? peek != 0 : 1
endfunction

" opts.prompt   title text
" opts.items    list of entries, for a static source
" opts.dynamic  funcref(query) -> list of entries, re-run as you type
" opts.min      minimum query length before a dynamic source runs
function! sand#pick#run(opts) abort
  if !has('popupwin')
    call s:err('interactive picking needs vim with +popupwin')
    return
  endif

  let st = {'query': get(a:opts, 'query', ''), 'index': 0,
        \ 'prompt': get(a:opts, 'prompt', 'pick'),
        \ 'all': get(a:opts, 'items', []), 'matches': []}
  " Capitalised: legacy vimscript refuses a lowercase local holding a Funcref.
  let Dynamic = get(a:opts, 'dynamic', 0)
  let minlen  = get(a:opts, 'min', 2)
  let dirty   = 1
  " A key read by the debounce loop that it could not handle itself.
  let carry   = ''

  try
    while 1
      if dirty
        if type(Dynamic) == v:t_func
          let st.all = len(st.query) >= minlen ? Dynamic(st.query) : []
          let st.matches = st.all
        else
          let st.matches = s:filter(st.all, st.query)
        endif
        let st.index = 0
        let dirty = 0
      endif
      call s:render(st)

      let c = empty(carry) ? s:getkey() : carry
      let carry = ''
      let last = len(st.matches) - 1

      if empty(c) || c ==# "\<Esc>" || c ==# "\<C-c>"
        return
      elseif c ==# "\<CR>" || c ==# "\<C-v>" || c ==# "\<C-x>" || c ==# "\<C-t>"
        if empty(st.matches)
          continue
        endif
        let how = {"\<CR>": 'edit', "\<C-v>": 'vsplit',
              \ "\<C-x>": 'split', "\<C-t>": 'tab'}[c]
        let item = st.matches[st.index]
        call s:close()
        call s:open(item, how)
        return
      elseif c ==# "\<C-q>"
        let items = st.matches
        call s:close()
        call s:to_quickfix(items, st.prompt)
        return
      elseif c ==# "\<C-n>" || c ==# "\<Down>"
        let st.index = last < 0 ? 0 : (st.index >= last ? 0 : st.index + 1)
      elseif c ==# "\<C-p>" || c ==# "\<Up>"
        let st.index = last < 0 ? 0 : (st.index <= 0 ? last : st.index - 1)
      elseif c ==# "\<BS>" || c ==# "\<C-h>"
        let st.query = strcharpart(st.query, 0, strchars(st.query) - 1)
        let dirty = 1
      elseif c ==# "\<C-u>"
        let st.query = ''
        let dirty = 1
      elseif s:printable(c)
        let st.query .= c
        let dirty = 1
      endif

      " Debounce: while the user is still typing, do not run the search yet.
      while dirty && s:pending()
        let c = s:getkey()
        if c ==# "\<BS>" || c ==# "\<C-h>"
          let st.query = strcharpart(st.query, 0, strchars(st.query) - 1)
        elseif s:printable(c)
          let st.query .= c
        else
          " Not ours to handle. Hand it to the main loop rather than
          " feeding it back - feedkeys() would append it behind the keys
          " still queued and scramble the order.
          let carry = c
          break
        endif
      endwhile
    endwhile
  finally
    call s:close()
  endtry
endfunction

" ------------------------------------------------------------------ pickers

function! sand#pick#files(...) abort
  let dir = a:0 && !empty(a:1) ? a:1 : '.'
  let out = systemlist('cd ' . shellescape(dir) . ' && ' . s:files_command())
  if v:shell_error
    call s:err('listing files failed: ' . join(out[0:1], ' '))
    return
  endif
  let prefix = dir ==# '.' ? '' : substitute(dir, '/*$', '/', '')

  " Mark the ones that are already open, so the file list doubles as a
  " "what am I working on" view.
  let open = {}
  for b in getbufinfo({'buflisted': 1})
    if !empty(b.name)
      let open[fnamemodify(b.name, ':p')] = 1
    endif
  endfor

  let items = []
  for f in out
    let path = prefix . f
    call add(items, {'file': path,
          \ 'text': printf('%s %s',
          \   has_key(open, fnamemodify(path, ':p')) ? '+' : ' ', path)})
  endfor
  call sand#pick#run({'prompt': 'files', 'items': items})
endfunction

function! sand#pick#grep(...) abort
  let seed = a:0 ? a:1 : ''
  call sand#pick#run({'prompt': 'grep', 'query': seed,
        \ 'min': get(g:, 'pick_grep_min', 2),
        \ 'dynamic': function('sand#pick#grep_source')})
endfunction

function! sand#pick#grep_source(query) abort
  let out = systemlist(s:grep_command(a:query))
  " grep exits 1 when there are simply no matches; that is not an error.
  if v:shell_error > 1
    return []
  endif
  return map(out[0 : get(g:, 'pick_max', 500) - 1], 's:parse_grep(v:val)')
endfunction

function! sand#pick#buffers() abort
  let items = []
  for b in getbufinfo({'buflisted': 1})
    let name = empty(b.name) ? '[No Name]' : fnamemodify(b.name, ':~:.')
    " No lnum: :buffer restores the position on its own.
    call add(items, {'text': printf('%3d %s %s', b.bufnr,
          \ b.changed ? '+' : ' ', name),
          \ 'bufnr': b.bufnr, 'file': b.name})
  endfor
  call sand#pick#run({'prompt': 'buffers', 'items': items})
endfunction

function! sand#pick#lines() abort
  let file  = expand('%:p')
  let items = []
  let n = 1
  for l in getline(1, '$')
    call add(items, {'text': printf('%5d  %s', n, l), 'file': file, 'lnum': n})
    let n += 1
  endfor
  call sand#pick#run({'prompt': 'lines', 'items': items})
endfunction
