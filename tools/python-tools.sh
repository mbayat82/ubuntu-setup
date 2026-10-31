# Build prerequisites for Python wheels, plus the UV_TOOLS list (ruff, ipython, pre-commit, ...).
# Needs uv first, so keep it after uv in TOOLS.

# Always run: `uv tool install` does nothing for tools that are already installed.
tool_installed() { return 1; }

tool_install() {
  # shellcheck disable=SC2086
  apt_install_available $PYTHON_APT_PACKAGES

  [[ -x "$(user_home)/.local/bin/uv" ]] || (( DRY_RUN )) || die "python-tools needs uv (put uv before it in TOOLS)"
  local t
  for t in $UV_TOOLS; do
    as_user uv tool install "$t"
  done
}
