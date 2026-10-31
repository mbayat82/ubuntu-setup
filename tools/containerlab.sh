# containerlab (official installer), KVM check and inotify limits for multi-node labs.
# CLAB_VERSION in config.env pins a version; empty = latest.

tool_installed() { command -v containerlab >/dev/null; }

tool_install() {
  apt_install cpu-checker
  run curl -fsSL https://get.containerlab.dev -o /tmp/clab-install.sh
  run bash /tmp/clab-install.sh ${CLAB_VERSION:+-v "$CLAB_VERSION"}

  write_file /etc/sysctl.d/99-clab.conf <<'EOF'
fs.inotify.max_user_instances = 1024
fs.inotify.max_user_watches = 524288
EOF
  run sysctl --system >/dev/null

  kvm-ok || warn "KVM not available - enable VT-x in the BIOS (needed for N9Kv)"
}
