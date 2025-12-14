return {
  {
    "zbirenbaum/copilot.lua",
    -- Keep Copilot enabled, but avoid extra UI to reduce agent churn
    opts = {
      suggestion = { enabled = true, auto_trigger = true },
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

