-- AstroNvim SQL 工作区
-- DuckDB / PostgreSQL
-- vim-dadbod + vim-dadbod-ui

--------------------------------------------------
-- 数据库连接
--------------------------------------------------

local function current_connection()
  local url = vim.b.db

  if type(url) == "string" and url ~= "" then return url, "b:db" end

  return vim.g.db or "duckdb:", "g:db"
end

local function set_connection(url, name)
  vim.b.db = url

  vim.notify("SQL 数据库已切换：" .. name, vim.log.levels.INFO)
end

local function switch_database()
  local choices = {
    { name = "DuckDB · 临时数据库", type = "memory" },
    { name = "DuckDB · 选择数据库文件", type = "duckdb" },
    { name = "PostgreSQL · 输入连接 URL", type = "postgresql" },
  }

  vim.ui.select(choices, {
    prompt = "选择数据库",
    format_item = function(item) return item.name end,
  }, function(item)
    if not item then return end

    if item.type == "memory" then
      set_connection("duckdb:", item.name)
    elseif item.type == "duckdb" then
      vim.ui.input({
        prompt = "DuckDB 数据库路径: ",
        completion = "file",
      }, function(path)
        if not path or path == "" then return end

        local absolute = vim.fn.fnamemodify(vim.fn.expand(path), ":p")

        local parent = vim.fn.fnamemodify(absolute, ":h")

        if vim.fn.isdirectory(parent) == 0 then
          vim.notify("数据库所在目录不存在：" .. parent, vim.log.levels.ERROR)
          return
        end

        -- 转义路径中的空格、#、% 等字符
        local encoded = vim.fn["db#url#path_encode"](absolute)

        set_connection("duckdb:" .. encoded, absolute)
      end)
    elseif item.type == "postgresql" then
      vim.ui.input({
        prompt = "PostgreSQL URL: ",
        default = "postgresql://localhost:5432/postgres",
      }, function(url)
        if not url or url == "" then return end

        if not (url:match "^postgresql://" or url:match "^postgres://") then
          vim.notify("无效的 PostgreSQL URL", vim.log.levels.ERROR)
          return
        end

        -- 不回显 URL，避免日志泄漏数据库密码
        set_connection(url, "PostgreSQL")
      end)
    end
  end)
end

--------------------------------------------------
-- SQL 执行计划
--------------------------------------------------

local explain_commands = {
  duckdb = {
    run = "",
    explain = "EXPLAIN",
    analyze = "EXPLAIN ANALYZE",
    json = "EXPLAIN (FORMAT JSON)",
  },

  postgresql = {
    run = "",
    explain = "EXPLAIN (VERBOSE, COSTS, SETTINGS)",
    analyze = "EXPLAIN (ANALYZE, BUFFERS, VERBOSE, SETTINGS, WAL)",
    json = "EXPLAIN (FORMAT JSON)",
  },
}

local function get_database_type(url)
  local scheme = url:match "^([%w%.%+%-]+):"

  if scheme == "postgres" then return "postgresql" end

  return scheme
end

-- 跳过开头空行和单行注释
-- 避免 EXPLAIN 被插到注释前面
local function sql_start_line(first, last)
  while first <= last do
    local line = vim.fn.getline(first)

    if line:match "^%s*$" or line:match "^%s*%-%-" then
      first = first + 1
    else
      break
    end
  end

  return first
end

local function execute_sql(opts)
  local action = opts.args

  local url, connection_ref = current_connection()
  local db_type = get_database_type(url)

  local commands = explain_commands[db_type]

  if not commands then
    vim.notify("暂不支持该数据库：" .. tostring(db_type), vim.log.levels.ERROR)
    return
  end

  local prefix = commands[action]

  if prefix == nil then
    vim.notify("不支持的 SQL 操作：" .. action, vim.log.levels.ERROR)
    return
  end

  local first = opts.line1
  local last = opts.line2

  -- 执行计划跳过前面的空行和 -- 注释
  if action ~= "run" then first = sql_start_line(first, last) end

  if first > last then
    vim.notify("没有可执行的 SQL", vim.log.levels.WARN)
    return
  end

  -- Dadbod 支持：
  -- :1,5DB b:db EXPLAIN
  -- :1,5DB g:db
  --
  -- 显式指定连接，避免 w:db 等变量覆盖
  local command = string.format("%d,%dDB %s%s", first, last, connection_ref, prefix ~= "" and (" " .. prefix) or "")

  local ok, err = pcall(vim.cmd, command)

  if not ok then vim.notify("SQL 执行失败：" .. tostring(err), vim.log.levels.ERROR) end
end

--------------------------------------------------
-- AstroNvim 插件配置
--------------------------------------------------

return {
  -- 确保 DB 命令始终可用
  {
    "tpope/vim-dadbod",
    lazy = false,
  },

  {
    "AstroNvim/astrocore",

    opts = {
      options = {
        g = {
          -- 默认 DuckDB 临时数据库
          db = "duckdb:",

          -- DBUI
          db_ui_execute_on_save = 0,
          db_ui_win_position = "left",
          db_ui_winwidth = 35,
          db_ui_use_nerd_fonts = 1,

          db_ui_save_location = vim.fn.stdpath "data" .. "/db_ui",
        },
      },

      commands = {
        SqlExec = {
          execute_sql,
          nargs = 1,
          range = true,
          complete = function()
            return {
              "run",
              "explain",
              "analyze",
              "json",
            }
          end,
          desc = "执行 SQL / 查看执行计划",
        },

        SqlDatabase = {
          switch_database,
          desc = "切换 SQL 数据库",
        },
      },

      mappings = {
        n = {
          ["<Leader>s"] = {
            desc = "SQL",
          },

          ["<Leader>sq"] = {
            "<Cmd>%SqlExec run<CR>",
            desc = "SQL: 执行 Buffer",
          },

          ["<Leader>se"] = {
            "<Cmd>%SqlExec explain<CR>",
            desc = "SQL: 估算执行计划",
          },

          ["<Leader>sa"] = {
            "<Cmd>%SqlExec analyze<CR>",
            desc = "SQL: 实际执行计划",
          },

          ["<Leader>sj"] = {
            "<Cmd>%SqlExec json<CR>",
            desc = "SQL: JSON 执行计划",
          },

          ["<Leader>sd"] = {
            "<Cmd>SqlDatabase<CR>",
            desc = "SQL: 切换数据库",
          },

          ["<Leader>su"] = {
            "<Cmd>DBUIToggle<CR>",
            desc = "SQL: 数据库管理器",
          },

          ["<Leader>sA"] = {
            "<Cmd>DBUIAddConnection<CR>",
            desc = "SQL: 保存数据库连接",
          },
        },

        x = {
          ["<Leader>sq"] = {
            ":<C-u>'<,'>SqlExec run<CR>",
            desc = "SQL: 执行选区",
          },

          ["<Leader>se"] = {
            ":<C-u>'<,'>SqlExec explain<CR>",
            desc = "SQL: 选区执行计划",
          },

          ["<Leader>sa"] = {
            ":<C-u>'<,'>SqlExec analyze<CR>",
            desc = "SQL: 选区实际计划",
          },

          ["<Leader>sj"] = {
            ":<C-u>'<,'>SqlExec json<CR>",
            desc = "SQL: 选区 JSON 计划",
          },
        },
      },
    },
  },
}
