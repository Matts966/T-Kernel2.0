FROM ubuntu:12.04
# RUN apt-get update && apt-get -y install build-essential glibc
# RUN wget https://developer.arm.com/-/media/Files/downloads/gnu-rm/8-2018q4/gcc-arm-none-eabi-8-2018-q4-major-linux.tar.bz2
# RUN bunzip2 gcc-arm-none-eabi-8-2018-q4-major-linux.tar.bz2
# RUN tar -xvf gcc-arm-none-eabi-8-2018-q4-major-linux.tar
RUN echo "foreign-architecture i386" > /etc/dpkg/dpkg.cfg.d/multiarch
RUN apt-get update && apt-get install -y make libc6:i386 libncurses5:i386 libstdc++6:i386
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
WORKDIR /usr/local/tef_em1d/tkernel_source
# RUN cd kernel/sysmain/build/tef_em1d && BD=/home/tkernel GNU_BD=/home/tool/Linux-i686 GNUARM_2=${GNU_BD}/arm_2-unknown-tkernel make && make emu
# RUN apt-get remove -y wget make
# RUN cd kernel/sysmain/build/tef_em1d && BD=/home/tkernel GNU_BD=/home/tool GNUARM_2=${GNU_BD}/etc make && make emu

# mkdir /home/tool/etc/bin
# cp /home/tool/etc/gcc4arm /home/tool/etc/bin/gcc4arm

RUN cd kernel/sysmain/build/tef_em1d && GNU_BD=/usr/local/tef_em1d/tool/Linux-i686 GNUARM_2=$GNU_BD/arm_2-unknown-tkernel BD=/usr/local/tef_em1d/tkernel_source GCC_EXEC_PREFIX=$GNU_BD/lib/gcc/ GNUarm_2=$GNU_BD/arm_2-unknown-tkernel make emu

ls /usr/local/tef_em1d/tkernel_source/bin/tef_em1d
