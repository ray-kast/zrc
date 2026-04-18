;;; early-init.el -- my emacs early init -*- lexical-binding: t -*-
;;; Commentary:
;;; itse my Emacs config :3

;;; Code:

(when-let* ((libs
	     (condition-case nil
		 (directory-files-recursively "/opt/local/lib" (rx (or ".a" ".o" ".so") string-end) nil
					      (lambda (d) (string-match-p
							   (rx (or "/" "\\")
							       "gcc"
							       (one-or-more digit)
							       (or "/" "\\" string-end))
							   d)))
	       (file-missing nil)))
	    (path (string-join (delete-dups (mapcar #'file-name-parent-directory libs)) ":")))
  (setenv "LIBRARY_PATH" path))

(require 'cl-seq)
(dolist (path
	 `("/usr/lib/rustup/bin"
	   "/opt/local/bin"
	   ,(expand-file-name "~/.cargo/bin")))
  (when (and
	 (not (cl-member path exec-path))
	 (file-directory-p path))
    (setq exec-path (cons path exec-path))))

;;; early-init.el ends here
