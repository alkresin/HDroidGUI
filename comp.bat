@call setenv

call %JAVA_HOME%/bin/javac -d libs -cp %ANDROID_JAR% -sourcepath src src/su/harbour/hDroidGUI/*.java
@if errorlevel 1 goto end

@rem jar cvf hdroidgui.jar -C libs .
:end
@pause
