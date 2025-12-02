# ═══════════════════════════════════════════════════════════════════════════════
#  MODE: INPUT
# ═══════════════════════════════════════════════════════════════════════════════

##
# @function mode_input
# @description Text input with styling and validation
# @return stdout - Entered text
# @return int    - 0 on submit, 1 on cancel
##
mode_input() {
    local header="" placeholder="" value="" width=40 char_limit=0
    local password=0 required=0 regex=""

    while [[ $# -gt 0 ]]; do
        case "$1" in
            -h|--help) show_input_help; return 0 ;;
            --header) header="$2"; shift 2 ;;
            --placeholder) placeholder="$2"; shift 2 ;;
            --value) value="$2"; shift 2 ;;
            --width) width="$2"; shift 2 ;;
            --char-limit) char_limit="$2"; shift 2 ;;
            --password) password=1; shift ;;
            --required) required=1; shift ;;
            --regex) regex="$2"; shift 2 ;;
            *) show_error "Unknown option: $1"; return 1 ;;
        esac
    done

    local cursor_pos=${#value}
    local input="$value"
    local error_msg=""

    cursor_hide

    while true; do
        printf '\r\033[J'

        # Header
        if [[ -n "$header" ]]; then
            printf '\n  %b%s%b\n\n' "${THEME[accent]}" "$header" "${COLORS[reset]}"
        else
            printf '\n'
        fi

        # Input box
        local display_text="$input"
        if ((password)) && [[ -n "$input" ]]; then
            display_text=$(str_repeat "●" ${#input})
        elif [[ -z "$input" && -n "$placeholder" ]]; then
            display_text="${THEME[muted]}${placeholder}${COLORS[reset]}"
        fi

        local box_content="$display_text"
        local padded=$(str_pad "$box_content" $((width - 4)))

        printf '  %b%s%b' "${THEME[primary]}" "${BOX[rtl]}" "${COLORS[reset]}"
        printf '%b%s%b' "${THEME[primary]}" "$(str_repeat "${BOX[h]}" $((width - 2)))" "${COLORS[reset]}"
        printf '%b%s%b\n' "${THEME[primary]}" "${BOX[rtr]}" "${COLORS[reset]}"

        printf '  %b%s%b ' "${THEME[primary]}" "${BOX[v]}" "${COLORS[reset]}"
        printf '%s' "$padded"
        printf ' %b%s%b\n' "${THEME[primary]}" "${BOX[v]}" "${COLORS[reset]}"

        printf '  %b%s%b' "${THEME[primary]}" "${BOX[rbl]}" "${COLORS[reset]}"
        printf '%b%s%b' "${THEME[primary]}" "$(str_repeat "${BOX[h]}" $((width - 2)))" "${COLORS[reset]}"
        printf '%b%s%b\n' "${THEME[primary]}" "${BOX[rbr]}" "${COLORS[reset]}"

        # Error or hint
        if [[ -n "$error_msg" ]]; then
            printf '\n  %b%s %s%b\n' "${THEME[error]}" "${BOX[cross_mark]}" "$error_msg" "${COLORS[reset]}"
        else
            printf '\n  %b%s%b\n' "${THEME[muted]}" "enter submit • esc cancel" "${COLORS[reset]}"
        fi

        if ((char_limit > 0)); then
            local remaining=$((char_limit - ${#input}))
            local count_color="${THEME[muted]}"
            ((remaining < 10)) && count_color="${THEME[warning]}"
            ((remaining < 0)) && count_color="${THEME[error]}"
            printf '  %b%d/%d%b\n' "$count_color" "${#input}" "$char_limit" "${COLORS[reset]}"
        fi

        # Position cursor in input box
        printf '\033[3A\033[%dC' $((4 + cursor_pos))
        cursor_show

        local key=$(read_key)
        cursor_hide

        # Move back to start
        printf '\r\033[3B'

        error_msg=""

        case "$key" in
            enter)
                if ((required)) && [[ -z "$input" ]]; then
                    error_msg="This field is required"
                elif [[ -n "$regex" ]] && [[ ! "$input" =~ $regex ]]; then
                    error_msg="Input doesn't match required format"
                elif ((char_limit > 0 && ${#input} > char_limit)); then
                    error_msg="Exceeds character limit"
                else
                    cursor_show
                    printf '\r\033[J'
                    printf '%s\n' "$input"
                    return 0
                fi
                ;;
            esc|quit)
                cursor_show
                printf '\r\033[J'
                return 1
                ;;
            backspace)
                if ((cursor_pos > 0)); then
                    input="${input:0:$((cursor_pos-1))}${input:$cursor_pos}"
                    ((cursor_pos--))
                fi
                ;;
            delete)
                if ((cursor_pos < ${#input})); then
                    input="${input:0:$cursor_pos}${input:$((cursor_pos+1))}"
                fi
                ;;
            left)
                ((cursor_pos > 0)) && ((cursor_pos--))
                ;;
            right)
                ((cursor_pos < ${#input})) && ((cursor_pos++))
                ;;
            home)
                cursor_pos=0
                ;;
            end)
                cursor_pos=${#input}
                ;;
            *)
                if [[ ${#key} -eq 1 ]] && [[ "$key" =~ [[:print:]] ]]; then
                    input="${input:0:$cursor_pos}${key}${input:$cursor_pos}"
                    ((cursor_pos++))
                fi
                ;;
        esac

        printf '\033[6A'
    done
}
