;; -*- lexical-binding: t; -*-

;; elpaca for package management
(add-to-list 'load-path (concat user-emacs-directory "lisp"))
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
(setq user-local-config-editable (concat user-emacs-directory "config.org"))
(setq user-local-config-target (concat user-emacs-directory "init.el"))
(defun edit-init () (interactive) (find-file user-local-config-editable))
(setq custom-file (expand-file-name "custom.el" user-local-tmp-config-dir))
(add-hook 'elpaca-after-init-hook (lambda () (load custom-file 'noerror)))

;; prefs
(setq-default indent-tabs-mode nil
              c-basic-indent 2
              c-basic-offset 2
              tab-width 2)
(recentf-mode 1)
(setq recentf-max-menu-items 25)
(setq recentf-max-saved-items 25)

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
  :elpaca nil
  :config
  (setq
   org-src-fontify-natively nil
   org-export-allow-bind-keywords t
   org-directory "~/org"
   org-ellipsis "⤵")
  (org-babel-do-load-languages
   'org-babel-load-languages '((python . t))))

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
  (add-to-list 'yas-snippet-dirs (expand-file-name "snippets" user-local-tmp-config-dir))
  (setq yas-wrap-around-region t)
  (yas-reload-all)
  :init (yas-global-mode +1))

(use-package yasnippet-snippets
  :ensure t)

;; minad packages
(use-package vertico
  :ensure t
  :init
  (vertico-mode))
(use-package savehist
  :elpaca nil
  :init
  (savehist-mode))

(use-package orderless
  :ensure t
  :init
  (setq completion-styles '(orderless basic)
        completion-category-defaults nil
        completion-category-overrides '((file (styles partial-completion)))))

(use-package marginalia
  :ensure t
  :bind (:map minibuffer-local-map
              ("M-A" . marginalia-cycle))
  :init
  (marginalia-mode))

(use-package nerd-icons-completion
  :after marginalia
  :config
  (nerd-icons-completion-mode)
  (add-hook 'marginalia-mode-hook #'nerd-icons-completion-marginalia-setup))

(use-package embark
  :ensure t
  :bind
  (("C-." . embark-act)  ;; pick some comfortable binding
   ("C-;" . embark-dwim)  ;; good alternative: M-.
   ("C-h B" . embark-bindings)) ;; alternative for `describe-bindings'
  :init
;; Optionally replace the key help with a completing-read interface
  (setq prefix-help-command #'embark-prefix-help-command)
;; (add-hook 'eldoc-documentation-functions #'embark-eldoc-first-target)
;; (setq eldoc-documentation-strategy #'eldoc-documentation-compose-eagerly)
  :config
  (add-to-list 'display-buffer-alist
               '("\\`\\*Embark Collect \\(Live\\|Completions\\)\\*"
                 nil
                 (window-parameters (mode-line-format . none)))))

(use-package consult
  :general
  ("C-c b" 'consult-buffer)
  ("C-c m" 'consult-man)
  ("C-c i" 'consult-info)
  ("C-c h" 'consult-history)
  ("C-c M-x" 'consult-mode-command)
  ("M-s d" 'consult-find)
  ("M-s c" 'consult-locate)
  ("M-s g" 'consult-grep)
  ("M-s G" 'consult-git-grep)
  ("M-s r" 'consult-ripgrep)
  ("M-s l" 'consult-line)
  ("M-s L" 'consult-line-multi)
  ("M-s k" 'consult-keep-lines)
  ("M-s u" 'consult-focus-lines)
  ("M-s e" 'consult-isearch-history)
  :hook (completion-list-mode . consult-preview-at-point-mode))

(use-package embark-consult
  :ensure t ; only need to install it, embark loads it after consult if found
  :hook
  (embark-collect-mode . consult-preview-at-point-mode))
(use-package wgrep)

(use-package corfu
  :init
  (global-corfu-mode))
(use-package emacs
  :elpaca nil
  :init
  (setq completion-cycle-threshold 3)
  (setq tab-always-indent 'complete))

;; Add extensions
(use-package cape
;; Bind dedicated completion commands
;; Alternative prefix keys: C-c p, M-p, M-+, ...
  :bind (("C-c p p" . completion-at-point) ;; capf
         ("C-c p t" . complete-tag)  ;; etags
         ("C-c p d" . cape-dabbrev)  ;; or dabbrev-completion
         ("C-c p h" . cape-history)
         ("C-c p f" . cape-file)
         ("C-c p k" . cape-keyword)
         ("C-c p s" . cape-elisp-symbol)
         ("C-c p e" . cape-elisp-block)
         ("C-c p a" . cape-abbrev)
         ("C-c p l" . cape-line)
         ("C-c p w" . cape-dict)
         ("C-c p :" . cape-emoji)
         ("C-c p \\" . cape-tex)
         ("C-c p _" . cape-tex)
         ("C-c p ^" . cape-tex)
         ("C-c p &" . cape-sgml)
         ("C-c p r" . cape-rfc1345))
  :init
;; Add to the global default value of `completion-at-point-functions' which is
;; used by `completion-at-point'.  The order of the functions matters, the
;; first function returning a result wins.  Note that the list of buffer-local
;; completion functions takes precedence over the global list.
  (add-to-list 'completion-at-point-functions #'cape-dabbrev)
  (add-to-list 'completion-at-point-functions #'cape-file)
  (add-to-list 'completion-at-point-functions #'cape-elisp-block)
;;(add-to-list 'completion-at-point-functions #'cape-history)
;;(add-to-list 'completion-at-point-functions #'cape-keyword)
;;(add-to-list 'completion-at-point-functions #'cape-tex)
;;(add-to-list 'completion-at-point-functions #'cape-sgml)
;;(add-to-list 'completion-at-point-functions #'cape-rfc1345)
;;(add-to-list 'completion-at-point-functions #'cape-abbrev)
;;(add-to-list 'completion-at-point-functions #'cape-dict)
;;(add-to-list 'completion-at-point-functions #'cape-elisp-symbol)
;;(add-to-list 'completion-at-point-functions #'cape-line)
  )

;; projects
(use-package projectile
  :init
  (projectile-mode +1)
  :general
  ("C-c p" '(:keymap projectile-command-map :package projectile))
  :bind (:map projectile-mode-map
              ("s-p" . projectile-command-map)
              ("C-c p" . projectile-command-map)))

(use-package ace-window
  :init
  (setq aw-dispatch-always t)
  :general
  ("C-c w" 'ace-window))

(use-package vterm)

(use-package flyspell
  :elpaca nil
  :config
  (setq flyspell-issue-message-flag nil
        ispell-program-name "aspell"
        ispell-extra-args '("--sug-mode=ultra" "--lang=en_US"))
  (add-hook 'text-mode-hook 'flyspell-mode)
  (add-hook 'prog-mode-hook 'flyspell-prog-mode))

;; testing
(use-package mixed-pitch
  :hook
  (text-mode . mixed-pitch-mode))

(use-package seq)
