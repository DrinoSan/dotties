-- Define leader key
vim.g.mapleader = " "

-- Mappings for NvimTree
vim.keymap.set('n', '<C-e>', '<Cmd>NvimTreeToggle<CR>', { desc = "Toggle NvimTree" })

-- Mapping for copy/paste
vim.keymap.set({ 'n', 'v' }, '<leader>y', [["+y]], { desc = "Copy to clipboard" })
vim.keymap.set('n', '<leader>Y', [[gg"+yG]])
vim.keymap.set('x', '<leader>p', [["_dP]])
vim.keymap.set('n', '<leader>v', [["+p]])

-- Autocmd to disable search highlights
vim.keymap.set('n', '<esc>', ':nohl<CR>', { desc = "Clear search highlights" })

-- Moving Text
vim.keymap.set('v', 'J', [[:m '>+1<CR>gv=gv]])
vim.keymap.set('v', 'K', [[:m '<-2<CR>gv=gv]])

-- Remaps to use blackhole reg by default
local map = vim.api.nvim_set_keymap
local options = { noremap = true, silent = true }
map('v', 'c', '"_c', options)
map('v', 'C', '"_C', options)
map('n', 'c', '"_c', options)
map('n', 'C', '"_C', options)

-- Nice Remap from [DrinoSan](https://github.com/DrinoSan) for interactive replacement.
vim.keymap.set('n', '<leader>x', '*``cgn', { desc = "Interactive replace items" })

-- Search and delete
-- nnoremap <expr><leader>ds ":%s/" . input("Delete: ") . "//g\<CR>"

-- Reload the config
vim.keymap.set('n', '<leader>rl', ':w<CR>:so%<CR>', { desc = "Reload neovim config" })

-- Go Compiling
vim.keymap.set('n', '<leader>gc', ':!go build %<CR>', { desc = "Go build" })
vim.keymap.set('n', '<leader>gr', ':!go run %<CR>', { desc = "Go run" })

-- Run current binary
vim.keymap.set('n', '<leader>rr', ':./%<', { desc = "Run current binary" })

-- Mapping for Quickfix List
vim.keymap.set('n', '<leader>q', '<Cmd>copen<CR>', { desc = "Open quickfix list" })
vim.keymap.set('n', '<leader>j', '<Cmd>cn<CR>', { desc = "Next in quickfix list" })
vim.keymap.set('n', '<leader>k', '<Cmd>cp<CR>', { desc = "Previous in quickfix list" })

-- Mapping for panes movement
vim.keymap.set('n', '<C-h>', '<C-w>h', { desc = "Move to left pane" })
vim.keymap.set('n', '<C-j>', '<C-w>j', { desc = "Move to below pane" })
vim.keymap.set('n', '<C-k>', '<C-w>k', { desc = "Move to above pane" })
vim.keymap.set('n', '<C-l>', '<C-w>l', { desc = "Move to right pane" })
vim.keymap.set('n', '<C-b>', '<C-w>H', { desc = "Move pane to left" })
vim.keymap.set('n', '<C-n>', '<C-w>L', { desc = "Move pane to right" })
vim.keymap.set('n', '<C-left>', '<C-w><', { desc = "Decrease pane width" })
vim.keymap.set('n', '<C-right>', '<C-w>>', { desc = "Increase pane width" })
vim.keymap.set('n', '<C-up>', '<C-w>+', { desc = "Increase pane height" })
vim.keymap.set('n', '<C-down>', '<C-w>-', { desc = "Decrease pane height" })

-- Mapping for Symbols Outline
vim.keymap.set('n', '<leader>so', ':SymbolsOutline<CR>')

-- Mapping for LSP Goto Definition
vim.keymap.set('n', '<leader>gv', ':vsplit<CR>gd')

-- Mapping for TODO
vim.keymap.set('n', '<leader>to', ':TodoTelescope keywords=TODO<CR>')

-- Mapping for Python Debugger
vim.keymap.set('n', '<leader>dm', [[:lua require('dap-python').test_method()<CR>]])
vim.keymap.set('n', '<leader>dc', [[:lua require('dap-python').test_class()<CR>]])
vim.keymap.set('n', '<leader>ds', [[<ESC>:lua require('dap-python').debug_selection()<CR>]])
