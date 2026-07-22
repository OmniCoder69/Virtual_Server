<sub>[← Back to README](README.md)</sub>

# Roadmap

Where this homelab is headed. Status markers match the README:
✅ done · 🚧 in progress · ⬜ planned.

## Done

- ✅ **Proxmox VE host on bare metal** (node `uno`, VE 9.2.4) — [writeup](proxmox/proxmox_setup.md)
- ✅ **WireGuard VPN + SSH hardening** (CT 100) — secure remote admin without exposing management — [writeup](wireguard/wireguard_setup.md)
- ✅ **Isolated bridge `vmbr1`** created on Proxmox (no IP, no uplink)
- ✅ **pfSense VM built** (VM 101, two NICs, UEFI) and booting to the installer

## In progress

- 🚧 **Finish the pfSense install & config** — [writeup](pfsense/pfsense_setup.md)
  - Run the installer and reboot
  - Assign `WAN = vtnet0 (vmbr0)`, `LAN = vtnet1 (vmbr1)`
  - Set the LAN subnet (placeholder `10.10.10.1/24`) and enable DHCP for the lab range
  - Add the strict `LAN → 10.0.0.0/24` block rule above the default allow

## Planned — next

- ⬜ **Stand up the first lab targets on `vmbr1`** — a Kali attacker and a vulnerable box (Metasploitable). Confirm isolation: internet reachable, home LAN not. A beginner-followable walkthrough will live at [`docs/lab-guide.md`](docs/lab-guide.md).
- ⬜ **Route the WireGuard tunnel into the pfSense lab** — the highest-leverage next step. It fuses the two finished projects (remote access + isolated range) into one, so the lab can be reached and pentested from anywhere.
- ⬜ **VLAN-segment the lab** — split `vmbr1` into separate attacker and victim segments to practice lateral-movement and segmentation controls.

## Planned — later

- ⬜ **Reproducible builds (Infrastructure-as-Code)** — Terraform (`bpg/proxmox`) to define the lab VMs and an Ansible playbook to baseline the targets, so the whole range can be torn down and rebuilt from code. Scaffolding lands under `infra/` in this branch.
- ⬜ **Snapshots & backups** — snapshot clean target states for fast reset after an exercise.
- ⬜ **More targets & scenarios** — additional Windows/Linux victims and guided attack scenarios.
- ⬜ **(Stretch) Detection lab** — a monitoring/IDS box (e.g. Security Onion) on a mirror segment to practice the blue-team side of the same attacks.

---

*This roadmap is intentionally honest about what's built vs. planned. See
[SECURITY.md](SECURITY.md) for the isolation model that every step above is designed
to preserve.*
