#!/usr/bin/env bash

# HDMI-0: 3840x2160 native, primary, left
# DP-2:   1920x1080 physical, but treated as 2400x1350 logical
#         2400x1350 = 1920x1080 * 1.25
#         This compensates for Xft.dpi 120, because 120 / 1.25 = 96.
#
# --fb sets the total res - see: https://www.reddit.com/r/linuxquestions/comments/4c2o4p/comment/d1ej2gl/

xrandr --fb 6720x2160 --dpi 144 \
	--output HDMI-0 --primary --mode 3840x2160 --rate 60.00 --pos 0x0 --rotate normal --scale 1x1 --panning 3840x2160+0+0 \
	--output DP-2 --mode 1920x1080 --rate 143.98 --pos 3840x540 --rotate normal --scale 1.5x1.5 --panning 2880x1620+3840+540
