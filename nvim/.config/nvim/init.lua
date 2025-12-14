-- Ensure a unique Neovim server address when not provided, to avoid
-- "address already in use: ~/.cache/nvim/server.pipe" collisions.
do
  local listen = vim.env.NVIM_LISTEN_ADDRESS
  if not listen or listen == "" then
    local cache = vim.fn.stdpath("cache")
    local addr = string.format("%s/server-%d.pipe", cache, vim.fn.getpid())
    vim.fn.setenv("NVIM_LISTEN_ADDRESS", addr)
    pcall(vim.fn.serverstart, addr)
  end
end

-- bootstrap lazy.nvim, LazyVim and your plugins
require("config.lazy")
-- require("plugins.lazy")
-- TODO: fix render markdown
