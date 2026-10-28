return {
  "AstroNvim/astrocore",
  opts = {
    mappings = {
      n = {
        ["<Leader>dp"] = {
          function()
            local buf = vim.api.nvim_get_current_buf()
            local lines = vim.api.nvim_buf_get_lines(buf, 0, -1, false)

            -- 直接合并多行，不插入空格
            local text = table.concat(lines, "")

            -- 验证 PARAMS 日志格式
            if not text:match "^%s*PARAMS%s*%(" then
              vim.notify("不是有效的 PARAMS 日志", vim.log.levels.WARN)
              return
            end

            local values = {}

            -- 提取 SEQNO、TYPE、DATA
            for seq, dtype, value in text:gmatch "%(%s*(%d+)%s*,%s*([%w_]+)%s*,%s*(.-)%)" do
              value = vim.trim(value)

              -- 删除字符串外层引号
              if value:sub(1, 1) == "'" and value:sub(-1) == "'" then value = value:sub(2, -2):gsub("''", "'") end

              table.insert(values, value)
            end

            if #values == 0 then
              vim.notify("未找到参数", vim.log.levels.WARN)
              return
            end

            -- 一次性替换 Buffer
            vim.api.nvim_buf_set_lines(buf, 0, -1, false, values)

            -- 自动复制提取结果到 macOS 系统剪贴板
            vim.fn.setreg("+", table.concat(values, "\n"))

            -- 移动到第一行
            vim.api.nvim_win_set_cursor(0, { 1, 0 })

            vim.notify(
              string.format("成功提取 %d 个参数，已复制到系统剪贴板", #values),
              vim.log.levels.INFO
            )
          end,
          desc = "DM: 提取 PARAMS 参数并复制",
        },
      },
    },
  },
}
