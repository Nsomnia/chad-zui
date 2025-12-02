# ═══════════════════════════════════════════════════════════════════════════════
#  SECTION: Help System
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
