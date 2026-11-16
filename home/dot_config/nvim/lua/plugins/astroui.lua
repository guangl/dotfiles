---@type LazySpec
return {
  {
    "AstroNvim/astroui",
    opts = { colorscheme = "catppuccin-mocha" },
  },
  {
    "catppuccin/nvim",
    name = "catppuccin",
    opts = {
      transparent_background = vim.env.TERM_PROGRAM == "ghostty" or vim.env.KITTY_WINDOW_ID ~= nil,
      custom_highlights = function(colors)
        return {
          SnacksDashboardHeader = { fg = colors.text },
          SnacksDashboardArt = { fg = colors.lavender },
          SnacksDashboardTitle = { fg = colors.lavender, bold = true },
          SnacksDashboardKey = { fg = colors.peach },
          SnacksPickerInputBorder = { fg = colors.peach },
          StatusLine = { fg = colors.text, bg = colors.mantle },
          NoiceCmdlinePopup = { fg = colors.text, bg = colors.mantle },
          NoiceCmdlinePopupBorder = { fg = colors.teal },
          NoiceCmdlinePopupTitle = { fg = colors.teal },
        }
      end,
    },
  },
}
