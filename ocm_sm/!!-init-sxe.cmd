@echo off
rem --- '!!-init-sxe.cmd' v3.2 by KdL (2025.06.29)

set TIMEOUT=1
set FOLDER=init_
set DEVICE=sxe
if "%1"=="" color 1f&title INIT for SX-E
if not exist "%FOLDER%%DEVICE%\" goto err_msg
rem ---------------cleanup----------------
call !!-cleanup.cmd --no-wait
rem --------------------------------------

:sxe
rem.>"__%DEVICE%__"
xcopy /S /E /Y "%FOLDER%%DEVICE%\*.*" >nul 2>nul
echo.&echo SX-E is ready to compile!
goto timer

:err_msg
if "%1"=="" color f0
echo.&echo '%FOLDER%%DEVICE%\' not found!

:timer
if "%1"=="" waitfor /T %TIMEOUT% pause >nul 2>nul

:quit
