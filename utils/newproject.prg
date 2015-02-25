/*
 * Creating of a new Android project, based on HDroidGUI
 */

STATIC cdiv, crlf

MEMVAR cHDGUIPath, cPass, lHrb

FUNCTION Main( ... )

   LOCAL aParams := hb_aParams(), lErr := .F., i, c1
   LOCAL cFullName, aFullName
   PRIVATE cHDGUIPath := "", cPass := ""
   PRIVATE lHrb := .F.

#ifdef __PLATFORM__UNIX
   crlf := e"\n"
   cdiv := "/"
#else
   crlf := e"\r\n"
   cdiv := "\"
#endif

   FOR i := 1 TO Len( aParams )
      IF Left( aParams[i],1 ) $ "-/"
         IF Lower( Substr( aParams[i],2 ) ) == "hrb"
            lHrb := .T.
         ELSEIF Lower( Substr( aParams[i],2,5 ) ) == "path="
            cHDGUIPath := Substr( aParams[i],7 )
         ELSEIF Lower( Substr( aParams[i],2,5 ) ) == "pass="
            cPass := Substr( aParams[i],7 )
         ELSE
            lErr := .T. ;  EXIT
         ENDIF
      ELSEIF i == 1 .OR. i == Len( aParams )
         cFullName := aParams[i]
      ELSE
         lErr := .T. ; EXIT
      ENDIF
   NEXT

   IF lErr .OR. ( Empty(cFullName) )
      ? "Syntax:"
      ? "newproject [-hrb] [-path=PATHtoHDROIDGUI] [-pass=cPassword] cFullPackageName"
      ?
      QUIT
   ENDIF
   IF !( "." $ cFullName )
      ? "Choose a full project name, i.e. org.harbour." + cFullName
      ?
      QUIT
   ENDIF
   IF Empty( cHDGUIPath ) .AND. Empty( cHDGUIPath := GetEnv( "HDROIDGUI_PATH" ) )
      ACCEPT "Path to HDroidGUI: " TO cHDGUIPath
      IF Empty( cHDGUIPath )
         ? "Path to HDroidGUI isn't set"
         ?
         QUIT
      ENDIF
   ENDIF
   IF Empty( cPass )
      ACCEPT "Password to sign package: " TO cPass
      IF Empty( cPass )
         ? "Password isn't set"
         ?
         QUIT
      ENDIF
   ENDIF

   aFullName := hb_aTokens( cFullName, "." )

   IF CreateDirs( aFullName )
      CreateJava( aFullName )
      CreateManifest( aFullName )
      CreateScripts( aFullName )
      CreatePrg( aFullName )
   ENDIF  

   RETURN Nil


STATIC FUNCTION CreateDirs( aFullName )

   LOCAL cPrjName  := Atail( aFullName ), i, csrc

   IF DirMake( cPrjName ) == 0

      csrc := cPrjName + cdiv + "src"

      DirMake( cPrjName + cdiv + "assets" )
      DirMake( cPrjName + cdiv + "bin" )
      DirMake( cPrjName + cdiv + "obj" )
      DirMake( cPrjName + cdiv + "res" )
      DirMake( cPrjName + cdiv + "src" )
      IF !lHrb
         DirMake( cPrjName + cdiv + "jni" )
         DirMake( cPrjName + cdiv + "lib" )
         DirMake( cPrjName + cdiv + "libs" )
      ENDIF

      DirMake( cPrjName + cdiv + "res" + cdiv + "drawable-hdpi" )
      DirMake( cPrjName + cdiv + "res" + cdiv + "drawable-ldpi" )
      DirMake( cPrjName + cdiv + "res" + cdiv + "drawable-mdpi" )
      DirMake( cPrjName + cdiv + "res" + cdiv + "drawable-xhdpi" )
      DirMake( cPrjName + cdiv + "res" + cdiv + "values" )

      FOR i := 1 TO Len( aFullName )
         csrc += cdiv + aFullName[i]
         DirMake( csrc )
      NEXT

      RETURN .T.
   ENDIF

   RETURN .F.

STATIC FUNCTION CreateJava( aFullName )

   LOCAL handle, cPath := Atail(aFullName) + cdiv + "src", i
   LOCAL cPackage := "package "
   LOCAL cBody


   FOR i := 1 TO Len( aFullName )
      cPath += cdiv + aFullName[i]
      cPackage += Iif( i==1, "", "." ) + aFullName[i]
   NEXT

   cPackage += ";" + crlf + crlf

   handle := FCreate( cPath + cdiv + "MainApp.java" )
   IF Ferror() != 0
      RETURN .F.
   ENDIF

   cBody := cPackage

   cBody += "import android.app.Application;" + crlf + ;
      "import su.harbour.hDroidGUI.Harbour;" + crlf + crlf + ;
      "public class MainApp extends Application {" + crlf + crlf + ;
      "   public static Harbour harb;" + crlf + crlf + ;
      "   @Override"  + crlf + ;
      "   public void onCreate() {" + crlf + ;
      "      super.onCreate();" + crlf + crlf + ;
      "      harb = new Harbour( this );" + crlf + crlf + ;
      "      harb.Init( " + Iif( lHrb, "true", "false" ) + " );" + crlf + crlf + "   }" + crlf + "}" + crlf

   FWrite( handle, cBody )
   FClose( handle )

   handle := FCreate( cPath + cdiv + "MainActivity.java" )
   IF Ferror() != 0
      RETURN .F.
   ENDIF

   cBody := cPackage
   cBody += "import android.app.Activity;" + crlf + ;
      "import android.os.Bundle;" + crlf + ;
      "import android.os.Bundle;" + crlf + ;
      "import android.view.View;" + crlf + ;
      "import su.harbour.hDroidGUI.Harbour;" + crlf + crlf + ;
      "public class MainActivity extends Activity {" + crlf + crlf + ;
      "   @Override" + crlf + ;
      "   public void onCreate(Bundle savedInstanceState) {" + crlf + ;
      "      super.onCreate(savedInstanceState);" + crlf + crlf + ;
      "      setContentView( MainApp.harb.hrbMain( this ) );" + crlf + ;
      "   }" + crlf + "}" + crlf

   FWrite( handle, cBody )
   FClose( handle )

   RETURN .T.


STATIC FUNCTION CreateManifest( aFullName )

   LOCAL handle, cPrjName := Atail(aFullName), cBody, i
   LOCAL cPackage := ""

   FOR i := 1 TO Len( aFullName )
      cPackage += Iif( i==1, "", "." ) + aFullName[i]
   NEXT

   handle := FCreate( cPrjName + cdiv + "AndroidManifest.xml" )
   IF Ferror() != 0
      RETURN .F.
   ENDIF

   cBody := '<?xml version="1.0" encoding="utf-8"?>' + crlf + ;
      '<manifest xmlns:android="http://schemas.android.com/apk/res/android"' + crlf + ;
      '      package="' + cPackage + '"' + crlf + ;
      '      android:versionCode="1"' + crlf + ;
      '      android:versionName="1.0">' + crlf + ;
      '   <application android:label="' + cPrjName + '"' + crlf + ;
      '         android:name="' + cPackage + '.MainApp">' + crlf + ;
      '      <activity android:name="MainActivity"' + crlf + ;
      '         android:label="' + cPrjName + '">' + crlf + ;
      '         <intent-filter>' + crlf + ;
      '            <action android:name="android.intent.action.MAIN" />' + crlf + ;
      '            <category android:name="android.intent.category.LAUNCHER" />' + crlf + ;
      '         </intent-filter>' + crlf + ;
      '      </activity>' + crlf + ;
      '      <activity' + crlf + ;
      '         android:name="' + cPackage + '.DopActivity"' + crlf + ;
      '         android:label="second"' + crlf + ;
      '         android:parentActivityName="' + cPackage + '.MainActivity" >' + crlf + ;
      '         <meta-data' + crlf + ;
      '            android:name="android.support.PARENT_ACTIVITY"' + crlf + ;
      '            android:value="' + cPackage + '.MainActivity" />' + crlf + ;
      '      </activity>' + crlf + ;
      '   </application>' + crlf + ;
      '   <uses-permission android:name="android.permission.INTERNET" />' + crlf + ;
      '</manifest>'

   FWrite( handle, cBody )
   FClose( handle )

   RETURN .T.

STATIC FUNCTION CreateScripts( aFullName )

   LOCAL handle, cPath := Atail(aFullName), cBody, i
   LOCAL cPackageDot := "", cPackageSep := ""

   FOR i := 1 TO Len( aFullName )
      cPackageDot += Iif( i==1, "", "." ) + aFullName[i]
      cPackageSep += Iif( i==1, "", cdiv ) + aFullName[i]
   NEXT

#ifdef __PLATFORM__UNIX

   handle := FCreate( cPath + cdiv + "build.sh" )
   IF Ferror() != 0
      RETURN .F.
   ENDIF

   cBody := "#!/bin/bash" + crlf + crlf + ;
      ". ./setenv.sh" + crlf + crlf + ;
      "./clear.sh" + crlf + crlf
   IF lHrb
      cBody += "$HRB_BIN/harbour src/main.prg -gh -q -i$HRB_INC -i$HDROIDGUI/src/include -i$HRB_INC -oassets/" + crlf
   ELSE
      cBody += "$HRB_BIN/harbour src/main.prg -q -i$HRB_INC -i$HDROIDGUI/src/include -i$HRB_INC -ojni/" + crlf
   ENDIF
   cBody += 'if [ "$?" -eq 0 ]' + crlf + ;
      "then" + crlf
   IF !lHrb
      cBody += 'export NDK_LIBS_OUT=lib' + crlf + ;
         '$NDK_HOME/prebuilt/linux-x86/bin/make -f $NDK_HOME/build/core/build-local.mk "$@" >a1.out 2>a2.out' + crlf
   ENDIF
   cBody += '  if [ "$?" -eq 0 ]' + crlf + ;
      "  then" + crlf + ;
      '    echo "compile java sources"' + crlf + ;
      '    $BUILD_TOOLS/aapt package -f -m -S res -J src -M AndroidManifest.xml -I $ANDROID_JAR' + crlf + ;
      "    javac -d obj -cp $ANDROID_JAR:$HDROIDGUI/hdroidgui.jar -sourcepath src src/$PACKAGE_PATH/*.java" + crlf + ;
      '    if [ "$?" -eq 0 ]' + crlf + ;
      "    then" + crlf + ;
      '      echo "convert to .dex"' + crlf + ;
      "      $BUILD_TOOLS/dx --dex --output=bin/classes.dex obj $HDROIDGUI/libs" + crlf + crlf + ;
      '      if [ "$?" -eq 0 ]' + crlf + ;
      "      then" + crlf + ;
      "        $BUILD_TOOLS/aapt package -f -M AndroidManifest.xml -S res -I $ANDROID_JAR -F bin/$APPNAME.unsigned.apk bin" + crlf + crlf
   IF lHrb
      cBody += "        cd $HDROIDGUI" + crlf
   ENDIF
   cBody += "        $BUILD_TOOLS/aapt add $DEV_HOME/bin/$APPNAME.unsigned.apk lib/armeabi/libharbour.so" + crlf + crlf + ;
      '        if [ "$?" -eq 0 ]' + crlf + ;
      "        then" + crlf + ;
      "          $BUILD_TOOLS/aapt add $DEV_HOME/bin/$APPNAME.unsigned.apk lib/armeabi/libh4droid.so" + crlf + crlf
   IF lHrb
      cBody += "          cd $DEV_HOME" + crlf
   ENDIF
   cBody += "          $BUILD_TOOLS/aapt add bin/$APPNAME.unsigned.apk assets/main.hrb" + crlf + ;
      '          echo "sign APK"' + crlf + ;
      '          keytool -genkey -v -keystore myrelease.keystore -alias key2 -keyalg RSA -keysize 2048 -validity 10000 -storepass ' + cPass + ' -keypass ' + cPass + ' -dname "CN=Alex K, O=Harbour, C=RU"' + crlf + ;
      "          jarsigner -sigalg SHA1withRSA -digestalg SHA1 -keystore myrelease.keystore -storepass " + cPass + " -keypass " + cPass + " -signedjar bin/$APPNAME.signed.apk bin/$APPNAME.unsigned.apk key2" + crlf + ;
      "          $BUILD_TOOLS/zipalign -v 4 bin/$APPNAME.signed.apk bin/$APPNAME.apk" + crlf + ;
      "        fi" + crlf
   IF lHrb
      cBody += "        cd $DEV_HOME" + crlf
   ENDIF
   cBody += "      else" + crlf + ;
      '        echo "error creating dex file"' + crlf + ;
      "      fi" + crlf + ;
      "    else" + crlf + ;
      '      echo "java sources compiling error"' + crlf + ;
      "    fi" + crlf + ;
      "  else" + crlf + ;
      '    echo "C sources compiling error"' + crlf + ;
      "  fi" + crlf + crlf + ;
      "fi" + crlf + ;
      'read -n1 -r -p "Press any key to continue..."'

   FWrite( handle, cBody )
   FClose( handle )

   handle := FCreate( cPath + cdiv + "clear.sh" )
   IF Ferror() != 0
      RETURN .F.
   ENDIF

   cBody := "#!/bin/sh" + crlf + crlf + ;
      ". ./setenv.sh" + crlf + crlf + ;
      "rm -f src/$PACKAGE_PATH/R.java" + crlf + ;
      "rm -f assets/*" + crlf + ;
      "rm -f bin/*" + crlf + ;
      "rm -f *.out" + crlf
   IF !lHrb
      cBody += "rm -f -r lib" + crlf + ;
      "mkdir lib" + crlf + ;
      "chmod a+w+r+x lib" + crlf + ;
      "rm -f -r libs" + crlf + ;
      "mkdir libs" + crlf + ;
      "chmod a+w+r+x libs" + crlf
   ENDIF
   cBody += "rm -f -r obj" + crlf + ;
      "mkdir obj" + crlf + ;
      "chmod a+w+r+x obj"

   FWrite( handle, cBody )
   FClose( handle )

   handle := FCreate( cPath + cdiv + "run.sh" )
   IF Ferror() != 0
      RETURN .F.
   ENDIF

   cBody := "#!/bin/bash" + crlf + crlf + ;
      ". ./setenv.sh" + crlf + crlf + ;
      "$ADB uninstall $PACKAGE" + crlf + ;
      "$ADB install bin/$APPNAME.apk" + crlf + crlf + ;
      "$ADB shell logcat -c" + crlf + ;
      "$ADB shell am start -n $PACKAGE/$PACKAGE.$MAIN_CLASS" + crlf + ;
      "$ADB shell logcat Harbour:I *:S > log.txt"

   FWrite( handle, cBody )
   FClose( handle )

   handle := FCreate( cPath + cdiv + "setenv.sh" )
   IF Ferror() != 0
      RETURN .F.
   ENDIF

   cBody := "#!/bin/bash" + crlf + crlf + ;
      "export HDROIDGUI=" + cHDGUIPath + crlf + ;
      ". $HDROIDGUI/setenv.sh" + crlf + crlf + ;
      "export APPNAME=" + Atail(aFullName) + crlf + ;
      "export PACKAGE=" + cPackageDot + crlf + ;
      "export PACKAGE_PATH=" + cPackageSep + crlf + ;
      "export MAIN_CLASS=MainActivity" + crlf + ;
      "export DEV_HOME=`pwd`"

   FWrite( handle, cBody )
   FClose( handle )

#else

   handle := FCreate( cPath + cdiv + "build.bat" )
   IF Ferror() != 0
      RETURN .F.
   ENDIF

   cBody := "@call setenv" + crlf + ;
      "@call clear" + crlf + crlf
   IF lHrb
      cBody += "@%HRB_BIN%\harbour src\main.prg /gh /q /i%HDROIDGUI%\src\include /i%HRB_INC% /oassets\" + crlf
   ELSE
      cBody += "@%HRB_BIN%\harbour src\main.prg /q /i%HDROIDGUI%\src\include /i%HRB_INC% /ojni\" + crlf
   ENDIF
   cBody += "@if errorlevel 1 goto end" + crlf + crlf
   IF !lHrb
      cBody += "@set NDK_LIBS_OUT=lib" + crlf + ;
         "@set SRC_FILES=main.c" + crlf + ;
         "%NDK_HOME%\prebuilt\windows\bin\make.exe -f %NDK_HOME%/build/core/build-local.mk %* >a1.out 2>a2.out" + crlf + ;
         "@if exist lib\armeabi\libh4droid.so goto comp" + crlf + ;
         "@echo Errors while compiling C sources" + crlf + ;
         "@goto end" + crlf + crlf + ;
         ":comp" + crlf
   ENDIF
   cBody += "call %BUILD_TOOLS%/aapt.exe package -f -m -S res -J src -M AndroidManifest.xml -I %ANDROID_JAR%" + crlf + ;
      "@if errorlevel 1 goto end" + crlf + crlf + ;
      "@rem compile, convert class dex" + crlf + ;
      "@rem call %JAVA_HOME%/bin/javac -d obj -cp %ANDROID_JAR%;%HDROIDGUI%\hdroidgui.jar -sourcepath src src/%PACKAGE_PATH%/*.java" + crlf + ;
      "call %JAVA_HOME%/bin/javac -d obj -cp %ANDROID_JAR%;%HDROIDGUI%\libs -sourcepath src src/%PACKAGE_PATH%/*.java" + crlf + ;
      "@if errorlevel 1 goto end" + crlf + crlf + ;
      "call %BUILD_TOOLS%/dx.bat --dex --output=bin/classes.dex obj %HDROIDGUI%\libs" + crlf + ;
      "@if errorlevel 1 goto end" + crlf + crlf + ;
      "@rem create APK" + crlf + ;
      "call %BUILD_TOOLS%/aapt.exe package -f -M AndroidManifest.xml -S res -I %ANDROID_JAR% -F bin/%APPNAME%.unsigned.apk bin" + crlf + crlf
   IF lHrb
      cBody += "@cd %HDROIDGUI%" + crlf + crlf
   ENDIF
   cBody += "call %BUILD_TOOLS%/aapt.exe add %DEV_HOME%/bin/%APPNAME%.unsigned.apk lib/armeabi/libharbour.so" + crlf + ;
      "@if errorlevel 1 goto end" + crlf + crlf + ;
      "call %BUILD_TOOLS%/aapt.exe add %DEV_HOME%/bin/%APPNAME%.unsigned.apk lib/armeabi/libh4droid.so" + crlf
   IF lHrb
      cBody += "@cd %DEV_HOME%" + crlf + crlf + ;
      "call %BUILD_TOOLS%/aapt.exe add bin/%APPNAME%.unsigned.apk assets/main.hrb" + crlf + crlf
   ENDIF
   cBody += "@rem sign APK" + crlf + ;
      'call %JAVA_HOME%/bin/keytool -genkey -v -keystore myrelease.keystore -alias key2 -keyalg RSA -keysize 2048 -validity 10000 -storepass ' + cPass + ' -keypass ' + cPass + ' -dname "CN=Alex K, O=Harbour, C=RU"' + crlf + ;
      "call %JAVA_HOME%/bin/jarsigner -sigalg SHA1withRSA -digestalg SHA1 -keystore myrelease.keystore -storepass " + cPass + " -keypass " + cPass + " -signedjar bin/%APPNAME%.signed.apk bin/%APPNAME%.unsigned.apk key2" + crlf + ;
      "%BUILD_TOOLS%/zipalign -v 4 bin/%APPNAME%.signed.apk bin/%APPNAME%.apk" + crlf + ;
      ":end" + crlf + crlf + ;
      "@pause"

   FWrite( handle, cBody )
   FClose( handle )

   handle := FCreate( cPath + cdiv + "clear.bat" )
   IF Ferror() != 0
      RETURN .F.
   ENDIF

   cBody := "@call setenv" + crlf + ;
      "@del src\%PACKAGE_PATH%\R.java" + crlf + ;
      "@del /q assets\*.*" + crlf + ;
      "@del /s /f /q bin\*.*" + crlf + ;
      "@del /q *.out" + crlf + ;
      "@rmdir /s /q obj" + crlf + ;
      "@md obj"
   IF !lHrb
      cBody += crlf + "@rmdir /s /q lib" + crlf + ;
         "@md lib" + crlf + ;
         "@rmdir /s /q libs" + crlf + ;
         "@md libs"
   ENDIF

   FWrite( handle, cBody )
   FClose( handle )

   handle := FCreate( cPath + cdiv + "run.bat" )
   IF Ferror() != 0
      RETURN .F.
   ENDIF

   cBody := "@call setenv" + crlf + crlf + ;
      "call %ADB% uninstall %PACKAGE%" + crlf + ;
      "call %ADB% install bin/%APPNAME%.apk" + crlf + crlf + ;
      "call %ADB% shell logcat -c" + crlf + ;
      "call %ADB% shell am start -n %PACKAGE%/%PACKAGE%.%MAIN_CLASS%" + crlf + ;
      "call %ADB% shell logcat Harbour:I *:S > log.txt"

   FWrite( handle, cBody )
   FClose( handle )

   handle := FCreate( cPath + cdiv + "setenv.bat" )
   IF Ferror() != 0
      RETURN .F.
   ENDIF

   cBody := "@set HDROIDGUI=" + cHDGUIPath + crlf + ;
      "@call %HDROIDGUI%/setenv" + crlf + crlf + ;
      "@set APPNAME=" + Atail(aFullName) + crlf + ;
      "@set PACKAGE=" + cPackageDot + crlf + ;
      "@set PACKAGE_PATH=" + cPackageSep + crlf + ;
      "@set MAIN_CLASS=MainActivity" + crlf + ;
      "@set DEV_HOME=%CD%"

   FWrite( handle, cBody )
   FClose( handle )

#endif

   IF !lHrb
      handle := FCreate( cPath + cdiv + "jni" + cdiv + "Android.mk" )
      IF Ferror() != 0
         RETURN .F.
      ENDIF

      cBody := "LOCAL_PATH := $(call my-dir)" + crlf + crlf + ;
         "include $(CLEAR_VARS)" + crlf + ;
         "LOCAL_MODULE := harbour" + crlf + ;
         "LOCAL_SRC_FILES := $(HDROIDGUI)/lib/armeabi/libharbour.so" + crlf + ;
         "LOCAL_EXPORT_C_INCLUDES := $(HRB_INC)" + crlf + ;
         "include $(PREBUILT_SHARED_LIBRARY)" + crlf + crlf + ;         
         "include $(CLEAR_VARS)" + crlf + ;
         "LOCAL_MODULE := h4droida" + crlf + ;
         "LOCAL_SRC_FILES := $(HDROIDGUI)/lib/libh4droida.a" + crlf + ;
         "include $(PREBUILT_STATIC_LIBRARY)" + crlf + ;
         "include $(CLEAR_VARS)" + crlf + crlf + ;        
         "LOCAL_CFLAGS := -I$(HRB_INC)" + crlf + ;
         "LOCAL_SHARED_LIBRARIES := harbour" + crlf + ;
         "LOCAL_MODULE := h4droid" + crlf + ;
         "LOCAL_SRC_FILES := $(SRC_FILES)" + crlf + ;
         "LOCAL_STATIC_LIBRARIES := h4droida" + crlf + crlf + ;        
         "include $(BUILD_SHARED_LIBRARY)" + crlf

      FWrite( handle, cBody )
      FClose( handle )

      handle := FCreate( cPath + cdiv + "jni" + cdiv + "Application.mk" )
      IF Ferror() != 0
         RETURN .F.
      ENDIF

      FWrite( handle, "APP_ABI := armeabi" )
      FClose( handle )

   ENDIF

   RETURN .T.

STATIC FUNCTION CreatePrg( aFullName )

   LOCAL handle, cPath := Atail(aFullName) + cdiv + "src"

   handle := FCreate( cPath + cdiv + "main.prg" )
   IF Ferror() != 0
      RETURN .F.
   ENDIF

   FWrite( handle, crlf + "FUNCTION HDroidMain" + crlf + crlf + "   RETURN NIL" + crlf )
   FClose( handle )

   RETURN .T.

