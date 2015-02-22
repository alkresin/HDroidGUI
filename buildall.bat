@call clear
@call ndkBuild
@if exist lib\armeabi\libh4droid.so goto comp
@echo Errors while compiling C sources
@pause
@goto end

:comp
@call comp

:end