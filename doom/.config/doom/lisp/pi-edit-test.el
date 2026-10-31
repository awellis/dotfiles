;;; pi-edit-test.el --- Tests for PI-EDIT passage editing -*- lexical-binding: t; -*-

(require 'ert)
(require 'pi-edit)

(defmacro pi-edit-test--passage (text &rest body)
  "Run BODY in a buffer containing a marked passage with TEXT."
  (declare (indent 1) (debug t))
  `(with-temp-buffer
     (text-mode)
     (insert "Before\n" pi-edit--start ,text pi-edit--end "\nAfter")
     (goto-char (+ (point-min) (length "Before\n") (length pi-edit--start)))
     ,@body))

(ert-deftest pi-edit-start-preserves-mode-and-document ()
  (pi-edit-test--passage "Grüezi [Link](page.qmd)\nSecond line"
    (set-buffer-modified-p nil)
    (let ((original (buffer-string)))
      (pi-edit-start)
      (should pi-edit-mode)
      (should (eq major-mode 'text-mode))
      (should (equal (buffer-string) "Grüezi [Link](page.qmd)\nSecond line"))
      (should-not (buffer-modified-p))
      (pi-edit-leave)
      (should-not pi-edit-mode)
      (should-not (buffer-narrowed-p))
      (should (equal (buffer-string) original)))))

(ert-deftest pi-edit-finish-keeps-boundary-insertions ()
  (pi-edit-test--passage "Original"
    (pi-edit-start)
    (insert "First ")
    (goto-char (point-max))
    (insert " last")
    (pi-edit-finish)
    (should (equal (buffer-string) "Before\nFirst Original last\nAfter"))
    (should-not pi-edit-mode)
    (should-not pi-edit--markers)
    (should-not (buffer-narrowed-p))))

(ert-deftest pi-edit-replace-entire-passage ()
  (pi-edit-test--passage "Original"
    (pi-edit-start)
    (delete-region (point-min) (point-max))
    (insert "Replacement")
    (pi-edit-finish)
    (should (equal (buffer-string) "Before\nReplacement\nAfter"))))

(ert-deftest pi-edit-empty-passage ()
  (pi-edit-test--passage ""
    (pi-edit-start)
    (insert "New")
    (pi-edit-finish)
    (should (equal (buffer-string) "Before\nNew\nAfter"))))

(ert-deftest pi-edit-leave-keeps-edits-and-allows-reentry ()
  (pi-edit-test--passage "Original"
    (pi-edit-start)
    (insert "Edited ")
    (pi-edit-leave)
    (should-not (buffer-narrowed-p))
    (should (equal (buffer-string)
                   (concat "Before\n" pi-edit--start "Edited Original"
                           pi-edit--end "\nAfter")))
    (pi-edit-start)
    (pi-edit-finish)
    (should (equal (buffer-string) "Before\nEdited Original\nAfter"))))

(ert-deftest pi-edit-finish-is-undoable-separately ()
  (pi-edit-test--passage "Original"
    (buffer-enable-undo)
    (pi-edit-start)
    (insert "Edited ")
    (pi-edit-finish)
    (undo 1)
    (should (equal (buffer-string)
                   (concat "Before\n" pi-edit--start "Edited Original"
                           pi-edit--end "\nAfter")))))

(ert-deftest pi-edit-selects-only-enclosing-pair ()
  (with-temp-buffer
    (insert pi-edit--start "One" pi-edit--end " / " pi-edit--start)
    (let ((position (point)))
      (insert "Two" pi-edit--end)
      (goto-char position))
    (pi-edit-start)
    (should (equal (buffer-string) "Two"))
    (pi-edit-finish)
    (should (equal (buffer-string)
                   (concat pi-edit--start "One" pi-edit--end " / Two")))))

(ert-deftest pi-edit-rejects-invalid-markers-without-changes ()
  (dolist (text (list "No markers"
                     (concat pi-edit--start "Missing end")
                     (concat "Missing start" pi-edit--end)
                     (concat pi-edit--start pi-edit--start "Nested"
                             pi-edit--end pi-edit--end)
                     (concat pi-edit--start "Text" pi-edit--end "Outside")))
    (with-temp-buffer
      (insert text)
      (should-error (pi-edit-start) :type 'user-error)
      (should-not pi-edit-mode)
      (should-not pi-edit--markers)
      (should-not (buffer-narrowed-p))
      (should (equal (buffer-string) text)))))

(ert-deftest pi-edit-rejects-preexisting-narrowing ()
  (pi-edit-test--passage "Original"
    (narrow-to-region (point) (+ (point) 3))
    (should-error (pi-edit-start) :type 'user-error)
    (should-not pi-edit-mode)
    (should (equal (buffer-string) "Ori"))
    (should (buffer-narrowed-p))))

(ert-deftest pi-edit-rejects-altered-comment ()
  (pi-edit-test--passage "Original"
    (pi-edit-start)
    (save-restriction
      (widen)
      (goto-char (car pi-edit--markers))
      (delete-char 1))
    (should-error (pi-edit-finish) :type 'user-error)
    (should pi-edit-mode)
    (should (buffer-narrowed-p))
    (should (equal (buffer-string) "Original"))
    (pi-edit-leave)))

(ert-deftest pi-edit-read-only-finish-is-safe ()
  (pi-edit-test--passage "Original"
    (pi-edit-start)
    (setq buffer-read-only t)
    (should-error (pi-edit-finish) :type 'buffer-read-only)
    (should pi-edit-mode)
    (should (buffer-narrowed-p))
    (pi-edit-leave)
    (should (equal (buffer-string)
                   (concat "Before\n" pi-edit--start "Original"
                           pi-edit--end "\nAfter")))))

(ert-deftest pi-edit-start-is-idempotent ()
  (pi-edit-test--passage "Original"
    (pi-edit-start)
    (pi-edit-start)
    (pi-edit-finish)
    (should (equal (buffer-string) "Before\nOriginal\nAfter"))))

(ert-deftest pi-edit-direct-mode-toggle-keeps-comments ()
  (pi-edit-test--passage "Original"
    (let ((original (buffer-string)))
      (pi-edit-mode 1)
      (pi-edit-mode -1)
      (should (equal original (buffer-string)))
      (should-not (buffer-narrowed-p)))))

(ert-deftest pi-edit-finish-requires-active-session ()
  (with-temp-buffer
    (should-error (pi-edit-finish) :type 'user-error)))

;;; pi-edit-test.el ends here
