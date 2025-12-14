return {
  {
    "nvim-neorg/neorg",
    dependencies = {
      "nvim-lua/plenary.nvim",
      "nvim-treesitter/nvim-treesitter",
    },
    ft = "norg",
    cmd = "Neorg",
    keys = {
      { "<leader>nj", "<cmd>Neorg journal today<cr>", desc = "Journal Today" },
      { "<leader>ny", "<cmd>Neorg journal yesterday<cr>", desc = "Journal Yesterday" },
      { "<leader>nt", "<cmd>Neorg journal tomorrow<cr>", desc = "Journal Tomorrow" },
      { "<leader>ni", "<cmd>Neorg index<cr>", desc = "Open Index" },
      { "<leader>nw", "<cmd>Neorg workspace<cr>", desc = "Switch Workspace" },
      { "<leader>nr", "<cmd>Neorg return<cr>", desc = "Return to Code" },
    },
    version = false,
    config = function()
      -- Ensure nvim-treesitter is loaded before Neorg integrates with it
      local ok_lazy, lazy = pcall(require, "lazy")
      if ok_lazy and lazy and lazy.load then
        pcall(lazy.load, { plugins = { "nvim-treesitter" } })
      end
      pcall(require, "nvim-treesitter.ts_utils")

      -- Back-compat shim for newer nvim-treesitter
      local ok_parsers, parsers = pcall(require, "nvim-treesitter.parsers")
      if ok_parsers and type(parsers.get_parser_configs) ~= "function" then
        parsers.get_parser_configs = function()
          return parsers
        end
      end

      require("neorg").setup({
        load = {
          -- Core functionality
          ["core.defaults"] = {},

          -- Visual enhancements (icons, concealing)
          ["core.concealer"] = {
            config = {
              icons = {
                todo = {
                  undone = { icon = " " },
                  done = { icon = "" },
                  pending = { icon = "" },
                  on_hold = { icon = "" },
                  cancelled = { icon = "" },
                  recurring = { icon = "" },
                  uncertain = { icon = "?" },
                  urgent = { icon = "" },
                },
              },
            },
          },

          -- Treesitter integration
          ["core.integrations.treesitter"] = {
            config = {
              configure_parsers = true,
              install_parsers = true,
            },
          },

          -- Workspace/directory management
          ["core.dirman"] = {
            config = {
              workspaces = {
                notes = "~/notes",
                work = "~/notes/work",
                personal = "~/notes/personal",
              },
              default_workspace = "notes",
            },
          },

          -- Keybindings (uses localleader)
          ["core.keybinds"] = {
            config = {
              default_keybinds = true,
            },
          },

          -- Journal for daily notes
          ["core.journal"] = {
            config = {
              workspace = "notes",
              journal_folder = "journal",
              strategy = "flat", -- or "nested" for year/month folders
            },
          },

          -- Export to markdown/other formats
          ["core.export"] = {},
          ["core.export.markdown"] = {
            config = {
              extensions = "all",
            },
          },

          -- Generate summary/TOC
          ["core.summary"] = {},

          -- Promote/demote headings
          ["core.promo"] = {},

          -- Continue lists/items with Alt+Enter
          ["core.itero"] = {},

          -- Quality of life (todo cycling, etc)
          ["core.qol.toc"] = {},
          ["core.qol.todo_items"] = {},

          -- Code block editing in separate buffer
          ["core.looking-glass"] = {},

          -- Date/time insertion
          ["core.tempus"] = {},

          -- Literate programming (tangle code blocks)
          ["core.tangle"] = {
            config = {
              tangle_on_write = false, -- Set to true if you want auto-tangle
            },
          },

          -- Presenter mode for slideshows (requires zen-mode or truezen plugin)
          -- Uncomment if you install folke/zen-mode.nvim:
          -- ["core.presenter"] = {
          --   config = {
          --     zen_mode = "zen-mode",
          --   },
          -- },
        },
      })
    end,
  },
}
