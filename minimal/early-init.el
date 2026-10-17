;; -*- lexical-binding: t; -*-
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
      ' ((menu-bar-lines . 0)
         (tool-bar-lines . 0) 
         (width . 120)
;        (height . 300)
;        (left . 900)
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

;fonts
;(push '(font . "Source Code Pro") default-frame-alist)
;(set-face-font 'default "Source Code Pro")
;(set-face-font 'variable-pitch "DejaVu Sans")
;(copy-face 'default 'fixed-pitch)

;end
(provide 'early-init)
;;; early-init.el ends here
