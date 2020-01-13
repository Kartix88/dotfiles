(require 'server)
(unless (server-running-p)
  (server-start))

(add-to-list 'exec-path "~/.local/bin")
(add-to-list 'exec-path "~/.cargo/bin")

(setq +scaling-ratio (pcase (system-name)
                       ("thinkpad" 1.75)
                       (_ 1.2))
      +font-size (pcase (system-name)
                   ("thinkpad" 13.5)
                   (_ 13.0))

      doom-font (font-spec :family "InputMono Nerd Font"
                           :width 'semi-condensed
                           :size +font-size)
      doom-variable-pitch-font (font-spec :family "Roboto"
                                          :size +font-size))

(setq display-line-numbers-type 'relative)

(setq mouse-wheel-scroll-amount '(1 ((shift) . 3) ((control)))
      scroll-conservatively 3
      scroll-margin 3
      maximum-scroll-margin 0.2)

(setq-hook! 'intero-repl-mode-hook scroll-margin 0)
(setq-hook! 'term-mode-hook scroll-margin 0)

(add-to-list 'default-frame-alist '(height . 40))
(add-to-list 'default-frame-alist '(width . 120))

(setq doom-modeline-height 30
      nav-flash-delay 0.25
      which-key-idle-delay 0.4
      ;; The gray comments are hard to read in my terminal, although I rarely
      ;; use Emacs in a terminal
      doom-one-brighter-comments (not (or (display-graphic-p) (daemonp))))

(setq-default show-trailing-whitespace nil)

(add-hook! (prog-mode text-mode conf-mode)
  (defun doom-enable-show-trailing-whitespace-h ()
    (setq show-trailing-whitespace t)))

(map!
 :gi [remap newline] #'+robbert/newline-and-indent
 :gi [M-return]      #'newline-and-indent
 :gi [M-backspace]   #'evil-delete-back-to-indentation
 :g "M-f"            #'swiper
 :g "M-F"            #'+default/search-project
 :gnvi "M-Q"         #'+robbert/unfill-paragraph
 :gni "C-S-SPC"      #'company-yasnippet

 (:leader
   (:prefix "b"
     :desc "New buffer"             "c" #'+default/new-buffer
     :desc "Replace with clipboard" "P" #'+robbert/clipboard-to-buffer
     :desc "Copy to clipboard"      "Y" #'+robbert/buffer-to-clipboard)

   (:prefix "f"
     :desc "Find file in dotfiles"  "t" #'+robbert/find-in-dotfiles
     :desc "Browse dotfiles"        "T" #'+robbert/browse-dotfiles
     :desc "Find file externally"   "x" #'counsel-find-file-extern)

   (:prefix "g"
     :desc "SMerge hydra"           "m" #'+hydra-smerge/body)

   (:prefix "t"
     :desc "Change dictionary"      "S" #'ispell-change-dictionary)))

(setq evil-escape-key-sequence nil
      evil-ex-substitute-global nil
      +evil-want-o/O-to-continue-comments nil)

(setq-default evil-symbol-word-search t)

;; Make `w' and `b' handle more like in vim
(add-hook 'after-change-major-mode-hook #'+robbert/fix-evil-words-underscore)

(after! evil
  ;; Doom Emacs overrides the `;' and `,' keys to also repeat things like
  ;; searches. Because it uses evil-snipe by default this hasn't been done for
  ;; the default f/F/t/T keybindings.
  (set-repeater! evil-find-char evil-repeat-find-char evil-repeat-find-char-reverse)
  (set-repeater! evil-find-char-backward evil-repeat-find-char evil-repeat-find-char-reverse)
  (set-repeater! evil-find-char-to evil-repeat-find-char evil-repeat-find-char-reverse)
  (set-repeater! evil-find-char-to-backward evil-repeat-find-char evil-repeat-find-char-reverse)

  ;; These are not necessary because of `scroll-conservatively'
  (dolist (fn '(evil-ex-search-forward evil-ex-search-backward))
    (advice-remove fn #'doom-recenter-a)))

(use-package! evil-lion
  :after evil
  :config (evil-lion-mode))

;; TODO: Check whether this still works
(after! evil-surround
  ;; Add evil-surround support for common markup symbols
  (dolist (pair '((?$ . ("$" . "$")) (?= . ("=" . "=")) (?~ . ("~" . "~"))
                  (?/ . ("/" . "/")) (?* . ("*" . "*")) (?* . (":" . ":"))))
    (push pair evil-surround-pairs-alist)))

(use-package! academic-phrases)

(after! company-tng
  (setq company-minimum-prefix-length 2
        company-idle-delay 0.1))

(map!
 (:after company
   (:map company-active-map
     "C-a"    #'company-abort
     "C-l"    #'company-complete
     [escape] nil)))

(setq flycheck-pos-tip-timeout 15)

(map!
 (:after flycheck
   (:map flycheck-error-list-mode-map
     :m [M-return] #'flycheck-error-list-explain-erro)))

(setq flyspell-default-dictionary "english")

(add-hook 'text-mode-hook 'flyspell-mode)

(set-popup-rule! "^\\*Help" :size 0.3 :select t)

(add-hook 'text-mode-hook #'hl-todo-mode)

(after! hl-todo
  (setq hl-todo-keyword-faces
        `(("TODO"  . ,(face-foreground 'warning))
          ("FIXME" . ,(face-foreground 'error))
          ("XXX"   . ,(face-foreground 'error))
          ("HACK"  . ,(face-foreground 'error))
          ("NOTE"  . ,(face-foreground 'success)))))

(setq hippie-expand-try-functions-list
      '(try-complete-file-name-partially
        try-complete-file-name
        try-expand-all-abbrevs
        try-expand-line
        try-expand-dabbrev-visible
        try-expand-dabbrev-all-buffers
        try-expand-dabbrev-from-kill
        try-complete-lisp-symbol-partially
        try-complete-lisp-symbol))

(after! yasnippet
  (add-to-list 'hippie-expand-try-functions-list 'yas-hippie-try-expand))

(map! [remap dabbrev-expand] #'hippie-expand)

(setq completion-styles '(partial-completion initials)
      confirm-nonexistent-file-or-buffer nil)

(map!
 (:after ivy
   (:map ivy-minibuffer-map
     "C-d" #'ivy-scroll-up-command
     "C-u" #'ivy-scroll-down-command)))

(after! langtool
  (setq langtool-disabled-rules '("WHITESPACE_RULE")
        langtool-java-classpath "/usr/share/languagetool:/usr/share/java/languagetool/*"))

(map!
 :m "[v" #'+robbert/languagetool-previous-error
 :m "]v" #'+robbert/languagetool-next-error

 (:leader
   (:prefix "t"
     :desc "LanguageTool"         "t" #'+robbert/languagetool-toggle
     :desc "LanguageTool correct" "T" #'langtool-correct-buffer)))

(after! lsp-mode
  ;; Don't highlight symbols automatically, I'll use `gh' to do this manually
  (setq lsp-enable-symbol-highlighting nil)
  ;; Increase the height of documentation (since these will contain long
  ;; docstrings in them)
  (set-popup-rule! "^\\*lsp-help\\*$" :size 0.3 :select t))

(map!
 (:after lsp-ui
   (:map lsp-ui-peek-mode-map
     [tab]                           #'lsp-ui-peek--toggle-file
     "j"                             #'lsp-ui-peek--select-next
     "k"                             #'lsp-ui-peek--select-prev
     "J"                             #'lsp-ui-peek--select-next-file
     "K"                             #'lsp-ui-peek--select-prev-file
     "l"                             #'lsp-ui-peek--goto-xref)

   (:map lsp-ui-mode-map
     :nvi [M-return]                 #'lsp-execute-code-action
     :nv  "gh"                       #'lsp-document-highlight

     (:localleader
       (:prefix "g"
         :desc "Implementations" "i" #'lsp-ui-peek-find-implementation)))))

(after! ediff
  ;; Ancestor is already shown in buffer C
  (setq ediff-show-ancestor nil))

(after! magit
  (remove-hook 'git-commit-setup-hook #'+vc-start-in-insert-state-maybe-h)
  (setq magit-diff-refine-hunk 'all))

(after! magit-todos
  ;; Ignore concatenated/minified files when searching for todos
  (setq magit-todos-rg-extra-args '("-M 512")))

(map!
 (:after diff-mode
   (:map diff-mode-map
     :nm "{" #'diff-hunk-prev
     :nm "}" #'diff-hunk-next))

 (:leader
   (:prefix "g"
     :desc "Git blame (follow copy)" "B" #'+robbert/magit-blame-follow-copy)))

(use-package! page-break-lines
  :config
  (add-hook! (emacs-lisp-mode view-mode) 'turn-on-page-break-lines-mode))

;; Auto reload PDFs
(add-hook 'doc-view-mode-hook #'auto-revert-mode)

(after! wordnut
  (set-popup-rule! "^\\*WordNut\\*$" :size 0.3 :select t))

(after! vterm
  (add-hook! 'vterm-mode-hook (blink-cursor-mode -1)))

(after! agda2-mode
  (set-lookup-handlers! 'agda2-mode :definition #'agda2-goto-definition-keyboard)

  (map! :map agda2-mode-map
        "C-c w" #'+robbert/agda-insert-with

        (:localleader
          :desc "Insert 'with'" "w" #'+robbert/agda-insert-with)))

(add-to-list 'auto-mode-alist '("\\.csproj$" . nxml-mode))
(add-to-list 'auto-mode-alist '("\\.ruleset$" . nxml-mode))

(after! csharp-mode
  (set-electric! 'csharp-mode :chars '(?\n ?\{)))

(after! omnisharp
  ;; Killing the omnisharp server doesn't work as well when constantly switching
  ;; branches and previewing files
  (add-hook! 'csharp-mode-hook :append
    (remove-hook 'kill-buffer-hook #'omnisharp-stop-server t))

  (map! :map omnisharp-mode-map
        :nv [M-return]                 #'omnisharp-run-code-action-refactoring

        (:localleader
          :desc "Refactor this"  "SPC" #'omnisharp-run-code-action-refactoring
          :desc "Restart server" "s"   #'omnisharp-start-omnisharp-server)) )

(add-to-list 'auto-mode-alist '("\\.service$" . conf-unix-mode))
(add-to-list 'auto-mode-alist '("\\.socket$" . conf-unix-mode))
(add-to-list 'auto-mode-alist '("\\.target$" . conf-unix-mode))
(add-to-list 'auto-mode-alist '("index\\.theme$" . conf-unix-mode))
(add-to-list 'auto-mode-alist '("\\.timer$" . conf-unix-mode))

(after! haskell-mode
  (set-formatter! 'hindent '("hindent") :modes '(haskell-mode literate-haskell-mode))
  (add-to-list '+format-on-save-enabled-modes 'haskell-mode t)

  ;; Improve code navigation in Haskell buffers
  (add-hook 'haskell-mode-hook #'haskell-decl-scan-mode)
  (add-hook 'haskell-mode-hook #'haskell-indentation-mode)
  (setq-hook! 'haskell-mode-hook
    outline-regexp "-- \\*+"
    ;; `haskell-mode' sets the default tab width to eight spaces for some reason
    tab-width 2)

  (map! :map haskell-mode-map
        [remap evil-open-above] #'+robbert/haskell-evil-open-above
        [remap evil-open-below] #'+robbert/haskell-evil-open-below))

;; TODO: Replace by something else since intero's been deprecated
(after! intero
  (flycheck-add-next-checker 'intero '(warning . haskell-hlint))

  (map! :map intero-mode-map
        ;; We can't just set the documentation function here since `intero-info'
        ;; does its own buffer management
        [remap +lookup/documentation] #'intero-info))

(add-to-list 'auto-mode-alist '("\\.ag$" . +robbert/basic-haskell-mode))

(after! ein
  (setq ein:jupyter-default-notebook-directory nil
        ein:slice-image '(10 nil)))

(map!
 (:after ein-multilang
   (:map ein:notebook-multilang-mode-map
     :ni  [C-return] #'ein:worksheet-execute-cell
     :ni  [S-return] #'ein:worksheet-execute-cell-and-goto-next
     :nvi [backtab]  #'ein:pytools-request-tooltip-or-help
     :n   "gj"       #'ein:worksheet-goto-next-input
     :n   "gk"       #'ein:worksheet-goto-prev-input
     :nv  "M-j"      #'ein:worksheet-move-cell-down
     :nv  "M-k"      #'ein:worksheet-move-cell-up
     :nv  "C-s"      #'ein:notebook-save-notebook-command
     (:localleader
       "y" #'ein:worksheet-copy-cell
       "p" #'ein:worksheet-yank-cell
       "d" #'ein:worksheet-kill-cell)))

 (:after ein-traceback
   (:map ein:traceback-mode-map
     (:localleader
       "RET" #'ein:tb-jump-to-source-at-point-command
       "n"   #'ein:tb-next-item
       "p"   #'ein:tb-prev-item
       "q"   #'bury-buffer)))

 (:leader
   (:prefix "o"
     (:prefix-map ("j" . "jupyter")
       :desc "Open in browser" "b" #'ein:notebook-open-in-browser
       :desc "Open this file"  "f" #'ein:notebooklist-open-notebook-by-file-name
       :desc "Login and open"  "o" #'ein:jupyter-server-login-and-open
       :desc "Start server"    "s" #'ein:jupyter-server-start))))

(use-package! kotlin-mode)

(after! latex-mode
  (set-electric! 'latex-mode :chars '(?\n ?\{)))

(after! markdown-mode
  (add-hook 'markdown-mode-hook #'doom-disable-delete-trailing-whitespace-h))

(setq org-directory (expand-file-name "~/Documenten/notes/"))

(after! org
  (setq org-export-with-smart-quotes t
        org-imenu-depth 3
        org-highlight-latex-and-related '(latex script entities))

  (set-face-attribute
   'org-todo nil :foreground (doom-darken (face-foreground 'org-todo) 0.2))

  ;; Org mode should use komascript for LaTeX exports and code fragments should be colored
  (with-eval-after-load 'ox-latex
    (add-to-list 'org-latex-classes
                 '("koma-article"
                   "\\documentclass[parskip=half]{scrartcl}
                    [DEFAULT-PACKAGES] [PACKAGES]
                    \\setminted{frame=leftline,framesep=1em,linenos,numbersep=1em,style=friendly}
                    \\setminted[python]{python3}
                    [EXTRA]"
                   ("\\section{%s}" . "\\section*{%s}")
                   ("\\subsection{%s}" . "\\subsection*{%s}")
                   ("\\subsubsection{%s}" . "\\subsubsection*{%s}")
                   ("\\paragraph{%s}" . "\\paragraph*{%s}")
                   ("\\subparagraph{%s}" . "\\subparagraph*{%s}")))
    (add-to-list 'org-latex-packages-alist '("dutch" "babel"))
    (add-to-list 'org-latex-packages-alist '("newfloat" "minted"))
    (setq org-latex-default-class "koma-article"
          org-format-latex-options
          (plist-put org-format-latex-options
                     :scale (* 1.25 +scaling-ratio))
          org-latex-caption-above nil
          org-latex-listings 'minted
          ;; latexmk tends to play along nicer than pdflatex
          org-latex-pdf-process '("latexmk -f -pdf %f"))))

(after! evil-org
  (setq evil-org-use-additional-insert t)
  (add-to-list 'evil-org-key-theme 'additional)
  (evil-org--populate-additional-bindings)

  (map! :map evil-org-mode-map
        ;; Doom changes c-return to always create new list items when inside of a
        ;; list, but M-return already does this so I prefer the old behaviour
        [C-return] (evil-org-define-eol-command org-insert-heading-respect-content)
        :ni [M-return] #'+robbert/evil-org-always-open-below))

(after! ox-pandoc
  ;; Doom explicitely adds the deprecated `parse-raw' option
  (setq org-pandoc-options '((standalone . t) (mathjax . t))))

(use-package! phpcbf
  :config
  (set-formatter! 'php-mode #'phpcbf))

(setq-hook! 'rustic-mode-hook fill-column 79)

(add-to-list 'auto-mode-alist '("Pipfile$" . conf-toml-mode))
(add-to-list 'auto-mode-alist '("Pipfile\\.lock$" . json-mode))

(after! python
  ;; Set this to `django' to force docstring to always be on multiple lines
  (setq python-fill-docstring-style 'onetwo)

  (setq lsp-python-ms-nupkg-channel "beta")
  (after! lsp-ui
    ;; Also show flake8 warnings since mspyls misses a lot of things
    (flycheck-add-next-checker 'lsp-ui '(warning . python-flake8)))

  ;; Electric indent on `:' only really works for `else' clauses and makes
  ;; defining functions a lot harder than it should be
  (set-electric! 'python-mode :words '("else:"))
  ;; Disable the default template, as we don't need a hashbang in every Python
  ;; file
  (set-file-template! 'python-mode :ignore t)

  (map! :map python-mode-map
        (:localleader
          (:prefix ("r" . "REPL send")
            :desc "Buffer"   "b" #'python-shell-send-buffer
            :desc "Function" "f" #'python-shell-send-defun
            :desc "Region"   "r" #'python-shell-send-region))))

(setq-hook! 'rustic-mode-hook fill-column 100)

(setq lsp-rust-server 'rust-analyzer)
(after! rustic-mode
  ;; RLS, for some reason, always wants to use the stable compiler's source code
  ;; even when specifically running the nightly RLS
  ;; XXX: Is this still needed?
  (setenv "RUST_SRC_PATH"
          (expand-file-name "~/.rustup/toolchains/nightly-x86_64-unknown-linux-gnu/lib/rustlib/src/rust/src")))

;; TODO: This is probably done differently for rust-analyzer
(add-hook! 'rustic-mode-hook :append
  (let ((preferences (make-hash-table)))
    (puthash "clippy_preference" "on" preferences)
    (lsp--set-configuration `(:rust ,preferences))))

(setq css-indent-offset 2)

(after! css-mode
  (set-electric! 'css-mode :chars '(?})))

(use-package! ggtags
  :commands (ggtags-find-tag-dwim ggtags-find-reference ggtags-mode)
  :hook (scss-mode . ggtags-mode)
  :config
  ;; Sort global results by nearness. This helps when editing Sass, as the
  ;; default variables will have a lower priority.
  (setq ggtags-sort-by-nearness t)

  ;; Fix gtags for Sass. Pygments has got a parser that works great, but it
  ;; doesn't use the dollar sign prefix. We'll have to manually add the jump
  ;; handler to scss-mode as there are not any yet.
  (add-hook! 'scss-mode-hook (modify-syntax-entry ?$ "'") (modify-syntax-entry ?% "."))

  ;; Completion is handled through `company-capf', though for scss in particular
  ;; we just want to use tags together with the lsp server as the built in
  ;; support misses a lot of variables
  (set-lookup-handlers! 'ggtags-mode
    :definition #'ggtags-find-tag-dwim
    :references #'ggtags-find-reference))

;; We can't apply our configuration in a simple hook as lsp-mode gets loaded
;; asynchronously
(add-hook! 'lsp-managed-mode-hook :append
  (cond ((derived-mode-p 'scss-mode)
         ;; `lsp-mode' overrides our tags here, but we need those for variable name
         ;; completions as `lsp-css' isn't that smart yet
         (setq company-backends '((:separate company-capf
                                             company-lsp
                                             company-yasnippet))
               ;; lsp-css's auto completion returns so many results that
               ;; company struggles to keep up
               company-idle-delay 0.3
               completion-at-point-functions '(ggtags-completion-at-point)))))

(map! :map scss-mode-map
      (:localleader
        :desc "Generate tags" "t" #'+robbert/generate-scss-tags))

;; TODO: Refactor this to use the new `+lookup/file' function
(require 'ffap)
(add-to-list 'ffap-alist '(scss-mode . +robbert/scss-find-file))

(setq sh-basic-offset 2)

(after! fish-mode
  (set-electric! 'fish-mode :words '("else" "end")))

(after! format-all
  (set-formatter! 'shfmt
    '("shfmt"
      "-i" "2"
      ;; Mode selection copied from the default config
      ("-ln" "%s" (cl-case (and (boundp 'sh-shell) (symbol-value 'sh-shell))
                    (bash "bash") (mksh "mksh") (t "posix"))))
    :modes 'sh-mode))

(setq js-indent-level 2
      typescript-indent-level 2)

(map!
 (:after tide
   (:map tide-mode-map
     :nv [M-return] #'tide-fix
     (:localleader
       :desc "JSDoc template" "c"   #'tide-jsdoc-template
       :desc "Restart"        "s"   #'tide-restart-server
       :desc "Fix issue"      "RET" #'tide-fix
       :desc "Refactor..."    "SPC" #'tide-refactor))))

(after! emmet-mode
  (setq emmet-self-closing-tag-style ""))

(after! (yasnippet web-mode)
  (remhash 'web-mode yas--parents))

(setq web-mode-markup-indent-offset 2
      web-mode-css-indent-offset 2
      web-mode-comment-style 2)

(after! web-mode
  ;; Make sure that attributes are indented when breaking lines (e.g. long lists
  ;; of classes)
  (set-electric! 'web-mode :chars '(?\<) :words '("endfor" "endif" "endblock"))

  ;; Editorconfig tells web-mode to indent attributes instead of aligning
  (add-hook! 'web-mode-hook :append
    (setq web-mode-attr-indent-offset nil
          web-mode-attr-value-indent-offset nil
          web-mode-block-padding 0)))

(map!
 (:after emmet-mode
   (:map emmet-mode-keymap
     :i [backtab] #'emmet-expand-line))

 (:after web-mode
   (:map web-mode-map
     "M-/" nil

     ;; In HTML we DO want to automatically indent broken 'strings', as these
     ;; are likely long attributes like a list of classes
     [remap newline] #'+robbert/newline-and-indent-always)))

(autoload 'web-mode-set-engine "web-mode" nil t)

(def-project-mode! +web-django-mode
  :modes '(web-mode js-mode coffee-mode css-mode haml-mode pug-mode)
  :files ("manage.py")
  :on-enter (web-mode-set-engine "django"))

(add-to-list '+format-on-save-enabled-modes 'yaml-mode t)
