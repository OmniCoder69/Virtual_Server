# Intro to Proxmox

[Proxmox](https://www.proxmox.com/en/downloads) is an open-source virtualization platform that provides several server solutions including:

- Proxmox VE
- Proxmox Backup Server
- Proxmox Mail Gateway
- Proxmox Datacenter Manager

For this homelab, I installed **Proxmox VE**.

In order to install Proxmox VE on a dedicated HDD or SSD you must first upload it a bootable USB drive with a software such as [Rufus](https://rufus.ie/en/). The better alternative in my opinion is using [Ventoy](https://www.ventoy.net/en/index.html). Ventoy is an opensource software that allows you to have multiple bootable install files all in one USB drive.

For the sake of showing you how proxmox looks when launching the install I used [Oracle VirtualBox](https://www.virtualbox.org/) to create a VM with Proxmox iso file. As you can see in [Example 1.1](#example-1-1) I created a VM in VirtualBox with 300gb of storage that proxmox is installing on. My real proxmox is on an entire HDD dedicated to proxmox only.

<h4 id="example-1-1">Example 1.1 - Proxmox Installation Agreement</h4>
<img src="/proxmox/img/agreement_prox.png" alt="Download of proxmox to hard drive" width="500" height="450">   

<h4 id="example-1-2">Example 1.2 - First Boot Terminal</h4>
<img src="/proxmox/img/terminal_prox.png" alt="Once proxmox is done installing" width="500" height="450">   

<h4 id="example-1-3">Example 1.3 - Web Interface Login</h4>
<img src="/proxmox/img/web_prox.png" alt="Description" width="500" height="450">   

<h4 id="example-1-4">Example 1.4 - Proxmox VE Helper Scripts</h4>
<img src="/proxmox/img/porxmoxhelper.png" alt="Description" width="500" height="450">   

<h4 id="example-1-5">Example 1.5 - Proxmox Dashboard</h4>
<img src="/proxmox/img/pve.png" alt="Description" width="500" height="450">   

<h4 id="example-1-6">Example 1.6 - Uploading an ISO</h4>
<img src="/proxmox/img/upload_iso.png" alt="Description" width="500" height="450">   

<h4 id="example-1-7">Example 1.7 - Removing the Enterprise Repository Notice</h4>
<img src="/proxmox/img/nosub.png" alt="Description" width="500" height="450">   

