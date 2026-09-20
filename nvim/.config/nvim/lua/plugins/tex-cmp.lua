-- Citation / bibliography completion for LaTeX and Quarto/Markdown.
--
-- LaTeX (\cite{...}): VimTeX's cmp source bridged into blink via blink.compat.
-- Quarto/Markdown (@citekey): cmp-pandoc-references, which reads the
-- `bibliography:` key from the document's YAML front matter.
return {
  -- nvim-cmp source reading VimTeX's parsed .bib data (LaTeX)
  { "micangl/cmp-vimtex" },

  -- Pandoc citation / cross-reference source (Quarto, R Markdown, Markdown)
  { "jmbuhr/cmp-pandoc-references" },

  -- Compatibility shim so blink can consume nvim-cmp sources
  { "saghen/blink.compat", version = "*", opts = {}, lazy = true },

  {
    "saghen/blink.cmp",
    opts = {
      sources = {
        per_filetype = {
          tex = { "vimtex", "lsp", "path", "snippets", "buffer" },
          latex = { "vimtex", "lsp", "path", "snippets", "buffer" },
          quarto = { "pandoc_references", "lsp", "path", "snippets", "buffer" },
          markdown = { "pandoc_references", "lsp", "path", "snippets", "buffer" },
        },
        providers = {
          vimtex = {
            name = "vimtex",
            module = "blink.compat.source",
          },
          pandoc_references = {
            name = "pandoc_references",
            module = "blink.compat.source",
          },
        },
      },
    },
  },
}
