return {
	'nvim-telescope/telescope.nvim',
	dependencies = {
		'nvim-lua/plenary.nvim',
		'kyazdani42/nvim-web-devicons',
		'nvim-telescope/telescope-file-browser.nvim',
		'Slotos/telescope-lsp-handlers.nvim',
		'nvim-telescope/telescope-project.nvim',
		{ 'nvim-telescope/telescope-fzf-native.nvim', run = 'make' }
	},
	config = function()
		local telescope = require('telescope')

		telescope.setup({
			defaults = {
				file_ignore_patterns = {
					'node_modules',
					'vendor',
					'%.map',
					'%.log',
					'%.min.js',
					'static'
				},
				prompt_prefix = "   ",
				selection_caret = "  ",
				entry_prefix = "  ",
				initial_mode = "insert",
				sorting_strategy = "ascending",
				layout_config = {
					horizontal = {
						prompt_position = "top",
						preview_width = 0.55,
						results_width = 0.8,
					},
				},
				set_env = { ["COLORTERM"] = "truecolor" },
			},
			extensions = {
				file_browser = {
					theme = 'ivy',
					-- disables netrw and use telescope-file-browser in its place
					hijack_netrw = true,
				},
				project = {
					base_dirs = {
						'~/Repos/',
					},
					hidden_files = true,
					theme = "dropdown",
					order_by = "asc",
					sync_with_nvim_tree = true,
				},
				fzf = {
					fuzzy = true,
					override_generic_sorter = true,
					override_file_sorter = true,
					case_mode = "smart_case",
				},
			},
		})

		-- Enable telescope extensions
		telescope.load_extension('file_browser')
		telescope.load_extension('project')
		require('telescope-lsp-handlers').setup()
-- Mapping for Telescope
local builtin = require('telescope.builtin')

vim.keymap.set('n', '<leader>ff', builtin.find_files, {})
vim.keymap.set('n', '<leader>fo', builtin.oldfiles, {})
vim.keymap.set('n', '<leader>fr', builtin.live_grep, {})
vim.keymap.set('n', '<leader>fs', builtin.lsp_document_symbols, {})
vim.keymap.set('n', '<leader>fw', builtin.lsp_workspace_symbols, {})
vim.keymap.set('n', '<leader>fl', builtin.diagnostics, {})
vim.keymap.set('n', '<leader>fg', builtin.git_files, {})
vim.keymap.set('n', '<leader>fh', builtin.help_tags, {})
vim.keymap.set('n', '<leader>fb', telescope.extensions.file_browser.file_browser, {})
vim.keymap.set('n', '<leader>fp', telescope.extensions.project.project, {})
	end
}
