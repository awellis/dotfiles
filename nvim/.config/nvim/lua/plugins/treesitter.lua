return {
  {
    "nvim-treesitter/nvim-treesitter",
    dependencies = {
      "nvim-treesitter/nvim-treesitter-textobjects",
    },
    version = false, -- last release is way too old and doesn't work on Windows
    build = ":TSUpdate",
    event = { "LazyFile", "VeryLazy" },
    lazy = vim.fn.argc(-1) == 0, -- load treesitter early when opening a file from the cmdline
    init = function(plugin)
      -- PERF: add nvim-treesitter queries to the rtp and it's custom query predicates early
      -- This is needed because a bunch of plugins no longer `require("nvim-treesitter")`, which
      -- no longer trigger the **nvim-treesitter** module to be loaded in time.
      -- Luckily, the only things that those plugins need are the custom queries, which we make available
      -- during startup.
      require("lazy.core.loader").add_to_rtp(plugin)
      -- query_predicates module was removed in newer nvim-treesitter versions
      pcall(require, "nvim-treesitter.query_predicates")
    end,
    cmd = { "TSUpdateSync", "TSUpdate", "TSInstall" },
    keys = {
      -- Incremental selection removed as it's no longer supported
      -- Use flash.nvim for similar functionality
    },
    opts_extend = { "ensure_installed" },
    ---@type TSConfig
    ---@diagnostic disable-next-line: missing-fields
    opts = {
      highlight = { enable = true },
      indent = { enable = true },
      ensure_installed = {
        "bash",
        "c",
        "diff",
        "html",
        "javascript",
        "jsdoc",
        "json",
        "jsonc",
        "julia",
        "latex",
        "lua",
        "luadoc",
        "luap",
        "markdown",
        "markdown_inline",
        "norg",
        "org",
        "printf",
        "python",
        "query",
        "r",
        "regex",
        "toml",
        "tsx",
        "typescript",
        "vim",
        "vimdoc",
        "xml",
        "yaml",
      },
      -- Incremental selection removed in new nvim-treesitter version
      -- Use flash.nvim instead for similar functionality
      textobjects = {
        move = {
          enable = true,
          goto_next_start = { ["]f"] = "@function.outer", ["]c"] = "@class.outer", ["]a"] = "@parameter.inner" },
          goto_next_end = { ["]F"] = "@function.outer", ["]C"] = "@class.outer", ["]A"] = "@parameter.inner" },
          goto_previous_start = { ["[f"] = "@function.outer", ["[c"] = "@class.outer", ["[a"] = "@parameter.inner" },
          goto_previous_end = { ["[F"] = "@function.outer", ["[C"] = "@class.outer", ["[A"] = "@parameter.inner" },
        },
      },
    },
    ---@param opts TSConfig
    config = function(_, opts)
      if type(opts.ensure_installed) == "table" then
        -- Handle deduplication manually since LazyVim.dedup might not be available
        local seen = {}
        local deduped = {}
        for _, lang in ipairs(opts.ensure_installed) do
          if not seen[lang] then
            seen[lang] = true
            table.insert(deduped, lang)
          end
        end
        opts.ensure_installed = deduped
      end
      -- Configure nvim-treesitter with a safe loader to avoid early-cache misses
      local function do_setup()
        local ok_cfg, configs = pcall(require, "nvim-treesitter.configs")
        if ok_cfg and configs and configs.setup then
          configs.setup(opts)
          return
        end
        local ok_ts, ts = pcall(require, "nvim-treesitter")
        if ok_ts and ts and ts.setup then
          ts.setup(opts)
          return
        end
        vim.schedule(function()
          vim.notify("nvim-treesitter not available for setup (will skip)", vim.log.levels.WARN)
        end)
      end
      if pcall(require, "nvim-treesitter.configs") then
        do_setup()
      else
        vim.schedule(do_setup)
      end
    end,
  },
}
