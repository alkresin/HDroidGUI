#!/bin/bash

. ./setenv.sh

$HRB_BIN/harbour src/prg/hdmain.prg src/prg/hdactiv.prg src/prg/hdwidget.prg src/prg/drawwidg.prg src/prg/hdbrowse.prg -n -w -i$HRB_INC -isrc/include -ojni/

export NDK_LIBS_OUT=lib
export NDK_OUT=obj
export SRC_FILES="../src/prg/h4droid.c hdmain.c hdactiv.c hdwidget.c drawwidg.c hdbrowse.c"
$NDK_HOME/prebuilt/linux-x86/bin/make -f $NDK_HOME/build/core/build-local.mk "$@" >a1.out 2>a2.out

cd static
export NDK_LIBS_OUT=../libs
export NDK_OUT=../obj
export SRC_FILES="../../src/prg/h4droid.c ../../jni/hdmain.c ../../jni/hdactiv.c ../../jni/hdwidget.c ../../jni/drawwidg.c ../../jni/hdbrowse.c"

$NDK_HOME/prebuilt/linux-x86/bin/make -f $NDK_HOME/build/core/build-local.mk "$@" >>../a1.out 2>>../a2.out
cd ../
cp obj/local/armeabi/libh4droida.a lib/libh4droida.a
