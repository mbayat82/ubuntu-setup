#!/usr/bin/env bash
# Ubuntu setup runner.
# Usage: sudo ./setup.sh [--dry-run] [--yes] [--tools "docker lynis"] [stage ...]
# No stage given = DEFAULT_STAGES from config.env. Stages: see stages/.
set -euo pipefail

ROOT=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
DRY_RUN=0
ASSUME_YES=0
TOOLS_OVERRIDE=""
stages=()

while (( $# )); do
  case $1 in
    --dry-run) DRY_RUN=1 ;;
    --yes)     ASSUME_YES=1 ;;
    --tools)   TOOLS_OVERRIDE=${2:?--tools needs a list}; shift ;;
    -h|--help) sed -n '2,4p' "${BASH_SOURCE[0]}"; exit 0 ;;
    -*)        echo "unknown option: $1" >&2; exit 1 ;;
    *)         stages+=("$1") ;;
  esac
  shift
done

# shellcheck source=config.env
source "$ROOT/config.env"
# Personal overrides (git-ignored) win over the generic defaults.
if [[ -f $ROOT/config.local.env ]]; then source "$ROOT/config.local.env"; fi
# shellcheck source=lib.sh
source "$ROOT/lib.sh"

if [[ -n $TOOLS_OVERRIDE ]]; then TOOLS=$TOOLS_OVERRIDE; fi
if [[ -z ${ADMIN_USER:-} ]]; then ADMIN_USER=${SUDO_USER:-}; fi
if (( ${#stages[@]} == 0 )); then read -r -a stages <<<"$DEFAULT_STAGES"; fi

require_root
[[ -n $ADMIN_USER && $ADMIN_USER != root ]] || die "set ADMIN_USER (run via sudo from a normal user, or set it in config.local.env)"
id "$ADMIN_USER" >/dev/null 2>&1 || die "user '$ADMIN_USER' does not exist"
if (( DRY_RUN )); then log "dry run: nothing will be changed"; fi

for s in "${stages[@]}"; do
  matches=("$ROOT"/stages/[0-9]*-"$s".sh)
  [[ -f ${matches[0]} ]] || die "unknown stage: $s"
  log "== stage: $s =="
  ( source "${matches[0]}"; stage_run )
done

log "done. Reboot if /var/run/reboot-required exists."
