@echo off
rem --- 'zz4_sm_collect_multi-release.cmd' v2.9 by KdL (2022.11.27)

set TIMEOUT=1
set PROJECT=ocm_sm
set PARKING=fw
set SRC=C:\intelFPGA_lite\multi-release\
set DEST=..\firmware\
set LOG=## BUILDING FAILED ##.log
set FAIL=NO
if "%1"=="" color 1f&title Multi-Release collector tool for %PROJECT%
if not exist %PROJECT%_device.env goto err_init
set DEVSTR=&set /P DEVICE=<%PROJECT%_device.env
if "%DEVICE%"=="smx" set DEVSTR= for SM-X&set BIOSLOGO=%DEVICE%
if "%DEVICE%"=="sx2" set DEVSTR= for SX-2&set BIOSLOGO=%DEVICE%
if not exist "%QUARTUS_ROOTDIR%\common\devinfo\cycloneive" goto err_quartus
if not exist %SRC% goto err_msg
if "%1"=="" echo.&echo ### NOTICE: the '%DEST%' folder will be updated!
if "%1"=="" echo.&echo Press any key to proceed...&pause >nul
cls&if "%1"=="" echo.&echo Please wait...
rem ---------------cleanup----------------
rd /S /Q %DEST%%DEVICE%_br_layout\ >nul 2>nul
rd /S /Q %DEST%%DEVICE%_es_layout\ >nul 2>nul
rd /S /Q %DEST%%DEVICE%_fr_layout\ >nul 2>nul
rd /S /Q %DEST%%DEVICE%_it_layout\ >nul 2>nul
rd /S /Q %DEST%%DEVICE%_jp_layout\ >nul 2>nul
rd /S /Q %DEST%%DEVICE%_us_layout\ >nul 2>nul
rem --------------------------------------
if not exist %PROJECT%.qsf.area.off set OPTMODE=1
if not exist %PROJECT%.qsf.area.normal if "%OPTMODE%"=="" (set OPTMODE=2) else (set OPTMODE=0)
if not exist %PROJECT%.qsf.area.extraeffort if "%OPTMODE%"=="" (set OPTMODE=3) else (set OPTMODE=0)
if not exist %PROJECT%.qsf.balanced.off if "%OPTMODE%"=="" (set OPTMODE=4) else (set OPTMODE=0)
if not exist %PROJECT%.qsf.balanced.normal if "%OPTMODE%"=="" (set OPTMODE=5) else (set OPTMODE=0)
if not exist %PROJECT%.qsf.balanced.extraeffort if "%OPTMODE%"=="" (set OPTMODE=6) else (set OPTMODE=0)
if "%OPTMODE%"=="0" set OPTMODE=(unknown_optimization)
if "%OPTMODE%"=="1" set OPTMODE=(area_powerplay_off)
if "%OPTMODE%"=="2" set OPTMODE=(area_normal_compilation)
if "%OPTMODE%"=="3" set OPTMODE=(area_extra_effort)
if "%OPTMODE%"=="4" set OPTMODE=(balanced_powerplay_off)
if "%OPTMODE%"=="5" set OPTMODE=(balanced_normal_compilation)
if "%OPTMODE%"=="6" set OPTMODE=(balanced_extra_effort)
set YENSLASH=backslash
set LAYOUT=br
call :collect_device
set LAYOUT=es
call :collect_device
set LAYOUT=fr
call :collect_device
set LAYOUT=it
call :collect_device
set LAYOUT=us
call :collect_device
set YENSLASH=yen
set LAYOUT=jp
call :collect_device
rem ---------------cleanup----------------
if "%FAIL%"=="NO" rd /S /Q %SRC% >nul 2>nul
rem --------------------------------------
if "%FAIL%"=="NO" if "%1"=="" cls&echo.&echo All done!
if "%FAIL%"=="YES" set TIMEOUT=2&cls&echo.&echo Multi-Release building failed!&if "%1"=="" color f0
goto timer

:collect_device
set INPDIR=%SRC%%LAYOUT%_dual_epbios\%PROJECT%\
if not exist "%INPDIR%%LOG%" if not exist "%INPDIR%%PARKING%\" set FAIL=YES&echo Task canceled "%INPDIR%%PROJECT%.qpf"%DEVSTR%>>"%LOG%"&goto:eof
if exist "%INPDIR%%LOG%" set FAIL=YES&echo Task failed "%INPDIR%%PROJECT%.qpf"%DEVSTR%>>"%LOG%"&goto:eof
set OUTDIR=%DEST%%DEVICE%_%LAYOUT%_layout\dual_epbios_%BIOSLOGO%_%YENSLASH%\
md %OUTDIR% >nul 2>nul
if not "%OPTMODE%"=="" rem.>"%OUTDIR%%OPTMODE%"
copy /Y %INPDIR%%PARKING%\%PROJECT%.pld %OUTDIR% >nul 2>nul
copy /Y %INPDIR%%PARKING%\recovery.jic %OUTDIR% >nul 2>nul
cd %INPDIR%
set CONFIG=%PROJECT%_512k_single_epbios_%YENSLASH%
copy /Y %CONFIG%.cof %PROJECT%_512k.cof >nul 2>nul
if exist "%QUARTUS_ROOTDIR%\bin64" set BIT=64
"%QUARTUS_ROOTDIR%\bin%BIT%\quartus_cpf.exe" -c %PROJECT%_512k.cof >nul 2>nul
del %PROJECT%_512k.cof >nul 2>nul
call 2_sm_finalize.cmd --no-wait
call 3_sm_collect.cmd --no-wait
cd %~dp0
set OUTDIR=%DEST%%DEVICE%_%LAYOUT%_layout\single_epbios_%BIOSLOGO%_%YENSLASH%\
md %OUTDIR% >nul 2>nul
if not "%OPTMODE%"=="" rem.>"%OUTDIR%%OPTMODE%"
copy /Y %INPDIR%%PARKING%\%PROJECT%.pld %OUTDIR% >nul 2>nul
copy /Y %INPDIR%%PARKING%\recovery.jic %OUTDIR% >nul 2>nul
goto:eof

:err_init
if "%1"=="" color f0
echo.&echo Please initialize a device first!
goto timer

:err_quartus
if "%1"=="" color f0
echo.&echo Quartus Prime was not found or unsupported device!
goto timer

:err_msg
if "%1"=="" color f0
echo.&echo '%SRC%' not found!

:timer
if "%1"=="" waitfor /T %TIMEOUT% pause >nul 2>nul

:quit
