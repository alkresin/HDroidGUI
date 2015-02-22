#!/bin/bash

. ./setenv.sh

$HRB_BIN/harbour src/prg/hdmain.prg src/prg/hdactiv.prg src/prg/hdwidget.prg -n -w -i$HRB_INC -isrc/include -ojni/

export NDK_LIBS_OUT=lib
$NDK_HOME/prebuilt/linux-x86/bin/make -f $NDK_HOME/build/core/build-local.mk "$@" >a1.out 2>a2.out
