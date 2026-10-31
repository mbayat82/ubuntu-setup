# zoxide (smarter cd) plus the bash hook for ADMIN_USER.
# ZOXIDE_REPLACE_CD=1 makes `cd` itself the smart jump (cd <part-of-path>); otherwise use `z`.

tool_installed() {
  command -v zoxide >/dev/null && grep -qF "# ubuntu-setup: zoxide" "$(user_home)/.bashrc" 2>/dev/null
}

tool_install() {
  local flags=""
  if (( ZOXIDE_REPLACE_CD )); then flags=" --cmd cd"; fi
  apt_install_available zoxide
  bashrc_add zoxide "command -v zoxide >/dev/null && eval \"\$(zoxide init bash$flags)\""
}
