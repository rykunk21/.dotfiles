vim.cmd("set tabstop=2")
vim.cmd("set softtabstop=2")
vim.cmd("set shiftwidth=2")
vim.g.mapleader = " "
vim.o.number = true
vim.opt.scrolloff = 999

-- Folding
vim.opt.foldmethod = "expr"
vim.opt.foldexpr = "nvim_treesitter#foldexpr()"
vim.opt.foldenable = true
vim.opt.foldlevel = 99

-- Make sure to setup `mapleader` and `maplocalleader` before
-- loading lazy.nvim so that mappings are correct.
-- This is also a good place to setup other settings (vim.opt)
vim.g.mapleader = " "
vim.g.maplocalleader = "\\"
vim.keymap.set('i', 'jj', '<Esc>', {})

vim.keymap.set('n', '<leader>k', ':resize -5<CR>', { noremap = true, silent = true })          -- Resize up
vim.keymap.set('n', '<leader>j', ':resize +5<CR>', { noremap = true, silent = true })          -- Resize down
vim.keymap.set('n', '<leader>h', ':vertical resize +5<CR>', { noremap = true, silent = true }) -- Resize left
vim.keymap.set('n', '<leader>l', ':vertical resize -5<CR>', { noremap = true, silent = true }) -- Resize right
