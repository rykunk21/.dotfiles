return {
	'augmentcode/augment.vim',
	dependencies = {
		"nvim-lua/plenary.nvim"
	},
	config = function()
		-- Set this BEFORE any other configuration
		vim.g.augment_disable_default_ui = true

		vim.g.augment_workspace_folders = {
			"~/repos/",
			"~/.dotfiles"
		}

		-- Add debug output to help diagnose the issue
		vim.g.augment_response_callback = function(response)
			-- Find the buffer from your custom-window.lua
			local augment_buf = nil
			local augment_win = nil
			local found = false

			-- Look through all windows to find our custom one
			for _, win in ipairs(vim.api.nvim_list_wins()) do
				local buf = vim.api.nvim_win_get_buf(win)
				local config = vim.api.nvim_win_get_config(win)

				-- Check if this is our custom window by looking at the title
				if config.title == "Augment Chat" then
					augment_buf = buf
					augment_win = win
					found = true
					break
				end
			end

			-- If we couldn't find the window, create it
			if not found then
				-- Try to call the toggle function if it exists
				local ok, _ = pcall(function()
					vim.cmd("lua require('plugins.custom-window').toggle_augment_float()")
				end)

				if not ok then
					-- If that fails, try again with the window search
					for _, win in ipairs(vim.api.nvim_list_wins()) do
						local buf = vim.api.nvim_win_get_buf(win)
						local config = vim.api.nvim_win_get_config(win)

						if config.title == "Augment Chat" then
							augment_buf = buf
							augment_win = win
							found = true
							break
						end
					end
				end
			end

			if augment_buf and vim.api.nvim_buf_is_valid(augment_buf) then
				local lines = vim.api.nvim_buf_get_lines(augment_buf, 0, -1, false)
				-- Split the response into lines
				local response_lines = {}
				for line in response:gmatch("[^\r\n]+") do
					table.insert(response_lines, line)
				end

				-- Add the first line with "Augment: " prefix
				if #response_lines > 0 then
					table.insert(lines, "Augment: " .. response_lines[1])
					-- Add the rest of the lines with proper indentation
					for i = 2, #response_lines do
						table.insert(lines, "         " .. response_lines[i])
					end
				else
					table.insert(lines, "Augment: " .. response)
				end

				table.insert(lines, "")
				vim.api.nvim_buf_set_lines(augment_buf, 0, -1, false, lines)

				-- Scroll to the bottom of the buffer
				if augment_win and vim.api.nvim_win_is_valid(augment_win) then
					vim.api.nvim_win_set_cursor(augment_win, { #lines, 0 })
				end
			else
				-- Fallback to print if we couldn't find the buffer
				print("Augment: Could not find custom window. Response: " .. response:sub(1, 50) .. "...")
			end
		end
	end
}
