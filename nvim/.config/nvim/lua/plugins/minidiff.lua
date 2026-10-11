return {
	'nvim-mini/mini.diff',
	version = false,
	event = 'VeryLazy',
	opts = {
		view = {
			style = vim.go.number and 'number' or 'sign',
			signs = { add = '▒', change = '▒', delete = '▒' },
			priority = 199,
		},
		mappings = {
			apply = 'gh',
			reset = 'gH',
			textobject = 'gh',
			goto_first = '[H',
			goto_prev = '[h',
			goto_next = ']h',
			goto_last = ']H',
		},
		options = {
			algorithm = 'histogram',
			indent_heuristic = true,
			linematch = 60,
			wrap_goto = false,
		},
	},
	keys = {
		{
			'<leader>go',
			function() require('mini.diff').toggle_overlay(0) end,
			desc = 'Toggle diff overlay',
		},
	},
	config = function(_, opts)
		require('mini.diff').setup(opts)

		-- Overlay colors (re-applied after colorscheme changes). Adjust to taste.
		local function set_overlay_hl()
			vim.api.nvim_set_hl(0, 'MiniDiffOverAdd', { bg = '#1f3d2b' })
			vim.api.nvim_set_hl(0, 'MiniDiffOverDelete', { bg = '#4a1f24', fg = '#e06c75' })
			vim.api.nvim_set_hl(0, 'MiniDiffOverChange', { bg = '#5a4a1a' })
			vim.api.nvim_set_hl(0, 'MiniDiffOverContext', { fg = '#7f849c' })
		end

		set_overlay_hl()
		vim.api.nvim_create_autocmd('ColorScheme', { callback = set_overlay_hl })
	end,
}
