" Lazily loaded: only sourced the first time sand#tmux#navigate() is called.

function! sand#tmux#navigate(direction) abort
  let oldwin = winnr()
  execute 'wincmd' a:direction

  " Still in the same window -> there was no vim window that way, so hand the
  " movement over to tmux instead.
  if !empty($TMUX) && winnr() == oldwin
    let sock = split($TMUX, ',')[0]
    let pane = tr(a:direction, 'hjkl', 'LDUR')
    silent execute printf('!tmux -S %s select-pane -%s', sock, pane)
    redraw!
  endif
endfunction
