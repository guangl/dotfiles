local dialects = {
  "duckdb",
  "postgresql",
  "sqlite",
  "plsql",
  "sql",
}

local function format_sql()
  if vim.fn.executable "sql-formatter" ~= 1 then
    vim.notify("未安装 sql-formatter", vim.log.levels.ERROR)
    return
  end

  local dialect = vim.b.sql_dialect or "sql"

  local input = table.concat(vim.api.nvim_buf_get_lines(0, 0, -1, false), "\n")

  local result = vim
    .system({
      "sql-formatter",
      "-l",
      dialect,
    }, {
      stdin = input,
      text = true,
    })
    :wait()

  if result.code ~= 0 then
    vim.notify(result.stderr or "格式化失败", vim.log.levels.ERROR)
    return
  end

  local output = (result.stdout or ""):gsub("\n$", "")

  vim.api.nvim_buf_set_lines(0, 0, -1, false, vim.split(output, "\n", { plain = true }))
end

vim.keymap.set("n", "<Leader>lf", format_sql, {
  buffer = true,
  desc = "Format SQL",
})

return {
  {
    "AstroNvim/astrocore",
    opts = {
      mappings = {
        n = {
          ["<Leader>sf"] = {
            format_sql,
            desc = "Format SQL",
          },

          ["<Leader>sd"] = {
            function()
              vim.ui.select(dialects, {
                prompt = "SQL 方言",
              }, function(choice)
                if choice then vim.b.sql_dialect = choice end
              end)
            end,
            desc = "Select SQL dialect",
          },
        },
      },
    },
  },
}
