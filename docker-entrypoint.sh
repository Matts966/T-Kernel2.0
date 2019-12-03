#!/bin/bash
./qemu/qemu-img create -f raw sd.img 1G && \
    DEV=$(losetup -f) && losetup $DEV sd.img && \
    mkfs.ext4 $DEV && mkdir root && mount $DEV root && \
    cp sd/* root && umount root && losetup -d $DEV
SD=sd.img # ${1:-/usr/local/srcpkg/tool/qemu/bin/rom.bin}
echo "SD size: $(wc -c $SD)"
./qemu/arm-softmmu/qemu-system-arm \
    -M raspi2 -m 3M -serial stdio \
    -hdb fat:sd:rw:/usr/local/sd
    # -drive file=$SD,index=0,media=disk,format=raw \
    # -rtc base=localtime #-drive file=/usr/local/sd.img,index=0x70020000,media=disk,format=raw #\
#     -serial tcp:0.0.0.0:$PORT,server &
# sleep 3
# /usr/local/srcpkg/tool/Linux-i686/etc/gterm -l localhost:$PORT
