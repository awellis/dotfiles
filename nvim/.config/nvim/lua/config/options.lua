-- Options are automatically loaded before lazy.nvim startup
-- Default options that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/options.lua
-- Add any additional options here

-- Highlight the 80th and 100th columns
local opt = vim.opt
-- opt.colorcolumn = "80"
opt.wrap = true

vim.g.vimtex_view_method = "skim"
vim.g.vimtex_view_skim_sync = 1
vim.g.vimtex_view_skim_activate = 1

-- require("catppuccin").setup({
--   flavour = "auto", -- latte, frappe, macchiato, mocha
-- })
-- vim.cmd.colorscheme("catppuccin")

-- Autosave: automatically write all buffers when leaving or losing focus
opt.autowriteall = true

-- Enable experimental external UI for cmdline/messages (Nvim 0.12+)
-- Eliminates "Press ENTER" prompts
vim.g._extui = true
