return {
	{
		'nvim-telescope/telescope.nvim',
		tag = '0.1.8',
		dependencies = { 
			'nvim-lua/plenary.nvim',
			'nvim-telescope/telescope-file-browser.nvim'

		},
		config = function()
			local builtin = require("telescope.builtin")
			
			require("telescope").load_extension("file_browser")
			vim.keymap.set('n', '<leader>fe', function()
				require('telescope').extensions.file_browser.file_browser({
					grouped=true
				})
				end, {desc = "Browse files by directory"}
			)
			-- keymaps
			vim.keymap.set('n', '<leader>ff', function()
				builtin.find_files({
					hidden=true,
					no_ignore = true,
					find_command = {
						"rg", "--files",
						"--hidden",
						"--no-ignore",
						"--glob", "!target/**",
						"--glob", "!node_modules/**",
						"--glob", "!**/.git/**",
						"--glob", "!**/.cache/**",
					}

				})
			end)

			vim.keymap.set('n', '<leader>fg', builtin.live_grep, {})
			vim.keymap.set('n', '<leader>E', builtin.diagnostics, {})
			vim.keymap.set('n', '<leader>fb', builtin.buffers, {})
		end
	},
	{
		"nvim-telescope/telescope-ui-select.nvim",
		config = function()
			-- This is your opts table
			require("telescope").setup {
				extensions = {
					["ui-select"] = {
						require("telescope.themes").get_dropdown {
							-- even more opts
						}
					},
					file_browser = {
						git_status = false
					}
				}
			}
			-- To get ui-select loaded and working with telescope, you need to call
			-- load_extension, somewhere after setup function:
			require("telescope").load_extension("ui-select")
			require("telescope").load_extension("file_browser")
		end

	}
}
