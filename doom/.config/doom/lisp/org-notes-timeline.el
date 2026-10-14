;;; org-notes-timeline.el --- Chronological viewer for timestamped Org notes -*- lexical-binding: t; -*-

;; This viewer recognizes notes written as:
;;
;;   - Note taken on [2026-10-14 Wed 08:39] :question: \\
;;     What does this imply?
;;
;; The :type: annotation is optional.  Legacy notes receive a visibly inferred
;; type in the timeline and can be annotated there with `a'.

;;; Commentary:
;;
;; `org-notes-timeline' presents these list notes oldest-first across the
;; current subtree, current file, or all `org-agenda-files'.  The view supports
;; filtering, source navigation, explicit type annotation, and Org export.

;;; Code:

(require 'org)
(require 'org-agenda)
(require 'button)
(require 'cl-lib)
(require 'face-remap)
(require 'font-latex nil t)
(require 'pulse)
(require 'subr-x)

(defgroup org-notes-timeline nil
  "Browse timestamped Org notes as a chronological timeline."
  :group 'org)

(defcustom org-notes-timeline-types
  '("idea" "question" "claim" "source" "outline" "decision" "todo")
  "Suggested explicit note types.
Other type names found in notes remain valid and are displayed unchanged."
  :type '(repeat string)
  :group 'org-notes-timeline)

(defcustom org-notes-timeline-gap-threshold (* 2 60 60)
  "Minimum interval in seconds for displaying a gap between same-day notes.
Set this to nil to hide elapsed-time annotations."
  :type '(choice (const :tag "Do not show gaps" nil) integer)
  :group 'org-notes-timeline)

(defcustom org-notes-timeline-window-width 0.52
  "Width of the timeline side window as a fraction of the frame."
  :type 'float
  :group 'org-notes-timeline)

(defcustom org-notes-timeline-font-family
  (and (display-graphic-p)
       (find-font (font-spec :family "FiraCode Nerd Font"))
       "FiraCode Nerd Font")
  "Font family used throughout the timeline.
Nil means to inherit the editor's default and variable-pitch families."
  :type '(choice (const :tag "Inherit editor faces" nil) string)
  :group 'org-notes-timeline)

(defconst org-notes-timeline--header-regexp
  (rx line-start
      (group (* blank))
      "- Note taken on "
      (group (or (seq "[" (+ (not (any "]\n"))) "]")
                 (seq "<" (+ (not (any ">\n"))) ">")))
      (? (+ blank)
         (group ":" (group (+ (or alnum "_" "-"))) ":"))
      (* blank) "\\" "\\" (* blank) line-end)
  "Regexp matching a timestamped note header.
Groups are indentation, timestamp, complete type annotation, and type name.")

(defconst org-notes-timeline--possible-header-regexp
  (rx line-start (* blank) "- Note taken on ")
  "Regexp matching a line that appears to begin a timestamped note.")

(defvar org-notes-timeline--buffer-cache
  (make-hash-table :test #'eq :weakness 'key)
  "Parsed notes keyed by source buffer and its modification tick.")

(defvar-local org-notes-timeline--origin-marker nil
  "Marker identifying the Org context from which the timeline was opened.")
(defvar-local org-notes-timeline--scope 'agenda
  "Active collection scope: `subtree', `file', or `agenda'.")
(defvar-local org-notes-timeline--descending nil
  "Non-nil when the timeline is sorted newest-first.")
(defvar-local org-notes-timeline--type-filter nil
  "Exact type required by the current view, or nil.")
(defvar-local org-notes-timeline--text-filter nil
  "Literal text required in note bodies, or nil.")
(defvar-local org-notes-timeline--heading-filter nil
  "Regexp required in heading breadcrumbs, or nil.")
(defvar-local org-notes-timeline--tag-filter nil
  "Heading tag required by the current view, or nil.")
(defvar-local org-notes-timeline--date-from nil
  "Inclusive lower time bound for the current view, or nil.")
(defvar-local org-notes-timeline--date-to nil
  "Exclusive upper time bound for the current view, or nil.")
(defvar-local org-notes-timeline--all-notes nil
  "All parsed notes in the active scope.")
(defvar-local org-notes-timeline--visible-notes nil
  "Filtered and sorted notes currently displayed.")
(defvar-local org-notes-timeline--malformed nil
  "Malformed note headers found in the active scope.")
(defvar-local org-notes-timeline--selection-overlay nil
  "Overlay marking the note currently selected in the timeline.")

(defvar org-notes-timeline-entry-map
  (let ((map (make-sparse-keymap)))
    (define-key map [mouse-1] #'org-notes-timeline-mouse-visit)
    map)
  "Mouse keymap active across each displayed note.")

(defface org-notes-timeline-kicker-face
  '((t :inherit font-latex-sedate-face :weight semibold :height 0.8))
  "Face for compact editorial labels."
  :group 'org-notes-timeline)

(defface org-notes-timeline-title-face
  '((t :inherit font-latex-sectioning-1-face))
  "Face for the timeline title."
  :group 'org-notes-timeline)

(defface org-notes-timeline-day-face
  '((t :inherit font-latex-sectioning-3-face))
  "Face for day separators."
  :group 'org-notes-timeline)

(defface org-notes-timeline-prose-face
  '((t :inherit default))
  "Face for note prose."
  :group 'org-notes-timeline)

(defface org-notes-timeline-time-face
  '((t :inherit font-latex-sedate-face :weight semibold))
  "Face for note timestamps."
  :group 'org-notes-timeline)

(defface org-notes-timeline-meta-face
  '((t :inherit shadow :height 0.88))
  "Face for secondary timeline information."
  :group 'org-notes-timeline)

(defface org-notes-timeline-rule-face
  '((t :inherit shadow :height 0.75))
  "Face for quiet editorial rules and timeline marks."
  :group 'org-notes-timeline)

(defface org-notes-timeline-type-face
  '((t :inherit font-lock-keyword-face :weight semibold :height 0.82))
  "Fallback face for note type labels."
  :group 'org-notes-timeline)

(defface org-notes-timeline-selected-face
  '((t :inherit hl-line :extend t))
  "Face for the currently selected note."
  :group 'org-notes-timeline)

(defun org-notes-timeline--source-label (buffer)
  "Return a concise source-file label for BUFFER."
  (with-current-buffer buffer
    (if-let* ((file buffer-file-name))
        (if (and (boundp 'org-directory) org-directory)
            (file-relative-name file (expand-file-name org-directory))
          (file-name-nondirectory file))
      (buffer-name buffer))))

(defun org-notes-timeline--breadcrumb ()
  "Return the Org outline path at point as a breadcrumb."
  (if (org-before-first-heading-p)
      "Top level"
    (mapconcat #'identity (org-get-outline-path t t) " › ")))

(defun org-notes-timeline--dedent-body (text indentation)
  "Dedent note body TEXT relative to header INDENTATION."
  (let ((limit (+ indentation 2)))
    (string-trim
     (mapconcat
      (lambda (line)
        (let ((index 0))
          (while (and (< index (length line))
                      (< index limit)
                      (memq (aref line index) '(?\s ?\t)))
            (setq index (1+ index)))
          (substring line index)))
      (split-string text "\n" nil)
      "\n"))))

(defun org-notes-timeline--infer-type (text)
  "Return a conservative inferred type for note TEXT."
  (let ((case-fold-search t))
    (cond
     ((string-match-p
       (rx (or "possible outline"
               (seq line-start (* blank) (+ digit) (any ")."))))
       text)
      "outline")
     ((string-match-p
       (rx word-start
           (or "argues" "according to" "research" "study" "evidence"
               "doi" "et al")
           word-end)
       text)
      "source")
     ((string-match-p
       (rx word-start
           (or "decided" "decision" "we will" "will use" "choose" "chosen")
           word-end)
       text)
      "decision")
     ((string-match-p
       (rx word-start (or "todo" "to-do" "next step" "need to" "must") word-end)
       text)
      "todo")
     ((string-match-p "?" text) "question")
     ((string-match-p
       (rx word-start (or "therefore" "thus" "implies" "claim") word-end)
       text)
      "claim")
     (t "idea"))))

(defun org-notes-timeline--body-end (limit indentation)
  "Return the end of the current list item body before LIMIT.
INDENTATION is the indentation of its note header.  Point must be at the first
body line."
  (let ((end (point)))
    (while (and (< (point) limit)
                (or (looking-at-p (rx (* blank) line-end))
                    (> (current-indentation) indentation)))
      (forward-line 1)
      (setq end (point)))
    end))

(defun org-notes-timeline--parse-buffer (buffer)
  "Parse all timestamped notes in BUFFER.
Return a cons of valid note plists and malformed-header plists."
  (with-current-buffer buffer
    (org-with-wide-buffer
      (let ((tick (buffer-chars-modified-tick))
            (cached (gethash buffer org-notes-timeline--buffer-cache)))
        (if (and cached (= tick (car cached)))
            (cdr cached)
          (let ((limit (point-max)) notes malformed)
            (save-excursion
              (goto-char (point-min))
              (while (re-search-forward org-notes-timeline--possible-header-regexp limit t)
                (goto-char (line-beginning-position))
                (if (not (looking-at org-notes-timeline--header-regexp))
                    (progn
                      (push (list :marker (copy-marker (line-beginning-position))
                                  :file (org-notes-timeline--source-label buffer)
                                  :line (line-number-at-pos))
                            malformed)
                      (forward-line 1))
                  (let* ((indentation (length (match-string-no-properties 1)))
                         (timestamp (match-string-no-properties 2))
                         (explicit-type (match-string-no-properties 4))
                         (header-marker (copy-marker (line-beginning-position)))
                         (line (line-number-at-pos))
                         (body-start (progn (forward-line 1) (point)))
                         (body-end (org-notes-timeline--body-end limit indentation))
                         (text (org-notes-timeline--dedent-body
                                (buffer-substring-no-properties body-start body-end)
                                indentation))
                         (time (condition-case nil
                                   (org-time-string-to-time timestamp)
                                 (error nil))))
                    (if (not time)
                        (push (list :marker header-marker
                                    :file (org-notes-timeline--source-label buffer)
                                    :line line)
                              malformed)
                      (goto-char header-marker)
                      (let* ((breadcrumb (org-notes-timeline--breadcrumb))
                             (tags (unless (org-before-first-heading-p)
                                     (org-get-tags)))
                             (inferred (null explicit-type))
                             (type (or explicit-type
                                       (org-notes-timeline--infer-type text))))
                        (push (list :timestamp timestamp
                                    :time time
                                    :type (downcase type)
                                    :inferred inferred
                                    :text text
                                    :marker header-marker
                                    :body-start (copy-marker body-start)
                                    :body-end (copy-marker body-end)
                                    :file (org-notes-timeline--source-label buffer)
                                    :path breadcrumb
                                    :tags tags
                                    :line line)
                              notes)))
                    (goto-char body-end)))))
            (let ((result (cons (nreverse notes) (nreverse malformed))))
              (puthash buffer (cons tick result) org-notes-timeline--buffer-cache)
              result)))))))

(defun org-notes-timeline--subtree-bounds (marker)
  "Return marker bounds for the Org subtree containing MARKER."
  (with-current-buffer (marker-buffer marker)
    (org-with-wide-buffer
      (save-excursion
        (goto-char marker)
        (org-back-to-heading t)
        (cons (point-marker)
              (copy-marker (save-excursion (org-end-of-subtree t t))))))))

(defun org-notes-timeline--agenda-buffers ()
  "Return buffers visiting the current `org-agenda-files'."
  (delq nil
        (mapcar
         (lambda (file)
           (condition-case err
               (find-file-noselect file)
             (error
              (message "Org notes timeline: skipped %s (%s)"
                       file (error-message-string err))
              nil)))
         (delete-dups (mapcar #'expand-file-name (org-agenda-files t))))))

(defun org-notes-timeline--collect ()
  "Collect notes and malformed headers for the current timeline scope."
  (pcase org-notes-timeline--scope
    ('subtree
     (unless (and org-notes-timeline--origin-marker
                  (marker-buffer org-notes-timeline--origin-marker))
       (user-error "The original Org subtree is no longer available"))
     (let* ((buffer (marker-buffer org-notes-timeline--origin-marker))
            (bounds (org-notes-timeline--subtree-bounds
                     org-notes-timeline--origin-marker))
            (parsed (org-notes-timeline--parse-buffer buffer))
            (begin (marker-position (car bounds)))
            (end (marker-position (cdr bounds))))
       (cons
        (cl-remove-if-not
         (lambda (note)
           (let ((position (marker-position (plist-get note :marker))))
             (and (>= position begin) (< position end))))
         (car parsed))
        (cl-remove-if-not
         (lambda (entry)
           (let ((position (marker-position (plist-get entry :marker))))
             (and (>= position begin) (< position end))))
         (cdr parsed)))))
    ('file
     (unless (and org-notes-timeline--origin-marker
                  (marker-buffer org-notes-timeline--origin-marker))
       (user-error "The original Org file is no longer available"))
     (org-notes-timeline--parse-buffer
      (marker-buffer org-notes-timeline--origin-marker)))
    ('agenda
     (let (notes malformed)
       (dolist (buffer (org-notes-timeline--agenda-buffers))
         (pcase-let ((`(,buffer-notes . ,buffer-malformed)
                      (org-notes-timeline--parse-buffer buffer)))
           (setq notes (nconc notes buffer-notes)
                 malformed (nconc malformed buffer-malformed))))
       (cons notes malformed)))
    (_ (error "Unknown Org notes timeline scope: %S" org-notes-timeline--scope))))

(defun org-notes-timeline--time< (left right)
  "Return non-nil when note LEFT predates note RIGHT."
  (time-less-p (plist-get left :time) (plist-get right :time)))

(defun org-notes-timeline--matches-filters-p (note)
  "Return non-nil when NOTE satisfies all active view filters."
  (and
   (or (null org-notes-timeline--type-filter)
       (equal org-notes-timeline--type-filter (plist-get note :type)))
   (or (null org-notes-timeline--text-filter)
       (let ((case-fold-search t))
         (string-match-p (regexp-quote org-notes-timeline--text-filter)
                         (plist-get note :text))))
   (or (null org-notes-timeline--heading-filter)
       (let ((case-fold-search t))
         (condition-case nil
             (string-match-p org-notes-timeline--heading-filter
                             (plist-get note :path))
           (invalid-regexp nil))))
   (or (null org-notes-timeline--tag-filter)
       (member org-notes-timeline--tag-filter (plist-get note :tags)))
   (or (null org-notes-timeline--date-from)
       (not (time-less-p (plist-get note :time)
                         org-notes-timeline--date-from)))
   (or (null org-notes-timeline--date-to)
       (time-less-p (plist-get note :time)
                    org-notes-timeline--date-to))))

(defun org-notes-timeline--scope-label ()
  "Return an editorial title for the active scope."
  (pcase org-notes-timeline--scope
    ('subtree
     (let ((marker org-notes-timeline--origin-marker))
       (with-current-buffer (marker-buffer marker)
         (save-excursion
           (goto-char marker)
           (org-get-heading t t t t)))))
    ('file
     (org-notes-timeline--source-label
      (marker-buffer org-notes-timeline--origin-marker)))
    ('agenda "All notes")))

(defun org-notes-timeline--scope-name ()
  "Return a compact uppercase name for the active scope."
  (pcase org-notes-timeline--scope
    ('subtree "CURRENT SUBTREE")
    ('file "CURRENT FILE")
    ('agenda "AGENDA FILES")))

(defun org-notes-timeline--filter-summary ()
  "Return a compact description of all active filters."
  (string-join
   (delq nil
         (list
          (when org-notes-timeline--type-filter
            (format "type:%s" org-notes-timeline--type-filter))
          (when org-notes-timeline--text-filter
            (format "text:%S" org-notes-timeline--text-filter))
          (when org-notes-timeline--heading-filter
            (format "heading:%S" org-notes-timeline--heading-filter))
          (when org-notes-timeline--tag-filter
            (format "tag:%s" org-notes-timeline--tag-filter))
          (when org-notes-timeline--date-from
            (format "from:%s" (format-time-string "%F" org-notes-timeline--date-from)))
          (when org-notes-timeline--date-to
            (format "to:%s"
                    (format-time-string "%F"
                                        (time-subtract org-notes-timeline--date-to
                                                       (seconds-to-time 1)))))))
   "  ·  "))

(defun org-notes-timeline--type-face (type)
  "Return the display face associated with note TYPE."
  (pcase type
    ((or "idea" "claim" "decision") 'font-lock-function-name-face)
    ("question" 'font-lock-keyword-face)
    ("source" 'font-lock-type-face)
    ("outline" 'font-lock-comment-face)
    ("todo" 'warning)
    (_ 'org-notes-timeline-type-face)))

(defun org-notes-timeline--type-badge-face (type)
  "Return an AUCTeX-like inline face for note TYPE."
  `(:inherit ,(org-notes-timeline--type-face type)
    :weight bold :height 0.88))

(defun org-notes-timeline--word-count (notes)
  "Count words across the bodies of NOTES."
  (cl-loop for note in notes
           sum (length (split-string (plist-get note :text)
                                     "[^[:word:]’'-]+" t))))

(defun org-notes-timeline--day-count (notes)
  "Count distinct calendar days represented by NOTES."
  (length
   (delete-dups
    (mapcar (lambda (note)
              (format-time-string "%F" (plist-get note :time)))
            notes))))

(defun org-notes-timeline--rule-width ()
  "Return a restrained rule width for the current timeline window."
  (let ((window (get-buffer-window (current-buffer) t)))
    (max 28 (min 66 (- (if window (window-body-width window) 70) 2)))))

(defun org-notes-timeline--header-line ()
  "Build the quiet, persistent keyboard guide shown above the timeline."
  (concat
   "  " (propertize "n/p" 'face 'help-key-binding) " move   "
   (propertize "RET" 'face 'help-key-binding) " open   "
   (propertize "a" 'face 'help-key-binding) " type   "
   (propertize "/" 'face 'help-key-binding) " filter   "
   (propertize "s" 'face 'help-key-binding) " scope   "
   (propertize "?" 'face 'help-key-binding) " help"))

(defun org-notes-timeline--format-duration (seconds)
  "Format an elapsed duration of SECONDS compactly."
  (cond
   ((>= seconds 86400) (format "%dd %dh later" (/ seconds 86400)
                                (/ (% seconds 86400) 3600)))
   ((>= seconds 3600) (format "%dh %dm later" (/ seconds 3600)
                               (/ (% seconds 3600) 60)))
   (t (format "%dm later" (/ seconds 60)))))

(defun org-notes-timeline--insert-indented (text prefix &optional face)
  "Insert every line of TEXT preceded by PREFIX and styled with FACE.
Wrapped visual lines retain PREFIX as their `wrap-prefix'."
  (let ((lines (split-string text "\n" nil)))
    (dolist (line lines)
      (let ((line-start (point)))
        (insert prefix)
        (let ((content-start (point)))
          (insert line "\n")
          (add-text-properties content-start (point) `(face ,face)))
        (add-text-properties line-start (point) `(wrap-prefix ,prefix))))))

(defun org-notes-timeline--update-selection ()
  "Move the selection overlay to the note at point."
  (when (derived-mode-p 'org-notes-timeline-mode)
    (let ((note (org-notes-timeline--note-at-point)))
      (if (not note)
          (when (overlayp org-notes-timeline--selection-overlay)
            (delete-overlay org-notes-timeline--selection-overlay)
            (setq org-notes-timeline--selection-overlay nil))
        (let* ((start (text-property-any
                       (point-min) (min (point-max) (1+ (point)))
                       'org-notes-timeline-note note))
               (end (and start
                         (next-single-property-change
                          start 'org-notes-timeline-note nil (point-max)))))
          (unless (overlayp org-notes-timeline--selection-overlay)
            (setq org-notes-timeline--selection-overlay
                  (make-overlay start end nil nil t))
            (overlay-put org-notes-timeline--selection-overlay
                         'face 'org-notes-timeline-selected-face)
            (overlay-put org-notes-timeline--selection-overlay 'priority -20))
          (move-overlay org-notes-timeline--selection-overlay start end))))))

(defun org-notes-timeline--note-at-point ()
  "Return the displayed note plist at point, or nil."
  (or (get-text-property (point) 'org-notes-timeline-note)
      (and (> (point) (point-min))
           (get-text-property (1- (point)) 'org-notes-timeline-note))))

(defun org-notes-timeline--find-note (marker)
  "Move point to the displayed note whose source is MARKER."
  (let ((position (point-min)) found)
    (while (and (< position (point-max)) (not found))
      (let ((note (get-text-property position 'org-notes-timeline-note)))
        (when (and note (eq (marker-buffer marker)
                            (marker-buffer (plist-get note :marker)))
                   (= (marker-position marker)
                      (marker-position (plist-get note :marker))))
          (setq found position)))
      (setq position (next-single-property-change
                      position 'org-notes-timeline-note nil (point-max))))
    (when found (goto-char found))))

(defun org-notes-timeline-refresh (&optional preserve-marker)
  "Rebuild the current timeline.
When PRESERVE-MARKER is non-nil, return point to that source note."
  (interactive (list (when-let* ((note (org-notes-timeline--note-at-point)))
                       (plist-get note :marker))))
  (let* ((collected (org-notes-timeline--collect))
         (all (car collected))
         (malformed (cdr collected))
         (visible (cl-remove-if-not #'org-notes-timeline--matches-filters-p all))
         (sorted (cl-stable-sort (copy-sequence visible)
                                 (if org-notes-timeline--descending
                                     (lambda (a b) (org-notes-timeline--time< b a))
                                   #'org-notes-timeline--time<)))
         (note-count (length sorted))
         (word-count (org-notes-timeline--word-count sorted))
         (day-count (org-notes-timeline--day-count sorted))
         (inhibit-read-only t)
         (body-prefix "          ")
         previous-time previous-day)
    (setq org-notes-timeline--all-notes all
          org-notes-timeline--visible-notes sorted
          org-notes-timeline--malformed malformed)
    (erase-buffer)

    ;; Masthead: quiet utility label, strong editorial title, compact colophon.
    (insert (propertize "ORG NOTES" 'face 'org-notes-timeline-kicker-face)
            (propertize "  /  " 'face 'org-notes-timeline-rule-face)
            (propertize (org-notes-timeline--scope-name)
                        'face 'org-notes-timeline-kicker-face)
            "\n")
    (insert (propertize (org-notes-timeline--scope-label)
                        'face 'org-notes-timeline-title-face)
            "\n")
    (insert
     (propertize
      (format "%s  ·  %d word%s  ·  %d day%s  ·  %s"
              (if (= note-count (length all))
                  (format "%d note%s" note-count (if (= note-count 1) "" "s"))
                (format "%d of %d notes" note-count (length all)))
              word-count
              (if (= word-count 1) "" "s")
              day-count
              (if (= day-count 1) "" "s")
              (if org-notes-timeline--descending
                  "newest → oldest" "oldest → newest"))
      'face 'org-notes-timeline-meta-face)
     "\n")
    (when-let* ((filters (org-notes-timeline--filter-summary)))
      (unless (string-empty-p filters)
        (insert (propertize "FILTER  /  " 'face 'org-notes-timeline-kicker-face)
                (propertize filters 'face 'org-notes-timeline-meta-face)
                "\n")))
    (when malformed
      (insert-text-button
       (format "⚠ %d malformed note header%s — press ! to inspect"
               (length malformed) (if (= (length malformed) 1) "" "s"))
       'face 'warning
       'follow-link t
       'action (lambda (_button) (org-notes-timeline-show-malformed)))
      (insert "\n"))
    (insert "\n\n")

    (if (null sorted)
        (progn
          (insert (propertize "Nothing here—yet.\n"
                              'face 'org-notes-timeline-day-face))
          (insert (propertize
                   "No notes match this scope and filter set.\nPress c to clear filters or s to change scope."
                   'face 'org-notes-timeline-meta-face)))
      (dolist (note sorted)
        (let* ((time (plist-get note :time))
               (day (format-time-string "%F" time))
               (entry-start nil)
               (type (plist-get note :type))
               (gap (and previous-time
                         (floor (float-time (time-subtract time previous-time))))))
          (unless (equal day previous-day)
            (unless (null previous-day) (insert "\n"))
            (insert (propertize (format-time-string "%A" time)
                                'face 'org-notes-timeline-day-face)
                    (propertize (format-time-string "  ·  %e %B %Y" time)
                                'face 'org-notes-timeline-meta-face)
                    "\n")
            (insert (propertize (make-string (org-notes-timeline--rule-width) ?─)
                                'face 'org-notes-timeline-rule-face)
                    "\n\n")
            (setq previous-day day))
          (when (and org-notes-timeline-gap-threshold
                     gap (> gap org-notes-timeline-gap-threshold)
                     (equal day (and previous-time
                                     (format-time-string "%F" previous-time))))
            (insert (propertize
                     (format "%s%s\n\n" body-prefix
                             (org-notes-timeline--format-duration gap))
                     'face 'org-notes-timeline-rule-face)))
          (setq entry-start (point))
          (insert-text-button
           (format-time-string "%H:%M" time)
           'face 'org-notes-timeline-time-face
           'follow-link t
           'help-echo "Open this note in its Org source"
           'org-notes-timeline-note note
           'action (lambda (button)
                     (org-notes-timeline-visit
                      (button-get button 'org-notes-timeline-note))))
          (insert "  "
                  (propertize "●" 'face (org-notes-timeline--type-face type))
                  "  ")
          (let* ((label (upcase type))
                 (label (if (plist-get note :inferred)
                            (concat "~" label) label)))
            (insert
             (propertize (format " %s " label)
                         'face (org-notes-timeline--type-badge-face type)
                         'help-echo
                         (if (plist-get note :inferred)
                             "Inferred type; press a to make it explicit"
                           "Explicit type annotation"))))
          (insert "\n\n")
          (org-notes-timeline--insert-indented
           (plist-get note :text) body-prefix 'org-notes-timeline-prose-face)
          (insert body-prefix
                  (propertize
                   (format "%s  /  %s"
                           (plist-get note :file) (plist-get note :path))
                   'face 'org-notes-timeline-meta-face)
                  "\n\n")
          (add-text-properties
           entry-start (point)
           `(org-notes-timeline-note ,note
             keymap ,org-notes-timeline-entry-map
             mouse-face highlight
             pointer hand
             rear-nonsticky t
             help-echo "Click or press RET to open source · a assigns type"))
          (setq previous-time time))))

    (goto-char (point-min))
    (if preserve-marker
        (unless (org-notes-timeline--find-note preserve-marker)
          (forward-button 1 t))
      (forward-button 1 t))
    (org-notes-timeline--update-selection)))

(defun org-notes-timeline-mouse-visit (event)
  "Visit the timeline note clicked by mouse EVENT."
  (interactive "e")
  (mouse-set-point event)
  (org-notes-timeline-visit))

(defun org-notes-timeline-visit (&optional note other-window)
  "Visit NOTE's source, using another window when OTHER-WINDOW is non-nil."
  (interactive (list nil current-prefix-arg))
  (setq note (or note (org-notes-timeline--note-at-point)))
  (unless note (user-error "No note at point"))
  (let ((marker (plist-get note :marker)))
    (unless (and marker (marker-buffer marker))
      (user-error "This note's source buffer is no longer available"))
    (if other-window
        (pop-to-buffer (marker-buffer marker) '(display-buffer-pop-up-window))
      (pop-to-buffer (marker-buffer marker)))
    (goto-char marker)
    (org-fold-show-context 'agenda)
    (recenter)
    (pulse-momentary-highlight-one-line (point))))

(defun org-notes-timeline--entry-positions ()
  "Return the starting positions of displayed note entries."
  (let ((position (point-min)) previous-note starts)
    (while (< position (point-max))
      (let ((note (get-text-property position 'org-notes-timeline-note)))
        (when (and note (not (eq note previous-note)))
          (push position starts))
        (setq previous-note note
              position (next-single-property-change
                        position 'org-notes-timeline-note nil (point-max)))))
    (nreverse starts)))

(defun org-notes-timeline--current-entry-start ()
  "Return the start of the displayed note at point, or nil."
  (when-let* ((note (org-notes-timeline--note-at-point)))
    (text-property-any (point-min) (min (point-max) (1+ (point)))
                       'org-notes-timeline-note note)))

(defun org-notes-timeline-next ()
  "Move to the next displayed note."
  (interactive)
  (let* ((current (or (org-notes-timeline--current-entry-start) (point)))
         (next (cl-find-if (lambda (position) (> position current))
                           (org-notes-timeline--entry-positions))))
    (if next
        (goto-char next)
      (user-error "No later displayed note"))))

(defun org-notes-timeline-previous ()
  "Move to the previous displayed note."
  (interactive)
  (let* ((current (or (org-notes-timeline--current-entry-start) (point)))
         (previous (car (last (cl-remove-if-not
                               (lambda (position) (< position current))
                               (org-notes-timeline--entry-positions))))))
    (if previous
        (goto-char previous)
      (user-error "No earlier displayed note"))))

(defun org-notes-timeline-reverse ()
  "Toggle chronological direction."
  (interactive)
  (setq org-notes-timeline--descending (not org-notes-timeline--descending))
  (org-notes-timeline-refresh))

(defun org-notes-timeline-set-scope ()
  "Choose the timeline scope."
  (interactive)
  (let* ((choice (completing-read
                  "Timeline scope: "
                  '("current subtree" "current file" "all agenda files")
                  nil t))
         (scope (pcase choice
                  ("current subtree" 'subtree)
                  ("current file" 'file)
                  (_ 'agenda))))
    (when (and (memq scope '(subtree file))
               (not (and org-notes-timeline--origin-marker
                         (marker-buffer org-notes-timeline--origin-marker))))
      (user-error "Open the timeline from an Org file to use that scope"))
    (setq org-notes-timeline--scope scope)
    (org-notes-timeline-refresh)))

(defun org-notes-timeline-filter-text ()
  "Filter notes by literal text content."
  (interactive)
  (let ((value (read-string "Text contains (empty clears): "
                            org-notes-timeline--text-filter)))
    (setq org-notes-timeline--text-filter (unless (string-empty-p value) value))
    (org-notes-timeline-refresh)))

(defun org-notes-timeline-filter-type ()
  "Filter notes by note type."
  (interactive)
  (let* ((types (delete-dups
                 (append org-notes-timeline-types
                         (mapcar (lambda (note) (plist-get note :type))
                                 org-notes-timeline--all-notes))))
         (value (completing-read "Type (all clears): "
                                 (cons "all" types) nil t)))
    (setq org-notes-timeline--type-filter
          (unless (equal value "all") value))
    (org-notes-timeline-refresh)))

(defun org-notes-timeline-filter-heading ()
  "Filter notes by a heading-path regexp."
  (interactive)
  (let ((value (read-string "Heading regexp (empty clears): "
                            org-notes-timeline--heading-filter)))
    (when (and (not (string-empty-p value))
               (condition-case nil (progn (string-match-p value "") nil)
                 (invalid-regexp t)))
      (user-error "Invalid regexp: %s" value))
    (setq org-notes-timeline--heading-filter (unless (string-empty-p value) value))
    (org-notes-timeline-refresh)))

(defun org-notes-timeline-filter-tag ()
  "Filter notes by an inherited heading tag."
  (interactive)
  (let* ((tags (delete-dups
                (apply #'append
                       (mapcar (lambda (note) (copy-sequence (plist-get note :tags)))
                               org-notes-timeline--all-notes))))
         (value (completing-read "Tag (all clears): "
                                 (cons "all" (sort tags #'string-lessp)) nil t)))
    (setq org-notes-timeline--tag-filter
          (unless (equal value "all") value))
    (org-notes-timeline-refresh)))

(defun org-notes-timeline--read-date (prompt current)
  "Read a date with PROMPT, formatting CURRENT as the default."
  (let* ((default (and current (format-time-string "%F" current)))
         (input (read-string prompt default)))
    (unless (string-empty-p input)
      (org-read-date nil t input))))

(defun org-notes-timeline-filter-dates ()
  "Set an inclusive date range for displayed notes."
  (interactive)
  (let* ((from (org-notes-timeline--read-date
                "From date (empty clears): " org-notes-timeline--date-from))
         (current-to (and org-notes-timeline--date-to
                          (time-subtract org-notes-timeline--date-to
                                         (days-to-time 1))))
         (to (org-notes-timeline--read-date
              "Through date (empty clears): " current-to)))
    (when (and from to (time-less-p to from))
      (user-error "End date precedes start date"))
    (setq org-notes-timeline--date-from from
          org-notes-timeline--date-to (and to (time-add to (days-to-time 1))))
    (org-notes-timeline-refresh)))

(defun org-notes-timeline-clear-filters ()
  "Clear every active timeline filter."
  (interactive)
  (setq org-notes-timeline--type-filter nil
        org-notes-timeline--text-filter nil
        org-notes-timeline--heading-filter nil
        org-notes-timeline--tag-filter nil
        org-notes-timeline--date-from nil
        org-notes-timeline--date-to nil)
  (org-notes-timeline-refresh))

(defun org-notes-timeline-assign-type ()
  "Persist an explicit type annotation on the note at point."
  (interactive)
  (let* ((note (org-notes-timeline--note-at-point))
         (_ (unless note (user-error "No note at point")))
         (old-type (plist-get note :type))
         (choices (delete-dups
                   (append org-notes-timeline-types (list old-type "clear"))))
         (type (completing-read "Assign type (clear removes annotation): "
                                choices nil nil nil nil old-type))
         (marker (plist-get note :marker))
         (source (marker-buffer marker)))
    (unless source (user-error "The source note no longer exists"))
    (unless (or (equal type "clear")
                (string-match-p "\\`[[:alnum:]_-]+\\'" type))
      (user-error "Types may contain only letters, numbers, underscores, and hyphens"))
    (with-current-buffer source
      (let ((was-modified (buffer-modified-p)))
        (save-excursion
          (goto-char marker)
          (unless (looking-at org-notes-timeline--header-regexp)
            (user-error "The source note header has changed"))
          (let ((indentation (match-string-no-properties 1))
                (timestamp (match-string-no-properties 2))
                (line-end (line-end-position)))
            (atomic-change-group
              (delete-region (line-beginning-position) line-end)
              (insert indentation "- Note taken on " timestamp
                      (if (equal type "clear") "" (format " :%s:" (downcase type)))
                      " \\\\"))))
        (unless was-modified (save-buffer))))
    (org-notes-timeline-refresh marker)
    (message "%s" (if (equal type "clear")
                       "Removed explicit note type"
                     (format "Assigned note type: %s" (downcase type))))))

(defun org-notes-timeline-show-malformed ()
  "Show note-like headers that could not be parsed."
  (interactive)
  (unless org-notes-timeline--malformed
    (user-error "No malformed note headers in this scope"))
  (let ((entries org-notes-timeline--malformed)
        (buffer (get-buffer-create "*Malformed Org Notes*")))
    (with-current-buffer buffer
      (let ((inhibit-read-only t))
        (erase-buffer)
        (special-mode)
        (insert (propertize "MALFORMED ORG NOTE HEADERS\n\n"
                            'face 'org-notes-timeline-title-face))
        (dolist (entry entries)
          (insert-text-button
           (format "%s:%d" (plist-get entry :file) (plist-get entry :line))
           'face 'link
           'follow-link t
           'source-marker (plist-get entry :marker)
           'action (lambda (button)
                     (let ((marker (button-get button 'source-marker)))
                       (pop-to-buffer (marker-buffer marker))
                       (goto-char marker)
                       (pulse-momentary-highlight-one-line (point)))))
          (insert "\n"))))
    (pop-to-buffer buffer)))

(defun org-notes-timeline-export ()
  "Export the visible timeline to a normal Org buffer."
  (interactive)
  (unless org-notes-timeline--visible-notes
    (user-error "There are no visible notes to export"))
  (let ((notes org-notes-timeline--visible-notes)
        (scope (org-notes-timeline--scope-label))
        (buffer (generate-new-buffer "*Org Notes Timeline Export*"))
        previous-day)
    (with-current-buffer buffer
      (org-mode)
      (insert "#+title: Org notes timeline\n"
              "#+subtitle: " scope "\n\n")
      (dolist (note notes)
        (let* ((time (plist-get note :time))
               (day (format-time-string "%F" time)))
          (unless (equal day previous-day)
            (insert "* " (format-time-string "%A, %e %B %Y" time) "\n")
            (setq previous-day day))
          (insert "** " (format-time-string "%H:%M" time)
                  " " (upcase (plist-get note :type))
                  " — " (plist-get note :path) "\n")
          (insert (format "[[file:%s::%d][%s]]\n\n"
                          (buffer-file-name
                           (marker-buffer (plist-get note :marker)))
                          (plist-get note :line)
                          (plist-get note :file)))
          (insert (plist-get note :text) "\n\n")))
      (goto-char (point-min))
      (set-buffer-modified-p nil))
    (pop-to-buffer buffer)))

(defvar org-notes-timeline-mode-map
  (let ((map (make-sparse-keymap)))
    (set-keymap-parent map special-mode-map)
    (define-key map (kbd "n") #'org-notes-timeline-next)
    (define-key map (kbd "p") #'org-notes-timeline-previous)
    (define-key map (kbd "RET") #'org-notes-timeline-visit)
    (define-key map (kbd "a") #'org-notes-timeline-assign-type)
    (define-key map (kbd "r") #'org-notes-timeline-reverse)
    (define-key map (kbd "s") #'org-notes-timeline-set-scope)
    (define-key map (kbd "/") #'org-notes-timeline-filter-text)
    (define-key map (kbd "t") #'org-notes-timeline-filter-type)
    (define-key map (kbd "d") #'org-notes-timeline-filter-dates)
    (define-key map (kbd "h") #'org-notes-timeline-filter-heading)
    (define-key map (kbd "T") #'org-notes-timeline-filter-tag)
    (define-key map (kbd "c") #'org-notes-timeline-clear-filters)
    (define-key map (kbd "x") #'org-notes-timeline-export)
    (define-key map (kbd "!") #'org-notes-timeline-show-malformed)
    (define-key map (kbd "?") #'describe-mode)
    (define-key map (kbd "g") #'org-notes-timeline-refresh)
    (define-key map (kbd "q") #'quit-window)
    map)
  "Keymap for `org-notes-timeline-mode'.")

(define-derived-mode org-notes-timeline-mode special-mode "Org-Notes"
  "Major mode for browsing timestamped Org notes chronologically."
  (setq-local truncate-lines nil)
  (setq-local line-spacing 0.2)
  (setq-local cursor-type 'box)
  (setq-local header-line-format
              '(:eval (org-notes-timeline--header-line)))
  (setq-local revert-buffer-function
              (lambda (&rest _ignore) (org-notes-timeline-refresh)))
  (when org-notes-timeline-font-family
    (dolist (face '(default variable-pitch))
      (face-remap-add-relative
       face `(:family ,org-notes-timeline-font-family))))
  (add-hook 'post-command-hook #'org-notes-timeline--update-selection nil t)
  (visual-line-mode 1))

;;;###autoload
(defun org-notes-timeline (&optional prompt-for-scope)
  "Open a chronological timeline of timestamped Org notes.
From an Org heading, the initial scope is its subtree.  Elsewhere in an Org
file it is the current file; outside Org it is all agenda files.  With prefix
argument PROMPT-FOR-SCOPE, ask for the initial scope."
  (interactive "P")
  (let* ((origin (when (derived-mode-p 'org-mode) (copy-marker (point))))
         (default-scope
          (cond
           ((not origin) 'agenda)
           ((org-before-first-heading-p) 'file)
           (t 'subtree)))
         (scope
          (if prompt-for-scope
              (let ((choice (completing-read
                             "Timeline scope: "
                             '("current subtree" "current file" "all agenda files")
                             nil t nil nil
                             (pcase default-scope
                               ('subtree "current subtree")
                               ('file "current file")
                               (_ "all agenda files")))))
                (pcase choice
                  ("current subtree" 'subtree)
                  ("current file" 'file)
                  (_ 'agenda)))
            default-scope))
         (buffer (get-buffer-create "*Org Notes Timeline*")))
    (when (and (memq scope '(subtree file)) (null origin))
      (user-error "Current subtree/file scope requires an Org source buffer"))
    (with-current-buffer buffer
      (org-notes-timeline-mode)
      (setq org-notes-timeline--origin-marker origin
            org-notes-timeline--scope scope
            org-notes-timeline--descending nil
            org-notes-timeline--type-filter nil
            org-notes-timeline--text-filter nil
            org-notes-timeline--heading-filter nil
            org-notes-timeline--tag-filter nil
            org-notes-timeline--date-from nil
            org-notes-timeline--date-to nil)
      (org-notes-timeline-refresh))
    (let ((window
           (display-buffer-in-side-window
            buffer `((side . right) (slot . 0)
                     (window-width . ,org-notes-timeline-window-width)))))
      (set-window-dedicated-p window t)
      (set-window-margins window 3 2)
      (select-window window))))

;;;###autoload
(defun org-notes-timeline-agenda ()
  "Open a chronological timeline across all `org-agenda-files'."
  (interactive)
  (let ((buffer (current-buffer)))
    (org-notes-timeline)
    (with-current-buffer "*Org Notes Timeline*"
      (setq org-notes-timeline--scope 'agenda
            org-notes-timeline--origin-marker
            (when (with-current-buffer buffer (derived-mode-p 'org-mode))
              (with-current-buffer buffer (copy-marker (point)))))
      (org-notes-timeline-refresh))))

(provide 'org-notes-timeline)
;;; org-notes-timeline.el ends here
