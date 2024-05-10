return {
	'romgrk/nvim-treesitter-context',
	opts = {
		enable = true,
		throttle = true,
		max_lines = 0,
		patterns = {
			default = {
				'class',
				'function',
				'method',
				'for',
				'if',
				'switch',
				'case',
			},
		}
	}
}
