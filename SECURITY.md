<sub>[← Back to README](README.md)</sub>

# Security Model

This is a personal cybersecurity homelab, but it's built around a deliberate
security posture. This document explains **how secrets are handled** and **how the
isolation boundary works** — the two things that keep the lab safe to experiment in.

---

## Secret handling

**No private keys or live secrets are ever committed to this repo.** The
[`.gitignore`](.gitignore) is written defensively to block them:

- WireGuard private keys and real `wg0.conf` files (only `*.conf.example` templates are tracked)
- SSH private keys (`id_ed25519`, `id_rsa`, `*.pem`, …)
- Terraform state (`*.tfstate`) and real `*.tfvars` (which can contain secrets in plaintext)
- Ansible vault/inventory files and `.env` files

If you fork or clone this, keep it that way: commit **example** files with
placeholders, never the filled-in originals.

### SSH

- **Key-only authentication** using an `ed25519` key pair.
- `PermitRootLogin prohibit-password` and password authentication disabled, so a
  guessed or leaked password is useless without the private key.
- Only the **public** key is ever distributed (into `authorized_keys`); the private
  key never leaves the client machine.

### WireGuard / remote access

- The Proxmox management interface is **never exposed directly to the internet**.
- The only inbound path from outside is a **single UDP port (51820)**, port-forwarded
  at the router to the WireGuard container. Everything else (the web UI, SSH) is only
  reachable **after** the tunnel is up.
- The tunnel uses a dedicated subnet (`10.6.0.0/24`) separate from the home LAN.

---

## Isolation model (trust boundaries)

The lab is organized into three trust zones, from least to most trusted-to-be-hostile:

| Zone | Network | Trust assumption |
| --- | --- | --- |
| Internet / WAN | — | Untrusted |
| Home LAN | `10.0.0.0/24` (`vmbr0`) | Semi-trusted (real devices live here) |
| **Lab LAN** | `10.10.10.0/24` (`vmbr1`, isolated) | **Assumed hostile** — malware/targets run here |

The whole point is that the **Lab LAN is treated as compromised by default**, and the
architecture — not a single toggle — is what keeps it contained:

1. **Physical isolation (in place now).** `vmbr1` is a Linux bridge with **no IP
   address and no physical uplink**. A machine on it has no path to anything except
   through a device that has a leg on both bridges. This is a fact of the wiring, not
   a rule that can be misconfigured away.
2. **The pfSense chokepoint (in progress).** [pfSense](pfsense/pfsense_setup.md) is the
   only device bridging `vmbr1` (LAN) and `vmbr0` (WAN). Every packet leaving the lab
   must pass through it, where it can be filtered. By default pfSense allows the LAN to
   start outbound connections but blocks the WAN from initiating into the LAN.
3. **The explicit block rule (planned).** To stop a compromised lab host from pivoting
   *back into the home network*, a LAN rule that **blocks `LAN → 10.0.0.0/24`** (placed
   above the default allow) will make the isolation strict: lab reaches the internet,
   never the house.

> [!NOTE]
> **Current state:** because pfSense is not yet installed, `vmbr1` is at present
> *completely* isolated (nothing routes off it at all), and no lab VMs exist yet. The
> outbound-internet path and the block rule come online once pfSense is configured.
> This document describes the target model; the [pfSense writeup](pfsense/pfsense_setup.md)
> tracks what's actually done.

---

## Screenshot review — potential redactions (for the author to decide)

The committed screenshots were checked for sensitive data. **Nothing that requires
rotating a credential was found** — no private keys, no passwords, and no public IP /
VPN endpoint are visible anywhere. The items below are low-risk and optional to redact:

| Item | Where | Risk | Suggestion |
| --- | --- | --- | --- |
| Physical NIC MAC, embedded in the interface name `enx309c23d6c07c` (= `30:9C:23:D6:C0:7C`) | `pfsense/img/create_vmbr1.png` | Low | Optional blur; a MAC is a hardware ID, not a secret |
| pfSense virtual NIC MACs (`BC:24:11:EF:11:9E`, `BC:24:11:D3:12:E8`) | `pfsense/img/add_vmbr.png`, `Screenshot 2026-07-17 142236.png` | Low | Auto-generated and trivially changeable; optional blur |
| Private IPs (`10.0.0.1/.44/.121`, demo `10.0.0.189`) | multiple | Very low | RFC1918, not internet-routable — fine to leave |
| Windows taskbar with app icons | `proxmox/img/login_prox.png` | Very low | Optional crop if you'd rather not show your desktop |

**Not exposed (good):** the public IP / WireGuard endpoint, any WireGuard config
contents, any SSH or WireGuard private key, and any password (the login field is blank).

---

## Reporting

This is a learning project, not a production service. If you notice a secret that
slipped into the repo history, or a security mistake in the writeups, please open an
issue so it can be fixed (and the key rotated).
