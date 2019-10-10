#!/bin/bash
function EPHEMERAL_PORT() {
    LOW_BOUND=10000
    RANGE=500
    while true; do
        CANDIDATE=$[$LOW_BOUND + ($RANDOM % $RANGE)]
        (echo "" >/dev/tcp/127.0.0.1/${CANDIDATE}) >/dev/null 2>&1
        if [ $? -ne 0 ]; then
            echo $CANDIDATE
            break
        fi
    done
}
PORT=$(EPHEMERAL_PORT)
VNC=$1
ROM=${2:-/usr/local/srcpkg/tool/qemu/bin/rom.bin}
echo "ROM size: $(wc -c $ROM)"
./qemu.sh $ROM sd.img $PORT $VNC > /dev/null &
sleep 3
/usr/local/srcpkg/tool/Linux-i686/etc/gterm -l localhost:$PORT
