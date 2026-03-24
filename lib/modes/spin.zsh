# ═══════════════════════════════════════════════════════════════════════════════
#  MODE: SPIN
# ═══════════════════════════════════════════════════════════════════════════════

##
# @function mode_spin
# @description Display a loading spinner while executing a command
##
mode_spin() {
    local title="Loading..." spinner_type="dots" success_msg="Done!" fail_msg="Failed!"
    local -a cmd=()

    while [[ $# -gt 0 ]]; do
        case "$1" in
            -h|--help) show_spin_help; return 0 ;;
            --title) title="$2"; shift 2 ;;
            --spinner) spinner_type="$2"; shift 2 ;;
            --success) success_msg="$2"; shift 2 ;;
            --fail) fail_msg="$2"; shift 2 ;;
            --) shift; cmd=("$@"); break ;;
            *) cmd+=("$1"); shift ;;
        esac
    done

    local -a frames
    case "$spinner_type" in
        line)   frames=("—" "\\" "|" "/") ;;
        circle) frames=("◐" "◓" "◑" "◒") ;;
        arrow)  frames=("←" "↖" "↑" "↗" "→" "↘" "↓" "↙") ;;
        pulse)  frames=("█" "▓" "▒" "░" "▒" "▓") ;;
        *)      frames=("⠋" "⠙" "⠹" "⠸" "⠼" "⠴" "⠦" "⠧" "⠇" "⠏") ;;
    esac

    local num_frames=${#frames[@]}
    local frame_idx=0
    local pid

    cursor_hide

    if [[ ${#cmd[@]} -gt 0 ]]; then
        # Run command in background
        "${cmd[@]}" &>/dev/null &
        pid=$!

        while kill -0 "$pid" 2>/dev/null; do
            printf '\r  %b%s%b %s' \
                "${THEME[primary]}" "${frames[$frame_idx]}" "${COLORS[reset]}" "$title"
            ((frame_idx = (frame_idx + 1) % num_frames))
            sleep 0.1
        done

        wait "$pid"
        local exit_code=$?

        cursor_show

        if ((exit_code == 0)); then
            printf '\r  %b%s%b %s\033[K\n' \
                "${THEME[success]}" "${BOX[check]}" "${COLORS[reset]}" "$success_msg"
        else
            printf '\r  %b%s%b %s\033[K\n' \
                "${THEME[error]}" "${BOX[cross_mark]}" "${COLORS[reset]}" "$fail_msg"
        fi

        return $exit_code
    else
        # Demo mode - spin for 3 seconds
        local end_time=$((SECONDS + 3))
        while ((SECONDS < end_time)); do
            printf '\r  %b%s%b %s' \
                "${THEME[primary]}" "${frames[$frame_idx]}" "${COLORS[reset]}" "$title"
            ((frame_idx = (frame_idx + 1) % num_frames))
            sleep 0.1
        done

        cursor_show
        printf '\r  %b%s%b %s\033[K\n' \
            "${THEME[success]}" "${BOX[check]}" "${COLORS[reset]}" "$success_msg"

        return 0
    fi
}
