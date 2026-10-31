# GitHub CLI (gh) from GitHub's official apt repo. Log in afterwards with: gh auth login

tool_installed() { command -v gh >/dev/null; }

tool_install() {
  local keyring=/etc/apt/keyrings/githubcli-archive-keyring.gpg
  apt_install ca-certificates curl
  run install -m 0755 -d /etc/apt/keyrings
  run curl -fsSL https://cli.github.com/packages/githubcli-archive-keyring.gpg -o "$keyring"
  run chmod go+r "$keyring"

  write_file /etc/apt/sources.list.d/github-cli.list <<EOF
deb [arch=$(dpkg --print-architecture) signed-by=$keyring] https://cli.github.com/packages stable main
EOF

  run apt-get update
  apt_install gh
  log "next: gh auth login"
}
