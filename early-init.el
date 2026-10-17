;;; -*- lexical-bindings: t; -*-
;;; early-init.el

(setq package-enable-at-startup nil)
(setq inhibit-default-init nil)
(setq native-comp-async-report-warnings-errors nil)
(defvar default-file-name-handler-alist file-name-handler-alist)
(setq file-name-handler-alist nil)

(setq gc-cons-threshold most-positive-fixnum
      gc-cons-percentage 1)
(defun +gc-after-focus-change ()
  "Run GC when frame loses focus."
  (run-with-idle-timer
   5 nil
   (lambda () (unless (frame-focus-state) (garbage-collect)))))
(defun +reset-init-values ()
  (run-with-idle-timer
   1 nil
   (lambda ()
     (setq file-name-handler-alist default-file-name-handler-alist
           gc-cons-percentage 0.1
           gc-cons-threshold 100000000)
     (message "gc-cons-threshold & file-name-handler-alist restored")
     (when (boundp 'after-focus-change-function)
       (add-function :after after-focus-change-function #'+gc-after-focus-change)))))

(with-eval-after-load 'elpaca
  (add-hook 'elpaca-after-init-hook '+reset-init-values))

(setq default-frame-alist
      '((width . 120)
        (height . 300)
        (left . 900)
        (menu-bar-lines . 0)
        (tool-bar-lines . 0) 
        (vertical-scroll-bars . nil)))
(setq server-client-instructions nil)
(setq frame-inhibit-implied-resize t)
(advice-add #'x-apply-session-resources :override #'ignore)
(setq ring-bell-function #'ignore
      inhibit-startup-screen t)

;custom dirs
(defun make-var-dir-pair (variable dir &optional path)
  (let ((path (or path user-emacs-directory))
        (target (expand-file-name dir path)))  
    (unless (file-directory-p target) (make-directory target))
    (set variable target)))
(defun make-var-dir-pairs-from-list (list)
  (dolist (pair list) (apply 'make-var-dir-pair pair)))
(make-var-dir-pairs-from-list
 '((user-local-tmp-config-dir ".config") 
   (user-local-tmp-data-dir ".data"))) 
(when (fboundp 'startup-redirect-eln-cache)
  (startup-redirect-eln-cache
   (convert-standard-filename
    (expand-file-name "eln-cache" user-local-tmp-data-dir))))
(setq package-user-dir (file-name-concat "elpa" user-local-tmp-config-dir))

(when (eq system-type 'darwin)
  (setq dired-use-ls-dired nil)
  (add-to-list 'exec-path "~/homebrew/bin")
  (add-to-list 'exec-path "/opt/homebrew/bin")
;;  (setenv "PATH" "~/.asdf/shims:/opt/homebrew/opt/asdf/libexec/bin:/opt/homebrew/opt/sqlite/bin:/opt/homebrew/bin:/opt/homebrew/sbin:/usr/local/bin:/System/Cryptexes/App/usr/bin:/usr/bin:/bin:/usr/sbin:/sbin:/var/run/com.apple.security.cryptexd/codex.system/bootstrap/usr/local/bin:/var/run/com.apple.security.cryptexd/codex.system/bootstrap/usr/bin:/var/run/com.apple.security.cryptexd/codex.system/bootstrap/usr/appleinternal/bin:/Library/Apple/usr/bin:/Library/TeX/texbin:/Applications/iTerm.app/Contents/Resources/utilities:~/.local/bin:~/.local/bin"
; (customize-set-variable 'native-comp-driver-options '("-Wl,-w"))
;  )
 )

; fonts
(push '(font . "Fira Code Retina") default-frame-alist)
(set-face-font 'default "Fira Code Retina 14")
(set-face-font 'variable-pitch "ETBookOT 14")
(copy-face 'default 'fixed-pitch)
(setq evil-want-keybinding nil)

;end
(provide 'early-init)
;;; early-init.el ends here
