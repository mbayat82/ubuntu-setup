# Automatic security updates. Reboots only if AUTO_REBOOT=true.

stage_run() {
  apt_install unattended-upgrades

  write_file /etc/apt/apt.conf.d/20auto-upgrades <<'EOF'
APT::Periodic::Update-Package-Lists "1";
APT::Periodic::Unattended-Upgrade "1";
EOF

  write_file /etc/apt/apt.conf.d/52ubuntu-setup-unattended <<EOF
Unattended-Upgrade::Automatic-Reboot "$AUTO_REBOOT";
Unattended-Upgrade::Remove-Unused-Kernel-Packages "true";
Unattended-Upgrade::Remove-Unused-Dependencies "true";
EOF

  run systemctl enable --now unattended-upgrades
}
