@echo off
rem --- '2_compile.cmd' v3.0 by KdL (2022.11.27)

set TIMEOUT=1
set PROJECT=emsx_top
set QPATH=C:\Altera\11.0sp1\quartus\
if "%1"=="" color 87&title COMPILE for %PROJECT%
if not exist %PROJECT%.qpf goto err_msg

:compile
if exist %QPATH%bin\quartus.exe (
    start %QPATH%bin\quartus.exe %PROJECT%.qpf
    goto init
)
if not exist "%QUARTUS_ROOTDIR%\common\devinfo\cyclone" goto err_quartus
explorer %PROJECT%.qpf

:init
del "## BUILDING FAILED ##.log" >nul 2>nul
goto quit

:err_quartus
if "%1"=="" color f0
echo.&echo Quartus II was not found or unsupported device!
goto timer

:err_msg
if "%1"=="" color f0
echo.&echo '%PROJECT%.qpf' not found!

:timer
if "%1"=="" waitfor /T %TIMEOUT% pause >nul 2>nul

:quit
