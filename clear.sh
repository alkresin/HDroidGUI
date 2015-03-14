#!/bin/sh
rm hdroidgui.jar
rm -f *.out
rm -f jni/*.out
rm -f -r lib
mkdir lib
chmod a+w+r+x lib
rm -f -r obj
mkdir obj
chmod a+w+r+x obj
rm -f -r libs
mkdir libs
chmod a+w+r+x libs
