# ═══════════════════════════════════════════════════════════════════════════════
#  CORE TUI LOGIC
# ═══════════════════════════════════════════════════════════════════════════════

# Source all library files
source "$(dirname "$0")/constants.zsh"
source "$(dirname "$0")/utils.zsh"
source "$(dirname "$0")/layout.zsh"
source "$(dirname "$0")/help.zsh"
source "$(dirname "$0")/keypress.zsh"

# Source all mode files
for mode_file in $(dirname "$0")/modes/*.zsh; do
    source "$mode_file"
done

# ═══════════════════════════════════════════════════════════════════════════════
#  SECTION: TUI Initialization
# ═══════════════════════════════════════════════════════════════════════════════

##
# @function init_tui
# @description Initializes the zcurses TUI environment.
##
init_tui() {
    zcurses init
    zcurses keypad 1
    zcurses noecho
    zcurses curs_set 0
}

##
# @function deinit_tui
# @description Restores the terminal from zcurses mode.
##
deinit_tui() {
    zcurses end
}

# ═══════════════════════════════════════════════════════════════════════════════
#  SECTION: Main Entry Point
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
    init_tui
    trap deinit_tui EXIT

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

            local choice=$(mode_choose "vim" "emacs" "nano" "ed (for the truly enlightened)" \
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
