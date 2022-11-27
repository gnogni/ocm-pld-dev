@echo off
rem --- '1_swap.cmd' v3.0 by KdL (2022.11.27)

set TIMEOUT=1
set PROJECT=emsx_top
if "%1"=="" if exist "__1chipmsx__" color 4f
if "%1"=="" if exist "__zemmixneo__" color 1f
if "%1"=="" title SWAP for %PROJECT%
rem ---------------cleanup----------------
call 3_finalize.cmd --no-wait
rem --------------------------------------

:zemmixneo
if not exist %PROJECT%_304k.hex.backslash.zemmixneo goto msxplusplus
ren %PROJECT%_304k.hex %PROJECT%_304k.hex.backslash.msxplusplus
ren %PROJECT%_304k.hex.backslash.zemmixneo %PROJECT%_304k.hex
if exist %PROJECT%.pld ren %PROJECT%.pld %PROJECT%.pld.1chipmsx >nul 2>nul
if exist recovery.pof ren recovery.pof recovery.pof.1chipmsx >nul 2>nul
if exist %PROJECT%.fit.summary ren %PROJECT%.fit.summary %PROJECT%.fit.summary.1chipmsx >nul 2>nul
del "__1chipmsx__"
rem.>"__zemmixneo__"
cd src\peripheral\
ren swioports.vhd swioports.vhd.1chipmsx >nul 2>nul
ren swioports.vhd.japanese swioports.vhd.japanese.1chipmsx >nul 2>nul
ren swioports.vhd.zemmixneo swioports.vhd >nul 2>nul
ren swioports.vhd.japanese.zemmixneo swioports.vhd.japanese >nul 2>nul
cd ..
ren emsx_top.vhd emsx_top.vhd.1chipmsx >nul 2>nul
ren emsx_top.vhd.zemmixneo emsx_top.vhd >nul 2>nul

if "%1"=="" cls&echo.&echo Zemmix Neo is ready to compile!
goto timer

:msxplusplus
if not exist %PROJECT%_304k.hex.backslash.msxplusplus goto err_msg
ren %PROJECT%_304k.hex %PROJECT%_304k.hex.backslash.zemmixneo
ren %PROJECT%_304k.hex.backslash.msxplusplus %PROJECT%_304k.hex
if exist %PROJECT%.pld ren %PROJECT%.pld %PROJECT%.pld.zemmixneo >nul 2>nul
if exist recovery.pof ren recovery.pof recovery.pof.zemmixneo >nul 2>nul
if exist %PROJECT%.fit.summary ren %PROJECT%.fit.summary %PROJECT%.fit.summary.zemmixneo >nul 2>nul
del "__zemmixneo__"
rem.>"__1chipmsx__"
cd src\peripheral\
ren swioports.vhd swioports.vhd.zemmixneo >nul 2>nul
ren swioports.vhd.japanese swioports.vhd.japanese.zemmixneo >nul 2>nul
ren swioports.vhd.1chipmsx swioports.vhd >nul 2>nul
ren swioports.vhd.japanese.1chipmsx swioports.vhd.japanese >nul 2>nul
cd ..
ren emsx_top.vhd emsx_top.vhd.zemmixneo >nul 2>nul
ren emsx_top.vhd.1chipmsx emsx_top.vhd >nul 2>nul

if "%1"=="" cls&echo.&echo 1chipMSX is ready to compile!  ^(default^)
goto timer

:err_msg
if "%1"=="" color f0
echo.&echo '%PROJECT%_304k.hex.backslash.???' not found!

:timer
if "%1"=="" waitfor /T %TIMEOUT% pause >nul 2>nul

:quit
