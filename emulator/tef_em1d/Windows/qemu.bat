rem
rem  *** QEMU-tef_em1d emulator execution ***
rem  Usage: qemu.bat <rom.bin> <sd.img>
rem
rem Start type
rem   -dipsw dbgsw=on   : Start T-Monitor only
rem   -dipsw dbgsw=off  : Start T-Kernel
rem
rem Serical port
rem   -serial tcp:127.0.0.1:10000,server : TCP port:127.0.0.1:10000
rem
rem LCD display
rem   -nographic        : No LCD display
rem   -vnc 127.0.0.1:0  : Use VNC server (TCP port: 127.0.0.1:5900)
rem   (none)            : Use SDL display
rem
rem Touch Panel conversion parameters
rem   -tp xmin=944,xmax=64,ymin=912,ymax=80,xchg=on
rem
rem Use gdb Debugger (TCP port: 127.0.0.1:1234)  
rem   -S                : Wait for gdb connection
rem   -gdb tcp:127.0.0.1:1234
rem

C:\qemu\bin\qemu-tef_em1d.exe ^
-cpu arm1176jzf-s ^
-kernel %1 ^
-sd %2 ^
-rtc base=localtime ^
-serial tcp:127.0.0.1:10000,server ^
-tp xmin=944,xmax=64,ymin=912,ymax=80,xchg=on ^
-dipsw dbgsw=on ^
%3 %4 %5 %6

