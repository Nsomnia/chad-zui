# ═══════════════════════════════════════════════════════════════════════════════
#  MODE: NOTIFY
# ═══════════════════════════════════════════════════════════════════════════════

##
# @function mode_notify
# @description Display a toast-style notification
##
mode_notify() {
    local message="" type="info" duration=3

    while [[ $# -gt 0 ]]; do
        case "$1" in
            -h|--help)
                printf '\n  %bNOTIFY MODE%b - Toast notifications\n' "${THEME[accent]}" "${COLORS[reset]}"
                printf '  Usage: %s notify "message" [--type info|success|error|warning]\n\n' "$CHAD_NAME"
                return 0
                ;;
            --type) type="$2"; shift 2 ;;
            --duration) duration="$2"; shift 2 ;;
            *) message="$1"; shift ;;
        esac
    done

    local icon bg_color
    case "$type" in
        success) icon="${BOX[check]}"      ; bg_color="${COLORS[bg_green]}" ;;
        error)   icon="${BOX[cross_mark]}" ; bg_color="${COLORS[bg_red]}" ;;
        warning) icon="${BOX[diamond]}"    ; bg_color="${COLORS[bg_yellow]}${COLORS[black]}" ;;
        *)       icon="${BOX[bullet]}"     ; bg_color="${COLORS[bg_blue]}" ;;
    esac

    printf '\n  %b %s %s %b\n\n' "$bg_color" "$icon" "$message" "${COLORS[reset]}"

    return 0
}
