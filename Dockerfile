FROM ubuntu:12.04
RUN echo "foreign-architecture i386" > /etc/dpkg/dpkg.cfg.d/multiarch
RUN apt-get update && apt-get install -y make libc6:i386 libncurses5:i386 libstdc++6:i386 libbluetooth3:i386 libz1:i386 zlib1g-dev
RUN mkdir -p /usr/local/srcpkg/tool/qemu/bin
COPY emulator/tef_em1d/Image/* /usr/local/srcpkg/tool/qemu/bin/
ADD emulator/tef_em1d/build/qemu-0.12.4-tef_em1d.tar.gz /usr/local/srcpkg/tool/qemu/
WORKDIR /usr/local/srcpkg/tool/qemu/qemu-0.12.4-tef_em1d
RUN ./configure --target-list=arm-softmmu --disable-blobs --prefix=/usr/local/srcpkg/tool/qemu
RUN make install
RUN mv /usr/local/srcpkg/tool/qemu/bin/qemu-system-arm /usr/local/srcpkg/tool/qemu/bin/qemu-tef_em1d
ADD develop/te.Linux-i686.common.15.tar.gz /usr/local/srcpkg/
ADD develop/te.Linux-i686.arm_2.1.0.3.tar.gz /usr/local/srcpkg/

COPY docker-entrypoint.sh /usr/local/srcpkg/tool/qemu/bin/
RUN chmod +x /usr/local/srcpkg/tool/qemu/bin/docker-entrypoint.sh
COPY emulator/tef_em1d/Linux/* /usr/local/srcpkg/tool/qemu/bin/

# Use COPY instead of ADD for building kernel.
COPY srcpkg/tkernel_source /usr/local/srcpkg/tkernel_source
COPY T2EX/srcpkg/t2ex_source /usr/local/srcpkg/t2ex_source
RUN cd /usr/local/srcpkg/t2ex_source \
    && cp -r * ../tkernel_source \
    && rm -rf /usr/local/srcpkg/t2ex_source

ARG GNU_BD=/usr/local/srcpkg/tool/Linux-i686
ARG GNUARM_2=$GNU_BD/arm_2-unknown-tkernel
ARG BD=/usr/local/srcpkg/tkernel_source
ARG GCC_EXEC_PREFIX=$GNU_BD/lib/gcc/
ARG GNUarm_2=$GNU_BD/arm_2-unknown-tkernel

# Build kernel
# Use this working directory instead of below if extension is not needed.
# WORKDIR /usr/local/srcpkg/tkernel_source/kernel/sysmain/build/srcpkg
WORKDIR /usr/local/srcpkg/tkernel_source/kernel/sysmain/build_t2ex/tef_em1d
RUN make req

# Install wolfMQTT
WORKDIR /usr/local
RUN apt-get update && apt-get install -y autoconf automake libtool
ARG WOLFSSL_VERSION=4.2.0c
ADD wolf/wolfssl-$WOLFSSL_VERSION.tar.gz /usr/local
RUN cd wolfssl-$WOLFSSL_VERSION && WOLFSSL_uTKERNEL2=1 && \
    ./autogen.sh && ./configure --host=arm-none-eabi CC=$GNUARM_2 && \
     make && sudo make install
ARG WOLFMQTT_VERSION=1.3.0
ADD wolf/wolfMQTT-$WOLFMQTT_VERSION.tar.gz $SRC_DIR

# Build user code with cache
COPY src /usr/local/srcpkg/tkernel_source/kernel/sysmain/src
RUN make emu

WORKDIR /usr/local/srcpkg/tool/qemu/bin/
ENTRYPOINT [ "./docker-entrypoint.sh" ]

# Remove this CMD if extension is not needed.
CMD [ "false", "/usr/local/srcpkg/tkernel_source/kernel/sysmain/build_t2ex/tef_em1d/rom_t2ex.bin" ]
