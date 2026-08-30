" keyclue.vim - after a prefix key, show what can follow it

if exists('g:loaded_keyclue') || &compatible
  finish
endif
let g:loaded_keyclue = 1

let g:keyclue_desc     = get(g:, 'keyclue_desc', {})
let g:keyclue_triggers = get(g:, 'keyclue_triggers', ['<leader>'])
let g:keyclue_popup    = get(g:, 'keyclue_popup', 1)

command! KeyClueEnable  call sand#keyclue#enable()
command! KeyClueDisable call sand#keyclue#disable()
command! KeyClueToggle  call sand#keyclue#toggle()

if !get(g:, 'keyclue_enabled', 1)
  let g:keyclue_enabled = 0
  finish
endif

call sand#keyclue#enable()
