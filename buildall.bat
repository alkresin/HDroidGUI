@call setenv
@call clear
@call ndkBuild
@if exist lib\%NDK_TARGET%\libh4droid.so goto comp
@echo Errors while compiling C sources
@pause
@goto end

:comp
@call comp

:end