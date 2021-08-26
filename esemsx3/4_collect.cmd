@echo off
rem --- '4_collect.cmd' v2.7 by KdL (2021.08.23)

set TIMEOUT=1
set PROJECT=emsx_top
if "%1"=="" color 1f&title COLLECT for %PROJECT%
if exist %PROJECT%.pld.1chipmsx goto collect
if exist %PROJECT%.pld.zemmixneo goto collect
if "%1"=="" if not exist %PROJECT%.pld goto err_msg

:collect
if exist old_fw if not exist old_fw\ del old_fw >nul 2>nul
if exist fw if not exist fw\ del fw >nul 2>nul
if exist fw\ if exist old_fw\ rd /S /Q old_fw\ >nul 2>nul
if exist fw\ ren fw old_fw >nul 2>nul
if exist %PROJECT%.pld.1chipmsx md fw\1chipmsx\ >nul 2>nul
move /Y %PROJECT%.pld.1chipmsx fw\1chipmsx\ >nul 2>nul
del %PROJECT%.pld.1chipmsx >nul 2>nul
move /Y recovery.pof.1chipmsx fw\1chipmsx\ >nul 2>nul
del recovery.pof.1chipmsx >nul 2>nul
move /Y %PROJECT%.fit.summary.1chipmsx fw\1chipmsx\ >nul 2>nul
del %PROJECT%.fit.summary.1chipmsx >nul 2>nul
ren fw\1chipmsx\%PROJECT%.pld.1chipmsx %PROJECT%.pld >nul 2>nul
ren fw\1chipmsx\recovery.pof.1chipmsx recovery.pof >nul 2>nul
ren fw\1chipmsx\%PROJECT%.fit.summary.1chipmsx fit_summary.log >nul 2>nul
if exist %PROJECT%.pld.zemmixneo md fw\zemmixneo\ >nul 2>nul
move /Y %PROJECT%.pld.zemmixneo fw\zemmixneo\ >nul 2>nul
del %PROJECT%.pld.zemmixneo >nul 2>nul
move /Y recovery.pof.zemmixneo fw\zemmixneo\ >nul 2>nul
del recovery.pof.zemmixneo >nul 2>nul
move /Y %PROJECT%.fit.summary.zemmixneo fw\zemmixneo\ >nul 2>nul
del %PROJECT%.fit.summary.zemmixneo >nul 2>nul
ren fw\zemmixneo\%PROJECT%.pld.zemmixneo %PROJECT%.pld >nul 2>nul
ren fw\zemmixneo\recovery.pof.zemmixneo recovery.pof >nul 2>nul
ren fw\zemmixneo\%PROJECT%.fit.summary.zemmixneo fit_summary.log >nul 2>nul
if exist %PROJECT%.pld md fw\ >nul 2>nul
move /Y %PROJECT%.pld fw\ >nul 2>nul
del %PROJECT%.pld >nul 2>nul
move /Y recovery.pof fw\ >nul 2>nul
del recovery.pof >nul 2>nul
move /Y %PROJECT%.fit.summary fw\ >nul 2>nul
del %PROJECT%.fit.summary >nul 2>nul
ren fw\%PROJECT%.fit.summary fit_summary.log >nul 2>nul
if "%1"=="" cls&echo.&echo Done!
goto quit_0

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
