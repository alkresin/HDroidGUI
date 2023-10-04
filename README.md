# HDroidGUI
Android GUI framework for Harbour

<b> Attention! Since October 6, 2023 we are forced to use two-factor authentication to be able to
   update the repository. Because it's not suitable for me, I will probably use another place for projects.
   Maybe, https://gitflic.ru/, maybe, Sourceforge... Follow the news on my website, http://www.kresin.ru/

   Внимание! С 6 октября 2023 года нас вынуждают использовать двухфакторную идентификацию для того, чтобы 
   продолжать работать над проектами. Поскольку для меня это крайне неудобно, я, возможно, переведу проекты
   на другое место. Это может быть https://gitflic.ru/, Sourceforge, или что-то еще. Следите за новостями
   на моем сайте http://www.kresin.ru/ </b>

###The structure of HDroidGUI distribution:
* _buildall.bat, buildall.sh_ - command scripts for the whole framework cross-compiling, bat - if you do it under Windows, sh - if under Linux.
* _clear.bat, clear.sh_ - command scripts for deleting the results of compiling.
* _comp.bat, comp.sh_ - command scripts for compiling of "Java" - code of the framework.
* _ndkBuild.bat, ndkbuild.sh_ - command scripts for compiling of "C" and "Harbour" - framework code.
* _setenv.bat, setenv.sh_ - command scripts to set the environment variable to compile the framework, you need to edit it - set the paths, which are correct for your system.
* _jni/Android.mk, jni/Application.mk_ - makefiles to build dynamic libraries ("so") of the "native" part of the framework.
* _jni/libharbour.so_ - prebuilt Harbour dynamic library, which is used to create dynamic libraries of the "native" part of the framework.
* _static/jni/Android.mk, static/jni/Application.mk_ - makefiles to build static library of the "native" part of the framework.
* _src/_ - the directory for the framrwork sources.
* _src/include/*_ - header files for Harbour-code.
* _src/prg/*_ - Harbour and C sources.
* _src/su/harbour/hDroidGUI/*_ - Java sources.
* _utils/newproject.prg_ - a source file of an utility for creating a new project.

###HDroidGUI compiled files (binaries) - (the result of buildall work):
* _lib/armeabi/libh4droid.so, lib/armeabi/libharbour.so* _ - dynamic libraries of the "native" part of the framework.
* _lib/libh4droida.a_ - static library of the "native" part of the framework.
* _libs/su/harbour/hDroidGUI/*_ - compiled Java classes.

