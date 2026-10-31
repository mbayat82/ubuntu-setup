# Key-only SSH, no root login. Refuses to run if no key is installed (lockout guard).

stage_run() {
  local keys conf=/etc/ssh/sshd_config.d/00-hardening.conf
  keys="$(user_home)/.ssh/authorized_keys"
  [[ -s $keys ]] || die "no key in $keys - add your public key first (password login would be switched off)"

  write_file "$conf" <<EOF
PermitRootLogin no
PasswordAuthentication no
KbdInteractiveAuthentication no
PubkeyAuthentication yes
AuthenticationMethods publickey
AllowUsers $ADMIN_USER
MaxAuthTries 3
LoginGraceTime 30
X11Forwarding no
EOF

  if (( ! DRY_RUN )); then
    sshd -t || { rm -f "$conf"; die "sshd config invalid - hardening file removed"; }
  fi
  run systemctl reload ssh
  run passwd -l root
  log "keep this session open and test a second key login before closing it"
}
