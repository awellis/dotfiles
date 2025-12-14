(setq user-full-name "Andrew Ellis"
      user-mail-address "andrewellis@pm.me")

;; Uncomment and set your GPG key if you use one
;; (setq user-gpg-key "YOUR-GPG-KEY-ID")

;; Available themes are listed in ~/.config/doom/themes
;; Set default colors to prevent white flash during catppuccin loading
(setq default-frame-alist
      '((background-color . "#1e1e2e")
        (foreground-color . "#cdd6f4")))
(setq initial-frame-alist default-frame-alist)

(setq doom-theme 'catppuccin)
(use-package! catppuccin-theme :init (setq catppuccin-flavor 'mocha))

;; Doom exposes five (optional) variables for controlling fonts:
;; - `doom-font'
;; - `doom-variable-pitch-font'
;; - `doom-big-font' -- used for `doom-big-font-mode'
;; - `doom-unicode-font' -- for unicode glyphs
;; - `doom-serif-font' -- for serif fonts

;; Configure Fira Code with larger size
;; Use different font names based on OS (macOS has "Fira Code", Linux has "FiraCode Nerd Font Mono")
(setq doom-font (font-spec :family (if (eq system-type 'darwin) "Fira Code" "FiraCode Nerd Font Mono") :size 16)
      doom-variable-pitch-font (font-spec :family "FiraCode Nerd Font" :size 16)
      doom-big-font (font-spec :family (if (eq system-type 'darwin) "Fira Code" "FiraCode Nerd Font Mono") :size 20))

;; Simple global ligature setup - enable ALL ligatures everywhere
(after! ligature
  ;; Create one comprehensive ligature list with all symbols
  (let ((all-ligatures '("|||>" "<|||" "<==>" "<!--" "####" "~~>" "***" "||=" "||>"
                         ":::" "::=" "=:=" "===" "==>" "=!=" "=>>" "=<<" "=/=" "!=="
                         "!!." ">=>" ">>=" ">>>" ">>-" ">->" "->>" "-->" "---" "-<<"
                         "<~~" "<~>" "<*>" "<||" "<|>" "<$>" "<==" "<=>" "<=<" "<->"
                         "<--" "<-<" "<<=" "<<-" "<<<" "<+>" "</>" "###" "#_(" "..<"
                         "..." "+++" "/==" "///" "_|_" "www" "&&" "^=" "~~" "~@" "~="
                         "~>" "~-" "**" "*>" "*/" "||" "|}" "|]" "|=" "|>" "|-" "{|"
                         "[|" "]#" "::" ":=" ":>" ":<" "$>" "==" "=>" "!=" "!!" ">:"
                         ">=" ">>" ">-" "-~" "-|" "->" "--" "-<" "<~" "<*" "<|" "<:"
                         "<$" "<=" "<>" "<-" "<<" "<+" "</" "#{" "#[" "#:" "#=" "#!"
                         "##" "#(" "#?" "#_" "%%" ".=" ".-" ".." ".?" "+>" "++" "?:"
                         "?=" "?." "??" ";;" "/*" "/=" "/>" "//" "__" "~~" "(*" "*)"
                         "\\\\" "://"
                         ;; R-specific ligatures
                         "%>%" "%<%" "%$%" "%T>%" "%<>%" "%in%" "%nin%"
                         ;; Julia-specific ligatures
                         ".<" ".>" ".+" ".-" ".*" "./" ".^" ".%" ".<=" ".>=" ".==" ".!=")))

    ;; Set ligatures globally for ALL modes using 't
    (ligature-set-ligatures 't all-ligatures))

  ;; Enable global ligature mode
  (global-ligature-mode 1))

;; Prevent polymode from transferring problematic modes between buffers
;; This eliminates ligature loss and font-lock conflicts during mode switches
(after! polymode
  ;; Remove problematic modes from the list of modes that polymode manages
  (setq polymode-move-these-minor-modes-from-old-buffer
        (delq 'ligature-mode polymode-move-these-minor-modes-from-old-buffer))
  (setq polymode-move-these-minor-modes-from-base-buffer
        (delq 'ligature-mode polymode-move-these-minor-modes-from-base-buffer))

  ;; Also prevent font-lock conflicts - each mode should handle its own syntax highlighting
  (setq polymode-move-these-minor-modes-from-old-buffer
        (delq 'font-lock-mode polymode-move-these-minor-modes-from-old-buffer))
  (setq polymode-move-these-minor-modes-from-base-buffer
        (delq 'font-lock-mode polymode-move-these-minor-modes-from-base-buffer))

  ;; Ensure proper syntax highlighting refresh after polymode operations
  (add-hook 'polymode-init-inner-hook #'font-lock-ensure)
  (add-hook 'polymode-init-host-hook #'font-lock-ensure))

;; This determines the style of line numbers in effect. If set to `nil', line
;; numbers are disabled. For relative line numbers, set this to `relative'.
(setq display-line-numbers-type t)

;; Configure smartparens to highlight matching parentheses
(after! smartparens
  ;; Enable pair highlighting
  (setq sp-show-pair-from-inside t)  ; Highlight when cursor is inside
  (setq sp-show-pair-delay 0)        ; Show matches instantly

  ;; Make sure it's enabled globally
  (show-smartparens-global-mode 1))

;; Map macOS Command key for cut/copy/paste (macOS only)
(when (featurep :system 'macos)
  (map! "s-c" #'kill-ring-save     ;; ⌘C
        "s-x" #'kill-region        ;; ⌘X
        "s-v" #'yank))             ;; ⌘V

;; Auto-generate/update a Table of Contents inside Org buffers
(use-package! org-make-toc
  :hook (org-mode . org-make-toc-mode))

;; If you use `org' and don't want your org files in the default location below,
;; change `org-directory'. It must be set before org loads!
;; (setq org-directory "~/org/")
(setq org-directory "~/Dropbox/org/")

;; Explicitly set org-roam-directory to prevent initialization errors
(setq org-roam-directory (expand-file-name "roam/" org-directory))

;; General org-babel session management
(after! org
  ;; Keep sessions alive and don't kill them immediately
  (setq org-babel-session-async-timeout 60)
  
  ;; Better process management for org-babel sessions
  (setq org-babel-default-header-args
        '((:session . "none")
          (:results . "replace")
          (:exports . "code")
          (:cache . "no")
          (:noweb . "no")
          (:hlines . "no")
          (:tangle . "no")
          (:eval . "never-export")))
  
  ;; Don't kill sessions on errors
  (setq org-babel-error-buffer-name "*Org-Babel Error Output*")
  
  ;; Keep inferior processes alive
  (setq org-babel-persistent-session t)
  
  ;; Org refile targets configuration - dynamically find all .org files
  (setq org-refile-targets
        `(,@(mapcar (lambda (file) (list file :maxlevel 2))
                    (directory-files-recursively 
                     (expand-file-name "areas/" org-directory) "\\.org$"))
          ,@(mapcar (lambda (file) (list file :maxlevel 2))
                    (directory-files-recursively 
                     (expand-file-name "resources/" org-directory) "\\.org$"))
          ,@(mapcar (lambda (file) (list file :maxlevel 2))
                    (directory-files-recursively 
                     (expand-file-name "projects/" org-directory) "\\.org$"))
          (,(expand-file-name "inbox.org" org-directory) :maxlevel . 2)
          (nil :maxlevel . 9)))
  
  ;; Refile interface configuration
  (setq org-refile-use-outline-path 'file)     ; Show file name in path
  (setq org-outline-path-complete-in-steps nil) ; Single-step completion
  (setq org-refile-allow-creating-parent-nodes 'confirm) ; Create new headings
  
  ;; Custom agenda commands
  (setq org-agenda-custom-commands
        '(("d" "Daily Agenda"
           ((agenda "" ((org-agenda-span 'day)
                        (org-deadline-warning-days 7)))
            (tags-todo "+PRIORITY=\"A\""
                       ((org-agenda-overriding-header "High Priority Tasks")))))
          ("w" "This Week"
           ((agenda "" ((org-agenda-span 'week)
                        (org-agenda-start-on-weekday 1))) ; Start on Monday
            (tags-todo "+thisweek|+weekly"
                       ((org-agenda-overriding-header "Do This Week")))
            (tags-todo "DEADLINE>=\"<today>\"+DEADLINE<=\"<+1w>\""
                       ((org-agenda-overriding-header "Due This Week")))))
          ("m" "This Month"
           ((agenda "" ((org-agenda-span 'month)))
            (tags-todo "+thismonth|+monthly"
                       ((org-agenda-overriding-header "Do This Month")))
            (tags-todo "DEADLINE>=\"<today>\"+DEADLINE<=\"<+1m>\""
                       ((org-agenda-overriding-header "Due This Month")))))))
  
  ;; Configure deadline warning days for different time windows
  (setq org-deadline-warning-days 7)  ; Start warning 7 days before deadline
  
  ;; Custom faces for deadline warnings
  (setq org-agenda-deadline-faces
        '((1.0 . org-warning)              ; Due today or overdue
          (0.5 . org-upcoming-deadline)    ; Due within half the warning period
          (0.0 . org-upcoming-distant-deadline))) ; Due later
  
  ;; Ensure agenda starts on current day
  (setq org-agenda-start-day nil)  ; nil means today
  (setq org-agenda-start-on-weekday 1)  ; Start on Monday (1), set to nil to start on today
  (setq org-agenda-span 'day)  ; Default to day view
  
  ;; Set Monday as first day of the week (instead of Sunday)
  (setq calendar-week-start-day 1)  ; 0 = Sunday, 1 = Monday

  ;; Set org-agenda-files to automatically include all .org files in projects/ and areas/
  (setq org-agenda-files
        (append
         ;; Core files
         (mapcar (lambda (file)
                   (expand-file-name file org-directory))
                 '("inbox.org"
                   "reminders-beorg.org"
                   "beorg-customize-init.org"))
         ;; All .org files in specified directories
         (mapcan (lambda (dir)
                   (directory-files (expand-file-name dir org-directory) t "\\.org$"))
                 '("areas/" "projects/")))))

(after! org
  (setq org-capture-templates
        '(("p" "New Project" plain
           (file (lambda () (read-file-name "Project file: " 
                                           (expand-file-name "projects/" org-directory))))
           (file "templates/project-template.org")
           :unnarrowed t
           :kill-buffer t)
          ("m" "Meeting Notes" entry
           (file+headline "inbox.org" "Meetings")
           "* Meeting: %^{Meeting Title} :meeting:\n:PROPERTIES:\n:DATE: %U\n:ATTENDEES: %^{Attendees}\n:END:\n\n** Agenda\n%^{Agenda items}\n\n** Discussion Points\n- %?\n\n** Action Items\n- [ ] \n\n** Follow-up\n- \n"
           :prepend t)
          ("d" "Daily Review" entry
           (file+olp+datetree "journal/2025.org")
           "* Daily Review\n** Morning Planning\n*** Today's Priority\n1. %?\n2. \n3. \n\n*** Energy Level\n[1-10]: \n\n** Work Log\n*** Accomplished\n- \n\n*** In Progress\n- \n\n*** Blocked/Deferred\n- \n\n** Evening Review\n*** What went well?\n- \n\n*** What could be improved?\n- \n\n*** Tomorrow's Top 3\n1. \n2. \n3. \n\n** Gratitude\n- \n\n** Health & Habits\n- [ ] Exercise\n- [ ] Meditation\n- [ ] Reading\n- [ ] Water intake\n- [ ] Sleep quality (last night): /10\n"
           :tree-type week)
          ("t" "Quick Task" entry
           (file+headline "inbox.org" "Tasks")
           "* TODO %?\nSCHEDULED: %t\n"
           :prepend t)
          ("n" "Quick Note" entry
           (file+headline "inbox.org" "Notes")
           "* %? :note:\n%U\n"
           :prepend t))))

(defun my/archive-all-done-items ()
  "Archive all DONE items in all agenda files."
  (interactive)
  (org-map-entries 'org-archive-subtree "/DONE" 'agenda))

;; Add keybinding for the archive function
(map! :leader
      (:prefix ("o" . "open")
       :desc "Archive all DONE items" "A" #'my/archive-all-done-items))

;; Portable R executable
(defvar +r-executable (or (executable-find "R") "/usr/local/bin/R")
  "Path to the R executable used by ESS and Org Babel.")

(after! org
  ;; Set R command for org-babel
  (setq org-babel-R-command (format "%s --slave --no-save" +r-executable))

  ;; Don't ask for confirmation when executing R code blocks
  (setq org-confirm-babel-evaluate nil)

  ;; Default header arguments for R blocks
  (setq org-babel-default-header-args:R
        '((:results . "output")
          (:session . "*R*")
          (:eval . "never-export"))))

;; Portable Python executable
(defvar python-executable (or (executable-find "python3") "python3")
  "Path to the Python executable used by Org Babel.")

;; Set up Python support for org-mode
;; Since we have (org +python) in init.el, Doom should handle ob-python loading
(after! org
  ;; Set the Python command for org-babel
  (setq org-babel-python-command python-executable)
  
  ;; Set default header arguments for Python
  (setq org-babel-default-header-args:python
        '((:results . "output")
          (:session . "*Python*"))))

;; Portable Julia executable
(defvar julia-executable (or (executable-find "julia") "julia")
  "Path to the Julia executable used by Org Babel.")

;; Set up Julia support for org-mode
(after! org
  (require 'ob-julia nil t)
  
  ;; Add Julia to org-babel languages
  (add-to-list 'org-babel-load-languages '(julia . t))
  (org-babel-do-load-languages 'org-babel-load-languages org-babel-load-languages)
  
  ;; Set the Julia command for org-babel with interactive flags
  (setq org-babel-julia-command (concat julia-executable " --interactive"))
  
  ;; Julia session management
  (setq org-babel-julia-startup-with-prompt t)
  
  ;; Set default header arguments for Julia
  (setq org-babel-default-header-args:julia
        '((:results . "output")
          (:session . "*Julia*")
          (:exports . "both")
          (:eval . "never-export"))))

;; macOS-specific app integration
(when (featurep :system 'macos)
  ;; Add message: link type for macOS Messages.app
  ;; This allows links like [[message:ABC123]] to open in Messages
  (require 'org)
  (org-add-link-type "message"
   (lambda (id)
    (shell-command
     (concat "open message:" id))))

  ;; Enable org-mac-link for macOS app integration
  ;; This package is included with Doom Emacs in the (org +mac) module
  (use-package! org-mac-link
    :after org
    :config
    ;; Load the package first
    (require 'org-mac-link)

    ;; Keybindings using Doom's map! macro
    ;; Local leader bindings (SPC m prefix in normal mode)
    (map! :map org-mode-map
          :localleader
          "g l" #'org-mac-link-get-link  ; Grab link from last active app
          "g g" #'org-mac-grab-link)      ; Interactive menu to choose app

    ;; Alternative C-c prefix bindings for insert mode or non-evil users
    (map! :map org-mode-map
          "C-c l l" #'org-mac-link-get-link  ; Grab link from last active app
          "C-c l g" #'org-mac-grab-link)))   ; Interactive menu to choose app

;; Note: The grabbed links will be formatted as org links automatically:
;; - Mail: [[message://message-id][Subject of Email]]
;; - Safari: [[https://example.com][Page Title]]
;; - Finder: [[file:/path/to/file.txt][file.txt]]

;; Disable the "Really exit Emacs?" confirmation
(setq confirm-kill-emacs nil)

;; Enable auto-save for all buffers
(setq auto-save-default t)

;; Auto-save every 300 characters typed
(setq auto-save-interval 300)

;; Auto-save after 30 seconds of idle time
(setq auto-save-timeout 30)

;; Function to save without prompting
(defun save-some-buffers-without-asking ()
  "Save all file-visiting buffers without asking."
  (save-some-buffers t))

;; Save buffers when Emacs loses focus (when you switch to another app)
(add-hook 'focus-out-hook 'save-some-buffers-without-asking)

;; Auto-save after idle time using a timer
(run-with-idle-timer 30 t (lambda () (save-some-buffers-without-asking)))

(after! ess
  ;; Core ESS settings following 2024-2025 best practices
  (setq inferior-R-program-name +r-executable
        ;; Working directory: Use lambda function that returns current file's directory
        ess-startup-directory-function (lambda () default-directory)
        ;; Don't prompt for directory
        ess-ask-for-ess-directory nil
        ;; Style and behavior - Use RStudio style for better indentation
        ess-style 'RStudio
        ess-eval-visibly-p 'nowait
        ess-nuke-trailing-whitespace-p t))

;; Claude Code - Stay in your buffer while working with Claude
(use-package! claude-code
  :config
  ;; Optional: Set custom Claude Code CLI path if needed
  ;; (setq claude-code-executable "claude-code")

  ;; Terminal backend (choose one: 'eat or 'vterm)
  (setq claude-code-terminal 'eat)

  ;; Enable desktop notifications
  (setq claude-code-use-notifications t)

  ;; Set the prefix key for Claude commands
  (setq claude-code-prefix-key "C-c c")

  ;; Set the default model (optional)
  ;; (setq claude-code-model "claude-3.5-sonnet")

  ;; Enable read-only mode for better text selection
  (setq claude-code-read-only-mode t)

  ;; Bind the transient menu
  :bind ("C-c c m" . claude-code))

;; Display Claude buffer in vertical split on the right
(after! claude-code
  ;; Override the display function to show Claude on the right side
  (defun my/claude-code-display-right (buffer)
    "Display BUFFER in a window on the right side."
    (display-buffer buffer '((display-buffer-in-side-window)
                             (side . right)
                             (window-width . 0.5))))

  (setq claude-code-display-window-fn #'my/claude-code-display-right))

;; Monet - IDE integration for Claude Code
(use-package! monet
  :config
  ;; Enable Monet mode globally
  (monet-mode 1)
  
  ;; Configure diff handling
  (setq monet-diff-tool 'monet-ediff-tool)  ; Use ediff for interactive diffs
  
  ;; Set custom keybindings for Monet
  (setq monet-prefix-key "C-c m")
  
  ;; Optional: Configure logging
  ;; (setq monet-log-level 'debug)
  
  ;; For external terminal integration (like Ghostty):
  ;; 1. Start Monet server: C-c m s (or SPC k S)
  ;; 2. Note the port number shown
  ;; 3. In Ghostty, run:
  ;;    ENABLE_IDE_INTEGRATION=t CLAUDE_CODE_SSE_PORT=<port> claude
  )

;; Add Doom-style leader key shortcuts for Claude (moved to unified AI menu below)

;; Vertico configuration
(after! vertico
  ;; Show more candidates
  (setq vertico-count 20)
  
  ;; Grow and shrink the Vertico minibuffer
  (setq vertico-resize t)
  
  ;; Enable cycling for `vertico-next' and `vertico-previous'
  (setq vertico-cycle t)
  
  ;; Improve directory navigation
  (define-key vertico-map (kbd "RET") #'vertico-directory-enter)
  (define-key vertico-map (kbd "DEL") #'vertico-directory-delete-char)
  (define-key vertico-map (kbd "M-DEL") #'vertico-directory-delete-word))

;; Persist history over Emacs restarts with savehist
(use-package! savehist
  :init
  (savehist-mode))

;; Orderless completion style (already loaded by Doom with corfu +orderless)
(after! orderless
  ;; Configure orderless matching styles
  (setq orderless-matching-styles '(orderless-regexp
                                    orderless-initialism
                                    orderless-prefixes
                                    orderless-flex)))

;; Marginalia - annotations in the minibuffer (already included with Doom)
(after! marginalia
  ;; Show absolute dates in file listings
  (setq marginalia-max-relative-age 0)
  ;; Align annotations to the right
  (setq marginalia-align 'right))

;; Corfu keybindings for Evil mode compatibility
(after! corfu
  ;; Make sure Corfu navigation works in Evil insert mode
  (define-key corfu-map (kbd "C-n") #'corfu-next)
  (define-key corfu-map (kbd "C-p") #'corfu-previous)
  (define-key corfu-map (kbd "C-j") #'corfu-next)
  (define-key corfu-map (kbd "C-k") #'corfu-previous)
  (define-key corfu-map (kbd "TAB") #'corfu-complete)
  (define-key corfu-map (kbd "RET") #'corfu-insert)
  (define-key corfu-map (kbd "C-g") #'corfu-quit)
  
  ;; Optional: Add scrolling for documentation
  (define-key corfu-map (kbd "M-d") #'corfu-info-documentation)
  (define-key corfu-map (kbd "M-l") #'corfu-info-location))

;; Command palette keybindings for easier command discovery
(map! :leader
      :desc "M-x with history" "?" #'execute-extended-command
      :desc "Search commands" "s c" #'helpful-command)

;; Which-key configuration
(after! which-key
  ;; Show which-key popup faster
  (setq which-key-idle-delay 0.5)  ; Default is 1.0
  
  ;; Allow longer descriptions
  (setq which-key-max-description-length 40)
  
  ;; Show which-key at bottom with max 4 lines
  (setq which-key-popup-type 'side-window
        which-key-side-window-location 'bottom
        which-key-side-window-max-height 0.25)
  
  ;; Sort alphabetically within each prefix
  (setq which-key-sort-order 'which-key-key-order-alpha)
  
  ;; Add custom prefixes for better descriptions
  (which-key-add-key-based-replacements
    "SPC p" "projectile"
    "SPC g" "git"
    "SPC f" "file"
    "SPC b" "buffer"
    "SPC w" "window"
    "SPC t" "toggle"
    "SPC o" "open"
    "SPC s" "search"
    "SPC c" "code"
    "SPC n" "notes"
    "SPC i" "insert"))

;; Projectile configuration
(after! projectile
  ;; Set project search paths
  (setq projectile-project-search-path '("~/Projects/" "~/Code/" "~/.config/"))

  ;; Ignore certain directories globally
  (add-to-list 'projectile-globally-ignored-directories "node_modules")
  (add-to-list 'projectile-globally-ignored-directories ".venv")
  (add-to-list 'projectile-globally-ignored-directories "__pycache__")

  ;; Enable caching for better performance
  (setq projectile-enable-caching t)

  ;; Sort files by recently opened
  (setq projectile-sort-order 'recently-active)

  ;; Add org-directory as a known project
  (projectile-add-known-project org-directory)

  ;; Recognize directories with .projectile files as projects
  (add-to-list 'projectile-project-root-files ".projectile")

  ;; Fix keybinding issues by completely disabling projectile's direct keybindings
  ;; Doom handles projectile keybindings through its leader key system
  (setq projectile-keymap-prefix nil)

  ;; Clear the entire projectile keymap to prevent conflicts
  (setq projectile-mode-map (make-sparse-keymap))

  ;; Additional fix: disable projectile's command map entirely
  (setq projectile-command-map (make-sparse-keymap))

  ;; Prevent projectile from trying to bind any keys
  (advice-add 'projectile-mode :around
              (lambda (orig-fn &rest args)
                "Disable projectile keybindings."
                (let ((projectile-keymap-prefix nil))
                  (apply orig-fn args)))))

;; Key bindings (Doom already sets up SPC p prefix)
;; Most useful commands:
;; SPC p p   - Switch to project
;; SPC p f   - Find file in project
;; SPC p r   - Recent project files
;; SPC p g   - Grep in project
;; SPC p c   - Compile project
;; SPC p t   - Test project

;; Workspace configuration
(after! +workspaces
  ;; Don't auto-create/switch workspaces when switching projects
  ;; This keeps you in the current workspace when you use SPC p p to switch to another project
  ;; If you want a fresh workspace for a project, create it manually with SPC TAB n
  (setq +workspaces-on-switch-project-behavior nil))

;; Configure indent-bars
(use-package! indent-bars
  :hook ((prog-mode . indent-bars-mode)
         (yaml-mode . indent-bars-mode))
  :config
  (setq indent-bars-treesit-support t
        indent-bars-no-descend-string t
        indent-bars-treesit-ignore-blank-lines-types '("module")
        indent-bars-treesit-wrap '((python argument_list parameters ; for python
                                           list list_comprehension
                                           dictionary dictionary_comprehension
                                           parenthesized_expression subscript))
        indent-bars-pattern "."
        indent-bars-width-frac 0.1
        indent-bars-pad-frac 0.1
        indent-bars-zigzag nil
        indent-bars-color-by-depth nil
        indent-bars-highlight-current-depth nil
        indent-bars-display-on-blank-lines nil))

;; Configure diff-hl to handle non-Git files gracefully
(after! diff-hl
  ;; Disable diff-hl for files outside Git repositories
  (setq diff-hl-disable-on-remote t)
  
  ;; Add advice to handle errors gracefully
  (defadvice! my/diff-hl-handle-errors (orig-fn &rest args)
    "Suppress diff-hl errors for files not in Git repositories."
    :around #'diff-hl-changes
    (condition-case nil
        (apply orig-fn args)
      (error nil)))
  
  ;; Only enable diff-hl in buffers that are actually in Git repositories
  (defun my/diff-hl-mode-on-maybe ()
    "Enable diff-hl-mode only if the current file is in a Git repository."
    (when (and buffer-file-name
               (vc-backend buffer-file-name))
      (diff-hl-mode 1)))
  
  ;; Replace the global mode hook
  (remove-hook 'find-file-hook #'diff-hl-mode-on)
  (add-hook 'find-file-hook #'my/diff-hl-mode-on-maybe))

;; Configure vterm to use fish shell
(after! vterm
  ;; Detect fish shell location based on OS
  (setq vterm-shell
        (cond
         ;; macOS with Homebrew (Apple Silicon)
         ((and (featurep :system 'macos)
               (file-exists-p "/opt/homebrew/bin/fish"))
          "/opt/homebrew/bin/fish")
         ;; macOS with Homebrew (Intel)
         ((and (featurep :system 'macos)
               (file-exists-p "/usr/local/bin/fish"))
          "/usr/local/bin/fish")
         ;; Linux - use system fish or fallback to bash
         ((executable-find "fish")
          (executable-find "fish"))
         ;; Fallback to system default shell
         (t (getenv "SHELL"))))

  ;; Fish-compatible prompt regex (works for bash/zsh too)
  (setq vterm-shell-prompt-regexp "^[^#$%>\n]*[#$%>] *")

  ;; Ensure vterm uses login shell
  (setq vterm-kill-buffer-on-exit t)

  ;; Optional: Set buffer name format
  (setq vterm-buffer-name-string "vterm %s"))

;; OpenCode - AI-powered coding assistant
(use-package! opencode
  :after gptel
  :config
  ;; Use the full OpenCode setup (registers tools and agents with gptel)
  (opencode-setup)
  ;; Set coding tools as enabled
  (setq opencode-enabled-tools 'coding)
  (setq opencode-default-preset 'opencode-coding))
  
;; Define the quick gptel function first
(defun my/gptel-quick ()
  "Start gptel without prompting for buffer name."
  (interactive)
  (require 'gptel)
  (let ((buffer (get-buffer-create "*OpenCode*")))
    (with-current-buffer buffer
      (unless (eq major-mode 'org-mode)
        (org-mode))
      (gptel-mode 1))
    (pop-to-buffer buffer)))

;; Load environment variables from .env file (not in version control)
(defun load-env-file (file)
  "Load environment variables from FILE."
  (when (file-exists-p file)
    (with-temp-buffer
      (insert-file-contents file)
      (goto-char (point-min))
      (while (not (eobp))
        (when (looking-at "^\\([^#\n][^=\n]*\\)=\\(.*\\)$")
          (let ((key (match-string 1))
                (value (match-string 2)))
            (setenv key value)))
        (forward-line 1)))))

(load-env-file (expand-file-name ".env" doom-user-dir))

;; Configure gptel to use OpenAI GPT-4o
(after! gptel
  ;; Set default buffer name
  (setq gptel-default-mode 'org-mode)

  ;; Configure OpenAI backend (default, but explicit for clarity)
  (setq gptel-backend (gptel-make-openai "OpenAI"
                                         :host "api.openai.com"
                                         :endpoint "/v1/chat/completions"
                                         :stream t
                                         :key (getenv "OPENAI_API_KEY")
                                         :models '(gpt-5 gpt-5-mini)))

  ;; Set GPT-5 as default model (latest and most capable)
  (setq gptel-model "gpt-5"))

;; Add gptel-magit integration
(use-package! gptel-magit
  :after (gptel magit)
  :hook (magit-mode . gptel-magit-install))

;; Unified AI assistant keybindings
(map! :leader
      (:prefix ("k" . "AI")
       ;; Direct Claude commands at top level
       :desc "Claude menu" "c" #'claude-code
       :desc "Send region/buffer" "r" #'claude-code-send-region
       :desc "Fix error" "e" #'claude-code-fix-error-at-point
       :desc "Toggle Claude window" "t" #'claude-code-toggle
       :desc "Send file" "o" #'claude-code-send-file
       :desc "Kill Claude session" "k" #'claude-code-kill
       :desc "Start Claude" "C" #'claude-code-start-in-directory
       :desc "Switch buffer" "b" #'claude-code-switch-to-buffer
       :desc "Continue conversation" "x" #'claude-code-continue
       :desc "Cycle mode" "M" #'claude-code-cycle-mode
       :desc "Kill all sessions" "K" #'claude-code-kill-all
       :desc "Send command" "/" #'claude-code-send-command
       
       ;; GPTel/OpenCode commands
       :desc "GPTel chat" "g" #'my/gptel-quick
       :desc "GPTel menu" "G" #'gptel-menu
       :desc "GPTel send" "s" #'gptel-send
       
       ;; Monet commands (directly at top level to avoid conflicts)
       :desc "Monet server" "S" #'monet-start-server
       :desc "Monet list" "l" #'monet-list-sessions
       :desc "Monet diff" "d" #'monet-show-diff))

;; Also set up the global Claude prefix key binding
(map! :n "C-c c m" #'claude-code
      :i "C-c c m" #'claude-code
      :v "C-c c m" #'claude-code)

;; Set terminal before eee loads - detect available terminal
(setq ee-terminal-command
      (cond
       ((executable-find "ghostty") "ghostty")
       ((executable-find "kitty") "kitty")
       ((executable-find "alacritty") "alacritty")
       ((and (featurep :system 'macos) (executable-find "iterm")) "iterm")
       (t "xterm")))  ; fallback

;; Autoload eee commands (Emacs will load eee when first invoked)
(autoload 'ee-yazi "eee" nil t)
(autoload 'ee-yazi-project "eee" nil t)

(map! :leader
      (:prefix ("o" . "open")
       :desc "Open Yazi" "y" #'ee-yazi
       :desc "Open Yazi (project)" "Y" #'ee-yazi-project))

;; GitHub Copilot configuration
(use-package! copilot
  :hook ((prog-mode . copilot-mode)
         (org-mode . copilot-mode))  ;; Enable copilot in org-mode too
  :bind (:map copilot-completion-map
              ("<tab>" . 'copilot-accept-completion)
              ("TAB" . 'copilot-accept-completion)
              ("C-TAB" . 'copilot-accept-completion-by-word)
              ("C-<tab>" . 'copilot-accept-completion-by-word))
  :config
  ;; Disable copilot in specific modes if needed
  (add-to-list 'copilot-disable-predicates #'company--active-p)

  ;; Set copilot to use Node.js from PATH
  (setq copilot-node-executable (executable-find "node"))

  ;; Optional: reduce copilot idle delay for faster suggestions
  (setq copilot-idle-delay 0.5)

  ;; Option 1: Disable the warning entirely (simplest solution)
  (setq copilot-indent-offset-warning-disable t)

  ;; Option 2: Add indentation settings properly
  ;; The copilot-indentation-alist should map modes to either:
  ;; - A direct number
  ;; - A variable name that contains the indentation value
  ;; - A list of variable names to check

  ;; Ensure the variable exists first
  (unless (boundp 'copilot-indentation-alist)
    (setq copilot-indentation-alist '()))

  ;; For org-mode, use the actual indentation variable
  (add-to-list 'copilot-indentation-alist '(org-mode org-indent-indentation-per-level))
  (add-to-list 'copilot-indentation-alist '(org-agenda-mode . 2))
  (add-to-list 'copilot-indentation-alist '(text-mode tab-width))
  (add-to-list 'copilot-indentation-alist '(fundamental-mode tab-width))
  (add-to-list 'copilot-indentation-alist '(special-mode tab-width))
  (add-to-list 'copilot-indentation-alist '(dired-mode . 2))
  (add-to-list 'copilot-indentation-alist '(magit-mode . 2))
  (add-to-list 'copilot-indentation-alist '(magit-status-mode . 2))
  (add-to-list 'copilot-indentation-alist '(magit-diff-mode . 2))
  (add-to-list 'copilot-indentation-alist '(magit-log-mode . 2))
  (add-to-list 'copilot-indentation-alist '(magit-revision-mode . 2))
  (add-to-list 'copilot-indentation-alist '(git-commit-mode . 2))
  (add-to-list 'copilot-indentation-alist '(help-mode . 2))
  (add-to-list 'copilot-indentation-alist '(Info-mode . 2))
  (add-to-list 'copilot-indentation-alist '(compilation-mode . 2))
  (add-to-list 'copilot-indentation-alist '(messages-buffer-mode . 2))
  (add-to-list 'copilot-indentation-alist '(inferior-emacs-lisp-mode . 2))
  (add-to-list 'copilot-indentation-alist '(lisp-interaction-mode . 2))
  (add-to-list 'copilot-indentation-alist '(eshell-mode . 2))
  (add-to-list 'copilot-indentation-alist '(shell-mode . 2))
  (add-to-list 'copilot-indentation-alist '(term-mode . 2))
  (add-to-list 'copilot-indentation-alist '(vterm-mode . 2))
  (add-to-list 'copilot-indentation-alist '(comint-mode . 2))
  (add-to-list 'copilot-indentation-alist '(diff-mode . 2))
  (add-to-list 'copilot-indentation-alist '(ediff-mode . 2))
  (add-to-list 'copilot-indentation-alist '(occur-mode . 2))
  (add-to-list 'copilot-indentation-alist '(grep-mode . 2))
  (add-to-list 'copilot-indentation-alist '(Custom-mode . 2))
  (add-to-list 'copilot-indentation-alist '(conf-unix-mode . 2))
  (add-to-list 'copilot-indentation-alist '(conf-space-mode . 2))

  ;; Add other modes as needed
  (dolist (mode-indent '((prog-mode . 2)
                         (emacs-lisp-mode . 2)
                         (lisp-mode . 2)
                         (scheme-mode . 2)
                         (clojure-mode . 2)
                         (python-mode . 4)
                         (python-ts-mode . 4)
                         (yaml-mode . 2)
                         (yaml-ts-mode . 2)
                         (js-mode . 2)
                         (js-ts-mode . 2)
                         (js2-mode . 2)
                         (typescript-mode . 2)
                         (typescript-ts-mode . 2)
                         (tsx-ts-mode . 2)
                         (json-mode . 2)
                         (json-ts-mode . 2)
                         (web-mode . 2)
                         (html-mode . 2)
                         (css-mode . 2)
                         (scss-mode . 2)
                         (rust-mode . 4)
                         (rustic-mode . 4)
                         (rust-ts-mode . 4)
                         (go-mode . 8)
                         (go-ts-mode . 8)
                         (c-mode . 4)
                         (c-ts-mode . 4)
                         (c++-mode . 4)
                         (c++-ts-mode . 4)
                         (objc-mode . 4)
                         (java-mode . 4)
                         (java-ts-mode . 4)
                         (julia-mode . 4)
                         (julia-ts-mode . 4)
                         (ess-r-mode . 2)
                         (R-mode . 2)
                         (ruby-mode . 2)
                         (ruby-ts-mode . 2)
                         (lua-mode . 2)
                         (lua-ts-mode . 2)
                         (sh-mode . 2)
                         (bash-ts-mode . 2)
                         (fish-mode . 2)
                         (markdown-mode . 2)
                         (latex-mode . 2)
                         (LaTeX-mode . 2)))
    (add-to-list 'copilot-indentation-alist mode-indent))

  ;; Ensure org-mode has proper indentation variables set
  ;; Note: Don't set tab-width in org-mode as it must be 8 per Org specification
  (add-hook 'org-mode-hook
            (lambda ()
              (setq-local indent-tabs-mode nil)
              (setq-local org-indent-indentation-per-level 2)))

  ;; Better approach: Set default indentation for modes that don't have it
  (defun my-copilot-tab-fallback ()
    "Return a fallback tab width for copilot."
    (or (and (boundp 'tab-width) tab-width) 2))

  ;; Add fallback entries for common modes that might not have indentation set
  (dolist (mode '(org-mode text-mode fundamental-mode special-mode))
    (unless (assq mode copilot-indentation-alist)
      (add-to-list 'copilot-indentation-alist
                   (cons mode 'my-copilot-tab-fallback)))))

;; Add keybindings for copilot
(map! :leader
      (:prefix ("k" . "AI")
       :desc "Toggle Copilot" "p" #'copilot-mode
       :desc "Copilot diagnose" "P" #'copilot-diagnose
       :desc "Copilot login" "L" #'copilot-login))

;; Citar - Citation management
(after! citar
  ;; Set bibliography files
  (setq citar-bibliography '("~/Dropbox/org/bibliography.bib"))

  ;; Set default cite format
  (setq org-cite-global-bibliography citar-bibliography)

  ;; Enable citar-embark integration
  (when (featurep 'citar-embark)
    (citar-embark-mode 1)))

;; Configure org-cite
(after! oc
  (require 'oc-csl)  ; citation style language support
  (require 'oc-biblatex))  ; biblatex support

;; Auto-revert buffers when files change on disk
(global-auto-revert-mode 1)

;; Also auto-revert dired buffers
(setq global-auto-revert-non-file-buffers t)

;; Disable file notifications to avoid errors - use polling instead
(setq auto-revert-use-notify nil)

;; Set polling interval (in seconds)
(setq auto-revert-interval 2)

;; Suppress auto-revert messages
(setq auto-revert-verbose nil)

;; Fix file-notify errors by ensuring proper handlers
(setq file-notify-debug nil)

;; Fix frameset window management issues
(setq frameset-filter-alist
      (append '((window-atom . :never)
                (window-side . :never)
                (window-parameters . :never))
              frameset-filter-alist))

;; Suppress frameset warnings
(setq warning-suppress-types '((frameset)))

;; Better window management for side windows
(setq window-sides-slots '(nil nil nil 1))

;; Disable desktop restoration of window configurations
;; This prevents frameset errors on startup
(setq desktop-restore-frames nil)
(setq desktop-restore-in-current-display t)
(setq desktop-restore-forces-onscreen nil)

;; Additional frameset safety
(advice-add 'frameset-restore :around
            (lambda (orig-fun &rest args)
              (condition-case err
                  (apply orig-fun args)
                (error (message "Frameset restore error: %s" err)
                       nil))))

;; Configure spell checking
(setq ispell-program-name "hunspell")
(setq ispell-local-dictionary "en_US")
(setq ispell-local-dictionary-alist
      '(("en_US" "[[:alpha:]]" "[^[:alpha:]]" "[']" nil ("-d" "en_US") nil utf-8)))

;; Set default dictionary
(setq ispell-dictionary "en_US")

;; Hunspell setup
(when (executable-find "hunspell")
  (setq ispell-program-name "hunspell")
  (setq ispell-dictionary "en_US")
  (setq ispell-personal-dictionary "~/.hunspell_personal"))

;;
;;; RMarkdown Support (poly-R)

(use-package! poly-R
  :after polymode
  :config
  ;; Associate .Rmd files with poly-markdown+r-mode
  (add-to-list 'auto-mode-alist '("\\.[rR]md\\'" . poly-markdown+r-mode)))

;;
;;; Quarto Support (quarto-mode)

(use-package! quarto-mode
  :after polymode
  :config
  (add-to-list 'auto-mode-alist '("\\.qmd\\'" . poly-quarto-mode)))

;;
;;; Popup rules for R/Help buffers
(with-eval-after-load 'ess
  (set-popup-rule! "^\\*R.*\\*$" :side 'bottom :height 0.3 :select nil :ttl nil :quit nil)
  (set-popup-rule! "^\\*help\\*$" :side 'right :width 0.33 :select t :ttl nil :quit t))

;;; --- Polymode Rmd "reverse typing" hardening ------------------------------

;; Predicate: are we in an *indirect* R code chunk buffer (not the host .Rmd)?
(defun +rmd/inner-r-chunk-p ()
  (and (buffer-base-buffer)
       (derived-mode-p 'ess-r-mode)))

;; Minor mode to mark buffers we've sanitized (gives a modeline cue, too)
(define-minor-mode +rmd-sanitized-mode
  "Minor mode indicating this buffer has been sanitized for Rmd chunk quirks."
  :init-value nil
  :lighter " ⟲Rmd"
  :keymap nil)

(defun +rmd/echo-debug-state ()
  "Quick debug: show bidi/input-method/indent/composition state."
  (interactive)
  (message "im:%s bidi-dir:%s bidi-reorder:%s vis-cursor:%s comp:%s elect-indent:%s trunc:%s"
           current-input-method
           bidi-paragraph-direction
           bidi-display-reordering
           visual-order-cursor-movement
           (if (boundp 'auto-composition-mode) auto-composition-mode 'n/a)
           (if (local-variable-p 'electric-indent-inhibit) electric-indent-inhibit 'n/a)
           truncate-lines))

;; 1) Reworked sanitizer (idempotent, more thorough, with redisplay)
(defun +rmd/sanitize-buffer (&rest _)
  "Enforce LTR, tame indentation/composition/input methods in Rmd chunk buffers."
  (when (+rmd/inner-r-chunk-p)
    ;; Don't re-apply every switch
    (unless +rmd-sanitized-mode
      ;; Input methods
      (when current-input-method (deactivate-input-method))
      (setq-local input-method-function nil)
      (setq-local default-input-method nil)

      ;; BiDi (strict LTR)
      (setq-local bidi-paragraph-direction 'left-to-right)
      (setq-local bidi-display-reordering nil)
      (setq-local bidi-inhibit-bpa t)
      (setq-local right-to-left-display nil)
      (setq-local visual-order-cursor-movement nil)

      ;; Composition / ligatures
      (when (fboundp 'auto-composition-mode) (auto-composition-mode -1))
      (setq-local composition-function-table nil)
      (when (boundp 'ligature-mode) (ignore-errors (ligature-mode -1)))

      ;; Electric indent (prevents odd newline/backtick behavior)
      (setq-local electric-indent-inhibit t)
      (when (fboundp 'electric-indent-local-mode)
        (ignore-errors (electric-indent-local-mode -1)))

      ;; Keep layout predictable
      (setq-local truncate-lines t)

      ;; Make backtick purely punctuation in code chunks (optional but helps)
      ;; (You can comment this out if you prefer ESS's native backtick semantics.)
      (let ((st (syntax-table)))
        (when (syntax-table-p st)
          (modify-syntax-entry ?` "." st))) ; "." = punctuation

      ;; Mark and refresh
      (+rmd-sanitized-mode 1)
      (force-mode-line-update)
      (redisplay))))

;; 2) ESS syntax-table workaround (optional but recommended)
;; Some setups treat backticks in ways that interact with Markdown chunk fences.
;; This ensures backticks don't start strings or quoting in inner R chunk buffers.
(defun +rmd/ess-syntax-workaround (&rest _)
  (when (+rmd/inner-r-chunk-p)
    (let ((st (syntax-table)))
      (when (syntax-table-p st)
        ;; Treat backtick as punctuation here; ESS still handles evaluation fine
        (modify-syntax-entry ?` "." st)))))

;; 3) Multi-hook strategy (init, switch, and on-mode)
(after! polymode
  ;; When the inner buffer initializes
  (add-hook 'polymode-init-inner-hook #'+rmd/sanitize-buffer)
  (add-hook 'polymode-init-inner-hook #'+rmd/ess-syntax-workaround)
  ;; Whenever polymode switches host<->chunk
  (add-hook 'polymode-after-switch-buffer-hook #'+rmd/sanitize-buffer))

;; Keep Evil sane on switches (ignore hook args)
(defun +pm/evil-normalize (&rest _)
  (when (bound-and-true-p evil-local-mode)
    (evil-normal-state)))
(after! polymode
  (add-hook 'polymode-after-switch-buffer-hook #'+pm/evil-normalize))

;; Also catch when the chunk's major mode turns on (extra safety net)
(add-hook 'ess-r-mode-hook
          (defun +rmd/sanitize-on-ess-enter ()
            (when (+rmd/inner-r-chunk-p)
              (+rmd/sanitize-buffer)
              (+rmd/ess-syntax-workaround))))

;; 4) User controls: manual fix & quick debug
(map! :map poly-markdown+r-mode-map
      :localleader
      (:prefix ("f" . "fix")
       :desc "Rmd fix: sanitize now" "r" #'+rmd/sanitize-buffer
       :desc "Rmd fix: echo debug state" "d" #'+rmd/echo-debug-state))

;; Only disable single-backtick pairing in R code (leave Markdown backticks alone)
(with-eval-after-load 'ess-r-mode
  (when (bound-and-true-p smartparens-mode)
    (sp-local-pair 'ess-r-mode "`" "`" :actions nil)))

(defun my/insert-r-assignment (&optional n)
  "Insert the R assignment operator '<-'. With prefix N, insert N copies.
Spaces are added around the operator when appropriate."
  (interactive "p")
  (let ((count (max 1 (or n 1))))
    (dotimes (_ count)
      (let* ((space-before (if (or (bolp)
                                   (looking-back "[ \t\n<]" 1))
                               "" " "))
             (space-after  (if (looking-at "[ \t\n]")
                               "" " ")))
        (insert (concat space-before "<-" space-after))))))

(defun my/org-in-r-src-block-p ()
  "Return non-nil if point is inside an Org src block of language R."
  (when (and (derived-mode-p 'org-mode)
             (org-in-src-block-p t))
    (let* ((info (org-babel-get-src-block-info 'light))
           (lang (downcase (car info))))
      (member lang '("r" "rscript")))))

(defun my/org-r-assignment-dwim ()
  "If in an Org R src block, insert '<-'; otherwise, fall back to `negative-argument'."
  (interactive)
  (if (my/org-in-r-src-block-p)
      (call-interactively #'my/insert-r-assignment)
    (call-interactively #'negative-argument)))

;; Keybindings
(after! ess-r-mode
  (map! :map ess-r-mode-map
        :i "M--" #'my/insert-r-assignment))

(after! org
  (map! :map org-mode-map
        :i "M--" #'my/org-r-assignment-dwim))

;; Preferred: Eglot (simple & stable with polymode)
(when (featurep 'eglot)
  (after! eglot
    (add-to-list 'eglot-server-programs
                 '(ess-r-mode . ("R" "--slave" "-e" "languageserver::run()")))
    (add-hook 'ess-r-mode-hook #'eglot-ensure)))

;; If you use lsp-mode instead: harden it in indirect buffers
(defun +rmd/disable-lsp-in-indirect-buffers-h ()
  (when (buffer-base-buffer) (lsp-managed-mode -1)))

(when (featurep 'lsp-mode)
  (after! lsp-mode
    (add-hook 'lsp-mode-hook #'+rmd/disable-lsp-in-indirect-buffers-h)
    (with-eval-after-load 'lsp-ui
      (setq lsp-ui-doc-enable nil
            lsp-ui-sideline-enable nil))))

(after! polymode
  ;; Rmd (poly-markdown+r)
  (map! :map poly-markdown+r-mode-map
        :n "]r" #'polymode-next-chunk
        :n "[r" #'polymode-previous-chunk
        :n "M-n" #'polymode-next-chunk
        :n "M-p" #'polymode-previous-chunk
        :i "M-n" #'polymode-next-chunk
        :i "M-p" #'polymode-previous-chunk)
  ;; Qmd (poly-quarto)
  (after! quarto-mode
    (when (boundp 'poly-quarto-mode-map)
      (map! :map poly-quarto-mode-map
            :n "]r" #'polymode-next-chunk
            :n "[r" #'polymode-previous-chunk
            :n "M-n" #'polymode-next-chunk
            :n "M-p" #'polymode-previous-chunk
            :i "M-n" #'polymode-next-chunk
            :i "M-p" #'polymode-previous-chunk))))

(after! org
  (map! :map org-mode-map
        :n "]r" #'org-babel-next-src-block
        :n "[r" #'org-babel-previous-src-block
        :n "M-n" #'org-babel-next-src-block
        :n "M-p" #'org-babel-previous-src-block
        :i "M-n" #'org-babel-next-src-block
        :i "M-p" #'org-babel-previous-src-block))

;; Place your custom functions here
