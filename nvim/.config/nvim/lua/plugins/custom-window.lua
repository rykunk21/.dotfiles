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


		toggle_augment_float = function()
			-- If windows already exist, close them
			if augment_win and vim.api.nvim_win_is_valid(augment_win) then
				close_augment_windows()
				return
			end

			-- Run Augment's chat-new to initialize
			vim.cmd("Augment chat-new")

			-- Get list of all buffers before and after running the command
			local before_buffers = vim.api.nvim_list_bufs()

			print("Before buffers count: " .. #before_buffers)
			-- Wait for the Augment buffer to be created (just a small delay)
			vim.defer_fn(function()
				local after_buffers = vim.api.nvim_list_bufs()

				print("After buffers count: " .. #after_buffers)
				-- Find the new buffer created by Augment (comparing before and after buffers)
				for _, buf in ipairs(after_buffers) do
					-- Check that the buffer wasn't already in the list before
					if not vim.tbl_contains(before_buffers, buf) then
						print("Found new buffer: " .. buf .. " with name: " .. name)
						augment_buf = buf
						break
					end
				end

				-- Now augment_buf should be the newly created Augment buffer
				if augment_buf then
					-- Get dimensions for main window
					local width = math.floor(vim.o.columns * 0.75)
					local height = math.floor(vim.o.lines * 0.75)
					local row = math.floor((vim.o.lines - height) / 2)
					local col = math.floor((vim.o.columns - width) / 2)

					-- Set window options
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

					-- Create the floating window with the Augment buffer
					augment_win = vim.api.nvim_open_win(augment_buf, true, opts)

					-- Set up keymaps for closing the window
					vim.keymap.set("n", "q", function()
						close_augment_windows()
					end, { buffer = augment_buf, noremap = true, silent = true })

					-- Create input window
					create_input_window()
				else
					print("Failed to capture Augment buffer")
				end
			end, 100) -- Delay by 100ms to ensure the buffer is created
		end




		-- Define create_input_window function
		create_input_window = function()
			-- Get dimensions for input window
			local width = math.floor(vim.o.columns * 0.75)
			local height = 3

			-- Calculate position to be directly under the main window
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

		-- Define send_message function

		send_message = function()
			local lines = vim.api.nvim_buf_get_lines(augment_input_buf, 0, -1, false)
			local message = table.concat(lines, "\n")

			if message and message:gsub("%s", "") ~= "" then
				-- Clear input buffer
				vim.api.nvim_buf_set_lines(augment_input_buf, 0, -1, false, { "" })

				-- Focus back to main chat window
				vim.api.nvim_set_current_win(augment_win)
				vim.api.nvim_set_current_buf(augment_buf)

				-- Send message to Augment (passing buffer number if needed)
				local escaped_message = message:gsub("'", "\\'")
				print("Sending to buffer id: " .. augment_buf)

				vim.cmd("Augment chat '" .. escaped_message .. "'")
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
