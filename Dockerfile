FROM ubuntu:12.04
# RUN apt-get update && apt-get -y install build-essential glibc
# RUN wget https://developer.arm.com/-/media/Files/downloads/gnu-rm/8-2018q4/gcc-arm-none-eabi-8-2018-q4-major-linux.tar.bz2
# RUN bunzip2 gcc-arm-none-eabi-8-2018-q4-major-linux.tar.bz2
# RUN tar -xvf gcc-arm-none-eabi-8-2018-q4-major-linux.tar
RUN echo "foreign-architecture i386" > /etc/dpkg/dpkg.cfg.d/multiarch
RUN apt-get update && apt-get install -y make gcc libc6:i386 libncurses5:i386 libstdc++6:i386 libbluetooth3:i386 libz1:i386 zlib1g-dev
RUN mkdir -p /home/tkernel && mkdir -p /usr/local/tef_em1d
ADD srcpkg/tkernel_source.tar.gz /usr/local/tef_em1d/
# COPY develop/te.Linux-i686.common.15.tar.gz /home/te.Linux-i686.common.15.tar.gz
# RUN tar -zxvf /home/te.Linux-i686.common.15.tar.gz
# COPY develop/te.Linux-i686.arm_2.1.0.3.tar.gz /home/te.Linux-i686.arm_2.1.0.3.tar.gz
ADD develop/te.Linux-i686.common.15.tar.gz /usr/local/tef_em1d/
# RUN gunzip /home/te.Linux-i686.arm_2.1.0.3.tar.gz
# RUN tar -xvf /home/te.Linux-i686.arm_2.1.0.3.tar -C /home
ADD develop/te.Linux-i686.arm_2.1.0.3.tar.gz /usr/local/tef_em1d/
# RUN echo "export GNU_BD=/usr/local/tef_em1d/tool/Linux-i686" >> /home/.bashrc
# RUN echo "export GNUARM_2=$GNU_BD/arm_2-unknown-tkernel" >> /home/.bashrc
# RUN echo "export BD=/usr/local/tef_em1d/tkernel_source" >> /home/.bashrc
WORKDIR /usr/local/tef_em1d/tkernel_source/kernel/sysmain/build/tef_em1d
# RUN cd kernel/sysmain/build/tef_em1d && BD=/home/tkernel GNU_BD=/home/tool/Linux-i686 GNUARM_2=${GNU_BD}/arm_2-unknown-tkernel make && make emu
# RUN apt-get remove -y wget make
# RUN cd kernel/sysmain/build/tef_em1d && BD=/home/tkernel GNU_BD=/home/tool GNUARM_2=${GNU_BD}/etc make && make emu

# mkdir /home/tool/etc/bin
# cp /home/tool/etc/gcc4arm /home/tool/etc/bin/gcc4arm

RUN GNU_BD=/usr/local/tef_em1d/tool/Linux-i686 GNUARM_2=$GNU_BD/arm_2-unknown-tkernel BD=/usr/local/tef_em1d/tkernel_source GCC_EXEC_PREFIX=$GNU_BD/lib/gcc/ GNUarm_2=$GNU_BD/arm_2-unknown-tkernel make emu

RUN mkdir -p /usr/local/tef_em1d/tool/qemu/bin
COPY emulator/tef_em1d/Linux/* /usr/local/tef_em1d/tool/qemu/bin/
COPY emulator/tef_em1d/Image/* /usr/local/tef_em1d/tool/qemu/bin/


# ENTRYPOINT [ "/usr/local/tef_em1d/tool/Linux-i686/etc/gterm", "-l", "localhost:10000" ]

# ls /usr/local/tef_em1d/tkernel_source/bin/tef_em1d

ADD emulator/tef_em1d/build/qemu-0.12.4-tef_em1d.tar.gz /usr/local/tef_em1d/tool/qemu/
WORKDIR /usr/local/tef_em1d/tool/qemu/qemu-0.12.4-tef_em1d
RUN ./configure --target-list=arm-softmmu --disable-blobs --prefix=/usr/local/tef_em1d/tool/qemu
# RUN make install
# RUN mv /usr/local/tef_em1d/tool/qemu/bin/qemu-system-arm /usr/local/tef_em1d/tool/qemu/bin/qemu-tef_em1d
# WORKDIR /usr/local/tef_em1d/tool/qemu/bin/
# RUN ./qemu.sh /usr/local/tef_em1d/tkernel_source/bin/tef_em1d/rom.bin sd.img
