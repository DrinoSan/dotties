return {
	'EdenEast/nightfox.nvim',
	priority = 1000,
	config = function()
		-- Setup color scheme
		local nightfox = require('nightfox')
		local nf_colors = require('nightfox.palette').load('nordfox')

		-- Setup Nightfox
		nightfox.setup({
			options = {
				transparent = true,
				styles = {
					comments = 'italic',
					functions = 'bold',
				}
			},
		})

		-- Set theme global
		vim.api.nvim_command('colorscheme nordfox')
		vim.api.nvim_set_hl(0, 'Normal', { bg = 'none' })
		vim.api.nvim_set_hl(0, 'NormalFloat', { bg = 'none' })

		-- Set colors for indentation
		vim.api.nvim_set_hl(0, 'IndentBlanklineIndent1', { fg = nf_colors.yellow.base })
		vim.api.nvim_set_hl(0, 'IndentBlanklineIndent2', { fg = nf_colors.blue.base })
		vim.api.nvim_set_hl(0, 'IndentBlanklineIndent3', { fg = nf_colors.orange.base })
		vim.api.nvim_set_hl(0, 'IndentBlanklineIndent4', { fg = nf_colors.magenta.base })
		vim.api.nvim_set_hl(0, 'IndentBlanklineIndent5', { fg = nf_colors.green.base })
		vim.api.nvim_set_hl(0, 'IndentBlanklineIndent6', { fg = nf_colors.red.base })

		-- Set color for Codeium in [nvim-cmp]
		vim.api.nvim_set_hl(0, 'CmpItemKindCodeium', { fg = nf_colors.yellow.base })
	end
}
