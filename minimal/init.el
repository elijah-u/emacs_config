;; elpaca for package management
(load "./elpaca-init.el")
(elpaca elpaca-use-package
  (elpaca-use-package-mode)
  (setq elpaca-use-package-by-default t))
(elpaca-wait)
(defun edit-init () (interactive) (find-file (concat user-emacs-directory "init.el")))
(setq custom-file (expand-file-name "customs.el" user-emacs-directory))
(add-hook 'elpaca-after-init-hook (lambda () (load custom-file 'noerror)))
;; evil mode
(use-package evil :demand t :conifg (evil-mode 1))
(use-package evil-collection 
	     :after evil
	     :custom (evil-collection-key-blacklist '("SPC"))
	     :config
	     (evil-collection-init)
	     (evil-collection-buff-menu-setup))
(use-package which-key
	     :config (which-key-mode))
(use-package general
	     :demand t
	     :config 
	     (general-evil-setup t)
	     (general-nmap "," (general-simulate-key "C-c")
	     (general-define-key :keymaps 'evil-insert-state-map
				 (general-chord "jk") 'evil-normal-state
				 (general-chord "kj") 'evil-normal-state))
(elpaca-wait)
(use-package magit
	     :general
	     ("C-c g" 'magit-status)
	     ("C-c G" 'magit-file-dispatch))

