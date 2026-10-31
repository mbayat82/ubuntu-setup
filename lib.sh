#!/usr/bin/env bash
# Shared helpers, sourced by setup.sh. Not run directly.

log()  { printf '\033[1;34m[setup]\033[0m %s\n' "$*"; }
warn() { printf '\033[1;33m[setup]\033[0m %s\n' "$*" >&2; }
die()  { printf '\033[1;31m[setup]\033[0m %s\n' "$*" >&2; exit 1; }

require_root() { [[ $EUID -eq 0 ]] || die "run with sudo"; }

# run CMD...  -> executes, or only prints with --dry-run
run() {
  if (( DRY_RUN )); then printf '  [dry-run] %s\n' "$*"; else "$@"; fi
}

# write_file PATH [MODE] < content   -> only rewrites when the content changed
write_file() {
  local path=$1 mode=${2:-644} tmp
  tmp=$(mktemp); cat >"$tmp"
  if [[ -f $path ]] && cmp -s "$tmp" "$path"; then
    log "unchanged: $path"
  elif (( DRY_RUN )); then
    log "[dry-run] would write $path"
  else
    install -m "$mode" "$tmp" "$path"; log "wrote: $path"
  fi
  rm -f "$tmp"
}

confirm() {
  if (( ASSUME_YES )); then return 0; fi
  local answer
  read -r -p "$1 Type 'yes' to continue: " answer
  [[ $answer == yes ]] || die "aborted"
}

# --- packages

pkg_installed() { dpkg-query -W -f='${Status}' "$1" 2>/dev/null | grep -q "install ok installed"; }

apt_install() { run env DEBIAN_FRONTEND=noninteractive apt-get install -y "$@"; }

# apt_install_available a b c  -> installs the ones apt knows, warns about the rest
apt_install_available() {
  local p list=()
  for p in "$@"; do
    if apt-cache show "$p" >/dev/null 2>&1; then list+=("$p"); else warn "not in apt, skipped: $p"; fi
  done
  if (( ${#list[@]} )); then apt_install "${list[@]}"; fi
}

# purge_pkgs a b c  -> purges only the ones that are installed
purge_pkgs() {
  local p list=()
  for p in "$@"; do
    if pkg_installed "$p"; then list+=("$p"); fi
  done
  if (( ${#list[@]} )); then run apt-get purge -y "${list[@]}"; fi
}

# --- services

unit_exists() { systemctl list-unit-files "$1" 2>/dev/null | grep -q "^$1"; }

# disable_units a.service b.socket  -> disables and stops the ones that exist
disable_units() {
  local u
  for u in "$@"; do
    if unit_exists "$u"; then run systemctl disable --now "$u"; fi
  done
}

# --- GitHub release binaries

# sys_arch -> x86_64 or arm64 (the spelling most release assets use)
sys_arch() {
  case $(uname -m) in
    x86_64)  echo x86_64 ;;
    aarch64) echo arm64 ;;
    *)       die "unsupported CPU: $(uname -m)" ;;
  esac
}

# github_latest_version OWNER/REPO -> latest release version without the leading v
github_latest_version() {
  curl -fsSL "https://api.github.com/repos/$1/releases/latest" | sed -n 's/.*"tag_name": *"v\{0,1\}\([^"]*\)".*/\1/p' | head -1
}

# install_release_binary NAME OWNER/REPO
# For releases that ship NAME_<version>_Linux_<arch>.tar.gz with a NAME binary inside.
install_release_binary() {
  local name=$1 repo=$2 ver arch tmp
  ver=$(github_latest_version "$repo")
  [[ -n $ver ]] || die "could not find the latest $name release (GitHub API rate limit?)"
  arch=$(sys_arch)
  tmp=$(mktemp -d)
  run curl -fsSL "https://github.com/$repo/releases/download/v$ver/${name}_${ver}_Linux_${arch}.tar.gz" -o "$tmp/$name.tar.gz"
  run tar -xzf "$tmp/$name.tar.gz" -C "$tmp" "$name"
  run install -m 0755 "$tmp/$name" "/usr/local/bin/$name"
  rm -rf "$tmp"
  log "$name $ver installed"
}

# --- ADMIN_USER helpers

user_home() { getent passwd "$ADMIN_USER" | cut -d: -f6; }

# as_user CMD...  -> runs as ADMIN_USER with ~/.local/bin on PATH
as_user() {
  run sudo -u "$ADMIN_USER" -H env "PATH=$(user_home)/.local/bin:$PATH" "$@"
}

# bashrc_add NAME 'line'  -> appends a marked line to ADMIN_USER's ~/.bashrc once
bashrc_add() {
  local name=$1 line=$2 rc
  rc="$(user_home)/.bashrc"
  if grep -qF "# ubuntu-setup: $name" "$rc" 2>/dev/null; then return 0; fi
  if (( DRY_RUN )); then log "[dry-run] would add '$name' to $rc"; return 0; fi
  printf '\n# ubuntu-setup: %s\n%s\n' "$name" "$line" >>"$rc"
  chown "$ADMIN_USER:$ADMIN_USER" "$rc"
}
