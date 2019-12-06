FROM ubuntu:12.04
RUN echo "foreign-architecture i386" > /etc/dpkg/dpkg.cfg.d/multiarch
RUN apt-get update && apt-get install -y make libc6:i386 libncurses5:i386 \
    libstdc++6:i386 libbluetooth3:i386 libz1:i386 zlib1g-dev autoconf \
    automake libtool vim
RUN mkdir -p /usr/local/srcpkg/tool/qemu/bin
ENV QEMU_BIN_DIR=/usr/local/srcpkg/tool/qemu/bin
COPY emulator/tef_em1d/Image/* $QEMU_BIN_DIR/
ADD emulator/tef_em1d/build/qemu-0.12.4-tef_em1d.tar.gz /usr/local/srcpkg/tool/qemu/
WORKDIR /usr/local/srcpkg/tool/qemu/qemu-0.12.4-tef_em1d
RUN ./configure --target-list=arm-softmmu --disable-blobs --prefix=/usr/local/srcpkg/tool/qemu
RUN make install
RUN mv $QEMU_BIN_DIR/qemu-system-arm $QEMU_BIN_DIR/qemu-tef_em1d
ADD develop/te.Linux-i686.common.15.tar.gz /usr/local/srcpkg/
ADD develop/te.Linux-i686.arm_2.1.0.3.tar.gz /usr/local/srcpkg/

COPY docker-entrypoint.sh $QEMU_BIN_DIR/
RUN chmod +x $QEMU_BIN_DIR/docker-entrypoint.sh
COPY emulator/tef_em1d/Linux/* $QEMU_BIN_DIR/

# Use COPY instead of ADD for building kernel.
COPY srcpkg/tkernel_source /usr/local/srcpkg/tkernel_source
COPY T2EX/srcpkg/t2ex_source /usr/local/srcpkg/t2ex_source
RUN cd /usr/local/srcpkg/t2ex_source \
    && cp -r * ../tkernel_source \
    && rm -rf /usr/local/srcpkg/t2ex_source

ENV GNU_BD=/usr/local/srcpkg/tool/Linux-i686
ENV GNUARM_2=$GNU_BD/arm_2-unknown-tkernel
ENV BD=/usr/local/srcpkg/tkernel_source

# Build kernel
# Use this working directory instead of below if extension is not needed.
# WORKDIR /usr/local/srcpkg/tkernel_source/kernel/sysmain/build/srcpkg
WORKDIR $BD/kernel/sysmain/build_t2ex/tef_em1d
RUN CC="$GNUARM_2/bin/gcc4arm -std=gnu11" make req

# Install wolfMQTT
ENV WOLFMQTT_VERSION=1.3.0
COPY wolf/wolfMQTT-$WOLFMQTT_VERSION /usr/local/wolfMQTT-$WOLFMQTT_VERSION
WORKDIR /usr/local
# ENTRYPOINT [ "/bin/bash" ]

RUN cd wolfMQTT-$WOLFMQTT_VERSION && \
    ./autogen.sh && ./configure --disable-tls --enable-nonblock \
        --prefix=$BD --host=arm-non-eabi \
        CC=$GNU_BD/arm_2-unknown-tkernel/bin/gcc4arm \
        CFLAGS="-mcpu=arm1176jzf-s -msoft-float -mfpu=vfp -mthumb-interwork \
        -static -nostdlib -D_T2EX=1 -DT2EX=1 -DT2EX_MM -DT2EX_NO_MD5 \
        -D_TEF_EM1D_ -DINET -DGATEWAY=1 -DTKERNEL_CHECK_CONST \
        -DNBPFILTER=3 -DNTUN=0 -DNDEBUG -Duse_libstr_func_as_std=1 \
        -DTEF_EM1D=1 -DTKERNEL -D_KERNEL -DNO_EXIT \
        -T $BD/kernel/sysmain/build_t2ex/tef_em1d/kernel_t2ex-rom.lnk \
        -I$BD/include/sys/sysdepend/tef_em1d \
        -I$BD/t2ex/network/net/src_bsdlib/libc/include \
        -I$BD/include/t2ex -I$BD/include \
        -L$BD/lib/build/tef_em1d -lconsolesvc -lem1diic -ldrvif -lc \
        -ldatetime -lload -lfs -lnetwork -ltk -lstr -lsys -ltm -lsvc -lgcc" && \
    make && make install

# Build user code with cache
COPY src $BD/kernel/sysmain/src
COPY wolf/wolfMQTT-$WOLFMQTT_VERSION/examples/ $BD/kernel/sysmain/src/examples/

# ENTRYPOINT [ "/bin/bash" ]

WORKDIR $BD/kernel/sysmain/build_t2ex/tef_em1d
RUN make emu

ENTRYPOINT [ "/usr/local/srcpkg/tool/qemu/bin/docker-entrypoint.sh" ]

# Remove this CMD if extension is not needed.
CMD [ "false", "rom_t2ex.bin" ]
