;;; pi-edit.el --- Edit passages delimited by PI-EDIT comments -*- lexical-binding: t; -*-

;;; Commentary:
;; Start inside a marked passage with `pi-edit-start'.  Finish removes only
;; the two comments; leave keeps them.  Neither command saves the file.
;; Run tests from the Doom directory:
;; emacs -Q --batch -L lisp -l lisp/pi-edit-test.el -f ert-run-tests-batch-and-exit

;;; Code:

(defconst pi-edit--start "<!-- PI-EDIT: start -->")
(defconst pi-edit--end "<!-- PI-EDIT: end -->")
(defconst pi-edit--regexp "<!-- PI-EDIT: \\(start\\|end\\) -->")

(defvar-local pi-edit--markers nil
  "Markers at the beginning of the opening and end of the closing comment.")

(defvar pi-edit-mode-map
  (let ((map (make-sparse-keymap)))
    (define-key map (kbd "C-c C-c") #'pi-edit-finish)
    (define-key map (kbd "C-c C-k") #'pi-edit-leave)
    map)
  "Keymap active while editing a PI-EDIT passage.")

(defvar pi-edit-command-map
  (let ((map (make-sparse-keymap "PI edit")))
    (define-key map (kbd "s") #'pi-edit-start)
    (define-key map (kbd "f") #'pi-edit-finish)
    (define-key map (kbd "l") #'pi-edit-leave)
    map)
  "Command prefix for Doom local-leader bindings.")

(defun pi-edit--bounds ()
  "Find the comment pair enclosing point, rejecting malformed marker pairs.
Return the start of the opening and end of the closing comment.
All PI-EDIT pairs in the buffer must be balanced and non-nested."
  (let ((origin (point)) opening content-start bounds
        (case-fold-search nil))
    (save-excursion
      (goto-char (point-min))
      (while (re-search-forward pi-edit--regexp nil t)
        (if (equal (match-string-no-properties 1) "start")
            (progn
              (when opening
                (user-error "Nested PI-EDIT start comments"))
              (setq opening (match-beginning 0)
                    content-start (match-end 0)))
          (unless opening
            (user-error "PI-EDIT end comment has no start comment"))
          (when (<= content-start origin (match-beginning 0))
            (setq bounds (list opening (match-end 0))))
          (setq opening nil)))
      (when opening
        (user-error "PI-EDIT start comment has no end comment")))
    (or bounds (user-error "Place point between PI-EDIT start and end comments"))))

(defun pi-edit--release ()
  "Release the current passage and restore the full buffer."
  (when pi-edit--markers
    (widen)
    (mapc (lambda (marker) (set-marker marker nil)) pi-edit--markers)
    (setq pi-edit--markers nil)))

;;;###autoload
(define-minor-mode pi-edit-mode
  "Edit text between PI-EDIT comments without changing the major mode.
Enabling requires an unnarrowed buffer and point inside a marked passage.
Disabling widens without removing comments or reverting edits.
Use `pi-edit-finish' to remove the comments and widen instead."
  :lighter " PI-Edit"
  :keymap pi-edit-mode-map
  (if pi-edit-mode
      (unless pi-edit--markers
        (condition-case err
            (progn
              (when (buffer-narrowed-p)
                (user-error "Widen the buffer before starting PI-EDIT"))
              (let* ((bounds (pi-edit--bounds))
                     (opening (car bounds))
                     (closing (cadr bounds)))
                (setq pi-edit--markers
                      (list (copy-marker opening)
                            (copy-marker closing t)))
                (narrow-to-region (+ opening (length pi-edit--start))
                                  (- closing (length pi-edit--end)))))
          (error
           (setq pi-edit-mode nil)
           (pi-edit--release)
           (signal (car err) (cdr err)))))
    (pi-edit--release)))

;;;###autoload
(defun pi-edit-start ()
  "Narrow to the PI-EDIT passage enclosing point."
  (interactive)
  (pi-edit-mode 1)
  (message "PI-EDIT: C-c C-c finishes; C-c C-k leaves comments in place"))

;;;###autoload
(defun pi-edit-leave ()
  "Leave passage editing, keeping both comments and all text edits."
  (interactive)
  (pi-edit-mode -1))

;;;###autoload
(defun pi-edit-finish ()
  "Remove the current passage's two comments and restore the full buffer.
Keep the edited text and surrounding whitespace exactly as they are.
Comment removal is a single undoable operation; the file is not saved."
  (interactive)
  (unless (and pi-edit-mode pi-edit--markers)
    (user-error "No active PI-EDIT passage"))
  (barf-if-buffer-read-only)
  (save-restriction
    (widen)
    (let* ((opening (marker-position (car pi-edit--markers)))
           (closing (marker-position (cadr pi-edit--markers)))
           (content-start (+ opening (length pi-edit--start)))
           (content-end (- closing (length pi-edit--end))))
      (unless (and (<= (point-min) opening content-start content-end
                       closing (point-max))
                   (equal (buffer-substring-no-properties opening content-start)
                          pi-edit--start)
                   (equal (buffer-substring-no-properties content-end closing)
                          pi-edit--end))
        (user-error "PI-EDIT comments changed; leave and inspect the buffer"))
      (undo-boundary)
      (atomic-change-group
        (save-excursion
          (delete-region content-end closing)
          (delete-region opening content-start)))
      (undo-boundary)))
  (pi-edit-mode -1)
  (message "PI-EDIT finished; comments removed (save when ready)"))

(provide 'pi-edit)
;;; pi-edit.el ends here
