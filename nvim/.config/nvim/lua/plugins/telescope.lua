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
			local previewers = require("telescope.previewers")
			-- Required directly: the extension isn't loaded yet when setup() runs,
			-- so telescope.extensions.file_browser wouldn't exist at this point.
			local fb_actions = require("telescope._extensions.file_browser.actions")

			-- Preview: directories as a tree of their children, files via bat (or cat).
			-- Needs `eza` (and optionally `bat`):  sudo pacman -S eza bat
			local function fb_previewer()
				return previewers.new_termopen_previewer({
					get_command = function(entry)
						local path = entry.path or entry.value
						if vim.fn.isdirectory(path) == 1 then
							return {
								"eza", "--tree", "--level=3",
								"--group-directories-first",
								"--git-ignore", -- skips target/, node_modules/ etc. if gitignored
								"--color=always",
								path,
							}
						end
						if vim.fn.executable("bat") == 1 then
							return { "bat", "--style=plain", "--color=always", "--paging=never", path }
						end
						return { "cat", path }
					end,
				})
			end

			-- One setup() call for everything.
			telescope.setup({
				extensions = {
					["ui-select"] = {
						require("telescope.themes").get_dropdown({}),
					},
					file_browser = {
						grouped = true,
						git_status = false,
						hide_parent_dir = true,
						initial_mode = "normal",  -- start in normal mode so vim motions work immediately
						sorting_strategy = "ascending", -- list entries from the top down
						layout_strategy = "horizontal",
						layout_config = {
							prompt_position = "top", -- use "bottom" to keep the prompt below the list
							width = 0.9,
							height = 0.85,
							horizontal = { preview_width = 0.6 }, -- wider preview pane
						},
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
				telescope.extensions.file_browser.file_browser({
					previewer = fb_previewer(),
					-- Uncomment to open in the current file's directory with it selected:
					path = "%:p:h",
					select_buffer = true,
				})
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
