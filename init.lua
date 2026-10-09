-- When run from the Nix package this config lives in the read-only store and
-- is loaded with `-u`, so it isn't on the runtimepath and stdpath("config")
-- doesn't point at it. Work out where we live and wire things up from there.
local root = vim.fn.fnamemodify(debug.getinfo(1, "S").source:sub(2), ":p:h")
vim.g.config_root = root

if root ~= vim.fn.stdpath("config") then
  vim.opt.rtp:prepend(root)

  -- lazy.nvim and LazyVim write back to lazy-lock.json / lazyvim.json, which
  -- can't happen in the store. Keep writable copies in the state dir and
  -- refresh them whenever the packaged config changes.
  local state = vim.fn.stdpath("state")
  local stamp = state .. "/config-source"
  local f = io.open(stamp, "r")
  local prev = f and f:read("*a")
  if f then
    f:close()
  end
  if prev ~= root then
    vim.fn.mkdir(state, "p")
    for _, name in ipairs({ "lazy-lock.json", "lazyvim.json" }) do
      vim.fn.writefile(vim.fn.readfile(root .. "/" .. name, "b"), state .. "/" .. name, "b")
    end
    vim.fn.writefile({ root }, stamp, "b")
  end
  vim.g.lazy_lockfile = state .. "/lazy-lock.json"
  vim.g.lazyvim_json = state .. "/lazyvim.json"
end

-- bootstrap lazy.nvim, LazyVim and your plugins
require("config.lazy")
