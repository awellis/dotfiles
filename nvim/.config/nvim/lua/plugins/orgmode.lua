return {
  "nvim-orgmode/orgmode",
  event = "VeryLazy",
  ft = { "org" },
  dependencies = {
    "nvim-treesitter/nvim-treesitter",
  },
  config = function()
    require("orgmode").setup({
      -- Your org files location
      org_agenda_files = "~/Dropbox/org/**/*",
      org_default_notes_file = "~/Dropbox/org/inbox.org",

      -- Agenda settings
      org_agenda_span = "week",
      org_agenda_start_on_weekday = 1, -- Monday
      org_agenda_skip_scheduled_if_done = true,
      org_agenda_skip_deadline_if_done = true,

      -- TODO keywords matching your current workflow
      org_todo_keywords = { "TODO(t)", "NEXT(n)", "WAITING(w)", "|", "DONE(d)", "CANCELLED(c)" },
      org_todo_keyword_faces = {
        TODO = ":foreground red :weight bold",
        NEXT = ":foreground blue :weight bold",
        WAITING = ":foreground orange :weight bold",
        DONE = ":foreground green :weight bold",
        CANCELLED = ":foreground gray :weight bold",
      },

      -- Priority settings (matching your [#A], [#B], [#C] usage)
      org_priority_highest = "A",
      org_priority_default = "B",
      org_priority_lowest = "C",

      -- Logging
      org_log_done = "time", -- Log when tasks are marked done
      org_log_into_drawer = "LOGBOOK",

      -- Tags
      org_tags_column = -80,
      org_use_tag_inheritance = true,

      -- Archive location
      org_archive_location = "~/Dropbox/org/archive/completed.org::* From %s",

      -- Startup folding
      org_startup_folded = "content",

      -- Calendar/popup for dates
      calendar_week_start_day = 1, -- Monday

      -- Capture templates
      org_capture_templates = {
        -- Quick TODO to inbox
        t = {
          description = "Task",
          template = "* TODO [#B] %?\nSCHEDULED: %t\n[%<%Y-%m-%d %a %H:%M>]",
          target = "~/Dropbox/org/inbox.org",
        },
        -- High priority task
        T = {
          description = "Urgent Task",
          template = "* TODO [#A] %?\nSCHEDULED: %t\nDEADLINE: %t\n[%<%Y-%m-%d %a %H:%M>]",
          target = "~/Dropbox/org/inbox.org",
        },
        -- Quick note
        n = {
          description = "Note",
          template = "* %?\n[%<%Y-%m-%d %a %H:%M>]",
          target = "~/Dropbox/org/inbox.org",
        },
        -- Link capture (for URLs you want to read later)
        l = {
          description = "Link",
          template = "* TODO [[%x][%?]]\nSCHEDULED: %t\n[%<%Y-%m-%d %a %H:%M>]",
          target = "~/Dropbox/org/inbox.org",
          headline = "Links",
        },
        -- Work task
        w = {
          description = "Work Task",
          template = "* TODO [#B] %?\nSCHEDULED: %t",
          target = "~/Dropbox/org/areas/work.org",
        },
        -- Meeting notes
        m = {
          description = "Meeting Notes",
          template = [[
* Meeting: %?
[%<%Y-%m-%d %a %H:%M>]
** Participants
-
** Agenda
1.
** Discussion
-
** Action Items
*** TODO
*** TODO
** Next Steps
-]],
          target = "~/Dropbox/org/inbox.org",
        },
        -- Journal entry
        j = {
          description = "Journal Entry",
          template = [[
*** %<%Y-%m-%d %A>
**** Daily Review
***** Morning Planning
****** Today's Priority
1.
2.
3.
****** Energy Level
[1-10]:
***** Work Log
****** Accomplished
-
****** In Progress
-
***** Evening Review
****** What went well?
-
****** What could be improved?
-
***** Gratitude
-
***** Health & Habits
- [ ] Exercise
- [ ] Meditation
- [ ] Reading
- [ ] Water intake]],
          target = "~/Dropbox/org/journal/2025.org",
          headline = "2025",
        },
      },

      -- Notifications (experimental)
      notifications = {
        enabled = true,
        repeater_reminder_time = 10, -- minutes before
        deadline_warning_reminder_time = 10,
        reminder_time = 10,
      },

      -- Mappings
      mappings = {
        org = {
          org_toggle_checkbox = "<C-Space>",
        },
      },
    })
  end,
}
