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

;; (use-package desktop
;;   :init
;;   (setq desktop-path `("." "~/.config/emacs/" "~"))
;;   :config
;;   (desktop-save-mode 1))

(use-package counsel
  :after (ivy swiper)
  :config
  (counsel-mode))

(use-package display-line-numbers
  :init
  (setq display-line-numbers-type 'relative)
  :config
  (global-display-line-numbers-mode))

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
  :hook ((after-init . global-flycheck-mode)))

(use-package ivy
  :after (avy)
  :config
  (ivy-mode))

(use-package lsp-mode
  :after (lsp-ivy lsp-ui)
  :init
  (setq lsp-inlay-hint-enable t
	lsp-keymap-prefix 'M-l)
  :custom
  (lsp-rust-analyzer-binding-mode-hints t)
  (lsp-rust-analyzer-call-info-full t)
  (lsp-rust-analyzer-closure-capture-hints t)
  (lsp-rust-analyzer-closure-return-type-hints "always")
  (lsp-rust-analyzer-discriminants-hints "always")
  (lsp-rust-analyzer-chaining-hints t)
  (lsp-rust-analyzer-display-closure-return-type-hints nil)
  (lsp-rust-analyzer-display-lifetime-elision-hints-enable "always")
  (lsp-rust-analyzer-display-lifetime-elision-hints-use-parameter-names nil)
  (lsp-rust-analyzer-display-parameter-hints t)
  (lsp-rust-analyzer-display-reborrow-hints "always")
  (lsp-rust-analyzer-expression-adjustment-hints "always")
  (lsp-rust-analyzer-max-inlay-hint-length 20)
  :bind-keymap ("M-l" . lsp-command-map)
  :hook ((lsp-mode . (lambda ()
		       (let ((lsp-keymap-prefix "M-l"))
			 (lsp-enable-which-key-integration))))))

(use-package lsp-ivy
  :after (ivy))

(use-package lsp-ui)

(use-package swiper
  :after (ivy evil)
  :bind (([remap isearch-forward] . swiper-isearch)
	 ([remap evil-search-forward] . swiper-isearch)
	 ([remap isearch-backward] . swiper-isearch-backward)
	 ([remap evil-search-backward] . swiper-isearch-backward)))

(use-package tramp)

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

;; Languages

(use-package rustic
  :after (lsp-mode))

;; Misc. Config

(require 'tramp)
(require 'desktop+)
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
