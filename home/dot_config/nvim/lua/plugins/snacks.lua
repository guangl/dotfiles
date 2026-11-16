local banner = [[
███╗  ██╗███████╗ ██████╗ ██╗   ██╗██╗███╗   ███╗
████╗ ██║██╔════╝██╔═══██╗██║   ██║██║████╗ ████║
██╔██╗██║█████╗  ██║   ██║██║   ██║██║██╔████╔██║
██║╚████║██╔══╝  ██║   ██║╚██╗ ██╔╝██║██║╚██╔╝██║
██║ ╚███║███████╗╚██████╔╝ ╚████╔╝ ██║██║ ╚═╝ ██║
╚═╝  ╚══╝╚══════╝ ╚═════╝   ╚═══╝  ╚═╝╚═╝     ╚═╝
]]

local ghost = [[
⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢀⣀⣀⣀⣀⡀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀
⠀⠀⠀⠀⠀⠀⠀⠀⠀⣠⠞⠋⠉⠀⠈⠉⠙⢶⡄⠀⠀⠀⠀⠀⠀⠀⠀
⠀⠀⠀⠀⠀⠀⠀⠀⣴⠋⠀⠀⠀⠀⠀⠀⠀⠀⢹⡄⠀⠀⠀⢰⡆⠀⠀
⠀⠀⠀⢰⡆⠀⠀⢰⡏⠀⠀⣠⡀⠀⠀⣠⡀⠀⠀⣿⠀⠀⠒⢺⡗⠒⠀
⠀⠀⠈⢹⡏⠁⠀⣾⠀⠀⠸⣿⡿⠀⠸⣿⡿⠀⠀⢹⡄⠀⠀⠘⠃⠀⠀
⠀⠀⠀⠀⠀⠀⠀⡿⠀⠀⠀⠈⠀⠀⠀⠈⠀⠀⠀⠸⡇⠀⠀⠀⠀⠀⠀
⠀⠀⠀⠀⠀⠀⢸⡇⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⣿⠀⠀⠀⠀⠀⠀
⠀⠀⢼⡧⠀⢀⡿⠀⠀⠀⠀⡆⠀⠀⠀⠀⡇⠀⠀⠀⠸⣇⠀⠀⠀⠀⠀
⠀⠀⠈⠁⢀⡼⠃⠀⠀⠀⣰⠇⠀⠀⠀⠀⢻⡀⠀⠀⠀⠹⣆⠀⠀⠀⠀
⠀⠀⠀⠀⣿⠁⠀⠀⠀⠐⠋⠀⠀⠀⠀⠀⠀⠙⢂⣀⠀⠀⢸⡇⠀⠀⠀
⠀⠀⠀⠀⠈⠳⠶⠞⠛⢧⣄⣤⠾⠛⢶⣄⣀⣠⠞⠉⠛⠛⠋⠀⠀⠀⠀
⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠈⠉⠁⠀⠀⠀⠀⠀⠀⠀⠀⠀
]]

---@type LazySpec
return {
  {
    "folke/snacks.nvim",
    opts = function(_, opts)
      local dashboard = opts.dashboard
      dashboard.width = 48
      dashboard.pane_gap = 8
      vim.list_extend(dashboard.preset.keys, {
        { key = "e", action = "<Leader>e", icon = " ", desc = "Explorer" },
        { key = "c", action = "<Leader>fa", icon = " ", desc = "Config Files" },
        { key = "q", action = ":qa", icon = "󰅚 ", desc = "Quit" },
      })
      if vim.fn.executable "yazi" == 1 and vim.fn.executable "ya" == 1 then
        table.insert(dashboard.preset.keys, 3, { key = "y", action = ":Yazi cwd", icon = "󰉋 ", desc = "Yazi" })
      end

      dashboard.sections = function(self)
        local width = vim.api.nvim_win_get_width(self.win)
        local height = vim.api.nvim_win_get_height(self.win)
        local two_panes = width >= dashboard.width * 2 + dashboard.pane_gap
        local show_history = two_panes or height >= 38
        local pane = two_panes and 2 or 1
        return {
          {
            text = { { width >= 50 and height >= 20 and vim.trim(banner) or "NEOVIM", hl = "SnacksDashboardHeader" } },
            align = "center",
            padding = 1,
          },
          {
            text = { { vim.trim(ghost), hl = "SnacksDashboardArt" } },
            align = "center",
            padding = 1,
            enabled = width >= 50 and (height >= 34 or (two_panes and height >= 23)),
          },
          { pane = pane, section = "keys", padding = 1 },
          {
            pane = pane,
            section = "recent_files",
            title = "Recent Files",
            icon = " ",
            limit = 3,
            padding = 1,
            enabled = show_history,
          },
          {
            pane = pane,
            section = "projects",
            title = "Projects",
            icon = " ",
            limit = 3,
            padding = 1,
            enabled = show_history,
          },
        }
      end

      opts.explorer = { enabled = true }
      opts.picker.sources = opts.picker.sources or {}
      opts.picker.sources.explorer = {
        layout = { preset = "sidebar", layout = { width = 32, min_width = 24 } },
      }
    end,
  },
  {
    "AstroNvim/astrocore",
    opts = function(_, opts)
      local function last_editor_sidebar()
        local explorer = require("snacks").picker.get({ source = "explorer" })[1]
        local sidebar = explorer and vim.tbl_get(explorer, "layout", "root", "win")
        local current = vim.api.nvim_get_current_win()
        if not sidebar or not vim.api.nvim_win_is_valid(sidebar) then return end
        if current == sidebar or vim.api.nvim_win_get_config(current).relative ~= "" then return end

        for _, win in ipairs(vim.api.nvim_tabpage_list_wins(0)) do
          if win ~= current and win ~= sidebar and vim.api.nvim_win_get_config(win).relative == "" then return end
        end

        return sidebar
      end

      opts.autocmds.neotree_start = nil
      opts.autocmds.snacks_explorer_quit = {
        {
          event = "QuitPre",
          desc = "Close Explorer when quitting the last editor window in a tab",
          callback = function()
            -- Close the split before Neovim decides whether to exit.
            local sidebar = last_editor_sidebar()
            if sidebar then vim.api.nvim_win_close(sidebar, false) end
          end,
        },
      }
      opts.mappings.n["<Leader>c"] = {
        function()
          local buffers = require "astrocore.buffer"
          local buf = vim.api.nvim_get_current_buf()
          local may_quit = vim.bo[buf].buftype == ""
            and buffers.is_valid(buf)
            and #vim.api.nvim_list_tabpages() == 1
            and last_editor_sidebar()

          buffers.close(buf)
          if not may_quit or buffers.is_valid(buf) or not last_editor_sidebar() then return end
          if vim.bo.buftype ~= "" or vim.api.nvim_buf_get_name(0) ~= "" then return end

          -- Buffer deletion leaves an empty editor window behind.
          for _, info in ipairs(vim.fn.getbufinfo()) do
            if info.changed == 1 or (info.listed == 1 and info.name ~= "") then return end
          end

          vim.cmd.quit()
        end,
        desc = "Close buffer",
      }
      opts.mappings.n["<Leader>e"] = {
        function() require("snacks").explorer() end,
        desc = "Toggle Explorer",
      }
      opts.mappings.n["<Leader>o"] = {
        function()
          local snacks = require "snacks"
          local explorer = snacks.picker.get({ source = "explorer" })[1]
          if not explorer then
            snacks.explorer()
          elseif explorer:is_focused() then
            vim.cmd.wincmd "p"
          else
            explorer:focus()
          end
        end,
        desc = "Toggle Explorer Focus",
      }
    end,
  },
  {
    "nvim-neo-tree/neo-tree.nvim",
    opts = { filesystem = { hijack_netrw_behavior = "disabled" } },
  },
}
