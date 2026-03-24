# ═══════════════════════════════════════════════════════════════════════════════
#  MODE: CONFIRM
# ═══════════════════════════════════════════════════════════════════════════════

##
# @function mode_confirm
# @description Yes/No confirmation dialog
# @param $1 string - Prompt message
# @return int      - 0 for yes, 1 for no
##
mode_confirm() {
    local prompt="" affirmative="Yes" negative="No" default="y"

    while [[ $# -gt 0 ]]; do
        case "$1" in
            -h|--help) show_confirm_help; return 0 ;;
            --affirmative) affirmative="$2"; shift 2 ;;
            --negative) negative="$2"; shift 2 ;;
            --default) default="$2"; shift 2 ;;
            -*) show_error "Unknown option: $1"; return 1 ;;
            *) prompt="$1"; shift ;;
        esac
    done

    if [[ -z "$prompt" ]]; then
        show_error "No prompt provided" "Usage: $CHAD_NAME confirm \"Your question?\""
        return 1
    fi

    local selected=0
    [[ "$default" == "n" ]] && selected=1

    cursor_hide

    while true; do
        printf '\r\033[J\n'

        printf '  %b%s%b  %s\n\n' "${THEME[accent]}" "${BOX[diamond]}" "${COLORS[reset]}" "$prompt"

        # Buttons
        printf '  '

        if ((selected == 0)); then
            printf '%b %s %b' "${THEME[primary]}${COLORS[reverse]}" "$affirmative" "${COLORS[reset]}"
        else
            printf '%b %s %b' "${THEME[muted]}" "$affirmative" "${COLORS[reset]}"
        fi

        printf '   '

        if ((selected == 1)); then
            printf '%b %s %b' "${THEME[primary]}${COLORS[reverse]}" "$negative" "${COLORS[reset]}"
        else
            printf '%b %s %b' "${THEME[muted]}" "$negative" "${COLORS[reset]}"
        fi

        printf '\n\n'
        printf '  %b←/→ switch • enter confirm%b\n' "${THEME[muted]}" "${COLORS[reset]}"

        local key=$(read_key)

        case "$key" in
            left|h|up|k|tab)
                selected=0
                ;;
            right|l|down|j)
                selected=1
                ;;
            enter)
                cursor_show
                printf '\033[5A\033[J'
                if ((selected == 0)); then
                    return 0
                else
                    return 1
                fi
                ;;
            y|Y)
                cursor_show
                printf '\033[5A\033[J'
                return 0
                ;;
            n|N|quit|esc)
                cursor_show
                printf '\033[5A\033[J'
                return 1
                ;;
        esac

        printf '\033[5A'
    done
}
