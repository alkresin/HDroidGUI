@call setenv
@%HRB_BIN%\harbour src\prg\hdmain.prg src\prg\hdactiv.prg src\prg\hdwidget.prg src\prg\drawwidg.prg -n -w -i%HRB_INC% -isrc\include -ojni\
@if errorlevel 1 goto end

@set NDK_LIBS_OUT=lib
@set NDK_OUT=obj
@set SRC_FILES=../src/prg/h4droid.c hdmain.c hdactiv.c hdwidget.c drawwidg.c
%NDK_HOME%\prebuilt\windows\bin\make.exe -f %NDK_HOME%/build/core/build-local.mk %* >a1.out 2>a2.out

@cd static
@set NDK_LIBS_OUT=..\libs
@set NDK_OUT=..\obj
@set SRC_FILES=../../src/prg/h4droid.c ../../jni/hdmain.c ../../jni/hdactiv.c ../../jni/hdwidget.c ../../jni/drawwidg.c

%NDK_HOME%\prebuilt\windows\bin\make.exe -f %NDK_HOME%/build/core/build-local.mk %* >>..\a1.out 2>>..\a2.out
@cd ..\
copy obj\local\armeabi\libh4droida.a lib\libh4droida.a
:end