return {
  -- Quarto documents (.qmd)
  {
    "quarto-dev/quarto-nvim",
    dependencies = {
      "jmbuhr/otter.nvim",
      "nvim-treesitter/nvim-treesitter",
    },
    ft = { "quarto", "markdown" },
    init = function()
      -- Quarto labels Observable JS fences as `ojs`; use the JavaScript
      -- parser for those Tree-sitter injections.
      vim.treesitter.language.register("javascript", "ojs")
    end,
    keys = {
      { "<leader>q", nil, desc = "Quarto" },
      { "<leader>qp", "<cmd>QuartoPreview<cr>", desc = "Preview" },
      { "<leader>qr", "<cmd>QuartoSendAbove<cr>", desc = "Run cells above" },
      { "<leader>qc", "<cmd>QuartoSendBelow<cr>", desc = "Run cell" },
    },
    opts = {
      lspFeatures = {
        enabled = true,
        -- OJS is highlighted with the JavaScript parser, but is not valid
        -- standard JavaScript, so exclude it from JS/TS LSP diagnostics.
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

  -- Use HTML comments in Quarto/Markdown prose.
  {
    "folke/ts-comments.nvim",
    opts = {
      lang = {
        quarto = "<!-- %s -->",
        markdown = "<!-- %s -->",
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
