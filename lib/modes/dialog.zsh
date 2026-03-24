# ═══════════════════════════════════════════════════════════════════════════════
#  MODE: DIALOG
# ═══════════════════════════════════════════════════════════════════════════════

##
# @function mode_dialog
# @description Display a styled message dialog
# @param $1 string - Message content
##
mode_dialog() {
    local message="" title="" type="info" width=50 style="rounded"

    while [[ $# -gt 0 ]]; do
        case "$1" in
            -h|--help) show_dialog_help; return 0 ;;
            --title) title="$2"; shift 2 ;;
            --type) type="$2"; shift 2 ;;
            --width) width="$2"; shift 2 ;;
            --style) style="$2"; shift 2 ;;
            -*) show_error "Unknown option: $1"; return 1 ;;
            *) message="$1"; shift ;;
        esac
    done

    if [[ -z "$message" ]]; then
        show_error "No message provided" "Usage: $CHAD_NAME dialog \"message\""
        return 1
    fi

    local icon border_color
    case "$type" in
        success) icon="${BOX[check]}" ; border_color="${THEME[success]}" ;;
        error)   icon="${BOX[cross_mark]}" ; border_color="${THEME[error]}" ;;
        warning) icon="${BOX[diamond]}" ; border_color="${THEME[warning]}" ;;
        *)       icon="${BOX[bullet]}" ; border_color="${THEME[primary]}" ;;
    esac

    local tl tr bl br h v
    case "$style" in
        heavy)   tl="${BOX[htl]}" tr="${BOX[htr]}" bl="${BOX[hbl]}" br="${BOX[hbr]}" h="${BOX[hh]}" v="${BOX[hv]}" ;;
        double)  tl="${BOX[dtl]}" tr="${BOX[dtr]}" bl="${BOX[dbl]}" br="${BOX[dbr]}" h="${BOX[dh]}" v="${BOX[dv]}" ;;
        light)   tl="${BOX[tl]}"  tr="${BOX[tr]}"  bl="${BOX[bl]}"  br="${BOX[br]}"  h="${BOX[h]}"  v="${BOX[v]}"  ;;
        *)       tl="${BOX[rtl]}" tr="${BOX[rtr]}" bl="${BOX[rbl]}" br="${BOX[rbr]}" h="${BOX[h]}"  v="${BOX[v]}"  ;;
    esac

    local inner_width=$((width - 4))

    printf '\n'

    # Top border with title
    printf '  %b%s' "$border_color" "$tl"
    if [[ -n "$title" ]]; then
        local title_display=" $icon $title "
        local title_len=$(str_len_visible "$title_display")
        local left=$((( inner_width - title_len + 2) / 2))
        local right=$((inner_width + 2 - left - title_len))
        printf '%s' "$(str_repeat "$h" $left)"
        printf '%b%s%b' "${COLORS[bold]}" "$title_display" "${COLORS[reset]}$border_color"
        printf '%s' "$(str_repeat "$h" $right)"
    else
        printf '%s' "$(str_repeat "$h" $((width - 2)))"
    fi
    printf '%s%b\n' "$tr" "${COLORS[reset]}"

    # Empty line
    printf '  %b%s%b%s%b%s%b\n' \
        "$border_color" "$v" "${COLORS[reset]}" \
        "$(str_repeat ' ' $((width - 2)))" \
        "$border_color" "$v" "${COLORS[reset]}"

    # Message (word-wrapped)
    local -a words=(${=message})
    local line=""
    for word in "${words[@]}"; do
        if (( ${#line} + ${#word} + 1 > inner_width )); then
            local padded=$(str_pad "$line" $inner_width)
            printf '  %b%s%b  %s  %b%s%b\n' \
                "$border_color" "$v" "${COLORS[reset]}" \
                "$padded" \
                "$border_color" "$v" "${COLORS[reset]}"
            line="$word"
        else
            [[ -n "$line" ]] && line+=" "
            line+="$word"
        fi
    done
    if [[ -n "$line" ]]; then
        local padded=$(str_pad "$line" $inner_width)
        printf '  %b%s%b  %s  %b%s%b\n' \
            "$border_color" "$v" "${COLORS[reset]}" \
            "$padded" \
            "$border_color" "$v" "${COLORS[reset]}"
    fi

    # Empty line
    printf '  %b%s%b%s%b%s%b\n' \
        "$border_color" "$v" "${COLORS[reset]}" \
        "$(str_repeat ' ' $((width - 2)))" \
        "$border_color" "$v" "${COLORS[reset]}"

    # Bottom border
    printf '  %b%s%s%s%b\n\n' \
        "$border_color" "$bl" "$(str_repeat "$h" $((width - 2)))" "$br" "${COLORS[reset]}"

    return 0
}
