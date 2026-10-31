# Template for a new tool. Copy to tools/<name>.sh, then add <name> to TOOLS in config.env.
# Two functions are required. Helpers from lib.sh: run, log, warn, die, apt_install,
# pkg_installed, write_file. Settings from config.env are available as variables.

# Return 0 if the tool is already there (the install is then skipped).
tool_installed() {
  command -v mytool >/dev/null
}

# Do the install. Wrap commands in `run` so --dry-run only prints them.
tool_install() {
  apt_install mytool
}
