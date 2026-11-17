---@type LazySpec
return {
  "folke/sidekick.nvim",
  cond = function() return vim.fn.executable "codex" == 1 end,
  cmd = "Sidekick",
  opts = {
    nes = { enabled = false },
    cli = { win = { split = { width = 0.4 } } },
  },
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
      "<Leader>aF",
      function()
        local textobjects = require "nvim-treesitter-textobjects.shared"
        local ok, range = pcall(textobjects.textobject_at_point, "@function.outer", "textobjects")
        if not ok or not range then
          vim.notify("No Tree-sitter function found at the cursor", vim.log.levels.WARN)
          return
        end

        local start_row, start_col, _, end_row, end_col = unpack(range)
        local lines = vim.api.nvim_buf_get_text(0, start_row, start_col, end_row, end_col, {})
        require("sidekick.cli").send {
          name = "codex",
          text = require("sidekick.text").to_text(lines),
          focus = true,
          submit = false,
        }
      end,
      desc = "Add function to Codex prompt",
    },
    {
      "<Leader>av",
      function() require("sidekick.cli").send { name = "codex", msg = "{selection}", focus = true } end,
      mode = "x",
      desc = "Add selection to Codex prompt",
    },
  },
}
