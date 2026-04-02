return {
  {
    "R-nvim/R.nvim",
    lazy = false,
    opts = {
      R_app = "radian",
      R_cmd = "R",
      bracketed_paste = true,
      min_editor_width = 72,
    },
  },
  {
    "nvim-treesitter/nvim-treesitter",
    opts = { ensure_installed = { "r", "rnoweb" } },
  },
  {
    "neovim/nvim-lspconfig",
    opts = {
      servers = {
        r_language_server = {
          cmd = { "R", "--slave", "-e", "languageserver::run()" },
          root_dir = function(bufnr)
            local fname = vim.api.nvim_buf_get_name(bufnr)
            return require("lspconfig.util").root_pattern("DESCRIPTION", "NAMESPACE", ".Rbuildignore")(fname)
              or require("lspconfig.util").find_git_ancestor(fname)
              or vim.fn.getcwd()
          end,
        },
      },
    },
  },
}
