@echo off
rem --- '2_sm_finalize.cmd' v3.1 by KdL (2023.12.13)

set TIMEOUT=1
set PROJECT=ocm_sm
if "%1"=="" color 1f&title FINALIZE for %PROJECT%

:finalize
rem.>%PROJECT%.qpf
rd /S /Q db\ >nul 2>nul
rd /S /Q greybox_tmp\ >nul 2>nul
rd /S /Q incremental_db\ >nul 2>nul
rd /S /Q simulation\ >nul 2>nul
del "## BUILDING FAILED ##.log" >nul 2>nul
del PLLJ_PLLSPE_INFO.txt >nul 2>nul
del *.map* >nul 2>nul
del *.qws* >nul 2>nul
del /S /Q *.bak >nul 2>nul
if "%1"=="" if not exist %PROJECT%.jic goto err_msg
jic2pld %PROJECT%.jic %PROJECT%.pld >nul 2>nul
move %PROJECT%.jic recovery.jic >nul 2>nul
if "%1"=="" echo.&echo Done!
goto timer

:err_msg
if "%1"=="" color f0
echo.&echo '%PROJECT%.jic' not found!

:timer
if "%1"=="" waitfor /T %TIMEOUT% pause >nul 2>nul

:quit
