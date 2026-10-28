return {
  {
    "brenton-leighton/multiple-cursors.nvim",

    -- 确保 setup 在使用 API 之前执行
    lazy = false,
    opts = {},

    keys = {
      {
        "<leader>ms",
        function()
          local pattern = vim.fn.getreg "/"

          if pattern == "" then
            vim.notify("请先使用 / 搜索", vim.log.levels.WARN)
            return
          end

          local ok, matches = pcall(vim.fn.matchbufline, vim.api.nvim_get_current_buf(), pattern, 1, "$")

          if not ok then
            vim.notify("搜索表达式无效", vim.log.levels.ERROR)
            return
          end

          matches = vim.tbl_filter(function(m) return m.text ~= "" end, matches)

          if #matches == 0 then
            vim.notify "没有匹配结果"
            return
          end

          -- 第一个匹配位置作为主光标
          local first = matches[1]

          vim.api.nvim_win_set_cursor(0, {
            first.lnum,
            first.byteidx,
          })

          -- 插件已经初始化，可以使用官方 API
          local mc = require "multiple-cursors"

          -- 为其余匹配位置添加虚拟光标
          for i = 2, #matches do
            local m = matches[i]
            local col = m.byteidx + 1

            mc.add_cursor(m.lnum, col, col)
          end

          vim.notify(string.format("已定位 %d 个匹配位置", #matches))
        end,
        mode = "n",
        desc = "为所有搜索结果添加光标",
      },
    },
  },
}
