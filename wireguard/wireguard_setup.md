<sub>[← Back to README](../README.md) · Related: [Proxmox setup](../proxmox/proxmox_setup.md) · [pfSense firewall](../pfsense/pfsense_setup.md)</sub>

# WireGuard VPN & Secure Remote Administration on Proxmox

## Project Overview
The goal of this project was to implement a secure remote administrative tool for my Proxmox homelab. I did this by using a WireGuard VPN together with SSH key-based authentication. This lets me connect to Proxmox securely from anywhere **without exposing the management interface to the internet** — the only thing the outside world can reach is the VPN's single UDP port.

<h3>Objective</h3>

- Deploy WireGuard inside Proxmox (in an LXC container, **CT 100**)
- Enable secure remote access to the Proxmox web interface
- Configure SSH key authentication for the root account on Proxmox
- Disable password-based SSH authentication

<h3>Network Architecture</h3>

| Role | Address | Network |
| --- | --- | --- |
| Home router (gateway) | 10.0.0.1 | Home LAN `10.0.0.0/24` |
| Proxmox host (node `uno`) | 10.0.0.44 | Home LAN |
| WireGuard container (CT 100) | 10.0.0.121 | Home LAN |
| WireGuard **server** (tunnel side) | 10.6.0.1 | VPN `10.6.0.0/24` |
| Remote **client** (e.g. Windows laptop) | 10.6.0.2 | VPN `10.6.0.0/24` |
| Listening port | UDP **51820** | port-forwarded at the router |

*Why a separate `10.6.0.0/24` for the tunnel:* the VPN needs its own address space that does **not** overlap the home LAN. That detail turned out to matter — see [War Story #1](#issue-1--vpn-address-conflict).

## Project Workflow

<h3>1. Deploy WireGuard</h3>

- Installed WireGuard from the community LXC script inside a container (**CT 100**).
- Verified the WireGuard service was installed and running.
- Generated the initial client configuration.

<h3>2. Configure SSH Key Authentication</h3>

The idea here is to replace "something you know" (a password) with "something you have" (a private key), so that only a machine holding the matching key can log in.

- Generate an SSH key pair on the client (Windows):

  ```bash
  ssh-keygen -t ed25519
  ```

- Copy the newly generated **public** key into the authorized-keys file on Proxmox:

  ```bash
  /root/.ssh/authorized_keys
  ```

- Harden the SSH daemon (`/etc/ssh/sshd_config`) so it accepts keys and refuses passwords for root:

  ```bash
  PermitRootLogin prohibit-password
  PubkeyAuthentication yes
  ```

<h4>Why this matters</h4>

When starting this project I wanted to make sure the SSH connection was working properly. To do this I needed to generate a key pair using the `ssh-keygen` tool. This generates a public key and a private key. The key pair is what lets two devices authenticate each other: you paste the **public** key into the `authorized_keys` file on the device you're connecting to, and the machine holding the matching **private** key is the only one allowed in. For best security practices I configured SSH to not allow password authentication. That way anyone trying to SSH into the device must have the correct key — a stolen or guessed password gets them nowhere.

> [!WARNING]
> The private key must never be exposed. If an unauthorized user ever gains access to the private key, they can log in over SSH as if they were you.

<h3>3. Initial VPN Testing</h3>

Established a successful WireGuard handshake and verified it with:

```bash
wg show
```

## Troubleshooting / War Stories

These are the two real bugs I hit bringing the tunnel up, and how I fixed each. Documenting them because they're the parts someone else will actually run into.

<h3 id="issue-1--vpn-address-conflict">Issue 1 — VPN address conflict</h3>

**Problem.** WireGuard automatically generated the tunnel network as `10.0.0.0/24` — the same subnet as my home LAN.

**Symptoms.**
- Routing conflicts
- Internet access blocked while connected
- Unable to reach Proxmox through the VPN

**Root cause.** With the tunnel and the home LAN claiming the *same* subnet, the client couldn't tell which route to use for `10.0.0.x` — so traffic meant for Proxmox (and for the internet) went the wrong way.

**Resolution.** Migrated the VPN to its own range, `10.6.0.0/24`, and updated:

- Server Address
- Client Address
- `AllowedIPs`

<h3 id="issue-2--endpoint-configuration">Issue 2 — Endpoint configuration</h3>

**Problem.** The generated client profile contained `Endpoint = 127.0.1.1`.

**Root cause.** `127.0.1.1` is a loopback address — it points the client back at *itself* instead of at the WireGuard server, so the tunnel can never actually reach home.

**Resolution.** Set the endpoint to the network's **public IP address**.

**Future improvement.**
- Configure Dynamic DNS
- Replace the public IP with a hostname (so the profile keeps working when the ISP changes the IP)

<h3 id="issue-3--remote-access">Issue 3 — Remote access (port forwarding)</h3>

To let the tunnel be reached from outside the house, I configured port forwarding at the router:

- **Port 51820** (the WireGuard listening port; adding the rule varies by router vendor)
- **Destination:** the WireGuard container / WireGuard IP

## Verification

Confirmed the remote-access path end to end:

- Successfully connected over a **mobile hotspot** and from the **external internet** (not on the home Wi-Fi)
- Reached the **Proxmox web interface** through the tunnel
- Reached the host over **SSH** (key-only)

## Useful Commands

<h3>WireGuard</h3>

```bash
wg show             # show tunnel status / handshakes / transfer
wg-quick up wg0     # bring the tunnel up
wg-quick down wg0   # bring the tunnel down
```

<h3>Networking</h3>

```bash
ip addr             # interface addresses
ip route            # routing table (handy for the Issue 1 conflict)
ping                # basic reachability
```

<h3>Firewall / NAT</h3>

```bash
iptables -L -n -v          # filter rules
iptables -t nat -L -n -v   # NAT rules
```

<h3>SSH</h3>

```bash
systemctl restart ssh   # apply sshd_config changes
systemctl status ssh    # confirm it came back up
```

<h3>Windows (client side)</h3>

```bash
ipconfig       # client addressing
route print    # client routing table
```

## Outcome
Successfully deployed secure remote access to Proxmox using SSH key authentication and a WireGuard VPN. This follows security best practices: VPN-only access instead of exposing management ports, public-key authentication with passwords disabled, a dedicated tunnel subnet separated from the home LAN, and NAT-based routing. The management interface is never directly reachable from the internet — only the single WireGuard UDP port is.
