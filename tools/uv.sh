# uv (Python package/project manager) for ADMIN_USER, plus a uv-managed Python.
# Installs to ~/.local/bin; log in again (or `source ~/.profile`) to get it on PATH.

tool_installed() { [[ -x "$(user_home)/.local/bin/uv" ]]; }

tool_install() {
  run curl -LsSf https://astral.sh/uv/install.sh -o /tmp/uv-install.sh
  as_user env UV_NO_MODIFY_PATH=1 sh /tmp/uv-install.sh
  as_user uv python install ${UV_PYTHON:+"$UV_PYTHON"}
  bashrc_add uv 'command -v uv >/dev/null && eval "$(uv generate-shell-completion bash)"'
}
