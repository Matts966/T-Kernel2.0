#!/bin/bash
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
if [[ $4 = "true" ]]; then
    VNC="-vnc 0.0.0.0:0 -tp xmin=944,xmax=64,ymin=912,ymax=80,xchg=on"
else
    VNC=""
fi

# This line creates a random MAC address. The downside is the DHCP server will assign a different IP address each time
printf -v macaddr "52:54:%02x:%02x:%02x:%02x" $(( $RANDOM & 0xff)) $(( $RANDOM & 0xff )) $(( $RANDOM & 0xff)) $(( $RANDOM & 0xff ))
# Instead, uncomment and edit this line to set a static MAC address. The benefit is that the DHCP server will assign the same IP address.
# macaddr='52:54:be:36:42:a9'

./qemu-tef_em1d \
-cpu arm1176jzf-s \
-kernel ${1:-/usr/local/tef_em1d/tool/qemu/bin/rom.bin} \
-sd ${2:-/usr/local/tef_em1d/tool/qemu/bin/sd.img} \
-rtc base=localtime \
-serial tcp:0.0.0.0:${3:-10000},server $VNC \
-net nic,macaddr=$macaddr \
-net tap,ifname=tap0,script=no,downscript=no \
$5 $6 $7 $8
