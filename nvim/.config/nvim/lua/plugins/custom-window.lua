return {
	"nvim-lua/plenary.nvim",
	config = function()
		-- Local variables to maintain conversation state
		local augment_buf = nil
		local augment_win = nil
		local augment_input_buf = nil
		local augment_input_win = nil

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
			-- If either window exists, close both windows
			if (augment_win and vim.api.nvim_win_is_valid(augment_win)) or
					(augment_input_win and vim.api.nvim_win_is_valid(augment_input_win)) then
				close_augment_windows()
				return
			end

			-- Save the current buffer before opening windows
			original_buf = vim.api.nvim_get_current_buf()

			-- Create input window first without waiting for buffer
			create_input_window()
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

			-- Set up keymaps for sending messages
			vim.keymap.set("n", "<CR>", function()
				send_message()
			end, { buffer = augment_input_buf, noremap = true, silent = true })

			vim.keymap.set("i", "<C-CR>", function()
				send_message()
			end, { buffer = augment_input_buf, noremap = true, silent = true })
		end



		send_message = function()
			local lines = vim.api.nvim_buf_get_lines(augment_input_buf, 0, -1, false)
			local message = table.concat(lines, "\n")

			if message and message:gsub("%s", "") ~= "" then
				-- Clear input buffer
				vim.api.nvim_buf_set_lines(augment_input_buf, 0, -1, false, { "" })

				-- Save current window to restore later
				local current_win = vim.api.nvim_get_current_win()

				-- Use a temporary hidden buffer to execute commands
				local temp_buf = vim.api.nvim_create_buf(false, true)
				local temp_win = vim.api.nvim_open_win(temp_buf, false, {
					relative = 'editor',
					width = 1,
					height = 1,
					row = 0,
					col = 0,
					style = 'minimal',
					noautocmd = true,
				})

				-- Set context in the temporary window
				if original_buf and vim.api.nvim_buf_is_valid(original_buf) then
					vim.api.nvim_win_set_buf(temp_win, original_buf)
					vim.fn['augment#chat#SaveUri']()
				end

				-- Run Augment's chat command in the temporary window
				vim.api.nvim_win_call(temp_win, function()
					vim.cmd("Augment chat '" .. message:gsub("'", "\\'") .. "'")
				end)

				-- Close temporary window
				vim.api.nvim_win_close(temp_win, true)

				-- Find the Augment buffer after command execution
				augment_buf = find_augment_buffer()

				if augment_buf then
					-- Create the main window if it doesn't exist
					if not augment_win or not vim.api.nvim_win_is_valid(augment_win) then
						local width = math.floor(vim.o.columns * 0.75)
						local height = math.floor(vim.o.lines * 0.75 - 10)
						local row = math.floor((vim.o.lines - height) / 2)
						local col = math.floor((vim.o.columns - width) / 2)

						local opts = {
							relative = "editor",
							width = width,
							height = height,
							row = row,
							col = col,
							style = "minimal",
							border = "rounded",
							title = "Augment Chat",
							title_pos = "center"
						}

						augment_win = vim.api.nvim_open_win(augment_buf, true, opts)

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
