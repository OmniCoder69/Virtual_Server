<sub>[← Back to README](README.md)</sub>

# Changelog

All notable changes to this repo. Format loosely follows
[Keep a Changelog](https://keepachangelog.com/).

## [Unreleased] — `claude-upgrade` branch (2026-07-22)

A documentation + reproducibility overhaul that turns the homelab writeups into a
portfolio-grade engineering project. **No live infrastructure was changed** — this
branch is docs, diagrams, and reviewed-but-unrun automation.

### Added
- **Portfolio README** — plain-English overview, embedded architecture diagram
  (PNG + live Mermaid), table of contents, "Skills demonstrated", and a status/
  roadmap table (✅/🚧/⬜).
- **pfSense writeup** (`pfsense/pfsense_setup.md`) — the previously-missing doc,
  with an honest "Build status" banner separating what's built from the standard
  path that isn't configured yet.
- **Network architecture diagram** committed in three formats (`docs/`).
- **Automation layer**
  - `scripts/create-vmbr1.sh` — create the isolated bridge (dry-run by default, idempotent).
  - `scripts/wg-client-gen.sh` — generate WireGuard client profiles + server peer block.
  - `infra/terraform/` — lab VMs on `vmbr1` via the `bpg/proxmox` provider.
  - `infra/ansible/` — baseline the lab and **assert isolation** (fails if the home LAN is reachable).
  - `Makefile` — one orchestration entrypoint (`make help`).
  - `configs/wireguard/wg0.conf.example` — server config template.
- **Lab guide** (`docs/lab-guide.md`) — a beginner-followable first pentest exercise.
- **Security hygiene** — `SECURITY.md` (secret handling + isolation model + a
  screenshot-redaction review), a secret-safe `.gitignore`, MIT `LICENSE`,
  `ROADMAP.md`, and this `CHANGELOG.md`.

### Changed
- **Proxmox + WireGuard writeups** restructured to one shared format
  (overview → objective → architecture → steps → verification → useful commands
  → outcome), voice preserved.
- **Proxmox images fixed** — corrected broken leading-slash paths (they likely
  weren't rendering on GitHub), wired the 3 previously-orphaned screenshots back
  in (9/9 now used), and replaced placeholder alt text.
- **WireGuard bugs** reformatted into a proper "Troubleshooting / War Stories"
  section; corrected the container reference (CT 100 / LXC, not a VM).

### Notes / not verified
- The lab LAN subnet `10.10.10.0/24` remains a **placeholder** to confirm.
- Terraform/Ansible/shellcheck were **not** run in the authoring environment (not
  installed). Shell scripts were syntax-checked and their dry-run/idempotency/
  error paths were exercised. Nothing here has been run against the live host.

## [0.1.0] — prior work (baseline)

The original homelab documentation by the author: Proxmox VE install walkthrough,
WireGuard VPN + SSH hardening writeup, and the pfSense screenshots. See the git
history before the `claude-upgrade` branch.
