return {
	"rykunk21/agent.nvim",
	branch = "dev",
	build = "cargo build",
	config = function()
		require('agent').setup({

			vim.keymap.set('n', '<leader>af', ':AgentToggle<CR>'),
			ui = {

				border_style = 'rounded',
				window_width_ratio = 0.8,
				window_height_ratio = 0.6,
			},
		})
	end,
}
