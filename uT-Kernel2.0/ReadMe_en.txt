/*
 *----------------------------------------------------------------------
 *    micro T-Kernel
 *
 *    Copyright (C) 2006-2014 by Ken Sakamura.
 *    This software is distributed under the T-License 2.0.
 *----------------------------------------------------------------------
 *
 *    Version:   2.00.00
 *    Released by T-Engine Forum (http://www.t-engine.org/) at 2014/12/10.
 *
 *----------------------------------------------------------------------
 */

------------------------------------------------------------------------
Package Content
------------------------------------------------------------------------

(1) Manuals

  ReadMe_en.txt                 release manual (this document)
  utk-dist-ucode.png            Distribution ucode
  TEF000-215-120911.pdf         T-License 2.0

  srcpkg/doc/en/
    tkernel.txt                 micro T-Kernel Source Code Manual
    TEF020-W024-01.00.01.pdf    How to install GNU tool for Cortex-M3
    TEF020-W002-01.00.02.pdf    How to install GNU tool for ARM7TDMI
    TEF020-W003-01.00.02.pdf    How to install GNU tool for H8S/2212
    TEF020-W025-02.00.00.pdf    micro T-Kernel Implementation Specification FM3 (Cortex-M3)
    TEF020-W014-01.01.02.pdf    micro T-Kernel Implementation Specification AT91 (ARM7TDMI)
    TEF020-W015-01.01.02.pdf    micro T-Kernel Implementation Specification H8S/2212


(2) Software

  srcpkg/
    utkernel.2.00.00.tar.gz     Source code package


(3) Development Environment

  develop/
    devenv_cortex-m3.tgz                Binary Code (Cygwin host)
    devenv_arm7tdmi.tgz                 Binary Code (Cygwin host)
    devenv_h8300-elf-4.1.tgz            Binary Code (Cygwin host)
    binutils-2.14.tar.gz                Source Code (ARM7TDMI)
    gcc-3.3.2.tar.gz                    Source Code (ARM7TDMI)
    binutils-2.16.92_sh_h8_v0602.tgz    Source Code (H8S/2212)
    gcc-4.1-20060407_sh_h8_v0602.tgz    Source Code (H8S/2212)
    scripts.tgz                         Script files (H8S/2212)

  [About ARM7TDMI GNU tools]
  - No modifications are added to the source codes of binutils and GCC.

  [About H8S/2212 GNU tools]
  - Some modifications were added to the source codes of binutils and 
    GCC (GNU H8 v0602) which were downloaded from KPIT Web Page.
    About modifications, please refer to the files (binutilspatchlistTEF.html 
    and gccpatchlistTEF.html) located under the root directory where each 
    archive file is extracted.
  - Script files were used to build binary code by the T-Engine Forum.
    Please use them for your reference when you build binary code.
[EOF]
