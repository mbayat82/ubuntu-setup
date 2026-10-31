# lazygit (terminal UI for git), latest GitHub release into /usr/local/bin.

tool_installed() { command -v lazygit >/dev/null; }

tool_install() { install_release_binary lazygit jesseduffield/lazygit; }
