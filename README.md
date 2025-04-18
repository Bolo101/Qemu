# QEMU Complete Guide

This guide covers installation, image management, and VM execution with QEMU, a powerful open-source machine emulator and virtualizer.

## Installation

### Method 1: Using the Repository

```bash
git clone https://github.com/Bolo101/Qemu.git
cd Qemu
chmod +x installQemu.sh
sudo bash installQemu.sh
```

### Method 2: Direct Package Installation

For Debian/Ubuntu:
```bash
sudo apt update
sudo apt install qemu-system qemu-utils
```

For Fedora/RHEL:
```bash
sudo dnf install qemu-kvm qemu-img
```

For Arch Linux:
```bash
sudo pacman -S qemu-full
```

## Image Management

### Creating Disk Images

#### Create a basic qcow2 image
```bash
qemu-img create -f qcow2 image_name.qcow2 10G
```

#### Create an optimized qcow2 image with metadata preallocation
```bash
qemu-img create -f qcow2 -o preallocation=metadata image_name.qcow2 10G
```

Metadata preallocation balances image compression and performance by allocating all metadata upfront while keeping the actual data sparse. This improves performance while maintaining reasonable file sizes.

### Compressing Images

```bash
qemu-img convert -O qcow2 -c source.qcow2 compressed.qcow2 -p
```

The `-p` flag shows progress during conversion, while `-c` enables compression.

Benefits of compression:
- Reduces physical disk space usage
- Improves transfer efficiency when moving VMs
- Optimizes storage without affecting VM performance

### Converting Images Between Formats

#### VHD to QCOW2
```bash
qemu-img convert -f vpc -O qcow2 source.vhd destination.qcow2
```

#### VMDK to QCOW2
```bash
qemu-img convert -f vmdk -O qcow2 source.vmdk destination.qcow2
```

#### RAW to QCOW2
```bash
qemu-img convert -f raw -O qcow2 source.img destination.qcow2
```

### Inspecting Images

Display image information:
```bash
qemu-img info image_name.qcow2
```

Check image for corruption:
```bash
qemu-img check image_name.qcow2
```

## Running Virtual Machines

### Basic VM Launch

```bash
qemu-system-x86_64 -m 2048 -smp 2 -boot d -drive file=debian12.qcow2,format=qcow2 -net nic -net user -enable-kvm
```

Parameters explained:
- `-m 2048`: Allocate 2GB of RAM
- `-smp 2`: Use 2 CPU cores
- `-boot d`: Boot from the first CD-ROM drive
- `-drive file=debian12.qcow2,format=qcow2`: Specify the disk image and format
- `-net nic -net user`: Setup user-mode networking with NAT
- `-enable-kvm`: Use KVM hardware acceleration (requires KVM support on host)

### VM with USB Device

```bash
qemu-system-x86_64 -m 2048 -smp 2 -boot d \
  -drive file=debian12.qcow2,format=qcow2 \
  -drive file=flash_device.img,format=raw,if=none,id=flash \
  -device usb-ehci,id=ehci \
  -device usb-storage,bus=ehci.0,drive=flash \
  -net nic -net user -enable-kvm
```

This configuration:
- Creates a USB 2.0 controller with `-device usb-ehci,id=ehci`
- Attaches a flash drive image with `-device usb-storage,bus=ehci.0,drive=flash`

### Creating a USB Flash Drive Image

```bash
qemu-img create -f raw flash_device.img 4G
```

### VM with Graphics and Sound

```bash
qemu-system-x86_64 -m 4096 -smp 4 \
  -drive file=windows10.qcow2,format=qcow2 \
  -vga virtio \
  -display gtk,gl=on \
  -device ac97 \
  -enable-kvm
```

Parameters:
- `-vga virtio`: Use the VirtIO GPU driver (better performance)
- `-display gtk,gl=on`: Use GTK display with OpenGL acceleration
- `-device ac97`: Add sound card emulation

### VM with Networking Options

#### Port Forwarding (Access VM's port 80 on host's port 8080)
```bash
qemu-system-x86_64 -m 2048 -smp 2 \
  -drive file=debian12.qcow2,format=qcow2 \
  -net nic \
  -net user,hostfwd=tcp::8080-:80 \
  -enable-kvm
```

#### Bridge Networking (Requires setup on host)
```bash
qemu-system-x86_64 -m 2048 -smp 2 \
  -drive file=debian12.qcow2,format=qcow2 \
  -netdev bridge,br=br0,id=net0 \
  -device virtio-net-pci,netdev=net0 \
  -enable-kvm
```

## Advanced Operations

### Resizing Disk Images

Increase disk size to 20GB:
```bash
qemu-img resize image_name.qcow2 20G
```

Note: This only resizes the container. You'll need to adjust partitions from within the VM.

### Creating Snapshots

Create a snapshot:
```bash
qemu-img snapshot -c snapshot_name image_name.qcow2
```

List all snapshots:
```bash
qemu-img snapshot -l image_name.qcow2
```

Apply a snapshot:
```bash
qemu-img snapshot -a snapshot_name image_name.qcow2
```

### Creating a Backup

```bash
qemu-img convert -O qcow2 -c source.qcow2 backup_$(date +%Y%m%d).qcow2 -p
```

This creates a compressed backup with the current date in the filename.

## Debugging and Troubleshooting

Check system KVM support:
```bash
kvm-ok
```

Verify QEMU version:
```bash
qemu-system-x86_64 --version
```

Monitor disk space usage:
```bash
du -sh *.qcow2
```

Monitor VM performance (within QEMU monitor):
1. Press `Ctrl+Alt+2` to access the monitor
2. Type `info status` to see VM state
3. Press `Ctrl+Alt+1` to return to VM

## Common Issues and Solutions

### Slow VM Performance
- Ensure KVM is enabled with `-enable-kvm`
- Use virtio drivers for storage and networking
- Allocate adequate memory and CPU cores

### USB Device Not Detected
- Check that USB controller is properly configured
- Ensure USB device image is properly formatted
- Try different USB controller types (ohci, uhci, ehci, xhci)

### Network Connectivity Issues
- Check firewall settings on host
- Verify network configuration in VM
- Try different network models (virtio-net-pci recommended)