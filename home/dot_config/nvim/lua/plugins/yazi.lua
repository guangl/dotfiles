---@type LazySpec
return {
  "mikavilpas/yazi.nvim",
  version = "*",
  cond = function() return vim.fn.executable "yazi" == 1 and vim.fn.executable "ya" == 1 end,
  dependencies = { "nvim-lua/plenary.nvim" },
  cmd = "Yazi",
  keys = {
    { "<Leader>-", "<Cmd>Yazi<CR>", desc = "Yazi at current file" },
    { "<Leader>fy", "<Cmd>Yazi cwd<CR>", desc = "Yazi at working directory" },
  },
  opts = { floating_window_scaling_factor = 0.92, yazi_floating_window_border = "rounded" },
}
