;; -*- lexical-binding: t; -*-
(setq package-enable-at-startup nil
      inhibit-default-init nil
      native-comp-async-report-warnings-errors nil
      ;; garbage collection settings for faster startup
      gc-cons-threshold most-positive-fixnum
      gc-cons-percentage 1
      server-client-instructions nil
      ring-bell-function #'ignore
      inhibit-startup-screen t
      )

(provide 'early-init)
;;; early-init.el ends here
