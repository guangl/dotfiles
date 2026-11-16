---@type LazySpec
return {
  "folke/sidekick.nvim",
  cond = function() return vim.fn.executable "codex" == 1 end,
  cmd = "Sidekick",
  opts = { nes = { enabled = false } },
  keys = {
    {
      "<Leader>aa",
      function() require("sidekick.cli").toggle { name = "codex" } end,
      desc = "Toggle Codex",
    },
    {
      "<Leader>af",
      function() require("sidekick.cli").send { name = "codex", msg = "{file}", focus = true } end,
      desc = "Add file to Codex prompt",
    },
    {
      "<Leader>av",
      function() require("sidekick.cli").send { name = "codex", msg = "{selection}", focus = true } end,
      mode = "x",
      desc = "Add selection to Codex prompt",
    },
  },
}
