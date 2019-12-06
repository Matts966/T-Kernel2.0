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
パッケージ内容
------------------------------------------------------------------------

(1) 説明書

  ReadMe.txt                    リリース説明書 (本書)
  utk-dist-ucode.png            ディストリビューションucode
  TEF000-215-120911.pdf         T-License 2.0

  srcpkg/doc/ja/
    tkernel.txt                 μT-Kernel ソースコード説明書
    TEF020-W024-01.00.01.pdf    Cortex-M3 用 GNU ツールインストール方法
    TEF020-W002-01.00.02.pdf    ARM7TDMI 用 GNU ツールインストール方法
    TEF020-W003-01.00.02.pdf    H8S/2212 用 GNU ツールインストール方法
    TEF020-W025-02.00.00.pdf    μT-Kernel 実装仕様書 FM3 (Cortex-M3) 版
    TEF020-W014-01.01.02.pdf    μT-Kernel 実装仕様書 AT91 (ARM7TDMI) 版
    TEF020-W015-01.01.02.pdf    μT-Kernel 実装仕様書 H8S/2212 版


(2) ソースコード

  srcpkg/
    utkernel.2.00.00.tar.gz     ソースコードパッケージ


(3) 開発環境

  develop/
    devenv_cortex-m3.tgz                バイナリ (実行環境:Cygwin)
    devenv_arm7tdmi.tgz                 バイナリ (実行環境:Cygwin)
    devenv_h8300-elf-4.1.tgz            バイナリ (実行環境:Cygwin)
    binutils-2.14.tar.gz                ソースコード (ARM7TDMI)
    gcc-3.3.2.tar.gz                    ソースコード (ARM7TDMI)
    binutils-2.16.92_sh_h8_v0602.tgz    ソースコード (H8S/2212)
    gcc-4.1-20060407_sh_h8_v0602.tgz    ソースコード (H8S/2212)
    scripts.tgz                         ビルド用スクリプト (H8S/2212)

【ARM7TDMI用GNUツールについて】
   ・ソースコードに対する改変は行っていません。

【H8S/2212用GNUツールについて】
   ・binutilsとGCCは、KPITのWebページから入手したソースコード
     (GNU H8 v0602)に対して改造を加えています。
     変更内容は、各ファイルを展開したルートディレクトリにある
     binutilspatchlistTEF.html, gccpatchlistTEF.html をご覧ください。
   ・ビルド用スクリプトは、T-Engineフォーラムで開発環境作成時に
     使用したものです。開発環境作成時の参考にお使いください。
以上
