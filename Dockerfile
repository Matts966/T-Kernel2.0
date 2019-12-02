FROM ubuntu:12.04
RUN echo "foreign-architecture i386" > /etc/dpkg/dpkg.cfg.d/multiarch
RUN apt-get update && apt-get install -y make libc6:i386 libncurses5:i386 libstdc++6:i386 libbluetooth3:i386 libz1:i386 zlib1g-dev
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
# ENV GCC_EXEC_PREFIX=$GNU_BD/lib/gcc/

# Build kernel
# Use this working directory instead of below if extension is not needed.
# WORKDIR /usr/local/srcpkg/tkernel_source/kernel/sysmain/build/srcpkg
WORKDIR $BD/kernel/sysmain/build_t2ex/tef_em1d
RUN CC="$GNUARM_2/bin/gcc4arm -std=c99" make req

# Install wolfMQTT
WORKDIR /usr/local
RUN apt-get update && apt-get install -y autoconf automake libtool
# binutils-arm-linux-gnueabi
# libnewlib-dev
ENV WOLFSSL_VERSION=4.2.0c
ADD wolf/wolfssl-$WOLFSSL_VERSION.tar.gz /usr/local

# ENTRYPOINT [ "/bin/bash" ]

# -msoft-float -mfpu=vfp -mthumb-interwork -static -nostdlib -T kernel_t2ex-rom.lnk

# CFLAGS="-L$BD/lib/build/tef_em1d -mcpu=arm1176jzf-s -DWOLFSSL_USER_SETTINGS -DNO_STDIO_FGETS_REMAP -D_TEF_EM1D_ -I$BD/include" \
#    ./configure --host=arm-linux-gnueabi --prefix=$BD

# -DWOLFSSL_uTKERNEL2 \

# VPATH=$BD/t2ex/build/tef_em1d:$BD/t2ex/network/net/src_bsd/net:$BD/t2ex/network/net/src_bsd/string:$BD/t2ex/network/net/src_bsd/ctype:$BD/t2ex/network/net/src_bsd/math \

# /usr/local/srcpkg/tkernel_source/lib/libc/src_bsd/include/unistd.h
# /usr/local/srcpkg/tkernel_source/lib/libc/src_bsd/include/sys/unistd.h
# /usr/local/srcpkg/tkernel_source/include/t2ex/sys/unistd.h
# /usr/local/srcpkg/tkernel_source/t2ex/network/net/src_bsd/sys/unistd.h
# /usr/local/srcpkg/tkernel_source/t2ex/network/net/include/netbsd/unistd.h

# echo "include $BD/lib/libc/src/Makefile.common" >> Makefile && \

# RUN apt-get install -y software-properties-common
RUN apt-get install -y python-software-properties
RUN add-apt-repository -y ppa:terry.guo/gcc-arm-embedded
RUN apt-get update && apt-get install --force-yes -y gcc-arm-none-eabi
RUN cd wolfssl-$WOLFSSL_VERSION && \
    ./autogen.sh && ./configure --host=arm-non-eabi \
        CC=arm-none-eabi-gcc \
        AR=arm-none-eabi-ar \
        STRIP=arm-none-eabi-strip \
        RANLIB=arm-none-eabi-ranlib \
        --prefix=$BD \
        CFLAGS="-mcpu=arm1176jzf-s --specs=nosys.specs \
            -DHAVE_PK_CALLBACKS -DWOLFSSL_USER_IO -DNO_WRITEV" \
        --disable-filesystem --enable-fastmath \
        --disable-shared && \
    make && make install

# arm_2-unknown-tkernelでリンク失敗
# ./configure --prefix=$BD --host=arm-non-eabi         CC=$GNU_BD/arm_2-unknown-tkernel/bin/gcc4arm         CFLAGS="-mcpu=arm1176jzf-s -msoft-float -mfpu=vfp -mthumb-interwork \
        # -nostartfiles -static -T $BD/kernel/sysmain/build_t2ex/tef_em1d/kernel_t2ex-rom.lnk \
        # -DWOLFSSL_uTKERNEL2 -DNO_STDIO_FGETS_REMAP -DTEF_EM1D -D_T2EX -DNO_WRITEV -DWOLFSSL_USER_IO -I$BD/lib/libc/src_bsd/include -I$BD/lib/libc/src_bsd/include/sysdepend/tef_em1d -I$BD/include -I$BD/include/t2ex" --disable-filesystem &&         make


# ./configure --host=arm-non-eabi --disable-examples --disable-tls --prefix=$BD CC=arm-none-eabi-gcc CFLAGS="-mcpu=arm1176jzf-s --specs=nosys.specs" && make && make install


# RUN cd wolfssl-$WOLFSSL_VERSION && \
#     # echo '#define WOLFSSL_uTKERNEL2' > $BD/include/user_settings.h && \
#     ./autogen.sh && ./configure \
#     --host=arm-non-eabi \
#     CC=$GNU_BD/arm_2-unknown-tkernel/bin/gcc4arm \
#     AR=$GNU_BD/arm_2-unknown-tkernel/bin/ar \
#     STRIP=$GNU_BD/arm_2-unknown-tkernel/bin/strip \
#     RANLIB=$GNU_BD/arm_2-unknown-tkernel/bin/ranlib \
#     --prefix=$BD \
#     CFLAGS="-mcpu=arm1176jzf-s -msoft-float -mfpu=vfp \
#         -mthumb-interwork -static -nostdlib \
#         -T $BD/kernel/sysmain/build_t2ex/tef_em1d/kernel_t2ex-rom.lnk -I/usr/include" \
#         # -DWOLFSSL_USER_SETTINGS \
#         # -DNO_STDIO_FGETS_REMAP -D_TEF_EM1D_ -I$BD/include -L$BD/lib/build/tef_em1d \
#         # -lgcc -ltk -lsys -ltm -lsvc -lnetwork" \
#     --disable-filesystem \
#     --disable-shared && \
#     make && make install
ENV WOLFMQTT_VERSION=1.3.0
ADD wolf/wolfMQTT-$WOLFMQTT_VERSION.tar.gz $SRC_DIR

# ENTRYPOINT [ "/bin/bash" ]

RUN cd wolfMQTT-$WOLFMQTT_VERSION && \
# -I/usr/local/srcpkg/tkernel_source/include -I/usr/local/srcpkg/tkernel_source/monitor/include -I../../src -D_TEF_EM1D_
    # ./autogen.sh && ./configure --host=arm-non-eabi \
    #     CC=arm-none-eabi-gcc \
    #     AR=arm-none-eabi-ar \
    #     STRIP=arm-none-eabi-strip \
    #     RANLIB=arm-none-eabi-ranlib \
    #     CFLAGS="-static -nostdlib -mcpu=arm1176jzf-s --specs=nosys.specs -D__need_wint_t -I/usr/local/include -L/usr/local/lib -lgcc -lc -I$BD/include -L$BD/lib -lwolfssl" \
    #     --disable-filesystem --disable-shared && \
    # make && make install
    ./autogen.sh && ./configure --disable-examples --disable-tls \
        --prefix=$BD --host=arm-non-eabi \
        CC=$GNU_BD/arm_2-unknown-tkernel/bin/gcc4arm \
        CFLAGS="-mcpu=arm1176jzf-s -msoft-float -mfpu=vfp -mthumb-interwork \
        -static -nostdlib \
        -T $BD/kernel/sysmain/build_t2ex/tef_em1d/kernel_t2ex-rom.lnk \
        -I$BD/lib/libc/src_bsd/include \
        -I$BD/lib/libc/src_bsd/include/sysdepend/tef_em1d" && \
        make && make install

        #define NO_STDIO_FGETS_REMAP
        #define WOLFSSL_uTKERNEL2


# RUN ln -s /usr/local/wolfssl-4.2.0c/wolfssl /usr/local/srcpkg/tkernel_source/include/wolfssl && \
#     ln -s /usr/local/wolfMQTT-1.3.0/wolfmqtt /usr/local/srcpkg/tkernel_source/include/wolfmqtt && \
#     ls /usr/include && cp -r /usr/include/* /usr/local/srcpkg/tkernel_source/include/ && \
#     ls /usr/local/srcpkg/tkernel_source/include

# ENTRYPOINT [ "/bin/bash" ]

# Build user code with cache
COPY src $BD/kernel/sysmain/src
WORKDIR $BD/kernel/sysmain/build_t2ex/tef_em1d
RUN make emu
RUN ls

ENTRYPOINT [ "/usr/local/srcpkg/tool/qemu/bin/docker-entrypoint.sh" ]

# Remove this CMD if extension is not needed.
# CMD [ "false", "rom_t2ex.bin" ]
