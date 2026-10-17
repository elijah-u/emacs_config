;; -*- lexical-binding: t; -*-
;; elpaca for package management
(add-to-list 'load-path (concat user-emacs-directory "lisp"))
(require 'elpaca-init)
(elpaca elpaca-use-package
  (elpaca-use-package-mode)
  (setq elpaca-use-package-by-default t))
(elpaca-wait)
;; custom
(use-package no-littering
  :init
  (setq no-littering-etc-directory user-local-tmp-config-dir
        no-littering-var-directory user-local-tmp-data-dir)
  :config
  (no-littering-theme-backups))
(defun edit-init () (interactive) (find-file (concat user-emacs-directory "init.el")))
(setq custom-file (expand-file-name "custom.el" user-local-tmp-config-dir))
(add-hook 'elpaca-after-init-hook (lambda () (load custom-file 'noerror)))
;; prefs
(setq-default indent-tabs-mode nil
              c-basic-indent 2
              c-basic-offset 2
              tab-width 2)
;; evil mode
(use-package evil 
  :demand t 
  :init
  (setq evil-want-integration t
        evil-want-keybinding nil
        evil-want-C-i-jump nil)
  :config (evil-mode 1))
(use-package evil-collection 
  :after evil
  :custom (evil-collection-key-blacklist '("SPC"))
  :config
  (evil-collection-init)
  (evil-collection-buff-menu-setup))
;; shortcuts and hinting
(use-package which-key
  :config (which-key-mode))
(use-package general
  :demand t
  :config 
  (general-evil-setup t)
  (general-define-key
   :states 'normal
   :keymaps 'override
   "," (general-simulate-key "C-c"))
  )
(elpaca-wait)
(use-package key-chord
  :init
  (key-chord-mode 1)
  :general
  (:keymaps 'evil-insert-state-map
            (general-chord "jk") 'evil-normal-state
            (general-chord "kj") 'evil-normal-state)
  :config
  (setq key-chord-two-keys-delay 1))
(elpaca-wait)
;; magit
(use-package magit
  :general
  ("C-c g" 'magit-status)
  ("C-c G" 'magit-file-dispatch))
