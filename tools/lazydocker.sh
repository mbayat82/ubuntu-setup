# lazydocker (terminal UI for Docker), latest GitHub release into /usr/local/bin.
# Only useful with docker installed, so keep it after docker in TOOLS.

tool_installed() { command -v lazydocker >/dev/null; }

tool_install() { install_release_binary lazydocker jesseduffield/lazydocker; }
