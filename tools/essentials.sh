# Everyday CLI tools (ESSENTIAL_PACKAGES in config.env): git, btop, tmux, ripgrep, fzf, jq, ...

# Always run: apt skips what is installed, and new names added to the list get picked up.
tool_installed() { return 1; }

tool_install() {
  # shellcheck disable=SC2086
  apt_install_available $ESSENTIAL_PACKAGES

  # Ubuntu renames these binaries; add the usual short names.
  if command -v fdfind >/dev/null && ! command -v fd >/dev/null; then
    run ln -s "$(command -v fdfind)" /usr/local/bin/fd
  fi
  if command -v batcat >/dev/null && ! command -v bat >/dev/null; then
    run ln -s "$(command -v batcat)" /usr/local/bin/bat
  fi
}
