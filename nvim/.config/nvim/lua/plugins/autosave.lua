-- inactive, returns empty table
if true then
  return {}
end

return {
  "Pocco81/auto-save.nvim",
  opts = {
    execution_message = {
      message = function() -- message to print on save
        return ""
      end,
    },
  },
}
