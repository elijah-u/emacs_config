;; -*- lexical-binding: t; -*-
;; elpaca for package management
;;(add-to-list 'load-path (concat user-emacs-directory "lisp"))
;;(require 'elpaca-init)
(defvar elpaca-installer-version 0.11)
(defvar elpaca-directory (expand-file-name "elpaca/" user-emacs-directory))
(defvar elpaca-builds-directory (expand-file-name "builds/" elpaca-directory))
(defvar elpaca-repos-directory (expand-file-name "repos/" elpaca-directory))
(defvar elpaca-order '(elpaca :repo "https://github.com/progfolio/elpaca.git"
                              :ref nil :depth 1 :inherit ignore
                              :files (:defaults "elpaca-test.el" (:exclude "extensions"))
                              :build (:not elpaca--activate-package)))
(let* ((repo  (expand-file-name "elpaca/" elpaca-repos-directory))
       (build (expand-file-name "elpaca/" elpaca-builds-directory))
       (order (cdr elpaca-order))
       (default-directory repo))
  (add-to-list 'load-path (if (file-exists-p build) build repo))
  (unless (file-exists-p repo)
    (make-directory repo t)
    (when (<= emacs-major-version 28) (require 'subr-x))
    (condition-case-unless-debug err
        (if-let* ((buffer (pop-to-buffer-same-window "*elpaca-bootstrap*"))
                  ((zerop (apply #'call-process `("git" nil ,buffer t "clone"
                                                  ,@(when-let* ((depth (plist-get order :depth)))
                                                      (list (format "--depth=%d" depth) "--no-single-branch"))
                                                  ,(plist-get order :repo) ,repo))))
                  ((zerop (call-process "git" nil buffer t "checkout"
                                        (or (plist-get order :ref) "--"))))
                  (emacs (concat invocation-directory invocation-name))
                  ((zerop (call-process emacs nil buffer nil "-Q" "-L" "." "--batch"
                                        "--eval" "(byte-recompile-directory \".\" 0 'force)")))
                  ((require 'elpaca))
                  ((elpaca-generate-autoloads "elpaca" repo)))
            (progn (message "%s" (buffer-string)) (kill-buffer buffer))
          (error "%s" (with-current-buffer buffer (buffer-string))))
      ((error) (warn "%s" err) (delete-directory repo 'recursive))))
  (unless (require 'elpaca-autoloads nil t)
    (require 'elpaca)
    (elpaca-generate-autoloads "elpaca" repo)
    (let ((load-source-file-function nil)) (load "./elpaca-autoloads"))))
(add-hook 'after-init-hook #'elpaca-process-queues)
(elpaca `(,@elpaca-order))

(elpaca elpaca-use-package
  (elpaca-use-package-mode)
  (setq elpaca-use-package-by-default t))
(elpaca-wait)
;; custom
(defmacro use-feature (name &rest args)
  "Like `use-package' but accounting for asynchronous installation.
  NAME and ARGS are in `use-package'."
  (declare (indent defun))
  `(use-package ,name
     :ensure nil
     ,@args))

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
;; magit
(use-package transient)
(use-package magit
  :after transient
  :general
  ("C-c g" 'magit-status)
  ("C-c G" 'magit-file-dispatch))
(use-package org-bullets
  :config
  (add-hook 'org-mode-hook (lambda () (org-bullets-mode 1))))

(setq visual-line-mode 1)

(use-package all-the-icons)
(use-package vertico
  :ensure t
  :init
  (vertico-mode))

(use-feature savehist
  :init
  (savehist-mode))

(use-package orderless
  :ensure t
  :init
  (setq completion-styles '(orderless basic)
        completion-category-defaults nil
        Completion-category-overrides '((file (styles partial-completion)))))

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

(use-package corfu
  :init
  (global-corfu-mode))

(use-feature emacs
  :init
  (setq completion-cycle-threshold 3)
  (setq tab-always-indent 'complete))
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

(use-feature flyspell
  :config
  (setq flyspell-issue-message-flag nil
        ispell-program-name "aspell"
        ispell-extra-args '("--sug-mode=ultra" "--lang=en_US"))
  (add-hook 'text-mode-hook 'flyspell-mode)
  (add-hook 'prog-mode-hook 'flyspell-prog-mode))

(use-package dired
  :ensure nil
  :config
  (setq dired-listing-switches
        "-l --almost-all --human-readable --group-directories-first --no-group")
  ;; this command is useful when you want to close the window of `dirvish-side'
  ;; automatically when opening a file
  (put 'dired-find-alternate-file 'disabled nil))

(use-package nerd-icons)

(use-package dirvish
  :ensure t
  :init
  (dirvish-override-dired-mode)
  :custom
  (dirvish-quick-access-entries ; It's a custom option, `setq' won't work
   '(("h" "~/"                          "Home")
     ("d" "~/Downloads/"                "Downloads")
     ;; ("m" "/mnt/"                       "Drives")
     ;; ("s" "/ssh:my-remote-server")      "SSH server"
     ;; ("e" "/sudo:root@localhost:/etc")  "Modify program settings"
     ;;("t" "~/.local/share/Trash/files/" "TrashCan"))
     ))
  :config
  ;; (dirvish-peek-mode)             ; Preview files in minibuffer
  ;; (dirvish-side-follow-mode)      ; similar to `treemacs-follow-mode'
  (setq dirvish-mode-line-format
        '(:left (sort symlink) :right (omit yank index)))
  (setq dirvish-attributes           ; The order *MATTERS* for some attributes
        '(vc-state subtree-state nerd-icons collapse git-msg file-time file-size)
        dirvish-side-attributes
        '(vc-state nerd-icons collapse file-size))
  (setq dired-mouse-drag-files t)
  (setq mouse-drag-and-drop-region-cross-program t)
  :general ;; Bind `dirvish-fd|dirvish-side|dirvish-dwim' as you see fit
  ("C-c f"  'dirvish)
  (:keymaps 'dirvish-mode-map         ;; Dirvish inherits `dired-mode-map'
   :states '(normal motion)           ;; evil
    ";"   #'dired-up-directory        ;; So you can adjust `dired' bindings here
    "?"   #'dirvish-dispatch          ;; [?] a helpful cheatsheet
    "a"   #'dirvish-setup-menu        ;; [a]ttributes settings:`t' toggles mtime, `f' toggles fullframe, etc.
    "f"   #'dirvish-file-info-menu    ;; [f]ile info
    "o"   #'dirvish-quick-access      ;; [o]pen `dirvish-quick-access-entries'
    "s"   #'dirvish-quicksort         ;; [s]ort flie list
    "r"   #'dirvish-history-jump      ;; [r]ecent visited
    "l"   #'dirvish-ls-switches-menu  ;; [l]s command flags
    "v"   #'dirvish-vc-menu           ;; [v]ersion control commands
    "*"   #'dirvish-mark-menu
    "y"   #'dirvish-yank-menu
    "N"   #'dirvish-narrow
    "^"   #'dirvish-history-last
    "TAB" #'dirvish-subtree-toggle
    "M-f" #'dirvish-history-go-forward
    "M-b" #'dirvish-history-go-backward
    "M-e" #'dirvish-emerge-menu))

