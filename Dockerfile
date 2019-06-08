FROM ubuntu:12.04
RUN echo "foreign-architecture i386" > /etc/dpkg/dpkg.cfg.d/multiarch
RUN apt-get update && apt-get install -y make gcc libc6:i386 libncurses5:i386 libstdc++6:i386 libbluetooth3:i386 libz1:i386 zlib1g-dev
RUN mkdir -p /usr/local/tef_em1d/tool/qemu/bin
COPY emulator/tef_em1d/Linux/* /usr/local/tef_em1d/tool/qemu/bin/
COPY emulator/tef_em1d/Image/* /usr/local/tef_em1d/tool/qemu/bin/
ADD emulator/tef_em1d/build/qemu-0.12.4-tef_em1d.tar.gz /usr/local/tef_em1d/tool/qemu/ 
WORKDIR /usr/local/tef_em1d/tool/qemu/qemu-0.12.4-tef_em1d
RUN ./configure --target-list=arm-softmmu --disable-blobs --prefix=/usr/local/tef_em1d/tool/qemu
RUN make install
RUN mv /usr/local/tef_em1d/tool/qemu/bin/qemu-system-arm /usr/local/tef_em1d/tool/qemu/bin/qemu-tef_em1d
COPY docker-entrypoint.sh /usr/local/tef_em1d/tool/qemu/bin/
RUN chmod +x /usr/local/tef_em1d/tool/qemu/bin/docker-entrypoint.sh
ADD develop/te.Linux-i686.common.15.tar.gz /usr/local/tef_em1d/
ADD develop/te.Linux-i686.arm_2.1.0.3.tar.gz /usr/local/tef_em1d/

# Use COPY instead of ADD for building kernel.
COPY srcpkg/tkernel_source /usr/local/tef_em1d/tkernel_source
WORKDIR /usr/local/tef_em1d/tkernel_source/kernel/sysmain/build/tef_em1d
RUN GNU_BD=/usr/local/tef_em1d/tool/Linux-i686 GNUARM_2=$GNU_BD/arm_2-unknown-tkernel BD=/usr/local/tef_em1d/tkernel_source GCC_EXEC_PREFIX=$GNU_BD/lib/gcc/ GNUarm_2=$GNU_BD/arm_2-unknown-tkernel make emu

WORKDIR /usr/local/tef_em1d/tool/qemu/bin/
ENTRYPOINT [ "./docker-entrypoint.sh" ]
