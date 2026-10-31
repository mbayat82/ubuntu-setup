# Format DATA_DISK as ext4 and mount it at DATA_MOUNT. DESTROYS the disk.
# Not in DEFAULT_STAGES: run it on purpose with  sudo ./setup.sh storage

stage_run() {
  [[ -n $DATA_DISK ]] || { log "DATA_DISK is empty - skipping"; return 0; }
  if findmnt -rn "$DATA_MOUNT" >/dev/null; then
    log "$DATA_MOUNT is already mounted - skipping"; return 0
  fi
  [[ -b $DATA_DISK ]] || die "$DATA_DISK is not a block device"
  if lsblk -nro MOUNTPOINT "$DATA_DISK" | grep -q .; then
    die "$DATA_DISK has mounted partitions (is it the system disk?)"
  fi

  lsblk -o NAME,SIZE,MODEL,SERIAL,FSTYPE "$DATA_DISK"
  confirm "This ERASES everything on $DATA_DISK."

  if (( DRY_RUN )); then
    log "[dry-run] would wipe, partition, format and mount $DATA_DISK at $DATA_MOUNT"
    return 0
  fi

  wipefs -a "$DATA_DISK"
  parted "$DATA_DISK" --script mklabel gpt mkpart data ext4 0% 100%
  partprobe "$DATA_DISK"; udevadm settle
  local part uuid
  part=$(lsblk -nrpo NAME "$DATA_DISK" | sed -n 2p)
  mkfs.ext4 -L data "$part"
  uuid=$(blkid -s UUID -o value "$part")

  mkdir -p "$DATA_MOUNT"
  grep -q "$uuid" /etc/fstab || echo "UUID=$uuid $DATA_MOUNT ext4 defaults,nofail 0 2" >>/etc/fstab
  mount -a
  chown "$ADMIN_USER:$ADMIN_USER" "$DATA_MOUNT"
  log "mounted $part at $DATA_MOUNT"
}
