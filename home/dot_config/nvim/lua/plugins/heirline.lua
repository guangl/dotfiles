---@type LazySpec
return {
  "rebelot/heirline.nvim",
  opts = function(_, opts)
    local status = require "astroui.status"
    opts.statusline[1] = status.component.mode {
      mode_text = { padding = { left = 1, right = 1 } },
      surround = { separator = { "", "" } },
    }
    -- The last AstroNvim component is an empty mode-colored segment.
    opts.statusline[#opts.statusline] = status.component.builder {
      { provider = function() return os.date "  %H:%M " end },
      hl = function() return status.hl.get_attributes "mode" end,
      surround = { separator = { "", "" }, color = status.hl.mode_bg },
    }
  end,
}
