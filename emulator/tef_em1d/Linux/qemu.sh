#!/bin/sh
#
# QEMU-tef_em1d emulator execution
#
# Usage: qemu.sh [<rom.bin> [<sd.img>]]
#
# Start type
#   -dipsw dbgsw=on   : Start T-Monitor only
#   -dipsw dbgsw=off  : Start T-Kernel
#
# Serical port
#   -serial tcp:127.0.0.1:10000,server : TCP port:127.0.0.1:10000
#   -serial pty                        : Use PTY (/dev/pts/*)
#
# LCD display
#   -nographic        : No LCD display
#   -vnc 127.0.0.1:0  : Use VNC server (TCP port: 127.0.0.1:5900)
#
# Touch Panel conversion parameters
#   -tp xmin=944,xmax=64,ymin=912,ymax=80,xchg=on
#
# Use gdb Debugger (TCP port: 127.0.0.1:1234)
#   -S                : Wait for gdb connection
#   -gdb tcp:127.0.0.1:1234
#
if [ $4 = "true" ]; then
    VNC="-vnc 0.0.0.0:0 -tp xmin=944,xmax=64,ymin=912,ymax=80,xchg=on"
else
    VNC=""
fi

./qemu-tef_em1d \
-cpu arm1176jzf-s \
-kernel ${1:-/usr/local/tef_em1d/tool/qemu/bin/rom.bin} \
-sd ${2:-/usr/local/tef_em1d/tool/qemu/bin/sd.img} \
-rtc base=localtime \
-serial tcp:0.0.0.0:${3:-10000},server $VNC \
# -net user \
$5 $6 $7 $8
