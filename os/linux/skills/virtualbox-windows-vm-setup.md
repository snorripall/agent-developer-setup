---
name: virtualbox-windows-vm-setup
description: Set up a Windows VirtualBox VM on CachyOS with USB passthrough for Xiaomi/Redmi phone tools
triggers:
  - "setup virtualbox windows"
  - "create windows vm"
  - "virtualbox vm windows"
  - "mi unlock virtualbox"
  - "windows vm for xiaomi"
---

# VirtualBox Windows VM Setup (CachyOS)

Use this skill when the user wants to run Windows inside VirtualBox on CachyOS/Linux, especially for USB-dependent tasks like Xiaomi Mi Unlock, device flashing, or Windows-only software.

## Pre-flight Checks

1. **CPU virtualization support:**
   ```bash
   lscpu | grep -i virtualization
   ```
   Expected output: `VT-x` (Intel) or `AMD-V` (AMD).

2. **RAM and disk space:**
   ```bash
   free -h
   df -h /home
   ```
   Windows 11 needs at least 8 GB RAM (recommended) and 80 GB disk.

## 1. Install VirtualBox & Extension Pack

```bash
# Install VirtualBox and DKMS host modules
sudo pacman -S --needed virtualbox virtualbox-host-dkms

# Load the kernel module
sudo modprobe vboxdrv

# Add user to vboxusers group (REQUIRED for USB passthrough)
sudo usermod -aG vboxusers "$USER"
```

**Important:** Log out and log back in after adding yourself to `vboxusers`. USB passthrough will not work until you do.

## 2. Download Windows 11 ISO

Navigate to Microsoft's download page and grab the official consumer ISO:
- URL: `https://www.microsoft.com/en-us/software-download/windows11`
- Select: **Download Windows 11 Disk Image (ISO) for x64 devices**
- Edition: `Windows 11 (multi-edition ISO)`
- Language: `English International` or preferred
- Architecture: `64-bit Download`

Save the ISO to a known location, e.g. `~/VMs/`.

## 3. Create the VM via CLI

```bash
VM_NAME="Windows 11"
ISO_PATH="$HOME/VMs/Win11_25H2_EnglishInternational_x64.iso"
DISK_PATH="$HOME/VMs/Windows 11.vdi"

# Create and register VM
vboxmanage createvm --name "$VM_NAME" --ostype Windows11_64 --register

# Configure hardware
vboxmanage modifyvm "$VM_NAME" \
  --memory 8192 \
  --cpus 4 \
  --vram 128 \
  --acpi on \
  --ioapic on \
  --firmware efi \
  --boot1 dvd \
  --boot2 disk

# Create virtual disk (80 GB)
vboxmanage createhd --filename "$DISK_PATH" --size 81920 --variant Standard

# Add SATA controller and attach disk + ISO
vboxmanage storagectl "$VM_NAME" --name "SATA Controller" --add sata --controller IntelAhci --portcount 2
vboxmanage storageattach "$VM_NAME" --storagectl "SATA Controller" --port 0 --device 0 --type hdd --medium "$DISK_PATH"
vboxmanage storageattach "$VM_NAME" --storagectl "SATA Controller" --port 1 --device 0 --type dvddrive --medium "$ISO_PATH"

# Enable USB 3.0
vboxmanage modifyvm "$VM_NAME" --usb on --usbxhci on
```

## 4. Install Extension Pack (Required for USB 3.0)

```bash
VERSION=$(vboxmanage --version | cut -d'r' -f1)
cd /tmp
curl -O "https://download.virtualbox.org/virtualbox/${VERSION}/Oracle_VirtualBox_Extension_Pack-${VERSION}.vbox-extpack"

# Install non-interactively
yes | sudo vboxmanage extpack install --replace "/tmp/Oracle_VirtualBox_Extension_Pack-${VERSION}.vbox-extpack"
```

Verify installation:
```bash
vboxmanage list extpacks
```

## 5. USB Device Filter (Xiaomi/Redmi)

After logging out and back into your session (so the `vboxusers` group is active), add a USB filter so the Mi Unlock tool can see the phone automatically:

```bash
vboxmanage usbfilter add 0 --target "Windows 11" --name "Xiaomi/Redmi Phone" --vendorid 2717 --active yes
```

If you want to filter by a specific device model instead of vendor-wide, connect the phone in fastboot or regular mode and run:

```bash
vboxmanage list usbhost
```

then create a more specific filter using `--productid` as well.

## 6. Start the VM

GUI mode:
```bash
VirtualBoxVM --startvm "Windows 11"
```

Or start from the VirtualBox Manager GUI.

## Troubleshooting

| Symptom | Fix |
|---------|-----|
| `vboxdrv` not loaded | `sudo modprobe vboxdrv` |
| USB not showing in VM | Log out and back in; verify `vboxusers` membership with `groups` |
| Extension pack won't install | Make sure version matches `vboxmanage --version` |
| Windows 11 setup says "This PC can't run Windows 11" | Enable EFI (`--firmware efi`), ensure 4+ GB RAM, or bypass TPM check in registry during install |
| Slow VM performance | Enable 3D acceleration or allocate more CPUs |

## Quick Reference

```bash
# Check VM info
vboxmanage showvminfo "Windows 11"

# List running VMs
vboxmanage list runningvms

# Power off gracefully
vboxmanage controlvm "Windows 11" acpipowerbutton

# Force power off
vboxmanage controlvm "Windows 11" poweroff
```
