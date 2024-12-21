#/bin/bash
#> /etc/apt/sources.list

    # Add the new repositories to /etc/apt/sources.list
    #echo "deb http://ftp.debian.org/debian bookworm main contrib" >> /etc/apt/sources.list
    #echo "deb http://ftp.debian.org/debian bookworm-updates main contrib" >> /etc/apt/sources.list
    #echo "deb http://security.debian.org/debian-security bookworm-security main contrib" >> /etc/apt/sources.list
#export PATH=$PATH:/usr/sbin:/sbin
apt update
apt full-upgrade -y
apt install qemu-kvm libvirt-daemon bridge-utils virt-manager -y
useradd -g $USER libvirt
useradd -g $USER libvirt-kvm
systemctl enable libvirtd && sudo systemctl start libvirtd


