return {
  -- Quarto documents (.qmd)
  {
    "quarto-dev/quarto-nvim",
    dependencies = {
      "jmbuhr/otter.nvim",
      "nvim-treesitter/nvim-treesitter",
    },
    ft = { "quarto", "markdown" },
    keys = {
      { "<leader>q", nil, desc = "Quarto" },
      { "<leader>qp", "<cmd>QuartoPreview<cr>", desc = "Preview" },
      { "<leader>qr", "<cmd>QuartoSendAbove<cr>", desc = "Run cells above" },
      { "<leader>qc", "<cmd>QuartoSendBelow<cr>", desc = "Run cell" },
    },
    opts = {
      lspFeatures = {
        enabled = true,
        languages = { "r", "python", "julia" },
        chunks = "all",
        diagnostics = {
          enabled = true,
          triggers = { "BufWritePost" },
        },
        completion = {
          enabled = true,
        },
      },
      codeRunner = {
        enabled = true,
        default_method = "slime",
      },
    },
  },

  -- LSP for code embedded in Markdown/Quarto
  {
    "jmbuhr/otter.nvim",
    dependencies = { "nvim-treesitter/nvim-treesitter" },
    opts = {},
  },
}
