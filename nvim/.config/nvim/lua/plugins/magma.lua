return {
  "dccsillag/magma-nvim",
  build = ":UpdateRemotePlugins",
  keys = {
    { "<localleader>r", "<cmd>MagmaEvaluateOperator<cr>", desc = "Magma Evaluate Operator" },
    { "<localleader>rr", "<cmd>MagmaEvaluateLine<cr>", desc = "Magma Evaluate Line" },
    { "<localleader>r", "<cmd>MagmaEvaluateVisual<cr>", mode = "v", desc = "Magma Evaluate Visual" },
    { "<localleader>rc", "<cmd>MagmaReevaluateCell<cr>", desc = "Magma Reevaluate Cell" },
    { "<localleader>rd", "<cmd>MagmaDelete<cr>", desc = "Magma Delete" },
    { "<localleader>ro", "<cmd>MagmaShowOutput<cr>", desc = "Magma Show Output" },
  },
  -- Magma requires neovim with python support
  dependencies = {
    "nvim-lua/plenary.nvim",
  },
  -- Only load when python is available
  cond = function()
    return vim.fn.has('python3') == 1
  end,
  config = function()
    vim.g.magma_automatically_open_output = false
    vim.g.magma_image_provider = "kitty"
  end
}
