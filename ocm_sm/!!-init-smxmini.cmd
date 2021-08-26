@echo off
rem --- '!!-init-smx.cmd' v2.7 by KdL (2021.08.23)

set TIMEOUT=1
set FOLDER=init_
set DEVICE=smxmini
if "%1"=="" color 6f&title INIT for SM-X Mini
if not exist "%FOLDER%%DEVICE%\" goto err_msg
rem ---------------cleanup----------------
call !!-cleanup.cmd --no-wait
rem --------------------------------------

:smx
rem.>"__%DEVICE%__"
xcopy /S /E /Y "%FOLDER%%DEVICE%\*.*" >nul 2>nul
echo.&echo SM-X Mini is ready to compile!
goto timer

:err_msg
if "%1"=="" color f0
echo.&echo '%FOLDER%%DEVICE%\' not found!

:timer
if "%1"=="" waitfor /T %TIMEOUT% pause >nul 2>nul

:quit
