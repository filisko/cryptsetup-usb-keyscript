#!/bin/bash
# Call with `sudo bash DEBUG=1 ./crypt-fix.sh` for verbose output
[ -n "$DEBUG"] && set -x
# Prompt user for device from /dev/sd* /dev/nvme* /dev/mmc* prefixes?
# For /dev/sda probably sda1 is EFI and sda2 is boot and sda3 is encrypted
DEVICE=/dev/nvme0n1
EFIPATH="${DEVICE}p1"
BOOTPATH="${DEVICE}p2"
CRYPTPATH="${DEVICE}p3"
TARGETPATH=/mnt

# Need root for mounting stuff
if ! (( $EUID == 0 )); then echo "Please run with `sudo $0`"; fi

clear_mounts () {
    # Clears mounts in case of interrupt or upon exit to allow running script multiple times
    umount $TARGETPATH/boot/efi
    umount $TARGETPATH/boot
    umount $TARGETPATH/proc
    umount $TARGETPATH/dev
    umount $TARGETPATH/run
    umount $TARGETPATH/sys
    umount $TARGETPATH
    vgchange -an
    cryptsetup close nvme0n1p3_crypt
    cryptsetup close $CRYPTNAME
    set +x
}
trap clear_mounts INT EXIT

cryptsetup open $CRYPTPATH nvme0n1p3_crypt
vgchange -ay
# Can't get this until LVM devices are scanned above
ROOTPATH=$(ls /dev/mapper/* | grep root)
# Make sure nothing else is mounted on our $TARGETPATH
umount $TARGETPATH
wait
mount $ROOTPATH $TARGETPATH
# Find the name that is required for `update-initramfs` to properly update things
CRYPTNAME=$(cat $TARGETPATH/etc/crypttab | awk '/^[ ]*[^#]/ { print $1; exit }')
umount $TARGETPATH
vgchange -an
cryptsetup close nvme0n1p3_crypt
# This proper name is required for `update-initramfs` to properly update things
cryptsetup open $CRYPTPATH $CRYPTNAME
wait
vgchange -ay
ROOTPATH=$(ls /dev/mapper/* | grep root)
mount $ROOTPATH $TARGETPATH
mount $BOOTPATH $TARGETPATH/boot
mount $EFIPATH $TARGETPATH/boot/efi
mount -t proc proc $TARGETPATH/proc
mount -o bind /dev $TARGETPATH/dev
mount -t sysfs sys $TARGETPATH/sys
mount -o bind /run $TARGETPATH/run

# Have also seen people mounting dev/pts and run and sys, they don't appear to be necessary

chroot $TARGETPATH update-initramfs -c -k all
echo "Completed crypt-fix, try rebooting and you should get prompted for your passphrase after grub"
