FROM ubuntu:12.04
RUN echo "foreign-architecture i386" > /etc/dpkg/dpkg.cfg.d/multiarch
RUN apt-get update && apt-get install -y make libc6:i386 libncurses5:i386 libstdc++6:i386 libbluetooth3:i386 libz1:i386 zlib1g-dev python-software-properties
RUN add-apt-repository -y ppa:terry.guo/gcc-arm-embedded
RUN apt-get update && apt-get install --force-yes -y gcc-arm-none-eabi autoconf automake libtool
ENV QEMU_BIN_DIR=/usr/local/srcpkg/tool/qemu/bin
RUN mkdir -p $QEMU_BIN_DIR
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

ENV BD=/usr/local/srcpkg/tkernel_source
ENV GNU_BD=/usr

# Build kernel
# Use this working directory instead of below if extension is not needed.
# WORKDIR /usr/local/srcpkg/tkernel_source/kernel/sysmain/build/srcpkg
WORKDIR $BD/kernel/sysmain/build_t2ex/tef_em1d

# RUN mv /usr/arm-none-eabi/include/stdlib.h /usr/arm-none-eabi/include/_stdlib.h
RUN make req

# Install wolfMQTT
# WORKDIR /usr/local
# ENV WOLFSSL_VERSION=4.2.0c
# ADD wolf/wolfssl-$WOLFSSL_VERSION.tar.gz /usr/local


# RUN apt-get install -y git vim
# ENTRYPOINT [ "/bin/bash" ]

# RUN cd wolfssl-$WOLFSSL_VERSION && \
#     ./autogen.sh && ./configure --host=arm-non-eabi \
#         --prefix=$BD \
#         CC=/usr/bin/arm-none-eabi-gcc \
#         CFLAGS="-mcpu=arm1176jzf-s -msoft-float -mfpu=vfp -mthumb-interwork \
#         -static --specs=nosys.specs \
#         -I$BD/include \
#         -I$BD/include/t2ex \
#         -I$BD/t2ex/network/net/src_bsd \
#         -I$BD/lib/libc/src_bsd/include \
#         -I$BD/lib/libc/src_bsd/include/sysdepend/tef_em1d" \
#         --disable-filesystem --enable-fastmath \
#         --disable-shared && \
#     make && make install

# RUN cd wolfssl-$WOLFSSL_VERSION && \
#     ./autogen.sh && ./configure --prefix=$BD --host=arm-non-eabi \
#         --prefix=$BD \
#         CC=/usr/bin/arm-none-eabi-gcc \
#         CFLAGS="-mcpu=arm1176jzf-s -msoft-float -mfpu=vfp -mthumb-interwork \
#         -nostdlib -static -T $BD/kernel/sysmain/build_t2ex/tef_em1d/kernel_t2ex-rom.lnk \
#         -DWOLFSSL_uTKERNEL2 -DNO_STDIO_FGETS_REMAP -DTEF_EM1D -DNO_TKERNEL_MEM_POOL \
#         -DNO_WRITE_TEMP_FILES -D_T2EX -DNO_WRITEV -DWOLFSSL_USER_IO -I$BD/lib/libc/src_bsd/include \
#         -I$BD/lib/libc/src_bsd/include/sysdepend/tef_em1d -I$BD/include -I$BD/include/t2ex \
#         -L$BD/lib -lc" \
#         --disable-filesystem && \
#     make && make install

# RUN cd wolfssl-$WOLFSSL_VERSION && \
#     ./autogen.sh && ./configure \
#     --host=arm-non-eabi \
#     CC=/usr/bin/arm-none-eabi-gcc \
#     AR=/usr/bin/arm-none-eabi-ar \
#     STRIP=/usr/bin/arm-none-eabi-strip \
#     RANLIB=/usr/bin/arm-none-eabi-ranlib \
#     --prefix=$BD \
#     CFLAGS="-mcpu=arm1176jzf-s -msoft-float -mfpu=vfp -mthumb-interwork \
#         -nostdlib -static -T $BD/kernel/sysmain/build_t2ex/tef_em1d/kernel_t2ex-rom.lnk \
#         -DWOLFSSL_uTKERNEL2 -DNO_STDIO_FGETS_REMAP -DTEF_EM1D -DNO_TKERNEL_MEM_POOL \
#         -DNO_WRITE_TEMP_FILES -D_T2EX -DNO_WRITEV -DWOLFSSL_USER_IO -I$BD/lib/libc/src_bsd/include \
#         -I$BD/lib/libc/src_bsd/include/sysdepend/tef_em1d -I$BD/include -I$BD/include/t2ex \
#         -L$BD/lib -lc" \
#     --disable-filesystem \
#     --disable-shared && \
#     make && make install





# ENV WOLFMQTT_VERSION=1.3.0
# ADD wolf/wolfMQTT-$WOLFMQTT_VERSION.tar.gz $SRC_DIR

# RUN cd wolfMQTT-$WOLFMQTT_VERSION && \
#     ./autogen.sh && ./configure --prefix=$BD --host=arm-non-eabi \
#         --prefix=$BD \
#         CC=/usr/bin/arm-none-eabi-gcc \
#         CFLAGS="-mcpu=arm1176jzf-s" && \
#     make && make install

# Build user code with cache
COPY src $BD/kernel/sysmain/src
WORKDIR $BD/kernel/sysmain/build_t2ex/tef_em1d
RUN make emu && pwd && ls
RUN ls $BD/kernel/sysmain/build_t2ex/tef_em1d/rom_t2ex.bin

WORKDIR $QEMU_BIN_DIR/
RUN ls $BD/kernel/sysmain/build_t2ex/tef_em1d/rom_t2ex.bin

# RUN apt-get install -y git vim
# ENTRYPOINT [ "/bin/bash" ]

ENTRYPOINT [ "./docker-entrypoint.sh" ]

# Remove this CMD if extension is not needed.
CMD [ "false", "/usr/local/srcpkg/tkernel_source/kernel/sysmain/build_t2ex/tef_em1d/rom_t2ex.bin" ]
