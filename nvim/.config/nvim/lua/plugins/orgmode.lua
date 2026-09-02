return {
  "nvim-orgmode/orgmode",
  event = "VeryLazy",
  ft = "org",
  keys = {
    { "<leader>n", nil, desc = "Org" },
    { "<leader>na", "<cmd>Org agenda<cr>", desc = "Org agenda" },
    { "<leader>nc", "<cmd>Org capture<cr>", desc = "Org capture" },
    { "<leader>ni", "<cmd>edit ~/Syncthing/org/inbox.org<cr>", desc = "Org inbox" },
    { "<leader>nt", nil, desc = "Org TODO" },
    {
      "<leader>ntd",
      function()
        local org = require("orgmode").instance()
        local headline = org.files:get_closest_headline()
        if not headline then
          vim.notify("No Org heading at point", vim.log.levels.WARN)
          return
        end

        -- Drive orgmode's normal TODO transition so CLOSED timestamps,
        -- parent cookies, and other transition behavior are preserved.
        local fast_key = headline:is_done() and "t" or "d"
        vim.api.nvim_feedkeys(fast_key, "n", false)
        require("orgmode").action("org_mappings.todo_next_state")
      end,
      desc = "Toggle Org DONE",
    },
  },
  config = function()
    local org_dir = "~/Syncthing/org"

    require("orgmode").setup({
      -- Keep this in sync with the Doom Emacs Org setup. Listing agenda
      -- sources explicitly avoids indexing archives and Syncthing versions.
      org_agenda_files = {
        org_dir .. "/inbox.org",
        org_dir .. "/inbox-mobile.org",
        org_dir .. "/reminders-beorg.org",
        org_dir .. "/beorg-customize-init.org",
        org_dir .. "/areas/*.org",
        org_dir .. "/projects/*.org",
      },
      org_default_notes_file = org_dir .. "/inbox.org",
      org_archive_location = org_dir .. "/archive/completed.org::",

      org_agenda_span = "day",
      org_agenda_start_on_weekday = 1,
      org_deadline_warning_days = 7,
      org_agenda_skip_scheduled_if_done = true,
      org_agenda_skip_deadline_if_done = true,

      org_todo_keywords = { "TODO(t)", "INPROGRESS(i)", "WAITING(w)", "|", "DONE(d)", "CANCELLED(c)" },
      org_todo_keyword_faces = {
        INPROGRESS = ":foreground #f9e2af :weight bold",
        WAITING = ":foreground #a6adc8 :weight bold",
        CANCELLED = ":foreground #6c7086 :weight bold",
      },

      org_priority_highest = "A",
      org_priority_default = "B",
      org_priority_lowest = "C",
      org_log_done = "time",
      org_log_into_drawer = "LOGBOOK",
      org_tags_column = -80,
      org_use_tag_inheritance = true,
      org_startup_folded = "content",
      calendar_week_start_day = 1,

      org_capture_templates = {
        t = {
          description = "Task → inbox",
          template = "* TODO %?\n%U",
          target = org_dir .. "/inbox.org",
        },
        n = {
          description = "Note → inbox",
          template = "* %? :note:\n%U",
          target = org_dir .. "/inbox.org",
        },
        w = {
          description = "Work task",
          template = "* TODO %?\n%U",
          target = org_dir .. "/areas/work.org",
          headline = "Tasks",
        },
        p = {
          description = "Personal task",
          template = "* TODO %?\n%U",
          target = org_dir .. "/areas/personal.org",
        },
        s = {
          description = "Shopping item",
          template = "* TODO %? :errand:\n%U",
          target = org_dir .. "/inbox.org",
        },
        m = {
          description = "Meeting",
          template = "* Meeting: %? :meeting:\n%U\n** Notes\n-\n** Actions\n- [ ] ",
          target = org_dir .. "/inbox.org",
        },
        j = {
          description = "Daily review",
          template = "* %<%Y-%m-%d %A>\n** Top 3\n1. %?\n2.\n3.\n** Notes\n-",
          target = org_dir .. "/journal/%<%Y>.org",
        },
      },

      notifications = {
        enabled = true,
        cron_enabled = false,
        repeater_reminder_time = 10,
        deadline_warning_reminder_time = 10,
        reminder_time = 10,
      },

      mappings = {
        prefix = "<leader>n",
        org = {
          -- Keep orgmode's normal-mode shortcuts. Use <leader>nts for the
          -- state prompt; <leader>ntd above toggles DONE directly.
          org_todo = { "cit", "<leader>nts" },
          org_todo_prev = { "ciT", "<leader>nT" },
          -- The default is <prefix>t (= <leader>nt), which consumes the TODO
          -- prefix before <leader>ntd or <leader>nts can be completed.
          org_set_tags_command = "<leader>ng",
        },
      },
      ui = {
        input = {
          use_vim_ui = true,
        },
      },
    })

    -- Orgmode ships an experimental LSP for symbols, references, and completion.
    vim.lsp.enable("org")
  end,
}
