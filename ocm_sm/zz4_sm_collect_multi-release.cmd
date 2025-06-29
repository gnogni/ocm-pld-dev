@echo off
rem --- 'zz4_sm_collect_multi-release.cmd' v3.2 by KdL (2025.06.29)

set TIMEOUT=1
set PROJECT=ocm_sm
set PARKING=fw
set SRC=C:\altera_lite\multi-release\
set DEST=..\firmware\
set LOG=## BUILDING FAILED ##.log
set FAIL=NO
if "%1"=="" color 1f&title Multi-Release collector tool for %PROJECT%
if not exist %PROJECT%_device.env goto err_init
set DEVSTR=&set /P DEVICE=<%PROJECT%_device.env
if "%DEVICE%"=="smx" set DEVSTR= for SM-X&set BIOSLOGO=%DEVICE%
if "%DEVICE%"=="sx2" set DEVSTR= for SX-2&set BIOSLOGO=%DEVICE%
if "%DEVICE%"=="sxe" set DEVSTR= for SX-E&set BIOSLOGO=%DEVICE%
if not exist "%QUARTUS_ROOTDIR%\common\devinfo\cycloneive" goto err_quartus
if not exist %SRC% goto err_msg
if "%1"=="" echo.&echo ### NOTICE: the '%DEST%' folder will be updated!
if "%1"=="" echo.&echo Press any key to proceed...&pause >nul
cls&if "%1"=="" echo.&echo Please wait...
if not exist %PROJECT%.qsf.performance.aggressive set OPTMODE=1
if not exist %PROJECT%.qsf.area.aggressive if "%OPTMODE%"=="" (set OPTMODE=2) else (set OPTMODE=0)
if not exist %PROJECT%.qsf.power.higheffort if "%OPTMODE%"=="" (set OPTMODE=3) else (set OPTMODE=0)
if not exist %PROJECT%.qsf.power.aggressive if "%OPTMODE%"=="" (set OPTMODE=4) else (set OPTMODE=0)
if not exist %PROJECT%.qsf.balanced.normal if "%OPTMODE%"=="" (set OPTMODE=5) else (set OPTMODE=0)
if not exist %PROJECT%.qsf.performance.higheffort if "%OPTMODE%"=="" (set OPTMODE=6) else (set OPTMODE=0)
if "%OPTMODE%"=="0" set OPTMODE=(unknown_optimization)
if "%OPTMODE%"=="1" set OPTMODE=(performance_aggressive)
if "%OPTMODE%"=="2" set OPTMODE=(area_aggressive)
if "%OPTMODE%"=="3" set OPTMODE=(power_high_effort)
if "%OPTMODE%"=="4" set OPTMODE=(power_aggressive)
if "%OPTMODE%"=="5" set OPTMODE=(balanced_normal_flow)
if "%OPTMODE%"=="6" set OPTMODE=(performance_high_effort)
set YENSLASH=backslash
set LAYOUT=br
call :cleanup
call :collect_device
set LAYOUT=es
call :cleanup
call :collect_device
set LAYOUT=fr
call :cleanup
call :collect_device
set LAYOUT=it
call :cleanup
call :collect_device
set LAYOUT=us
call :cleanup
call :collect_device
set YENSLASH=yen
set LAYOUT=jp
call :cleanup
call :collect_device
if "%FAIL%"=="NO" rd /S /Q %SRC% >nul 2>nul&if "%1"=="" cls&echo.&echo All done!
if "%FAIL%"=="YES" set TIMEOUT=2&cls&echo.&echo Multi-Release building failed or was partially successful!&if "%1"=="" color f0
goto timer

:cleanup
rd /S /Q %DEST%%DEVICE%_%LAYOUT%_layout\ >nul 2>nul
goto:eof

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
