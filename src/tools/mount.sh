#!/bin/bash

# debe ser el valor dentro de crypttab (LUKS device name)
cryptsetup luksOpen /dev/nvme0n1p3 cryptdata

vgscan --mknodes
vgchange -ay

mkdir here

mount /dev/mapper/vgubuntu-root here

mount /dev/nvme0n1p2 here/boot
mount /dev/nvme0n1p1 here/boot/efi

mount -t proc proc here/proc
mount -t sysfs sys here/sys
mount -o bind /dev here/dev
mount -t devpts pts here/dev/pts
mount -o bind /run here/run

chroot here /bin/bash

 
