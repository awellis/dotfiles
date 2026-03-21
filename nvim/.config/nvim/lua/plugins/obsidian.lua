return {
  {
    "obsidian-nvim/obsidian.nvim",
    version = "*",
    ft = "markdown",
    dependencies = {
      "nvim-lua/plenary.nvim",
    },
    keys = {
      { "<leader>o", nil, desc = "Obsidian" },
      { "<leader>oo", "<cmd>Obsidian quick_switch<cr>", desc = "Open note" },
      { "<leader>on", "<cmd>Obsidian new<cr>", desc = "New note" },
      { "<leader>od", "<cmd>Obsidian today<cr>", desc = "Daily note" },
      { "<leader>os", "<cmd>Obsidian search<cr>", desc = "Search vault" },
      { "<leader>ob", "<cmd>Obsidian backlinks<cr>", desc = "Backlinks" },
      { "<leader>ot", "<cmd>Obsidian tags<cr>", desc = "Tags" },
      { "<leader>ol", "<cmd>Obsidian follow_link<cr>", desc = "Follow link" },
      { "<leader>op", "<cmd>Obsidian paste_img<cr>", desc = "Paste image" },
      { "<leader>or", "<cmd>Obsidian rename<cr>", desc = "Rename note" },
    },
    opts = {
      legacy_commands = false,

      workspaces = {
        {
          name = "vault",
          path = "~/vault",
        },
      },

      daily_notes = {
        folder = "daily",
        date_format = "%Y-%m-%d",
        template = "daily.md",
      },

      templates = {
        folder = "templates",
        date_format = "%Y-%m-%d",
        time_format = "%H:%M",
      },

      completion = {
        blink = true,
        min_chars = 2,
      },

      -- Use note title as filename, no Zettelkasten IDs
      note_id_func = function(title)
        if title ~= nil then
          return title:gsub(" ", "-"):gsub("[^A-Za-z0-9%-]", ""):lower()
        else
          return tostring(os.time())
        end
      end,
    },
  },
}
