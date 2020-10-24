;;; sndioctl-emacs.el
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
;; along with GNU Emacs.  If not, see <http://www.gnu.org/licenses/>.
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; This package draws some inspiration from
;;; https://github.com/flexibeast/pulseaudio-control

(defgroup sndioctl nil
  "Control system volume via sndioctl."
  :group 'external)

(defcustom sndioctl-executable-path (or (executable-find "sndioctl")
					"/usr/bin/sndioctl")
  "Executable path for sndioctl."
  :type '(file :must-match t)
  :group 'sndioctl)

(defcustom sndioctl-default-volume-delta "0.05"
  "Default step for adjusting volume"
  :type 'string
  :group 'sndioctl)

(defcustom sndioctl-verbose t
  "Whether or not to display info in the minibuffer on changes to volume"
  :type 'boolean
  :group 'sndioctl)

(defun sndioctl--call (command)
  "Handy wrapper for calling sndioctl and capturing the output"
  (shell-command-to-string (concat sndioctl-executable-path " " command)))

(defun sndioctl--parse-vol-output (msg)
  "Takes in the output from the volume query and returns a number that can be displayed as a %"
  (concat "Volume: "
	  (format "%4g" (* 100 (string-to-number msg)))
	  "%"))

(defun sndioctl--parse-mute-output (msg)
  "Turns the mute flag output into a readable message"
  (if (= 1 (string-to-number msg))
      (concat "Muted: Yes")
  (concat "Muted: No")))

(defun sndioctl--status-message ()
  "Turns the current status into a printable message"
  (concat "sndioctl: "
	  (sndioctl--parse-vol-output (sndioctl--call "-n output.level"))
	  " / "
	  (sndioctl--parse-mute-output (sndioctl--call "-n output.mute"))))

(defun sndioctl--increase-volume ()
  "Increases volume according to the delta defined above."
  (sndioctl--call
   (concat "output.level=+"
	   sndioctl-default-volume-delta))
  (if sndioctl-verbose
      (message "%s" (sndioctl--status-message))))

(defun sndioctl--decrease-volume ()
    "Decrease volume according to the delta defined above."
  (sndioctl--call
   (concat "output.level=-"
	   sndioctl-default-volume-delta))
  (if sndioctl-verbose
      (message "%s" (sndioctl--status-message))))

(defun sndioctl--set-mute ()
  "Sets mute."
  (sndioctl--call "output.mute=1")
  (if sndioctl-verbose
      (message "%s" (sndioctl--status-message))))

(defun sndioctl--unset-mute ()
  "Unsets mute"
  (sndioctl--call "output.mute=0")
  (if sndioctl-verbose
      (message "%s" (sndioctl--status-message))))

(defun sndioctl--toggle-mute ()
  "Toggles mute"
  (sndioctl--call "output.mute=!")
  (if sndioctl-verbose
      (message "%s" (sndioctl--status-message))))
