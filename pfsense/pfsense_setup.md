<sub>[← Back to README](../README.md) · Related: [Proxmox setup](../proxmox/proxmox_setup.md) · [WireGuard VPN](../wireguard/wireguard_setup.md)</sub>

# pfSense Firewall & Isolated Lab Network on Proxmox

## Project Overview
The goal of this project was to add a virtual firewall/router to the Proxmox homelab so that I can run an **isolated lab network**. I did this by deploying [pfSense](https://www.pfsense.org/) as a virtual machine with two network interfaces: one facing my home network and one facing a private, isolated bridge that only the lab machines live on. This lets me run malware analysis, penetration testing, and vulnerable target machines without any of that traffic touching the rest of my home network.

> [!IMPORTANT]
> **Build status.** The isolated bridge `vmbr1` and the pfSense VM (VM 101 — two NICs, UEFI) are **built**, and the VM boots to the installer — that is exactly what the screenshots below show. Everything from *[Boot the Installer](#3-boot-the-installer)* onward is the **standard install/configuration path**, documented here as the plan. Those later steps and their values (LAN subnet, DHCP range, firewall rules) are **not configured yet** and are flagged inline as placeholders to confirm.

<h3>Objective</h3>

- Create a second, isolated virtual bridge (`vmbr1`) on Proxmox
- Deploy pfSense as a VM with a WAN interface (`vmbr0`) and a LAN interface (`vmbr1`)
- Route and firewall the lab network so it can reach the internet but **cannot** reach the home network
- Lay the groundwork for attacker/target lab VMs to sit safely behind the firewall

<h3>Network Architecture</h3>

| Interface / Device | Bridge | Address |
| --- | --- | --- |
| Home Router | — | 10.0.0.1 |
| Proxmox host (node `uno`) | vmbr0 | 10.0.0.44/24 |
| pfSense WAN (net0) | vmbr0 | from home LAN (10.0.0.x) |
| pfSense LAN (net1) | vmbr1 | 10.10.10.1/24 *(lab gateway)* |
| Lab VMs | vmbr1 | 10.10.10.0/24 *(via pfSense DHCP)* |

> [!NOTE]
> The LAN subnet (`10.10.10.0/24`) is the value I am using for the lab. Pick any private range that does **not** overlap your home LAN (`10.0.0.0/24`) — reusing the home subnet here causes the same kind of routing conflict I ran into on the [WireGuard project](../wireguard/wireguard_setup.md#troubleshooting-and-war-stories).

<h3>Understanding the Two Bridges</h3>

Proxmox uses Linux bridges (`vmbrX`) as virtual switches. The key to this whole project is that the two bridges do different jobs:

- **`vmbr0`** is the *uplink* bridge. It is attached to the physical NIC (`nic0`) and carries my real home network (`10.0.0.0/24`). This is what pfSense treats as its **WAN**.
- **`vmbr1`** is *isolated*. It has **no IP address and no physical port**, so nothing on it can reach the outside world except through pfSense. This is the lab's **LAN**.

*Why it matters:* isolation isn't a firewall rule you can forget to add — it's a physical fact of the wiring. Because `vmbr1` has no uplink of its own, the **only** path off the lab network is through pfSense, where I control every packet. That's what makes the sandbox safe by design rather than by hope.

## Project Workflow

<h3>1. Create the Isolated Bridge (vmbr1)</h3>

In the Proxmox web interface, go to:

```text
Datacenter
└── uno (node)
    └── System
        └── Network
            └── Create → Linux Bridge
```

Create the bridge and leave the **IPv4/CIDR and Gateway fields blank**, with no bridge port assigned. That empty configuration is exactly what makes it isolated. After creating it, click **Apply Configuration**.

As shown in [Example 1.1](#example-1-1), `vmbr0` carries the `10.0.0.44/24` address and gateway `10.0.0.1`, while the newly created `vmbr1` has no address at all.

<h4 id="example-1-1">Example 1.1 - Proxmox Network Bridges</h4>
<img src="img/create_vmbr1.png" alt="Proxmox node network list showing vmbr0 with 10.0.0.44/24 and the isolated vmbr1 with no address" width="500" height="450">

<h3 id="2-create-the-pfsense-vm">2. Create the pfSense VM</h3>

Download the [Netgate pfSense installer ISO](https://www.pfsense.org/download/) and upload it to Proxmox local storage (see the ISO upload step in the [Proxmox walkthrough](../proxmox/proxmox_setup.md#5-upload-iso-images)). Then create a new VM with the following settings:

| Setting | Value |
| --- | --- |
| VM ID / Name | 101 / pfSense |
| BIOS | OVMF (UEFI) + EFI disk |
| Machine | q35 |
| Memory | 4 GB |
| Processors | 2 cores (host type) |
| Disk | 26 GB (VirtIO SCSI) |
| ISO | netgate-installer-v1.2-RELEASE-amd64.iso |

The important part is the **two network devices**:

- **net0 → bridge `vmbr0`** — this becomes the **WAN**
- **net1 → bridge `vmbr1`** — this becomes the **LAN**

Both are shown attached to the VM in [Example 1.2](#example-1-2).

<h4 id="example-1-2">Example 1.2 - pfSense VM Hardware (two NICs)</h4>
<img src="img/add_vmbr.png" alt="pfSense VM 101 hardware showing net0 on vmbr0 and net1 on vmbr1" width="500" height="450">

<h3 id="3-boot-the-installer">3. Boot the Installer</h3>

Start the VM and open the console. Because the VM is set to UEFI, it lands on the boot device menu shown in [Example 1.3](#example-1-3). Select the **QEMU DVD-ROM** entry to boot the pfSense installer, then walk through the installer (accept the defaults for a standard install, choose the 26 GB VirtIO disk as the target).

<h4 id="example-1-3">Example 1.3 - UEFI Boot Device Menu</h4>
<img src="img/Screenshot%202026-07-17%20142236.png" alt="UEFI boot device selection menu for the pfSense VM" width="500" height="450">

> [!WARNING]
> Make sure you select the DVD-ROM / ISO entry, **not** a PXE (network boot) entry. The UEFI menu lists several PXE and HTTP-boot options first; booting those will not start the pfSense installer.

<h3>4. Assign Interfaces (WAN / LAN)</h3>

> [!NOTE]
> Steps 4–6 are the standard pfSense bring-up. They are documented here as the plan; the values below (LAN IP, DHCP range, rules) are the ones I intend to use, not yet applied.

After install and reboot, pfSense drops into its console menu and asks you to assign interfaces. pfSense sees the two VirtIO NICs as `vtnet0` and `vtnet1`, in the same order as `net0` / `net1` in Proxmox:

- `vtnet0` → **WAN** (this is `vmbr0`, the home network)
- `vtnet1` → **LAN** (this is `vmbr1`, the isolated lab)

> [!NOTE]
> If you are unsure which virtual NIC is which, match the MAC address shown in pfSense against the MAC on the Proxmox **Hardware** tab (Example 1.2). Getting WAN and LAN backwards is the most common mistake here.

Once assigned:

- **WAN** pulls an address automatically from the home LAN over DHCP (something in `10.0.0.x`).
- **LAN** is set from the console menu (option **2 → Set interface IP address**) to `10.10.10.1/24`, with the **pfSense DHCP server enabled** for the lab range (e.g. `10.10.10.100 – 10.10.10.200`).

<h3>5. Access the Web GUI</h3>

Because the LAN is isolated, the web GUI is reached **from a machine on `vmbr1`**, not from the home network. Attach any VM to `vmbr1`, let it pull a `10.10.10.x` lease from pfSense, then browse to:

```text
https://10.10.10.1
```

Default credentials are `admin` / `pfsense`. Change the password immediately, then run the initial Setup Wizard (hostname, DNS, timezone).

<h3 id="6-firewall-and-isolation-rules">6. Firewall &amp; Isolation Rules</h3>

Out of the box pfSense already does most of what this lab needs: the **LAN can start connections outbound** (to the internet, via NAT through WAN), but the **WAN side cannot start connections into the LAN**. That alone keeps the home network from reaching the lab.

To make the isolation strict — so a compromised lab VM cannot pivot back into the home network — add a LAN firewall rule **above** the default allow rule:

- **Block** LAN → `10.0.0.0/24` (the home network)
- **Allow** LAN → any (internet), so targets can still download updates/tools

*Why this order:* pfSense evaluates rules top-down and stops at the first match. Putting the block rule **above** the default "allow LAN to any" is what actually prevents a compromised target from reaching `10.0.0.x` — below it, the allow-any would match first and the block would never fire.

## Verification

The lab is working correctly when, from a VM attached to `vmbr1`:

- It receives a `10.10.10.x` address from pfSense DHCP
- It can reach the internet (e.g. `ping 8.8.8.8`)
- It **cannot** reach any host on the home network (`ping 10.0.0.1` fails)
- The pfSense web GUI at `https://10.10.10.1` is reachable

## Useful Commands

<h3>pfSense (console / shell)</h3>

```bash
ifconfig            # confirm vtnet0 (WAN) and vtnet1 (LAN) addresses
pfSsh.php           # pfSense developer shell
```

<h3>Proxmox host (verifying bridges)</h3>

```bash
ip -br a            # list interfaces/bridges and their addresses
bridge link         # show which interfaces are attached to which bridge
```

## Next Steps

- Deploy the first lab VMs on `vmbr1`: a Kali attacker and a vulnerable target (Metasploitable, an intentionally-old Windows box, etc.). A beginner-followable walkthrough lives in the [lab guide](../docs/lab-guide.md).
- Add VLANs on `vmbr1` to split the lab into multiple segments (e.g. attacker net vs. victim net)
- Route the existing [WireGuard VPN](../wireguard/wireguard_setup.md) into the lab so the range can be reached and tested remotely — this connects the two projects into one

## Outcome
So far I've created the isolated bridge (`vmbr1`) and the pfSense VM (VM 101) with two NICs — `net0` on `vmbr0` (WAN) and `net1` on the isolated `vmbr1` (LAN) — and the VM boots to the installer. The remaining install-and-configure steps are documented above as the standard path. Once they're complete, the result will be a self-contained network segment that can reach the internet but is firewalled off from the home network — the safe foundation for running cybersecurity labs, malware analysis, and penetration testing on the homelab.
