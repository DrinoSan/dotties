return {
	'petertriho/nvim-scrollbar',
	event = { 'BufReadPre', 'BufNewFile' },
	dependencies = 'EdenEast/nightfox.nvim',
	config = function()
		local nf_colors = require('nightfox.palette').load('nordfox')

		require('scrollbar').setup({
			marks = {
				Cursor = {
					text = "•",
					color = nf_colors.blue.base,
				},
				Search = {
					text = { '' },
					color = nf_colors.yellow.base,
				},
				Error = {
					text = { '' },
					color = nf_colors.red.base,
				},
				Warn = {
					text = { '' },
					color = nf_colors.orange.base,
				},
				Info = {
					text = { '' },
					color = nf_colors.blue.base,
				},
				Hint = {
					text = { '' },
					color = nf_colors.green.base,
				},
				Misc = {
					text = { "-", "=" },
					color = nf_colors.magenta.base,
				},
				GitAdd = {
					text = '',
					color = nf_colors.green.base,
				},
				GitChange = {
					text = '',
					color = nf_colors.yellow.base,
				},
				GitDelete = {
					text = '',
					color = nf_colors.red.base,
				},
			}
		})

		-- Enable GitSigns
		require("scrollbar.handlers.gitsigns").setup()
	end
}
