return {
  "pwntester/octo.nvim",
  cmd = "Octo",
  dependencies = {
    "nvim-lua/plenary.nvim",
    "nvim-tree/nvim-web-devicons",
  },
  opts = {
    picker = "snacks",
  },
  keys = {
    { "<leader>gi", "<cmd>Octo issue list<cr>", desc = "Issues (Octo)" },
    { "<leader>gp", "<cmd>Octo pr list<cr>", desc = "PRs (Octo)" },
    { "<leader>gP", "<cmd>Octo pr create<cr>", desc = "Create PR (Octo)" },
    { "<leader>gD", "<cmd>Octo pr diff<cr>", desc = "PR diff (Octo)" },
    { "<leader>ga", "<cmd>Octo actions<cr>", desc = "Actions (Octo)" },
  },
}
