#!/usr/bin/env zsh
# ╔═══════════════════════════════════════════════════════════════════════════════╗
# ║  CHAD-TUI v1.337 - The Superior Terminal User Interface Framework             ║
# ║  "I use Arch btw" - Every DevOps Team Lead Ever                               ║
# ║                                                                               ║
# ║  Written in pure zsh because bash is for junior devs who still use Ubuntu    ║
# ╚═══════════════════════════════════════════════════════════════════════════════╝
#
# SPDX-License-Identifier: MIT
# Author: A Chad Developer Who Actually Reads Man Pages

setopt LOCAL_OPTIONS NO_GLOB_SUBST NO_POSIX_BUILTINS PIPE_FAIL
setopt EXTENDED_GLOB NULL_GLOB KSH_ARRAYS 2>/dev/null || true

# ═══════════════════════════════════════════════════════════════════════════════
#  SECTION: Global Configuration & Constants
#  These are immutable. Like a senior dev's opinions on tabs vs spaces.
# ═══════════════════════════════════════════════════════════════════════════════

typeset -r CHAD_VERSION="1.337"
typeset -r CHAD_NAME="chad-tui"

# ─────────────────────────────────────────────────────────────────────────────
#  ANSI Color Codes (TTY Compatible)
#  Because real devs don't need 16 million colors to feel validated
# ─────────────────────────────────────────────────────────────────────────────

typeset -rA COLORS=(
    [reset]="\033[0m"
    [bold]="\033[1m"
    [dim]="\033[2m"
    [italic]="\033[3m"
    [underline]="\033[4m"
    [blink]="\033[5m"
    [reverse]="\033[7m"
    
    # Foreground Colors
    [black]="\033[30m"
    [red]="\033[31m"
    [green]="\033[32m"
    [yellow]="\033[33m"
    [blue]="\033[34m"
    [magenta]="\033[35m"
    [cyan]="\033[36m"
    [white]="\033[37m"
    
    # Bright Foreground
    [bright_black]="\033[90m"
    [bright_red]="\033[91m"
    [bright_green]="\033[92m"
    [bright_yellow]="\033[93m"
    [bright_blue]="\033[94m"
    [bright_magenta]="\033[95m"
    [bright_cyan]="\033[96m"
    [bright_white]="\033[97m"
    
    # Background Colors
    [bg_black]="\033[40m"
    [bg_red]="\033[41m"
    [bg_green]="\033[42m"
    [bg_yellow]="\033[43m"
    [bg_blue]="\033[44m"
    [bg_magenta]="\033[45m"
    [bg_cyan]="\033[46m"
    [bg_white]="\033[47m"
)

# ─────────────────────────────────────────────────────────────────────────────
#  Box Drawing Characters (TTY/Unicode Compatible)
#  For drawing boxes that would make your terminal emulator proud
# ─────────────────────────────────────────────────────────────────────────────

typeset -rA BOX=(
    # Light box
    [h]="─"      [v]="│"
    [tl]="┌"     [tr]="┐"
    [bl]="└"     [br]="┘"
    [lv]="├"     [rv]="┤"
    [th]="┬"     [bh]="┴"
    [cross]="┼"
    
    # Heavy box  
    [hh]="━"     [hv]="┃"
    [htl]="┏"    [htr]="┓"
    [hbl]="┗"    [hbr]="┛"
    
    # Double box
    [dh]="═"     [dv]="║"
    [dtl]="╔"    [dtr]="╗"
    [dbl]="╚"    [dbr]="╝"
    
    # Rounded
    [rtl]="╭"    [rtr]="╮"
    [rbl]="╰"    [rbr]="╯"
    
    # Block elements
    [full]="█"   [shade_d]="▓"
    [shade_m]="▒" [shade_l]="░"
    [half_l]="▌" [half_r]="▐"
    [half_t]="▀" [half_b]="▄"
    
    # Arrows & Symbols
    [arrow_r]="→" [arrow_l]="←"
    [arrow_u]="↑" [arrow_d]="↓"
    [bullet]="●"  [circle]="○"
    [check]="✓"   [cross_mark]="✗"
    [star]="★"    [diamond]="◆"
    [tri_r]="▶"   [tri_l]="◀"
)

# ─────────────────────────────────────────────────────────────────────────────
#  UI Theme Configuration
#  Customizable because we respect user choice (unlike some distros)
# ─────────────────────────────────────────────────────────────────────────────

typeset -A THEME=(
    [primary]="${COLORS[cyan]}"
    [secondary]="${COLORS[magenta]}"
    [accent]="${COLORS[bright_yellow]}"
    [success]="${COLORS[bright_green]}"
    [error]="${COLORS[bright_red]}"
    [warning]="${COLORS[yellow]}"
    [muted]="${COLORS[bright_black]}"
    [text]="${COLORS[white]}"
    [highlight]="${COLORS[reverse]}"
)

# ═══════════════════════════════════════════════════════════════════════════════
#  SECTION: Pure Utility Functions
#  Functional programming: because state is the enemy of reproducibility
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
    local stripped="${str//\033\[[0-9;]*m/}"
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
cursor_hide() { printf '\033[?25l'; }

##
# @function cursor_show
# @description Shows cursor
##
cursor_show() { printf '\033[?25h'; }

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

# ═══════════════════════════════════════════════════════════════════════════════
#  SECTION: Box Drawing & Layout Functions
#  Because borders matter. Unlike the ones on your Jira tickets.
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

# ═══════════════════════════════════════════════════════════════════════════════
#  SECTION: Easter Eggs & Chad Wisdom
#  For those who RTFM and deserve a laugh
# ═══════════════════════════════════════════════════════════════════════════════

typeset -ra CHAD_QUOTES=(
    "\"Real devs don't use mice\" - Ancient Proverb"
    "\"I use Arch btw\" - Every Senior Dev, Unprompted"
    "\"Have you tried turning it off and on again?\" - DevOps Lead to Junior"
    "\"It works on my machine\" → \"Then we'll ship your machine\" - Chad CI/CD"
    "\"Why use a GUI when you can alias everything?\" - Shell Enthusiast"
    "\"The cloud is just someone else's computer\" - Wise DevOps Elder"
    "\"sudo rm -rf /* fixes everything\" - DO NOT ACTUALLY DO THIS"
    "\"I don't always test my code, but when I do, I do it in production\""
    "\"Git blame should be renamed to git credit\" - said no one ever"
    "\"Documentation? The code IS the documentation\" - Villain Origin Story"
)

typeset -r ARCH_ASCII='
     ⠀⠀⠀⠀⣀⣤⣴⣶⣶⣶⣦⣤⣀⠀⠀⠀⠀
     ⠀⠀⣠⣾⣿⣿⣿⣿⣿⣿⣿⣿⣿⣷⣄⠀⠀
     ⠀⣴⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣦⠀
     ⢸⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⡇
     ⢿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⡿
     ⠈⢿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⡿⠁
     ⠀⠀⠙⢿⣿⣿⣿⣿⣿⣿⣿⣿⣿⡿⠋⠀⠀
     ⠀⠀⠀⠀⠉⠛⠿⠿⠿⠿⠛⠉⠀⠀⠀⠀   btw'

##
# @function get_random_quote
# @description Returns a random chad quote
##
get_random_quote() {
    local idx=$((RANDOM % ${#CHAD_QUOTES[@]}))
    printf '%s' "${CHAD_QUOTES[$idx]}"
}

##
# @function show_arch_easter_egg
# @description Shows the Arch Linux easter egg (triggered by --btw flag)
##
show_arch_easter_egg() {
    printf '%b%s%b\n' "${THEME[primary]}" "$ARCH_ASCII" "${COLORS[reset]}"
    printf '\n  %s\n\n' "$(t accent "I use Arch btw. Also, I vape and do crossfit.")"
}

# ═══════════════════════════════════════════════════════════════════════════════
#  SECTION: Help System
#  Because unlike some projects, we actually document things
# ═══════════════════════════════════════════════════════════════════════════════

##
# @function show_main_help
# @description Displays the main help message with all modes
##
show_main_help() {
    local width=76
    
    printf '\n'
    
    # Header box
    draw_box_with_content $width "double" "CHAD-TUI v${CHAD_VERSION}" \
        "" \
        "$(t text "The")$(t primary " Superior")$(t text " Terminal User Interface Framework")" \
        "$(t muted "For developers who read man pages before Stack Overflow")" \
        ""
    
    printf '\n'
    
    # Usage section
    printf '  %s\n\n' "$(t accent "${BOX[tri_r]} USAGE")"
    printf '    %s %s %s\n\n' \
        "$(t primary "$CHAD_NAME")" \
        "$(t secondary "<mode>")" \
        "$(t muted "[options]")"
    
    # Modes section
    printf '  %s\n\n' "$(t accent "${BOX[tri_r]} MODES")"
    
    printf '    %s  %s\n' \
        "$(t primary "$(str_pad "choose" 12)")" \
        "$(t text "Interactive selection menu (single or multi-select)")"
    printf '    %s  %s\n' \
        "$(t primary "$(str_pad "input" 12)")" \
        "$(t text "Text input prompt with validation")"
    printf '    %s  %s\n' \
        "$(t primary "$(str_pad "confirm" 12)")" \
        "$(t text "Yes/No confirmation dialog")"
    printf '    %s  %s\n' \
        "$(t primary "$(str_pad "dialog" 12)")" \
        "$(t text "Display a message dialog box")"
    printf '    %s  %s\n' \
        "$(t primary "$(str_pad "spin" 12)")" \
        "$(t text "Loading spinner animation")"
    printf '    %s  %s\n' \
        "$(t primary "$(str_pad "notify" 12)")" \
        "$(t text "Toast-style notification")"
    
    printf '\n'
    
    # Global options
    printf '  %s\n\n' "$(t accent "${BOX[tri_r]} GLOBAL OPTIONS")"
    printf '    %s, %s      %s\n' "$(t secondary "-h")" "$(t secondary "--help")" "$(t text "Show help (mode-specific if mode given)")"
    printf '    %s, %s   %s\n' "$(t secondary "-v")" "$(t secondary "--version")" "$(t text "Show version")"
    printf '    %s            %s\n' "$(t secondary "--btw")" "$(t muted "I use Arch btw")"
    
    printf '\n'
    
    # Examples
    printf '  %s\n\n' "$(t accent "${BOX[tri_r]} EXAMPLES")"
    printf '    %s\n' "$(t muted "# Choose from a list:")"
    printf '    %s\n\n' "$(t text "$CHAD_NAME choose \"vim\" \"emacs\" \"nano\" --header \"Choose your fighter:\"")"
    printf '    %s\n' "$(t muted "# Get user input:")"
    printf '    %s\n\n' "$(t text "$CHAD_NAME input --placeholder \"Enter your name\" --header \"Who are you?\"")"
    printf '    %s\n' "$(t muted "# Confirm action:")"
    printf '    %s\n\n' "$(t text "$CHAD_NAME confirm \"Delete node_modules?\" --affirmative \"Chad Yes\" --negative \"No way\"")"
    
    # Footer with random quote
    printf '  %s\n' "$(t muted "$(str_repeat "${BOX[h]}" 72)")"
    printf '  %s\n\n' "$(t muted "$(get_random_quote)")"
}

##
# @function show_choose_help
# @description Help for choose mode
##
show_choose_help() {
    printf '\n'
    draw_box_with_content 70 "rounded" "CHOOSE MODE" \
        "" \
        "$(t text "Interactive selection from a list of options")" \
        "$(t muted "Like a dating app, but for command line arguments")" \
        ""
    
    printf '\n  %s\n\n' "$(t accent "${BOX[tri_r]} USAGE")"
    printf '    %s choose %s %s\n\n' \
        "$(t primary "$CHAD_NAME")" \
        "$(t secondary "[items...]")" \
        "$(t muted "[options]")"
    
    printf '  %s\n\n' "$(t accent "${BOX[tri_r]} OPTIONS")"
    printf '    %s                %s\n' "$(t secondary "--multi")" "$(t text "Enable multi-select mode")"
    printf '    %s       %s\n' "$(t secondary "--header <text>")" "$(t text "Header text above the list")"
    printf '    %s       %s\n' "$(t secondary "--cursor <char>")" "$(t text "Cursor character (default: ${BOX[tri_r]})")"
    printf '    %s    %s\n' "$(t secondary "--selected <idx>")" "$(t text "Pre-select item by index")"
    printf '    %s                %s\n' "$(t secondary "--limit")" "$(t text "Max selections in multi mode")"
    printf '    %s              %s\n' "$(t secondary "--no-wrap")" "$(t text "Disable list wrapping")"
    
    printf '\n  %s\n\n' "$(t accent "${BOX[tri_r]} KEYBINDINGS")"
    printf '    %s / %s          %s\n' "$(t secondary "↑ k")" "$(t secondary "↓ j")" "$(t text "Navigate up/down")"
    printf '    %s                  %s\n' "$(t secondary "Space")" "$(t text "Toggle selection (multi mode)")"
    printf '    %s                  %s\n' "$(t secondary "Enter")" "$(t text "Confirm selection")"
    printf '    %s / %s              %s\n' "$(t secondary "q")" "$(t secondary "Esc")" "$(t text "Cancel and exit")"
    
    printf '\n  %s\n\n' "$(t accent "${BOX[tri_r]} EXAMPLE")"
    printf '    %s\n\n' "$(t text "$CHAD_NAME choose vim emacs \"VS Code\" nano --header \"Choose your editor:\"")"
    
    printf '  %s\n\n' "$(t muted "${BOX[tri_r]} Pro tip: Vim users don't need this menu. They can't exit anyway.")"
}

##
# @function show_input_help
# @description Help for input mode
##
show_input_help() {
    printf '\n'
    draw_box_with_content 70 "rounded" "INPUT MODE" \
        "" \
        "$(t text "Stylish text input with validation support")" \
        "$(t muted "Because read -p is for junior devs")" \
        ""
    
    printf '\n  %s\n\n' "$(t accent "${BOX[tri_r]} USAGE")"
    printf '    %s input %s\n\n' \
        "$(t primary "$CHAD_NAME")" \
        "$(t muted "[options]")"
    
    printf '  %s\n\n' "$(t accent "${BOX[tri_r]} OPTIONS")"
    printf '    %s       %s\n' "$(t secondary "--header <text>")" "$(t text "Prompt header text")"
    printf '    %s  %s\n' "$(t secondary "--placeholder <text>")" "$(t text "Placeholder text")"
    printf '    %s        %s\n' "$(t secondary "--value <text>")" "$(t text "Initial value")"
    printf '    %s        %s\n' "$(t secondary "--width <num>")" "$(t text "Input field width")"
    printf '    %s     %s\n' "$(t secondary "--char-limit <n>")" "$(t text "Maximum character limit")"
    printf '    %s             %s\n' "$(t secondary "--password")" "$(t text "Hide input (show dots)")"
    printf '    %s             %s\n' "$(t secondary "--required")" "$(t text "Disallow empty input")"
    printf '    %s        %s\n' "$(t secondary "--regex <pat>")" "$(t text "Validation regex pattern")"
    
    printf '\n  %s\n\n' "$(t accent "${BOX[tri_r]} EXAMPLE")"
    printf '    %s\n\n' "$(t text "$CHAD_NAME input --header \"Enter API key:\" --password --required")"
}

##
# @function show_confirm_help
# @description Help for confirm mode
##
show_confirm_help() {
    printf '\n'
    draw_box_with_content 70 "rounded" "CONFIRM MODE" \
        "" \
        "$(t text "Yes/No confirmation dialog")" \
        "$(t muted "For when you need permission to rm -rf")" \
        ""
    
    printf '\n  %s\n\n' "$(t accent "${BOX[tri_r]} USAGE")"
    printf '    %s confirm %s %s\n\n' \
        "$(t primary "$CHAD_NAME")" \
        "$(t secondary "\"<prompt>\"")" \
        "$(t muted "[options]")"
    
    printf '  %s\n\n' "$(t accent "${BOX[tri_r]} OPTIONS")"
    printf '    %s %s\n' "$(t secondary "--affirmative <text>")" "$(t text "Text for 'yes' (default: Yes)")"
    printf '    %s     %s\n' "$(t secondary "--negative <text>")" "$(t text "Text for 'no' (default: No)")"
    printf '    %s            %s\n' "$(t secondary "--default <y|n>")" "$(t text "Default selection")"
    
    printf '\n  %s\n\n' "$(t accent "${BOX[tri_r]} EXIT CODES")"
    printf '    %s    %s\n' "$(t success "0")" "$(t text "User confirmed (yes)")"
    printf '    %s    %s\n' "$(t error "1")" "$(t text "User declined (no)")"
    
    printf '\n  %s\n\n' "$(t accent "${BOX[tri_r]} EXAMPLE")"
    printf '    %s\n\n' "$(t text "$CHAD_NAME confirm \"Deploy to production?\" --default n")"
}

##
# @function show_dialog_help
# @description Help for dialog mode
##
show_dialog_help() {
    printf '\n'
    draw_box_with_content 70 "rounded" "DIALOG MODE" \
        "" \
        "$(t text "Display message dialogs and info boxes")" \
        "$(t muted "alert() but make it ✨ terminal aesthetic ✨")" \
        ""
    
    printf '\n  %s\n\n' "$(t accent "${BOX[tri_r]} USAGE")"
    printf '    %s dialog %s %s\n\n' \
        "$(t primary "$CHAD_NAME")" \
        "$(t secondary "\"<message>\"")" \
        "$(t muted "[options]")"
    
    printf '  %s\n\n' "$(t accent "${BOX[tri_r]} OPTIONS")"
    printf '    %s        %s\n' "$(t secondary "--title <text>")" "$(t text "Dialog title")"
    printf '    %s         %s\n' "$(t secondary "--type <type>")" "$(t text "info|success|error|warning")"
    printf '    %s        %s\n' "$(t secondary "--width <num>")" "$(t text "Dialog width")"
    printf '    %s        %s\n' "$(t secondary "--style <type>")" "$(t text "rounded|double|heavy|light")"
    
    printf '\n  %s\n\n' "$(t accent "${BOX[tri_r]} EXAMPLE")"
    printf '    %s\n\n' "$(t text "$CHAD_NAME dialog \"Build succeeded!\" --type success --title \"CI/CD\"")"
}

##
# @function show_spin_help
# @description Help for spin mode
##
show_spin_help() {
    printf '\n'
    draw_box_with_content 70 "rounded" "SPIN MODE" \
        "" \
        "$(t text "Loading spinner for long-running tasks")" \
        "$(t muted "npm install would like to know your location")" \
        ""
    
    printf '\n  %s\n\n' "$(t accent "${BOX[tri_r]} USAGE")"
    printf '    %s spin %s %s\n\n' \
        "$(t primary "$CHAD_NAME")" \
        "$(t secondary "--title \"<text>\"")" \
        "$(t muted "-- <command>")"
    
    printf '  %s\n\n' "$(t accent "${BOX[tri_r]} OPTIONS")"
    printf '    %s       %s\n' "$(t secondary "--title <text>")" "$(t text "Spinner message")"
    printf '    %s      %s\n' "$(t secondary "--spinner <name>")" "$(t text "dots|line|circle|arrow|pulse")"
    printf '    %s %s\n' "$(t secondary "--success <text>")" "$(t text "Message on success")"
    printf '    %s    %s\n' "$(t secondary "--fail <text>")" "$(t text "Message on failure")"
    
    printf '\n  %s\n\n' "$(t accent "${BOX[tri_r]} EXAMPLE")"
    printf '    %s\n\n' "$(t text "$CHAD_NAME spin --title \"Installing dependencies...\" -- npm install")"
}

##
# @function show_error
# @description Displays a formatted error message
# @param $1 string - Error message
# @param $2 string - Additional details (optional)
##
show_error() {
    local message="$1" details="${2:-}"
    
    printf '\n'
    printf '  %b%s %s%b\n' "${THEME[error]}${COLORS[bold]}" "${BOX[cross_mark]}" "ERROR" "${COLORS[reset]}"
    printf '  %s\n' "$(t text "$message")"
    [[ -n "$details" ]] && printf '  %s\n' "$(t muted "$details")"
    printf '\n'
    printf '  %s\n\n' "$(t muted "Run '$CHAD_NAME --help' for usage information")"
}

# ═══════════════════════════════════════════════════════════════════════════════
#  SECTION: Input Handling
#  Reading keys without read -n 1 weirdness
# ═══════════════════════════════════════════════════════════════════════════════

##
# @function read_key
# @description Reads a single keypress including special keys
# @return string - Key identifier (up/down/left/right/enter/space/esc/char)
##
read_key() {
    local key
    local -i code
    
    [[ -t 0 ]] && stty -echo
    IFS= read -rsk1 key
    code=$?
    
    if [[ "$key" == $'\x1b' ]]; then
        read -rsk2 -t 0.01 key
        case "$key" in
            '[A'|'OA') echo "up" ;;
            '[B'|'OB') echo "down" ;;
            '[C'|'OC') echo "right" ;;
            '[D'|'OD') echo "left" ;;
            '[H')      echo "home" ;;
            '[F')      echo "end" ;;
            '[3~')     echo "delete" ;;
            *)         echo "esc" ;;
        esac
    else
        case "$key" in
            '')        echo "enter" ;;
            ' ')       echo "space" ;;
            $'\x7f'|$'\x08') echo "backspace" ;;
            $'\t')     echo "tab" ;;
            'k'|'K')   echo "up" ;;
            'j'|'J')   echo "down" ;;
            'q'|'Q')   echo "quit" ;;
            *)         echo "$key" ;;
        esac
    fi
    [[ -t 0 ]] && stty echo
}

# ═══════════════════════════════════════════════════════════════════════════════
#  SECTION: Mode Implementations
#  The actual TUI components. This is where the magic happens.
# ═══════════════════════════════════════════════════════════════════════════════

# ─────────────────────────────────────────────────────────────────────────────
#  CHOOSE MODE
# ─────────────────────────────────────────────────────────────────────────────

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
    
    # Cleanup on exit
    trap 'cursor_show; return 1' INT TERM
    
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

# ─────────────────────────────────────────────────────────────────────────────
#  INPUT MODE
# ─────────────────────────────────────────────────────────────────────────────

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
    trap 'cursor_show; return 1' INT TERM
    
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

# ─────────────────────────────────────────────────────────────────────────────
#  CONFIRM MODE
# ─────────────────────────────────────────────────────────────────────────────

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
    trap 'cursor_show; return 1' INT TERM
    
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

# ─────────────────────────────────────────────────────────────────────────────
#  DIALOG MODE
# ─────────────────────────────────────────────────────────────────────────────

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

# ─────────────────────────────────────────────────────────────────────────────
#  SPIN MODE
# ─────────────────────────────────────────────────────────────────────────────

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

# ─────────────────────────────────────────────────────────────────────────────
#  NOTIFY MODE
# ─────────────────────────────────────────────────────────────────────────────

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

# ═══════════════════════════════════════════════════════════════════════════════
#  SECTION: Main Entry Point
#  "It's not about the destination, it's about the exit code" - Senior Dev
# ═══════════════════════════════════════════════════════════════════════════════

##
# @function show_version
# @description Displays version info with flair
##
show_version() {
    printf '\n'
    printf '  %s\n' "$(gradient_text "CHAD-TUI" cyan magenta bright_cyan bright_magenta)"
    printf '  %bv%s%b\n' "${THEME[muted]}" "$CHAD_VERSION" "${COLORS[reset]}"
    printf '  %s\n\n' "$(t muted "Built different. Like your code should be.")"
}

##
# @function main
# @description Main dispatcher - routes to appropriate mode
##
main() {
    trap 'stty echo; exit 1' INT TERM
    # No arguments - show help
    if [[ $# -eq 0 ]]; then
        show_main_help
        return 0
    fi
    
    local mode="$1"
    shift
    
    case "$mode" in
        -h|--help)
            show_main_help
            return 0
            ;;
        -v|--version)
            show_version
            return 0
            ;;
        --btw)
            show_arch_easter_egg
            return 0
            ;;
        choose)
            mode_choose "$@"
            ;;
        input)
            mode_input "$@"
            ;;
        confirm)
            mode_confirm "$@"
            ;;
        dialog)
            mode_dialog "$@"
            ;;
        spin)
            mode_spin "$@"
            ;;
        notify)
            mode_notify "$@"
            ;;
        demo)
            # Easter egg: full demo mode
            printf '\n'
            mode_dialog "Welcome to CHAD-TUI demo mode! This showcases all available components. Built by someone who definitely uses Arch btw." \
                --title "CHAD-TUI Demo" --type info --width 60
            
            sleep 1
            
            mode_spin --title "Compiling Gentoo from source..." --spinner dots -- sleep 2
            
            local choice
            choice=$(mode_choose "vim" "emacs" "nano" "ed (for the truly enlightened)" \
                --header "Choose your editor (wrong answers only):")
            
            mode_dialog "You chose: $choice. Interesting choice. The DevOps team lead is judging you." \
                --type warning --title "Judgment"
            
            if mode_confirm "Do you use Arch btw?"; then
                show_arch_easter_egg
            else
                mode_notify "That's... acceptable. I guess." --type warning
            fi
            ;;
        *)
            show_error "Unknown mode: $mode" "Valid modes: choose, input, confirm, dialog, spin, notify"
            printf '  %s\n\n' "$(t muted "Tip: A senior dev would have read the --help first")"
            return 1
            ;;
    esac
}

# ═══════════════════════════════════════════════════════════════════════════════
#  Run main if script is executed (not sourced)
# ═══════════════════════════════════════════════════════════════════════════════

if [[ "${ZSH_EVAL_CONTEXT:-}" == "toplevel" ]] || [[ "${BASH_SOURCE[0]:-$0}" == "$0" ]]; then
    main "$@"
fi
