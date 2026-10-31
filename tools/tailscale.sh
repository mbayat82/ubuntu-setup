# Tailscale client (official installer). Login stays manual.

tool_installed() { command -v tailscale >/dev/null; }

tool_install() {
  run curl -fsSL https://tailscale.com/install.sh -o /tmp/tailscale-install.sh
  run sh /tmp/tailscale-install.sh
  log "next: sudo tailscale up, then disable key expiry for this machine in the admin console"
}
