-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here
vim.keymap.set("i", "jj", "<ESC>", { silent = true })

local function open_prose_preview()
  local file = vim.api.nvim_buf_get_name(0)
  if file == "" then
    vim.notify("Save the document before opening its preview", vim.log.levels.WARN)
    return
  end

  vim.cmd("silent update")
  vim.system({ "prose-preview", file }, { text = true }, function(result)
    if result.code ~= 0 then
      vim.schedule(function()
        vim.notify(vim.trim(result.stderr or "Preview command failed"), vim.log.levels.ERROR, { title = "Prose preview" })
      end)
    end
  end)
end

vim.api.nvim_create_user_command("MarkdownPreview", open_prose_preview, { desc = "Preview Markdown or Org" })
vim.api.nvim_create_user_command("ProsePreview", open_prose_preview, { desc = "Preview Markdown or Org" })
vim.keymap.set("n", "<leader>mp", open_prose_preview, { desc = "Preview Markdown or Org" })

-- Send the visual selection to the pi TUI running in a tmux pane (open one with
-- tmux prefix+a). <leader>amp drives pi in-editor over ACP instead; this is for
-- when you want the real pi session next door.
vim.keymap.set("v", "<leader>aP", function()
  local mode = vim.fn.mode()
  local lines = vim.fn.getregion(vim.fn.getpos("v"), vim.fn.getpos("."), { type = mode })
  local first, last = vim.fn.line("v"), vim.fn.line(".")
  if first > last then
    first, last = last, first
  end
  local text = string.format(
    "%s:%d-%d\n```%s\n%s\n```\n",
    vim.fn.expand("%:."),
    first,
    last,
    vim.bo.filetype,
    table.concat(lines, "\n")
  )
  vim.system({ "tmux-ai-send" }, { stdin = text }, function(out)
    if out.code ~= 0 then
      vim.schedule(function()
        vim.notify(out.stderr, vim.log.levels.ERROR)
      end)
    end
  end)
  vim.api.nvim_input("<Esc>")
end, { desc = "Send selection to pi (tmux)" })
vim.keymap.set("n", "<leader>sm", function()
  local ok, noice = pcall(require, "noice")
  if ok and noice and noice.cmd then
    noice.cmd("history")
  else
    vim.cmd("messages")
  end
end, { desc = "Messages (Noice history or :messages)" })
