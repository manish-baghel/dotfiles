#!/usr/bin/env bash
set -u

AUTO_DEVICE_NAME="SRS-XB13"

# Leave empty for normal bluetoothctl behavior.
# If generic connect still causes profile weirdness, try:
CONNECT_PROFILE="a2dp-sink"

INTERVAL=2
STARTUP_GRACE_SECONDS=2

CONNECT_TIMEOUT=6
CONNECT_RETRY_SECONDS=3
CONNECT_RETRY_SLOW_SECONDS=10
SLOW_AFTER_FAILURES=4

SCAN_SECONDS=5
UNKNOWN_TARGET_SCAN_INTERVAL=30

PACTL_TIMEOUT=2

STATE_DIR="${XDG_CACHE_HOME:-$HOME/.cache}/i3-bluetooth"
PIDFILE="$STATE_DIR/autoconnect.pid"
LOCKFILE="$STATE_DIR/autoconnect.lock"
LOG="$STATE_DIR/autoconnect.log"
STATE_FILE="$STATE_DIR/autoconnect.state"

SELF="$(readlink -f "$0" 2>/dev/null || realpath "$0" 2>/dev/null || printf '%s\n' "$0")"

mkdir -p "$STATE_DIR"

LOG_MAX_BYTES=$((5 * 1024 * 1024))

rotate_log_if_needed() {
	[ -f "$LOG" ] || return 0

	local size
	size="$(wc -c <"$LOG" 2>/dev/null || printf '0')"

	if [ "$size" -gt "$LOG_MAX_BYTES" ]; then
		mv "$LOG" "${LOG}.$(date '+%Y%m%d-%H%M%S')" 2>/dev/null || true
		: >"$LOG"
	fi
}

log() {
	rotate_log_if_needed
	printf '[%s] [pid:%s] %s\n' "$(date '+%F %T.%3N')" "$$" "$*" >>"$LOG"
}

log_section() {
	log "========== $* =========="
}

log_multiline() {
	local prefix="$1"
	local text="${2:-}"

	if [ -z "$text" ]; then
		log "$prefix | <no output>"
		return 0
	fi

	while IFS= read -r line; do
		log "$prefix | $line"
	done <<<"$text"
}

run_logged() {
	local label="$1"
	shift

	local start end rc out
	start="$(date +%s%3N)"

	log "CMD[$label] start: $(printf '%q ' "$@")"

	out="$("$@" 2>&1)"
	rc=$?

	end="$(date +%s%3N)"

	log "CMD[$label] exit=$rc duration_ms=$((end - start))"
	log_multiline "CMD[$label]" "$out"

	printf '%s\n' "$out"
	return "$rc"
}

run_logged_timeout() {
	local seconds="$1"
	local label="$2"
	shift 2

	if command -v timeout >/dev/null 2>&1; then
		run_logged "$label" timeout "$seconds" "$@"
	else
		run_logged "$label" "$@"
	fi
}

notify() {
	notify-send "Bluetooth" "$1" >/dev/null 2>&1 || true
}

bt() {
	bluetoothctl -- "$@"
}

now_epoch() {
	date +%s
}

write_state() {
	local new_state="$*"
	local old_state=""

	if [ -r "$STATE_FILE" ]; then
		old_state="$(cat "$STATE_FILE" 2>/dev/null || true)"
	fi

	printf '%s\n' "$new_state" >"$STATE_FILE"

	if [ "$new_state" != "$old_state" ]; then
		log "STATE: ${old_state:-<none>} -> $new_state"
	fi
}

read_state() {
	if [ -r "$STATE_FILE" ]; then
		cat "$STATE_FILE"
	fi
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

ensure_power_on() {
	local powered
	powered="$(adapter_powered)"

	if [ "$powered" = "yes" ]; then
		return 0
	fi

	run_logged "power-on" bluetoothctl -- power on >/dev/null || true
}

device_prop() {
	local mac="${1:-}"
	local prop="${2:-}"

	[ -n "$mac" ] || return 0
	[ -n "$prop" ] || return 0

	bt info "$mac" 2>/dev/null |
		awk -F': ' -v prop="$prop" '$1 == prop { print $2; exit }'
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

is_trusted() {
	local mac="${1:-}"

	[ -n "$mac" ] || return 1

	bt info "$mac" 2>/dev/null |
		grep -q "Trusted: yes"
}

is_paired() {
	local mac="${1:-}"

	[ -n "$mac" ] || return 1

	bt info "$mac" 2>/dev/null |
		grep -q "Paired: yes"
}

audio_sink_status() {
	local mac="${1:-}"
	local sink_mac out rc

	[ -n "$mac" ] || {
		printf 'no'
		return
	}

	if ! command -v pactl >/dev/null 2>&1; then
		printf 'unknown'
		return
	fi

	sink_mac="${mac//:/_}"

	if command -v timeout >/dev/null 2>&1; then
		out="$(timeout "$PACTL_TIMEOUT" pactl list short sinks 2>/dev/null)"
		rc=$?
	else
		out="$(pactl list short sinks 2>/dev/null)"
		rc=$?
	fi

	if [ "$rc" -ne 0 ]; then
		printf 'unknown'
		return
	fi

	if printf '%s\n' "$out" | grep -Fq "bluez_sink.${sink_mac}"; then
		printf 'yes'
	else
		printf 'no'
	fi
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

snapshot_adapter() {
	log_section "adapter snapshot"

	run_logged "bluetoothctl-show" bluetoothctl -- show >/dev/null || true

	if command -v rfkill >/dev/null 2>&1; then
		run_logged "rfkill-bluetooth" rfkill list bluetooth >/dev/null || true
	fi

	if command -v systemctl >/dev/null 2>&1; then
		run_logged "systemctl-bluetooth-active" systemctl is-active bluetooth >/dev/null || true
	fi
}

snapshot_device() {
	local mac="${1:-}"

	log_section "device snapshot: ${mac:-<no-mac>}"

	run_logged "bluetoothctl-devices" bluetoothctl -- devices >/dev/null || true

	if [ -n "$mac" ]; then
		run_logged "bluetoothctl-info-$mac" bluetoothctl -- info "$mac" >/dev/null || true
	fi

	run_logged "bluetoothctl-devices-connected" bluetoothctl -- devices Connected >/dev/null || true
	run_logged "bluetoothctl-devices-paired" bluetoothctl -- devices Paired >/dev/null || true
	run_logged "bluetoothctl-devices-trusted" bluetoothctl -- devices Trusted >/dev/null || true

	if command -v pactl >/dev/null 2>&1; then
		run_logged "pactl-sinks-short" pactl list short sinks >/dev/null || true
		run_logged "pactl-cards-short" pactl list short cards >/dev/null || true
	fi
}

debug_snapshot() {
	local mac

	mac="$(get_mac_by_name "$AUTO_DEVICE_NAME")"

	log_section "manual debug snapshot"
	snapshot_adapter
	snapshot_device "$mac"

	if command -v journalctl >/dev/null 2>&1; then
		run_logged "journalctl-bluetooth" journalctl -u bluetooth -n 120 --no-pager >/dev/null || true
	fi

	notify "Bluetooth debug snapshot written to $LOG"
}

ensure_target_trusted_once() {
	local mac="$1"
	local label="${2:-auto}"

	[ -n "$mac" ] || return 1

	if is_trusted "$mac"; then
		return 0
	fi

	if ! is_paired "$mac"; then
		log "$label trust skipped: $mac is not paired."
		return 1
	fi

	log_section "$label trust once: $mac"

	if run_logged "$label-trust-$mac" bluetoothctl -- trust "$mac" >/dev/null; then
		sleep 1
		if is_trusted "$mac"; then
			log "$label trust result: SUCCESS $mac"
			return 0
		fi
	fi

	log "$label trust result: FAILED $mac"
	return 1
}

connect_attempt() {
	local mac="$1"
	local mode="${2:-auto}"
	local name

	[ -n "$mac" ] || return 1

	name="$(device_name_for_mac "$mac")"
	[ -n "$name" ] || name="$mac"

	if is_connected "$mac"; then
		write_state "connected"
		log "$mode connect skipped: already Connected=yes $name <$mac>"
		return 0
	fi

	log_section "$mode connect attempt: $name <$mac>"
	write_state "connecting"

	ensure_power_on

	# Trust once if needed. This prevents interactive A2DP authorization prompts.
	ensure_target_trusted_once "$mac" "$mode" || true

	if [ -n "$CONNECT_PROFILE" ]; then
		run_logged_timeout "$CONNECT_TIMEOUT" "$mode-connect-$mac-$CONNECT_PROFILE" \
			bluetoothctl -- connect "$mac" "$CONNECT_PROFILE" >/dev/null || true
	else
		run_logged_timeout "$CONNECT_TIMEOUT" "$mode-connect-$mac" \
			bluetoothctl -- connect "$mac" >/dev/null || true
	fi

	sleep 1

	if is_connected "$mac"; then
		write_state "connected"
		log "$mode connect result: SUCCESS $name <$mac>"
		notify "Connected to $name"
		return 0
	fi

	log "$mode connect result: FAILED $name <$mac>"
	return 1
}

start_watcher() {
	if watcher_running; then
		notify "Auto watcher already running. PID: $(watcher_pid)"
		return 0
	fi

	local mac
	mac="$(get_mac_by_name "$AUTO_DEVICE_NAME")"

	if [ -n "$mac" ]; then
		ensure_target_trusted_once "$mac" start || true

		if is_connected "$mac"; then
			write_state "connected"
			log "Start skipped: $AUTO_DEVICE_NAME already Connected=yes at $mac."
			return 0
		fi
	fi

	nohup "$SELF" watch >/dev/null 2>&1 &
	notify "Auto watcher started for $AUTO_DEVICE_NAME"
}

stop_watcher() {
	local silent="${1:-0}"

	if ! watcher_running; then
		rm -f "$PIDFILE"
		case "$(read_state)" in
		connected) ;;
		*) write_state "stopped" ;;
		esac

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
	write_state "stopped"
	log "Watcher stopped by user."

	if [ "$silent" != "1" ]; then
		notify "Auto watcher stopped"
	fi
}

restart_watcher() {
	stop_watcher 1
	start_watcher
}

scan_devices_once() {
	log_section "scan once for ${SCAN_SECONDS}s"

	local out rc start end
	start="$(date +%s%3N)"

	out="$(
		{
			printf 'scan on\n'
			sleep "$SCAN_SECONDS"
			printf 'scan off\n'
			printf 'quit\n'
		} | bluetoothctl 2>&1
	)"
	rc=$?
	end="$(date +%s%3N)"

	log "SCAN exit=$rc duration_ms=$((end - start))"
	log_multiline "SCAN" "$out"
	return "$rc"
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
		case "$(read_state)" in
		connected) ;;
		*) write_state "stopped" ;;
		esac
		log "Watcher exited."
	}

	trap cleanup EXIT
	trap 'exit 0' INT TERM

	log_section "watcher started: target=$AUTO_DEVICE_NAME"
	write_state "starting"

	if [ "$STARTUP_GRACE_SECONDS" -gt 0 ]; then
		write_state "startup-grace-${STARTUP_GRACE_SECONDS}s"
		sleep "$STARTUP_GRACE_SECONDS"
	fi

	local mac last_attempt=0 failures=0 retry_after now last_unknown_scan=0 rc

	while true; do
		now="$(now_epoch)"
		mac="$(get_mac_by_name "$AUTO_DEVICE_NAME")"

		ensure_power_on

		if [ -z "$mac" ]; then
			write_state "target-unknown"
			log "Target not known in bluetoothctl devices: $AUTO_DEVICE_NAME"

			if [ $((now - last_unknown_scan)) -ge "$UNKNOWN_TARGET_SCAN_INTERVAL" ]; then
				scan_devices_once || true
				last_unknown_scan="$(now_epoch)"
			fi

			sleep "$INTERVAL"
			continue
		fi

		ensure_target_trusted_once "$mac" auto || true

		if is_connected "$mac"; then
			write_state "connected"
			log "$AUTO_DEVICE_NAME already Connected=yes at $mac. Exiting watcher."
			notify "$AUTO_DEVICE_NAME connected"
			exit 0
		fi

		if [ "$failures" -ge "$SLOW_AFTER_FAILURES" ]; then
			retry_after="$CONNECT_RETRY_SLOW_SECONDS"
		else
			retry_after="$CONNECT_RETRY_SECONDS"
		fi

		if [ "$last_attempt" -ne 0 ] && [ $((now - last_attempt)) -lt "$retry_after" ]; then
			write_state "retry-in-$((retry_after - (now - last_attempt)))s"
			sleep "$INTERVAL"
			continue
		fi

		last_attempt="$(now_epoch)"

		connect_attempt "$mac" auto
		rc=$?

		if [ "$rc" -eq 0 ]; then
			log "Auto watcher connected successfully. Exiting."
			exit 0
		fi

		failures=$((failures + 1))
		log "Auto attempt failed. failure_count=$failures retry_after=${retry_after}s"

		sleep "$INTERVAL"
	done
}

connect_mac() {
	local mac="$1"

	stop_watcher 1
	connect_attempt "$mac" manual
}

disconnect_mac() {
	local mac="$1"
	local name

	name="$(device_name_for_mac "$mac")"
	[ -n "$name" ] || name="$mac"

	stop_watcher 1

	log_section "manual disconnect: $name <$mac>"
	run_logged "manual-disconnect-$mac" bluetoothctl -- disconnect "$mac" >/dev/null || true
	sleep 1

	if is_connected "$mac"; then
		log "Manual disconnect result: STILL CONNECTED $name <$mac>"
		notify "Still connected to $name"
		return 1
	fi

	write_state "stopped"
	log "Manual disconnect result: DISCONNECTED $name <$mac>"
	notify "Disconnected $name"
}

status_notify() {
	local mac connected powered watcher state paired trusted services_resolved name battery sink_status

	mac="$(get_mac_by_name "$AUTO_DEVICE_NAME")"
	name="$AUTO_DEVICE_NAME"
	powered="$(adapter_powered)"
	state="$(read_state)"
	watcher="stopped"

	if watcher_running; then
		watcher="running, PID $(watcher_pid)"
	fi

	if [ -z "$mac" ]; then
		notify "Target: $name
MAC: not found
Adapter powered: ${powered:-unknown}
Connected: unknown
Watcher: $watcher
State: ${state:-unknown}"
		return 0
	fi

	connected="$(connected_text "$mac")"
	paired="$(device_prop "$mac" Paired)"
	trusted="$(device_prop "$mac" Trusted)"
	services_resolved="$(device_prop "$mac" ServicesResolved)"
	battery="$(device_prop "$mac" "Battery Percentage")"
	sink_status="$(audio_sink_status "$mac")"

	notify "Target: $name
MAC: $mac
Adapter powered: ${powered:-unknown}
Connected: ${connected:-unknown}
Paired: ${paired:-unknown}
Trusted: ${trusted:-unknown}
ServicesResolved: ${services_resolved:-unknown}
Audio sink: $sink_status
Battery: ${battery:-unknown}
Watcher: $watcher
State: ${state:-unknown}"
}

polybar_output() {
	local mac state

	mac="$(get_mac_by_name "$AUTO_DEVICE_NAME")"
	state="$(read_state)"

	# Important: no pactl call here. Polybar runs often.
	if [ -n "$mac" ] && is_connected "$mac"; then
		printf 'BT %s ✓\n' "$AUTO_DEVICE_NAME"
		return
	fi

	if watcher_running; then
		case "$state" in
		starting | startup-grace-*) printf 'BT %s boot\n' "$AUTO_DEVICE_NAME" ;;
		connecting) printf 'BT %s conn\n' "$AUTO_DEVICE_NAME" ;;
		retry-in-*) printf 'BT %s wait\n' "$AUTO_DEVICE_NAME" ;;
		target-unknown) printf 'BT ?\n' ;;
		*) printf 'BT %s …\n' "$AUTO_DEVICE_NAME" ;;
		esac
		return
	fi

	if [ -z "$mac" ]; then
		printf 'BT ?\n'
	else
		printf 'BT %s ×\n' "$AUTO_DEVICE_NAME"
	fi
}

format_device_row() {
	local mac="$1"
	local name status prefix paired trusted sink

	name="$(device_name_for_mac "$mac")"
	[ -n "$name" ] || name="$mac"

	status="off"
	if is_connected "$mac"; then
		status="connected"
	fi

	sink="$(audio_sink_status "$mac")"
	paired="$(device_prop "$mac" Paired)"
	trusted="$(device_prop "$mac" Trusted)"

	prefix="  "
	if [ "$name" = "$AUTO_DEVICE_NAME" ] || [[ "$name" == *"$AUTO_DEVICE_NAME"* ]]; then
		prefix="★ "
	fi

	printf '%s%s    %s    [%s paired:%s trusted:%s sink:%s]\n' \
		"$prefix" "$name" "$mac" "$status" "${paired:-?}" "${trusted:-?}" "$sink"
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
	ensure_power_on
	scan_devices_once || true
	notify "Bluetooth scan finished"
}

device_action_menu() {
	local mac="$1"
	local name connected paired trusted services_resolved action info

	name="$(device_name_for_mac "$mac")"
	[ -n "$name" ] || name="$mac"

	connected="$(connected_text "$mac")"
	paired="$(device_prop "$mac" Paired)"
	trusted="$(device_prop "$mac" Trusted)"
	services_resolved="$(device_prop "$mac" ServicesResolved)"

	action="$(
		printf '%s\n' \
			"Connect" \
			"Disconnect" \
			"Stop watcher + disconnect" \
			"Trust" \
			"Untrust" \
			"Pair" \
			"Remove device" \
			"Info notification" \
			"Debug snapshot" \
			"Restart auto watcher" \
			"Stop auto watcher" |
			rofi -dmenu -i \
				-p "$name" \
				-mesg "MAC: $mac | Connected: ${connected:-unknown} | Paired: ${paired:-?} | Trusted: ${trusted:-?} | ServicesResolved: ${services_resolved:-?}"
	)" || return 0

	case "$action" in
	Connect)
		connect_mac "$mac"
		;;
	Disconnect)
		disconnect_mac "$mac"
		;;
	"Stop watcher + disconnect")
		stop_watcher 1
		disconnect_mac "$mac"
		;;
	Trust)
		log_section "manual trust: $name <$mac>"
		run_logged "manual-trust-$mac" bluetoothctl -- trust "$mac" >/dev/null || true
		sleep 1
		notify "Trust command sent for $name"
		;;
	Untrust)
		log_section "manual untrust: $name <$mac>"
		run_logged "manual-untrust-$mac" bluetoothctl -- untrust "$mac" >/dev/null || true
		sleep 1
		notify "Untrust command sent for $name"
		;;
	Pair)
		stop_watcher 1
		log_section "manual pair: $name <$mac>"
		run_logged_timeout "$CONNECT_TIMEOUT" "manual-pair-$mac" bluetoothctl -- pair "$mac" >/dev/null || true
		sleep 1
		notify "Pair command sent for $name"
		;;
	"Remove device")
		stop_watcher 1
		log_section "manual remove: $name <$mac>"
		run_logged "manual-remove-$mac" bluetoothctl -- remove "$mac" >/dev/null || true
		notify "Removed $name"
		;;
	"Info notification")
		info="$(
			bt info "$mac" 2>/dev/null |
				awk -F': ' '
					/Name:/ { name=$2 }
					/Alias:/ { alias=$2 }
					/Connected:/ { connected=$2 }
					/Paired:/ { paired=$2 }
					/Bonded:/ { bonded=$2 }
					/Trusted:/ { trusted=$2 }
					/Blocked:/ { blocked=$2 }
					/ServicesResolved:/ { services=$2 }
					/Battery Percentage:/ { battery=$2 }
					END {
						printf "Name: %s\nAlias: %s\nConnected: %s\nPaired: %s\nBonded: %s\nTrusted: %s\nBlocked: %s\nServicesResolved: %s\nBattery: %s", name, alias, connected, paired, bonded, trusted, blocked, services, battery
					}
				'
		)"
		notify "$info"
		;;
	"Debug snapshot")
		snapshot_adapter
		snapshot_device "$mac"
		notify "Debug snapshot written to $LOG"
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

	local choice mac state watcher

	state="$(read_state)"
	watcher="stopped"
	if watcher_running; then
		watcher="running"
	fi

	choice="$(
		{
			printf '★ Auto target: %s\n' "$AUTO_DEVICE_NAME"
			printf '↻ Restart auto watcher\n'
			printf '■ Stop auto watcher\n'
			printf '⌕ Scan %ss then reopen\n' "$SCAN_SECONDS"
			printf 'ⓘ Status notification\n'
			printf '⚙ Debug snapshot\n'
			printf '────────────\n'
			device_rows
		} |
			rofi -dmenu -i \
				-p "Bluetooth" \
				-mesg "Watcher: $watcher | State: ${state:-unknown} | Enter: manage device"
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
	"ⓘ Status notification")
		status_notify
		;;
	"⚙ Debug snapshot")
		debug_snapshot
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
	tail -n 160 "$LOG"
}

follow_log() {
	tail -f "$LOG"
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
	show_log
	;;
follow-log)
	follow_log
	;;
*)
	echo "Usage: $0 {start|stop|restart|status|polybar|menu|watch|scan|debug|log|follow-log}" >&2
	exit 2
	;;
esac
