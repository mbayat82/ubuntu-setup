# Installs every tool named in TOOLS (config). One file per tool in tools/.
# To add a tool: copy tools/_template.sh to tools/<name>.sh and add <name> to TOOLS.

stage_run() {
  local t f
  for t in $TOOLS; do
    f="$ROOT/tools/$t.sh"
    [[ -f $f ]] || die "no such tool: $t (expected $f)"
    (
      source "$f"
      if tool_installed; then
        log "$t: already installed"
      else
        log "$t: installing"
        tool_install
      fi
    )
  done
}
