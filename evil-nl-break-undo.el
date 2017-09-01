;;; Evil 'break undo when line changes' mode --- -*- lexical-binding: t; coding: utf-8 -*-

;; Copyright (C) 2017 Gabriel Lazar

;; Author: VanLaser <Gabriel.Lazar@com.utcluj.ro>
;; URL: https://github.com/VanLaser/evil-nl-break-undo

;; This file is NOT part of GNU Emacs.

;;; License:
;;
;; This program is free software: you can redistribute it and/or modify
;; it under the terms of the GNU General Public License as published by
;; the Free Software Foundation, either version 3 of the License, or
;; (at your option) any later version.
;;
;; This program is distributed in the hope that it will be useful,
;; but WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;; GNU General Public License for more details.
;;
;; You should have received a copy of the GNU General Public License
;; along with this program.  If not, see <http://www.gnu.org/licenses/>.

;;; Commentary:
;;
;; Simple minor mode that breaks evil's undo sequence when the buffer
;; is changed over a line boundary.
;;

;;; Usage:
;;
;; Add the mode to the buffers you want (Evil should be already enabled there).
;; For example:
;;
;; (add-hook 'text-mode-hook #'evil-nl-break-undo-mode)
;; (add-hook 'prog-mode-hook #'evil-nl-break-undo-mode)

;;; Code:

(require 'evil)

(defvar evil-break-undo-regexp "\n"
  "REGEXP used to break an evil undo sequence.
The search takes place on the text range that is being changed.")

(defun evil-nl-break-undo--maybe (beg end &optional len)
  "Local hook run before and after the buffer is changed.
Checks if a newline was either removed, or inserted, and breaks
the current evil undo step."
  (when (and (not (minibufferp))
	     (not evil-want-fine-undo)
	     (evil-insert-state-p)
	     (< beg end)
	     (save-excursion
	       (save-match-data		;don't spoil user searches
		 (goto-char beg) (re-search-forward evil-break-undo-regexp end t))))
    (evil-end-undo-step)
    (evil-echo "Break undo")
    (evil-start-undo-step)))

(defun evil-nl-break-undo--enable ()
    (add-hook 'before-change-functions    #'evil-nl-break-undo--maybe nil t)
    (add-hook 'after-change-functions     #'evil-nl-break-undo--maybe nil t))

(defun evil-nl-break-undo--disable ()
    (remove-hook 'before-change-functions    #'evil-nl-break-undo--maybe t)
    (remove-hook 'after-change-functions     #'evil-nl-break-undo--maybe t))

;;;###autoload
(define-minor-mode evil-nl-break-undo-mode
  "Evil minor mode that breaks the current undo step when a
change in insert state includes a newline, i.e. when a change in
the buffer steps over a newline (either by inserting, or by
removing one)."

  :lighter " ↵"
  (if evil-nl-break-undo-mode
      (evil-nl-break-undo--enable)
    (evil-nl-break-undo--disable)))

(provide 'evil-nl-break-undo)

