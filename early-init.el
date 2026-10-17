;;; -*- lexical-bindings: t; -*-
;;; early-init.el

(setq package-enable-at-startup nil)
(setq inhibit-default-init nil)
(setq native-comp-async-report-warnings-errors nil)
(defvar default-file-name-handler-alist file-name-handler-alist)
(setq file-name-handler-alist nil)

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
(defun make-dir-if-not-there (dir)
  "Creates a directory if it doesn't exist and returns the full path."
  (let ((dir-path (expand-file-name dir)))
      (make-directory dir-path t)
      dir-path))
(defun make-var-dir-pair (variable dir &optional path)
    (let ((path (or path user-emacs-directory))
        (target (expand-file-name dir path)))  
    (unless (file-directory-p target) (make-directory target))
    (set variable target)))
(defun make-var-dir-pairs-from-list (list)
    (dolist (pair list) (apply 'make-var-dir-pair pair)))
(make-var-dir-pairs-from-list
    '((user-local-tmp-config-dir ".config") 
    (user-local-tmp-data-dir ".data")
    (user-local-lisp "lisp")))

(when (fboundp 'startup-redirect-eln-cache)
    (startup-redirect-eln-cache
    (convert-standard-filename
    (expand-file-name "eln-cache" user-local-tmp-data-dir))))

(when (eq system-type 'darwin)
  (setq dired-use-ls-dired nil)
  (add-to-list 'exec-path "~/homebrew/bin")
  (add-to-list 'exec-path "/opt/homebrew/bin")
 )

; fonts
(push '(font . "Fira Code Retina") default-frame-alist)
(set-face-font 'default "Fira Code Retina 14")
(set-face-font 'variable-pitch "ETBookOT 14")
(copy-face 'default 'fixed-pitch)

;end
(provide 'early-init)
;;; early-init.el ends here
