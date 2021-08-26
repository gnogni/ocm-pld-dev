@echo off
rem --- '!!-cleanup.cmd' v2.7 by KdL (2021.08.23)

set PROJECT1=emsx_top
set PROJECT2=ocm_sm
if "%1"=="" color 1f&title ### WARNING !! ###
for %%I in (.) do set DIR=%%~nxI
if "%1"=="" echo.&echo Current folder: %DIR%\
if "%1"=="" echo.&echo The cleanup tool is ready to proceed, press any key...
if "%1"=="" pause >nul 2>nul
if "%1"=="" cls
if "%1"=="" echo.&echo Cleaning up...
if exist %PROJECT1%.qpf goto %PROJECT1%
if exist %PROJECT2%.qpf goto %PROJECT2%
goto quit

:emsx_top
call 3_finalize.cmd --no-wait
call 4_collect.cmd --no-wait
set PROJECT=%PROJECT1%
del *.sof >nul 2>nul
del *.rbf >nul 2>nul
goto done

:ocm_sm
call 2_sm_finalize.cmd --no-wait
call 3_sm_collect.cmd --no-wait
set PROJECT=%PROJECT2%
set OUTPUT=output_files\
rd /S /Q %OUTPUT% >nul 2>nul
del src_addons\peripheral\sm_swioports.vhd* >nul 2>nul
del src_addons\sys\pll.vhd >nul 2>nul
del src_addons\top.vhd >nul 2>nul
del "__*__" >nul 2>nul
del *.cdf >nul 2>nul
del *.qsf* >nul 2>nul
del *.cof >nul 2>nul
del *.hex >nul 2>nul
del %PROJECT%_device.env >nul 2>nul
del zz0*.* >nul 2>nul

:done
set DEST=C:\Altera\multi-release\
if exist %DEST% rd /S /Q %DEST% >nul 2>nul
if "%1"=="" echo.&echo Done!

:quit
