#!/usr/bin/env bash
set -u

AUTO_DEVICE_NAME="SRS-XB13"
INTERVAL=5
CONNECT_TIMEOUT=5
SCAN_SECONDS=15

STATE_DIR="$HOME/.cache/i3-bluetooth"
PIDFILE="$STATE_DIR/srs-xb13.pid"
LOCKFILE="$STATE_DIR/srs-xb13.lock"
LOG="$STATE_DIR/srs-xb13.log"

SELF="$(readlink -f "$0" 2>/dev/null || realpath "$0" 2>/dev/null || printf '%s\n' "$0")"

mkdir -p "$STATE_DIR"

log() {
	printf '[%s] %s\n' "$(date '+%F %T')" "$*" >>"$LOG"
}

notify() {
	notify-send "Bluetooth" "$1" >/dev/null 2>&1 || true
}

bt() {
	bluetoothctl -- "$@"
}

get_mac_by_name() {
	local wanted="$1"

	bt devices 2>/dev/null |
		awk -v wanted="$wanted" '
			$1 == "Device" {
				mac = $2
				name = $0
				sub(/^Device[[:space:]]+[0-9A-Fa-f:]+[[:space:]]+/, "", name)

				if (name == wanted || index(name, wanted)) {
					print mac
					exit
				}
			}
		'
}

device_name_for_mac() {
	local mac="$1"

	bt devices 2>/dev/null |
		awk -v mac="$mac" '
			$1 == "Device" && $2 == mac {
				name = $0
				sub(/^Device[[:space:]]+[0-9A-Fa-f:]+[[:space:]]+/, "", name)
				print name
				exit
			}
		'
}

adapter_powered() {
	bt show 2>/dev/null |
		awk -F': ' '/Powered:/ { print $2; exit }'
}

is_connected() {
	local mac="${1:-}"

	[ -n "$mac" ] || return 1

	bt info "$mac" 2>/dev/null |
		grep -q "Connected: yes"
}

connected_text() {
	local mac="${1:-}"

	if [ -z "$mac" ]; then
		printf 'unknown'
		return
	fi

	bt info "$mac" 2>/dev/null |
		awk -F': ' '/Connected:/ { print $2; exit }'
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

watcher_pid() {
	if watcher_running; then
		cat "$PIDFILE"
	fi
}

connect_mac() {
	local mac="$1"
	local name

	name="$(device_name_for_mac "$mac")"
	[ -n "$name" ] || name="$mac"

	bt power on >>"$LOG" 2>&1 || true
	bt trust "$mac" >>"$LOG" 2>&1 || true

	log "Manual/auto connect attempt: $name <$mac>"

	if command -v timeout >/dev/null 2>&1; then
		timeout "$CONNECT_TIMEOUT" bluetoothctl -- connect "$mac" >>"$LOG" 2>&1 || true
	else
		bt connect "$mac" >>"$LOG" 2>&1 || true
	fi

	sleep 1

	if is_connected "$mac"; then
		log "Connected: $name <$mac>"
		notify "Connected to $name"
		return 0
	fi

	log "Connect failed: $name <$mac>"
	notify "Could not connect to $name"
	return 1
}

disconnect_mac() {
	local mac="$1"
	local name

	name="$(device_name_for_mac "$mac")"
	[ -n "$name" ] || name="$mac"

	bt disconnect "$mac" >>"$LOG" 2>&1 || true
	sleep 1

	if is_connected "$mac"; then
		notify "Still connected to $name"
		return 1
	fi

	notify "Disconnected $name"
	return 0
}

start_watcher() {
	if watcher_running; then
		notify "Auto watcher already running. PID: $(watcher_pid)"
		return 0
	fi

	local mac
	mac="$(get_mac_by_name "$AUTO_DEVICE_NAME")"

	if is_connected "$mac"; then
		log "$AUTO_DEVICE_NAME already connected at $mac. Watcher not started."
		notify "$AUTO_DEVICE_NAME already connected"
		return 0
	fi

	nohup "$SELF" watch >/dev/null 2>&1 &
	notify "Auto watcher started for $AUTO_DEVICE_NAME"
}

stop_watcher() {
	local silent="${1:-0}"

	if ! watcher_running; then
		rm -f "$PIDFILE"

		if [ "$silent" != "1" ]; then
			notify "Auto watcher is not running"
		fi

		return 0
	fi

	local pid
	pid="$(cat "$PIDFILE")"

	kill "$pid" 2>/dev/null || true
	sleep 0.2

	if kill -0 "$pid" 2>/dev/null; then
		kill -9 "$pid" 2>/dev/null || true
	fi

	rm -f "$PIDFILE"
	log "Watcher stopped by user."

	if [ "$silent" != "1" ]; then
		notify "Auto watcher stopped"
	fi
}

restart_watcher() {
	stop_watcher 1
	start_watcher
}

status_notify() {
	local mac connected powered watcher name

	mac="$(get_mac_by_name "$AUTO_DEVICE_NAME")"
	name="$AUTO_DEVICE_NAME"
	powered="$(adapter_powered)"
	watcher="stopped"

	if watcher_running; then
		watcher="running, PID $(watcher_pid)"
	fi

	if [ -z "$mac" ]; then
		notify "Target: $name
MAC: not found
Adapter powered: ${powered:-unknown}
Connected: unknown
Watcher: $watcher"
		return 0
	fi

	connected="$(connected_text "$mac")"

	notify "Target: $name
MAC: $mac
Adapter powered: ${powered:-unknown}
Connected: ${connected:-unknown}
Watcher: $watcher"
}

polybar_output() {
	local mac

	mac="$(get_mac_by_name "$AUTO_DEVICE_NAME")"

	if [ -z "$mac" ]; then
		printf 'BT ?\n'
		return
	fi

	if is_connected "$mac"; then
		printf 'BT %s ✓\n' "$AUTO_DEVICE_NAME"
		return
	fi

	if watcher_running; then
		printf 'BT %s …\n' "$AUTO_DEVICE_NAME"
		return
	fi

	printf 'BT %s ×\n' "$AUTO_DEVICE_NAME"
}

watch_loop() {
	exec 9>"$LOCKFILE"

	if ! flock -n 9; then
		log "Watcher already running. Exiting duplicate."
		exit 0
	fi

	echo "$$" >"$PIDFILE"

	cleanup() {
		rm -f "$PIDFILE"
		log "Watcher exited."
	}

	trap cleanup EXIT
	trap 'exit 0' INT TERM

	log "Watcher started for $AUTO_DEVICE_NAME."

	while true; do
		bt power on >>"$LOG" 2>&1 || true

		local mac
		mac="$(get_mac_by_name "$AUTO_DEVICE_NAME")"

		if [ -z "$mac" ]; then
			log "$AUTO_DEVICE_NAME not found in bluetoothctl devices list. Retrying in ${INTERVAL}s."
			sleep "$INTERVAL"
			continue
		fi

		if is_connected "$mac"; then
			log "$AUTO_DEVICE_NAME already connected at $mac. Exiting watcher."
			notify "$AUTO_DEVICE_NAME connected"
			exit 0
		fi

		connect_mac "$mac" >/dev/null 2>&1 || true

		if is_connected "$mac"; then
			log "Auto-connected successfully to $AUTO_DEVICE_NAME at $mac. Exiting watcher."
			notify "$AUTO_DEVICE_NAME connected"
			exit 0
		fi

		log "Auto-connect failed. Retrying in ${INTERVAL}s."
		sleep "$INTERVAL"
	done
}

format_device_row() {
	local mac="$1"
	local name status prefix

	name="$(device_name_for_mac "$mac")"
	[ -n "$name" ] || name="$mac"

	status="off"
	if is_connected "$mac"; then
		status="connected"
	fi

	prefix="  "
	if [ "$name" = "$AUTO_DEVICE_NAME" ] || [[ "$name" == *"$AUTO_DEVICE_NAME"* ]]; then
		prefix="★ "
	fi

	printf '%s%s    %s    [%s]\n' "$prefix" "$name" "$mac" "$status"
}

device_rows() {
	local auto_mac
	auto_mac="$(get_mac_by_name "$AUTO_DEVICE_NAME")"

	if [ -n "$auto_mac" ]; then
		format_device_row "$auto_mac"
	fi

	bt devices 2>/dev/null |
		awk '$1 == "Device" { print $2 }' |
		while read -r mac; do
			[ -n "$mac" ] || continue
			[ "$mac" = "$auto_mac" ] && continue
			format_device_row "$mac"
		done
}

scan_once() {
	notify "Scanning Bluetooth devices for ${SCAN_SECONDS}s…"
	log "Bluetooth scan started for ${SCAN_SECONDS}s."

	bt power on >>"$LOG" 2>&1 || true
	bt scan on >>"$LOG" 2>&1 || true
	sleep "$SCAN_SECONDS"
	bt scan off >>"$LOG" 2>&1 || true

	log "Bluetooth scan finished."
	notify "Bluetooth scan finished"
}

device_action_menu() {
	local mac="$1"
	local name connected action info

	name="$(device_name_for_mac "$mac")"
	[ -n "$name" ] || name="$mac"

	connected="$(connected_text "$mac")"

	action="$(
		printf '%s\n' \
			"Connect" \
			"Disconnect" \
			"Trust" \
			"Pair" \
			"Remove device" \
			"Info notification" \
			"Restart auto watcher" \
			"Stop auto watcher" |
			rofi -dmenu -i \
				-p "$name" \
				-mesg "MAC: $mac | Connected: ${connected:-unknown}"
	)" || return 0

	case "$action" in
	Connect)
		connect_mac "$mac"
		;;
	Disconnect)
		disconnect_mac "$mac"
		;;
	Trust)
		bt trust "$mac" >>"$LOG" 2>&1 && notify "Trusted $name"
		;;
	Pair)
		bt pair "$mac" >>"$LOG" 2>&1 && notify "Pair requested for $name"
		;;
	"Remove device")
		bt remove "$mac" >>"$LOG" 2>&1 && notify "Removed $name"
		;;
	"Info notification")
		info="$(
			bt info "$mac" 2>/dev/null |
				awk -F': ' '
						/Name:/ { name=$2 }
						/Alias:/ { alias=$2 }
						/Connected:/ { connected=$2 }
						/Paired:/ { paired=$2 }
						/Trusted:/ { trusted=$2 }
						END {
							printf "Name: %s\nAlias: %s\nConnected: %s\nPaired: %s\nTrusted: %s", name, alias, connected, paired, trusted
						}
					'
		)"
		notify "$info"
		;;
	"Restart auto watcher")
		restart_watcher
		;;
	"Stop auto watcher")
		stop_watcher
		;;
	esac
}

manual_menu() {
	if ! command -v rofi >/dev/null 2>&1; then
		notify "rofi is not installed/found"
		return 1
	fi

	local choice mac

	choice="$(
		{
			printf '★ Auto target: %s\n' "$AUTO_DEVICE_NAME"
			printf '↻ Restart auto watcher\n'
			printf '■ Stop auto watcher\n'
			printf '⌕ Scan %ss then reopen\n' "$SCAN_SECONDS"
			printf '────────────\n'
			device_rows
		} |
			rofi -dmenu -i \
				-p "Bluetooth" \
				-mesg "Enter: manage device | SRS-XB13 is listed first by default"
	)" || return 0

	case "$choice" in
	"★ Auto target:"*)
		status_notify
		;;
	"↻ Restart auto watcher")
		restart_watcher
		;;
	"■ Stop auto watcher")
		stop_watcher
		;;
	"⌕ Scan "*)
		scan_once
		manual_menu
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

		if [ -n "$mac" ]; then
			device_action_menu "$mac"
		fi
		;;
	esac
}

show_log() {
	tail -n 100 "$LOG"
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
log)
	show_log
	;;
*)
	echo "Usage: $0 {start|stop|restart|status|polybar|menu|watch|scan|log}" >&2
	exit 2
	;;
esac
