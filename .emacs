;; -*- lexical-binding: t; -*-



;;; =============================
;;; Emacs Configuration
;;; =============================

(package-initialize)
(add-to-list 'load-path "~/.emacs.local/")

(load "~/.emacs.rc/rc.el")
(load "~/.emacs.rc/misc-rc.el")
(load "~/.emacs.rc/org-mode-rc.el")
(load "~/.emacs.rc/autocommit-rc.el")

;;; =============================
;;; Basic Functions
;;; =============================

(defun dired-open-file-in-new-tab ()
  "Open the file at point in a new tab."
  (interactive)
  (let ((file (dired-get-file-for-visit)))
    (tab-new)
    (find-file file)))

(with-eval-after-load 'dired
  (define-key dired-mode-map (kbd "o") 'dired-open-file-in-new-tab))

;;; =============================
;;; Whitespace Handling
;;; =============================

(global-whitespace-mode -1)
(remove-hook 'prog-mode-hook #'whitespace-mode)
(remove-hook 'text-mode-hook #'whitespace-mode)
(setq-default show-trailing-whitespace nil)

(defun rc/set-up-whitespace-handling ()
  (interactive)
  (whitespace-mode 1)
  (add-to-list 'write-file-functions 'delete-trailing-whitespace))

;;; =============================
;;; Appearance / UI Enhancements
;;; =============================

(defun rc/get-default-font ()
  "Return Consolas if available, otherwise fallback fonts by OS."
  (let ((font-name "Consolas"))
    (if (member font-name (font-family-list))
        (format "%s-13" font-name)
      (pcase system-type
        ('windows-nt "Cascadia Code-13")
        ('gnu/linux "Iosevka Term-16")
        ('darwin "SF Mono-14")  ; fixed quote
        (_ "Monospace-13")))))

(add-to-list 'default-frame-alist `(font . ,(rc/get-default-font)))
(add-to-list 'default-frame-alist '(background-color . "#131313")) ; slightly lighter black
(add-to-list 'default-frame-alist '(foreground-color . "#c6c6c6"))
(add-to-list 'default-frame-alist '(cursor-color . "#c6c6c6"))

;;; Minimal UI
(tool-bar-mode -1)
(menu-bar-mode -1)
(scroll-bar-mode -1)
(setq inhibit-startup-screen t)
(column-number-mode 1)
(show-paren-mode 1)
(global-hl-line-mode 1)
(set-face-attribute 'hl-line nil :background "#1a1a1a") ; slightly lighter highlight
(set-face-attribute 'fringe nil :background "#131313") ; match background

;;; Theme
(use-package base16-theme
  :ensure t
  :config
  (load-theme 'base16-eighties t)
  (set-face-background 'default "#131313")
  (set-face-foreground 'default "#c6c6c6")
  (set-face-background 'region "#262626")
  (set-face-background 'mode-line "#1a1a1a")
  (set-face-background 'mode-line-inactive "#1a1a1a")
  (set-face-foreground 'mode-line "#c6c6c6")
  (set-face-foreground 'mode-line-inactive "#888888"))

;;; Modeline
(use-package doom-modeline
  :ensure t
  :init (doom-modeline-mode 1)
  :custom
  ((doom-modeline-height 25)
   (doom-modeline-bar-width 4)
   (doom-modeline-buffer-file-name-style 'truncate-upto-project)))

;;; Icons
(use-package all-the-icons
  :ensure t
  :config
  (unless (member "all-the-icons" (font-family-list))
    (all-the-icons-install-fonts t)))

(use-package all-the-icons-dired
  :ensure t
  :hook (dired-mode . all-the-icons-dired-mode))

;;; Line numbers
(global-display-line-numbers-mode 1)
(setq display-line-numbers-type 'relative)
(set-face-attribute 'line-number nil :foreground "#676e95" :background "#131313")
(set-face-attribute 'line-number-current-line nil :foreground "#c6c6c6" :weight 'bold :background "#131313")

;;; Fringes
(set-fringe-mode 12)

;;; Visual line wrapping
(global-visual-line-mode 1)
(setq-default word-wrap t)

;;; Ligatures
(use-package ligature
  :ensure t
  :config
  (ligature-set-ligatures 't '("www" "->" "=>" "::" "==" "!=" "<=" ">=" "&&" "||"))
  (global-ligature-mode t))

;;; Optional: Hide warnings if no GUI
(when (not (display-graphic-p))
  (message "Warning: Icons require Emacs GUI to display properly"))

;;; =============================
;;; Completion & Navigation
;;; =============================

(global-set-key (kbd "C-x b") 'helm-mini)

;; Inline completion with Corfu
(use-package corfu
  :ensure t
  :custom
  (corfu-cycle t)             ; Cycle through candidates
  (corfu-auto t)              ; Enable auto completion
  (corfu-auto-delay 0.1)
  (corfu-min-width 30)
  (corfu-echo-delay 0.25)
  :init
  (global-corfu-mode))

;; Icons in completion menus
(use-package all-the-icons-completion
  :ensure t
  :after corfu
  :config
  (all-the-icons-completion-mode))

;; Smex for improved M-x
(use-package smex
  :ensure t
  :bind (("M-x" . smex)
         ("C-c C-c M-x" . execute-extended-command)))

;; Helm for fuzzy search and navigation
(use-package helm
  :ensure t
  :init (helm-mode 1)
  :bind (("C-c h f" . helm-find-files)
         ("C-c h r" . helm-recentf)
         ("C-c h g g" . helm-git-grep)
         ("C-c h g l" . helm-ls-git-ls)))

;; Projectile for project management
(use-package projectile
  :ensure t
  :init
  (projectile-mode +1)
  :bind-keymap ("C-c p" . projectile-command-map) ;; keep C-c p as prefix
  :custom
  (projectile-project-search-path '("~/path/to/projects/"))
  ;; Open root in Dired by default when switching projects
  (projectile-switch-project-action 'projectile-dired))

;; Helm Projectile integration
(use-package helm-projectile
  :ensure t
  :after (helm projectile)
  :config
  (helm-projectile-on))

;; Optional: automatically disable Flycheck and LSP diagnostics in all buffers of the project
(defun my/projectile-disable-linters-for-project ()
  "Disable Flycheck and LSP diagnostics for all buffers in current Projectile project."
  (dolist (buf (projectile-current-project-buffers))
    (with-current-buffer buf
      (when (bound-and-true-p flycheck-mode)
        (flycheck-mode -1))
      (when (bound-and-true-p lsp-mode)
        (setq-local lsp-diagnostics-provider :none)))))

(advice-add 'projectile-switch-project :after #'my/projectile-disable-linters-for-project)

;; Keep standard Projectile commands functional under C-c p
(with-eval-after-load 'projectile
  (define-key projectile-command-map (kbd "f") #'projectile-find-file)
  (define-key projectile-command-map (kbd "s s") #'projectile-ripgrep)
  (define-key projectile-command-map (kbd "g") #'projectile-grep)
  (define-key projectile-command-map (kbd "b") #'projectile-switch-to-buffer))

;; Avy for quick jumping
(use-package avy
  :ensure t
  :bind ("C-:" . avy-goto-char-timer)
         ("C-'" . avy-goto-word-1)
         ("M-g f" . avy-goto-line))

;;; =============================
;;; Programming / Language Mode Enhancements
;;; =============================

;; -----------------------------
;; LSP and Completion
;; -----------------------------
(use-package lsp-mode
  :ensure t
  :commands lsp
  :init
  (setq lsp-keymap-prefix "C-c l"
        lsp-enable-snippet nil
        lsp-prefer-flymake nil
        lsp-file-watch-threshold 15000)
  :hook ((c-mode c++-mode python-mode haskell-mode typescript-mode) . lsp))

(use-package lsp-ui
  :ensure t
  :commands lsp-ui-mode
  :config
  (setq lsp-ui-doc-enable t
        lsp-ui-doc-position 'at-point
        lsp-ui-sideline-enable t
        lsp-ui-sideline-show-symbol t
        lsp-ui-sideline-show-hover t
        lsp-ui-sideline-show-diagnostics t
        lsp-ui-sideline-delay 0.2))

;; -----------------------------
;; Completion
;; -----------------------------
(use-package corfu
  :ensure t
  :init (global-corfu-mode)
  :custom
  (corfu-cycle t)
  (corfu-auto t)
  (corfu-auto-delay 0.1)
  (corfu-min-width 30)
  (corfu-echo-delay 0.25))

(use-package company
  :ensure t
  :hook ((c-mode c++-mode python-mode) . company-mode)
  :custom
  (company-idle-delay 0.1)
  (company-minimum-prefix-length 1)
  (company-show-numbers t))

;; Icons in completions
(use-package all-the-icons-completion
  :ensure t
  :after corfu
  :config
  (all-the-icons-completion-mode))

;; -----------------------------
;; Syntax Checking
;; -----------------------------
(use-package flycheck
  :ensure t
  :init (global-flycheck-mode)
  :custom
  (flycheck-display-errors-delay 0.3))

;; -----------------------------
;; Autoformatting on save
;; -----------------------------
(defun rc/clang-format-buffer ()
  "Format current buffer with clang-format."
  (interactive)
  (when (derived-mode-p 'c-mode 'c++-mode)
    (clang-format-buffer)))

(defun rc/python-black-buffer ()
  "Format Python buffer with black."
  (interactive)
  (when (eq major-mode 'python-mode)
    (call-process "black" nil "*Black Output*" t buffer-file-name)))

(add-hook 'before-save-hook 'rc/clang-format-buffer)
(add-hook 'before-save-hook 'rc/python-black-buffer)

;; -----------------------------
;; Paredit & Eldoc for Lisp
;; -----------------------------
(use-package paredit
  :ensure t
  :hook ((emacs-lisp-mode lisp-mode clojure-mode scheme-mode) . paredit-mode))

(add-hook 'emacs-lisp-mode-hook 'eldoc-mode)
(add-hook 'clojure-mode-hook 'eldoc-mode)
(add-hook 'lisp-mode-hook 'eldoc-mode)

;; -----------------------------
;; Haskell enhancements
;; -----------------------------
(use-package hindent
  :ensure t
  :hook (haskell-mode . hindent-mode))

(add-hook 'haskell-mode-hook 'interactive-haskell-mode)
(add-hook 'haskell-mode-hook 'haskell-doc-mode)
(add-hook 'haskell-mode-hook 'haskell-indent-mode)

;; -----------------------------
;; General Programming Enhancements
;; -----------------------------
;; Display line numbers
(when (version<= "26.0.50" emacs-version)
  (global-display-line-numbers-mode))

;; Highlight current line
(global-hl-line-mode 1)

;;; =============================
;;; C++ Project Full Features Setup
;;; =============================

;; Ensure LSP is active for C/C++
(add-hook 'c-mode-hook #'lsp)
(add-hook 'c++-mode-hook #'lsp)

;; Use clangd as the LSP server
(setq lsp-clients-clangd-executable "/usr/local/bin/clangd") ;; adjust if needed
(setq lsp-clients-clangd-args
      '("--compile-commands-dir=."
        "--header-insertion=never"
        "--clang-tidy"))

;; Auto-generate compile_commands.json for CMake projects
(defun rc/generate-compile-commands ()
  "Generate compile_commands.json if missing and restart LSP."
  (let ((root (projectile-project-root)))
    (when (and root
               (file-exists-p (expand-file-name "CMakeLists.txt" root))
               (not (file-exists-p (expand-file-name "compile_commands.json" root))))
      (compile "cmake -DCMAKE_EXPORT_COMPILE_COMMANDS=ON .")
      ;; Restart LSP after compilation finishes
      (add-hook 'compilation-finish-functions
                (lambda (buffer status)
                  (when (string-match "finished" status)
                    (when (fboundp 'lsp)
                      (lsp-restart-workspace))
                    (remove-hook 'compilation-finish-functions
                                 #'rc/generate-compile-commands)))))))

(add-hook 'c-mode-hook #'rc/generate-compile-commands)
(add-hook 'c++-mode-hook #'rc/generate-compile-commands)

;; Autoformat C/C++ on save
(defun rc/clang-format-buffer ()
  "Run clang-format on current buffer if C/C++."
  (interactive)
  (when (derived-mode-p 'c-mode 'c++-mode)
    (clang-format-buffer)))
(add-hook 'before-save-hook 'rc/clang-format-buffer)

;; Flycheck for real-time diagnostics
(add-hook 'c-mode-hook 'flycheck-mode)
(add-hook 'c++-mode-hook 'flycheck-mode)

;; Company completion for C/C++
(add-hook 'c-mode-hook
          (lambda ()
            (setq-local company-backends '(company-capf company-files company-keywords))
            (company-mode 1)))
(add-hook 'c++-mode-hook
          (lambda ()
            (setq-local company-backends '(company-capf company-files company-keywords))
            (company-mode 1)))

;; Optional: Corfu inline completion
(add-hook 'c-mode-hook #'corfu-mode)
(add-hook 'c++-mode-hook #'corfu-mode)

;; Navigation keys
(with-eval-after-load 'lsp-mode
  (define-key lsp-mode-map (kbd "M-.") 'lsp-find-definition)
  (define-key lsp-mode-map (kbd "M-,") 'lsp-find-references)
  (define-key lsp-mode-map (kbd "C-c l r") 'lsp-rename)
  (define-key lsp-mode-map (kbd "C-c l f") 'lsp-format-buffer))

;; Enable line numbers and highlight current line
(when (version<= "26.0.50" emacs-version)
  (display-line-numbers-mode 1))
(global-hl-line-mode 1)

(provide 'cpp-full-features)

;;; =============================
;;; Org Mode & Productivity Enhancements
;;; =============================

;; -----------------------------
;; Core Org Mode
;; -----------------------------
(use-package org
  :ensure t
  :config
  ;; Visual improvements
  (setq org-fontify-whole-heading-line t
        org-hide-leading-stars t
        org-startup-indented t
        org-pretty-entities t
        org-agenda-start-with-log-mode t
        org-log-done 'time
        org-log-into-drawer t))

;; -----------------------------
;; Org Bullets
;; -----------------------------
(use-package org-bullets
  :ensure t
  :hook (org-mode . org-bullets-mode))

;; -----------------------------
;; Org Modern: Visual Theme & Icons
;; -----------------------------
(use-package org-modern
  :ensure t
  :hook (org-mode . org-modern-mode)
  :custom
  (org-modern-hide-stars nil)
  (org-modern-todo nil)
  (org-modern-block-fringe nil)
  (org-modern-table nil))

;; -----------------------------
;; Org Agenda & Capture Templates
;; -----------------------------
(setq org-agenda-files '("~/org/"))
(setq org-capture-templates
      '(("t" "Todo" entry (file+headline "~/org/todo.org" "Tasks")
         "* TODO %?\n  %i\n  %a")
        ("n" "Note" entry (file+headline "~/org/notes.org" "Notes")
         "* %?\n  %i\n  %a")))

(global-set-key (kbd "C-c a") 'org-agenda)
(global-set-key (kbd "C-c c") 'org-capture)

;; -----------------------------
;; Org Refiling
;; -----------------------------
(setq org-refile-use-outline-path 'file
      org-outline-path-complete-in-steps nil
      org-refile-targets '((org-agenda-files :maxlevel . 3)))

;; -----------------------------
;; Org-Roam: Knowledge Management
;; -----------------------------
(use-package org-roam
  :ensure t
  :init (setq org-roam-v2-ack t)
  :custom
  (org-roam-directory (expand-file-name "~/org/roam/"))
  :bind (("C-c n l" . org-roam-buffer-toggle)
         ("C-c n f" . org-roam-node-find)
         ("C-c n i" . org-roam-node-insert))
  :config
  ;; Ensure the directory exists to prevent startup errors
  (unless (file-exists-p org-roam-directory)
    (make-directory org-roam-directory t))
  (org-roam-db-autosync-mode 1))

(provide 'org-productivity)

;;; =============================
;;; LSP / Completion / Syntax
;;; =============================

;; LSP
(use-package lsp-mode
  :ensure t
  :hook ((c-mode c++-mode) . lsp)
  :commands lsp
  :config
  (setq lsp-clients-clangd-executable "/opt/homebrew/opt/llvm/bin/clangd"
        lsp-enable-snippet nil
        lsp-prefer-flymake nil))

(use-package lsp-ui
  :ensure t
  :commands lsp-ui-mode
  :config
  (setq lsp-ui-doc-enable t
        lsp-ui-doc-position 'at-point
        lsp-ui-sideline-enable t))

;; Flycheck
(use-package flycheck
  :ensure t
  :init (global-flycheck-mode))

;;; =============================
;;; Custom Features & Extras
;;; =============================

;; Global text scale
(defvar cfg/global-text-scale 0 "Global text scale applied to all buffers.")
(defun cfg/apply-global-text-scale () (text-scale-set cfg/global-text-scale))
(add-hook 'buffer-list-update-hook #'cfg/apply-global-text-scale)
(defun cfg/update-global-text-scale ()
  (setq cfg/global-text-scale (or text-scale-mode-amount 0)))
(add-hook 'text-scale-mode-hook #'cfg/update-global-text-scale)

(provide 'cfg)
(custom-set-variables
 ;; custom-set-variables was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(package-selected-packages
   '(ag all-the-icons-completion all-the-icons-dired avy base16-theme
        catppuccin-theme ccls clang-format clojure-mode cmake-mode
        corfu d-mode dash-functional dockerfile-mode doom-modeline
        doom-themes elpy glsl-mode go-mode graphviz-dot-mode
        gruber-darker-theme gruvbox-theme haskell-mode helm-ls-git
        helm-projectile helm-rg hindent ido-completing-read+
        jinja2-mode kotlin-mode ligature lsp-ui lua-mode magit
        modus-themes move-text multiple-cursors nginx-mode nim-mode
        nix-mode org-bullets org-cliplink org-modern org-roam paredit
        php-mode powershell proof-general purescript-mode qml-mode
        racket-mode rfc-mode rust-mode scala-mode smex sml-mode tide
        toml-mode tuareg typescript-mode uxntal-mode yaml-mode)))
(custom-set-faces
 ;; custom-set-faces was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 )

(defun disable-flycheck-for-current-project-once ()
  "Disable Flycheck automatically for this buffer in the current project.
Runs only once per buffer to avoid re-enabling issues."
  (interactive)
  (when (and (projectile-project-p)
             (bound-and-true-p flycheck-mode)
             (not (bound-and-true-p flycheck-disabled-for-project)))
    ;; Mark this buffer as having Flycheck disabled
    (setq-local flycheck-disabled-for-project t)
    ;; Disable automatic checking
    (setq-local flycheck-check-syntax-automatically nil)
    ;; Clear any existing overlays
    (flycheck-clear)
    (message "Flycheck disabled for this buffer in this project")))

(defun enable-flycheck-for-current-project ()
  "Re-enable Flycheck for the current buffer."
  (interactive)
  (when (projectile-project-p)
    ;; Re-enable automatic checking
    (setq-local flycheck-check-syntax-automatically
                '(save mode-enabled idle-change new-line))
    (flycheck-buffer)
    (setq-local flycheck-disabled-for-project nil)
    (message "Flycheck enabled for this buffer in this project")))

;; Hook the “disable once” function safely
(add-hook 'prog-mode-hook 'disable-flycheck-for-current-project-once)


