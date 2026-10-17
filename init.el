(add-to-list 'load-path (expand-file-name "lisp/" user-emacs-directory))
(require 'elpaca-init)

(elpaca use-package)
(setq use-package-always-ensure t)

(setq evil-want-integration t
      evil-want-keybinding nil
      evil-want-C-i-jump nil)

(use-package evil
  :config (evil-mode 1))

(use-package evil-collection
  :after evil
  :config
  (setq evil-collection-key-blacklist '("SPC"))
  (evil-collection-init))

(use-package evil-org
  :after org
  :hook (org-mode . evil-org-mode)
  :config (evil-org-set-key-theme '(textobjects insert navigation additional todo)))

(use-package key-chord
  :config
  (setq key-chord-two-keys-delay 0.5)
  (key-chord-mode 1)
  (key-chord-define evil-insert-state-map "jk" 'evil-normal-state)
  (key-chord-define evil-insert-state-map "kj" 'evil-normal-state))

(use-package general
  :config
  (general-create-definer leader-key
    :states '(normal visual emacs insert)
    :prefix "SPC"
    :non-normal-prefix "M-SPC")
  (leader-key
    "/" '(consult-line :which-key "search buffer")
    "e" '(:ignore t :which-key "edit")
    "e i" '(lambda () (interactive) (find-file (expand-file-name "config.org" user-emacs-directory)))
    "m" '(:ignore t :which-key "misc/org")
    "m a" '(org-agenda :which-key "agenda")
    "m c" '(org-capture :which-key "capture")))

(use-package which-key
  :config (which-key-mode))

(use-package vertico
  :init (vertico-mode))

(use-package marginalia
  :init (marginalia-mode))

(use-package orderless
  :custom (completion-styles '(orderless basic)))

(use-package nerd-icons-completion
  :config (nerd-icons-completion-mode))

(use-package consult)

(use-package org
  :elpaca nil
  :config
  (setq org-directory "~/org"
        org-ellipsis "⤵"
        org-export-allow-bind-keywords t
        org-src-fontify-natively t)
  (org-babel-do-load-languages
   'org-babel-load-languages
   '((emacs-lisp . t)
     (python . t)
     (shell . t)
     (plantuml . t)
     (lilypond . t))))

(use-package org-modern
  :hook (org-mode . global-org-modern-mode)
  :config
  (setq org-modern-label-border 0.3))

(defun org-babel-tangle-config ()
  (when (string-equal (buffer-file-name)
                      (expand-file-name "config.org" user-emacs-directory))
    (org-babel-tangle)
    (load-file (expand-file-name "init.el" user-emacs-directory))
    (elpaca-process-queues)))

(add-hook 'org-mode-hook
          (lambda ()
            (add-hook 'after-save-hook #'org-babel-tangle-config nil t)))

(setq org-confirm-babel-evaluate nil)
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
