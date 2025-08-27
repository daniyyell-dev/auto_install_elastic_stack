## Step-by-Step Guide to Setting Up a SOC Lab (VirtualBox/VMware + Ubuntu/Kali)

This guide walks you through downloading and setting up **virtualisation software** (VirtualBox or VMware) and then installing a Linux distribution (Ubuntu, Kali, or Kali Purple).  
Once the system is ready, you can run the **Elastic Stack auto-install script** to deploy Elasticsearch + Kibana with HTTPS enabled.  

## Download & Install Virtualisation Software

You need software to run virtual machines (VMs) on your computer. Choose one:

### Option A: VirtualBox (Free & Open Source)
1. Visit the [VirtualBox downloads page](https://www.virtualbox.org/wiki/Downloads).  
2. Select the version for your operating system (Windows, macOS, Linux, or Solaris).  
3. Download and run the installer.  
4. Follow the installation prompts (default options are fine).  
5. (Optional) Install the **VirtualBox Extension Pack** (adds USB 2.0/3.0, RDP, PXE boot, etc.).

### Option B: VMware Workstation
- **For Windows/Linux**: Download **VMware Workstation Player (Free for personal use)**  
  [Download here](https://www.vmware.com/products/workstation-player.html)  
- **For macOS**: Use **VMware Fusion** (free for personal use).  
  [Download here](https://www.vmware.com/products/fusion.html)  

Install VMware following the on-screen instructions.  


## Download a Linux ISO Image

You’ll need a Linux distribution ISO file to install inside your VM. Choose one:

### Option A: Ubuntu (Recommended for Elastic Stack)
- Go to [Ubuntu downloads](https://ubuntu.com/download/desktop).  
- Download the latest **LTS (Long-Term Support)** release (Ubuntu 20.04 or newer, e.g., 22.04).  
- Save the `.iso` file.  

### Option B: Kali Linux (Security Testing)
- Go to [Kali Linux downloads](https://www.kali.org/get-kali/).  
- Download the latest version (64-bit).  
- If you want preinstalled SOC tools, try **Kali Purple** (designed for defensive security).  

Both work Ubuntu is **stable** and good for Elastic, while Kali/Kali Purple are **security-focused** and come with many built-in tools.  

## Create a Virtual Machine (VM)

1. Open **VirtualBox** or **VMware**.  
2. Click **New VM** (or **Create New Virtual Machine**).  
3. Give your VM a name (e.g., `Ubuntu-Lab` or `Kali-Purple`).  
4. Choose the downloaded `.iso` file as the installation media.  
5. Allocate resources:  
   - **RAM**: at least **4GB** (15GB+ recommended for Elastic Stack).  
   - **CPU**: 2 cores minimum (6+ recommended).  
   - **Disk space**: 40GB+ minimum (200GB+ recommended).  
6. **Configure Network (Important!)**  
   - **Option 1: Bridged Adapter** → VM will get an IP from the same network as your host.  
     - Recommended if you want to access Kibana/Elasticsearch directly from other devices on your LAN.  
   - **Option 2: NAT** → VM shares host IP.  
     - Recommended if you want quick setup on a laptop.  
   - **Option 3: Host-Only Adapter** → VM is only accessible from the host machine.  
     - Good for isolated lab testing.  
7. Finish setup and start the VM.  
8. Install the OS by following the Linux installer prompts.  


## Network Setup Recommendations

- If you are learning SOC tools and want **browser access** to Kibana → use **Bridged Adapter**.  
- If you want a **portable lab** that only runs on your laptop → use **NAT** with port forwarding:  


## Install Guest Additions / VMware Tools

After Linux installation completes:  
- In **VirtualBox**:  
  - Go to *Devices > Insert Guest Additions CD Image*.  
  - Follow prompts to install drivers (better performance + clipboard sharing).  
- In **VMware**:  
  - Go to *VM > Install VMware Tools*.  
  - Follow prompts inside Linux.  


## Update the System

Once inside your Linux VM, update the system:  

```bash
sudo apt update && sudo apt upgrade -y

```
This ensures your packages are up to date before installing Elastic Stack. Good luck !!
