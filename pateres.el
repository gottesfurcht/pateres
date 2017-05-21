(require 'greek)

(defvar pateres-url "http://www.imgap.gr/file1/AG-Pateres/AG%20KeimenoMetafrasi/KD/")

(defun pateres (document gr en)
  (with-temp-buffer
    (let* ((output-buffer (buffer-name))
           (chap " [0-9]+[ ]*$\\|^[ ]+$")
           (ref (concat "^.?" gr " \\([0-9]+\\) ?,\\([0-9]+\\)[  —]+")))
      (with-temp-buffer
        (url-insert-file-contents (concat pateres-url document))
        (let ((default-process-coding-system 'windows-1253)
              (coding-system-for-read 'utf-8)
              (coding-system-for-write 'windows-1253))
          (shell-command-on-region (point-min) (point-max) "html2text" output-buffer)))
        (goto-char (point-min))
        (push-mark)
        (re-search-forward chap nil t)
        (beginning-of-line)
        (delete-region (point) (mark))
        (save-excursion
          (while (re-search-forward chap nil t)
            (kill-whole-line)))
        (save-excursion
          (while (re-search-forward ref nil t)
            (replace-match (concat "$$$" en " \\1:\\2\n"))
            (when (re-search-forward ref nil t)
              (beginning-of-line)
              (push-mark)
              (if (re-search-forward ref nil t 2)
                  (progn (beginning-of-line)
                         (delete-region (point) (mark)))
                (re-search-forward ref nil t)
                (beginning-of-line)
                (delete-region (point) (point-max))))))
        (write-file (concat en ".imp")))))

(pateres "01. Math.htm" "Ματθ." "Matthew")
(pateres "02. Mark.htm" "Μαρκ." "Mark")
;; TODO fix Luke:
;; (pateres "03. Louk.htm" "Λουκ." "Luke")
(pateres "04. Ioan.htm" "Ιω." "John")

