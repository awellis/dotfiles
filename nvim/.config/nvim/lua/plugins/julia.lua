return {
  {
    "neovim/nvim-lspconfig",
    opts = {
      servers = {
        -- Use nvim-lspconfig's current LanguageServer.runserver() integration.
        -- The dedicated environment is maintained outside Mason.
        julials = {
          mason = false,
        },
      },
      setup = {
        julials = function(_, opts)
          vim.lsp.config("julials", opts)
          vim.lsp.enable("julials")
          return true
        end,
      },
    },
  },
}
