# Read-only summary of the end state. Never fails the run.

stage_run() {
  log "sshd (effective)"
  sshd -T 2>/dev/null | grep -E '^(permitrootlogin|passwordauthentication|allowusers|maxauthtries) ' || true

  log "ufw"
  ufw status verbose || true

  log "listening ports"
  ss -tulpn || true

  log "unattended-upgrades: $(systemctl is-active unattended-upgrades 2>/dev/null || true)"
  if command -v containerlab >/dev/null; then
    log "kvm: $(ls /dev/kvm 2>/dev/null || echo 'MISSING (enable VT-x in the BIOS)')"
  fi
  if command -v tailscale >/dev/null; then tailscale status 2>&1 | head -3 || true; fi

  if [[ -f /var/run/reboot-required ]]; then warn "reboot required"; fi
}
