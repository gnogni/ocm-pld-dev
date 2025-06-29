@echo off
rem --- 'zz2_sm_prepare_multi-release.cmd' v3.2 by KdL (2025.06.29)

set TIMEOUT=1
set PROJECT=ocm_sm
set SRC0=esemsx3\
set SRC1=ocm_sm\
set DEST1=C:\Altera\multi-release\
set DEST2=C:\altera_lite\multi-release\
set DEST=%DEST2%
set SEEDENV=%PROJECT%_synthesis_seed.env
set OUTLINE=######################################################
set CAUTION=### CAUTION: a Multi-Release is still in progress! ###
rem ---------------variant----------------
set VPATH=src\video\
set VNAME=vdp_vga.vhd
set VTYPE=.topright25
set VSHOW=no
set VTEXT=&if "%VSHOW%"=="yes" set VTEXT=, [V] for '%VNAME%%VTYPE%'
rem --------------------------------------
if "%1"=="" color 1f&title Multi-Release preparing tool for %PROJECT%
if not exist %PROJECT%_device.env goto err_init
if not exist "%QUARTUS_ROOTDIR%\common\devinfo\cycloneive" goto err_quartus
if not exist src_addons\ goto err_msg
if "%1"=="" echo.&echo A copy of the "%PROJECT%" project will be prepared
if "%1"=="" echo to compile several firmware in parallel.
if exist %SEEDENV% set /P CURSEED=<%SEEDENV%
if "%1"=="" if defined CURSEED echo.&echo Current Synthesis Seed = %CURSEED%
if "%1"=="" echo.&echo Destination path: %DEST%
if exist "%DEST1%" set MULTI=1
if exist "%DEST2%" set MULTI=1
if "%1"=="" if "%MULTI%"=="1" echo.&echo %OUTLINE%&echo %CAUTION%&echo %OUTLINE%
if "%1"=="" (
    echo.&echo Press any key to continue%VTEXT%...
    set VARIANT=&for /f "delims=" %%a in ('xcopy /l /w "%~f0" "%~f0" 2^>nul') do (if not defined VARIANT set "VARIANT=%%a")&cls
)
if "%1"=="" if /I "%VARIANT:~-1%"=="V" set VARIANT=yes&echo.&echo Variant '%VNAME%%VTYPE%' selected.
if "%1"=="" echo.&echo Please wait...
rem ---------------cleanup----------------
del "## BUILDING FAILED ##.log" >nul 2>nul
rd /S /Q %DEST% >nul 2>nul
md %DEST% >nul 2>nul
rem --------------------------------------
echo %~dp0>%DEST%source_path.txt
echo @echo off>%DEST%sm_compile_multi-release.cmd
echo rem --- 'sm_compile_multi-release.cmd' v3.2 by KdL (2025.06.29)>>%DEST%sm_compile_multi-release.cmd
echo.>>%DEST%sm_compile_multi-release.cmd

rem --- BR layout
cd ..
set LAYOUT=br
set LAYOUTFN=brazilian
call :extra_layout

rem --- ES layout
cd ..
set LAYOUT=es
set LAYOUTFN=spanish
call :extra_layout

rem --- FR layout
cd ..
set LAYOUT=fr
set LAYOUTFN=french
call :extra_layout

rem --- IT layout
cd ..
set LAYOUT=it
set LAYOUTFN=italian
call :extra_layout

rem --- JP layout
cd ..
set LAYOUT=jp
set LAYOUTFN=japanese
set OUTDIR=%DEST%%LAYOUT%_dual_epbios\
set INPDIR=%SRC0%
xcopy /S /E /Y %INPDIR%*.* %OUTDIR%%INPDIR% >nul 2>nul
rem ---------------variant----------------
if /I "%VARIANT%"=="yes" move %OUTDIR%%INPDIR%%VPATH%%VNAME%%VTYPE% %OUTDIR%%INPDIR%%VPATH%%VNAME% >nul 2>nul
rem --------------------------------------
set INPDIR=%SRC1%
xcopy /S /E /Y %INPDIR%*.* %OUTDIR%%INPDIR% >nul 2>nul
move %OUTDIR%%INPDIR%src_addons\peripheral\sm_swioports.vhd.%LAYOUTFN% %OUTDIR%%INPDIR%src_addons\peripheral\sm_swioports.vhd >nul 2>nul
move %OUTDIR%%INPDIR%%PROJECT%_512k_dual_epbios_yen.cof %OUTDIR%%INPDIR%%PROJECT%_512k_dual_epbios_backslash.cof >nul 2>nul
echo cd "%OUTDIR%%INPDIR%">>%DEST%sm_compile_multi-release.cmd
echo start "compile" /d "%OUTDIR%%INPDIR%" /min /affinity fff7 4_sm_auto-collect.cmd --no-wait>>%DEST%sm_compile_multi-release.cmd
cd %~dp0

rem --- US layout
cd ..
set LAYOUT=us
set OUTDIR=%DEST%%LAYOUT%_dual_epbios\
set INPDIR=%SRC0%
xcopy /S /E /Y %INPDIR%*.* %OUTDIR%%INPDIR% >nul 2>nul
rem ---------------variant----------------
if /I "%VARIANT%"=="yes" move %OUTDIR%%INPDIR%%VPATH%%VNAME%%VTYPE% %OUTDIR%%INPDIR%%VPATH%%VNAME% >nul 2>nul
rem --------------------------------------
set INPDIR=%SRC1%
xcopy /S /E /Y %INPDIR%*.* %OUTDIR%%INPDIR% >nul 2>nul
echo cd "%OUTDIR%%INPDIR%">>%DEST%sm_compile_multi-release.cmd
echo start "compile" /d "%OUTDIR%%INPDIR%" /min /affinity fff7 4_sm_auto-collect.cmd --no-wait>>%DEST%sm_compile_multi-release.cmd
cd %~dp0

if "%1"=="" cls&echo.&echo All done!
goto quit_0

:extra_layout
set OUTDIR=%DEST%%LAYOUT%_dual_epbios\
set INPDIR=%SRC0%
xcopy /S /E /Y %INPDIR%*.* %OUTDIR%%INPDIR% >nul 2>nul
rem ---------------variant----------------
if /I "%VARIANT%"=="yes" move %OUTDIR%%INPDIR%%VPATH%%VNAME%%VTYPE% %OUTDIR%%INPDIR%%VPATH%%VNAME% >nul 2>nul
rem --------------------------------------
move %OUTDIR%%INPDIR%src\peripheral\keymap.vhd.%LAYOUTFN% %OUTDIR%%INPDIR%src\peripheral\keymap.vhd >nul 2>nul
set INPDIR=%SRC1%
xcopy /S /E /Y %INPDIR%*.* %OUTDIR%%INPDIR% >nul 2>nul
echo cd "%OUTDIR%%INPDIR%">>%DEST%sm_compile_multi-release.cmd
echo start "compile" /d "%OUTDIR%%INPDIR%" /min /affinity fff7 4_sm_auto-collect.cmd --no-wait>>%DEST%sm_compile_multi-release.cmd
cd %~dp0
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
echo.&echo 'src_addons\' not found!
goto timer

:quit_0
echo exit>>%DEST%sm_compile_multi-release.cmd

:timer
if "%1"=="" waitfor /T %TIMEOUT% pause >nul 2>nul

:quit
