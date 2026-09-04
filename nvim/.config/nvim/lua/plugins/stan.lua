-- Stan (mc-stan.org) support.
--
-- Neovim has no built-in ftdetect for .stan, and nvim-treesitter ships no stan
-- parser, so both are registered here.
--
-- The parser registration must live in a `User TSUpdate` autocommand (the
-- pattern documented under "Adding custom languages"): nvim-treesitter wipes
-- `package.loaded['nvim-treesitter.parsers']` at the start of every install and
-- update, then fires TSUpdate so user entries are re-applied to the fresh
-- table. Registering from `opts`/`config` instead is silently discarded.
--
-- Highlight queries are vendored in nvim/queries/{stan,stanfunctions}/ rather
-- than pulled via install_info.queries, because upstream keeps both grammars'
-- queries in one directory (highlights.scm + sf-highlights.scm) and that cannot
-- be mapped onto two parsers.
--
-- Keep the revision in sync with helix/.config/helix/build-grammars.sh.

local repo = "https://github.com/WardBrian/tree-sitter-stan"
local revision = "74d7eb2d970c84982c8c687a20695ebe2f259cfd" -- v0.3.1

return {
  {
    "nvim-treesitter/nvim-treesitter",
    init = function()
      vim.filetype.add({
        extension = {
          stan = "stan",
          stanfunctions = "stanfunctions",
        },
      })

      vim.api.nvim_create_autocmd("User", {
        pattern = "TSUpdate",
        group = vim.api.nvim_create_augroup("stan_treesitter", { clear = true }),
        callback = function()
          local parsers = require("nvim-treesitter.parsers")
          for _, lang in ipairs({ "stan", "stanfunctions" }) do
            parsers[lang] = {
              install_info = {
                url = repo,
                revision = revision,
                location = "grammars/" .. lang,
              },
              tier = 2,
            }
          end
        end,
      })
    end,
    opts = { ensure_installed = { "stan", "stanfunctions" } },
  },
}
