@echo off
rem --- '!!-init-sx2.cmd' v2.7 by KdL (2021.08.23)

set TIMEOUT=1
set FOLDER=init_
set DEVICE=sx2
if "%1"=="" color 1f&title INIT for SX-2
if not exist "%FOLDER%%DEVICE%\" goto err_msg
rem ---------------cleanup----------------
call !!-cleanup.cmd --no-wait
rem --------------------------------------

:sx2
rem.>"__%DEVICE%__"
xcopy /S /E /Y "%FOLDER%%DEVICE%\*.*" >nul 2>nul
echo.&echo SX-2 is ready to compile!
goto timer

:err_msg
if "%1"=="" color f0
echo.&echo '%FOLDER%%DEVICE%\' not found!

:timer
if "%1"=="" waitfor /T %TIMEOUT% pause >nul 2>nul

:quit
