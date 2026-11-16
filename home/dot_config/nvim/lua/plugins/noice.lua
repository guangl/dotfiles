---@type LazySpec
return {
  {
    "folke/noice.nvim",
    event = "VeryLazy",
    dependencies = { "MunifTanjim/nui.nvim" },
    opts = {
      messages = { enabled = false },
      -- AstroLSP configures the default options for both handlers.
      lsp = { hover = { enabled = false }, signature = { enabled = false } },
      presets = { bottom_search = true, command_palette = true },
      cmdline = { format = { cmdline = { title = " Command " } } },
      views = {
        cmdline_popup = {
          size = { width = "45%", min_width = 24, height = "auto" },
          border = { style = "rounded" },
        },
        cmdline_popupmenu = {
          size = { width = "45%", max_height = 10 },
        },
      },
    },
  },
  {
    "AstroNvim/astrocore",
    opts = function(_, opts)
      if vim.fn.exists "*wildtrigger" == 0 then return end
      opts.options.opt.wildmode = "noselect:lastused,full"
      opts.autocmds.command_palette = {
        {
          event = "CmdlineChanged",
          pattern = ":",
          desc = "Show command completions as you type",
          callback = function() vim.fn.wildtrigger() end,
        },
      }
    end,
  },
}
