# CHAD-TUI

**The Superior Terminal User Interface Framework**

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)

"I use Arch btw" - Every DevOps Team Lead Ever

Written in pure zsh because bash is for junior devs who still use Ubuntu.

## Features

-   **Fluent Interface**: A simple and intuitive command-line interface.
-   **Pure Zsh**: No external dependencies required.
-   **Modular Design**: Easily extendable with new modes and components.
-   **Robust Input Handling**: Powered by `zcurses` for reliable keyboard input.

## Installation

1.  Clone the repository:
    ```sh
    git clone https://github.com/your-username/chad-tui.git
    ```
2.  Add the `chad-tui` script to your `PATH`:
    ```sh
    ln -s "$(pwd)/chad-tui/chad-tui" /usr/local/bin/chad-tui
    ```

## Usage

### Choose Mode

Interactive selection from a list of options.

```sh
chad-tui choose "vim" "emacs" "nano" --header "Choose your fighter:"
```

### Input Mode

Text input prompt with validation.

```sh
chad-tui input --placeholder "Enter your name" --header "Who are you?"
```

### Confirm Mode

Yes/No confirmation dialog.

```sh
chad-tui confirm "Delete node_modules?" --affirmative "Chad Yes" --negative "No way"
```

### Dialog Mode

Display a message dialog box.

```sh
chad-tui dialog "Build succeeded!" --type success --title "CI/CD"
```

### Spin Mode

Loading spinner for long-running tasks.

```sh
chad-tui spin --title "Installing dependencies..." -- npm install
```

### Notify Mode

Toast-style notification.

```sh
chad-tui notify "That's... acceptable. I guess." --type warning
```

