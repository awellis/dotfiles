-- Compatibility shim for deprecated nvim-treesitter.ts_utils
-- Provides the minimal API Neorg expects on recent nvim-treesitter versions.
local M = {}

--- Jump cursor to the start of a TS node
--- @param node TSNode
--- @param bufnr? integer
--- @param win? integer
function M.goto_node(node, bufnr, win)
  if not node then return end
  bufnr = bufnr or 0
  win = win or vim.api.nvim_get_current_win()
  local sr, sc = node:range()
  pcall(vim.api.nvim_win_set_buf, win, bufnr)
  pcall(vim.api.nvim_win_set_cursor, win, { sr + 1, sc })
end

return M

