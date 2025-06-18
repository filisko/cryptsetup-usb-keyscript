#!/bin/bash

# dm_crypt-0 UUID=bd5bf7de-15a1-4183-b4d4-71b7a5d3c246 /dev/disk/by-uuid/28D6-838D:/luks.key discard,keyscript=/home/filis/here.sh,tries=3

# openssl genrsa -out - 4096

dd if=/dev/urandom of=y bs=4096 count=1

dsdump ls

dm_crypt-0	(252:0)
ubuntu--vg-ubuntu--lv	(252:1)