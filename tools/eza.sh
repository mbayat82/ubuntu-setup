# eza (modern ls). With EZA_ALIASES=1, ls/ll/la/lt are aliased to it in ADMIN_USER's ~/.bashrc.
# Aliases only affect interactive shells; scripts and cron still use the real ls.

tool_installed() {
  command -v eza >/dev/null && grep -qF "# ubuntu-setup: eza" "$(user_home)/.bashrc" 2>/dev/null
}

tool_install() {
  apt_install_available eza
  if (( EZA_ALIASES )); then
    bashrc_add eza "if command -v eza >/dev/null; then
  alias ls='eza'
  alias ll='eza -l --git'
  alias la='eza -la --git'
  alias lt='eza --tree --level=2'
fi"
  fi
}
