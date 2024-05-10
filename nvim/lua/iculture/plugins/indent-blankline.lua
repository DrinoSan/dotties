return {
	'lukas-reineke/indent-blankline.nvim',
	event = { 'BufReadPre', 'BufNewFile' },
	main = "ibl",
	opts = {
		indent = {
			highlight = {
				'IndentBlanklineIndent1',
				'IndentBlanklineIndent2',
				'IndentBlanklineIndent3',
				'IndentBlanklineIndent4',
				'IndentBlanklineIndent5',
				'IndentBlanklineIndent6',
			}
		}
	}
}
