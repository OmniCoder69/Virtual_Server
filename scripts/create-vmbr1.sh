#!/usr/bin/env bash
# =============================================================================
# create-vmbr1.sh — create the isolated lab bridge (vmbr1) on a Proxmox host
# =============================================================================
#
# WHAT THIS DOES
#   Adds an isolated Linux bridge to /etc/network/interfaces:
#
#       auto vmbr1
#       iface vmbr1 inet manual
#           bridge-ports none      # <- no physical uplink
#           bridge-stp off
#           bridge-fd 0
#
#   "inet manual" + "bridge-ports none" is the whole trick: the bridge has NO
#   IP address and NO physical port, so nothing attached to it can reach the
#   outside world except through a VM that also has a leg on another bridge
#   (that VM is pfSense). This is the physical foundation of the isolated lab.
#   See ../pfsense/pfsense_setup.md and ../SECURITY.md for the why.
#
# SAFETY MODEL
#   * DRY-RUN BY DEFAULT. Running with no flags changes NOTHING — it only prints
#     the stanza it would add and the commands it would run. You must pass
#     --apply to make real changes.
#   * Idempotent: if a vmbr1 stanza already exists it does nothing (use --force
#     to re-add).
#   * Before writing, it backs up /etc/network/interfaces to a timestamped copy.
#
#   >>> REVIEW THIS SCRIPT BEFORE RUNNING IT AGAINST REAL HARDWARE. <<<
#   Adding vmbr1 is additive and should not touch vmbr0, but you are editing the
#   host's network config on a live box. Have console access as a fallback.
#
# USAGE
#   ./create-vmbr1.sh                 # dry-run (safe; prints the plan)
#   ./create-vmbr1.sh --apply         # actually create the bridge + reload
#   ./create-vmbr1.sh --bridge vmbr2  # use a different bridge name
#   ./create-vmbr1.sh --apply --force # re-add even if a stanza exists
#   ./create-vmbr1.sh --help
#
# REQUIREMENTS (for --apply): root, Proxmox with ifupdown2 (provides `ifreload`).
# =============================================================================

set -euo pipefail

# --- defaults ----------------------------------------------------------------
BRIDGE="vmbr1"
PORTS="none"                          # "none" = isolated; or an iface like enp3s0
IFACES_FILE="/etc/network/interfaces"
APPLY=0
FORCE=0

# --- tiny logging/helpers ----------------------------------------------------
c_reset=$'\033[0m'; c_blue=$'\033[34m'; c_yellow=$'\033[33m'; c_red=$'\033[31m'; c_green=$'\033[32m'
log()  { printf '%s[*]%s %s\n' "$c_blue"   "$c_reset" "$*"; }
warn() { printf '%s[!]%s %s\n' "$c_yellow" "$c_reset" "$*"; }
err()  { printf '%s[x]%s %s\n' "$c_red"    "$c_reset" "$*" >&2; }
ok()   { printf '%s[+]%s %s\n' "$c_green"  "$c_reset" "$*"; }
die()  { err "$*"; exit 1; }

# run: echo a command; execute it only when --apply is set, otherwise just show it
run() {
  if [[ "$APPLY" -eq 1 ]]; then
    log "run: $*"
    "$@"
  else
    printf '      would run: %s\n' "$*"
  fi
}

usage() { sed -n '2,45p' "$0" | sed 's/^# \{0,1\}//'; }

# --- arg parsing -------------------------------------------------------------
while [[ $# -gt 0 ]]; do
  case "$1" in
    --apply)   APPLY=1 ;;
    --force)   FORCE=1 ;;
    --bridge)  BRIDGE="${2:?--bridge needs a name}"; shift ;;
    --ports)   PORTS="${2:?--ports needs a value}"; shift ;;
    --file)    IFACES_FILE="${2:?--file needs a path}"; shift ;;
    -h|--help) usage; exit 0 ;;
    *) die "unknown argument: $1 (try --help)" ;;
  esac
  shift
done

# --- the bridge stanza we intend to add --------------------------------------
read -r -d '' STANZA <<EOF || true

auto ${BRIDGE}
iface ${BRIDGE} inet manual
	bridge-ports ${PORTS}
	bridge-stp off
	bridge-fd 0
#	Isolated lab bridge created by create-vmbr1.sh — no IP, no uplink.
#	Only pfSense (with a leg on vmbr0) bridges this to the outside world.
EOF

echo
if [[ "$APPLY" -eq 1 ]]; then
  warn "APPLY mode: real changes will be made to ${IFACES_FILE}."
else
  ok "DRY-RUN (default): nothing will be changed. Re-run with --apply to commit."
fi
echo
log "Target file : ${IFACES_FILE}"
log "Bridge      : ${BRIDGE}  (ports: ${PORTS})"
echo "----- stanza to add -------------------------------------------------"
printf '%s\n' "$STANZA"
echo "---------------------------------------------------------------------"
echo

# --- preflight (hard requirements only enforced for --apply) -----------------
if [[ "$APPLY" -eq 1 ]]; then
  [[ "$(id -u)" -eq 0 ]] || die "must run as root to modify ${IFACES_FILE}"
  command -v ifreload >/dev/null 2>&1 || die "ifreload not found (need ifupdown2 — is this a Proxmox host?)"
  [[ -f "$IFACES_FILE" ]] || die "interfaces file not found: ${IFACES_FILE}"
fi

# --- idempotency check -------------------------------------------------------
# Only read the file if it exists — a dry-run off the Proxmox host (e.g. on a
# laptop, where /etc/network/interfaces is absent) should still show the plan.
if [[ -f "$IFACES_FILE" ]]; then
  if grep -Eq "^[[:space:]]*iface[[:space:]]+${BRIDGE}[[:space:]]" "$IFACES_FILE"; then
    if [[ "$FORCE" -eq 0 ]]; then
      ok "Bridge '${BRIDGE}' is already configured in ${IFACES_FILE} — nothing to do."
      warn "Use --force to append another stanza anyway (rarely what you want)."
      exit 0
    fi
    warn "Bridge '${BRIDGE}' already exists but --force was given; appending anyway."
  fi
else
  warn "Note: ${IFACES_FILE} not present here — that's expected for a dry-run off the Proxmox host."
fi

# --- back up, then append ----------------------------------------------------
backup="${IFACES_FILE}.bak.$(date +%Y%m%d-%H%M%S)"
run cp -a "$IFACES_FILE" "$backup"
[[ "$APPLY" -eq 1 ]] && ok "Backed up ${IFACES_FILE} -> ${backup}"

if [[ "$APPLY" -eq 1 ]]; then
  printf '%s\n' "$STANZA" >> "$IFACES_FILE"
  ok "Appended ${BRIDGE} stanza to ${IFACES_FILE}"
else
  printf '      would append the stanza above to %s\n' "$IFACES_FILE"
fi

# --- reload networking -------------------------------------------------------
warn "Reloading network config (this is where a bad edit could disrupt access)."
run ifreload -a

echo
ok "Done. Verify with:"
echo "    ip -br a | grep ${BRIDGE}      # should show ${BRIDGE} with no IPv4 address"
echo "    bridge link                    # ${BRIDGE} should have no physical port"
[[ "$APPLY" -eq 0 ]] && { echo; ok "That was a dry run. Re-run with --apply when the plan looks right."; }
