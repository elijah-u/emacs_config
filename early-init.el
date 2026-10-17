(setq package-enable-at-startup nil)

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
