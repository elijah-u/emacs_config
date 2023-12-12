;; more-init.el --- development settings for init file  
;;  -*- lexical-binding: t; -*-

(setq-local org-confirm-babel-evaluate nil)
(require 'auto-tangle-mode)
(auto-tangle-mode)
(add-hook 'auto-tangle-after-tangle-hook (lambda ()
                                           (let ((elpaca-log-functions nil))
                                             (load-file "~/.emacs.d/init.el")
                                             (elpaca-process-queues))))
(eldoc-mode)
(provide 'init-dev)

