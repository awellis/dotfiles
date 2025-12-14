return {
  {
    "folke/noice.nvim",
    optional = true,
    opts = {
      cmdline = { enabled = false },
      messages = { enabled = false },
      notify = { enabled = false },
      lsp = {
        progress = { enabled = false },
      },
      presets = {
        command_palette = false,
        long_message_to_split = false,
        inc_rename = false,
      },
    },
  },
}

