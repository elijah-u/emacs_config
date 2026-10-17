;;; -*- lexical-bindings: t; -*-
;; elpaca for package management
(add-to-list 'load-path (expand-file-name "lisp/" user-emacs-directory))
(require 'elpaca-init)
(elpaca elpaca-use-package
  (elpaca-use-package-mode)
 (setq elpaca-use-package-by-default t))
(elpaca-wait)

;; cleaner config
(use-package no-littering
  :init
  (setq no-littering-etc-directory user-local-tmp-config-dir
        no-littering-var-directory user-local-tmp-data-dir)
  :config
  (no-littering-theme-backups))
(setq custom-file (expand-file-name "custom.el" user-local-tmp-config-dir))
(add-hook 'elpaca-after-init-hook (lambda () (load custom-file 'noerror)))

(setq help-window-select t) ; Switch to help buffers automatically

(setq user-local-config-editable (expand-file-name "config.org" user-emacs-directory))
(setq user-local-config-target (expand-file-name "init.el" user-emacs-directory))
(defun edit-init () (interactive) (find-file user-local-config-editable))
(defun reload-init () (interactive) (load-file user-local-config-target))

(defun my-org-babel-tangle-config ()
  "Tangle the Emacs configuration files."
  (if (equal buffer-file-name user-local-config-editable)
    (org-babel-tangle)
    (reload-init)))

(add-hook 'after-save-hook 'my-org-babel-tangle-config)

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

(use-package evil-org
  :commands evil-org-mode
  :after org
  :init
  (add-hook 'org-mode-hook 'evil-org-mode)
  :config
  (add-hook 'evil-org-mode-hook
            (lambda ()
              (evil-org-set-key-theme '(textobjects insert navigation additional todo)))))

(use-package org
  :ensure nil
  :config
  (setq
   org-src-fontify-natively nil
   org-export-allow-bind-keywords t
   org-directory "~/org"
   org-ellipsis "⤵")
  (org-babel-do-load-languages
   'org-babel-load-languages
   '((python . t)
     (emacs-lisp . t)
     (shell . t)
     (plantuml . t)
     (lilypond . t)
     ))
  )

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
  (general-define-key
      :keymaps '(normal insert emacs)
      :prefix "SPC"
      :non-normal-prefix "M-SPC"
      "/" 'consult-line
      "e" '(:ignore t :which-key "edit")
      "ei" 'edit-init
      "eR" 'reload-init)
  (general-create-definer my-leader-def
      :prefix "SPC m")
  (my-leader-def
      :keymaps 'normal
      "a" 'org-agenda
      "b" 'consult-bookmark
      "c" 'org-capture)
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

;; transient needed first
(use-package transient)

;; magit
(use-package magit
  :general
  ("C-c g" 'magit-status)
  ("C-c G" 'magit-file-dispatch))

;;  (load-theme 'leuven)
  (use-package solarized-theme
    :config
    (setq solarized-distinct-fringe-background t
          solarized-use-variable-pitch t
          solarized-high-contrast-mode-line t
          solarized-use-more-italic t)
    :init
    (load-theme 'solarized-light :no-confirm))

(setq org-hide-emphasis-markers t)

(font-lock-add-keywords 'org-mode
                        '(("^ *\\([-]\\) "
                           (0 (prog1 () (compose-region (match-beginning 1) (match-end 1) "•"))))))

(use-package org-bullets
  :config
  (add-hook 'org-mode-hook (lambda () (org-bullets-mode 1))))

(setq visual-line-mode 1)

(use-package all-the-icons)
(use-package doom-modeline
  :init (doom-modeline-mode +1))

;; yasnippet
(use-package yasnippet
  :ensure t
  :config
  (add-to-list 'yas-snippet-dirs (make-dir-if-not-there (expand-file-name "snippets" user-local-tmp-config-dir)))
  (setq yas-wrap-around-region t)
  (yas-reload-all)
  :init (yas-global-mode +1))

(use-package yasnippet-snippets
  :ensure t)
