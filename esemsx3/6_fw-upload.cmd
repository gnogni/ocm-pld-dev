@echo off
rem --- '6_fw-upload.cmd' v3.2 by KdL (2025.06.29)

set TIMEOUT=1
set PROJECT=emsx_top
set PARKING=fw
set CABLE="USB-Blaster [USB-0]"
if "%1"=="" color 1f&title FW-UPLOAD for %PROJECT%
if not exist "%QUARTUS_ROOTDIR%\common\devinfo\cyclone" goto err_quartus
if not exist %PARKING%\recovery.pof goto err_msg

:fw_upload
if "%1"=="" (
echo.&echo Hardware Setup: %CABLE%&echo.&echo Press any key to start programming, [E] to perform a full erase...
set ERASE=&for /f "delims=" %%a in ('xcopy /l /w "%~f0" "%~f0" 2^>nul') do (if not defined ERASE set "ERASE=%%a")
)&cls
if "%1"=="" if /I "%ERASE:~-1%"=="E" set ERASE=YES
copy /Y %PARKING%\recovery.pof %PROJECT%.pof >nul 2>nul
set QPGM=%QUARTUS_ROOTDIR%\bin\quartus_pgm.exe
if not exist %QPGM% goto err_quartus

:init
if "%2"=="--full-erase" set ERASE=YES
echo.&if /I "%ERASE%"=="YES" echo Erasing ASP configuration device...&echo.&"%QPGM%" -c %CABLE% %PROJECT%_erase.cdf >nul 2>nul&if "%1"=="" cls&echo.
echo Programming device...&echo.&echo Firmware: "%~dp0%PARKING%\recovery.pof"&echo.
"%QPGM%" -c %CABLE% %PROJECT%.cdf >nul 2>nul
if not %ERRORLEVEL% == 0 "%QPGM%" -c %CABLE% %PROJECT%.cdf >nul 2>nul
if %ERRORLEVEL% == 0 (cls&echo.&echo PROGRAMMING SUCCEEDED!) else (color 4f&cls&echo.&echo PROGRAMMING FAILED!)&set TIMEOUT=2
del %PROJECT%.pof >nul 2>nul
goto timer

:err_quartus
if "%1"=="" color f0
if "%1"=="" echo.&echo Quartus II was not found or unsupported device!
goto timer

:err_msg
if "%1"=="" color f0
echo.&echo '%PARKING%\recovery.pof' not found!

:timer
waitfor /T %TIMEOUT% pause >nul 2>nul

:quit
if not "%1"=="--auto-collect" exit
set EXITSTR=AUTO-COLLECT for %PROJECT%  (%RANDOM%)
title %EXITSTR%
for /f "tokens=2" %%G in ('tasklist /v^|findstr "%EXITSTR%"') do set CURRPID=ParentProcessId=%%~G and Name='conhost.exe'
for /f "usebackq" %%G in (`wmic process where "%CURRPID%" get ProcessId^,WindowsVersion^|findstr /r "[0-9]"`) do taskkill /f /fi "PID eq %%~G"
pause >nul 2>nul
