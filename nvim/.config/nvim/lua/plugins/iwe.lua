return {
  "iwe-org/iwe.nvim",
  ft = "markdown",
  config = function()
    local lsp_group = vim.api.nvim_create_augroup("iwe_lsp", { clear = true })

    vim.api.nvim_create_autocmd("LspAttach", {
      group = lsp_group,
      callback = function(args)
        local client = vim.lsp.get_client_by_id(args.data.client_id)
        if not client or client.name ~= "iwes" then
          return
        end

        vim.lsp.inlay_hint.enable(true, { bufnr = args.buf })
        vim.api.nvim_create_autocmd("BufWritePre", {
          group = lsp_group,
          buffer = args.buf,
          callback = function()
            vim.lsp.buf.format({
              async = false,
              bufnr = args.buf,
              filter = function(format_client)
                return format_client.name == "iwes"
              end,
            })
          end,
        })
      end,
    })

    require("iwe").setup({
      mappings = {
        leader = "<leader>i",
        enable_markdown_mappings = true,
        enable_picker_keybindings = true,
        enable_lsp_keybindings = true,
        enable_preview_keybindings = true,
      },
      picker = {
        backend = "snacks",
      },
      telescope = {
        enabled = false,
      },
    })
  end,
}
