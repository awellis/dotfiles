return {
  "saghen/blink.cmp",
  -- Make blink.cmp toggleable
  opts = function(_, opts)
    vim.b.completion = true

    Snacks.toggle({
      name = "Completion",
      get = function()
        return vim.b.completion
      end,
      set = function(state)
        vim.b.completion = state
      end,
    }):map("<leader>uk")

    opts.enabled = function()
      return vim.b.completion ~= false
    end
    return opts
  end,
  fuzzy = {
    sorts = {
      "exact",
      -- defaults
      "score",
      "sort_text",
    },
  },
  sources = {
    providers = {
      buffer = {
        -- keep case of first char
        transform_items = function(a, items)
          local keyword = a.get_keyword()
          local correct, case
          if keyword:match("^%l") then
            correct = "^%u%l+$"
            case = string.lower
          elseif keyword:match("^%u") then
            correct = "^%l+$"
            case = string.upper
          else
            return items
          end

          -- avoid duplicates from the corrections
          local seen = {}
          local out = {}
          for _, item in ipairs(items) do
            local raw = item.insertText
            if raw:match(correct) then
              local text = case(raw:sub(1, 1)) .. raw:sub(2)
              item.insertText = text
              item.label = text
            end
            if not seen[item.insertText] then
              seen[item.insertText] = true
              table.insert(out, item)
            end
          end
          return out
        end,
      },
    },
  },
}
