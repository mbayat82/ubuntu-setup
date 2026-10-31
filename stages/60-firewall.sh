# UFW: deny incoming, allow SSH (everywhere, or only SSH_ALLOW_CIDRS), optional trusted subnets.
# SSH rules are added before enabling. If SSH_ALLOW_CIDRS is set, the script first checks
# that your current SSH session is covered by it, so enabling UFW cannot cut you off.

check_ssh_sessions_allowed() {
  local allowed="$SSH_ALLOW_CIDRS 127.0.0.0/8 ::1/128" peer
  if (( UFW_TAILSCALE )); then allowed+=" 100.64.0.0/10"; fi
  while read -r peer; do
    [[ -n $peer ]] || continue
    # shellcheck disable=SC2086
    python3 -c 'import ipaddress, sys
ip = ipaddress.ip_address(sys.argv[1])
sys.exit(0 if any(ip in ipaddress.ip_network(c) for c in sys.argv[2:]) else 1)' "$peer" $allowed \
      || die "your SSH session from $peer is not covered by SSH_ALLOW_CIDRS - enabling UFW would lock you out"
  done < <(ss -Htn state established '( sport = :22 )' | awk '{print $4}' | sed 's/:[0-9]*$//' | tr -d '[]')
}

stage_run() {
  local c
  apt_install ufw
  run ufw default deny incoming
  run ufw default allow outgoing

  if [[ -z $SSH_ALLOW_CIDRS ]]; then
    run ufw allow 22/tcp comment 'SSH'
  else
    check_ssh_sessions_allowed
    for c in $SSH_ALLOW_CIDRS; do
      run ufw allow from "$c" to any port 22 proto tcp comment 'SSH'
    done
  fi
  if (( UFW_TAILSCALE )); then
    run ufw allow in on tailscale0 to any port 22 proto tcp comment 'SSH via Tailscale'
  fi
  for c in $UFW_TRUSTED_CIDRS; do
    run ufw allow from "$c" comment 'trusted subnet'
  done

  run ufw --force enable
  run ufw status verbose
}
