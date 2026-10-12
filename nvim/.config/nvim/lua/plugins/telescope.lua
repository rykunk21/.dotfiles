-- ~/.config/nvim/lua/plugins/telescope.lua
return {
	{
		"nvim-telescope/telescope.nvim",
		tag = "0.1.8",
		dependencies = {
			"nvim-lua/plenary.nvim",
			"nvim-telescope/telescope-file-browser.nvim",
			"nvim-telescope/telescope-ui-select.nvim",
		},
		config = function()
			local telescope = require("telescope")
			local builtin = require("telescope.builtin")
			local actions = require("telescope.actions")
			-- Required directly: the extension isn't loaded yet when setup() runs,
			-- so telescope.extensions.file_browser wouldn't exist at this point.
			local fb_actions = require("telescope._extensions.file_browser.actions")

			-- One setup() call for everything.
			telescope.setup({
				extensions = {
					["ui-select"] = {
						require("telescope.themes").get_dropdown({}),
					},
					file_browser = {
						grouped = true,
						git_status = false,
						initial_mode = "normal", -- start in normal mode so vim motions work immediately
						mappings = {
							n = {
								h = fb_actions.goto_parent_dir, -- default `h` is toggle_hidden
								l = actions.select_default, -- enter dir / open file
								["."] = fb_actions.toggle_hidden,
							},
						},
					},
				},
			})

			-- Load extensions AFTER setup so the options above apply.
			telescope.load_extension("ui-select")
			telescope.load_extension("file_browser")

			-- Keymaps
			vim.keymap.set("n", "<leader>fe", function()
				telescope.extensions.file_browser.file_browser()
			end, { desc = "Browse files by directory" })

			vim.keymap.set("n", "<leader>ff", function()
				builtin.find_files({
					hidden = true,
					no_ignore = true,
					find_command = {
						"rg", "--files",
						"--hidden",
						"--no-ignore",
						"--glob", "!target/**",
						"--glob", "!node_modules/**",
						"--glob", "!**/.git/**",
						"--glob", "!**/.cache/**",
					},
				})
			end, { desc = "Find files" })

			vim.keymap.set("n", "<leader>fg", builtin.live_grep, { desc = "Live grep" })
			vim.keymap.set("n", "<leader>E", builtin.diagnostics, { desc = "Diagnostics" })
			vim.keymap.set("n", "<leader>fb", builtin.buffers, { desc = "Buffers" })
		end,
	},
}
