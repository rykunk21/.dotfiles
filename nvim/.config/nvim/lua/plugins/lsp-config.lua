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
					"lua_ls", "pyright"
				}
			}
		end
	},
	{
		"neovim/nvim-lspconfig",
		config = function()
			local lspconfig = require("lspconfig")
			vim.lsp.config("lua_ls", {
				settings = {
					Lua = {
						runtime = {
							version = "LuaJIT",
						},
						workspace = {
							library = vim.api.nvim_get_runtime_file("", true),
						},
						telemetry = {
							enable = false,
						},
					},
				},
			})

			vim.lsp.config("pyright", {
				settings = {
					python = {
						analysis = {
							autoSearchPaths = true,
							diagnosticMode = "openFilesOnly",
							useLibraryCodeForTypes = true,
						},
					},
				},
			})
			-- Set up keybindings
			vim.keymap.set('n', 'K', vim.lsp.buf.hover, {})
			vim.keymap.set('n', '<leader>ca', vim.lsp.buf.code_action, {})
			vim.keymap.set('n', 'gd', vim.lsp.buf.definition, {})
			vim.keymap.set('n', '<leader>e', vim.diagnostic.open_float, {})

			-- Configure diagnostic signs
			vim.diagnostic.config({
				virtual_text = true, -- shows inline text
				underline = true, -- enables squiggles
				signs = true,    -- symbols in gutter
				severity_sort = true,
			})
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
