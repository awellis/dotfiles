return {
  {
    "mason-org/mason.nvim",
    opts = function(_, opts)
      opts.ensure_installed = vim.tbl_filter(function(tool)
        return tool ~= "hlint"
      end, opts.ensure_installed or {})
    end,
  },
  {
    "stevearc/conform.nvim",
    optional = true,
    opts = {
      formatters_by_ft = {
        cabal = { "cabal_gild" },
      },
      formatters = {
        cabal_gild = {
          command = "cabal-gild",
          args = { "--stdin=$FILENAME" },
          stdin = true,
        },
      },
    },
  },
  {
    "mfussenegger/nvim-lint",
    optional = true,
    opts = {
      linters = {
        hlint = {
          cmd = function()
            local homebrew_hlint = "/opt/homebrew/bin/hlint"
            return vim.fn.executable(homebrew_hlint) == 1 and homebrew_hlint or "hlint"
          end,
        },
      },
    },
  },
}
