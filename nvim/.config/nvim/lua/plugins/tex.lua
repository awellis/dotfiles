-- LaTeX: lualatex via latexmk, Skim.app preview with SyncTeX.
-- Inverse search (cmd-shift-click in Skim -> jump in nvim) is configured
-- in Skim > Preferences > Sync, not here.
return {
  {
    "lervag/vimtex",
    init = function()
      -- Viewer
      vim.g.vimtex_view_method = "skim"
      vim.g.vimtex_view_skim_sync = 1 -- forward-sync after each compile
      vim.g.vimtex_view_skim_activate = 1 -- bring Skim to front on :VimtexView
      vim.g.vimtex_view_skim_reading_bar = 1

      -- Compiler: latexmk driving lualatex
      vim.g.vimtex_compiler_method = "latexmk"
      vim.g.vimtex_compiler_latexmk = {
        aux_dir = "",
        out_dir = "",
        callback = 1,
        continuous = 1,
        executable = "latexmk",
        hooks = {},
        options = {
          "-verbose",
          "-file-line-error",
          "-synctex=1",
          "-interaction=nonstopmode",
          "-lualatex",
        },
      }

      -- Don't steal focus with the quickfix on warnings
      vim.g.vimtex_quickfix_mode = 0
    end,
  },
}
