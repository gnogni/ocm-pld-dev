@echo off
rem --- '3_finalize.cmd' v3.1 by KdL (2023.12.13)

set TIMEOUT=1
set PROJECT=emsx_top
if "%1"=="" color 1f&title FINALIZE for %PROJECT%

:finalize
rem.>%PROJECT%.qpf
rd /S /Q db\ >nul 2>nul
rd /S /Q greybox_tmp\ >nul 2>nul
rd /S /Q incremental_db\ >nul 2>nul
del "## BUILDING FAILED ##.log" >nul 2>nul
del *.done >nul 2>nul
del *.map* >nul 2>nul
del *.pin* >nul 2>nul
del *.rpt* >nul 2>nul
del *.sta* >nul 2>nul
del /S /Q *.bak >nul 2>nul
if "%1"=="" if not exist %PROJECT%.pof goto err_msg
pof2pld %PROJECT%.pof %PROJECT%.pld >nul 2>nul
move %PROJECT%.pof recovery.pof >nul 2>nul
if "%1"=="" echo.&echo Done!
goto timer

:err_msg
if "%1"=="" color f0
echo.&echo '%PROJECT%.pof' not found!

:timer
if "%1"=="" waitfor /T %TIMEOUT% pause >nul 2>nul

:quit
