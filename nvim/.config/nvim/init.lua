-- Ensure a unique Neovim server address when not provided, to avoid
-- "address already in use: ~/.cache/nvim/server.pipe" collisions.
do
  local cache = vim.fn.stdpath("cache")
  local addr = string.format("%s/server-%d.pipe", cache, vim.fn.getpid())
  pcall(vim.fn.serverstart, addr)
  -- Clear from environment so child processes (lazygit, terminal nvim)
  -- don't inherit and collide on the same socket.
  vim.fn.setenv("NVIM_LISTEN_ADDRESS", vim.NIL)
end

-- bootstrap lazy.nvim, LazyVim and your plugins
require("config.lazy")
-- require("plugins.lazy")
-- TODO: fix render markdown
