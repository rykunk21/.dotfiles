return {
	'augmentcode/augment.vim',
	dependencies = {
		"nvim-lua/plenary.nvim"
	},
	config = function()
		-- Set this BEFORE any other configuration
		vim.g.augment_disable_default_ui = true

		-- Workspace folders
		vim.g.augment_workspace_folders = {

			"~/repos/",
			"~/.dotfiles/",
			"~/temp/augment.vim/"
		}




		-- Create an autocmd to close only the default panel window, not your custom floating window
		vim.api.nvim_create_autocmd("BufWinEnter", {
			pattern = "*AugmentChatHistory*",
			callback = function()
				vim.defer_fn(function()
					-- Get all windows displaying the AugmentChatHistory buffer
					for _, win in ipairs(vim.api.nvim_list_wins()) do
						local buf = vim.api.nvim_win_get_buf(win)
						local buf_name = vim.api.nvim_buf_get_name(buf)

						-- Check if this is the AugmentChatHistory buffer
						if buf_name:match("AugmentChatHistory") then
							-- Check if this is NOT our custom floating window
							local win_config = vim.api.nvim_win_get_config(win)

							-- Default panels are not floating windows, so close them
							if win_config.relative == "" then
								vim.fn.win_execute(win, 'close')
							end
						end
					end
				end, 10)
			end
		})
	end
}
