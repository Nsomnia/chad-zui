# ═══════════════════════════════════════════════════════════════════════════════
#  SECTION: Pure Utility Functions
# ═══════════════════════════════════════════════════════════════════════════════

# ─────────────────────────────────────────────────────────────────────────────
#  String Manipulation Functions
# ─────────────────────────────────────────────────────────────────────────────

##
# @function str_repeat
# @description Repeats a string N times. Pure function, no side effects.
# @param $1 string - The string to repeat
# @param $2 int    - Number of repetitions
# @return string   - Repeated string via stdout
# @example $(str_repeat "─" 10) → "──────────"
##
str_repeat() {
    local str="$1" count="${2:-1}"
    local result=""
    local i
    for ((i=0; i<count; i++)); do
        result+="$str"
    done
    printf '%s' "$result"
}

##
# @function str_len_visible
# @description Returns visible length of string (excluding ANSI codes)
# @param $1 string - Input string potentially containing ANSI codes
# @return int      - Visible character count
##
str_len_visible() {
    local str="$1"
    # Strip ANSI escape sequences
    local stripped="${str//$'\\e'\[[0-9;]*m/}"
    printf '%d' "${#stripped}"
}

##
# @function str_pad
# @description Pads a string to specified width
# @param $1 string - Input string
# @param $2 int    - Target width
# @param $3 string - Pad character (default: space)
# @param $4 string - Alignment: left|right|center (default: left)
# @return string   - Padded string
##
str_pad() {
    local str="$1" width="$2" char="${3:- }" align="${4:-left}"
    local visible_len=$(str_len_visible "$str")
    local pad_needed=$((width - visible_len))

    ((pad_needed <= 0)) && { printf '%s' "$str"; return; }

    case "$align" in
        right)
            printf '%s%s' "$(str_repeat "$char" $pad_needed)" "$str"
            ;;
        center)
            local left_pad=$((pad_needed / 2))
            local right_pad=$((pad_needed - left_pad))
            printf '%s%s%s' "$(str_repeat "$char" $left_pad)" "$str" "$(str_repeat "$char" $right_pad)"
            ;;
        *)
            printf '%s%s' "$str" "$(str_repeat "$char" $pad_needed)"
            ;;
    esac
}

##
# @function str_truncate
# @description Truncates string to max length with ellipsis
# @param $1 string - Input string
# @param $2 int    - Maximum length
# @param $3 string - Ellipsis string (default: "…")
# @return string   - Truncated string
##
str_truncate() {
    local str="$1" max="$2" ellipsis="${3:-…}"
    local len=${#str}

    if ((len <= max)); then
        printf '%s' "$str"
    else
        printf '%s%s' "${str:0:$((max - ${#ellipsis}))}" "$ellipsis"
    fi
}

# ─────────────────────────────────────────────────────────────────────────────
#  Terminal Control Functions
# ─────────────────────────────────────────────────────────────────────────────

##
# @function term_size
# @description Gets terminal dimensions
# @return string - "width height" space-separated
##
term_size() {
    local cols lines
    if [[ -t 1 ]]; then
        cols="${COLUMNS:-$(tput cols 2>/dev/null || echo 80)}"
        lines="${LINES:-$(tput lines 2>/dev/null || echo 24)}"
    else
        cols=80
        lines=24
    fi
    printf '%d %d' "$cols" "$lines"
}

##
# @function cursor_save
# @description Saves cursor position
##
cursor_save() { printf '\033[s'; }

##
# @function cursor_restore
# @description Restores cursor position
##
cursor_restore() { printf '\033[u'; }

##
# @function cursor_hide
# @description Hides cursor
##
cursor_hide() { zcurses curs_set 0; }

##
# @function cursor_show
# @description Shows cursor
##
cursor_show() { zcurses curs_set 1; }

##
# @function cursor_move
# @description Moves cursor to position
# @param $1 int - Row (1-indexed)
# @param $2 int - Column (1-indexed)
##
cursor_move() { printf '\033[%d;%dH' "$1" "$2"; }

##
# @function screen_clear
# @description Clears screen
##
screen_clear() { printf '\033[2J\033[H'; }

##
# @function line_clear
# @description Clears current line
##
line_clear() { printf '\033[2K\r'; }

# ─────────────────────────────────────────────────────────────────────────────
#  Color & Styling Functions
# ─────────────────────────────────────────────────────────────────────────────

##
# @function c
# @description Applies color/style to text. The chad way to colorize.
# @param $1 string - Color name from COLORS array
# @param $@ string - Text to colorize
# @return string   - Colorized text with reset at end
##
c() {
    local color="$1"; shift
    printf '%b%s%b' "${COLORS[$color]:-}" "$*" "${COLORS[reset]}"
}

##
# @function t
# @description Applies theme color to text
# @param $1 string - Theme key
# @param $@ string - Text to style
##
t() {
    local theme_key="$1"; shift
    printf '%b%s%b' "${THEME[$theme_key]:-}" "$*" "${COLORS[reset]}"
}

##
# @function gradient_text
# @description Creates a gradient effect on text (cycles through colors)
# @param $1 string - Text to apply gradient to
# @param $@ array  - Color names to cycle through
##
gradient_text() {
    local text="$1"; shift
    local -a colors=("$@")
    local len=${#text}
    local num_colors=${#colors[@]}
    local result=""
    local i

    for ((i=0; i<len; i++)); do
        local color_idx=$((i % num_colors))
        result+="${COLORS[${colors[$color_idx]}]}${text:$i:1}"
    done
    printf '%s%b' "$result" "${COLORS[reset]}"
}
