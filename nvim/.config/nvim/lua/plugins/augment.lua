return {
    'augmentcode/augment.vim',

    config = function()
			vim.keymap.set('n', '<leader>au', ':Augment chat<CR>', {})
			vim.keymap.set('v', '<leader>au', ':Augment chat<CR>', {})
      vim.g.augment_workspace_folders = {
            "~/repos/",
            "~/.dotfiles"
        }
    end
}
