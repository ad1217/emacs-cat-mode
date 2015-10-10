;;; cat-mode.el --- Buffer management with catagories.

;; Copyright (C) 2015-
;;
;; Author: Adam Goldsmith <adam@adamgoldsmith.name>
;; Created: 3 Oct 2015
;; Homepage: http://github.com/ad1217/emacs-cat-mode
;; Version: 0.1
;; Keywords: convenience, usability
;; Package-Requires: ((ibuffer))

;; This file is not part of GNU Emacs.

;;; License:

;; CC-BY-SA 4.0 https://creativecommons.org/licenses/by-sa/4.0/

;;; Commentary:

;; Enable with (cat-mode 1)

;;; Code:

(defvar buffer-cat)
(make-variable-buffer-local 'buffer-cat)

(defvar current-cat "frame0")
(defvar cat-frame-number 0)
(make-variable-frame-local 'cat-frame-number)
(defvar cat-frame-cat "frame0")
(make-variable-frame-local 'cat-frame-cat)

(defgroup cat-mode nil
  "Buffer management with catagories."
  :group 'convenience
  :prefix "cat-")

(defcustom cat-special-cat "special"
  "The name of the \"special\" cat"
  :type 'string
  :group 'cat-mode)

(defcustom cat-special-buffers '("*scratch*" "*Messages*" "*Ibuffer*" "*Help*" "*Completions*")
  "Names of buffers to put in 'cat-special-cat'"
  :type '(repeat string)
  :group 'cat-mode)

(defcustom cat-ibuffer 't
  "Toggle ibuffer support"
  :type 'boolean
  :group 'cat-mode)

(defun cat-set (cat)
  "Sets the current buffer's 'buffer-cat' and 'current-cat' to CAT."
  (interactive (list (completing-read "Cat: " (cat-list-cats))))
  (setq buffer-cat cat)
  (setq current-cat cat))

(defun cat-get (buf)
  "Returns the value of 'buffer-cat' in BUF."
  (with-current-buffer buf
	buffer-cat))

(defun cat-add-cat-if-empty (buf)
  "Checks for missing 'buffer-cat's, and sets them to 'current-cat' if they are missing.
Sets buffers with names in 'cat-special-buffers' to 'cat-special-cat'."
  (with-current-buffer buf
	(if (not buffer-cat)
		(if (member (buffer-name buf) cat-special-buffers)
			(cat-set cat-special-cat)
		  (if (string= current-cat cat-special-cat)
			  (cat-set cat-frame-cat)
			(cat-set current-cat))))))

(defun cat-new-buffers ()
  "Calls 'cat-add-cat-if-empty' on the 'buffer-list', and sets 'current-cat' to the current buffer's cat."
  (mapcar 'cat-add-cat-if-empty (buffer-list))
  (setq current-cat (cat-get (current-buffer))))

(defun cat-new-frame (frame)
  "Increments 'cat-frame-number' and sets 'cat-frame-cat' and 'current-cat' to frame#."
  (setq cat-frame-cat (format "frame%d" (incf cat-frame-number)))
  (setq current-cat cat-frame-cat))

(defun cat-list-buffers (cat)
  "Returns a list of buffers in CAT"
  (remove nil (mapcar (lambda (buf) (if (string= (cat-get buf) cat) buf))
					  (buffer-list))))

(defun cat-list-cats ()
  "Returns a list of cats generated by iterating over all buffers and adding each 'buffer-cat' to a set."
  (let (cat-list)
	(delete 'nil (mapcar #'(lambda (buf)
							 (setq cat-list (adjoin (cat-get buf) cat-list)))
						 (buffer-list)))
	cat-list))

(defun kill-cat (cat)
  "Kills all buffers in CAT."
  (interactive (list (completing-read "Kill Cat: " (cat-list-cats))))
  (mapc #'kill-buffer (cat-list-buffers cat)))

(defun cat-init-ibuffer ()
  (with-eval-after-load "ibuffer"
	(require 'ibuf-ext)

	(define-ibuffer-filter cats
		"Filter to buffers of current cat."
	  (:description "cats-mode"
					:reader (completing-read "Filter by Cat: " (cat-list-cats)))
	  (cat-buffer-in-cat buf qualifier))

	(defun cat-update-ibuffer-groups ()
	  "Update or create the ibuffer groups for cat-mode."
	  (setq ibuffer-saved-filter-groups
			(delete* "cat-mode" ibuffer-saved-filter-groups
					 :test 'string= :key 'car))
	  (add-to-list 'ibuffer-saved-filter-groups
				   (cons "cat-mode" (delete* nil
											 (mapcar #'(lambda (pn)
														 (list pn (cons 'predicate
																		`(string= buffer-cat ,pn))))
													 (cat-list-cats))
											 :test 'string= :key 'car))))

	(defun cat-update-ibuffer (&optional arg silent)
	  "Creates or updates the ibuffer groups. Arguments are ignored."
	  (cat-update-ibuffer-groups)
	  (setq ibuffer-filter-groups
			(cdr (assoc "cat-mode" ibuffer-saved-filter-groups))))

	(defun cat-set-ibuffer (cat)
	  "Sets all marked buffers in ibuffer to cat"
	  (interactive (list (completing-read "Cat: " (cat-list-cats))))
	  (ibuffer-do-eval `(cat-set ,cat))
	  (ibuffer-update nil t))

	(add-hook 'ibuffer-mode-hook
			  #'(lambda ()
				  (cat-update-ibuffer-groups)
				  (ibuffer-switch-to-saved-filter-groups "cats-mode")
				  (advice-add 'ibuffer-update :before #'cat-update-ibuffer)))))

  (defun cat-deinit-ibuffer ()
	(setq ibuffer-saved-filter-groups
		  (delete* "cat-mode" ibuffer-saved-filter-groups
				   :test 'string= :key 'car))
	(remove-hook 'ibuffer-mode-hook
				 #'(lambda ()
					 (cat-update-ibuffer-groups)
					 (ibuffer-switch-to-saved-filter-groups "cats-mode")
					 (advice-add 'ibuffer-update :before #'cat-update-ibuffer)))
	(advice-remove 'ibuffer-update #'cat-update-ibuffer))

(defun cat-init ()
  (setq-default mode-line-format
				(append mode-line-format
						'((:eval (format "[%s|%s] " cat-frame-cat current-cat)))))
  (add-hook 'buffer-list-update-hook #'cat-new-buffers)
  (add-hook 'after-make-frame-functions #'cat-new-frame)
  (if cat-ibuffer (cat-init-ibuffer)))

(defun cat-deinit ()
  (setq-default mode-line-format
				(remove '(:eval (format "[%s|%s] " cat-frame-cat current-cat))
						mode-line-format))
  (remove-hook 'buffer-list-update-hook #'cat-new-buffers)
  (remove-hook 'after-make-frame-functions #'cat-new-frame)
  (if cat-ibuffer (cat-deinit-buffer)))

;;;###autoload
(define-minor-mode cat-mode
  ""
  :init-value nil
  :lighter ""
  :global t
  (if cat-mode
	  (cat-init)
	(cat-deinit)))

(provide 'cat-mode)

;;; cat-mode.el ends here
