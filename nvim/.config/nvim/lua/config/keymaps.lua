-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here
vim.keymap.set("i", "jj", "<ESC>", { silent = true })
vim.keymap.set("n", "<leader>cc", "<cmd>ClaudeCode<CR>", { desc = "Toggle Claude Code" })
vim.keymap.set("n", "<leader>sm", function()
  local ok, noice = pcall(require, "noice")
  if ok and noice and noice.cmd then
    noice.cmd("history")
  else
    vim.cmd("messages")
  end
end, { desc = "Messages (Noice history or :messages)" })
