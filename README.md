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

## Compress qcow2 image

```bash
qemu-img convert -O qcow2 -c source.qcow2 compressed.qcow2
```
## Convert files from vhd to qcow2

```bash
qemu-img convert -O qcow2 -c source.qcow2 compressed.qcow2
```


