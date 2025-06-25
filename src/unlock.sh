#!/bin/sh
# This scrip is licensed under the MIT License
#
# Copyright (c) 2025 Filis Futsarov (www.filis.me)
#
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in all
# copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
# SOFTWARE.

echo_kernel() {
    echo "unlock.sh: $1" > /dev/kmsg
}

ask_for_password () {
    cryptkey="Enter the passphrase: "

    if [ -x /bin/plymouth ] && plymouth --ping; then
        cryptkeyscript="plymouth ask-for-password --prompt"
    else
        cryptkeyscript="/lib/cryptsetup/askpass"
    fi

    $cryptkeyscript "$cryptkey"
}

MARKER="Attempt #"
RETRY_COUNT=$(dmesg | grep -c "$MARKER" &> /dev/null)
RETRY_COUNT=$((RETRY_COUNT + 1))

if [ $RETRY_COUNT -eq 4 ]; then
    echo_kernel "Max retries (3) reached. Proceeding to ask for manually entering the password."
    ask_for_password
    exit 1
else
    echo_kernel "$MARKER$RETRY_COUNT"
fi

MOUNTPOINT="/mnt/unlock-usb"
DEVICE=$(printf $1 | cut -d: -f1)
KEYFILE=$(printf $1 | cut -d: -f2)

# wait for the USB device to appear (up to 10 seconds)
for i in $(seq 1 3); do
    if [ -b "$DEVICE" ]; then
        break
    fi
    sleep 1
done

# if device couldn't be found, ask for password
if [ ! -b "$DEVICE" ]; then
    echo_kernel "Device for decryption not found: $DEVICE"
    echo_kernel "Proceeding to ask for manually entering the password"
    ask_for_password
    exit 1
fi

# if device couldn't be mounted, ask for password
mkdir -p "$MOUNTPOINT"
mount "$DEVICE" "$MOUNTPOINT" 2>/dev/null

if [ $? -ne 0 ]; then
    echo_kernel "Failed to mount device: $DEVICE at $MOUNTPOINT"
    echo_kernel "Proceeding to ask for manually entering the password"
    ask_for_password
    exit 1
fi

if [[ ! -f "$MOUNTPOINT$KEYFILE" ]]; then
    echo_kernel "No keyfile found at: $MOUNTPOINT$KEYFILE"
    echo_kernel "Proceeding to ask for manually entering the password"
    ask_for_password
    exit 1
fi

echo_kernel "Using keyfile: $MOUNTPOINT$KEYFILE"

# output the key to stdout
# printf "this is wrong"
cat "$MOUNTPOINT$KEYFILE"

# clean up
umount -l "$MOUNTPOINT"
rmdir "$MOUNTPOINT"

