# Hostname, timezone, LVM grow, system upgrade, base packages.

stage_run() {
  if [[ -n $NEW_HOSTNAME ]]; then run hostnamectl set-hostname "$NEW_HOSTNAME"; fi
  if [[ -n $TIMEZONE ]]; then run timedatectl set-timezone "$TIMEZONE"; fi

  # Grow the root LV if the installer left free space in the volume group.
  local root_src
  root_src=$(findmnt -no SOURCE /)
  if [[ $root_src == /dev/mapper/* ]]; then
    run lvextend -r -l +100%FREE "$root_src" || log "LVM: nothing to extend"
  fi

  run apt-get update
  run env DEBIAN_FRONTEND=noninteractive apt-get full-upgrade -y
  # shellcheck disable=SC2086
  apt_install $BASE_PACKAGES
}
