# WireGuard VPN & Secure Remote Administration on Proxmox
## Project Overview
The goal of this project was to implement a secure remote administrative tool for my Proxmox homelab. I did this by using WireGuard VPN and SSH based authentication. This tool allows for a secure connection to Proxmox without exposing management systems to the internet.

<h3>Objective</h3>
  
- Implement WireGuard VPN within Proxmox 
- Enable secure remote access to the Proxmox web interface
- Configure SSH key authentication for root account on Proxmox
- Disable password-based SSH authentication

<h3>Network Architecture</h3>

| Devices | Address |
| --- | --- |
| Router | 10.0.0.1 |
| Proxmox | 10.0.0.44 |
| WireGuard Container| 10.0.0.121 |

<h3>VPN Network</h3>

| Devices | Address |
| --- | --- |
| WireGuard Server | 10.6.0.1 |
| Windows Client | 10.6.0.2 |

#

## Project Workflow

<h3>1. Deploy WireGuard</h3>

- Installed the WireGuard Community Script inside an LXC container.
- Verified WireGuard service installation.
- Generated initial client configuration.

# 

<h3>2. Configuring SSH Connection</h3>

- Generated SSH key pair on Windows

Example: 
```bash
ssh-keygen -t ed25519
```

- Copy newly generated public key to ssh authorized keys

Example: 
```bash
/root/.ssh/authorized_keys
```

<h4>Configure SSH:</h4>

```bash
PermitRootLogin prohibit-password
PubkeyAuthentication yes
```
<h3>Summary</h3>
When starting this project I wanted to ensure that ssh connection was working properly, to do this I needed to generate key pairs using the ssh keygen tool. Using this tool generates a public key, and private key file. These key pairs are important because they allow for devices to authenticate eachother if they have the same key pair. Thats why it is important to paste the public key to the authorized key file in the desired device you are trying to connect to. For best security practices I configured ssh to not allow password authentication. This ensures that anyone that is trying to ssh into the device must have the same key pair to enter.

>[!WARNING]
The private key must never be exposed because if an unauthorized user ever gains access to the private key they can gain access through ssh. 

# 

<h3>3. Initial VPN Testing</h3>

Successfully established a WireGuard handshake.

Verified using:
```bash
wg show
```
#

<h3>Issue 1 - VPN Address Conflict</h3>

**Problem**

WireGuard automatically generated:

10.0.0.0/24

which matched the home LAN.

Symptoms
Routing conflicts
Internet access blocked
Unable to reach Proxmox through the VPN
Resolution

Migrated the VPN to:

10.6.0.0/24

Updated:

- Server Address
- Client Address
- AllowedIPs
# 

<h3>Issue 2 - Endpoint Configuration</h3>

**Problem**

Generated client profile contained:

Endpoint = 127.0.1.1
Cause

Loopback address.

Resolution

Configured the endpoint to use the public IP address.

Future improvement:

- Configure Dynamic DNS
- Replace public IP with hostname
# 

<h3>Issue 3 - Remote Access</h3>

Configured:

- Port Forwarding (Adding rule may very depending on your router provider)
- Port 51820

Destination:
- WireGuard Container/ Wireguard IP

Successfully connected over:

- Mobile Hotspot
- External Internet

Successfully accessed:

- Proxmox Web Interface
- SSH
#
## Useful Commands

<h3>WireGuard</h3>

```bash
wg show
wg-quick up wg0
wg-quick down wg0
```
#
<h3>Networking</h3>

```bash
ip addr
ip route
ping
```
#
<h3>Firewall / NAT</h3>

```bash
iptables -L -n -v
iptables -t nat -L -n -v
```
#
<h3>SSH</h3>

```bash
systemctl restart ssh
systemctl status ssh
```
#
<h3>Windows</h3>

```bash
ipconfig
route print
```
#
<h3>Outcome</h3>
Successfully deployed a secure remote connection to Proxmox through SSH authentication, and Wireguard VPN. This follows security best practices by using VPN access, public key authentication, network segmentation, and NAT-based routing. 