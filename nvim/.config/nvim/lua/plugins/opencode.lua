return {
  "NickvanDyke/opencode.nvim",
  dependencies = {
    -- Recommended for better prompt input, and required to use opencode.nvim's embedded terminal. Otherwise optional.
    { "folke/snacks.nvim", opts = { input = { enabled = true } } },
  },
  ---@type opencode.Opts
  opts = {
    -- Your configuration, if any
  },
  keys = {
    {
      "<leader>aA",
      function()
        require("opencode").ask()
      end,
      desc = "Ask opencode",
    },
    {
      "<leader>ao",
      function()
        require("opencode").toggle()
      end,
      desc = "Toggle opencode",
    },
    {
      "<leader>an",
      function()
        require("opencode").command("session_new")
      end,
      desc = "New opencode session",
    },
    {
      "<leader>ay",
      function()
        require("opencode").command("messages_copy")
      end,
      desc = "Copy last message",
    },
    {
      "<leader>ap",
      function()
        require("opencode").select_prompt()
      end,
      desc = "Select prompt",
      mode = { "n", "v" },
    },
    {
      "<leader>ax",
      function()
        require("opencode").prompt("Explain @cursor and its context")
      end,
      desc = "Explain code near cursor",
    },
  },
}
