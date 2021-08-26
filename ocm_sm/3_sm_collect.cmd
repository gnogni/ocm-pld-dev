@echo off
rem --- '3_sm_collect.cmd' v2.7 by KdL (2021.08.23)

set TIMEOUT=1
set PROJECT=ocm_sm
set OUTPUT=output_files\
if "%1"=="" color 1f&title COLLECT for %PROJECT%
if "%1"=="" if not exist %PROJECT%.pld goto err_msg

:collect
if exist old_fw if not exist old_fw\ del old_fw >nul 2>nul
if exist fw if not exist fw\ del fw >nul 2>nul
if exist fw\ if exist old_fw\ rd /S /Q old_fw\ >nul 2>nul
if exist fw\ ren fw old_fw >nul 2>nul
if exist %PROJECT%.pld md fw\ >nul 2>nul
move /Y %PROJECT%.pld fw\ >nul 2>nul
del %PROJECT%.pld >nul 2>nul
move /Y recovery.jic fw\ >nul 2>nul
del recovery.jic >nul 2>nul
move /Y %OUTPUT%%PROJECT%.fit.summary fw\ >nul 2>nul
del %OUTPUT%%PROJECT%.fit.summary >nul 2>nul
ren fw\%PROJECT%.fit.summary fit_summary.log >nul 2>nul
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
