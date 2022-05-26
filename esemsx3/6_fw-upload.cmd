@echo off
rem --- '6_fw-upload.cmd' v2.7 by KdL (2021.08.23)

set TIMEOUT=1
set PROJECT=emsx_top
set CABLE="USB-Blaster [USB-0]"
if "%1"=="" color 1f&title FW-UPLOAD for %PROJECT%
if not exist "%QUARTUS_ROOTDIR%\common\devinfo\cyclone" goto err_quartus
if not exist fw\recovery.pof goto err_msg
if "%1"=="" echo.&echo Hardware Setup: %CABLE%&echo.&echo Press any key to start programming...&pause >nul 2>nul&cls
echo.&echo Uploading...&echo.&echo Firmware: "%~dp0fw\recovery.pof"&echo.
copy /Y fw\recovery.pof %PROJECT%.pof >nul 2>nul
set QPGM=%QUARTUS_ROOTDIR%\bin\quartus_pgm.exe
if not exist %QPGM% goto err_quartus
"%QPGM%" -c %CABLE% %PROJECT%.cdf >nul 2>nul
if not %ERRORLEVEL% == 0 "%QPGM%" -c %CABLE% %PROJECT%.cdf >nul 2>nul
if %ERRORLEVEL% == 0 (cls&echo.&echo PROGRAMMING SUCCEEDED!) else (color 4f&cls&echo.&echo PROGRAMMING FAILED!)
del %PROJECT%.pof >nul 2>nul
goto timer

:err_quartus
if "%1"=="" color f0
if "%1"=="" echo.&echo Quartus II was not found or unsupported device!
goto timer

:err_msg
if "%1"=="" color f0
echo.&echo 'fw\recovery.pof' not found!

:timer
waitfor /T %TIMEOUT% pause >nul 2>nul

:quit
set EXITSTR=FW-UPLOAD for %PROJECT%  (%RANDOM%)
if "%1"=="--auto-collect" set EXITSTR=AUTO-COLLECT for %PROJECT%  (%RANDOM%)
title %EXITSTR%
for /f "tokens=2" %%G in ('tasklist /v^|findstr "%EXITSTR%"') do set CURRPID=ParentProcessId=%%~G and Name='conhost.exe'
for /f "usebackq" %%G in (`wmic process where "%CURRPID%" get ProcessId^,WindowsVersion^|findstr /r "[0-9]"`) do taskkill /f /fi "PID eq %%~G"
