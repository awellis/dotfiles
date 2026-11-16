local HOME = os.getenv("HOME")

return {
  {
    "stevearc/conform.nvim",
    opts = {
      formatters_by_ft = {
        julia = { "julia_formatter" },
      },
      formatters = {
        julia_formatter = {
          command = "julia",
          args = {
            "--startup-file=no",
            "--history-file=no",
            "--project=" .. HOME .. "/.julia/environments/nvim-lspconfig",
            "-e",
            "using JuliaFormatter; format_file(ARGS[1])",
            "$FILENAME",
          },
          stdin = false,
        },
      },
    },
  },
}
