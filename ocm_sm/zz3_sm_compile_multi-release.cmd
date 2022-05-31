@echo off
rem --- 'zz3_sm_compile_multi-release.cmd' v2.7 by KdL (2021.08.23)

set TIMEOUT=1
set PROJECT=ocm_sm
set SRC=C:\intelFPGA_lite\multi-release\
if "%1"=="" color 87&title Multi-Release compiler tool for %PROJECT%
if not exist %PROJECT%_device.env goto err_init
if not exist "%QUARTUS_ROOTDIR%\common\devinfo\cycloneive" goto err_quartus
if not exist %SRC%sm_compile_multi-release.cmd goto err_msg
cd "%SRC%"
start "%SRC%" /d %SRC% /min sm_compile_multi-release.cmd
goto quit

:err_init
if "%1"=="" color f0
echo.&echo Please initialize a device first!
goto timer

:err_quartus
if "%1"=="" color f0
echo.&echo Quartus II was not found or unsupported device!
goto timer

:err_msg
if "%1"=="" color f0
echo.&echo '%SRC%sm_compile_multi-release.cmd' not found!

:timer
if "%1"=="" waitfor /T %TIMEOUT% pause >nul 2>nul

:quit
