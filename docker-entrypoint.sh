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

sysctl net.ipv4.ip_forward=1

cat <<EOF > /etc/qemu-ifup
#!/bin/bash
echo "Executing /etc/qemu-ifup"
echo "Bringing up \$1 for bridged mode..."
ip link set \$1 up promisc on
echo "Adding \$1 to br0..."
brctl addif br0 \$1
sleep 2
EOF
chmod +x /etc/qemu-ifup

cat <<EOF > /etc/qemu-ifdown
#!/bin/bash
echo "Executing /etc/qemu-ifdown"
ip link set \$1 down
brctl delif br0 \$1
ip link delete dev \$1
EOF
chmod +x /etc/qemu-ifdown

./qemu.sh ${2:-/usr/local/tef_em1d/tool/qemu/bin/rom.bin} sd.img $PORT $VNC > /dev/null &
sleep 10
/usr/local/tef_em1d/tool/Linux-i686/etc/gterm -l localhost:$PORT
