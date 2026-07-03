# Intro to Proxmox

[Proxmox](https://www.proxmox.com/en/downloads) is an open-source virtualization platform that provides several server solutions including:

- Proxmox VE
- Proxmox Backup Server
- Proxmox Mail Gateway
- Proxmox Datacenter Manager

For this homelab, I installed **Proxmox VE**.

## Creating the Installation USB

Before installing Proxmox, the ISO must be written to a bootable USB drive.

Two common tools are:

- [Rufus](https://rufus.ie/en/)
- [Ventoy](https://www.ventoy.net/en/index.html)

**Recommendation**
I personally recommend **Ventoy** because it allows multiple bootable ISO files to exist on a single USB drive. Instead of reformatting the drive every time you need another operating system, simply copy additional ISO files onto the USB.


## Installing Proxmox VE

For demonstration purposes, I installed Proxmox inside an [Oracle VirtualBox](https://www.virtualbox.org/) virtual machine.

As seen in [Example 1.1](#example-1-1) I created a vm with 300gb to show what it would look like to install proxmox. 

The actual server is installed directly on its own dedicated hard drive.

**Warning**
When installing Proxmox make sure you are selecting the correct destination of where you want to install it because Proxmox will delete any and all data that is being installed on the selected location.

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

