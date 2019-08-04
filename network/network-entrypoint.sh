#!/bin/bash
brctl addbr br0 && \
    brctl addif br0 eth0 && \
    # ip link set up dev br0 && \
    brctl show && \
    # ifconfig br0 192.168.2.1 && \
    # ifconfig br0 && \
    tunctl -u $(whoami) && \
    ifconfig tap0 0.0.0.0 promisc up && \
    brctl addif br0 tap0 && \
    ip link set up dev tap0 && \
    brctl show && ifconfig && ip a
make run