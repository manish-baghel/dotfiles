#!/bin/sh

killall -q polybar

while pgrep -x polybar >/dev/null; do sleep 1; done

if type "xrandr"; then
	for m in $(xrandr --query | grep " connected" | cut -d" " -f1); do
		MONITOR=$m polybar i3wmthemer_bar &
	done
else
	polybar i3wmthemer_bar &
fi
