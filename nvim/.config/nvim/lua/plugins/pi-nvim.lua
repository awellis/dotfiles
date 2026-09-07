return {
  "cperalt/pi-nvim",
  lazy = false,
  config = function()
    require("pi-nvim").setup({
      -- Keep normal context lightweight. Visual selections are still sent
      -- exactly through the live editor context, including unsaved text.
      context_format = "reference",
      show_popup = false,
      live_context = {
        enabled = true,
        debounce_ms = 150,
        include_buffer_text = false,
        max_selection_bytes = 50000,
      },
    })
  end,
}
