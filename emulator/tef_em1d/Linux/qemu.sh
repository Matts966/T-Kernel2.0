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

USERID=$(whoami)
# Get name of newly created TAP device; see https://bbs.archlinux.org/viewtopic.php?pid=1285079#p1285079
precreationg=$(ip tuntap list | cut -d: -f1 | sort)
ip tuntap add user $USERID mode tap
postcreation=$(ip tuntap list | cut -d: -f1 | sort)
IFACE=$(comm -13 <(echo "$precreationg") <(echo "$postcreation"))
# This line creates a random MAC address. The downside is the DHCP server will assign a different IP address each time
printf -v macaddr "52:54:%02x:%02x:%02x:%02x" $(( $RANDOM & 0xff)) $(( $RANDOM & 0xff )) $(( $RANDOM & 0xff)) $(( $RANDOM & 0xff ))
# Instead, uncomment and edit this line to set a static MAC address. The benefit is that the DHCP server will assign the same IP address.
# macaddr='52:54:be:36:42:a9'

SWITCH=br0
ip link add $SWITCH type bridge
ip link set eth0 master $SWITCH

cat <<EOF > /etc/network/interfaces
auto lo
iface lo inet loopback

auto eth0
iface eth0 inet manual

iface br0 inet dhcp
bridge_ports eth0
bridge_stp off
auto br0
EOF

ifdown eth0 && ifup eth0
ifup br0

IP_ADDRESS=192.168.1.60/24
NICS="eth0 "
NICS+=$IFACE
brctl addbr $SWITCH
brctl stp $SWITCH off
ip addr add $IP_ADDRESS dev $SWITCH
for NIC in $NICS
do
    ip addr flush dev $NIC
    brctl addif $SWITCH $NIC
    ip link set dev $NIC promisc on
    ip link set dev $NIC up
done
ip link set dev $SWITCH up

service networking restart

sleep 5

./qemu-tef_em1d \
-cpu arm1176jzf-s \
-kernel ${1:-/usr/local/tef_em1d/tool/qemu/bin/rom.bin} \
-sd ${2:-/usr/local/tef_em1d/tool/qemu/bin/sd.img} \
-rtc base=localtime \
-serial tcp:0.0.0.0:${3:-10000},server $VNC \
-net nic,macaddr=$macaddr \
-net tap,ifname="$IFACE" \
$5 $6 $7 $8

ip link set dev $IFACE down &> /dev/null
ip tuntap del $IFACE mode tap &> /dev/null
