return {
  -- slime (REPL integration)
  {
    "jpalardy/vim-slime",
    ft = { "julia", "python", "r", "rmd", "quarto" },
    keys = {
      { "<leader>rC", "<cmd>SlimeConfig<cr>", desc = "Slime Config" },
      { "<leader>rr", "<Plug>SlimeSendCell<BAR>/^# %%<CR>", desc = "Slime Send Cell" },
      { "<leader>rr", ":<C-u>'<,'>SlimeSend<CR>", mode = "v", desc = "Slime Send Selection" },
      { "<leader>rl", "<Plug>SlimeLineSend", desc = "Slime Send Line" },
      { "<leader>rp", "<Plug>SlimeParagraphSend", desc = "Slime Send Paragraph" },
    },
    init = function()
      vim.g.slime_target = "tmux"
      vim.g.slime_default_config = { socket_name = "default", target_pane = "{last}" }
      vim.g.slime_cell_delimiter = "# %%"
      vim.g.slime_bracketed_paste = 1
    end,
  },
}
