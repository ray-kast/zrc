;;; init.el -- my emacs config -*- lexical-binding: t -*-
;;; Commentary:
;;; itse my Emacs config :3

;;; Code:

;; Packages

(require 'package)
(add-to-list 'package-archives '("melpa" . "https://melpa.org/packages/") t)

(require 'use-package-ensure)
(setq use-package-always-ensure t)

(use-package auto-package-update
  :defer 1
  :init
  (setq auto-package-update-delete-old-versions t
	auto-package-update-interval 7)
  :hook (auto-package-update-after . (lambda ()
				       (mapc #'treesit-install-language-grammar (mapcar #'car treesit-language-source-alist))))
  :config
  (auto-package-update-maybe))

;; Global stuff

(use-package avy
  :defer nil
  :bind (("C-'" . avy-goto-char-2)))

(use-package company
  :init
  (setq company-minimum-prefix-length 1
	company-idle-delay 0.3)
  :hook ((after-init . global-company-mode)))

(use-package desktop+
  :defer nil
  :bind (("C-x w l" . desktop+-load)
	 ("C-x w c" . desktop+-create)))

(use-package counsel
  :after (ivy swiper)
  :config
  (counsel-mode))

(use-package display-line-numbers
  :init
  (setq display-line-numbers-type 'relative)
  :config
  (global-display-line-numbers-mode))

(use-package eglot
  :after (project)
  :init
  (setq eglot-autoshutdown t)
  :config
  (add-to-list 'eglot-server-programs
	       `((python-mode python-ts-mode) .
		 (lambda (inter proj)
		   (let ((project-dir (project-root proj)))
		     (eglot-alternatives `(("uv" "run" "--project" ,project-dir "-wpython-lsp-server[all],python-lsp-ruff" "pylsp")
					   (,(getenv "SHELL") "-lc" "uv run --project \"$1\" -w'python-lsp-server[all],python-lsp-ruff' pylsp" "--" ,project-dir)))))))
  :hook ((c-ts-mode c++-ts-mode python-ts-mode rust-ts-mode) . eglot-ensure))

(use-package evil
  :after (avy undo-fu)
  :init
  (setq evil-want-integration t
	evil-want-keybinding nil
	evil-want-C-u-scroll t
	evil-undo-system 'undo-fu)
  :config
  (evil-mode 1))

(use-package evil-collection
  :after (evil)
  :config
  (evil-collection-init))

(use-package flycheck
  :hook (after-init . global-flycheck-mode))

(use-package flycheck-eglot
  :after (flycheck eglot)
  :config
  (global-flycheck-eglot-mode 1))

(use-package ivy
  :after (avy)
  :config
  (ivy-mode))

(use-package magit)

(use-package project
  :config
  (defun +project-try-bny (dir)
    "Perform an ancestor search starting at DIR for project manifest files."
    (when-let* ((found
		 (condition-case nil
		     (locate-dominating-file dir (lambda (d)
						   (directory-files
						    d nil
						    (rx string-start
							(or "compile_commands.json"
							    "pyproject.toml")
							string-end))))
		   (file-missing nil))))
      (cons 'bny found)))

  (cl-defmethod project-root ((project (head bny)))
    "Get the project root for PROJECT, if located by (+project-try-bny)."
    (cdr project))

  (add-hook 'project-find-functions #'+project-try-bny -1337))

(use-package swiper
  :after (ivy evil)
  :bind (([remap isearch-forward] . swiper-isearch)
	 ([remap evil-search-forward] . swiper-isearch)
	 ([remap isearch-backward] . swiper-isearch-backward)
	 ([remap evil-search-backward] . swiper-isearch-backward)))

(use-package tramp)

(use-package treesit-fold
  :config
  (global-treesit-fold-mode))

(use-package undo-fu)

(use-package which-key
  :after (evil evil-collection)
  :init
  (setq which-key-idle-delay 0.5)
  :config
  (which-key-mode))

(use-package yasnippet
  :config
  (yas-global-mode 1))

;; Misc. Config

(use-package emacs
  :after (tramp desktop+)

  :init
  (setq project-mode-line t

	backup-by-copying t
	custom-file "~/.config/emacs/custom.el"
	delete-old-versions t
	version-control t
	kept-new-versions 6
	kept-old-versions 2

	treesit-language-source-alist '((c "https://github.com/tree-sitter/tree-sitter-c")
					(cpp "https://github.com/tree-sitter/tree-sitter-cpp")
					(python "https://github.com/tree-sitter/tree-sitter-python")
					(rust "https://github.com/tree-sitter/tree-sitter-rust"))
	major-mode-remap-alist (append (eval major-mode-remap-alist)
				       '((c-mode . c-ts-mode)
					 (c++-mode . c++-ts-mode)
					 (python-mode . python-ts-mode)
					 (rust-mode . rust-ts-mode))))

  :config
  (let ((auto-save-dir "~/.local/state/emacs/auto-saves/")
	(backup-dir "~/.local/state/emacs/backups/")
	(lock-dir "~/.local/state/emacs/locks/")
	(desktop-dir "~/.local/state/emacs/desktops/"))

    (dolist (dir (list auto-save-dir backup-dir lock-dir desktop-dir))
      (when (not (file-directory-p dir))
	(make-directory dir t)))

    (setq auto-save-file-name-transforms `((".*" ,auto-save-dir t))
	  auto-save-list-file-prefix (concat auto-save-dir ".saves-")
	  tramp-auto-save-directory auto-save-dir

	  backup-directory-alist `((".*" . ,backup-dir))
	  tramp-backup-directory-alist `((".*" . ,backup-dir))

	  lock-file-name-transforms `((".*" ,lock-dir t))

	  desktop+-base-dir desktop-dir))

  (load-theme 'tango-dark))

;;; init.el ends here
