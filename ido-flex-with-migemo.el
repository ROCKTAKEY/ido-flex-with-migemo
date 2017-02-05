;;; ido-flex-with-migemo.el --- use migemo with flex and migemo

;; Copyright (C) 2017 by ROCKTAKEY

;; Author: ROCKTAKEY  <rocktakey@gmail.com>

;; URL: https://github.com/ROCKTAKEY/ido-flex-with-migemo

;; Keywords: ido, migemo, flex

;; Package-Requires: ((flx-ido "0.6.1") (migemo "1.9.1"))

;; This program is free software; you can redistribute it and/or modify
;; it under the terms of the GNU General Public License as published by
;; the Free Software Foundation, either version 3 of the License, or
;; (at your option) any later version.

;; This program is distributed in the hope that it will be useful,
;; but WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;; GNU General Public License for more details.

;; You should have received a copy of the GNU General Public License
;; along with this program.  If not, see <http://www.gnu.org/licenses/>.
;;; Commentary:

;; ROCKTAKEY


;; Table of Contents
;; _________________

;; 1 Usage
;; 2 Variable
;; .. 2.1 ido-flex-with-migemo-excluded-func-list


;; 1 Usage
;; =======

;;   If you turn on "ido-flex-with-migemo-mode," you can use ido with both
;;   flex and migemo.


;; 2 Variable
;; ==========

;; 2.1 ido-flex-with-migemo-excluded-func-list
;; ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

;;   This is list of function you don't want to use ido-flex-with-migemo in.
;;   Here's an example:

;;   ,----
;;   | 1  (require 'smex)      ;;you have to install "smex" if you use this example
;;   | 2  (add-to-list 'ido-flex-with-migemo-excluded-func-list '(smex))
;;   `----

;;; Code:

(require 'flx-ido)
(require 'migemo)

(defgroup ido-flex-with-migemo nil
  "Group of `ido-flex-with-migemo-mode'"
  :group 'ido)
(defcustom ifwm-excluded-func-list '(ido-describe-bindings
                                     describe-variable
                                     describe-function
                                     smex)
  "This is list of function you don't want to use ido-flex-with-migemo."
  :group 'ido-flex-with-migemo)



(defun ifwm-migemo-match (query items)
  "Return list of matches to QUERY in ITEMS on migemo."
  (let ((regexp (migemo-get-pattern query))
        result)

    (cl-loop for x in items with str
             do (setq str (if (listp x) (car x) x))
             if (string-match regexp str)
             collect x)))
(defun flex-with-migemo-match (query items)
  "Return list of matches to QUERY in ITEMS on migemo and flex"
  (let ((flex-items   (flx-ido-match query items))
        (migemo-items (ifwm-migemo-match query items)))
    (setq migemo-items
          (cl-remove-if (lambda (arg) nil nil
                          (member arg flex-items)) migemo-items))
    (append flex-items migemo-items)
    ))


;; (defadvice ido-set-matches-1 (around ido-flex-with-migemo-set-matches-1 compile)
;;   "Choose among between the regular ido-set-matches-1, ido-flex-with-migemo-match and flx-ido-match."
;;   (if (or (not ido-flex-with-migemo-mode)
;;           (memq this-command ifwm-excluded-func-list))
;;       ;; flx-ido のアドバイスのコピー
;;       (if (not flx-ido-mode) ad-do-it
;;         (let* ((query ido-text)
;;                (original-items (ad-get-arg 0)))
;;           (flx-ido-debug "query: %s" query)
;;           (flx-ido-debug "id-set-matches-1 sees %s items" (length original-items))
;;           (setq ad-return-value (flx-ido-match query original-items)))
;;         (flx-ido-debug "id-set-matches-1 returning %s items starting with %s "
;;                        (length ad-return-value) (car ad-return-value))) ;ここまで
;;     (let ((query ido-text)
;;           (original-items (ad-get-arg 0)))
;;       (flx-ido-debug "query: %s" query)
;;       (flx-ido-debug "id-set-matches-1 sees %s items" (length original-items))
;;       (setq ad-return-value  (flex-with-migemo-match query original-items)))
;;     (flx-ido-debug "id-set-matches-1 returning %s items starting with %s "
;;                    (length ad-return-value) (car ad-return-value))))

(defun ido-flex-with-migemo-set-matches-1 (orig-func &rest args)
  "Choose among the regular ido-set-matches-1, ido-flex-with-migemo-match and flx-ido-match."
  (let (ad-return-value)
    (if (or (not ido-flex-with-migemo-mode)
            (memq this-command ifwm-excluded-func-list))

        (if (not flx-ido-mode) (funcall orig-func args)
          (let* ((query ido-text)
                 (original-items (car args)))
            (flx-ido-debug "query: %s" query)
            (flx-ido-debug "id-set-matches-1 sees %s items" (length original-items))
            (setq ad-return-value (flx-ido-match query original-items)))
          (flx-ido-debug "id-set-matches-1 returning %s items starting with %s "
                         (length ad-return-value) (car ad-return-value)))
      
      (let ((query ido-text)
            (original-items (car args)))
        (flx-ido-debug "query: %s" query)
        (flx-ido-debug "id-set-matches-1 sees %s items" (length original-items))
        (setq ad-return-value  (flex-with-migemo-match query original-items)))
      (flx-ido-debug "id-set-matches-1 returning %s items starting with %s "
                     (length ad-return-value) (car ad-return-value)))
    ad-return-value))

;;;###autoload
(define-minor-mode ido-flex-with-migemo-mode
  "Toggle ido flex with migemo mode"
  :init-value nil
  :lighter ""
  :group 'ido-flex-with-migemo
  :global t
  (if ido-flex-with-migemo-mode
      (advice-add 'ido-set-matches-1 :around  'ido-flex-with-migemo-set-matches-1)
    (advice-remove 'ido-set-matches-1 'ido-flex-with-migemo-set-matches-1)))

(provide 'ido-flex-with-migemo)


;; Local Variables:
;; coding: utf-8
;; indent-tabs-mode: nil
;; End:

;;; ido-flex-with-migemo.el ends here
