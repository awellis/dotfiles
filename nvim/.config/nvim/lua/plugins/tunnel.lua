return {
  "sourproton/tunnell.nvim",
  opts = {
    -- defaults are:
    cell_header = "# %%",
    tmux_target = "{right-of}",
  },

  -- to lazy-load on keymaps:
  keys = {
    -- suggestions for keymaps:
    { "<leader>tt", ":TunnellCell<CR>", mode = { "n" }, desc = "Tunnell cell" },
    { "<leader>tt", ":TunnellRange<CR>", mode = { "v" }, desc = "Tunnell range" },
    { "<leader>tc", ":TunnellConfig<CR>", mode = { "n" }, desc = "Tunnell config" },
  },

  -- to lazy-load on commands:
  cmd = {
    "TunnellCell",
    "TunnellRange",
    "TunnellConfig",
  },
}
