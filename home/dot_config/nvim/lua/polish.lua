-- This will run last in the setup process.
-- This is just pure lua so anything that doesn't
-- fit in the normal config locations above can go here

vim.opt.scrolloff = 999
vim.opt.sidescrolloff = 8

vim.keymap.set("n", "n", "nzzzv", { desc = "Next search result centered" })
vim.keymap.set("n", "N", "Nzzzv", { desc = "Previous search result centered" })
vim.keymap.set("n", "<C-d>", "<C-d>zz", { desc = "Scroll down centered" })
vim.keymap.set("n", "<C-u>", "<C-u>zz", { desc = "Scroll up centered" })

-- Synology DSM ships neither `getconf` nor `ldd`, so mason-core cannot detect glibc and
-- reports "The current platform is unsupported." for every linux_x64_gnu asset
-- (lua-language-server, ...). Declare the glibc target manually on such a machine.
if vim.fn.has "linux" == 1 and (vim.uv or vim.loop).os_uname().machine == "x86_64" then
  pcall(function()
    local platform = require "mason-core.platform"
    if not platform.is.linux_x64_gnu then platform.is["linux_x64_gnu"] = true end
  end)
end

