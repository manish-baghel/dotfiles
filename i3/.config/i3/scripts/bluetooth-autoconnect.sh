#!/usr/bin/env bash
set -uo pipefail

AUTO_DEVICE_NAME="SRS-XB13"
CONNECT_PROFILE="a2dp-sink"

RETRY_SECONDS=5
BT_QUERY_TIMEOUT=10
CONNECT_TIMEOUT=8
PAIR_TIMEOUT=30
SCAN_SECONDS=5

STATE_DIR="${XDG_CACHE_HOME:-$HOME/.cache}/i3-bluetooth"
PIDFILE="$STATE_DIR/autoconnect.pid"
LOCKFILE="$STATE_DIR/autoconnect.lock"
STATE_FILE="$STATE_DIR/autoconnect.state"
LOG="$STATE_DIR/autoconnect.log"

SELF="$(readlink -f -- "$0" 2>/dev/null || printf '%s\n' "$0")"

# Polybar colours.
COLOR_CONNECTED="#9ece6a"
COLOR_WAITING="#e0af68"
COLOR_DISCONNECTED="#f7768e"
COLOR_MUTED="#737aa2"

COLOR_BATTERY_LOW="#ff9e64"
COLOR_BATTERY_MID="#e0af68"
COLOR_BATTERY_HIGH="#9ece6a"

# Font Awesome / Nerd Font glyphs.
ICON_BLUETOOTH=""
ICON_BATTERY_FULL=""
ICON_BATTERY_75=""
ICON_BATTERY_50=""
ICON_BATTERY_25=""
ICON_BATTERY_EMPTY=""

mkdir -p "$STATE_DIR"

log() {
	printf '[%s] [pid:%s] %s\n' \
		"$(date '+%F %T')" \
		"$$" \
		"$*" >>"$LOG"
}

notify() {
	notify-send "Bluetooth" "$1" >/dev/null 2>&1 || true
}

write_state() {
	printf '%s\n' "$1" >"$STATE_FILE"
}

read_state() {
	if [ -r "$STATE_FILE" ]; then
		cat "$STATE_FILE"
	else
		printf 'stopped\n'
	fi
}

# Quiet Bluetooth reads used by Polybar and the watcher.
# Any stuck bluetoothctl process is killed after BT_QUERY_TIMEOUT.
bt_read() {
	timeout "$BT_QUERY_TIMEOUT" bluetoothctl "$@" 2>/dev/null || true
}

# Logged Bluetooth mutations such as connect, pair, trust, and disconnect.
bt_run() {
	local seconds="$1"
	local label="$2"
	shift 2

	local output rc

	log "CMD[$label]: bluetoothctl $(printf '%q ' "$@")"

	output="$(timeout "$seconds" bluetoothctl "$@" 2>&1)"
	rc=$?

	if [ -n "$output" ]; then
		while IFS= read -r line; do
			log "CMD[$label] | $line"
		done <<<"$output"
	fi

	log "CMD[$label] exit=$rc"
	return "$rc"
}

get_mac_by_name() {
	local wanted="$1"

	bt_read devices |
		awk -v wanted="$wanted" '
			$1 == "Device" {
				mac = $2
				name = $0
				sub(/^Device[[:space:]]+[^[:space:]]+[[:space:]]+/, "", name)

				if (name == wanted) {
					print mac
					exit
				}
			}
		'
}

device_info() {
	local mac="${1:-}"

	[ -n "$mac" ] || return 0
	bt_read info "$mac"
}

# Parse one property from a captured `bluetoothctl info` result.
#
# bluetoothctl indents properties:
#
#         Paired: yes
#         Battery Percentage: 0x46 (70)
#
# We trim the key and value before comparing.
info_value() {
	local info="$1"
	local wanted="$2"

	printf '%s\n' "$info" |
		awk -v wanted="$wanted" '
			{
				colon = index($0, ":")
				if (colon == 0) {
					next
				}

				key = substr($0, 1, colon - 1)
				value = substr($0, colon + 1)

				sub(/^[[:space:]]+/, "", key)
				sub(/[[:space:]]+$/, "", key)

				sub(/^[[:space:]]+/, "", value)
				sub(/[[:space:]]+$/, "", value)

				if (key == wanted) {
					print value
					exit
				}
			}
		'
}

battery_percent() {
	local info="$1"
	local raw hex

	raw="$(info_value "$info" "Battery Percentage")"

	if [[ "$raw" =~ \(([0-9]{1,3})\) ]]; then
		printf '%s\n' "${BASH_REMATCH[1]}"
	elif [[ "$raw" =~ ^([0-9]{1,3})%?$ ]]; then
		printf '%s\n' "${BASH_REMATCH[1]}"
	elif [[ "$raw" =~ ^0x([0-9A-Fa-f]+) ]]; then
		hex="${BASH_REMATCH[1]}"
		printf '%d\n' "$((16#$hex))"
	fi
}

controller_powered() {
	info_value "$(bt_read show)" "Powered"
}

ensure_power_on() {
	[ "$(controller_powered)" = "yes" ] && return 0

	bt_run "$BT_QUERY_TIMEOUT" power-on power on || true
}

is_connected_info() {
	[ "$(info_value "$1" "Connected")" = "yes" ]
}

ensure_trusted() {
	local mac="$1"
	local info="$2"

	[ "$(info_value "$info" "Trusted")" = "yes" ] && return 0
	[ "$(info_value "$info" "Paired")" = "yes" ] || return 1

	bt_run "$BT_QUERY_TIMEOUT" "trust-$mac" trust "$mac"
}

watcher_running() {
	[ -s "$PIDFILE" ] || return 1

	local pid
	pid="$(cat "$PIDFILE" 2>/dev/null || true)"

	if [ -n "$pid" ] && kill -0 "$pid" 2>/dev/null; then
		return 0
	fi

	rm -f "$PIDFILE"
	return 1
}

connect_device() {
	local mac="$1"
	local source="${2:-auto}"
	local info name

	info="$(device_info "$mac")"
	name="$(info_value "$info" "Name")"
	[ -n "$name" ] || name="$mac"

	if is_connected_info "$info"; then
		write_state connected
		return 0
	fi

	ensure_power_on
	ensure_trusted "$mac" "$info" || true

	write_state connecting

	if [ -n "$CONNECT_PROFILE" ]; then
		bt_run \
			"$CONNECT_TIMEOUT" \
			"$source-connect-$mac" \
			connect "$mac" "$CONNECT_PROFILE" ||
			true
	else
		bt_run \
			"$CONNECT_TIMEOUT" \
			"$source-connect-$mac" \
			connect "$mac" ||
			true
	fi

	# BlueZ normally updates Connected immediately. Give it one second
	# before reading the final state.
	sleep 1

	info="$(device_info "$mac")"

	if is_connected_info "$info"; then
		write_state connected
		log "$source connection succeeded: $name <$mac>"
		notify "Connected to $name"
		return 0
	fi

	write_state waiting
	log "$source connection failed: $name <$mac>"
	return 1
}

start_watcher() {
	if watcher_running; then
		notify "Auto-connect watcher is already running"
		return 0
	fi

	# Do not query Bluetooth here. Starting must always be immediate and
	# non-blocking, even when bluetoothd is still initializing.
	nohup "$SELF" watch >/dev/null 2>&1 &

	notify "Auto-connect watcher started for $AUTO_DEVICE_NAME"
}

stop_watcher() {
	local silent="${1:-0}"
	local pid

	if ! watcher_running; then
		rm -f "$PIDFILE"
		write_state stopped

		[ "$silent" = "1" ] ||
			notify "Auto-connect watcher is not running"

		return 0
	fi

	pid="$(cat "$PIDFILE")"

	kill "$pid" 2>/dev/null || true

	for _ in 1 2 3 4 5; do
		kill -0 "$pid" 2>/dev/null || break
		sleep 0.1
	done

	kill -9 "$pid" 2>/dev/null || true

	rm -f "$PIDFILE"
	write_state stopped
	log "Watcher stopped"

	[ "$silent" = "1" ] ||
		notify "Auto-connect watcher stopped"
}

restart_watcher() {
	stop_watcher 1
	start_watcher
}

watch_loop() {
	exec 9>"$LOCKFILE"

	if ! flock -n 9; then
		log "Another watcher already holds the lock"
		exit 0
	fi

	echo "$$" >"$PIDFILE"
	write_state waiting
	log "Watcher started: target=$AUTO_DEVICE_NAME"

	cleanup() {
		rm -f "$PIDFILE"

		[ "$(read_state)" = "connected" ] ||
			write_state stopped

		log "Watcher exited"
	}

	trap cleanup EXIT
	trap 'exit 0' INT TERM

	while true; do
		local mac info

		ensure_power_on
		mac="$(get_mac_by_name "$AUTO_DEVICE_NAME")"

		if [ -z "$mac" ]; then
			write_state target-unknown
			sleep "$RETRY_SECONDS"
			continue
		fi

		info="$(device_info "$mac")"

		if is_connected_info "$info"; then
			write_state connected
			log "$AUTO_DEVICE_NAME is connected; watcher exiting"
			notify "$AUTO_DEVICE_NAME connected"
			exit 0
		fi

		connect_device "$mac" auto && exit 0

		sleep "$RETRY_SECONDS"
	done
}

scan_once() {
	ensure_power_on
	notify "Scanning for Bluetooth devices…"

	{
		printf 'scan on\n'
		sleep "$SCAN_SECONDS"
		printf 'scan off\n'
		printf 'quit\n'
	} |
		timeout "$((SCAN_SECONDS + 3))" bluetoothctl \
			>>"$LOG" 2>&1 ||
		true

	notify "Bluetooth scan finished"
}

battery_icon() {
	local percent="$1"

	if ((percent <= 10)); then
		printf '%s' "$ICON_BATTERY_EMPTY"
	elif ((percent <= 30)); then
		printf '%s' "$ICON_BATTERY_25"
	elif ((percent <= 60)); then
		printf '%s' "$ICON_BATTERY_50"
	elif ((percent <= 85)); then
		printf '%s' "$ICON_BATTERY_75"
	else
		printf '%s' "$ICON_BATTERY_FULL"
	fi
}

battery_color() {
	local percent="$1"

	if ((percent <= 20)); then
		printf '%s' "$COLOR_BATTERY_LOW"
	elif ((percent <= 60)); then
		printf '%s' "$COLOR_BATTERY_MID"
	else
		printf '%s' "$COLOR_BATTERY_HIGH"
	fi
}

battery_markup() {
	local percent="$1"
	local icon color

	[ -n "$percent" ] || return 0

	icon="$(battery_icon "$percent")"
	color="$(battery_color "$percent")"

	# The first "%" is the battery percentage symbol.
	# The second "%" begins Polybar's %{F-} colour reset tag.
	printf '%s' "%{F${color}}${icon} ${percent}%%{F-}"
}

status_notify() {
	local mac info name battery battery_label watcher

	mac="$(get_mac_by_name "$AUTO_DEVICE_NAME")"

	watcher=stopped
	watcher_running && watcher=running

	if [ -z "$mac" ]; then
		notify "Target: $AUTO_DEVICE_NAME
MAC: not found
Watcher: $watcher
State: $(read_state)"

		return 0
	fi

	info="$(device_info "$mac")"
	name="$(info_value "$info" "Name")"
	battery="$(battery_percent "$info")"

	battery_label="${battery:+${battery}%}"
	[ -n "$battery_label" ] || battery_label=unknown

	notify "Name: ${name:-$AUTO_DEVICE_NAME}
MAC: $mac
Connected: $(info_value "$info" "Connected")
Paired: $(info_value "$info" "Paired")
Bonded: $(info_value "$info" "Bonded")
Trusted: $(info_value "$info" "Trusted")
Blocked: $(info_value "$info" "Blocked")
Battery: $battery_label
Watcher: $watcher
State: $(read_state)"
}

polybar_output() {
	local mac info name connected battery battery_text state

	mac="$(get_mac_by_name "$AUTO_DEVICE_NAME")"
	state="$(read_state)"

	if [ -z "$mac" ]; then
		printf '%s\n' \
			"%{F${COLOR_MUTED}}${ICON_BLUETOOTH} ?%{F-}"

		return 0
	fi

	info="$(device_info "$mac")"
	name="$(info_value "$info" "Name")"
	connected="$(info_value "$info" "Connected")"
	battery="$(battery_percent "$info")"
	battery_text="$(battery_markup "$battery")"

	[ -n "$name" ] || name="$AUTO_DEVICE_NAME"

	if [ "$connected" = "yes" ]; then
		printf '%s\n' \
			"%{F${COLOR_CONNECTED}}${ICON_BLUETOOTH}%{F-} ${name}${battery_text:+  $battery_text}"
	elif watcher_running; then
		printf '%s\n' \
			"%{F${COLOR_WAITING}}${ICON_BLUETOOTH}%{F-} ${name}  ${state}"
	else
		printf '%s\n' \
			"%{F${COLOR_DISCONNECTED}}${ICON_BLUETOOTH}%{F-} ${name} ×"
	fi
}

format_device_row() {
	local mac="$1"
	local info name connected paired trusted battery prefix details

	info="$(device_info "$mac")"

	name="$(info_value "$info" "Name")"
	connected="$(info_value "$info" "Connected")"
	paired="$(info_value "$info" "Paired")"
	trusted="$(info_value "$info" "Trusted")"
	battery="$(battery_percent "$info")"

	[ -n "$name" ] || name="$mac"

	prefix="  "
	[ "$name" = "$AUTO_DEVICE_NAME" ] && prefix="★ "

	details="connected:${connected:-?} paired:${paired:-?} trusted:${trusted:-?}"

	[ -n "$battery" ] &&
		details+=" battery:${battery}%"

	printf '%s%s    %s    [%s]\n' \
		"$prefix" \
		"$name" \
		"$mac" \
		"$details"
}

device_rows() {
	local auto_mac mac

	auto_mac="$(get_mac_by_name "$AUTO_DEVICE_NAME")"

	[ -n "$auto_mac" ] &&
		format_device_row "$auto_mac"

	while read -r mac; do
		[ -n "$mac" ] || continue
		[ "$mac" = "$auto_mac" ] && continue

		format_device_row "$mac"
	done < <(
		bt_read devices |
			awk '$1 == "Device" { print $2 }'
	)
}

connect_mac() {
	stop_watcher 1
	connect_device "$1" manual
}

disconnect_mac() {
	local mac="$1"
	local info name

	stop_watcher 1

	info="$(device_info "$mac")"
	name="$(info_value "$info" "Name")"

	[ -n "$name" ] || name="$mac"

	bt_run \
		"$BT_QUERY_TIMEOUT" \
		"disconnect-$mac" \
		disconnect "$mac" ||
		true

	write_state stopped
	notify "Disconnected $name"
}

show_device_info() {
	local mac="$1"
	local info name battery battery_label

	info="$(device_info "$mac")"
	name="$(info_value "$info" "Name")"
	battery="$(battery_percent "$info")"

	battery_label="${battery:+${battery}%}"
	[ -n "$battery_label" ] || battery_label=unknown

	notify "Name: ${name:-$mac}
MAC: $mac
Connected: $(info_value "$info" "Connected")
Paired: $(info_value "$info" "Paired")
Bonded: $(info_value "$info" "Bonded")
Trusted: $(info_value "$info" "Trusted")
Blocked: $(info_value "$info" "Blocked")
Battery: $battery_label"
}

device_action_menu() {
	local mac="$1"
	local info name action

	info="$(device_info "$mac")"
	name="$(info_value "$info" "Name")"

	[ -n "$name" ] || name="$mac"

	action="$(
		printf '%s\n' \
			Connect \
			Disconnect \
			Trust \
			Untrust \
			Pair \
			Remove \
			Info |
			rofi -dmenu -i -p "$name"
	)" || return 0

	case "$action" in
	Connect)
		connect_mac "$mac"
		;;
	Disconnect)
		disconnect_mac "$mac"
		;;
	Trust)
		bt_run \
			"$BT_QUERY_TIMEOUT" \
			"trust-$mac" \
			trust "$mac" ||
			true

		notify "Trusted $name"
		;;
	Untrust)
		bt_run \
			"$BT_QUERY_TIMEOUT" \
			"untrust-$mac" \
			untrust "$mac" ||
			true

		notify "Untrusted $name"
		;;
	Pair)
		stop_watcher 1

		bt_run \
			"$PAIR_TIMEOUT" \
			"pair-$mac" \
			pair "$mac" ||
			true

		notify "Pair command finished for $name"
		;;
	Remove)
		stop_watcher 1

		bt_run \
			"$BT_QUERY_TIMEOUT" \
			"remove-$mac" \
			remove "$mac" ||
			true

		notify "Removed $name"
		;;
	Info)
		show_device_info "$mac"
		;;
	esac
}

manual_menu() {
	command -v rofi >/dev/null 2>&1 || {
		notify "rofi is not installed"
		return 1
	}

	local choice mac

	choice="$(
		{
			printf '↻ Start/restart auto-connect\n'
			printf '■ Stop auto-connect\n'
			printf '⌕ Scan for devices\n'
			printf 'ⓘ Auto-target status\n'
			printf '────────────\n'
			device_rows
		} |
			rofi -dmenu -i -p "Bluetooth" \
				-mesg "Auto target: $AUTO_DEVICE_NAME | State: $(read_state)"
	)" || return 0

	case "$choice" in
	"↻ Start/restart auto-connect")
		restart_watcher
		;;
	"■ Stop auto-connect")
		stop_watcher
		;;
	"⌕ Scan for devices")
		scan_once
		manual_menu
		;;
	"ⓘ Auto-target status")
		status_notify
		;;
	"────────────")
		return 0
		;;
	*)
		mac="$(
			printf '%s\n' "$choice" |
				grep -Eoi '([0-9A-F]{2}:){5}[0-9A-F]{2}' |
				head -n1
		)"

		[ -n "$mac" ] &&
			device_action_menu "$mac"
		;;
	esac
}

debug_snapshot() {
	local mac output

	mac="$(get_mac_by_name "$AUTO_DEVICE_NAME")"

	log "========== debug snapshot =========="

	bt_run "$BT_QUERY_TIMEOUT" show show || true
	bt_run "$BT_QUERY_TIMEOUT" devices devices || true

	[ -n "$mac" ] &&
		bt_run "$BT_QUERY_TIMEOUT" "info-$mac" info "$mac" ||
		true

	if command -v journalctl >/dev/null 2>&1; then
		output="$(
			journalctl \
				-u bluetooth \
				-n 80 \
				--no-pager \
				2>&1 ||
				true
		)"

		while IFS= read -r line; do
			log "JOURNAL | $line"
		done <<<"$output"
	fi

	notify "Bluetooth debug snapshot written to $LOG"
}

usage() {
	printf \
		'Usage: %s {start|stop|restart|status|polybar|menu|watch|scan|debug|log|follow-log}\n' \
		"$0"
}

case "${1:-status}" in
start)
	start_watcher
	;;
stop)
	stop_watcher
	;;
restart)
	restart_watcher
	;;
status)
	status_notify
	;;
polybar)
	polybar_output
	;;
menu)
	manual_menu
	;;
watch)
	watch_loop
	;;
scan)
	scan_once
	;;
debug)
	debug_snapshot
	;;
log)
	touch "$LOG"
	tail -n 120 "$LOG"
	;;
follow-log)
	touch "$LOG"
	tail -f "$LOG"
	;;
*)
	usage >&2
	exit 2
	;;
esac
