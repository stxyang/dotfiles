;;; lgfang.init.el --- my configuration file

;; Created:  Lungang Fang 2004
;; Modified: Lungang Fang 2023-09-15T14:53:46+1000>

;;; Commentary:

;; My Emacs configure

;;; Code:

;;; Paths

(defvar my-emacs-base
  (file-name-as-directory (expand-file-name "~/.emacs.d")))
(defvar my-extension-path
  (file-name-as-directory (expand-file-name "~/.emacs.d/emacs-extensions")))
(defvar my-elisp-path
  (file-name-as-directory (expand-file-name "~/.emacs.d/my-elisp")))
(defvar my-personal-path
  (file-name-as-directory (expand-file-name "~/mynotes/personal")))
(defvar my-backward-path
  (file-name-as-directory (concat my-extension-path "backward-compatibility")))

;; load path
(add-to-list 'load-path my-extension-path)
(add-to-list 'load-path my-backward-path t)
(add-to-list 'load-path my-elisp-path t)

;; exec path
(cond
 ((eq system-type 'cygwin)
  (setq exec-path
        (append '("/cygdrive/c/Program Files/Mozilla Firefox") exec-path)))
 ((eq system-type 'darwin)
  ;; cocoa emacs does not inherit PATH from Terminal setting
  (setenv "PATH" (concat "/usr/local/bin:" (getenv "PATH")))
  (setq exec-path (append '("/usr/local/bin") exec-path))))

;; ;; woman path
;; (setq woman-manpath '("patha" "pathb"))

;;; package

(require 'package)
(add-to-list 'package-archives '("melpa" . "https://melpa.org/packages/") t)
(setq package-user-dir "~/.emacs.d/emacs-extensions/elpa")
(package-initialize)

;;; cygwin wrappers
;; NOTE: put this section in the begining of my configure so that files I hacked
;; can make used of these functions.

(defun cygpath (path)
  "Convert the PATH to  Java etc. does not read the cygwin PATH."
  (if (eq system-type 'cygwin)
      (substring ;; delete trailing new-line added
       (shell-command-to-string (format "cygpath -m \"%s\"" path)) 0 -1)
  path))

;;; Personal Info

;; Confidential info saved in this file.
(unless (load (concat my-personal-path "my-confidential") t nil nil)
  ;; If this file doesn't exist, set dumb values to allow emacs to start.
  (setq user-full-name "Full Name" user-mail-address "you@email.com"))

(setq
      ;; url-proxy-services '(("http" . "localhost:8888"))

      ;; world time 'M-x display-time-world', /usr/share/zoneinfo
      display-time-world-time-format "%Z\t%z\t%a %d %b %R"
      display-time-world-list '(("Australia/Sydney" "Sydney")
                                ("UTC" "UTC")
                                ("America/New_York" "New York")
                                ("America/Chicago" "Chicago")
                                ("America/Los_Angeles" "Palo Alto")
                                ("Asia/Shanghai" "Beijing")
                                ("Asia/Kolkata" "Delhi")
                                ("Asia/Tel_Aviv" "Tel Aviv")
                                ("Europe/London" "Dublin"))
      )

;;; Language Environment - these settings are normally no longer needed

;; (if (eq system-type 'windows-nt)
;;     (if (>= emacs-major-version 23)
;;         (set-language-environment 'Chinese-GB18030)
;;       (set-language-environment 'Chinese-GB)))

;; (set-language-environment 'utf-8)
;; (set-keyboard-coding-system 'utf-8)
;; (prefer-coding-system 'utf-8)
;; ;; set terminal coding system to utf-8 explictly to display unicode chars
;; ;; (including emojis/Chinese chars) correctly. This is needed when utf-8 is
;; ;; supported but emacs does not detect and set set it correctly due to wrong
;; ;; shell locale etc.
;; (set-terminal-coding-system 'utf-8)

;;; global key bindings

(when (eq system-type 'darwin)          ; OSX
  ;; ;; Not all Emacs builds support this modifier remap. At the moment, it works
  ;; ;; for my GUI Emacs. For terminal emacs, please remap modifiers in
  ;; ;; corresponding terminal emulator instead.
  ;; (setq mac-option-modifier 'control mac-command-modifier 'meta)

  (unless (display-graphic-p)
    ;; In OSX terminal, trackpad gestures for up/down mapped to mouse-4/5
    (define-key global-map [mouse-4] '(lambda () (interactive) (scroll-down 1)))
    (define-key global-map [mouse-5] '(lambda () (interactive) (scroll-up 1)))))

;; F1-F12
(define-key global-map [f1] 'lgfang-recentf-open)
(define-key global-map [f2] 'ido-goto-symbol)
;; f3/f4: define keyboard macros
(define-key global-map [f5] 'whitespace-cleanup)
(define-key global-map [f7] 'flyspell-mode)
(define-key global-map [f8] 'bury-buffer)
;; f9 to clock in last, `C-u f9' to select from recent tasks.
(define-key global-map [f9] 'org-clock-in-last)
;; shift-f9 to clock out
(define-key global-map (kbd "S-<f9>") 'org-clock-out)
(define-key global-map [f10] 'org-capture)
;; f11 : reserved for twm/tmux etc.
;; f12 : reserved for twm/tmux etc.

;; C-, M-, C-M- ... :(
(define-key global-map (kbd "C-c p") 'flymake-goto-prev-error)
(define-key global-map (kbd "C-c n") 'flymake-goto-next-error)
(define-key global-map (kbd "C-c m") 'flymake-display-err-menu-for-current-line)
(define-key global-map (kbd "C-x C-b") 'ibuffer)
(define-key global-map (kbd "C-x c l") 'org-store-link)
(define-key global-map (kbd "C-x c a") 'org-agenda)
(define-key global-map (kbd "C-x c o") 'org-open-at-point-global)
(define-key global-map (kbd "M-/") 'hippie-expand)
(define-key global-map (kbd "M-g c") 'move-to-column)
(define-key global-map (kbd "M-g ]") 'lgfang-goto-page)
(define-key global-map (kbd "C-h d") 'sdcv-search-pointer)
(define-key global-map (kbd "C-h D") 'sdcv-search-pointer+)

;; Split & Resize Windows
(define-key global-map (kbd "C-x |") 'split-window-horizontally)
(define-key global-map (kbd "C-x _") 'split-window-vertically)
(define-key global-map (kbd "C-{") 'shrink-window-horizontally)
(define-key global-map (kbd "C-}") 'enlarge-window-horizontally)
(define-key global-map (kbd "C-^") 'enlarge-window)

;; Move cursor between buffers
(define-key global-map (kbd "C-x <up>") 'windmove-up)
(define-key global-map (kbd "C-x <down>") 'windmove-down)
(define-key global-map (kbd "C-x <right>") 'windmove-right)
(define-key global-map (kbd "C-x <left>") 'windmove-left)

;; Swap buffers
(define-key global-map (kbd "C-x S-<up>"   ) 'buf-move-up)
(define-key global-map (kbd "C-x S-<down>" ) 'buf-move-down)
(define-key global-map (kbd "C-x S-<right>") 'buf-move-right)
(define-key global-map (kbd "C-x S-<left>" ) 'buf-move-left)

;; Change Layout
(define-key global-map (kbd "C-\\") 'tiling-cycle)
(define-key global-map (kbd "C-x C-S-<up>") 'tiling-tile-up)
(define-key global-map (kbd "C-x C-S-<down>") 'tiling-tile-down)
(define-key global-map (kbd "C-x C-S-<right>") 'tiling-tile-right)
(define-key global-map (kbd "C-x C-S-<left>") 'tiling-tile-left)

;; ;; Another type of representation of same keys, in case your terminal
;; ;; doesn't recognize above key-binding. Tip: C-h k C-up etc. to see into
;; ;; what your terminal tranlated the key sequence.
;; (define-key global-map (kbd "M-[ a"     ) 'windmove-up)
;; (define-key global-map (kbd "M-[ b"     ) 'windmove-down)
;; (define-key global-map (kbd "M-[ c"     ) 'windmove-right)
;; (define-key global-map (kbd "M-[ d"     ) 'windmove-left)
;; (define-key global-map (kbd "ESC <up>"   ) 'buf-move-up)
;; (define-key global-map (kbd "ESC <down>" ) 'buf-move-down)
;; (define-key global-map (kbd "ESC <right>") 'buf-move-right)
;; (define-key global-map (kbd "ESC <left>" ) 'buf-move-left)
;; (define-key global-map (kbd "ESC M-[ a" ) 'tiling-tile-up)
;; (define-key global-map (kbd "ESC M-[ b" ) 'tiling-tile-down)
;; (define-key global-map (kbd "ESC M-[ c" ) 'tiling-tile-right)
;; (define-key global-map (kbd "ESC M-[ d" ) 'tiling-tile-left)

;;; abbrev - conflicts with auto-complete-mode, use yasnippet instead.

;;; ansi color code handling
(defun ansi-color-after-scroll (window start)
  "Used by ansi-color-mode minor mode"
  (let ((ansi-color-context-region nil))
    (ansi-color-apply-on-region start (window-end window t) t)))

(define-minor-mode ansi-color-mode
  "A very primitive minor mode to view log files containing ANSI color codes.

Pros: this minor mode runs `ansi-color-apply-on-region' lazily,
i.e. only the visible part of the buffer. Hence, it does NOT
freeze Emacs even if the log file is huge.

Cons: a) when the minor code is toggled off, it does not undo
what has already been ansi colorized. b) assumes the buffer
content etc. does not change. c) jumping to random places within
the buffer may incur incorrect/incomplete colorization.

How to install: put this code into your init.el, then evaluate it or
restart Emacs for the code to take effect.

How to use: in the log buffer of need run `M-x ansi-color-mode'.
Alternatively, feel free to enable this minor mode via mode hooks
so that you needn't enable it manually.

-- lgfang
"
  :global nil
  :lighter ""
  (if ansi-color-mode
      (progn
        (ansi-color-apply-on-region (window-start) (window-end) t)
        (add-hook 'window-scroll-functions 'ansi-color-after-scroll 80 t))
    (remove-hook 'window-scroll-functions 'ansi-color-after-scroll t)))

;; process & render color codes in the compilation buffer. NOTE:
;; ansi-color-compilation-filter is unavailable before emacs 28.
(add-hook 'compilation-filter-hook 'ansi-color-compilation-filter)

;;; ascii mode
(autoload 'ascii-display "ascii" "Toggle ASCII code display." t)

;;; asm mode
(setq-default asm-comment-char 35)      ; 35 -> ascii code for '#'

;;; auto-complete
(let ((my-path-to-auto-complete (concat my-extension-path "auto-complete")))
  (add-to-list 'load-path my-path-to-auto-complete)
  (when (require 'auto-complete-config nil t)
    (add-to-list 'ac-dictionary-directories
                 (concat my-path-to-auto-complete "/dict"))
    (add-to-list 'ac-dictionary-directories
                 (concat my-extension-path "/my-ac-dict"))
    (add-to-list 'ac-sources ac-source-yasnippet)
    (define-key ac-complete-mode-map "\C-s" 'ac-next)
    (define-key ac-complete-mode-map "\C-r" 'ac-previous)
    ;; (setq-default ac-sources ac-sources) ; works, though tricky
    ;; ;; common source
    ;; (setq-default ac-sources '(ac-source-imenu ac-source-abbrev
    ;;               ac-source-words-in-buffer
    ;;               ac-source-files-in-current-dir ac-source-filename
    ;;               ))
    (ac-config-default)
    (setq ac-dwim t
          ac-auto-start 2               ; start ac after 3 chars
          ;; modes that automatically startup auto-complete-mode
          ac-modes '(asm-mode
                     c++-mode ;; c-mode
                     cc-mode
                     emacs-lisp-mode
                     java-mode
                     lisp-interaction-mode
                     lisp-mode
                     makefile-mode
                     makefile-gmake-mode
                     org-mode
                     cperl-mode
                     python-mode
                     sh-mode
                     tcl-mode
                     org-mode
                     text-mode
                     conf-mode))
    ;; (global-set-key "\M-/" 'ac-start)
    (dolist (hook '(emacs-lisp-mode-hook
                    lisp-interaction-mode-hook
                    shell-mode-hook
                    tcl-mode-hook))
      (add-hook hook (lambda()
                       (add-to-list 'ac-sources ac-source-filename))))))

;;; auto insert
(setq auto-insert t
      auto-insert-directory (concat my-emacs-base "auto-insert/"))
(add-hook 'find-file-hooks 'auto-insert)

;;; auto mode list
(setq auto-mode-alist (append
                       '(("\\.[xX]\\'" . c-mode)
                         ("\\.mak\\'" . makefile-mode)
                         ("\\.make\\'" . makefile-mode)
                         ("\\.gdb\\'" . gdb-script-mode)
                         ("\\.v\\'" . verilog-mode)
                         ("\\.ldif\\'" . ldap-mode))
                       auto-mode-alist))

;;; auto-revert when file modified by other
(global-auto-revert-mode t)

;;; backup files
(setq make-backup-files t
      version-control 'never
      backup-by-copying-when-linked t)

;;; bbdb & bbdb-vcard-export
(when (require 'bbdb nil t)
  (require 'qp)
  (bbdb-initialize 'gnus 'message)
  (setq bbdb-default-area-code 532
        bbdb-default-country "China"
        bbdb-file (concat my-personal-path "my-bbdb")
        bbdb-north-american-phone-numbers-p nil
        bbdb-user-mail-names (regexp-opt
                              '("myname@163.com" "another@smth.org"))
        bbdb-complete-name-allow-cycling t
        bbdb-use-pop-up nil)
  ;;  (add-hook 'gnus-startup-hook 'bbdb-insinuate-gns)

  (if (require 'bbdb-vcard nil t)
      (setq bbdb-vcard-export-coding-system 'utf-8-unix))

  (defun lgfang-bbdb-to-vcards()
    "Adapted to nokia E72"
    (interactive)
    (let ((path "~/tmp/exported-vcards/"))
      (bbdb "" nil)                       ; have to run this first
      (bbdb-vcard-export path t t)
      (mapc (lambda(file)
              (with-temp-buffer
                (insert-file-contents-literally file)
                (quoted-printable-encode-region (point-min) (point-max))
                ;; delete useless field
                (replace-regexp "^\\(FN\\|NICKNAME\\):.*$" ""
                                nil (point-min) (point-max))
                ;; corrections of quoted-printable-encode-region
                (replace-regexp "^VERSION:3.0" "VERSION:2.1"
                                nil (point-min) (point-max))
                (replace-string ";TYPE=3D" ";"
                                nil (point-min) (point-max))
                (replace-regexp "^EMAIL:" "EMAIL;INTERNET:"
                                nil (point-min) (point-max))
                (replace-regexp "^\\(ADR[^:]*\\|N\\|ORG\\):"
                                "\\1;CHARSET=UTF-8;ENCODING=QUOTED-PRINTABLE:"
                                nil (point-min) (point-max))

                (write-region (point-min) (point-max) file nil)))
            (file-expand-wildcards (concat path "*.vcf"))))))

;;; bookmark/bookmark+ - breaks org-mode + flyspell
;; Note: if `C-x r m` (i.e. bookmark-set) emits "end of file during parsing",
;; review (or simply delete) ~/.emacs.d/bookmarks.

(when (require 'browse-kill-ring nil t)
  (browse-kill-ring-default-keybindings))

(unless (eq system-type 'darwin)          ; OSX
  (setq browse-url-browser-function 'browse-url-firefox))

(require 'buffer-move nil t)

;;; c mode configuration
(defconst lgfang-c-style
  '((c-tab-always-indent        . t)
    (c-basic-offset . 4)
    (c-ignore-auto-fill . nil)
    (c-comment-only-line-offset . (0 . 0))
    (c-hanging-braces-alist     . ((substatement-open after before)
                                   (brace-list-open)))
    (c-hanging-colons-alist     . ((member-init-intro before)
                                   (inher-intro)
                                   (case-label after)
                                   (label after)
                                   (access-label after)))
    (c-cleanup-list             . (scope-operator
                                   empty-defun-braces
                                   defun-close-semi))
    (c-offsets-alist . ((knr-argdecl-intro . 5)
                        (arglist-intro . +)
                        (arglist-close . c-lineup-close-paren)
                        (inclass . +)
                        (member-init-intro . +)
                        (statement-block-intro . +)
                        (defun-block-intro . +)
                        (substatement-open . 0)
                        (label . 0)
                        (statement-case-open . +)
                        (statement-case-intro . +)
                        (case-label . 0)
                        (statement-cont . c-lineup-math)
                        (inline-open . 0)
                        (brace-list-open . +)
                        (topmost-intro-cont . 0)
                        (c . 1) ; "c" for continue of comment, not "c
                                ; programming language"
                        ))
    (c-special-indent-hook . c-gnu-impose-minimum)
    (c-block-comment-prefix . "lgf: ")
    (c-comment-prefix-regexp . ((awk-mode . "#+(lgf: )?")
                                (other ."lgf: \\|//+\\|\\**")))
    ;; go to this file and test if c block comments works
    ;; [[file:./patches/comments-test.c]]
    (c-echo-syntactic-information-p . t))
  "lgfang's C Programming Style")
(c-add-style "lgfang" lgfang-c-style nil)

(add-hook 'c-mode-common-hook
          (lambda ()
            (c-set-style "lgfang")
            (c-toggle-hungry-state 1)
            (hs-minor-mode 1)
            ;; (eldoc-mode 1)
            ))
;; Can't hook imenu-add-menubar-index to c-mode-common-hook since awk mode don't
;; support it
(dolist (hook '(c-mode-hook c++-mode-hook java-mode-hook))
  (add-hook hook 'imenu-add-menubar-index))

;;; Calendar Chinese & Aussie NSW Holidays
(when (require 'cal-china-x nil t)
  (defun holiday-new-year-bank-holiday ()
    "This & next copied from https://emacs.stackexchange.com/a/45352/9670"
    (let ((m displayed-month) (y displayed-year))
      (calendar-increment-month m y 1)
      (when (<= m 3)
        (let ((d (calendar-day-of-week (list 1 1 y))))
          (cond ((= d 6)
                 (list (list (list 1 3 y)
                             "NSW: New Year's Day (day in lieu)")))
                ((= d 0)
                 (list (list (list 1 2 y)
                             "NSW: New Year's Day (day in lieu)"))))))))
  (defun holiday-christmas-bank-holidays ()
    (let ((m displayed-month) (y displayed-year))
      (calendar-increment-month m y -1)
      (when (>= m 10)
        (let ((d (calendar-day-of-week (list 12 25 y))))
          (cond ((= d 5)
                 (list (list (list 12 28 y)
                             "NSW: Boxing Day (day in lieu)")))
                ((= d 6)
                 (list (list (list 12 27 y)
                             "NSW: Boxing Day (day in lieu)")
                       (list (list 12 28 y)
                             "NSW: Christmas Day (day in lieu)")))
                ((= d 0)
                 (list (list (list 12 27 y)
                             "NSW: Christmas Day (day in lieu)"))))))))
  (setq mark-holidays-in-calendar t
        holiday-nsw-holidays '((holiday-fixed 1 1 "NSW: New Year's Day")
                               (holiday-new-year-bank-holiday)
                               (holiday-fixed 1 26 "NSW: Austrlia Day")
                               (holiday-easter-etc -2 "NSW: Good Friday")
                               (holiday-easter-etc -1 "NSW: Easter Saturday")
                               (holiday-easter-etc 0 "NSW: Easter Sunday")
                               (holiday-easter-etc 1 "NSW: Easter Monday")
                               (holiday-fixed 4 25 "NSW: Anzac Day")
                               (holiday-float 6 1 2 "NSW: Queen's Birthday")
                               (holiday-float 10 1 1 "NSW: Labour Day")
                               (holiday-fixed 12 25 "NSW: Christmas Day")
                               (holiday-fixed 12 26 "NSW: Boxing Day")
                               (holiday-christmas-bank-holidays))
        holiday-other-holidays '((holiday-lunar 1 15 "元宵节")
                                 (holiday-fixed 10 31 "Halloween"))
        calendar-holidays (append
                           cal-china-x-chinese-holidays
                           holiday-nsw-holidays
                           holiday-other-holidays
                           )))

;;; ccrypt: auto encrypt/decrypt files using ccrypt
(require 'ps-ccrypt nil t)

;;; Clipboard
;; from/to tmux buffer
(defun lgfang-send-to-tmux ()
  "Send content of active region or HEAD of the kill-ring to
tmux's buffer"
  (interactive)
  (let ((file (make-temp-file "/tmp/emacs-to-tmux.clip")))
    (if (region-active-p) (kill-ring-save (region-beginning) (region-end)))
    (with-temp-file file (insert-for-yank (current-kill 0)))
    (call-process "tmux" nil nil nil "load-buffer" file)
    (delete-file file)))

(defun lgfang-get-from-tmux ()
  "Get current tmux buffer."
  (interactive)
  (call-process "tmux" nil t nil "show-buffer"))

;; aliases to type less characters
(fset 'to-tmux 'lgfang-send-to-tmux)
(fset 'from-tmux 'lgfang-get-from-tmux)

;; From/to system clipboard. To use it in tmux, upgrade to tmux 2.6+.
(when (eq system-type 'darwin)
  (defun copy-from-osx ()
    (let ((tramp-mode nil) (default-directory "~"))
      (shell-command-to-string "pbpaste")))

  (defun paste-to-osx (text &optional push)
    (let ((process-connection-type nil))
      (let ((proc (start-process "pbcopy" "*Messages*" "pbcopy")))
        (process-send-string proc text)
        (process-send-eof proc))))

  (setq interprogram-cut-function 'paste-to-osx)
  (setq interprogram-paste-function 'copy-from-osx))

;;; color theme
(add-to-list 'custom-theme-load-path (concat my-extension-path "themes"))
(if (display-graphic-p) (load-theme 'solarized-dark t) (load-theme 'wombat t))
;; Themes I recommend: wombat, solarized-dark, tango-dark, tango, gnome2. For
;; themes ported to emacs24: https://github.com/emacs-jp/replace-colorthemes

(column-number-mode t)

(setq comment-style 'extra-line)

;;; compilation
(eval-after-load "compile"
  '(progn
     (setq compile-command "clang++ --std=c++11 "
           ;; compile-command "python -m unittest "
           compilation-scroll-output t)
     (define-key compilation-mode-map "n" 'next-error-no-select)
     (define-key compilation-mode-map "p" 'previous-error-no-select)
     (define-key compilation-mode-map " "
       (lambda () (interactive)
         (save-selected-window (compile-goto-error))))
     (define-key compilation-mode-map [return] 'compile-goto-error)
     (define-key compilation-mode-map "o"
       (lambda () (interactive)
         (compile-goto-error) (delete-other-windows)))
     (define-key compilation-mode-map "q" 'quit-window)))

;;; Copy/cut current line
;;; from http://blog.waterlin.org
(defadvice kill-ring-save (before slickcopy activate compile)
  "If region not active, copy current line."
    (interactive
     (if mark-active (list (region-beginning) (region-end))
       (list (line-beginning-position)
             (line-beginning-position 2)))))

(defadvice kill-region (before slickcut activate compile)
  "If region not active, kill current line."
    (interactive
     (if mark-active (list (region-beginning) (region-end))
       (list (line-beginning-position)
             (line-beginning-position 2)))))

;;; Current path+filename
(defun current-file-path ()
  "Copy current path/to/file_name to the kill ring."
  (interactive)
  (let ((string (buffer-file-name)))
    (message (concat "current file: " string))
    (kill-new string)))

;;; delete selection typed text replaces the selection (marked region)
;; (delete-selection-mode 0)

;;; default major mode
;; (setq default-major-mode 'text-mode)

;;; desktop save, use savehist etc. instead
(desktop-save-mode -1)

;;; dired etc.
(setq dired-recursive-copies 'top dired-recursive-deletes 'top)
(require 'dired-x)
(setq-default dired-omit-files-p t)
(setq dired-omit-files (concat dired-omit-files "\\|^\\..+$"))
;; guess of '!' action
(add-to-list 'dired-guess-shell-alist-user
             (list "\\.\\(avi\\|mkv\\|mpg\\|rmvb\\|rm\\)\\'" "mplayer"))
(add-to-list 'dired-guess-shell-alist-user (list "\\.\\(rar\\)\\'" "7z x"))
(when (require 'dired-details nil t) (dired-details-install))

;;; ediff
(setq
 ;; ediff-diff-options "-w"
 ;; do not pop a frame for ediff
 ediff-window-setup-function 'ediff-setup-windows-plain
 ;; my screen is large enough
 ediff-split-window-function 'split-window-sensibly)

;;; elisp
(add-hook 'emacs-lisp-mode-hook
          (lambda() (imenu-add-menubar-index) (hs-minor-mode 1)))

;;; eglot: an LSP client
;; (add-hook 'eglot-managed-mode-hook
;;           (lambda()
;;             ;; eglot sets it to nil but I like t as it shows me what the
;;             ;; identifier at point is.
;;             (setq xref-prompt-for-identifier t)
;;             ))

;; Note for Eglot + Pyright on MacOS: you may want to increase the "open files"
;; limit (`ulimit -n'), say to 65536. The default value is 256, which pyright
;; easily hits when the python project is non-trivial. (You'll see the error
;; message if you set debug-on-error to t and then enable eglot.).

;;; emms configure in another file
(load "lgfang.emms" t nil nil)

;;; ERC - use RCIRC instead for cleaner code base

;;; eshell: restore arrows(up/down) to their orginal functions
(add-hook 'eshell-mode-hook
          (lambda ()
            (define-key eshell-mode-map [up] 'previous-line)
            (define-key eshell-mode-map [down] 'next-line)))
;; multi-eshell
(when (require 'multi-eshell nil t)
  (setq multi-eshell-name "*eshell*")
  (setq multi-eshell-shell-function (quote (eshell))))
;; commands for eshell
(defun eshell/ep ()
  "In eshell, `ep' to go to the path of the previous buffer"
  (cd (with-current-buffer (other-buffer) default-directory)))
(defun eshell/vi (&rest args)
  ;; from http://www.emacswiki.org/emacs/EshellFunctions
  "Invoke `find-file' on the file.
    \"vi +42 foo\" also goes to line 42 in the buffer."
  (while args
    (if (string-match "\\`\\+\\([0-9]+\\)\\'" (car args))
        (let* ((line (string-to-number (match-string 1 (pop args))))
               (file (pop args)))
          (find-file file)
          (goto-line line))
      (find-file (pop args)))))

;;; face, add our own keywords. ctypes.el is too heavy-weight
(add-hook 'find-file-hooks
          (lambda ()
            (font-lock-add-keywords
             nil '(("\\<\\(lgfang\\|TODO\\|FIXME\\|NOTE\\|IMPORTANT\\):"
                    . (0 font-lock-warning-face t))))))
(font-lock-add-keywords 'c-mode         ; for c mode only
                        '(("\\<\\(TRUE\\|FALSE\\)\\>"
                           . font-lock-constant-face)))

(when (require 'ffap nil t)
;; (ffap-bindings) ; Don't bind to `C-x C-f' etc., explicitly `M-x ffap' etc.
;; (setq ffap-c-path (append ffap-c-path sourcepair-header-path))

  ;; My extensions to ffap jira/sfsc tickets. Remember to define my-employer in
  ;; my-confidential.el
  (defun ffap-jira (name) ; ffap HELP-12345 etc. opens corresponding jira ticket
    (let ((company (if (boundp 'my-employer) my-employer "example")))
      (format "https://jira.%s.org/browse/%s" company name)))
  (add-to-list 'ffap-alist '("\\`\\(HELP\\|EVG\\|BF\\|TIG\\)-[0-9]+\\'" . ffap-jira))
  ;;                            ^^^ Or simply "\\`\\([A-Z]+\\)-[0-9]+" ?

  (defun ffap-sfsc (name)  ; ffap 123456 opens corresponding SFSC ticket
    (let ((company (if (boundp 'my-employer) my-employer "example")))
      (format "https://support.%s.com/case/%s%s"
              company (make-string (- 8 (length name)) ?0)  name)))
  (add-to-list 'ffap-alist '("\\`[0-9]\\{6,8\\}\\'" . ffap-sfsc))
)

;;; fill column
(setq-default fill-column 80 comment-fill-column nil)
(require 'fill-column-indicator nil t) ;; run "(fci-mode)"
;; (define-globalized-minor-mode
;;   global-fci-mode fci-mode (lambda () (fci-mode 1)))
;; (global-fci-mode t)

;;; flymake & flycheck (Prefer flycheck when possible)
(if (require 'flycheck nil t)
    (progn
      ;; NOTE: to debug, open a source file and 'M-x flycheck-verify-setup' to
      ;; see what checkers are/aren't being used.

      (global-flycheck-mode 1)

      ;; (setq-default flycheck-sh-shellcheck-executable "path/to/shellcheck")

      (add-hook 'c++-mode-hook
                (lambda ()
                  (setq
                   ;; Depends on the compiler available, one of the two takes
                   ;; effect. But, setting both does not hurt.
                   flycheck-clang-language-standard "c++20"
                   flycheck-gcc-language-standard "c++20")))

      (flycheck-define-checker rnc
        "Check rnc files using jing.jar See URL
`https://github.com/TreeRex/rnc-mode' and
`http://www.thaiopensource.com/relaxng/jing.html'"
        :command ("java" "-jar" (eval (cygpath rnc-jing-jar-file)) "-c"
                  (eval (cygpath (flycheck-save-buffer-to-temp
                                  #'flycheck-temp-file-system "flycheck"))))
        :error-patterns
        ((error line-start (zero-or-more anything) ":" line ":"
                column ": error:" (message) line-end)) :modes rnc-mode)
      (add-to-list 'flycheck-checkers 'rnc)
      )

  ;; if flycheck not available, use flymake
  (require 'flymake)
  (setq flymake-no-changes-timeout 2    ; don't grab too much cpu time
        flymake-allowed-file-name-masks
        (cons '("\\.cc\\'" flymake-simple-make-init) ; C++ source file
              ;; remember to add target in makefile
              ;; check-syntax:
              ;;       g++/gcc -o nul -Wall -S $(CHK_SOURCES)
              flymake-allowed-file-name-masks)))

;;; fonts
(when (and (>= emacs-major-version 23) window-system)

  ;; Recommended English fonts: "consolas", "DejaVu Sans Mono", "monofur"
  (set-face-attribute 'default nil :font "monaco-16:weight=normal")

  ;; Recommended Chinese fonts: "SimSun", "Microsoft YaHei", "WenQuanYi
  ;; Micro Hei Mono"
  (let ((zh-font-family "SimSun"))
    ;; Set scale of zh font so that width of one chinese char equals that of two
    ;; english chars. (Windows Emacs has a bug in "scale", hardcode zh font size
    ;; instead)
    (if (eq window-system 'w32)
        (dolist (each '(han cjk-misc))
          (set-fontset-font nil each
                            (font-spec :family zh-font-family :size 22)))
      (dolist (each '(han cjk-misc )) ;include kana, bopomofo, symbol?
        (set-fontset-font nil each
                          (font-spec :family zh-font-family)))
      (setq face-font-rescale-alist (list (cons zh-font-family 1.2)))))

  ;; Resize using mouse wheel
  (let ()
    (if (eq window-system 'w32)
        (setq up (kbd "<C-wheel-up>") down (kbd "<C-wheel-down>"))
      (setq up (kbd "<C-mouse-4>") down (kbd "<C-mouse-5>")))
    (define-key global-map up 'text-scale-increase)
    (define-key global-map down 'text-scale-decrease))
  )
;; Emoji ZWJ (Zero Width Joiner) handling. Though not strictly a font thing, put
;; them together as they both are about rendering contents.
(unless (display-graphic-p)
  ;; Disable auto-complete-mode if running in a terminal as most terminal
  ;; emulators cannot handle Emoji ZWJ. NOTE: disabling it on the fly does not
  ;; work very well, must restart the emacs.
  (setq-default auto-composition-mode nil)
  )

;;; frame position/size; emacs22 or later supports 'emacs --fullscreen'
;; (when (> emacs-major-version 23)
;;   (setq init-frame-alist
;;         '((top . 1) (left . 1) (width . 80) (height . 24)
;;            ;; (alpha 90 50)                 ;transparency
;;           )))

;;; frame title: hostname:current file name
(setq frame-title-format
      (list (replace-regexp-in-string "\\..*$" "" system-name)
            ":" '(buffer-file-name
                  "%f" (dired-directory dired-directory "%b"))))

;;; gdb
;; (setq gdb-many-windows t)

;;; git-gutter
;; Choose this over diff-hl because the later does not work in 'emacs -nw'.
(when (require 'git-gutter)

  ;; To diff with a revision other than the latest one, in the repo root
  ;; directory, add to the emacs directory local variable file (.dir-locals.el)
  ;; add content similar to the following:
  ;;
  ;; ((prog-mode . ((git-gutter:start-revision . "my_branch"))))

  (global-git-gutter-mode t)

  ;; Jump to next/previous hunk
  (global-set-key (kbd "C-x v [") 'git-gutter:previous-hunk)
  (global-set-key (kbd "C-x v ]") 'git-gutter:next-hunk)

  (global-set-key (kbd "C-x v =") 'git-gutter:popup-hunk)

  ;; Stage current hunk
  (global-set-key (kbd "C-x v s") 'git-gutter:stage-hunk)
  ;; Revert current hunk
  (global-set-key (kbd "C-x v r") 'git-gutter:revert-hunk)

  (set-face-background 'git-gutter:modified "DarkOrange")
  (set-face-background 'git-gutter:added "green")
  (set-face-background 'git-gutter:deleted "red")
  (setq git-gutter:modified-sign " "
        git-gutter:added-sign " "
        git-gutter:deleted-sign " ")
  )

;;; git-link
(setq git-link-open-in-browser t)

;;; golang
(add-hook 'go-mode-hook
          (lambda() (add-hook 'before-save-hook 'gofmt-before-save)))

;;; hide-ifdef-mode settings
(require 'hideif)

(defun hif-overlay-at (position)
  "An imitation of the one in hide-show, used by
lgfang-hif-toggle-block"
  (let ((overlays (overlays-at position)) ov found)
    (while (and (not found) (setq ov (car overlays)))
      (setq found (eq (overlay-get ov 'invisible) 'hide-ifdef)
            overlays (cdr overlays)))
    found))

(defun lgfang-hif-toggle-block ()
  "toggle hide/show-ifdef-block"
  (interactive)
  (require 'hideif)
  (let* ((top-bottom (hif-find-ifdef-block)) (top (car top-bottom)))
    (goto-char top)
    (hif-end-of-line)
    (if (hif-overlay-at (point)) (show-ifdef-block)
      (hide-ifdef-block))))

;;; Fold ifdef blocks by default. This is safer than showing them by default
;;; since when you see a code snippet folded, you know it is folded. In
;;; contrast, if they are not folded, you may learn in a hard way that you are
;;; in an undefined block.
(setq hide-ifdef-initially t
      hide-ifdef-define-alist
      ;; Add/remove "define" alist per your own need
      '((default)  ; An empty alist, makes every ifdef block folded, but not
                   ; ifndef blocks. See below for an example of how to define a
                   ; list per your project/environment.
        (mongodb-mac __APPLE__
                     (__LIBCPP_STD_VER . 14)
                     )
        ))
(defvar my-define-alist "mongodb-mac")

(defun lgfang-hide-ifdef-use-define-alist (name)
  "A wrapper for `hide-ifdef-use-define-alist' to use NAME define alist."
  (interactive
   (list (let* ((prompt "Use MACRO define list: ")
                (symbol-names
                 (mapcar (lambda (a) (symbol-name (car a)))
                         hide-ifdef-define-alist)))
           (if (require 'ido nil t)
               (ido-completing-read prompt symbol-names)
             (completing-read prompt symbol-names)))))
  (setq my-define-alist name) ; also apply this to buffers not opened yet
  (hide-ifdefs)                         ; for current buffer
  (hide-ifdef-use-define-alist name))

(dolist (hook '(c-mode-hook c++-mode-hook))
  (add-hook hook (lambda () (hide-ifdef-mode 1)
                   (hide-ifdef-use-define-alist my-define-alist))))

(eval-after-load "cc-mode"
  '(define-key c-mode-base-map (kbd "M-'") 'lgfang-hif-toggle-block))

;;; hide-show
(setq hs-allow-nesting t hs-isearch-open t)
(defun lgfang-toggle-level ()
  "hide/show the next level"
  (interactive) (hs-show-block) (hs-hide-level 1))

;;; highlight-tail
;; (when (require 'highlight-tail)
;;   (setq highlight-tail-colors '(("black" . 0)
;;                                 ("#bc2525" . 25)
;;                                 ("black" . 66))
;;         highlight-tail-steps 14
;;         highlight-tail-timer 1
;;         highlight-tail-posterior-type 'const)
;;   (highlight-tail-mode 1))

;;; hippie expand
(setq hippie-expand-try-functions-list
      '(try-expand-dabbrev
        try-expand-dabbrev-visible
        try-expand-dabbrev-all-buffers
        try-expand-dabbrev-from-kill
        try-complete-file-name-partially
        try-complete-file-name
        try-expand-all-abbrevs
        try-expand-list
        try-expand-line
        try-complete-lisp-symbol-partially
        try-complete-lisp-symbol))

(require 'htmlize nil t)

;;; ido `C-r/C-s' for ido-next/previous-match, `C-f' to get out ido mode into
;;; "normal" find file mode
(ido-mode 1)
(setq ido-enable-flex-matching t)

;;; imenu
(setq imenu-sort-function 'imenu--sort-by-name
      imenu-auto-rescan t
      imenu-use-popup-menu 'on-mouse)

(defun ido-goto-symbol ()
  "Will update the imenu index and then use ido to select a
symbol to navigate to.  From emacswiki, by shjk"
  (interactive)
  (imenu--make-index-alist)
  (let ((name-and-pos '()) (symbol-names '()))
    (flet
        ((addsymbols
          (symbol-list)
          (when (listp symbol-list)
            (dolist (symbol symbol-list)
              (let ((name nil) (position nil))
                (cond
                 ((and (listp symbol) (imenu--subalist-p symbol))
                  (addsymbols symbol))

                 ((listp symbol)
                  (setq name (car symbol))
                  (setq position (cdr symbol)))

                 ((stringp symbol)
                  (setq name symbol)
                  (setq position
                        (get-text-property
                         1 'org-imenu-marker symbol))))

                (unless (or (null position) (null name))
                  (add-to-list 'symbol-names name)
                  (add-to-list 'name-and-pos (cons name position))))))))
      (addsymbols imenu--index-alist))
      (let* ((selected-symbol
              (ido-completing-read "jump to: " symbol-names nil nil
                                   (thing-at-point 'symbol)))
             (position (cdr (assoc selected-symbol name-and-pos))))
        (push-mark)
        (goto-char position))))

;;; init
(setq inhibit-startup-message t
      inhibit-splash-screen t)
(eval-after-load "outline"
  '(setq initial-scratch-message
         (if (file-exists-p "~/.tod.org")
             (with-temp-buffer
               (insert-file-contents "~/.tod.org")
               ;; jump to somewhere randomly, must after first heading
               (outline-next-heading)
               ;; set random seed, otherwise "emacs -nw" always get same
               ;; tip
               (random t)
               (goto-char (+ (random (- (point-max) (point))) (point)))
               (outline-mark-subtree)
               (let* ((beg (point))
                      (end (mark)))
                 (buffer-substring beg end)))
           "Hello My Buddy,\n
You may want to get a copy of 'Tip Of the Day'.\n
lgfang")))

;;; ispell - aspell instead
(setq ispell-program-name "aspell"
      ;; regardless locale settings, always use english refer to
      ;; ispell-dictionary-alist for details
      ispell-dictionary "english")

;;; Javascript
(add-hook 'js-mode-hook
          (lambda()
            (define-key js-mode-map (kbd "M-'") 'lgfang-toggle-level)
            (define-key js-mode-map [mouse-3] 'lgfang-toggle-level)
            (hs-minor-mode 1)))

;;; Large files
(defun my-find-file-huge-file-hook ()
  "Turn off features that make Emacs super slow with large log
files and avoid accidental modifications."
  (when (> (buffer-size) (* 1024 1024 8)) ; 8 MB
    (setq buffer-read-only t)
    (buffer-disable-undo)
    (fundamental-mode)
    (which-func-mode -1)
    (if (fboundp 'highlight-parentheses-mode) (highlight-parentheses-mode -1))
    ))
(add-hook 'find-file-hook 'my-find-file-huge-file-hook)

;;; ldap mode for ldif files
(autoload 'ldap-mode "ldap-mode" "Edit ldif files" t)

;;; linum
(when (not (window-system))
  (setq linum-format
        (lambda (linum)
          (propertize
           (format
            (concat
             "%"
             (number-to-string
              (length (number-to-string
                       (count-lines (point-min) (point-max)))))
             "d| ") linum) 'face 'linum))))
(require 'linum nil t)
;;(global-linum-mode t)

(autoload 'log-mode "log-mode" "my mode to view log files" t)
(add-to-list 'auto-mode-alist '("\\.log\\(\\.[0-9]+\\)?\\'" . log-mode) t)

;;; long lines
(setq
 longlines-wrap-follows-window-size t
 ;; for visual-line-mode, indicates lines are wrapped
 visual-line-fringe-indicators '(left-curly-arrow right-curly-arrow))

;;; markdown; remember to package-install RET markdown-mode
;; The "standard" markdown command line tool is not good enough
(setq markdown-command "/usr/local/bin/pandoc")
(add-hook 'markdown-mode-hook 'flyspell-mode)

;;; mermaid mode: package-installed, just remember to install mermaid cli:
;; 'npm install -g @mermaid-js/mermaid-cli'

(menu-bar-mode -1)

(setq messages-buffer-max-lines 500)    ; default value too small

(when (require 'midnight nil t)
  (midnight-delay-set 'midnight-delay "1:30am")
  (setq clean-buffer-list-delay-general 1))

;;; mongolog: MongodDB log file mode
(add-to-list 'load-path (concat my-elisp-path "mongolog"))
(require 'mongolog nil t)
(add-to-list 'auto-mode-alist '("mongod.*\\.log" . js-mode))

;;; mouse
(setq mouse-yank-at-point t             ; instead of at mouse cursor
      mouse-drag-copy-region t)

(when (not window-system) (xterm-mouse-mode 1)) ;use mouse in xterm

;;; nXML mode
(add-to-list 'auto-mode-alist
             '("\\.\\((xml\\|xsd\\|sch\\|rng\\|xslt\\|svg\\|rss\\)\\'"
               . nxml-mode))
(setq magic-mode-alist
      (cons '("<\\?xml " . nxml-mode) magic-mode-alist))
(fset 'xml-mode 'nxml-mode)
(fset 'html-mode 'nxml-mode)
(require 'rng-loc nil t)

(add-hook 'nxml-mode-hook (lambda() (hs-minor-mode 1)))

(add-to-list 'rng-schema-locating-files
             "~/mynotes/emacs/schema-locations.xml")

(add-to-list 'hs-special-modes-alist
             '(nxml-mode
               ;; "<!--\\|<[^/>]*[^/]>" ;; regexp for start block
               ;; "-->\\|</[^/>]*[^/]>" ;; regexp for end block
               "<!--\\|<[^/>][^>]*[^/]>" ;; our xml has names like calea/li
               "-->\\|</[^/>][^>]*[^/]>"
               "<!--" ;; regexp for comment start. (need this??)
               nxml-forward-element
               nil))

(eval-after-load "nxml-mode"
  '(progn
     (define-key nxml-mode-map (kbd "M-'") 'lgfang-toggle-level)
     (define-key nxml-mode-map [mouse-3] 'lgfang-toggle-level)))

(defun nxml-where ()
  "Display the hierarchy of XML elements the point is on as a
path. from http://www.emacswiki.org/emacs/NxmlMode"
  (interactive)
  (let ((path nil))
    (save-excursion
      (save-restriction
        (widen)
        (while
            (and (< (point-min) (point)) ;; Doesn't error if point is at
                                         ;; beginning of buffer
                 (condition-case nil
                     (progn
                       (nxml-backward-up-element) ; always returns nil
                       t)
                   (error nil)))
          (setq path (cons (xmltok-start-tag-local-name) path)))
        (if (called-interactively-p t)
            (message "/%s" (mapconcat 'identity path "/"))
          (format "/%s" (mapconcat 'identity path "/")))))))

(require 'auto-complete-nxml nil t)

;;; occur
(define-key occur-mode-map "n" 'next-error-no-select)
(define-key occur-mode-map "p" 'previous-error-no-select)
(define-key occur-mode-map " " 'occur-mode-display-occurrence)
(define-key occur-mode-map "o" (lambda () (interactive)
                                 (occur-mode-goto-occurrence)
                                 (delete-other-windows)))

;;; org mode
(load "~/.org" t nil nil)

;;; parenthesis highlighting, Use highlight-parentheses instead
;; (show-paren-mode nil)(setq show-paren-style 'expression)
(when (require 'highlight-parentheses nil t)
  ;; M-x list-colors-display to see named colors
  (setq hl-paren-colors '("brown" "orange" "yellow" "forest green"
                          "cyan" "blue" "violet"))
  (global-highlight-parentheses-mode t))

;;; perl: using cperl-mode instead
(defalias 'perl-mode 'cperl-mode)
(add-hook 'cperl-mode-hook 'imenu-add-menubar-index)
(setq cperl-indent-level 4
      cperl-close-paren-offset -4
      cperl-continued-statement-offset 4
      cperl-indent-parens-as-block t
      cperl-tab-always-indent t)

;;; PHP
(add-to-list 'auto-mode-alist '("\\.php$" . php-mode))
;; Installed using M-x package-install
(autoload 'php-mode "php-mode" "Major mode for editing PHP code." t)

;;; Python related

;;; Python mode hook
(add-hook 'python-mode-hook
          (lambda()
            (setq tab-width 4)  ; "python-mode" sets it to 8, change it back.
            (hs-minor-mode 1)
            (outline-minor-mode 1)
            ;; (anaconda-mode)             ; for cross reference, also see eglot
            (blacken-mode 1)            ; relies on the command black
            (setq imenu-create-index-function 'python-imenu-create-flat-index)
            (imenu-add-menubar-index)))

(require 'pydoc-info nil t)

(if (require 'flycheck nil t)
      ;; if flake8, mypy and/or pyright are installed, flycheck uses them out of
      ;; box except for this line. Run `M-x flycheck-verify-setup' in a python
      ;; buffer for more information.
      (setq flycheck-python-flake8-executable "flake8")
  )

;;; RCIRC - replaces ERC
(when (require 'my-confidential nil t)
  ;; configure RCIRC only when my confidential information is available.
  (setq rcirc-server-alist `((,slack-server
                              :port ,slack-port
                              :encryption tls
                              :nick ,slack-nick
                              :password ,(concat slack-pass "-no_mpdm_greet")
                              :channels ("#tse-notifications"))
                             ("irc.freenode.net"
                              :channels ("#emacs" "#rcirc" "#mongodb"))
                             )
        ;; register nick name: https://freenode.net/kb/answer/registration
        rcirc-authinfo `(("freenode" nickserv ,my-net-id ,my-pub-passwd))
        rcirc-omit-responses '("JOIN" "PART" "QUIT" "NICK" "AWAY")
        ;; rcirc-nick-completion-format "@%s"
        rcirc-fill-flag nil
        rcirc-default-nick my-net-id)

  (add-hook 'rcirc-mode-hook
   (lambda ()
     (rcirc-track-minor-mode 1)
     (flyspell-mode 1)))
  )

;;; recently opened file
(require 'recentf)
;; add at the front of list, don't conncect to remote hosts
(add-to-list 'recentf-keep 'file-remote-p)
(setq recentf-max-saved-items 666)
(recentf-mode 1)

;;; Always end a file with a newline
(setq require-final-newline t)

;;; rfcview
(add-to-list 'auto-mode-alist
             '("/\\(rfc[0-9]+\\|draft-.+\\)\\.txt\\(\\.gz\\)?\\'"
               . rfcview-mode))
(autoload 'rfcview-mode "rfcview")
;; ffap try find RFCs in ffap-rfc-directories before downloading
(setq ffap-rfc-directories '("~/rfc" "~/projects/rfc"))

;;; rnc mode - nxml mode uses rnc files
(add-to-list 'auto-mode-alist '("\\.rnc\\'" . rnc-mode))
(autoload 'rnc-mode "rnc-mode")
(setq rnc-enable-imenu t
      rnc-jing-jar-file (expand-file-name
                         (concat my-extension-path "jing/bin/jing.jar")))

;; ;; Had not been the java, it could be this:
;; (flycheck-define-checker rnc
;;   :command ("java" "-jar" (eval rnc-jing-jar-file) "-c" source)
;;   :error-patterns ((error line-start (file-name) ":" line ":"
;;   column (message) line-end)) :modes rnc-mode)

(defun rnc2rng ()
  (interactive)
  (let* ((rnc (buffer-file-name))
         (rng (concat (file-name-sans-extension rnc) ".rng")))
    (call-process "java" nil nil nil "-jar"
                  (cygpath
                   (expand-file-name
                    (concat my-extension-path "trang.jar")))
                  (cygpath rnc) (cygpath rng))))

;;; save minibuffer history and place of cursor between sessions
(savehist-mode t)
(setq-default save-place-mode t)
(require 'saveplace)

(setq scroll-margin 0 scroll-conservatively 100) ;  scroll-step ?
(when (and (> emacs-major-version 21) window-system)
  (set-scroll-bar-mode nil))

(when (require 'sdcv nil t)
  (setq sdcv-dictionary-simple-list
        '(
          "牛津现代英汉双解词典"
          "朗道英汉字典5.0"
          "朗道汉英字典5.0"
          )
        sdcv-dictionary-complete-list nil ; use all available dicts
        ))

;;; selective display
(defun lgfang-toggle-selective-display()
  "set-selective-display to current column or toggle
selective-display"
  (interactive)
  (let ((arg (progn (back-to-indentation) (1+ (current-column)))))
    (set-selective-display (if (eq arg selective-display) nil arg))))

;;; sentence end
(setq sentence-end-double-space nil)
;; (setq sentence-end
;;       "\\([。！？]\\|……\\|[.?!][]\"')}]*\\($\\|[ \t]\\)\\)[ \t\n]*")

;;; server (alternatively, you may use "emacs --daemon")
(require 'server)
(when (not (server-running-p))
  (server-start))

;;; sh-mode-hook. Note that mode for shell script is sh-mode, NOT shell-mode
(setq my-sh-imenu-generic-expression
      '((nil "^\\s-*\\(function\\s-+\\)?\\([A-Za-z_][A-Za-z_0-9]+\\)\\s-*()" 2)
        (nil "^\\s-*function\\s-+\\([A-Za-z_][A-Za-z_0-9]+\\)" 1)))
(add-hook 'sh-mode-hook
          (lambda ()
            (hs-minor-mode 1)
            (setq imenu-generic-expression
                  my-sh-imenu-generic-expression
                  outline-regexp "# [*\\f]+")
            (imenu-add-menubar-index)))

;;; sh-mode, the mode for shell scripts
(when (eq system-type 'gnu/linux)
  (setq sh-alias-alist
        '((csh . tcsh)
          (ksh . ksh88)                 ; flycheck doesn't handle pdksh
          (bash2 . bash)
          (sh5 . sh))))

;;; skeleton, use yasnippet instead
;; avoid skeleton/abbrev recursion
(setq-default skeleton-further-elements '((abbrev-mode nil)))
;; skeleton-pair-insert
(setq
 ;; turn on/off skeleton-pair-insert
 skeleton-pair nil
 ;; inhibit paired insertion before/inside a word
 skeleton-pair-on-word nil)
(when skeleton-pair                     ; if turned on
  (dolist (hook '(c-mode-common-hook
                  tcl-mode-hook org-mode-hook
                  latex-mode-hook nxml-mode-hook
                  rnc-mode-hook))
    (add-hook
     hook
     (lambda ()
       (local-set-key (kbd "(") 'skeleton-pair-insert-maybe)
       (local-set-key (kbd "[") 'skeleton-pair-insert-maybe)
       (local-set-key (kbd "{") 'skeleton-pair-insert-maybe)
       (local-set-key (kbd "'") 'skeleton-pair-insert-maybe)
       (local-set-key (kbd "`") 'skeleton-pair-insert-maybe)
       (local-set-key (kbd "\"") 'skeleton-pair-insert-maybe)))))
;; (load "lgfang-skeleton" t nil nil)

;;; split horizontally if screen wide enough
(setq split-width-threshold 300)

;;; subword-mode
(global-subword-mode)

;;; Tabbar
;; (when (and window-system (require 'tabbar nil t)) (tabbar-mode 1))

;;; Tcl & expect
(add-hook 'tcl-mode-hook
          (lambda ()
            (imenu-add-menubar-index)
            (hs-minor-mode 1)))
(add-to-list 'interpreter-mode-alist '("expect" . tcl-mode))

;;; thingatpt+ - breaks org-mode + flyspell
;; (eval-after-load "thingatpt" '(require 'thingatpt+))

;;; Tiling
(add-to-list 'load-path (concat my-elisp-path "tiling"))
(require 'tiling nil t)

;;; time stamp
(add-hook 'write-file-hooks 'time-stamp)
(setq time-stamp-format "%U %Y-%02m-%02dT%02H:%02M:%02S%5z"
      time-stamp-start "\\(Modified\\|last-edit\\): *\\\\?"
      time-stamp-end "\\\\?>"
      ;; no Chinese chars in time stamps even in Chinese locale.
      system-time-locale "C")

;;; Terraform (package install terraform-mode)
(setq-default terraform-indent-level 4)

;;; toggle-window-dedicated.el
(load "toggle-window-dedicated" t nil nil)

;;; tool-bar - I need no tool bar
(tool-bar-mode -1)

;;; tramp
(require 'tramp)
(setq tramp-debug-buffer t)
(add-to-list 'tramp-default-method-alist '("localhost" nil "su"))

;;; highlight selected region
(setq-default transient-mark-mode t)

;;; trash
(when (>= emacs-major-version 23)
  (setq delete-by-moving-to-trash nil)
  ;; works for *nix only
  (setq trash-directory "~/.trashbin"))

(setq-default truncate-lines nil)

;;; Uniquify buffer name with more meaningful names
(when (require 'uniquify nil t)
  (setq uniquify-buffer-name-style 'post-forward
        uniquify-strip-common-suffix t
        uniquify-separator "@"))

;;; verilog mode
(autoload 'verilog-mode "verilog-mode" "Verilog mode" t )

;;; version control: git, vc, clearcase etc.
(load "lgfang.vc" t nil nil)
(add-to-list 'load-path (concat my-extension-path "vc-clearcase"))
(load "vc-clearcase-auto" t nil nil)
(setq clearcase-use-external-diff t             ; the internal one sucks
      ;; vc-clearcase-diff-switches "-diff_format" ; if diff unavailable
      ;; vc-git-diff-switches "-w"         ; ignore diff of whitespace
      )
;; magit show CommitDate instead of AuthorDate in log mode
(setq magit-log-margin-show-committer-date t)

;;; vimrc mode
(autoload 'vimrc-mode "vimrc-mode")
(add-to-list 'auto-mode-alist '(".vim\\(rc\\)?$" . vimrc-mode))

;;; viper, those who miss vi so bad please change "nil" to "t"
(when nil
  (setq viper-inhibit-startup-message t
        viper-expert-level '5
        viper-mode t)
  (require 'viper))

;;; Weather
(require 'cn-weather nil t)

(which-function-mode t)

;;; whitespace related
;; (setq-default show-trailing-whitespace t) ; use whitespace mode instead
(setq-default indent-tabs-mode nil ; inserts space instead of <tab> when indent
              tab-stop-list nil    ; stops every ‘tab-width’ columns
              tab-width 4)
(setq whitespace-line-column nil
      whitespace-style '(face
                         trailing
                         tabs
                         indentation
                         space-before-tab
                         space-after-tab
                         lines-tail
                         empty))
;; Editting others' files with whitespace-mode turned on can be boresome as they
;; never clean up whitespace. Therefore, M-x whitespace-mode only when needed.
(global-whitespace-mode 0)

;;; windmove - autoloaded

;;; Winner-mode - autoloaded
(winner-mode 1)

;;; woman
(setq woman-use-own-frame nil
      woman-fill-frame t)

;;; word
(setq-default word-wrap t)

;;; to make the cursor as wide as the character it is over
(setq x-stretch-cursor t)

;;; xcscope,
;; NOTE: cscope is now just a backup. Normally eglot + clangd is more convient.
;; Just `M-x eglot` in a C/C++ buffer to activate eglot.
(when (require 'xcscope nil t)
  (cscope-setup)

  (setq
   ;; use gtags-cscope instead of the legacy cscope
   cscope-program "gtags-cscope"
   ;; set cscope-database-file accordingly. Otherwise xcscope looks for
   ;; "cscope.out" and fails and then build the database in the current
   ;; directory.
   cscope-database-file "GTAGS")

  ;; ;; Below are for huge code bases. No need of them at the moment
  ;; (require 'cscope-filter nil t)
  ;; (setq
  ;;  cscope-do-not-update-database t ; do not rebuild database for every search.
  ;;  cscope-database-regexps
  ;;  '(("\\(sandbox/trunk\\)"
  ;;     (t) ;; local cscope.out first
  ;;     ("/home/lgfang/projects/vsg/sandbox/lcp_lite/")
  ;;     ("/home/lgfang/projects/vsg/sandbox/libsoap-1.1.0/libcsoap/")
  ;;     ("/home/lgfang/projects/vsg/sandbox/libxml2/")
  ;;     t ; 't' doesn't work, comment out useless database-dir
  ;;     ;;("/remote/.../b2008.09_icc_us02/syn/icc_sh/cscope.out.bak")
  ;;     )))

  )

;;; xref
(setq xref-prompt-for-identifier t) ; always prompt for identifier to search

;;; yasnippet
(add-to-list 'load-path (concat my-extension-path "yasnippet"))
;; NOTE: download http://elpa.gnu.org/packages/cl-lib.html if needed
(when (require 'yasnippet nil t)
  (setq yas/root-directory
        (list (concat my-extension-path "yasnippet/snippets")))
  (when (file-exists-p "~/.emacs.snippets")
    (add-to-list 'yas/root-directory "~/.emacs.snippets"))

  ;; Org-mode specific
  (defun yas/org-very-safe-expand ()
    (let ((yas/fallback-behavior 'return-nil)) (yas/expand)))
  (add-hook
   'org-mode-hook
   (lambda ()
     ;; yasnippet (using the new org-cycle hooks)
     (make-variable-buffer-local 'yas/trigger-key)
     (setq yas/trigger-key [tab])
     (add-to-list 'org-tab-first-hook 'yas/org-very-safe-expand)
     (define-key yas/keymap [tab] 'yas/next-field)))

  (yas-global-mode 1))

;;; yaml
(when (require 'yaml-mode nil t)
  (add-to-list 'auto-mode-alist '("\\.ya?ml$" . yaml-mode))
  (require 'yaml-path))

;;; y/n instead of yes/no
(fset 'yes-or-no-p 'y-or-n-p)

;;; ------ end General ------

;;; ------ begin MyFunction ------

;; auto insert TODO: use yasnippet?
(defun lgfang-copy-left ()
  (interactive)
  (save-excursion
    (goto-char (point-min))
    (let ((beg (point)))
    (insert
     "\\file Name: "
     (file-name-nondirectory buffer-file-name) "\n"
     "Created:  " (user-full-name) " "
     (format-time-string "%Y-%m-%d") "\n"
     "Modified: >\n"
     "\n"
     "\\brief\n"
     "\n"
     "\\details\n"
     "\n"
     )
    (comment-region beg (point)))
    (let ((beg (point)))
      (insert
       "This program is free software; you can redistribute it
and/or modify it under the terms of the GNU General Public
License as published by the Free Software Foundation; either
version 2, or (at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

Had you not received a copy of the GNU General Public License
yet, write to the Free Software Foundation, 675 Mass Ave,
Cambridge, MA 02139, USA.
")
      (let ((fill-column (- fill-column 6))) ;; make room for comment
        (fill-region beg (point)))
      (comment-region beg (point))
      )
    ))

(define-auto-insert
  (cons "\\.\\([Hh]\\|hh\\|hpp\\)\\'" "C / C++ header")
  'lgfang-copy-left t)

;; autoinsert C/C++ header
(define-auto-insert
  (cons "\\.\\([Cc]\\|cc\\|cpp\\)\\'" "C / C++ program")
  'lgfang-copy-left t)

(define-auto-insert
  (cons "\\.py\\'" "Python Script")
  '(insert
    "#!/usr/bin/env python3\n\n"
    "# Created:  " (user-full-name) " " (format-time-string "%Y-%m-%d") "\n"
    "# Modified: >\n\n"
    "import unittest\n\n"
    "if __name__ == '__main__':\n"
    "    unittest.main()\n"
    )
  t)

(define-auto-insert
  (cons "\\.sh\\'" "Shell Script")
  'lgfang-copy-left t)

(defadvice comment-dwim (before lgfang-comment-wim activate compile)
  "if neiter mark-active not at end of line, comment current
line (by making the whole line an active region). This gets you a
really cool behavior :)."
  (unless (or mark-active (looking-at "[ \t]*$"))
    (goto-char (line-beginning-position))
    (set-mark-command nil)
    (goto-char (line-end-position))))

(defun lgfang-goto-page (pageNumber)
  "RFCs in ascii format use traditional page
delimiter (Ctrl-L). While Emacs Provides functions like
forward-page,backward-page etc., it doesn't provide goto-page or
sth alike. To go to certain page, I used to either go to the
beginning of the buffer at first or calculate how many pages to
be moved from current page at first. For me, that is a little
boring. I think this function may help. P.S. You may want to give
rfcview.el a try."

  (interactive
   (if (and current-prefix-arg (not (consp current-prefix-arg)))
       (list (prefix-numeric-value current-prefix-arg))
     ;; Look for a default, a number in the buffer at point.
     (let* ((default
              (save-excursion
                (skip-chars-backward "0-9")
                (if (looking-at "[0-9]")
                    (buffer-substring-no-properties
                     (point)
                     (progn (skip-chars-forward "0-9") (point)))))))

       (list (read-from-minibuffer
              (format
               (if default "Goto Page (%s): " "Goto Page: ") default)
              nil nil t
              'minibuffer-history
              default)))))
  (save-restriction
    (widen)
    (goto-char (point-min))
    (forward-page (1- pageNumber))))

(defun lgfang-insert-date ()
  "Insert current date at point.  From Tijs van Bakel at
newsgroup: gnu.emacs.help.  To customize format of date
string,refer to format-time-string."
  (interactive)
  (insert (format-time-string "%Y-%m-%d")))

(defun lgfang-mode-line-all ()              ; long/long/ago
  "Sometimes there are too many infomation in mode line to show
  it in one line. Using this function to show it in an message
  box (or pop-up tool tip)"
  (interactive)
  (message "%s" (format-mode-line mode-line-format t))
  ;; (tooltip-show (format-mode-line mode-line-format t))
  ;; (message-box "%s" (format-mode-line mode-line-format t))
  )
(fset 'mla 'lgfang-mode-line-all)

(defun lgfang-recentf-open ()
  "open recent files. In ido style if applicable"
  (interactive)
  (let* ((prompt "File Name: ")
         (path-table (mapcar
                      (lambda (x) (cons (file-name-nondirectory x) x))
                      recentf-list))
         (fname (if (require 'ido nil t)
                    (ido-completing-read
                     prompt
                     (mapcar (lambda(x) (file-name-nondirectory
                                         x)) recentf-list))
                  (completing-read prompt path-table)))
         candidates )
    (dolist (afile path-table)
      (if (string-equal (car afile) fname)
          (progn
            (add-to-list 'candidates (cdr afile)))))

    (if (> (length candidates) 1)
        (find-file (ido-completing-read "full path:" candidates))
      (find-file (cdr (assoc fname path-table))))))

;;; replace strings in parallel
(defun lgfang-paralle-repl (replacement-alist)
  "Replace pairs of strings to search/replace in parallel."
  (interactive (list (batch-replace-strings-prompt)))
  (if (region-active-p)
      (let ((beg (region-beginning))
            (end (region-end))
            (case-fold-search nil))
        (save-excursion
          (dolist (pair replacement-alist)
            (goto-char (min beg end))
            (while (search-forward (car pair) (max beg end) t)
              (replace-match (cdr pair) t t)))))
    (message "No text selected")))

(defun batch-replace-strings-prompt ()  ; from Trey Jackson
  "prompt for string pairs and return as an association list"
  (let (from-string ret-alist)
    (while (not (string-equal "" (setq from-string
                                       (read-string
                                        "String to search (RET to stop): "))))
      (setq ret-alist
            (cons (cons from-string (read-string
                                     (format "Replace %s with: " from-string)))
                  ret-alist)))
    ret-alist))

(when (require 'ange-ftp nil t)
  (defvar lgfang-to-protocols (list "ssh" "ftp") "")
  (defvar lgfang-to-users (list "root" ange-ftp-default-user) "")
  (defvar lgfang-to-history nil "")
  (defun lgfang-to()
    "Inspired by 'remote-access' from tonyaw"
    (interactive)
    (let* ((protocol
            (read-from-minibuffer "Protocol (ftp): "
                                  "ftp" nil nil 'lgfang-to-protocols nil))
           (prompt "host name: ")
           (hosts "~/.hosts") host-names host-list)

      (when (file-readable-p hosts)
        (with-temp-buffer
          (insert-file-contents hosts)
          (goto-char (point-min))
          (while (not (eobp))
            (let* ((line (buffer-substring-no-properties
                          (line-beginning-position) (line-end-position)))
                   (fields (split-string line)))
              (unless (or (string-match "^#.*$" line)
                          (string-match "^[ \t]*$" line))
                (add-to-list 'host-names (or (nth 1 fields) (car fields)))
                (add-to-list 'host-list
                             (list (or (nth 1 fields) (car fields)) fields)))
              (forward-line))))

        (let* ((dest (if (require 'ido nil t)
                         (ido-completing-read prompt host-names nil nil nil
                                              'lgfang-to-history)
                       (completing-read prompt host-list nil nil nil
                                        'lgfang-to-history)))
               (ip (nth 0 (car (cdr (assoc dest host-list)))))
               (user (or (nth 2 (car (cdr (assoc dest host-list))))
                         (read-from-minibuffer "username (root): " "root"
                                               nil nil 'lgfang-to-users)))
               (file-name (format "/%s:%s@%s:/" protocol user ip)))

          (ffap file-name))))))

;;; Stefan Monnier <foo at acm.org>. It is the opposite of fill-paragraph
(defun unfill-paragraph (&optional region)
  "Takes a multi-line paragraph and makes it into a single line of text."
  (interactive (progn (barf-if-buffer-read-only) '(t)))
  (let ((fill-column (point-max))
        ;; This would override `fill-column' if it's an integer.
        (emacs-lisp-docstring-fill-column t))
    (fill-paragraph nil region)))

;;; ------ end MyFunction ------

(load "tmp.el" t nil nil)
(custom-set-variables
 ;; custom-set-variables was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(package-selected-packages
   '(cue-mode git-gutter mermaid-mode protobuf-mode cmake-mode magit anaconda-mode eglot blacken git-link csv-mode emms json-reformat windata w3m solarized-theme showtip terraform-mode highlight-parentheses highlight-indentation org-contrib yasnippet-snippets hide-lines ox-gfm yasnippet pydoc-info pydoc markdown-mode jira-markup-mode ht go-mode flycheck f)))
(custom-set-faces
 ;; custom-set-faces was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 )
