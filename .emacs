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
        ('darwin "SF Mono-14")
        (_ "Monospace-13")))))

(add-to-list 'default-frame-alist `(font . ,(rc/get-default-font)))
(add-to-list 'default-frame-alist '(background-color . "#131313"))
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
(set-face-attribute 'hl-line nil :background "#1a1a1a")
(set-face-attribute 'fringe nil :background "#131313")

;;; =============================
;;; VS Code-like Theme
;;; =============================
(use-package base16-theme
  :ensure t
  :config
  (load-theme 'base16-eighties t) ;; choose a dark base16 theme

  ;; Editor background and foreground
  (set-face-background 'default "#1e1e1e")  ;; VS Code dark background
  (set-face-foreground 'default "#d4d4d4")  ;; VS Code light text

  ;; Selection
  (set-face-background 'region "#264f78")   ;; VS Code selection blue

  ;; Line highlighting
  (set-face-background 'hl-line "#2a2a2a")  ;; subtle highlight for current line

  ;; Mode-line
  (set-face-background 'mode-line "#0a52d0")          ;; VS Code blue active
  (set-face-foreground 'mode-line "#ffffff")          ;; white text
  (set-face-attribute 'mode-line nil :weight 'bold)
  (set-face-background 'mode-line-inactive "#3c3c3c") ;; dark gray inactive
  (set-face-foreground 'mode-line-inactive "#888888")

  ;; Fringe
  (set-face-background 'fringe "#1e1e1e")  ;; match editor background

  ;; Window divider
  (set-face-background 'window-divider "#333333")
  (set-face-background 'window-divider-first-pixel "#333333")
  (set-face-background 'window-divider-last-pixel "#333333")

  ;; Line numbers
  (set-face-foreground 'line-number "#858585")
  (set-face-foreground 'line-number-current-line "#d4d4d4")
  (set-face-background 'line-number-current-line "#1e1e1e"))

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
  (corfu-cycle t)
  (corfu-auto t)
  (corfu-auto-delay 0.1)
  (corfu-min-width 30)
  (corfu-echo-delay 0.25)
  :init
  (global-corfu-mode))

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
  :bind-keymap ("C-c p" . projectile-command-map)
  :custom
  (projectile-project-search-path '("~/path/to/projects/"))
  (projectile-switch-project-action 'projectile-dired))

;; Helm Projectile integration
(use-package helm-projectile
  :ensure t
  :after (helm projectile)
  :config
  (helm-projectile-on))

;; Avy for quick jumping
(use-package avy
  :ensure t
  :bind (("C-:" . avy-goto-char-timer)
         ("C-'" . avy-goto-word-1)
         ("M-g f" . avy-goto-line)))

;;; =============================
;;; Neotree: Project File Tree
;;; =============================

(use-package neotree
  :ensure t
  :after projectile
  :bind (("C-x n t" . neotree-toggle)
         ("C-x n f" . neotree-find))
  :config
  (setq neo-smart-open t)
  (setq neo-theme (if (display-graphic-p) 'icons 'arrow))
  (defun my/projectile-switch-to-neotree ()
    "Open Neotree at the Projectile project root after switching projects."
    (when (projectile-project-p)
      (let ((project-root (projectile-project-root)))
        (neotree-dir project-root)
        (neotree-find))))
  (advice-add 'projectile-switch-project :after #'my/projectile-switch-to-neotree)
  (setq neo-window-width 50)
  (setq neo-window-allow-other-window nil)
  (setq neo-window-fixed-size 'auto)
  (setq neo-truncate-names t)
  (add-hook 'neo-after-create-hook
            (lambda (_)
              (setq truncate-lines t)
              (text-scale-set 0)
              (setq-local text-scale-mode-amount 0)
              (setq-local text-scale-mode-step 0)
              (text-scale-mode 1))))

(defun my/neotree-zoom-in ()
  "Zoom in NeoTree buffer only."
  (interactive)
  (when (eq major-mode 'neotree-mode)
    (text-scale-increase 1)))

(defun my/neotree-zoom-out ()
  "Zoom out NeoTree buffer only."
  (interactive)
  (when (eq major-mode 'neotree-mode)
    (text-scale-decrease 1)))

(with-eval-after-load 'neotree
  (define-key neotree-mode-map (kbd "C-+") 'my/neotree-zoom-in)
  (define-key neotree-mode-map (kbd "C--") 'my/neotree-zoom-out)
  (defun my/neotree-jump-to-folder ()
    "Change Neotree root to the folder under cursor."
    (interactive)
    (let* ((node (neo-buffer--get-filename-current-line))
           (dir (cond
                 ((null node) (user-error "No node under cursor"))
                 ((file-directory-p node) node)
                 (t (file-name-directory node)))))
      (let ((neo-buf (get-buffer neo-buffer-name)))
        (when neo-buf (kill-buffer neo-buf)))
      (neotree-dir dir)
      (neotree-show)
      (message "Neotree root changed to: %s" dir)))
  (define-key neotree-mode-map (kbd "M-RET") #'my/neotree-jump-to-folder))

    ;; Optional: automatically expand NeoTree on project switch
  (defun my/projectile-switch-to-neotree ()
    "Open NeoTree at Projectile project root after switching projects."
    (when (projectile-project-p)
      (neotree-dir (projectile-project-root))
      (neotree-show)))
  (advice-add 'projectile-switch-project :after #'my/projectile-switch-to-neotree)

  ;; -----------------------------
  ;; Keybindings inside NeoTree window
  ;; -----------------------------
  (with-eval-after-load 'neotree
    (define-key neotree-mode-map (kbd "RET") 'neotree-enter)          ;; open file/folder
    (define-key neotree-mode-map (kbd "o") 'neotree-enter)            ;; alternate open
    (define-key neotree-mode-map (kbd "C") 'neotree-create-node)      ;; create file or dir
    (define-key neotree-mode-map (kbd "R") 'neotree-rename-node)      ;; rename
    (define-key neotree-mode-map (kbd "D") 'neotree-delete-node)      ;; delete
    (define-key neotree-mode-map (kbd "g") 'neotree-refresh)          ;; refresh
    (define-key neotree-mode-map (kbd "TAB") 'neotree-enter)          ;; open folder
    (define-key neotree-mode-map (kbd "SPC") 'neotree-quick-look)     ;; preview file
    (define-key neotree-mode-map (kbd "q") 'neotree-hide)             ;; close NeoTree
    (define-key neotree-mode-map (kbd "C-c C-c") 'neotree-copy-node)  ;; copy
    (define-key neotree-mode-map (kbd "C-c C-v") 'neotree-paste-node) ;; paste
    (define-key neotree-mode-map (kbd "C-c C-m") 'neotree-move-node)  ;; move
    (define-key neotree-mode-map (kbd "m") 'neotree-toggle-mark))     ;; mark/unmark file

  ;; -----------------------------
  ;; Hide hidden files by default, with toggle
  ;; -----------------------------
  (defun my-neotree-toggle-hidden-files ()
    "Toggle visibility of hidden files in NeoTree and fully refresh the root."
    (interactive)
    (setq neo-show-hidden-files (not neo-show-hidden-files))
    ;; Remember the NeoTree root
    (let ((root (or (bound-and-true-p neo-buffer--start-node)
                    default-directory)))
      ;; Kill the existing NeoTree buffer
      (let ((buf (get-buffer neo-buffer-name)))
        (when buf (kill-buffer buf)))
      ;; Reopen NeoTree at the same root
      (neotree-dir root)))

  ;; Hide dotfiles by default
  (setq neo-show-hidden-files nil)

  (with-eval-after-load 'neotree
    (define-key neotree-mode-map (kbd ".") #'my-neotree-toggle-hidden-files))

;;; =============================
;;; Programming / Language Mode Enhancements
;;; =============================

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

;; -----------------------------
;; Auto-completion & Snippets
;; -----------------------------
(electric-pair-mode 1)

(use-package yasnippet
  :ensure t
  :hook (prog-mode . yas-minor-mode)
  :config
  (yas-reload-all))

;; -----------------------------
;; Indentation: 4 spaces
;; -----------------------------
(setq-default indent-tabs-mode nil)
(setq-default tab-width 4)
(setq-default standard-indent 4)

(defun rc/setup-prog-indent ()
  "Set up 4-space indentation for programming modes."
  (setq-local c-basic-offset 4)
  (setq-local python-indent-offset 4)
  (setq-local haskell-indentation-layout-offset 4)
  (setq-local haskell-indentation-starter-offset 4)
  (setq-local haskell-indentation-left-offset 4)
  (setq-local haskell-indentation-where-pre-offset 4)
  (setq-local lisp-indent-offset 4)
  (setq-local js-indent-level 4)
  (setq-local typescript-indent-level 4)
  (setq-local web-mode-markup-indent-offset 4)
  (setq-local web-mode-css-indent-offset 4)
  (setq-local web-mode-code-indent-offset 4))

(add-hook 'prog-mode-hook 'rc/setup-prog-indent)

;;; =============================
;;; Org Mode & Productivity Enhancements
;;; =============================

(use-package org
  :ensure t
  :config
  (setq org-fontify-whole-heading-line t
        org-hide-leading-stars t
        org-startup-indented t
        org-pretty-entities t
        org-agenda-start-with-log-mode t
        org-log-done 'time
        org-log-into-drawer t))

(use-package org-bullets
  :ensure t
  :hook (org-mode . org-bullets-mode))

(use-package org-modern
  :ensure t
  :hook (org-mode . org-modern-mode)
  :custom
  (org-modern-hide-stars nil)
  (org-modern-todo nil)
  (org-modern-block-fringe nil)
  (org-modern-table nil))

(setq org-agenda-files '("~/org/"))
(setq org-capture-templates
      '(("t" "Todo" entry (file+headline "~/org/todo.org" "Tasks")
         "* TODO %?\n  %i\n  %a")
        ("n" "Note" entry (file+headline "~/org/notes.org" "Notes")
         "* %?\n  %i\n  %a")))

(global-set-key (kbd "C-c a") 'org-agenda)
(global-set-key (kbd "C-c c") 'org-capture)

(setq org-refile-use-outline-path 'file
      org-outline-path-complete-in-steps nil
      org-refile-targets '((org-agenda-files :maxlevel . 3)))

(use-package org-roam
  :ensure t
  :init (setq org-roam-v2-ack t)
  :custom
  (org-roam-directory (expand-file-name "~/org/roam/"))
  :bind (("C-c n l" . org-roam-buffer-toggle)
         ("C-c n f" . org-roam-node-find)
         ("C-c n i" . org-roam-node-insert))
  :config
  (unless (file-exists-p org-roam-directory)
    (make-directory org-roam-directory t))
  (org-roam-db-autosync-mode 1))

;;; =============================
;;; Custom Features & Extras
;;; =============================

(use-package pdf-tools
  :ensure t
  :config
  (pdf-tools-install))

(provide 'cfg)

(defun my-term-mode-setup ()
  (local-set-key (kbd "M-x") 'execute-extended-command))
(add-hook 'term-mode-hook 'my-term-mode-setup)

(global-set-key (kbd "M-3")
                (lambda () (interactive) (insert "#")))


(setq gc-cons-threshold 500000000) ; 100MB instead of default ~0.8MB
(setq gc-cons-percentage 0.6)


;; -------------------------------
;; Multi-Term Setup
;; -------------------------------

(require 'package)

;; Add MELPA if not already added
(unless (assoc "melpa" package-archives)
  (add-to-list 'package-archives
               '("melpa" . "https://melpa.org/packages/") t))

;; Refresh package contents if needed
(unless package-archive-contents
  (package-refresh-contents))

;; Install multi-term if missing
(unless (package-installed-p 'multi-term)
  (package-install 'multi-term))

(require 'multi-term)

;; Optional: default multi-term buffer name
(setq multi-term-buffer-name "terminal")

;; Optional: keybinding to quickly open multi-term
(global-set-key (kbd "C-c t") 'multi-term)

;;; =============================
;;; Independent Font Scaling per Window/Tab
;;; =============================

;; Remove the global synchronization that caused font sizes to jump
(remove-hook 'buffer-list-update-hook #'cfg/apply-global-text-scale)
(remove-hook 'text-scale-mode-hook #'cfg/update-global-text-scale)

;; Simple keybindings for per-window scaling (built-in behavior)
(global-set-key (kbd "C-x C-+") #'text-scale-increase)
(global-set-key (kbd "C-x C--") #'text-scale-decrease)
(global-set-key (kbd "C-x C-0") (lambda () (interactive) (text-scale-set 0)))

;;; =============================
;;; Optimized C++ Dev Config (Corfu + LSP-only Completion)
;;; =============================

;; -----------------------------
;; Corfu: Completion popup UI
;; -----------------------------
(use-package corfu
  :ensure t
  :custom
  (corfu-cycle t)
  (corfu-auto t)
  (corfu-auto-delay 0.1)
  (corfu-min-width 30)
  (corfu-echo-delay 0.25)
  :init
  (global-corfu-mode))

;; -----------------------------
;; LSP (clangd recommended)
;; -----------------------------
(use-package lsp-mode
  :ensure t
  :commands lsp
  :hook ((c++-mode c-mode) . lsp)
  :init

  (setq lsp-enable-snippet nil
        lsp-prefer-flymake nil
        lsp-file-watch-threshold 5000
        lsp-enable-file-watchers nil
        lsp-diagnostics-provider :none
        lsp-idle-delay 0.5
        lsp-prefer-capf t)
  :config
  ;; Prefer Homebrew clangd if available
  (setq lsp-clients-clangd-executable
        (or (executable-find "/opt/homebrew/opt/llvm/bin/clangd")
            (executable-find "/usr/local/opt/llvm/bin/clangd")
            (executable-find "/usr/bin/clangd")
            (executable-find "clangd"))))

;; -----------------------------
;; LSP UI (hover, peek, references)
;; -----------------------------
(use-package lsp-ui
  :ensure t
  :commands lsp-ui-mode
  :init
  (add-hook 'lsp-mode-hook 'lsp-ui-mode)
  :config
  ;; Keep lightweight: disable docs/sideline spam
  (setq lsp-ui-sideline-enable nil
        lsp-ui-doc-enable nil))

;; Keybindings for navigation
(with-eval-after-load 'lsp-mode
  (define-key lsp-mode-map (kbd "M-.") 'lsp-find-definition)
  (define-key lsp-mode-map (kbd "M-,") 'lsp-find-references)
  (global-set-key (kbd "M-[") 'xref-go-back)
  (global-set-key (kbd "M-]") 'xref-go-forward))


;; -----------------------------
;; C++ Style (braces on new line)
;; -----------------------------
(defun rc/cpp-style ()
  "Custom C++ coding style with braces on new lines."
  (c-set-style "stroustrup")
  (setq c-basic-offset 4
        indent-tabs-mode nil)
  (c-set-offset 'substatement-open 0)
  (c-set-offset 'inline-open 0)
  (c-set-offset 'brace-list-open 0))
(add-hook 'c++-mode-hook 'rc/cpp-style)
(add-hook 'c-mode-hook 'rc/cpp-style)

;; -----------------------------
;; CMake support
;; -----------------------------
(use-package cmake-font-lock
  :ensure t
  :hook (cmake-mode . cmake-font-lock-activate))

;; -----------------------------
;; clang-format (manual trigger)
;; -----------------------------
(use-package clang-format
  :ensure t
  :bind (:map c++-mode-map
              ("C-c f" . clang-format-region)))

;;; =============================
;;; LSP Safety & CPU-friendly Settings
;;; =============================

(setq lsp-enable-file-watchers nil)
(setq lsp-auto-guess-root t)
(setq lsp-trace nil)
(setq lsp-enable-on-type-formatting nil)
(setq lsp-idle-delay 1.0)

(use-package lsp-ui
  :ensure t
  :commands lsp-ui-mode
  :init
  (add-hook 'lsp-mode-hook 'lsp-ui-mode)
  :config
  (setq lsp-ui-sideline-enable nil
        lsp-ui-doc-enable nil))

(with-eval-after-load 'company
  (setq company-global-modes '())
  (global-company-mode -1)
  (fmakunbound 'company-mode)
  (setq company-mode nil)
  (setq company-backends nil))

;; Prevent any function from activating company-mode
(advice-add 'company-mode :override #'ignore)

