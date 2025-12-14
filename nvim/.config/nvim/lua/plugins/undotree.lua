return {
  {
    "mbbill/undotree",
    lazy = true, -- needs to be explicitly set, because of the keys property
    keys = {
      {
        "<leader>ut",
        vim.cmd.UndotreeToggle,
        desc = "Toggle undotree",
      },
    },
  },
}
