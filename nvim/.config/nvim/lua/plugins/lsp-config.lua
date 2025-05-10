return {
	{
		"williamboman/mason.nvim",

		config = function()
			require("mason").setup()
		end
	},
	{
		"williamboman/mason-lspconfig.nvim",
		config = function()
			require("mason-lspconfig").setup {
				ensure_installed = {
					"lua_ls", "rust_analyzer"
				}
			}
		end
	},
	{
		"neovim/nvim-lspconfig",
		config = function()
			local lspconfig = require("lspconfig")
			lspconfig.lua_ls.setup {}
			lspconfig.rust_analyzer.setup {}

			vim.keymap.set('n', 'K', vim.lsp.buf.hover, {})
			vim.keymap.set('n', '<leader>ca', vim.lsp.buf.code_action, {})
			vim.keymap.set('n', 'gd', vim.lsp.buf.definition, {})
			vim.keymap.set('n', '<leader>e', vim.diagnostic.open_float, {})

			-- Add format keybinding
			vim.keymap.set('n', '<leader>f', function()
				vim.lsp.buf.format({ async = true })
			end, { desc = "Format current buffer" })

			-- Auto format on save
			vim.api.nvim_create_autocmd("BufWritePre", {
				callback = function()
					vim.lsp.buf.format({ async = false })
				end,
			})
		end
	}
}
