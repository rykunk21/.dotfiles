return {
	'augmentcode/augment.vim',
	config = function()
		vim.keymap.set('n', '<leader>au', ':Augment chat<CR>', {})
	end
}
