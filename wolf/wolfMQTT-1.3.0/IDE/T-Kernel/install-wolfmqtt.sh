#!/bin/sh

DIR=${PWD##*/}
if [ "$DIR" = "T-Kernel" ]; then
    rm -rf wolfMQTT

    mkdir wolfMQTT
    cp ../../src/*.c ./wolfMQTT

    mkdir wolfMQTT/wolfmqtt
    cp ../../wolfmqtt/*.h ./wolfMQTT/wolfmqtt
else
    echo "ERROR: You must be in the IDE/T-Kernel directory to run this script"
fi
