Install Qemu and Linux systems

# Clone the repo locally
```bash
git clone https://github.com/Bolo101/Qemu.git
```
# Execute script
```
cd Qemu
chmod +x installQemu.sh
sudo bash install.sh
```

# Useful commands

## Create qcow2 image w

This command enables to balance image compression and performance

```bash
qemu-img create -f qcow2 -o preallocation=metadata image_name.qcow2 'IMAGE_SIZE'G
```

## Compress qcow2 image

```bash
qemu-img convert -O qcow2 -c source.qcow2 compressed.qcow2 -p
```

Compression reduces the disk size of the virtual image, optimizing storage efficiency.
It also enhances transfer performance by minimizing the amount of disk size data that needs to be moved, rather than transferring the entire virtual size data.

## Convert files from vhd to qcow2

```bash
qemu-img convert -f vpc -O qcow2 source.vhd compressed.qcow2
```

## Launch using CLI

```bash
qemu-system-x86_64   -m 2048   -smp 2   -boot d  -drive file=debian12.qcow2,format=qcow2   -drive file=flash_device.img,format=raw,if=none,id=flash   -device usb-ehci,id=ehci   -device usb-storage,bus=ehci.0,drive=flash   -net nic   -net user   -enable-kvm
```
