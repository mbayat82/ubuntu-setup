# direnv (per-directory environment, e.g. auto-activate a uv venv) plus the bash hook.

tool_installed() {
  command -v direnv >/dev/null && grep -qF "# ubuntu-setup: direnv" "$(user_home)/.bashrc" 2>/dev/null
}

tool_install() {
  apt_install_available direnv
  bashrc_add direnv 'command -v direnv >/dev/null && eval "$(direnv hook bash)"'
}
