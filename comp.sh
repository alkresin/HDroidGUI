#!/bin/bash
. ./setenv.sh

echo "compile java sources"
javac -d libs -cp $ANDROID_JAR -sourcepath src src/su/harbour/hDroidGUI/*.java
if [ "$?" -eq 0 ]; then
  echo "building jar"
  jar cvf hdroidgui.jar -C libs .
else
  echo "java sources compiling error"
fi
read -n1 -r -p "Press any key to continue..."
