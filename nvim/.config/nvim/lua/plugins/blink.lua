return {
  "saghen/blink.cmp",
  -- Make blink.cmp toggleable
  opts = function(_, opts)
    local prose_ft = { markdown = true, text = true, tex = true, latex = true, quarto = true, org = true, rst = true }

    -- Check if cursor is inside a code block via treesitter
    local function in_code_block()
      local node = vim.treesitter.get_node()
      while node do
        local t = node:type()
        if t == "fenced_code_block" or t == "code_fence_content" or t == "code_block" then
          return true
        end
        node = node:parent()
      end
      return false
    end

    local function completion_active()
      if vim.b.completion == false then return false end
      if vim.b.completion == true then return true end
      -- auto: prose filetypes only complete in code blocks
      if prose_ft[vim.bo.filetype] then return in_code_block() end
      return true
    end

    -- Default prose filetypes to "auto" (nil), code filetypes to true
    vim.api.nvim_create_autocmd("FileType", {
      group = vim.api.nvim_create_augroup("completion_prose", { clear = true }),
      callback = function(ev)
        if not prose_ft[ev.match] then
          vim.b[ev.buf].completion = true
        end
        -- prose filetypes left as nil = "auto" mode
      end,
    })

    -- Blink-only toggle
    Snacks.toggle({
      name = "Blink Completion",
      get = function()
        return vim.b.completion ~= false
      end,
      set = function(state)
        vim.b.completion = state and nil or false
      end,
    }):map("<leader>uB")

    -- Copilot-only toggle
    Snacks.toggle({
      name = "Copilot",
      get = function()
        return vim.b.copilot_suggestion_auto_trigger ~= false
      end,
      set = function(state)
        local ok, suggestion = pcall(require, "copilot.suggestion")
        if ok and not state then suggestion.dismiss() end
        vim.b.copilot_suggestion_auto_trigger = state
      end,
    }):map("<leader>at")

    -- Unified toggle for both
    Snacks.toggle({
      name = "Completion (all)",
      get = function()
        return vim.b.completion ~= false
      end,
      set = function(state)
        vim.b.completion = state and nil or false
        local ok, suggestion = pcall(require, "copilot.suggestion")
        if ok and not state then suggestion.dismiss() end
        vim.b.copilot_suggestion_auto_trigger = state
      end,
    }):map("<leader>uk")

    -- Copilot auto-trigger respects context in prose filetypes
    vim.api.nvim_create_autocmd("CursorMovedI", {
      group = vim.api.nvim_create_augroup("copilot_prose_context", { clear = true }),
      callback = function()
        if vim.b.completion == false then return end
        if not prose_ft[vim.bo.filetype] then return end
        vim.b.copilot_suggestion_auto_trigger = in_code_block()
      end,
    })

    opts.enabled = function()
      return completion_active()
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
