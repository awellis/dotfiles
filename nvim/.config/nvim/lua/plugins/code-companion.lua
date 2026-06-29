return {
  "olimorris/codecompanion.nvim",
  dependencies = {
    "nvim-lua/plenary.nvim",
    "nvim-treesitter/nvim-treesitter",
  },
  keys = {
    { "<leader>ai", "<cmd>CodeCompanionChat Toggle<cr>", desc = "AI Chat" },
    { "<leader>ae", "<cmd>CodeCompanionActions<cr>", desc = "AI Actions" },
    { "<leader>ae", "<cmd>CodeCompanionActions<cr>", mode = "v", desc = "AI Actions (visual)" },
    -- ACP agent chats (external agents over the Agent Client Protocol)
    { "<leader>am", nil, desc = "ACP agents" },
    { "<leader>amp", "<cmd>CodeCompanionChat adapter=pi<cr>", desc = "ACP chat: pi" },
    { "<leader>amc", "<cmd>CodeCompanionChat adapter=claude_code<cr>", desc = "ACP chat: Claude" },
  },
  opts = {
    -- `strategies` is the legacy key; this version maps it onto `interactions`.
    strategies = {
      chat = { adapter = "anthropic" },
      inline = { adapter = "anthropic" },
    },
    adapters = {
      -- NOTE: this CodeCompanion version nests adapters under `http`/`acp`.
      -- A flat `adapters.anthropic` is silently ignored by the resolver.
      http = {
        anthropic = function()
          return require("codecompanion.adapters").extend("anthropic", {
            env = {
              api_key = "ANTHROPIC_API_KEY",
            },
            schema = {
              model = {
                default = "claude-sonnet-4-6",
              },
            },
          })
        end,
      },
      -- ACP adapters: external agents driven over the Agent Client Protocol.
      -- `claude_code` is built in and launches `claude-agent-acp` (on PATH).
      acp = {
        -- The `pi` coding agent, bridged to ACP by the `pi-acp` stdio adapter
        -- (`npm i -g pi-acp`). pi-acp spawns `pi --mode rpc` underneath and
        -- uses pi's own provider/model config (~/.pi/agent/settings.json), so
        -- no API key is set here. Change the model in pi's settings or via
        -- Ctrl+P inside a pi session.
        pi = function()
          local helpers = require("codecompanion.adapters.acp.helpers")
          return {
            name = "pi",
            formatted_name = "pi (ACP)",
            type = "acp",
            roles = {
              llm = "assistant",
              user = "user",
            },
            opts = {
              vision = false,
            },
            commands = {
              default = { "pi-acp" },
            },
            defaults = {
              mcpServers = {},
              timeout = 20000, -- 20 seconds
            },
            parameters = {
              protocolVersion = 1,
              clientCapabilities = {
                fs = { readTextFile = true, writeTextFile = true },
              },
              clientInfo = {
                name = "CodeCompanion.nvim",
                version = "1.0.0",
              },
            },
            handlers = {
              setup = function(self)
                return true
              end,
              form_messages = function(self, messages, capabilities)
                return helpers.form_messages(self, messages, capabilities)
              end,
              on_exit = function(self, code) end,
            },
          }
        end,
      },
    },
  },
}
