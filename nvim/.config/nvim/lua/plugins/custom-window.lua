return {
	"nvim-lua/plenary.nvim",
	config = function()
		-- Local variables to maintain conversation state
		local augment_buf = nil
		local augment_win = nil
		local augment_input_buf = nil
		local augment_input_win = nil
		local augment_content = {}

		-- Forward declare functions
		local create_input_window
		local close_augment_windows
		local send_message
		local toggle_augment_float
		local find_augment_buffer

		-- Function to find the Augment buffer after it's created
		find_augment_buffer = function()
			for _, buf in ipairs(vim.api.nvim_list_bufs()) do
				local name = vim.api.nvim_buf_get_name(buf)
				if name:match("AugmentChatHistory") then
					return buf
				end
			end
			return nil
		end


		toggle_augment_float = function()
			-- Check if the cursor is in the input window
			if augment_input_win and vim.api.nvim_win_is_valid(augment_input_win) and vim.api.nvim_get_current_win() ~= augment_input_win then
				-- if the window is open and the cursor is not inside it, move the cursor inside the input window
				vim.api.nvim_set_current_win(augment_input_win)
				return
			end
			-- Check if the input window exists and is valid
			if augment_input_win and vim.api.nvim_win_is_valid(augment_input_win) then
				-- If the input window is open, close both windows (input and chat buffer)
				close_augment_windows()
			else
				-- If the input window is not open, open the input window and the chat buffer
				-- Save the current buffer before opening windows
				original_buf = vim.api.nvim_get_current_buf()

				-- Create the input window first
				create_input_window()

				-- Open the AugmentChatHistory buffer
				augment_buf = find_augment_buffer()

				if augment_buf then
					-- If the AugmentChatHistory buffer exists, open it
					local width = math.floor(vim.o.columns * 0.75)
					local input_height = 3 -- Height of input window
					local padding = 2 -- Extra padding for visual spacing

					-- Calculate main window height to fill available space
					local main_height = math.floor(vim.o.lines - input_height - padding * 2)
					local row = padding + input_height + padding -- Position the augment window below the input window
					local col = math.floor((vim.o.columns - width) / 2)

					local opts = {
						relative = "editor",
						width = width,
						height = main_height,
						row = row,
						col = col,
						style = "minimal",
						border = "rounded",
						title = "Augment Chat",
						title_pos = "center"
					}

					-- Open the augment window
					augment_win = vim.api.nvim_open_win(augment_buf, true, opts)

					-- Make sure the input window stays on top
					vim.api.nvim_win_set_config(augment_input_win, { zindex = 50 })
					vim.api.nvim_win_set_config(augment_win, { zindex = 40 })
				end
			end
		end


		-- Define create_input_window function
		create_input_window = function()
			-- Get dimensions for input window
			local width = math.floor(vim.o.columns * 0.75)
			local height = 3

			-- Calculate position for the input window
			local main_height = math.floor(vim.o.lines * 0.75)
			local main_row = math.floor((vim.o.lines - main_height) / 2)
			local row = main_row + main_height + 1 -- +1 for the border
			local col = math.floor((vim.o.columns - width) / 2)

			-- Create or reuse input buffer
			if not augment_input_buf or not vim.api.nvim_buf_is_valid(augment_input_buf) then
				augment_input_buf = vim.api.nvim_create_buf(false, true)
				vim.api.nvim_buf_set_option(augment_input_buf, "filetype", "markdown")
			end

			-- Set input window options
			local input_opts = {
				relative = "editor",
				width = width,
				height = height,
				row = row,
				col = col,
				style = "minimal",
				border = "rounded",
				title = "Message",
				title_pos = "center"
			}

			-- Create input window
			augment_input_win = vim.api.nvim_open_win(augment_input_buf, true, input_opts)

			-- Set the cursor to this window just created
			vim.api.nvim_set_current_win(augment_input_win)

			-- Set up keymaps for sending messages
			vim.keymap.set("n", "<CR>", function()
				send_message()
			end, { buffer = augment_input_buf, noremap = true, silent = true })

			vim.keymap.set("i", "<C-CR>", function()
				send_message()
			end, { buffer = augment_input_buf, noremap = true, silent = true })
		end



		send_message = function()
			-- Get the lines from the augment_input_buf
			local lines = vim.api.nvim_buf_get_lines(augment_input_buf, 0, -1, false)
			local message = table.concat(lines, "\n")

			-- Proceed if the message is non-empty
			if message and message:gsub("%s", "") ~= "" then
				-- Clear the input buffer
				vim.api.nvim_buf_set_lines(augment_input_buf, 0, -1, false, { "" })

				-- Save the current window to restore later
				local current_win = vim.api.nvim_get_current_win()

				-- Use the current buffer directly (the file the user is working in)
				local original_buf = vim.api.nvim_get_current_buf()

				-- Run the Augment chat command from the original buffer
				vim.api.nvim_win_call(current_win, function()
					-- Run the command in the context of the current buffer
					vim.cmd("Augment chat '" .. message:gsub("'", "\\'") .. "'")
				end)

				-- Find the Augment buffer after command execution
				augment_buf = find_augment_buffer()

				if augment_buf then
					-- Create the main window if it doesn't exist
					if not augment_win or not vim.api.nvim_win_is_valid(augment_win) then
						local width = math.floor(vim.o.columns * 0.75)
						local input_height = 3 -- Height of input window
						local padding = 2 -- Extra padding for visual spacing
						local offset = 5

						-- Calculate main window height to fill available space
						local main_height = math.floor(vim.o.lines - input_height + offset - padding * 2)
						local row = padding + input_height +
								padding -- Position the augment window below the input window (input_height + padding)
						local col = math.floor((vim.o.columns - width) / 2)

						local opts = {
							relative = "editor",
							width = width,
							height = main_height,
							row = row,
							col = col,
							style = "minimal",
							border = "rounded",
							title = "Augment Chat",
							title_pos = "center"
						}

						augment_win = vim.api.nvim_open_win(augment_buf, true, opts)

						-- Restore saved content if available
						if #augment_content > 0 then
							vim.api.nvim_buf_set_lines(augment_buf, 0, -1, false, augment_content)
						end

						-- Set up keymaps for closing the window
						vim.keymap.set("n", "q", function()
							close_augment_windows()
						end, { buffer = augment_buf, noremap = true, silent = true })
					end

					-- Make sure we're back in the input window
					vim.api.nvim_set_current_win(augment_input_win)
				end
			end
		end
		-- Define close_augment_windows function
		close_augment_windows = function()
			-- Save buffer content before closing if valid
			if augment_buf and vim.api.nvim_buf_is_valid(augment_buf) then
				augment_content = vim.api.nvim_buf_get_lines(augment_buf, 0, -1, false)
			end

			-- Close windows if they exist and are valid
			if augment_win and vim.api.nvim_win_is_valid(augment_win) then
				vim.api.nvim_win_close(augment_win, true)
				augment_win = nil
			end

			if augment_input_win and vim.api.nvim_win_is_valid(augment_input_win) then
				vim.api.nvim_win_close(augment_input_win, true)
				augment_input_win = nil
			end
		end



		-- Set up keybinding to toggle the float
		vim.keymap.set("n", "<leader>af", function()
			toggle_augment_float()
		end, { noremap = true, silent = true, desc = "Toggle Augment Float" })
	end
}
