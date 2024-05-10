return {
	'fgheng/winbar.nvim',
	event = { 'BufEnter', 'BufWinEnter' },
	config = function()
		local nf_colors = require('nightfox.palette').load('nordfox')

		require('winbar').setup({
			enabled = true,
			show_file_path = true,
			show_symbols = true,
			colors = {
				path = nf_colors.fg3,
				file_name = nf_colors.pink.base,
				symbols = '',
			},
			icons = {
				file_icon_default = '',
				separator = '>',
				editor_state = '●',
				lock_icon = '',
			},
			exclude_filetype = {
				'help',
				'startify',
				'packer',
				'neogitstatus',
				'NvimTree',
				'Trouble',
				'alpha',
				'lir',
				'Outline',
				'spectre_panel',
				'toggleterm',
				'qf',
			}
		})
	end
}
