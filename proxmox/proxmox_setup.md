# Introduction to Proxmox - Walkthrough 

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

For demonstration purposes, I installed Proxmox inside an [Oracle VirtualBox](https://www.virtualbox.org/) virtual machine. Which if you are just starting out small you do not need a USB drive you can run the Proxmox ISO file directly on VirtualBox. 

As seen in [Example 1.1](#example-1-1) I created a vm with 300gb to show what it would look like to install proxmox. 

The actual server is installed directly on its own dedicated hard drive.

**Warning**
When installing Proxmox make sure you are selecting the correct destination of where you want to install it because Proxmox will delete any and all data that is being installed on the selected location.

When going through the install process Proxmox will ask you to create a password for the root user account. Be sure to remember this password becaue thats how you will be able to log into the proxmox server console and web page. The deault user account is named "root" which can be be changed later if you decide to. Also it will ask you to create a domain name for your Proxmox server for my example I set my domain name to uno. Setting your domain name shouldn't affect how you login.

<h4 id="example-1-1">Example 1.1 - Proxmox Installation Agreement</h4>
<img src="/proxmox/img/agreement_prox.png" alt="Download of proxmox to hard drive" width="500" height="450">   

## Proxmox First Boot

Proxmox does not have a GUI when launching on the device it was installed on. Instead, it boots directly into the terminal. When logging in, type the username "root" and press Enter. Then, enter the password you created during the Proxmox installation. If everything was configured correctly, you should now have access to the system through the command line.

<h4 id="example-1-2">Example 1.2 - First Boot Terminal</h4>
<img src="/proxmox/img/terminal_prox.png" alt="Once proxmox is done installing" width="500" height="450">   

Proxmox does have a web interface that you can connect through on another device. As seen in [Example 1.2](#example-1-2) The welcome page for Proxmox should show something like this **https://"your ip address":8006/** where port 8006 is the default TCP protocol that Proxmox uses to connect. When connecting to your webpage through your prefered web browser you should see something like this [Example 1.3](#example-1-3) 

**Warning** Make sure that your Proxmox server and the device you are using to connect to the web page are on the same network and subnet. If not your device will not be able to connect to the web interface. If you need to troubleshoot and find out what subnet and ip address your device is using on the network use these commands in your terminal depending on what OS system you are using.
- Windows: ipconfig
- Linux: ip -a
- Mac: curl ifconfig.me
  
If your Proxmox server is on a different subnet than the rest of your network, you will need to update its network configuration.

Example:

Your computer: 192.168.0.32
Proxmox server: 172.16.0.10

Since these devices are on different subnets, they will not be able to communicate without additional routing.

To change the Proxmox IP address, open the Proxmox terminal and edit the network configuration file using your preferred text editor:

Example: "nano /etc/network/interfaces"

Inside the file, locate the following lines:

- address
- gateway

Before changing these values, determine which IP addresses are available on your network. From another device connected to your network, run:

arp -a

Choose an unused IP address that matches your network's subnet, then update both the address and gateway fields. Save the file and reboot or restart the networking service to apply the changes. your new address and gateway should look similar to this example depending on your devices ip.
- Your computer: 192.168.0.32
- Proxmox Server: 192.168.0._(ip not being used)
- Gateway: 192.168.0.1 (Routers ip which is usually default to 1)


<h4 id="example-1-3">Example 1.3 - Web Interface Login</h4>
<img src="/proxmox/img/login_prox.png" alt="Description" width="500" height="450">   

## Uploading ISO Images

Uploading ISO images to your Proxmox server is straightforward. To begin, navigate to the ISO Images section under your local storage.

Navigation Path:

local (node name) → ISO Images → Upload

Proxmox provides two methods for adding ISO images to your server:

- Upload from your local device – Select an ISO file stored on your computer.
- Download from a URL – Provide the direct download link, and Proxmox will retrieve the ISO for you.

Both methods are shown in [Example 1.4](#example-1-4)

<h4 id="example-1-4">Example 1.4 - Uploading an ISO</h4>
<img src="/proxmox/img/upload_iso.png" alt="Description" width="500" height="450">   

## Extra Tools

One main source that I would like to mention is [Proxmox VE Helper-Scripts](https://github.com/community-scripts/ProxmoxVE). This is a community driven project found on Github that can help setup and customize Proxmox by using automated scripts to allow users to install services they may need.  
<h4 id="example-1-5">Example 1.5 - Proxmox VE Helper Scripts</h4>
<img src="/proxmox/img/porxmoxhelper.png" alt="Description" width="500" height="450">   

An example script found through this Helper-Scripts community was PVE Post install script. The PVE Post install script automates the tasks of turning off enterprise mode and enterprise ads on your Proxmox install. Enabling the no-subscription mode in Proxmox and allows for updates to be recieved by your Proxmox install.
<h4 id="example-1-6">Example 1.6 - Proxmox Dashboard</h4>
<img src="/proxmox/img/pve.png" alt="Description" width="500" height="450">   

