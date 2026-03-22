return {
  "iwe-org/iwe.nvim",
  ft = "markdown",
  config = function()
    require("iwe").setup({
      lsp = {
        auto_format_on_save = true,
        enable_inlay_hints = true,
      },
      mappings = {
        leader = "<leader>i",
        enable_markdown_mappings = true,
        enable_picker_keybindings = true,
        enable_lsp_keybindings = true,
        enable_preview_keybindings = true,
      },
      picker = {
        backend = "snacks",
      },
      telescope = {
        enabled = false,
      },
    })
  end,
}
