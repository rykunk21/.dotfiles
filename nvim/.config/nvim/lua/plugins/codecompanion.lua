return {
	'olimorris/codecompanion.nvim',
	dependencies = {
		'nvim-lua/plenary.nvim',
		'nvim-treesitter/nvim-treesitter',
	},
	opts = {
		display = {
			chat = {
				window = {
					layout = 'vertical',
					position = 'right',
					width = 0.3,      -- fraction of the editor width
					full_height = true, -- span the full editor height
				},
			}
		},
		adapters = {
			http = { -- older versions: put `ollama = ...` directly under `adapters`
				ollama = function()
					return require('codecompanion.adapters').extend('ollama', {
						env = { url = 'http:/localhost:11434' },
						schema = {
							model   = { default = 'kimi-k2.6:cloud' },
							num_ctx = { default = 16384 },
						},
					})
				end,
			},
		},
		strategies = {
			chat   = { adapter = 'ollama' },
			inline = { adapter = 'ollama' },
		},
	},
	keys = {
		{ '<leader>ai', '<cmd>CodeCompanionChat Toggle<cr>', desc = 'AI chat' },
	},
}
