FROM ubuntu:18.04
RUN apt-get update && apt-get install -y git vim make automake libtool build-essential zlib1g-dev pkg-config libglib2.0-dev binutils-dev libboost-all-dev libssl-dev libpixman-1-dev libpython-dev python-pip python-capstone virtualenv gcc-arm-none-eabi bison flex libsdl-dev gcc-arm-linux-gnueabi
WORKDIR /usr/local
RUN git clone git://git.qemu.org/qemu.git
WORKDIR /usr/local/qemu
RUN git checkout -b v4.1.0-release refs/tags/v4.1.0
RUN git submodule update --init
RUN ./configure --prefix=$(pwd)/build --target-list=arm-softmmu
RUN make
WORKDIR /usr/local

ADD uT-Kernel2.0/develop/devenv_cortex-m3.tgz /usr/local/
ADD uT-Kernel2.0/srcpkg/utkernel.2.00.00.tar.gz /usr/local/
ENV BD=/usr/local/utkernel_source
ENV GNU_BD=/usr
ENV GNUARM_2=$GNU_BD/arm-none-eabi

WORKDIR $BD/kernel/sysmain/build/

# RUN dd if=/dev/zero of=./sd.img bs=1024 count=4194304 && \
#     losetup -fP ./sd.img && \
#     mkfs.ext4 /dev/loop0 && \
#     mount /dev/loop0 /usr/local/sd-dir && \
#     cp /usr/local/sd/* /usr/local/sd-dir && \
#     umount /usr/local/sd-dir && \
#     losetup -d /dev/loop0

# WORKDIR /usr/local
# RUN export CROSS_COMPILE=arm-linux-gnueabi-
# RUN git clone git://git.denx.de/u-boot.git
# WORKDIR /usr/local/u-boot
# RUN make qemu_arm_defconfig
# WORKDIR /usr/local
# RUN ./qemu/build/bin/qemu-system-arm -M vexpress_a9 -nographic -kernel u-boot/u-boot


# # Use COPY instead of ADD for building kernel.
# COPY srcpkg/tkernel_source /usr/local/srcpkg/tkernel_source
# COPY T2EX/srcpkg/t2ex_source /usr/local/srcpkg/t2ex_source
# RUN cd /usr/local/srcpkg/t2ex_source \
#     && cp -r * ../tkernel_source \
#     && rm -rf /usr/local/srcpkg/t2ex_source

# ENV BD=/usr/local/srcpkg/tkernel_source
# ENV GNU_BD=/usr

# # Build kernel
# WORKDIR $BD/kernel/sysmain/build_t2ex/tef_em1d

# RUN make req


# Build user code with cache
# COPY src $BD/kernel/sysmain/src
# WORKDIR $BD/kernel/sysmain/build_t2ex/tef_em1d
# RUN make emu
# COPY emulator/tef_em1d/Image/* /usr/local/

# ADD develop/te.Linux-i686.common.15.tar.gz /usr/local/srcpkg/
# COPY docker-entrypoint.sh /usr/local
# RUN chmod +x /usr/local/docker-entrypoint.sh

ENTRYPOINT [ "/bin/bash" ]

# ENTRYPOINT [ "./docker-entrypoint.sh" ]
# # Remove this CMD if extension is not needed.
# CMD [ "/usr/local/srcpkg/tkernel_source/kernel/sysmain/build_t2ex/tef_em1d/kernel_t2ex-rom.rom" ]
