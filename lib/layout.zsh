# ═══════════════════════════════════════════════════════════════════════════════
#  SECTION: Box Drawing & Layout Functions
# ═══════════════════════════════════════════════════════════════════════════════

##
# @function draw_box
# @description Draws a box at specified position with content
# @param $1 int    - Width
# @param $2 int    - Height
# @param $3 string - Style: light|heavy|double|rounded (default: rounded)
# @param $4 string - Border color (default: primary theme)
##
draw_box() {
    local width="$1" height="$2" style="${3:-rounded}" border_color="${4:-${THEME[primary]}}"
    local tl tr bl br h v

    case "$style" in
        heavy)   tl="${BOX[htl]}" tr="${BOX[htr]}" bl="${BOX[hbl]}" br="${BOX[hbr]}" h="${BOX[hh]}" v="${BOX[hv]}" ;;
        double)  tl="${BOX[dtl]}" tr="${BOX[dtr]}" bl="${BOX[dbl]}" br="${BOX[dbr]}" h="${BOX[dh]}" v="${BOX[dv]}" ;;
        rounded) tl="${BOX[rtl]}" tr="${BOX[rtr]}" bl="${BOX[rbl]}" br="${BOX[rbr]}" h="${BOX[h]}"  v="${BOX[v]}"  ;;
        *)       tl="${BOX[tl]}"  tr="${BOX[tr]}"  bl="${BOX[bl]}"  br="${BOX[br]}"  h="${BOX[h]}"  v="${BOX[v]}"  ;;
    esac

    local inner_width=$((width - 2))
    local horizontal=$(str_repeat "$h" "$inner_width")

    # Top border
    printf '%b%s%s%s%b\n' "$border_color" "$tl" "$horizontal" "$tr" "${COLORS[reset]}"

    # Middle rows
    local i
    for ((i=0; i<height-2; i++)); do
        printf '%b%s%b%s%b%s%b\n' "$border_color" "$v" "${COLORS[reset]}" \
            "$(str_repeat ' ' $inner_width)" "$border_color" "$v" "${COLORS[reset]}"
    done

    # Bottom border
    printf '%b%s%s%s%b' "$border_color" "$bl" "$horizontal" "$br" "${COLORS[reset]}"
}

##
# @function draw_box_with_content
# @description Draws a box containing centered content
# @param $1 int      - Width
# @param $2 string   - Style
# @param $3 string   - Title (optional)
# @param $@ strings  - Content lines
##
draw_box_with_content() {
    local width="$1" style="$2" title="$3"; shift 3
    local -a content=("$@")
    local inner_width=$((width - 4))
    local height=$((${#content[@]} + 2))
    local tl tr bl br h v lv rv

    case "$style" in
        heavy)   tl="${BOX[htl]}" tr="${BOX[htr]}" bl="${BOX[hbl]}" br="${BOX[hbr]}" h="${BOX[hh]}" v="${BOX[hv]}" ;;
        double)  tl="${BOX[dtl]}" tr="${BOX[dtr]}" bl="${BOX[dbl]}" br="${BOX[dbr]}" h="${BOX[dh]}" v="${BOX[dv]}" ;;
        rounded) tl="${BOX[rtl]}" tr="${BOX[rtr]}" bl="${BOX[rbl]}" br="${BOX[rbr]}" h="${BOX[h]}"  v="${BOX[v]}"  ;;
        *)       tl="${BOX[tl]}"  tr="${BOX[tr]}"  bl="${BOX[bl]}"  br="${BOX[br]}"  h="${BOX[h]}"  v="${BOX[v]}"  ;;
    esac

    # Top border with optional title
    printf '%b%s' "${THEME[primary]}" "$tl"
    if [[ -n "$title" ]]; then
        local title_display=" ${title} "
        local title_len=${#title_display}
        local left_pad=$(( (width - 2 - title_len) / 2 ))
        local right_pad=$(( width - 2 - title_len - left_pad ))
        printf '%s%b%s%b%s' \
            "$(str_repeat "$h" $left_pad)" \
            "${THEME[accent]}" "$title_display" "${THEME[primary]}" \
            "$(str_repeat "$h" $right_pad)"
    else
        printf '%s' "$(str_repeat "$h" $((width - 2)))"
    fi
    printf '%s%b\n' "$tr" "${COLORS[reset]}"

    # Content rows
    for line in "${content[@]}"; do
        local visible_len=$(str_len_visible "$line")
        local padding=$((inner_width - visible_len))
        printf '%b%s%b %s%s %b%s%b\n' \
            "${THEME[primary]}" "$v" "${COLORS[reset]}" \
            "$line" "$(str_repeat ' ' $padding)" \
            "${THEME[primary]}" "$v" "${COLORS[reset]}"
    done

    # Bottom border
    printf '%b%s%s%s%b\n' "${THEME[primary]}" "$bl" "$(str_repeat "$h" $((width - 2)))" "$br" "${COLORS[reset]}"
}
