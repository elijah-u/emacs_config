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

(push '(menu-bar-lines . 0) default-frame-alist)
(push '(tool-bar-lines . 0) default-frame-alist)
(push '(vertical-scroll-bars) default-frame-alist)
(setq server-client-instructions nil)
(setq frame-inhibit-implied-resize t)
(advice-add #'x-apply-session-resources :override #'ignore)
(setq ring-bell-function #'ignore
      inhibit-startup-screen t)
;custom dirs
(defun make-var-dir-pair(list)
  (dolist (pair list)
    (let ((var (car pair))
          (dir (car (cdr pair))))
        (make-directory dir)
        (set var dir))))
(make-var-dir-pair
 '((user-local-tmp-config-dir '(expand-file-name ".config" user-emacs-directory))
   (user-local-tmp-data-dir '(expand-file-name ".data" user-emacs-directory))))
(when (fboundp 'startup-redirect-eln-cache)
  (startup-redirect-eln-cache
   (convert-standard-filename
    (expand-file-name  "eln-cache" user-local-tmp-data-dir))))
;fonts
(push '(font . "Source Code Pro") default-frame-alist)
(set-face-font 'default "Source Code Pro")
(set-face-font 'variable-pitch "DejaVu Sans")
(copy-face 'default 'fixed-pitch)
;end
(provide 'early-init)
;;; early-init.el ends here
