;;; sndioctl-emacs.el --- Allows OpenBSD sndio to be controlled emacs
;;; Copyright (c) 2020 Ashton Fagg <ashton@fagg.id.au>

;;
;; This file is NOT part of GNU emacs
;;
;; This program is free software: you can redistribute it and/or modify
;; it under the terms of the GNU General Public License as published by
;; the Free Software Foundation, either version 3 of the License, or
;; (at your option) any later version.

;; This program is distributed in the hope that it will be useful,
;; but WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;; GNU General Public License for more details.

;; You should have received a copy of the GNU General Public License
;; along with GNU Emacs. If not, see <http://www.gnu.org/licenses/>.
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;; Commentary:
;;; This package draws some inspiration from
;;; https://github.com/flexibeast/pulseaudio-control


;;; Code:

(defgroup sndioctl nil
  "Control system volume via sndioctl."
  :group 'external)

(defcustom sndioctl-executable-path (or (executable-find "sndioctl")
					"/usr/bin/sndioctl")
  "Executable path for sndioctl."
  :type '(file :must-match t)
  :group 'sndioctl)

(defcustom sndioctl-default-volume-delta "0.05"
  "Default step for adjusting volume."
  :type 'string
  :group 'sndioctl)

(defcustom sndioctl-verbose t
  "Whether or not to display info in the minibuffer on changes to volume."
  :type 'boolean
  :group 'sndioctl)

(defun sndioctl--call (command)
  "Handy wrapper for calling sndioctl and capturing the output.
Argument COMMAND string of arguments to pass to sndioctl."
  (shell-command-to-string (concat sndioctl-executable-path " " command)))

(defun sndioctl--parse-vol-output (msg)
  "Formats volume state message.
Argument MSG Output from sndioctl containing volume state."
  (concat "Volume: "
	  (format "%4g" (* 100 (string-to-number msg)))
	  "%"))

(defun sndioctl--parse-mute-output (msg)
  "Turn the mute flag output into a readable message.
Argument MSG Output from sndioctl containing mute state."
  (if (= 1 (string-to-number msg))
      (concat "Muted: Yes")
  (concat "Muted: No")))

(defun sndioctl--status-message ()
  "Turn the current status into a printable message."
  (concat "sndioctl: "
	  (sndioctl--parse-vol-output (sndioctl--call "-n output.level"))
	  " / "
	  (sndioctl--parse-mute-output (sndioctl--call "-n output.mute"))))

(defun sndioctl--increase-volume ()
  "Increases volume according to the delta defined above."
  (sndioctl--call
   (concat "-q output.level=+"
	   sndioctl-default-volume-delta))
  (if sndioctl-verbose
      (message "%s" (sndioctl--status-message))))

(defun sndioctl--decrease-volume ()
  "Decrease volume according to the delta defined above."
  (sndioctl--call
   (concat "-q output.level=-"
	   sndioctl-default-volume-delta))
  (if sndioctl-verbose
      (message "%s" (sndioctl--status-message))))

(defun sndioctl--set-mute ()
  "Set mute."
  (sndioctl--call "-q output.mute=1")
  (if sndioctl-verbose
      (message "%s" (sndioctl--status-message))))

(defun sndioctl--unset-mute ()
  "Unsets mute."
  (sndioctl--call "-q output.mute=0")
  (if sndioctl-verbose
      (message "%s" (sndioctl--status-message))))

(defun sndioctl--toggle-mute ()
  "Toggle mute."
  (sndioctl--call "-q output.mute=!")
  (if sndioctl-verbose
      (message "%s" (sndioctl--status-message))))

(provide 'sndioctl-emacs)

;;; sndioctl-emacs.el ends here
