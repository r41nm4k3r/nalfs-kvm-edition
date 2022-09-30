# Nlfs Kvm Edition

## Description

Create qcow2 image for KVM (QEMU) of LFS 11.1 x86_64 systemd or sysvinit.

The goal of this script is to substitute the alfs procedure.

## Features

* Downloads all code automatically
* Creates qcow2 image
* Builds LFS 11.1
* Supports systemd or sysvinit
* Can be resumed from almost every step

## Prerequisites

* Linux
    - Debian 11 (tested and working)
    - Red Hat 8.6 (tested and working)
    - Arch Linux (tested partialy and working)
* QEMU

## Usage

* First run 02-version-check.sh and confirm all software with the book.
* Then run lfs-kvm.sh to make lfs qcow2 image.

```
If for some reason the sript stop
./lfs-builder.sh [start-chapter]
```
`start-chapter` - from which chapter (to continue) building

### How to choose init system:

Modify variable KVM_LFS_INIT in lfs-kvm.sh.

Supported values:
```
systemd
sysvinit
```

## Side Effects

### Permanent:

* Creates lfs user
* Creates lfs group
* Creates `/mnt/lfs` directory

### Temporary:

During build:

* Mounts `/mnt/lfs`
* Mounts temporary filesystems
* Connects nbd device to qcow2 image

## Difference compared to ALFS

* Builds version 11.1 (latest version ALFS supports is 8.0)
* Uses shell scripts directly (ALFS extracts build instructions from LFS
    sources)

