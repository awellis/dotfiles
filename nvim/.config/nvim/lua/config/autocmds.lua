-- Autocmds are automatically loaded on the VeryLazy event
-- Default autocmds that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/autocmds.lua
--
-- Add any additional autocmds here
-- with `vim.api.nvim_create_autocmd`
--
-- Or remove existing autocmds by their group name (which is prefixed with `lazyvim_` for the defaults)
-- e.g. vim.api.nvim_del_augroup_by_name("lazyvim_wrap_spell")

-- Auto :lcd to terminal CWD via OSC7 (:h terminal-osc7)
vim.api.nvim_create_autocmd("TermRequest", {
  desc = "Auto :lcd to terminal CWD on OSC7",
  callback = function(ev)
    if string.sub(vim.v.termrequest, 1, 4) == "\x1b]7;" then
      local dir = string.gsub(vim.v.termrequest, "^\x1b%]7;file://[^/]*", "")
      dir = string.gsub(dir, "\x1b\\$", "")
      if vim.fn.isdirectory(dir) == 1 then
        vim.api.nvim_buf_set_var(ev.buf, "osc7_dir", dir)
        if vim.api.nvim_get_current_buf() == ev.buf then
          vim.cmd.lcd(dir)
        end
      end
    end
  end,
})

-- When entering a terminal buffer, lcd to its OSC7 directory if set
vim.api.nvim_create_autocmd("BufEnter", {
  pattern = "term://*",
  callback = function(ev)
    local ok, dir = pcall(vim.api.nvim_buf_get_var, ev.buf, "osc7_dir")
    if ok and dir and vim.fn.isdirectory(dir) == 1 then
      vim.cmd.lcd(dir)
    end
  end,
})

-- Jump to previous/next shell prompt with [[ and ]] (:h shell-prompt)
vim.api.nvim_create_autocmd("TermOpen", {
  desc = "Setup shell prompt navigation",
  callback = function()
    vim.keymap.set("n", "[[", function()
      vim.fn.search("^❯\\|^\\$\\|^➜\\|^%", "bW")
    end, { buffer = true, desc = "Previous shell prompt" })
    vim.keymap.set("n", "]]", function()
      vim.fn.search("^❯\\|^\\$\\|^➜\\|^%", "W")
    end, { buffer = true, desc = "Next shell prompt" })
  end,
})
