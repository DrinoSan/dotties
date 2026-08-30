" format.vim - run a formatter over the buffer, safely

if exists('g:loaded_format') || &compatible
  finish
endif
let g:loaded_format = 1

" key   = filetype
" cmd   = shell command, %s is replaced by the (escaped) path of the buffer
" mode  = 'filter'  text on stdin, formatted text on stdout   (default)
"         'inplace' the tool rewrites the file, we reload it
" range = printf template for formatting only a line range
let g:format_by_filetype = extend({
      \ 'c':      {'cmd': 'clang-format --assume-filename=%s', 'range': '--lines=%d:%d'},
      \ 'cpp':    {'cmd': 'clang-format --assume-filename=%s', 'range': '--lines=%d:%d'},
      \ 'objc':   {'cmd': 'clang-format --assume-filename=%s', 'range': '--lines=%d:%d'},
      \ 'rust':   {'cmd': 'rustfmt --emit stdout --quiet'},
      \ 'go':     {'cmd': 'gofmt'},
      \ 'python': {'cmd': 'black --quiet -'},
      \ 'json':   {'cmd': 'python3 -m json.tool --indent 2'},
      \ }, get(g:, 'format_by_filetype', {}))

let g:format_on_save = get(g:, 'format_on_save', [])

command! -range=% Format     call sand#format#run(<line1>, <line2>)
command! -range=% -nargs=1 -complete=shellcmd
      \ FormatWith call sand#format#with(<q-args>, <line1>, <line2>)
command! -nargs=1 -complete=shellcmd
      \ FormatFile call sand#format#file(<q-args>)

augroup format_on_save
  autocmd!
  autocmd BufWritePre * call sand#format#on_save()
augroup END

nnoremap <silent> <Plug>Format :<C-u>Format<CR>
xnoremap <silent> <Plug>Format :Format<CR>

if get(g:, 'format_no_mappings', 0)
  finish
endif

nmap <leader>f <Plug>Format
xmap <leader>f <Plug>Format
