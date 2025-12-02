# ═══════════════════════════════════════════════════════════════════════════════
#  SECTION: Input Handling
# ═══════════════════════════════════════════════════════════════════════════════

##
# @function read_key
# @description Reads a single keypress including special keys
# @return string - Key identifier (up/down/left/right/enter/space/esc/char)
##
read_key() {
    local -i key_code
    zcurses getch key_code

    case "$key_code" in
        # Arrow keys
        $KEY_UP) echo "up" ;;
        $KEY_DOWN) echo "down" ;;
        $KEY_LEFT) echo "left" ;;
        $KEY_RIGHT) echo "right" ;;

        # Action keys
        10) echo "enter" ;;
        32) echo "space" ;;
        27) echo "esc" ;;

        # Editing keys
        $KEY_BACKSPACE|127) echo "backspace" ;;
        $KEY_DC) echo "delete" ;;
        $KEY_HOME) echo "home" ;;
        $KEY_END) echo "end" ;;

        # Vim-style navigation
        107|75) echo "up" ;;   # k/K
        106|74) echo "down" ;; # j/J
        104) echo "left" ;; # h
        108) echo "right" ;; # l

        # Other common keys
        9) echo "tab" ;;
        113|81) echo "quit" ;; # q/Q

        # Default for printable characters
        *)
            if (( key_code >= 32 && key_code <= 126 )); then
                printf \\$(printf '%03o' "$key_code")
            fi
            ;;
    esac
}
