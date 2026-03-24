return {
  {
    "zbirenbaum/copilot.lua",
    -- Keep Copilot enabled, but avoid extra UI to reduce agent churn
    opts = {
      suggestion = { enabled = false },
      -- To switch to ghost text instead of menu completions, replace the line above with:
      -- suggestion = {
      --   enabled = true,
      --   auto_trigger = true,
      --   keymap = { accept = "<C-y>" },
      -- },
      panel = { enabled = false },
      filetypes = {
        markdown = true,
        help = true,
        gitcommit = true,
        ["*"] = true,
      },
    },
  },
}

