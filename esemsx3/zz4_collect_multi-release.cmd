@echo off
rem --- 'zz4_collect_multi-release.cmd' v3.2 by KdL (2025.06.29)

set TIMEOUT=1
set PROJECT=emsx_top
set PARKING=fw
set SRC=C:\Altera\multi-release\
set DEST=..\firmware\
set LOG=## BUILDING FAILED ##.log
set FAIL=NO
if "%1"=="" color 1f&title Multi-Release collector tool for %PROJECT%
if not exist "%QUARTUS_ROOTDIR%\common\devinfo\cyclone" goto err_quartus
if not exist %SRC% goto err_msg
if "%1"=="" echo.&echo ### NOTICE: the '%DEST%' folder will be updated!
if "%1"=="" echo.&echo Press any key to proceed...&pause >nul
cls&if "%1"=="" echo.&echo Please wait...
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
call :cleanup
call :collect_1chipmsx
call :collect_sx1mini
call :collect_zemmixneo
set LAYOUT=es
call :cleanup
call :collect_1chipmsx
call :collect_sx1mini
call :collect_zemmixneo
set LAYOUT=fr
call :cleanup
call :collect_1chipmsx
call :collect_sx1mini
call :collect_zemmixneo
set LAYOUT=it
call :cleanup
call :collect_1chipmsx
call :collect_sx1mini
call :collect_zemmixneo
set LAYOUT=us
call :cleanup
call :collect_1chipmsx
call :collect_sx1mini
call :collect_zemmixneo
set YENSLASH=yen
set LAYOUT=jp
call :cleanup
call :collect_1chipmsx
call :collect_sx1mini
call :collect_zemmixneo
if "%FAIL%"=="NO" rd /S /Q %SRC% >nul 2>nul&if "%1"=="" cls&echo.&echo All done!
if "%FAIL%"=="YES" set TIMEOUT=2&cls&echo.&echo Multi-Release building failed or was partially successful!&if "%1"=="" color f0
goto timer

:cleanup
rd /S /Q %DEST%1chipmsx_%LAYOUT%_layout\ >nul 2>nul
rd /S /Q %DEST%sx1mini_%LAYOUT%_layout\ >nul 2>nul
rd /S /Q %DEST%zemmixneo_%LAYOUT%_layout\ >nul 2>nul
goto:eof

:collect_1chipmsx
set INPDIR=%SRC%esemsx3_%LAYOUT%_1chipmsx\
if not exist "%INPDIR%%LOG%" if not exist "%INPDIR%%PARKING%\" set FAIL=YES&echo Task canceled "%INPDIR%%PROJECT%.qpf">>"%LOG%"&goto:eof
if exist "%INPDIR%%LOG%" set FAIL=YES&echo Task failed "%INPDIR%%PROJECT%.qpf">>"%LOG%"&goto:eof
set OUTDIR=%DEST%1chipmsx_%LAYOUT%_layout\single_epbios_msxplusplus_%YENSLASH%\
md %OUTDIR% >nul 2>nul
if not "%OPTMODE%"=="" rem.>"%OUTDIR%%OPTMODE%"
copy /Y %INPDIR%%PARKING%\%PROJECT%.pld %OUTDIR% >nul 2>nul
copy /Y %INPDIR%%PARKING%\recovery.pof %OUTDIR% >nul 2>nul
cd %INPDIR%
move %PROJECT%_304k.hex.%YENSLASH%.msx2plus %PROJECT%_304k.hex >nul 2>nul
"%QUARTUS_ROOTDIR%\bin\quartus_cpf.exe" -c %PROJECT%_304k.cof >nul 2>nul
call 3_finalize.cmd --no-wait
call 4_collect.cmd --no-wait
cd %~dp0
set OUTDIR=%DEST%1chipmsx_%LAYOUT%_layout\single_epbios_msx2plus_%YENSLASH%\
md %OUTDIR% >nul 2>nul
if not "%OPTMODE%"=="" rem.>"%OUTDIR%%OPTMODE%"
copy /Y %INPDIR%%PARKING%\%PROJECT%.pld %OUTDIR% >nul 2>nul
copy /Y %INPDIR%%PARKING%\recovery.pof %OUTDIR% >nul 2>nul
goto:eof

:collect_sx1mini
set INPDIR=%SRC%esemsx3_%LAYOUT%_sx1mini\
if not exist "%INPDIR%%LOG%" if not exist "%INPDIR%%PARKING%\" set FAIL=YES&echo Task canceled "%INPDIR%%PROJECT%.qpf">>"%LOG%"&goto:eof
if exist "%INPDIR%%LOG%" set FAIL=YES&echo Task failed "%INPDIR%%PROJECT%.qpf">>"%LOG%"&goto:eof
cd %INPDIR%
move %PROJECT%_304k.hex.%YENSLASH%.sx1 %PROJECT%_304k.hex >nul 2>nul
"%QUARTUS_ROOTDIR%\bin\quartus_cpf.exe" -c %PROJECT%_304k.cof >nul 2>nul
call 3_finalize.cmd --no-wait
call 4_collect.cmd --no-wait
cd %~dp0
set OUTDIR=%DEST%sx1mini_%LAYOUT%_layout\single_epbios_sx1_%YENSLASH%\
md %OUTDIR% >nul 2>nul
if not "%OPTMODE%"=="" rem.>"%OUTDIR%%OPTMODE%"
copy /Y %INPDIR%%PARKING%\%PROJECT%.pld %OUTDIR% >nul 2>nul
copy /Y %INPDIR%%PARKING%\recovery.pof %OUTDIR% >nul 2>nul
goto:eof

:collect_zemmixneo
set INPDIR=%SRC%esemsx3_%LAYOUT%_zemmixneo\
if not exist "%INPDIR%%LOG%" if not exist "%INPDIR%%PARKING%\" set FAIL=YES&echo Task canceled "%INPDIR%%PROJECT%.qpf">>"%LOG%"&goto:eof
if exist "%INPDIR%%LOG%" set FAIL=YES&echo Task failed "%INPDIR%%PROJECT%.qpf">>"%LOG%"&goto:eof
set OUTDIR=%DEST%zemmixneo_%LAYOUT%_layout\single_epbios_zemmixneo_%YENSLASH%\
md %OUTDIR% >nul 2>nul
if not "%OPTMODE%"=="" rem.>"%OUTDIR%%OPTMODE%"
copy /Y %INPDIR%%PARKING%\%PROJECT%.pld %OUTDIR% >nul 2>nul
copy /Y %INPDIR%%PARKING%\recovery.pof %OUTDIR% >nul 2>nul
cd %INPDIR%
move %PROJECT%_304k.hex.%YENSLASH%.zemmixneobr %PROJECT%_304k.hex >nul 2>nul
"%QUARTUS_ROOTDIR%\bin\quartus_cpf.exe" -c %PROJECT%_304k.cof >nul 2>nul
call 3_finalize.cmd --no-wait
call 4_collect.cmd --no-wait
cd %~dp0
set OUTDIR=%DEST%zemmixneo_%LAYOUT%_layout\single_epbios_zemmixneobr_%YENSLASH%\
md %OUTDIR% >nul 2>nul
if not "%OPTMODE%"=="" rem.>"%OUTDIR%%OPTMODE%"
copy /Y %INPDIR%%PARKING%\%PROJECT%.pld %OUTDIR% >nul 2>nul
copy /Y %INPDIR%%PARKING%\recovery.pof %OUTDIR% >nul 2>nul
cd %INPDIR%
move %PROJECT%_304k.hex.%YENSLASH%.sx1 %PROJECT%_304k.hex >nul 2>nul
"%QUARTUS_ROOTDIR%\bin\quartus_cpf.exe" -c %PROJECT%_304k.cof >nul 2>nul
call 3_finalize.cmd --no-wait
call 4_collect.cmd --no-wait
cd %~dp0
set OUTDIR=%DEST%zemmixneo_%LAYOUT%_layout\single_epbios_sx1_%YENSLASH%\
md %OUTDIR% >nul 2>nul
if not "%OPTMODE%"=="" rem.>"%OUTDIR%%OPTMODE%"
copy /Y %INPDIR%%PARKING%\%PROJECT%.pld %OUTDIR% >nul 2>nul
copy /Y %INPDIR%%PARKING%\recovery.pof %OUTDIR% >nul 2>nul
goto:eof

:err_quartus
if "%1"=="" color f0
echo.&echo Quartus II was not found or unsupported device!
goto timer

:err_msg
if "%1"=="" color f0
echo.&echo '%SRC%' not found!

:timer
if "%1"=="" waitfor /T %TIMEOUT% pause >nul 2>nul

:quit
