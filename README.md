Install Qemu and Linux systems

# Clone the repo locally
```bash
git clone https://github.com/Bolo101/Qemu.git
```
# Execute script
```
cd Qemu
chmod +x install.sh
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
qemu-img convert -O qcow2 -c source.qcow2 compressed.qcow2
```
## Convert files from vhd to qcow2

```bash
qemu-img convert -O qcow2 -c source.qcow2 compressed.qcow2
```
