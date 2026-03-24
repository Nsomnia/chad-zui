# Developer Guide

This guide provides an overview of the `chad-tui` library structure and conventions for developers.

## File Structure

- `chad-tui`: The main executable. This is a thin wrapper that sources the core library and calls the `main` function.
- `lib/`: Contains the core library files.
  - `constants.zsh`: Global constants, including colors, box-drawing characters, and themes.
  - `utils.zsh`: General-purpose utility functions.
  - `layout.zsh`: Functions for drawing boxes and other layout elements.
  - `help.zsh`: Functions for displaying help messages.
  - `keypress.zsh`: The `read_key` function for handling keyboard input.
  - `core.zsh`: The core TUI logic, which sources all other library files and contains the `main` function.
  - `modes/`: Contains the implementation for each TUI mode.
    - `choose.zsh`: The `mode_choose` function.
    - `input.zsh`: The `mode_input` function.
    - `confirm.zsh`: The `mode_confirm` function.
    - `dialog.zsh`: The `mode_dialog` function.
    - `spin.zsh`: The `mode_spin` function.
    - `notify.zsh`: The `mode_notify` function.

## Conventions

- All library files are sourced into `lib/core.zsh`.
- Each TUI mode is implemented in its own file in the `lib/modes/` directory.
- The main executable `chad-tui` should remain a thin wrapper.
- All functions should have a header comment explaining their purpose, parameters, and return values.
