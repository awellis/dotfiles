return {
  {
    "zbirenbaum/copilot.lua",
    opts = {
      suggestion = {
        enabled = true,
        auto_trigger = true,
        keymap = {
          accept = "<C-y>",
          accept_word = "<M-w>",
          accept_line = "<M-l>",
          next = "<M-]>",
          prev = "<M-[>",
          dismiss = "<C-]>",
        },
      },
      panel = { enabled = false },
      -- Disable Copilot for prose/commit buffers. Avoids the LSP
      -- "Document for URI could not be found" desync that auto_trigger
      -- causes on markdown manuscripts, and keeps ghost text out of prose.
      filetypes = {
        markdown = false,
        gitcommit = false,
        help = false,
        yaml = false,
      },
    },
  },
}

