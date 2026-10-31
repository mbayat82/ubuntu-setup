# Remove packages and services you do not need. Everything is opt-in via config.

remove_snapd() {
  command -v snap >/dev/null || return 0
  local pass name
  # apps first, then bases; a few passes because of snap dependencies
  for pass in 1 2 3; do
    for name in $(snap list 2>/dev/null | awk 'NR>1 {print $1}' | grep -vx snapd); do
      run snap remove --purge "$name" || true
    done
  done
  disable_units snapd.socket snapd.service snapd.seeded.service
  purge_pkgs snapd
  if ! pkg_installed snapd; then run apt-mark hold snapd; fi
}

stage_run() {
  if (( REMOVE_SNAPD )); then remove_snapd; fi

  # shellcheck disable=SC2086
  disable_units $DISABLE_UNITS
  # shellcheck disable=SC2086
  purge_pkgs $PURGE_PACKAGES

  # Bare metal: stop cloud-init, keep the generated netplan file.
  if (( DISABLE_CLOUD_INIT )) && [[ -d /etc/cloud ]]; then run touch /etc/cloud/cloud-init.disabled; fi

  run apt-get autoremove --purge -y
}
