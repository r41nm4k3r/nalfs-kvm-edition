#!/bin/bash

set -e
set -v

cd /
cd /sources

mkdir -vp /etc/systemd/network
cat > /etc/systemd/network/10-eth-static.network << "EOF"
[Match]
Name=ens0

[Network]
Address=192.168.122.12
Gateway=192.168.122.1
Domains=lfs10
EOF

cat > /etc/systemd/network/10-eth-dhcp.network << "EOF"
[Match]
Name=ens0

[Network]
DHCP=ipv4

[DHCP]
UseDomains=true
EOF
	#ln -sfv /run/systemd/resolve/resolv.conf /etc/resolv.conf

cat > /etc/resolv.conf << "EOF"
# Begin /etc/resolv.conf

nameserver 1.1.1.1
nameserver 1.0.0.1

# End /etc/resolv.conf
EOF

echo "lfs11.2" > /etc/hostname

cat > /etc/hosts << "EOF"
# Begin /etc/hosts

127.0.0.1 localhost.localdomain localhost
127.0.1.1 lfs10.example.org lfs10
192.168.122.12 lfs10.example.org lfs10
::1 localhost ip6-localhost ip6-loopback
ff02::1 ip6-allnodes
ff02::2 ip6-allrouters

# End /etc/hosts
EOF

mkdir -pv /etc/modprobe.d
echo "blacklist forte" >> /etc/modprobe.d/blacklist.conf

cat > /etc/locale.conf << "EOF"
LANG=en_US.ISO-8859-1
EOF

cat > /etc/inputrc << "EOF"
# Begin /etc/inputrc
# Modified by Chris Lynn <roryo@roryo.dynup.net>

# Allow the command prompt to wrap to the next line
set horizontal-scroll-mode Off

# Enable 8-bit input
set meta-flag On
set input-meta On

# Turns off 8th bit stripping
set convert-meta Off

# Keep the 8th bit for display
set output-meta On

# none, visible or audible
set bell-style none

# All of the following map the escape sequence of the value
# contained in the 1st argument to the readline specific functions
"\eOd": backward-word
"\eOc": forward-word

# for linux console
"\e[1~": beginning-of-line
"\e[4~": end-of-line
"\e[5~": beginning-of-history
"\e[6~": end-of-history
"\e[3~": delete-char
"\e[2~": quoted-insert

# for xterm
"\eOH": beginning-of-line
"\eOF": end-of-line

# for Konsole
"\e[H": beginning-of-line
"\e[F": end-of-line

# End /etc/inputrc
EOF

cat > /etc/shells << "EOF"
# Begin /etc/shells

/bin/sh
/bin/bash

# End /etc/shells
EOF

mkdir -pv /etc/systemd/coredump.conf.d
cat > /etc/systemd/coredump.conf.d/maxuse.conf << EOF
[Coredump]
MaxUse=5G
EOF
	#loginctl enable-linger
	echo "KillUserProcesses=no" >> /etc/systemd/logind.conf

cat > /etc/fstab << "EOF"
# Begin /etc/fstab

# file system  mount-point  type      options               dump  fsck
#                                                                 order

/dev/vda1      /            ext4      defaults              1     1
/dev/vda2      swap         swap      pri=1                 0     0
EOF

cat >> /etc/fstab << "EOF"

# End /etc/fstab
EOF

cd /
cd /sources
tar -xf linux-5.19.2.tar.xz
cd linux-5.19.2
make mrproper
zcat /proc/config.gz > .config
yes '' | make oldconfig
sed -e 's/.*\bCONFIG_UEVENT_HELPER\b.*/# CONFIG_UEVENT_HELPER is not set (required by LFS)/' -i .config
sed -e 's/.*\bCONFIG_DEVTMPFS\b.*/CONFIG_DEVTMPFS=y/' -i .config
sed -e 's/.*\bCONFIG_EFI_STUB\b.*/CONFIG_EFI_STUB=y/' -i .config
sed -e 's/.*\bCONFIG_EXT4_FS\b.*/CONFIG_EXT4_FS=y/' -i .config
sed -e 's/.*\bCONFIG_VIRTIO_BLK\b.*/CONFIG_VIRTIO_BLK=y/' -i .config
sed -e 's/.*\bCONFIG_SCSI_VIRTIO\b.*/CONFIG_SCSI_VIRTIO=y/' -i .config
sed -e 's/.*\bCONFIG_VIRTIO_CONSOLE\b.*/CONFIG_VIRTIO_CONSOLE=y/' -i .config
sed -e 's/.*\bCONFIG_VIRTIO_PCI\b.*/CONFIG_VIRTIO_PCI=y/' -i .config

	sed -e 's/.*\bCONFIG_CGROUPS\b.*/CONFIG_CGROUPS=y/' -i .config
	sed -e 's/.*\bCONFIG_SYSFS_DEPRECATED\b.*/# CONFIG_SYSFS_DEPRECATED is not set (required by LFS)/' -i .config
	sed -e 's/.*\bCONFIG_EXPERT\b.*/CONFIG_EXPERT=y/' -i .config
	sed -e 's/.*\bCONFIG_FHANDLE\b.*/CONFIG_FHANDLE=y/' -i .config
	sed -e 's/.*\bCONFIG_AUDIT\b.*/# CONFIG_AUDIT is not set (required by LFS)/' -i .config
	sed -e 's/.*\bCONFIG_SECCOMP\b.*/CONFIG_SECCOMP=y/' -i .config
	sed -e 's/.*\bCONFIG_DMIID\b.*/CONFIG_DMIID=y/' -i .config
	sed -e 's/.*\bCONFIG_IPV6\b.*/CONFIG_IPV6=y/' -i .config
	sed -e 's/.*\bCONFIG_FW_LOADER_USER_HELPER\b.*/# CONFIG_FW_LOADER_USER_HELPER is not set (required by LFS)/' -i .config
	sed -e 's/.*\bCONFIG_INOTIFY_USER\b.*/CONFIG_INOTIFY_USER=y/' -i .config
	sed -e 's/.*\bCONFIG_AUTOFS_FS\b.*/CONFIG_AUTOFS_FS=y/' -i .config
	sed -e 's/.*\bCONFIG_TMPFS_POSIX_ACL\b.*/CONFIG_TMPFS_POSIX_ACL=y/' -i .config
	sed -e 's/.*\bCONFIG_TMPFS_XATTR\b.*/CONFIG_TMPFS_XATTR=y/' -i .config
make kernelversion
make kernelrelease
make
make modules_install
cp -iv arch/x86/boot/bzImage /boot/vmlinuz-5.19.2-lfs-11.2-systemd
cp -iv System.map /boot/System.map-5.19.2
cp -iv .config /boot/config-5.19.2
install -d /usr/share/doc/linux-5.19.2
cp -r Documentation/* /usr/share/doc/linux-5.19.2
chown -R 0:0 .
install -v -m755 -d /etc/modprobe.d
cat > /etc/modprobe.d/usb.conf << "EOF"
# Begin /etc/modprobe.d/usb.conf

install ohci_hcd /sbin/modprobe ehci_hcd ; /sbin/modprobe -i ohci_hcd ; true
install uhci_hcd /sbin/modprobe ehci_hcd ; /sbin/modprobe -i uhci_hcd ; true

# End /etc/modprobe.d/usb.conf
EOF

grub-install --target i386-pc --force /dev/nbd0

cat > /boot/grub/grub.cfg << "EOF"
# Begin /boot/grub/grub.cfg

set default=0
set timeout=5

insmod ext2
set root=(hd0,gpt1)

menuentry "GNU/Linux, Linux 5.19.2-lfs-11.2" {
        linux   /boot/vmlinuz-5.19.2-lfs-11.2 loglevel=7 root=/dev/vda1 ro
}
EOF

echo 10.0 > /etc/lfs-release
cat > /etc/lsb-release << "EOF"
DISTRIB_ID="Linux From Scratch"
DISTRIB_RELEASE="11.1"
DISTRIB_CODENAME="Nnyx"
DISTRIB_DESCRIPTION="Linux From Scratch"
EOF

cat > /etc/os-release << "EOF"
NAME="Linux From Scratch"
VERSION="11.1"
ID=lfs
PRETTY_NAME="Linux From Scratch Nny-Kvm Edition"
VERSION_CODENAME="Nny-Kvm Edition"
EOF

logout
