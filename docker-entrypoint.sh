#!/bin/bash
./qemu.sh /usr/local/tef_em1d/tkernel_source/bin/tef_em1d/rom.bin sd.img &
sleep 3
/usr/local/tef_em1d/tool/Linux-i686/etc/gterm -l localhost:10000
