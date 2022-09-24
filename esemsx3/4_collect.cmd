@echo off
rem --- '4_collect.cmd' v2.8 by KdL (2022.09.24)

set TIMEOUT=1
set PROJECT=emsx_top
set PARKING=fw
set DEVICE1=1chipmsx
set DEVICE2=zemmixneo
if "%1"=="" color 1f&title COLLECT for %PROJECT%
if exist %PROJECT%.pld.%DEVICE1% goto collect
if exist %PROJECT%.pld.%DEVICE2% goto collect
if "%1"=="" if not exist %PROJECT%.pld goto err_msg

:collect
if exist old_%PARKING% if not exist old_%PARKING%\ del old_%PARKING% >nul 2>nul
if exist %PARKING% if not exist %PARKING%\ del %PARKING% >nul 2>nul
if exist %PARKING%\ if exist old_%PARKING%\ rd /S /Q old_%PARKING%\ >nul 2>nul
if exist %PARKING%\ ren %PARKING%\ old_%PARKING% >nul 2>nul
set DEVICE=DEVICE1
call :collect_device
set DEVICE=DEVICE2
call :collect_device
if exist %PROJECT%.pld md %PARKING%\ >nul 2>nul
move %PROJECT%.pld %PARKING%\ >nul 2>nul
move recovery.pof %PARKING%\ >nul 2>nul
move %PROJECT%.fit.summary %PARKING%\fit_summary.log >nul 2>nul
del %PROJECT%.pld >nul 2>nul
del recovery.pof >nul 2>nul
del %PROJECT%.fit.summary >nul 2>nul
if "%1"=="" cls&echo.&echo Done!
goto quit_0

:collect_device
if exist %PROJECT%.pld.%DEVICE% md %PARKING%\%DEVICE%\ >nul 2>nul
move %PROJECT%.pld.%DEVICE% %PARKING%\%DEVICE%\%PROJECT%.pld >nul 2>nul
move recovery.pof.%DEVICE% %PARKING%\%DEVICE%\recovery.pof >nul 2>nul
move %PROJECT%.fit.summary.%DEVICE% %PARKING%\%DEVICE%\fit_summary.log >nul 2>nul
del %PROJECT%.pld.%DEVICE% >nul 2>nul
del recovery.pof.%DEVICE% >nul 2>nul
del %PROJECT%.fit.summary.%DEVICE% >nul 2>nul
goto:eof

:err_msg
if "%1"=="" color f0
echo.&echo '%PROJECT%.pld' not found!

:quit_0
if "%1"=="" del "## BUILDING FAILED ##.log" >nul 2>nul
if "%1"=="" del *.sof >nul 2>nul
if "%1"=="" del *.rbf >nul 2>nul

:timer
if "%1"=="" waitfor /T %TIMEOUT% pause >nul 2>nul

:quit
