# Nlfs Kvm Edition

## Description

Create qcow2 image for KVM (QEMU) of LFS 11.1 x86_64 systemd or sysvinit.

The goal of this project is to substitute the alfs project which is outdated.


## Important

This project is heavily based on lfs-kvm project by @fedorenchik so pay him a visit @ github.He has some very interesting projects.

## **BIG THANKS** ! ! !

## Features

* Downloads all code automatically
* Creates qcow2 image
* Builds LFS 11.1
* Supports systemd or sysvinit
* Can be resumed from almost every step

## Prerequisites

* Linux
    - Debian 11 (systemd tested and working 100%)
    - Red Hat 8.6 (systemd tested and working 100%)
    - Arch Linux (systemd tested partialy and working)
* QEMU

## Usage

* First run 02-version-check.sh and confirm all software with the book.
* Then run lfs-kvm.sh to make lfs qcow2 image.


If for some reason the sript stops, you can resume by running again the main script followed by the chapter.

`./lfs-kvm.sh` [start-chapter]
```
start-chapter - from which chapter (to continue) building
```
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

You can safely delete the user,group and lfs directory when the script finish:

 - ` Sudo userdel lfs`
 - ` Sudo groupdel lfs`
 - ` Sudo rm -rf /mnt/lfs`

### Temporary:

During build:

* Mounts `/mnt/lfs`
* Mounts temporary filesystems
* Connects nbd device to qcow2 image

## Difference compared to ALFS

* Builds version 11.1 (latest version ALFS supports is 8.0)
* Uses shell scripts directly (ALFS extracts build instructions from LFS
    sources)

