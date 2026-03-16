return {
  "olimorris/codecompanion.nvim",
  dependencies = {
    "nvim-lua/plenary.nvim",
    "nvim-treesitter/nvim-treesitter",
  },
  keys = {
    { "<leader>ai", "<cmd>CodeCompanionChat Toggle<cr>", desc = "AI Chat" },
    { "<leader>ae", "<cmd>CodeCompanionActions<cr>", desc = "AI Actions" },
    { "<leader>ae", "<cmd>CodeCompanionActions<cr>", mode = "v", desc = "AI Actions (visual)" },
  },
  opts = {
    strategies = {
      chat = { adapter = "anthropic" },
      inline = { adapter = "anthropic" },
    },
    adapters = {
      anthropic = function()
        return require("codecompanion.adapters").extend("anthropic", {
          env = {
            api_key = "ANTHROPIC_API_KEY",
          },
          schema = {
            model = {
              default = "claude-sonnet-4-6",
            },
          },
        })
      end,
    },
  },
}
