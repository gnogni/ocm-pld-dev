@echo off
rem --- 'zz3_compile_multi-release.cmd' v2.8 by KdL (2022.09.24)

set TIMEOUT=1
set PROJECT=emsx_top
set SRC=C:\Altera\multi-release\
if "%1"=="" color 87&title Multi-Release compiler tool for %PROJECT%
if not exist "%QUARTUS_ROOTDIR%\common\devinfo\cyclone" goto err_quartus
if not exist %SRC%compile_multi-release.cmd goto err_msg
cd "%SRC%"
start "%SRC%" /d %SRC% /min compile_multi-release.cmd
goto quit

:err_quartus
if "%1"=="" color f0
echo.&echo Quartus II was not found or unsupported device!
goto timer

:err_msg
if "%1"=="" color f0
echo.&echo '%SRC%compile_multi-release.cmd' not found!

:timer
if "%1"=="" waitfor /T %TIMEOUT% pause >nul 2>nul

:quit
