return {
	'nvim-lualine/lualine.nvim',
	dependencies = { 'kyazdani42/nvim-web-devicons' },
	opts = {
		options = {
			theme = 'nordfox',
			globalstatus = true,
			component_separators = { left = '/', right = '\\' },
			section_separators = { left = '', right = '' },
		},
		sections = {
			lualine_a = {
			{ 'mode' },
			},
			lualine_b = { 'filename', 'branch', 'diff', 'diagnostics' },
			lualine_c = {},
			lualine_x = {},
			lualine_y = {
				'searchcount',
				'fileformat',
				{ 'filetype', icon_only = true },
				'progress' },
			lualine_z = {
				{ 'location' },
			},
		},
		inactive_sections = {
			lualine_a = {},
			lualine_b = {},
			lualine_c = {},
			lualine_x = {},
			lualine_y = {},
			lualine_z = {}
		},
	}
}
