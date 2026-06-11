return {
  {
    "CopilotC-Nvim/CopilotChat.nvim",
    -- Turned off alongside copilot.lua. Re-enable by removing this line + :Lazy sync.
    enabled = false,
    dependencies = {
      { "zbirenbaum/copilot.lua" },
      { "nvim-lua/plenary.nvim", branch = "master" }, -- for curl, log and async functions
    },
    build = "make tiktoken", -- Only on MacOS or Linux
    opts = {
      -- See Configuration section for options
    },
    -- See Commands section for default commands if you want to lazy load on them
  },
}
