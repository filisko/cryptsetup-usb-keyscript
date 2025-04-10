#!/bin/sh

# Simple keyscript for cryptsetup that reads a key file from a USB device by label

# Redirect stdout and stderr Globally
# Save original stdout (FD 1) to FD 3, and stderr (FD 2) to FD 4

# device=$(echo $1 | cut -d: -f1)
# filepath=$(echo $1 | cut -d: -f2)

# # Ask for password if device doesn't exist
# if [ ! -b $device ]; then
#     ask_for_password
#     exit
# fi

ask_for_password () {
    cryptkey="Enter the passphrase: "

    if [ -x /bin/plymouth ] && plymouth --ping; then
        cryptkeyscript="plymouth ask-for-password --prompt"
    else
        cryptkeyscript="/lib/cryptsetup/askpass"
    fi

    $cryptkeyscript "$cryptkey"
}

KEYFILE="/luks.key"
MOUNTPOINT="/mnt/key-usb"

DEVICE="/dev/disk/by-uuid/28D6-838D"

# Wait for the USB device to appear (up to 10 seconds)
for i in $(seq 1 3); do
    echo "$(date) - waiting for USB $i"
    if [ -b "$DEVICE" ]; then
        break
    fi
    sleep 1
done

# if device couldn't be found
if [ ! -b "$DEVICE" ]; then
    echo "$(date) - USB device with label $USB_LABEL not found" 
    ask_for_password
    exit 1
fi

# Mount the USB
mkdir -p "$MOUNTPOINT"
mount "$DEVICE" "$MOUNTPOINT" 2>/dev/null

if [ $? -ne 0 ]; then
    echo "$(date) - Failed to mount USB device" 
    ask_for_password
    exit 1
fi

# Output the key to stdout
cat "$MOUNTPOINT$KEYFILE"

# Clean up
umount "$MOUNTPOINT"
rmdir "$MOUNTPOINT"

echo "$(date) - unlock.sh success"