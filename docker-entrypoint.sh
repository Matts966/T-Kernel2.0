#!/bin/bash
./qemu.sh ${1:-/usr/local/tef_em1d/tool/qemu/bin/rom.bin} sd.img > /dev/null &
sleep 3
/usr/local/tef_em1d/tool/Linux-i686/etc/gterm -l localhost:10000
