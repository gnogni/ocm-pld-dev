@echo off
rem --- '3_sm_collect.cmd' v3.1 by KdL (2023.12.13)

set TIMEOUT=1
set PROJECT=ocm_sm
set PARKING=fw
set OUTPUT=output_files\
if "%1"=="" color 1f&title COLLECT for %PROJECT%
if "%1"=="" if not exist %PROJECT%.pld goto err_msg

:collect
if exist old_%PARKING% if not exist old_%PARKING%\ del old_%PARKING% >nul 2>nul
if exist %PARKING% if not exist %PARKING%\ del %PARKING% >nul 2>nul
if exist %PARKING%\ if exist old_%PARKING%\ rd /S /Q old_%PARKING%\ >nul 2>nul
if exist %PARKING%\ ren %PARKING%\ old_%PARKING% >nul 2>nul
if exist %PROJECT%.pld md %PARKING%\ >nul 2>nul
move %PROJECT%.pld %PARKING%\ >nul 2>nul
move recovery.jic %PARKING%\ >nul 2>nul
move %OUTPUT%%PROJECT%.fit.summary %PARKING%\fit_summary.log >nul 2>nul
del %PROJECT%.pld >nul 2>nul
del recovery.jic >nul 2>nul
del %OUTPUT%%PROJECT%.fit.summary >nul 2>nul
if "%1"=="" cls&echo.&echo Done!
goto quit_0

:err_msg
if "%1"=="" color f0
echo.&echo '%PROJECT%.pld' not found!

:quit_0
if "%1"=="" del "## BUILDING FAILED ##.log" >nul 2>nul
if "%1"=="" rd /S /Q %OUTPUT% >nul 2>nul

:timer
if "%1"=="" waitfor /T %TIMEOUT% pause >nul 2>nul

:quit
