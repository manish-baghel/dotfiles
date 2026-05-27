#!/usr/bin/env bash
set -u

PRIMARY="HDMI-0"
SECONDARY="DP-2"

PRIMARY_MODE="3840x2160"
PRIMARY_RATE="60.00"
PRIMARY_W=3840
PRIMARY_H=2160

SECONDARY_MODE="1920x1080"
SECONDARY_RATE="143.98"
SECONDARY_W=1920
SECONDARY_H=1080

DPI_FALLBACK=120

ACTION="auto"
DRY_RUN=0

usage() {
	cat <<USAGE
Usage: $0 [--dry-run|-n|dryrun|print] [auto|single|dual|rescue]

Examples:
  $0 --dry-run auto
  $0 dryrun single
  $0 print dual
  $0 auto
USAGE
}

while [ $# -gt 0 ]; do
	case "$1" in
	--dry-run | -n | dryrun | dry-run | print)
		DRY_RUN=1
		;;
	auto | single | dual | rescue)
		ACTION="$1"
		;;
	-h | --help | help)
		usage
		exit 0
		;;
	*)
		echo "Unknown argument: $1" >&2
		usage >&2
		exit 2
		;;
	esac
	shift
done

LOG="$HOME/.cache/monitors.log"
mkdir -p "$(dirname "$LOG")"

emit_line() {
	if [ "$DRY_RUN" -eq 1 ]; then
		printf '%s\n' "$*" | tee -a "$LOG"
	else
		printf '%s\n' "$*" >>"$LOG"
	fi
}

emit_cmd() {
	local suffix="$1"
	shift

	if [ "$DRY_RUN" -eq 1 ]; then
		{
			printf '+ '
			printf '%q ' "$@"
			printf '%s\n' "$suffix"
		} | tee -a "$LOG"
	else
		{
			printf '+ '
			printf '%q ' "$@"
			printf '%s\n' "$suffix"
		} >>"$LOG"
	fi
}

run() {
	emit_cmd "" "$@"

	if [ "$DRY_RUN" -eq 1 ]; then
		return 0
	fi

	"$@"
}

run_quiet() {
	emit_cmd ">/dev/null 2>&1" "$@"

	if [ "$DRY_RUN" -eq 1 ]; then
		return 0
	fi

	"$@" >/dev/null 2>&1
}

run_bg() {
	emit_cmd ">/dev/null 2>&1 &" "$@"

	if [ "$DRY_RUN" -eq 1 ]; then
		return 0
	fi

	"$@" >/dev/null 2>&1 &
}

read_dpi() {
	local dpi=""

	if [ -r "$HOME/.Xresources" ]; then
		dpi="$(
			awk -F: '
                /^[[:space:]]*Xft\.dpi[[:space:]]*:/ {
                    gsub(/[[:space:]]/, "", $2)
                    print int($2)
                    exit
                }
            ' "$HOME/.Xresources" 2>/dev/null
		)"
	fi

	if [ -z "${dpi:-}" ]; then
		dpi="$(
			xrdb -query 2>/dev/null |
				awk '/^Xft\.dpi:/ { print int($2); exit }'
		)"
	fi

	[ -n "${dpi:-}" ] || dpi="$DPI_FALLBACK"
	printf '%s\n' "$dpi"
}

connected() {
	xrandr --query 2>/dev/null | grep -q "^$1 connected"
}

notify() {
	run_quiet notify-send "Monitor layout" "$1"
}

refresh_desktop_bits() {
	run_bg nitrogen --restore

	if command -v fix_xcursor >/dev/null 2>&1; then
		run_bg fix_xcursor
	fi

	if [ -x "$HOME/.config/polybar/start.sh" ]; then
		run_bg "$HOME/.config/polybar/start.sh"
	fi
}

# In i3 this is already set. These defaults help when running from TTY.
export DISPLAY="${DISPLAY:-:0}"
export XAUTHORITY="${XAUTHORITY:-$HOME/.Xauthority}"

emit_line "===== $(date) :: monitors.sh action=$ACTION dry_run=$DRY_RUN ====="

# Live mode merges Xresources. Dry-run only prints this command.
if [ -r "$HOME/.Xresources" ]; then
	run_quiet xrdb -merge "$HOME/.Xresources"
fi

DPI="$(read_dpi)"

SCALE="$(
	awk -v dpi="$DPI" 'BEGIN { printf "%.7f", dpi / 96 }'
)"

SECONDARY_LOGICAL_W="$(
	awk -v w="$SECONDARY_W" -v s="$SCALE" 'BEGIN { printf "%d", (w * s) + 0.5 }'
)"

SECONDARY_LOGICAL_H="$(
	awk -v h="$SECONDARY_H" -v s="$SCALE" 'BEGIN { printf "%d", (h * s) + 0.5 }'
)"

FB_W=$((PRIMARY_W + SECONDARY_LOGICAL_W))

if [ "$SECONDARY_LOGICAL_H" -gt "$PRIMARY_H" ]; then
	FB_H="$SECONDARY_LOGICAL_H"
	SECONDARY_Y=0
else
	FB_H="$PRIMARY_H"
	SECONDARY_Y=$((PRIMARY_H - SECONDARY_LOGICAL_H))
fi

SECONDARY_X="$PRIMARY_W"

mm_for_dpi() {
	awk -v px="$1" -v dpi="$DPI" 'BEGIN { printf "%d", (px * 25.4 / dpi) + 0.5 }'
}

PRIMARY_FBMM_W="$(mm_for_dpi "$PRIMARY_W")"
PRIMARY_FBMM_H="$(mm_for_dpi "$PRIMARY_H")"

FBMM_W="$(mm_for_dpi "$FB_W")"
FBMM_H="$(mm_for_dpi "$FB_H")"

emit_line "# primary_fbmm=${PRIMARY_FBMM_W}x${PRIMARY_FBMM_H} fbmm=${FBMM_W}x${FBMM_H}"

emit_line "# primary=$PRIMARY secondary=$SECONDARY dpi=$DPI scale=$SCALE"
emit_line "# secondary_logical=${SECONDARY_LOGICAL_W}x${SECONDARY_LOGICAL_H} fb=${FB_W}x${FB_H} secondary_pos=${SECONDARY_X}x${SECONDARY_Y}"

rescue_layout() {
	emit_line "# resolved=rescue"

	run xrandr --auto || true
	run sleep 0.5

	if connected "$PRIMARY"; then
		run xrandr \
			--output "$PRIMARY" --auto --primary \
			--pos 0x0 \
			--rotate normal \
			--scale 1x1 \
			--panning 0x0 || true
	fi

	if connected "$PRIMARY" && connected "$SECONDARY"; then
		run xrandr \
			--output "$PRIMARY" --auto --primary \
			--pos 0x0 \
			--rotate normal \
			--scale 1x1 \
			--panning 0x0 \
			--output "$SECONDARY" --auto \
			--right-of "$PRIMARY" \
			--rotate normal \
			--scale 1x1 \
			--panning 0x0 || true
	fi

	refresh_desktop_bits
	notify "Rescue layout applied"
}

single_layout() {
	emit_line "# resolved=single"

	if ! connected "$PRIMARY"; then
		emit_line "# $PRIMARY is not connected; refusing to disable anything; using rescue"
		rescue_layout
		notify "$PRIMARY not connected; rescue layout used"
		return 1
	fi

	# Step 0: validate that HDMI-0 can be set to the intended mode.
	if ! run xrandr --dryrun \
		--output "$PRIMARY" --primary \
		--mode "$PRIMARY_MODE" \
		--rate "$PRIMARY_RATE" \
		--pos 0x0 \
		--rotate normal \
		--scale 1x1 \
		--panning 0x0; then
		emit_line "# HDMI-0 dry-run validation failed; using rescue"
		rescue_layout
		return 1
	fi

	# Step 1: make/reaffirm HDMI-0 visible while DP-2 is still untouched.
	if ! run xrandr \
		--output "$PRIMARY" --primary \
		--mode "$PRIMARY_MODE" \
		--rate "$PRIMARY_RATE" \
		--pos 0x0 \
		--rotate normal \
		--scale 1x1 \
		--panning 0x0; then
		emit_line "# HDMI-0 visible step failed; using rescue"
		rescue_layout
		return 1
	fi

	run sleep 0.5

	# Step 2: only now turn off the secondary.
	# If this fails, HDMI-0 should still remain visible.
	if connected "$SECONDARY"; then
		if ! run xrandr --output "$SECONDARY" --off; then
			emit_line "# Could not turn off $SECONDARY; leaving HDMI-0 visible"
		fi
	else
		emit_line "# $SECONDARY already disconnected/off"
	fi

	run sleep 0.3

	# Step 3: shrink framebuffer after DP-2 is off.
	if ! run xrandr --fb "${PRIMARY_W}x${PRIMARY_H}" --fbmm "${PRIMARY_FBMM_W}x${PRIMARY_FBMM_H}"; then
		emit_line "# Framebuffer shrink failed; leaving visible primary layout"
	fi

	run sleep 0.3

	# Step 4: reassert primary after framebuffer resize.
	run xrandr \
		--output "$PRIMARY" --primary \
		--mode "$PRIMARY_MODE" \
		--rate "$PRIMARY_RATE" \
		--pos 0x0 \
		--rotate normal \
		--scale 1x1 \
		--panning 0x0 || true

	refresh_desktop_bits
	notify "Single: $PRIMARY only, DPI $DPI"
}

dual_layout() {
	emit_line "# resolved=dual"

	if ! connected "$PRIMARY"; then
		emit_line "# $PRIMARY is not connected; using rescue"
		rescue_layout
		return 1
	fi

	if ! connected "$SECONDARY"; then
		emit_line "# $SECONDARY is not connected; using single"
		single_layout
		return 0
	fi

	# Validation command. In live mode this is actually executed before applying.
	if ! run xrandr --dryrun \
		--fb "${FB_W}x${FB_H}" \
		--fbmm "${FBMM_W}x${FBMM_H}" \
		--output "$PRIMARY" --primary \
		--mode "$PRIMARY_MODE" \
		--rate "$PRIMARY_RATE" \
		--pos 0x0 \
		--rotate normal \
		--scale 1x1 \
		--panning 0x0 \
		--output "$SECONDARY" \
		--mode "$SECONDARY_MODE" \
		--rate "$SECONDARY_RATE" \
		--pos "${SECONDARY_X}x${SECONDARY_Y}" \
		--rotate normal \
		--scale "${SCALE}x${SCALE}" \
		--panning "${SECONDARY_LOGICAL_W}x${SECONDARY_LOGICAL_H}+${SECONDARY_X}+${SECONDARY_Y}"; then
		emit_line "# Dual dry-run validation failed; using rescue"
		rescue_layout
		return 1
	fi

	if ! run xrandr \
		--fb "${FB_W}x${FB_H}" \
		--fbmm "${FBMM_W}x${FBMM_H}" \
		--output "$PRIMARY" --primary \
		--mode "$PRIMARY_MODE" \
		--rate "$PRIMARY_RATE" \
		--pos 0x0 \
		--rotate normal \
		--scale 1x1 \
		--panning 0x0 \
		--output "$SECONDARY" \
		--mode "$SECONDARY_MODE" \
		--rate "$SECONDARY_RATE" \
		--pos "${SECONDARY_X}x${SECONDARY_Y}" \
		--rotate normal \
		--scale "${SCALE}x${SCALE}" \
		--panning "${SECONDARY_LOGICAL_W}x${SECONDARY_LOGICAL_H}+${SECONDARY_X}+${SECONDARY_Y}"; then
		emit_line "# Dual apply failed; using rescue"
		rescue_layout
		return 1
	fi

	run_quiet i3-msg \
		"workspace 6; move workspace to output $SECONDARY; workspace 7; move workspace to output $SECONDARY; workspace 8; move workspace to output $SECONDARY; workspace 1"

	refresh_desktop_bits
	notify "Dual: $PRIMARY + $SECONDARY, DPI $DPI, scale $SCALE"
}

case "$ACTION" in
rescue)
	rescue_layout
	;;
single)
	single_layout
	;;
dual)
	dual_layout
	;;
auto)
	if connected "$SECONDARY"; then
		dual_layout
	else
		single_layout
	fi
	;;
*)
	usage >&2
	exit 2
	;;
esac
