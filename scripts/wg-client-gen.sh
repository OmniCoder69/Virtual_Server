#!/usr/bin/env bash
# =============================================================================
# wg-client-gen.sh — generate a WireGuard client config for the homelab tunnel
# =============================================================================
#
# WHAT THIS DOES
#   Creates a ready-to-import WireGuard client profile (<name>.conf) for
#   connecting into the homelab over the tunnel documented in
#   ../wireguard/wireguard_setup.md:
#
#       VPN subnet : 10.6.0.0/24   (server 10.6.0.1)
#       Port       : 51820/udp     (port-forwarded at the router)
#
#   It generates a fresh client keypair, writes the .conf with locked-down
#   permissions, and prints the matching [Peer] block you paste on the SERVER.
#
# SECRET HYGIENE  (see ../SECURITY.md)
#   * The generated <name>.conf contains a PRIVATE key. It is written with
#     chmod 600 and its name matches the repo's .gitignore (*.conf) so it will
#     NOT be committed. Never commit a real client config.
#   * The server's public key and public endpoint are environment-specific. Pass
#     them in; if you don't, the script emits clearly-marked placeholders
#     (<SERVER_PUBLIC_KEY>, <PUBLIC_IP_OR_DDNS>) for you to fill in by hand.
#
# USAGE
#   ./wg-client-gen.sh --name laptop \
#       --server-pubkey "abc123...=" \
#       --endpoint "vpn.example.com:51820"
#
#   ./wg-client-gen.sh --name phone --client-ip 10.6.0.5     # pick the tunnel IP
#   ./wg-client-gen.sh --name laptop --full-tunnel           # route all traffic
#   ./wg-client-gen.sh --dry-run --name test                 # show, write nothing
#   ./wg-client-gen.sh --help
#
# REQUIREMENTS: the `wg` binary (wireguard-tools) for key generation.
# =============================================================================

set -euo pipefail

# --- defaults ----------------------------------------------------------------
NAME=""
CLIENT_IP="10.6.0.2"                       # matches the documented Windows client
SERVER_PUBKEY="<SERVER_PUBLIC_KEY>"        # placeholder until provided
ENDPOINT="<PUBLIC_IP_OR_DDNS>:51820"       # placeholder until provided
DNS="10.0.0.1"                             # home router / your chosen resolver
# Split tunnel by default: only homelab traffic goes through the VPN.
#   10.0.0.0/24 = home LAN (Proxmox 10.0.0.44, WireGuard CT 10.0.0.121)
#   10.6.0.0/24 = the VPN subnet itself
ALLOWED_IPS="10.0.0.0/24, 10.6.0.0/24"
KEEPALIVE=25
OUTDIR="."
DRYRUN=0
FORCE=0

# --- helpers -----------------------------------------------------------------
c_reset=$'\033[0m'; c_blue=$'\033[34m'; c_yellow=$'\033[33m'; c_red=$'\033[31m'; c_green=$'\033[32m'
log()  { printf '%s[*]%s %s\n' "$c_blue"   "$c_reset" "$*"; }
warn() { printf '%s[!]%s %s\n' "$c_yellow" "$c_reset" "$*"; }
err()  { printf '%s[x]%s %s\n' "$c_red"    "$c_reset" "$*" >&2; }
ok()   { printf '%s[+]%s %s\n' "$c_green"  "$c_reset" "$*"; }
die()  { err "$*"; exit 1; }
usage() { sed -n '2,42p' "$0" | sed 's/^# \{0,1\}//'; }

# --- arg parsing -------------------------------------------------------------
while [[ $# -gt 0 ]]; do
  case "$1" in
    --name)          NAME="${2:?}"; shift ;;
    --client-ip)     CLIENT_IP="${2:?}"; shift ;;
    --server-pubkey) SERVER_PUBKEY="${2:?}"; shift ;;
    --endpoint)      ENDPOINT="${2:?}"; shift ;;
    --dns)           DNS="${2:?}"; shift ;;
    --allowed-ips)   ALLOWED_IPS="${2:?}"; shift ;;
    --full-tunnel)   ALLOWED_IPS="0.0.0.0/0, ::/0" ;;
    --outdir)        OUTDIR="${2:?}"; shift ;;
    --dry-run)       DRYRUN=1 ;;
    --force)         FORCE=1 ;;
    -h|--help)       usage; exit 0 ;;
    *) die "unknown argument: $1 (try --help)" ;;
  esac
  shift
done

[[ -n "$NAME" ]] || die "a client --name is required (e.g. --name laptop)"
command -v wg >/dev/null 2>&1 || die "the 'wg' binary is required (install wireguard-tools)"

outfile="${OUTDIR%/}/${NAME}.conf"
if [[ -e "$outfile" && "$FORCE" -eq 0 && "$DRYRUN" -eq 0 ]]; then
  die "refusing to overwrite existing ${outfile} (use --force)"
fi

# --- generate the client keypair --------------------------------------------
# In dry-run we still generate keys in memory to show a realistic config, but we
# do NOT write anything to disk.
client_priv="$(wg genkey)"
client_pub="$(printf '%s' "$client_priv" | wg pubkey)"

# --- warn about unfilled placeholders ---------------------------------------
[[ "$SERVER_PUBKEY" == "<SERVER_PUBLIC_KEY>" ]] && \
  warn "No --server-pubkey given; leaving placeholder <SERVER_PUBLIC_KEY> in the file."
[[ "$ENDPOINT" == "<PUBLIC_IP_OR_DDNS>:51820" ]] && \
  warn "No --endpoint given; leaving placeholder <PUBLIC_IP_OR_DDNS> in the file."

# --- build the client config -------------------------------------------------
client_conf="[Interface]
# Client: ${NAME}
PrivateKey = ${client_priv}
Address = ${CLIENT_IP}/32
DNS = ${DNS}

[Peer]
# The homelab WireGuard server (CT 100)
PublicKey = ${SERVER_PUBKEY}
Endpoint = ${ENDPOINT}
AllowedIPs = ${ALLOWED_IPS}
PersistentKeepalive = ${KEEPALIVE}
"

echo
log "Client name : ${NAME}"
log "Tunnel IP   : ${CLIENT_IP}/32"
log "AllowedIPs  : ${ALLOWED_IPS}"
log "Output file : ${outfile}"
echo "----- ${NAME}.conf --------------------------------------------------"
printf '%s' "$client_conf"
echo "---------------------------------------------------------------------"

if [[ "$DRYRUN" -eq 1 ]]; then
  echo
  ok "DRY-RUN: nothing written to disk. (Keys shown above were generated in memory.)"
  exit 0
fi

# --- write it out with tight perms ------------------------------------------
umask 077
printf '%s' "$client_conf" > "$outfile"
chmod 600 "$outfile"
ok "Wrote ${outfile} (chmod 600, git-ignored by *.conf)."

# --- print the SERVER-side peer block ---------------------------------------
echo
warn "Add this [Peer] block to the SERVER's wg config, then reload the tunnel:"
echo "---------------------------------------------------------------------"
cat <<EOF
[Peer]
# ${NAME}
PublicKey = ${client_pub}
AllowedIPs = ${CLIENT_IP}/32
EOF
echo "---------------------------------------------------------------------"
echo "    # on the server:  wg addconf wg0 <(...)   OR edit wg0.conf then:"
echo "    #                 wg syncconf wg0 <(wg-quick strip wg0)"
