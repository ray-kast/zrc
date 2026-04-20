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
  :custom
  (auto-package-update-delete-old-versions t)
  (auto-package-update-interval 7)
  :hook (auto-package-update-after . (lambda ()
				       (mapc #'treesit-install-language-grammar (mapcar #'car treesit-language-source-alist))))
  :config
  (auto-package-update-maybe))

;; Global stuff

(use-package affe
  :after (consult orderless)
  :bind (("M-p" . affe-find)
	 ("C-M-p" . affe-grep))
  :init
  (defun +affe-orderless-regexp-compiler (input _type _ignorecase)
    (setq input (cdr (orderless-compile input)))
    (cons input (apply-partially #'orderless--highlight input t)))

  (let ((path (locate-file "rg" exec-path)))
   (setq affe-find-command (concat path " --color=never --files")
	 affe-grep-command (concat path " --null --color=never --max-columns=1000 --no-heading --line-number -v ^$")
	 affe-regexp-compiler #'+affe-orderless-regexp-compiler)))

(use-package avy
  :defer nil
  :custom
  (avy-timeout-seconds 0.2)
  :bind (("C-'" . evil-avy-goto-char-timer)
	 ("C-c '" . evil-avy-goto-char-timer)
	 :map evil-normal-state-map
	 ("s" . evil-avy-goto-char-timer)
	 :map evil-motion-state-map
	 ("s" . evil-avy-goto-char-timer)))

(use-package cape
  :after (corfu)
  :bind ("C-c p" . cape-prefix-map)
  :init
  (add-hook 'completion-at-point-functions #'cape-dabbrev)
  (add-hook 'completion-at-point-functions #'cape-file)
  (add-hook 'completion-at-point-functions #'cape-elisp-block))

(use-package corfu
  :after (vertico)
  :custom
  (corfu-auto t)
  (corfu-quit-no-match t)
  (corfu-quit-at-boundary 'separator)
  :config
  (require 'corfu-auto)
  (require 'corfu-echo)
  (require 'corfu-history)
  (global-corfu-mode)
  (corfu-echo-mode)
  (with-eval-after-load 'savehist
    (corfu-history-mode)))

(if (and (version< emacs-version "31")
	 (not (display-graphic-p)))
    (use-package corfu-terminal
      :after (corfu)
      :config
      (corfu-terminal-mode)))

(use-package consult
  :defer 0

  :bind (;; C-c bindings in `mode-specific-map'
	 ("C-c x" . consult-mode-command)
	 ("C-c h" . consult-history)
	 ("C-c k" . consult-kmacro)
	 ("C-c m" . consult-man)
	 ("C-c i" . consult-info)
	 ([remap Info-search] . consult-info)
	 ;; C-x bindings in `ctl-x-map'
	 ("C-x M-:" . consult-complex-command)     ;; orig. repeat-complex-command
	 ("C-x b" . consult-buffer)                ;; orig. switch-to-buffer
	 ("C-x 4 b" . consult-buffer-other-window) ;; orig. switch-to-buffer-other-window
	 ("C-x 5 b" . consult-buffer-other-frame)  ;; orig. switch-to-buffer-other-frame
	 ("C-x t b" . consult-buffer-other-tab)    ;; orig. switch-to-buffer-other-tab
	 ("C-x r b" . consult-bookmark)            ;; orig. bookmark-jump
	 ("C-x p b" . consult-project-buffer)      ;; orig. project-switch-to-buffer
	 ;; Custom M-# bindings for fast register access
	 ("M-#" . consult-register-load)
	 ("M-'" . consult-register-store)          ;; orig. abbrev-prefix-mark (unrelated)
	 ("C-M-#" . consult-register)
	 ;; Other custom bindings
	 ("M-y" . consult-yank-pop)                ;; orig. yank-pop
	 ;; M-g bindings in `goto-map'
	 ("M-g e" . consult-compile-error)
	 ("M-g r" . consult-grep-match)
	 ("M-g f" . consult-flymake)               ;; Alternative: consult-flycheck
	 ("M-g g" . consult-goto-line)             ;; orig. goto-line
	 ("M-g M-g" . consult-goto-line)           ;; orig. goto-line
	 ("M-g o" . consult-outline)               ;; Alternative: consult-org-heading
	 ("M-g m" . consult-mark)
	 ("M-g k" . consult-global-mark)
	 ("M-g i" . consult-imenu)
	 ("M-g I" . consult-imenu-multi)
	 ;; M-s bindings in `search-map'
	 ("M-s d" . consult-find)                  ;; Alternative: consult-fd
	 ("M-s c" . consult-locate)
	 ("M-s g" . consult-grep)
	 ("M-s G" . consult-git-grep)
	 ("M-s r" . consult-ripgrep)
	 ("M-s l" . consult-line)
	 ("M-s L" . consult-line-multi)
	 ("M-s k" . consult-keep-lines)
	 ("M-s u" . consult-focus-lines)
	 ;; Isearch integration
	 ("M-s e" . consult-isearch-history)
	 :map isearch-mode-map
	 ("M-e" . consult-isearch-history)         ;; orig. isearch-edit-string
	 ("M-s e" . consult-isearch-history)       ;; orig. isearch-edit-string
	 ("M-s l" . consult-line)                  ;; needed by consult-line to detect isearch
	 ("M-s L" . consult-line-multi)            ;; needed by consult-line to detect isearch
	 ;; Minibuffer history
	 :map minibuffer-local-map
	 ("M-s" . consult-history)                 ;; orig. next-matching-history-element
	 ("M-r" . consult-history))

  :custom
  (register-preview-delay 0.5)
  (xref-show-xrefs-function #'consult-xref)
  (xref-show-definitions-function #'consult-xref)

  :init
  (advice-add #'register-preview :override #'consult-register-window)

  :config
  (consult-customize
   consult-theme :preview-key '(:debounce 0.2 any)
   consult-ripgrep consult-git-grep consult-grep consult-man
   consult-bookmark consult-recent-file consult-xref
   consult-source-bookmark consult-source-file-register
   consult-source-recent-file consult-source-project-recent-file
   :preview-key '(:debounce 0.4 any))

  (setq consult-narrow-key "<"))

(use-package consult-eglot
  :after (consult eglot))

(use-package consult-yasnippet
  :after (consult eglot yasnippet))

(use-package desktop+
  :defer nil
  :bind (("C-x w l" . desktop+-load)
	 ("C-x w c" . desktop+-create)))

(use-package display-line-numbers
  :init
  (setq display-line-numbers-type 'relative)
  :config
  (global-display-line-numbers-mode))

(use-package eat
  :hook ((eshell-load . eat-eshell-mode))
  :bind (("C-c t" . eat))
  :commands (eat))

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

(use-package embark
  :bind (("C-c ." . embark-act)
	 ("C-c C-." . embark-act)
	 ("C-c ;" . embark-dwim)
	 ("C-c C-;" . embark-dwim)
	 ("C-h B" . embark-bindings))
  :config
  (setq prefix-help-command #'embark-prefix-help-command)
  (add-to-list 'display-buffer-alist
               '("\\`\\*Embark Collect \\(Live\\|Completions\\)\\*"
                 nil
                 (window-parameters (mode-line-format . none)))))

(use-package embark-consult)

(use-package evil
  :after (avy undo-fu)
  :init
  (setq evil-echo-state nil
	evil-move-beyond-eol t
	evil-want-integration t
	evil-want-keybinding nil
	evil-want-C-w-delete nil
	evil-want-C-u-scroll t
	evil-undo-system 'undo-fu)
  :config
  (evil-mode 1))

(use-package evil-args
  :after (evil evil-collection)
  :bind (:map evil-inner-text-objects-map
	 ("a" . evil-inner-arg)
	 :map evil-outer-text-objects-map
	 ("a" . evil-outer-arg)
	 :map evil-normal-state-map
	 ("g l" . evil-forward-arg)
	 ("g h" . evil-backward-arg)
	 ("g a" . evil-jump-out-args)
	 :map evil-motion-state-map
	 ("g l" . evil-forward-arg)
	 ("g h" . evil-backward-arg)))

(use-package evil-cleverparens
  :after (evil evil-collection smartparens)
  :custom
  (evil-cleverparens-use-additional-movement-keys nil)
  :hook (smartparens-mode . evil-cleverparens-mode))

(use-package evil-collection
  :after (evil)
  :config
  (evil-collection-init))

(use-package evil-commentary
  :after (evil evil-collection)
  :config
  (evil-commentary-mode))

(use-package evil-exchange
  :after (evil evil-collection)
  :config
  (evil-exchange-install))

(use-package evil-indent-plus
  :after (evil evil-collection)
  :bind (:map evil-inner-text-objects-map
	 ("i" . evil-indent-plus-i-indent)
	 ("I" . evil-indent-plus-i-indent-up)
	 ("J" . evil-indent-plus-i-indent-up-down)
	 :map evil-outer-text-objects-map
	 ("i" . evil-indent-plus-a-indent)
	 ("I" . evil-indent-plus-a-indent-up)
	 ("J" . evil-indent-plus-a-indent-up-down)))

(use-package evil-matchit
  :after (evil evil-collection)
  :config
  (global-evil-matchit-mode 1))

(use-package evil-mc
  :after (evil evil-collection)
  :config
  (global-evil-mc-mode 1))

(use-package evil-numbers
  :after (evil evil-collection)
  :bind (:map evil-normal-state-map
	 ("g =" . evil-numbers/inc-at-pt)
	 ("g -" . evil-numbers/dec-at-pt)
	 ("g M-=" . evil-numbers/inc-at-pt-incremental)
	 ("g M--" . evil-numbers/dec-at-pt-incremental)))

(use-package evil-org
  :after (evil evil-collection)
  :hook (org-mode . evil-org-mode)
  :config
  (require 'evil-org-agenda)
  (evil-org-agenda-set-keys))

(use-package evil-surround
  :after (evil evil-collection)
  :config
  (global-evil-surround-mode))

(use-package evil-vimish-fold
  :after (vimish-fold)
  :hook ((prog-mode conf-mode text-mode) . evil-vimish-fold-mode))

(use-package flymake
  :custom
  (flymake-show-diagnostics-at-end-of-line t)
  :bind ("C-c k" . flymake-show-project-diagnostics)
  :hook ((prog-mode text-mode) . flymake-mode))

(use-package kind-icon
  :after (corfu)
  :config
  (add-to-list 'corfu-margin-formatters #'kind-icon-margin-formatter))

(use-package magit)

(use-package marginalia
  :config
  (marginalia-mode))

(use-package orderless
  :after (embark)
  :custom
  (orderless-component-separator #'orderless-escapable-split-on-space)
  (completion-styles '(orderless basic))
  (completion-category-overrides '((file (styles partial-completion))))
  (completion-category-defaults nil)
  (completion-pcm-leading-wildcard t))

(use-package org-modern
 :after (org)
 :config
 (global-org-modern-mode))

(use-package popper
  :bind (("C-c o" . popper-toggle)
	 ("C-c C-o" . popper-toggle)
	 ("C-c O" . popper-toggle-type)
	 ("C-c M-o" . popper-cycle))
  :custom
  (popper-reference-buffers
   '("\\*Messages\\*"
     "Output\\*"
     "\\*Async Shell Command\\*"
     help-mode
     compilation-mode))
  :config
  (popper-mode)
  (popper-echo-mode))

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

(use-package projectile
  :defer nil
  :bind (:map projectile-mode-map
	 ("C-c r" . projectile-command-map))
  :custom
  (projectile-fd-executable (locate-file "fd" exec-path))
  :config
  (projectile-mode))

(use-package rustic
  :after (emacs))

(use-package savehist
  :config
  (savehist-mode))

(use-package smartparens
  :after (evil evil-collection)
  :hook ((prog-mode text-mode markdown-mode) . smartparens-strict-mode)
  :config
  (require 'smartparens-config))

(use-package tramp)

(use-package treesit-fold
  :config
  (global-treesit-fold-mode))

(use-package undo-fu)

(use-package vertico
  :custom
  (vertico-resize nil)
  (vertico-cycle t)
  (vertico-multiform-commands
   '((consult-line buffer)
     (consult-imenu reverse buffer)
     (execute-extended-command (:keymap "X" execute-extended-command-for-buffer))))
  (vertico-multiform-categories
   '((file (:keymap . vertico-directory-map))
     (imenu (:not indexed mouse))
     (symbol (vertico-sort-function . vertico-sort-alpha))))
  :defer nil
  :hook (rfn-eshadow-update-overlay . vertico-directory-tidy)
  :config
  (vertico-mode)
  (vertico-multiform-mode))

(use-package vimish-fold
  :after (evil evil-collection))

(use-package yasnippet
  :config
  (yas-global-mode 1))

;; Misc. Config

(use-package emacs
  :after (tramp desktop+)

  :custom
  (backup-by-copying t)
  (custom-file "~/.config/emacs/custom.el")
  (delete-old-versions t)
  (version-control t)
  (kept-new-versions 6)
  (kept-old-versions 2)

  (enable-recursive-minibuffers t)
  (project-mode-line t)
  (context-menu-mode t)
  (read-extended-command-predicate #'command-completion-default-include-p)
  (minibuffer-prompt-properties '(read-only t cursor-intangible t face minibuffer-prompt))

  (tab-always-indent 'complete)
  (text-mode-ispell-word-completion nil)

  (org-fold-catch-invisible-edits 'show-and-error)
  (org-special-ctrl-a/e t)
  (org-insert-heading-respect-content t)
  (org-pretty-entities t)
  (org-ellipsis "…")

  (treesit-language-source-alist '((c "https://github.com/tree-sitter/tree-sitter-c")
				   (cpp "https://github.com/tree-sitter/tree-sitter-cpp")
				   (python "https://github.com/tree-sitter/tree-sitter-python")
				   (rust "https://github.com/tree-sitter/tree-sitter-rust")))

  (major-mode-remap-alist (append (eval major-mode-remap-alist)
				       '((c-mode . c-ts-mode)
					 (c++-mode . c++-ts-mode)
					 (python-mode . python-ts-mode)
					 (rust-mode . rust-ts-mode)
					 (rustic-mode . rust-ts-mode))))

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

  (menu-bar-mode -1)
  (tool-bar-mode -1)
  (load-theme 'tango-dark))

;;; init.el ends here
