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
  :init
  (setq auto-package-update-delete-old-versions t
	auto-package-update-interval 7)
  :config
  (auto-package-update-maybe))

(use-package undo-fu)

;; Global stuff

(use-package company
  :init
  (setq ;; company-backends '((company-capf))
	company-minimum-prefix-length 1
	company-idle-delay 0.3)
  :hook ((after-init . global-company-mode)))

(use-package desktop
  :init
  (setq desktop-path `("." "~/.config/emacs/" "~"))
  :config
  (desktop-save-mode 1))

(use-package display-line-numbers
  :init
  (setq display-line-numbers-type 'relative)
  :config
  (global-display-line-numbers-mode))

(use-package evil
  :after (undo-fu)
  :init
  (setq evil-undo-system 'undo-fu)
  :config
  (evil-mode 1))

(use-package flycheck
  :hook ((after-init . global-flycheck-mode)))

(use-package lsp-mode
  :after (lsp-ui)
  :init
  (setq lsp-inlay-hint-enable t
	lsp-keymap-prefix 'M-l)
  :bind-keymap ("M-l" . lsp-command-map)
  :hook ((lsp-mode . (lambda ()
		       (let ((lsp-keymap-prefix "M-l"))
			 (lsp-enable-which-key-integration))))))

(use-package lsp-ui)

(use-package tramp)

(use-package which-key
  :after (evil)
  :init
  (setq which-key-idle-delay 0.5)
  :config
  (which-key-mode))

;; Languages

(use-package rustic
  :after (lsp-mode))

;; Misc. Config

(require 'tramp)
(let ((auto-save-dir "~/.local/state/emacs/auto-saves/")
      (backup-dir "~/.local/state/emacs/backups/")
      (lock-dir "~/.local/state/emacs/locks/"))

  (dolist (dir (list auto-save-dir backup-dir lock-dir))
    (when (not (file-directory-p dir))
      (make-directory dir t)))

  (setq auto-save-file-name-transforms `((".*" ,auto-save-dir t))
	auto-save-list-file-prefix (concat auto-save-dir ".saves-")
	tramp-auto-save-directory auto-save-dir

	backup-directory-alist `((".*" . ,backup-dir))
	tramp-backup-directory-alist `((".*" . ,backup-dir))

	lock-file-name-transforms `((".*" ,lock-dir t))))

(setq backup-by-copying t
      delete-old-versions t
      version-control t
      kept-new-versions 6
      kept-old-versions 2)

(load-theme 'tango-dark)

(custom-set-variables
 ;; custom-set-variables was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(package-selected-packages nil))
(custom-set-faces
 ;; custom-set-faces was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 )
