# ═══════════════════════════════════════════════════════════════════════════════
#  MODE: CHOOSE
# ═══════════════════════════════════════════════════════════════════════════════

##
# @function mode_choose
# @description Interactive selection menu
# @param $@ - Items to choose from and options
# @return stdout - Selected item(s)
# @return int    - 0 on selection, 1 on cancel
##
mode_choose() {
    local -a items=()
    local header="" cursor="${BOX[tri_r]}" multi=0 limit=0 no_wrap=0
    local -a selected_indices=()

    # Parse arguments
    while [[ $# -gt 0 ]]; do
        case "$1" in
            -h|--help) show_choose_help; return 0 ;;
            --multi) multi=1; shift ;;
            --header) header="$2"; shift 2 ;;
            --cursor) cursor="$2"; shift 2 ;;
            --selected) selected_indices+=("$2"); shift 2 ;;
            --limit) limit="$2"; shift 2 ;;
            --no-wrap) no_wrap=1; shift ;;
            --) shift; items+=("$@"); break ;;
            -*) show_error "Unknown option: $1" "Valid options: --multi, --header, --cursor"; return 1 ;;
            *) items+=("$1"); shift ;;
        esac
    done

    if [[ ${#items[@]} -eq 0 ]]; then
        show_error "No items provided" "Usage: $CHAD_NAME choose <item1> <item2> ..."
        return 1
    fi

    local current=0
    local num_items=${#items[@]}
    local -A selected=()

    # Initialize pre-selected
    for idx in "${selected_indices[@]}"; do
        ((idx >= 0 && idx < num_items)) && selected[$idx]=1
    done

    # Prepare terminal
    cursor_hide


    local max_width=0
    for item in "${items[@]}"; do
        ((${#item} > max_width)) && max_width=${#item}
    done
    ((max_width += 6))

    while true; do
        # Clear and redraw
        printf '\r'

        # Header
        if [[ -n "$header" ]]; then
            printf '\n  %b%s%b\n\n' "${THEME[accent]}" "$header" "${COLORS[reset]}"
        else
            printf '\n'
        fi

        # Items
        local i
        for ((i=0; i<num_items; i++)); do
            local item="${items[$i]}"
            local prefix=" "
            local is_current=$((i == current))
            local is_selected=${selected[$i]:-0}

            if ((multi)); then
                if ((is_selected)); then
                    prefix="${THEME[success]}${BOX[check]}${COLORS[reset]}"
                else
                    prefix="${THEME[muted]}${BOX[circle]}${COLORS[reset]}"
                fi
            fi

            if ((is_current)); then
                printf '  %b%s%b %s %b%s%b\n' \
                    "${THEME[primary]}" "$cursor" "${COLORS[reset]}" \
                    "$prefix" \
                    "${THEME[primary]}${COLORS[bold]}" "$item" "${COLORS[reset]}"
            else
                printf '    %s %b%s%b\n' \
                    "$prefix" \
                    "${THEME[text]}" "$item" "${COLORS[reset]}"
            fi
        done

        # Footer hints
        printf '\n  %b' "${THEME[muted]}"
        if ((multi)); then
            printf '↑↓ navigate • space select • enter confirm • q cancel'
        else
            printf '↑↓ navigate • enter select • q cancel'
        fi
        printf '%b\n' "${COLORS[reset]}"

        # Read input
        local key=$(read_key)

        case "$key" in
            up)
                if ((current > 0)); then
                    ((current--))
                elif ((! no_wrap)); then
                    current=$((num_items - 1))
                fi
                ;;
            down)
                if ((current < num_items - 1)); then
                    ((current++))
                elif ((! no_wrap)); then
                    current=0
                fi
                ;;
            space)
                if ((multi)); then
                    if [[ -n "${selected[$current]}" ]]; then
                        unset "selected[$current]"
                    else
                        if ((limit == 0 || ${#selected[@]} < limit)); then
                            selected[$current]=1
                        fi
                    fi
                fi
                ;;
            enter)
                cursor_show
                printf '\033[%dA\033[J' $((num_items + 3 + (header ? 1 : 0)))

                if ((multi)); then
                    for idx in "${(@k)selected}"; do
                        printf '%s\n' "${items[$idx]}"
                    done
                else
                    printf '%s\n' "${items[$current]}"
                fi
                return 0
                ;;
            quit|esc)
                cursor_show
                printf '\033[%dA\033[J' $((num_items + 3 + (header ? 1 : 0)))
                return 1
                ;;
        esac

        # Move cursor up to redraw
        printf '\033[%dA' $((num_items + 2 + (header ? 2 : 0)))
    done
}
