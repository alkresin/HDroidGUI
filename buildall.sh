#!/bin/bash

. ./setenv.sh
./clear.sh
./ndkbuild.sh
if [ -f lib/$NDK_TARGET/libh4droid.so ]; then
   ./comp.sh
else
   echo "Errors while compiling C sources"
   read -n1 -r -p "Press any key to continue..."
fi
