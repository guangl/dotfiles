-- AstroNvim 数据库文件打开器
-- 支持 DuckDB / SQLite
-- 依赖 vim-dadbod + vim-dadbod-ui

--------------------------------------------------
-- 识别数据库文件
--------------------------------------------------

local function detect_database(path)
  local file = io.open(path, "rb")
  if not file then return nil end

  local header = file:read(16) or ""
  file:close()

  if header:sub(1, 16) == "SQLite format 3\0" then return "sqlite" end

  if header:sub(9, 12) == "DUCK" then return "duckdb" end

  return nil
end

--------------------------------------------------
-- 注册 DBUI 连接
--------------------------------------------------

local function register_database(path, engine, url)
  local name = engine:upper() .. ": " .. path
  local dbs = vim.g.dbs or {}

  if vim.islist(dbs) then
    local found = false

    for _, entry in ipairs(dbs) do
      if entry.name == name then
        entry.url = url
        found = true
        break
      end
    end

    if not found then table.insert(dbs, {
      name = name,
      url = url,
    }) end
  else
    dbs[name] = url
  end

  vim.g.dbs = dbs

  -- DBUI 会缓存数据库连接列表
  -- 更新连接之后刷新缓存
  pcall(vim.fn["db_ui#reset_state"])
end

--------------------------------------------------
-- 创建 SQL 工作区
--------------------------------------------------

local function create_workspace(buf, path, engine)
  if not vim.api.nvim_buf_is_valid(buf) then return end

  if vim.api.nvim_get_current_buf() ~= buf then return end

  local executable = engine == "sqlite" and "sqlite3" or "duckdb"

  if vim.fn.executable(executable) == 0 then
    vim.notify("未安装数据库客户端：" .. executable, vim.log.levels.ERROR)
    return
  end

  local ok, encoded = pcall(vim.fn["db#url#path_encode"], path)

  if not ok then
    vim.notify("Dadbod 不可用：" .. tostring(encoded), vim.log.levels.ERROR)
    return
  end

  local url = engine .. ":" .. encoded

  register_database(path, engine, url)

  -- 创建普通 SQL Buffer
  vim.cmd "enew"

  local sql_buf = vim.api.nvim_get_current_buf()
  local sql_win = vim.api.nvim_get_current_win()

  vim.bo[sql_buf].filetype = "sql"
  vim.b[sql_buf].db = url

  local lines

  if engine == "sqlite" then
    lines = {
      "-- SQLite: " .. path,
      "",
      "SELECT name FROM sqlite_master",
      "WHERE type = 'table';",
    }
  else
    lines = {
      "-- DuckDB: " .. path,
      "",
      "SELECT table_name",
      "FROM information_schema.tables",
      "WHERE table_schema = 'main';",
    }
  end

  vim.api.nvim_buf_set_lines(sql_buf, 0, -1, false, lines)

  vim.bo[sql_buf].modified = false

  -- 打开 DBUI
  local success, err = pcall(vim.cmd, "DBUI")

  if not success then
    vim.notify("无法打开 DBUI：" .. tostring(err), vim.log.levels.ERROR)
    return
  end

  if vim.api.nvim_win_is_valid(sql_win) then vim.api.nvim_set_current_win(sql_win) end
end

--------------------------------------------------
-- 文件打开入口
--------------------------------------------------

local function open_database(args)
  local buf = args.buf

  local path = vim.fn.fnamemodify(vim.api.nvim_buf_get_name(buf), ":p")

  local exists = vim.fn.filereadable(path) == 1
  local extension = vim.fn.fnamemodify(path, ":e"):lower()

  -- 接管数据库文件读取
  -- 禁止将二进制文件显示为普通文本
  vim.bo[buf].buftype = "nofile"
  vim.bo[buf].bufhidden = "wipe"
  vim.bo[buf].swapfile = false
  vim.bo[buf].modifiable = false
  vim.bo[buf].modified = false

  if exists then
    local engine = detect_database(path)

    if not engine then
      vim.notify("无法识别数据库格式：" .. path, vim.log.levels.ERROR)
      return
    end

    vim.schedule(function() create_workspace(buf, path, engine) end)

    return
  end

  -- 不存在的文件，根据扩展名决定数据库
  if extension == "duckdb" or extension == "ddb" then
    vim.schedule(function() create_workspace(buf, path, "duckdb") end)
  elseif extension == "sqlite" or extension == "sqlite3" then
    vim.schedule(function() create_workspace(buf, path, "sqlite") end)
  elseif extension == "db" then
    -- 新 .db 文件无法通过文件头识别
    -- 让用户选择数据库引擎
    vim.schedule(function()
      vim.ui.select({
        "DuckDB",
        "SQLite",
      }, {
        prompt = "新数据库类型",
      }, function(choice)
        if not choice then return end

        local engine = choice == "DuckDB" and "duckdb" or "sqlite"

        create_workspace(buf, path, engine)
      end)
    end)
  end
end

--------------------------------------------------
-- AstroNvim
--------------------------------------------------

return {
  {
    "AstroNvim/astrocore",
    opts = {
      autocmds = {
        database_file_open = {
          {
            event = "BufReadCmd",
            pattern = {
              "*.db",
              "*.duckdb",
              "*.ddb",
              "*.sqlite",
              "*.sqlite3",
            },
            desc = "Open database SQL workspace",
            callback = open_database,
          },
          {
            event = "BufNewFile",
            pattern = {
              "*.db",
              "*.duckdb",
              "*.ddb",
              "*.sqlite",
              "*.sqlite3",
            },
            desc = "Create database SQL workspace",
            callback = open_database,
          },
        },
      },
    },
  },
}
