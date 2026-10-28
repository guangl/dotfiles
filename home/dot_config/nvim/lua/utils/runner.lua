local M = {}

local function exists(cmd) return vim.fn.executable(cmd) == 1 end

local function find_up(name, dir)
  return vim.fs.find(name, {
    path = dir,
    upward = true,
  })[1]
end

local function run_command(file, ft)
  local dir = vim.fs.dirname(file)
  local ext = vim.fn.fnamemodify(file, ":e")
  local root = vim.fs.root(file, {
    "pyproject.toml",
    "package.json",
    "go.mod",
    "Cargo.toml",
    ".git",
  }) or dir

  if ft == "python" then
    local venv = find_up(".venv", dir)
    local python = "python3"

    if venv then
      local candidate = venv .. "/bin/python"
      if exists(candidate) then python = candidate end
    end

    return { python, file }, root
  elseif ft == "javascript" then
    return { "node", file }, root
  elseif ft == "typescript" then
    if exists "bun" then
      return { "bun", "run", file }, root
    elseif exists "tsx" then
      return { "tsx", file }, root
    end
  elseif ft == "sh" or ft == "bash" or ft == "zsh" then
    local shell = ext == "zsh" and "zsh" or ext == "bash" and "bash" or "sh"

    return { shell, file }, dir
  elseif ft == "lua" then
    local lua = exists "lua" and "lua" or "luajit"
    return { lua, file }, dir
  elseif ft == "go" then
    return { "go", "run", file }, root
  elseif ft == "rust" then
    local cargo = find_up("Cargo.toml", dir)

    if cargo then return { "cargo", "run" }, vim.fs.dirname(cargo) end

    -- 单文件 Rust：编译到临时目录后执行
    local binary = vim.fn.tempname()
    local cmd = "rustc "
      .. vim.fn.shellescape(file)
      .. " -o "
      .. vim.fn.shellescape(binary)
      .. " && "
      .. vim.fn.shellescape(binary)

    return { vim.o.shell, vim.o.shellcmdflag, cmd }, dir
  end

  return nil, root
end

function M.run()
  local buf = vim.api.nvim_get_current_buf()
  local ft = vim.bo[buf].filetype
  local file = vim.api.nvim_buf_get_name(buf)

  if file == "" then
    vim.notify("请先保存文件", vim.log.levels.WARN)
    return
  end

  -- 自动保存
  if vim.bo[buf].modified then vim.api.nvim_buf_call(buf, function() vim.cmd "write" end) end

  local cmd, cwd = run_command(file, ft)

  if not cmd then
    vim.notify("不支持运行: " .. ft, vim.log.levels.WARN)
    return
  end

  if not exists(cmd[1]) then
    vim.notify("执行器不存在: " .. cmd[1], vim.log.levels.ERROR)
    return
  end

  -- 打开底部终端
  vim.cmd "botright 15new"
  local term_buf = vim.api.nvim_get_current_buf()

  vim.bo[term_buf].bufhidden = "wipe"

  local job = vim.fn.termopen(cmd, {
    cwd = cwd,
  })

  if job <= 0 then
    vim.notify("启动执行器失败", vim.log.levels.ERROR)
    vim.api.nvim_buf_delete(term_buf, { force = true })
    return
  end

  -- 普通模式按 q 关闭运行窗口
  vim.keymap.set("n", "q", function()
    if vim.api.nvim_buf_is_valid(term_buf) then vim.api.nvim_buf_delete(term_buf, { force = true }) end
  end, {
    buffer = term_buf,
    silent = true,
    desc = "Close Run Output",
  })

  -- 运行结束后按 q 可直接退出
  vim.api.nvim_create_autocmd("TermClose", {
    buffer = term_buf,
    once = true,
    callback = function()
      vim.keymap.set("t", "q", function()
        vim.cmd "stopinsert"
        if vim.api.nvim_buf_is_valid(term_buf) then vim.api.nvim_buf_delete(term_buf, { force = true }) end
      end, {
        buffer = term_buf,
        silent = true,
        desc = "Close Finished Run",
      })
    end,
  })

  vim.cmd "startinsert"
end

return M
