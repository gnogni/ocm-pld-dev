@echo off
rem --- 'zz2_sm_prepare_multi-release.cmd' v2.7 by KdL (2021.08.23)

set TIMEOUT=1
set PROJECT=ocm_sm
set SRC0=esemsx3\
set SRC1=ocm_sm\
set DEST=C:\intelFPGA_lite\multi-release\
if "%1"=="" color 1f&title Multi-Release preparing tool for %PROJECT%
if not exist %PROJECT%_device.env goto err_init
if not exist "%QUARTUS_ROOTDIR%\common\devinfo\cycloneive" goto err_quartus
if not exist src_addons\ goto err_msg
if "%1"=="" echo.&echo A copy of the "%PROJECT%" project will be prepared
if "%1"=="" echo to compile several variants in parallel.
if "%1"=="" echo.&echo Destination folder: %DEST%&echo.
if "%1"=="" echo Press any key to continue...&pause >nul
if "%1"=="" cls&echo.&echo Please wait...
rem ---------------cleanup----------------
del "## BUILDING FAILED ##.log" >nul 2>nul
rd /S /Q %DEST% >nul 2>nul
md %DEST% >nul 2>nul
rem --------------------------------------
echo %~dp0>%DEST%source_path.txt
echo @echo off>%DEST%sm_compile_multi-release.cmd
echo rem --- 'sm_compile_multi-release.cmd' v2.7 by KdL (2021.08.23)>>%DEST%sm_compile_multi-release.cmd
echo.>>%DEST%sm_compile_multi-release.cmd

rem --- BR layout
cd ..
set LAYOUT=br
set LAYOUTFN=brazilian
set OUTDIR=%DEST%%LAYOUT%_dual_epbios\
set INPDIR=%SRC0%
xcopy /S /E /Y %INPDIR%*.* %OUTDIR%%INPDIR% >nul 2>nul
del %OUTDIR%%INPDIR%src\peripheral\keymap.vhd >nul 2>nul
ren %OUTDIR%%INPDIR%src\peripheral\keymap.vhd.%LAYOUTFN% keymap.vhd
set INPDIR=%SRC1%
xcopy /S /E /Y %INPDIR%*.* %OUTDIR%%INPDIR% >nul 2>nul
echo cd "%OUTDIR%%INPDIR%">>%DEST%sm_compile_multi-release.cmd
echo start "compile" /d "%OUTDIR%%INPDIR%" /min 4_sm_auto-collect.cmd --no-wait>>%DEST%sm_compile_multi-release.cmd
cd %~dp0

rem --- ES layout
cd ..
set LAYOUT=es
set LAYOUTFN=spanish
set OUTDIR=%DEST%%LAYOUT%_dual_epbios\
set INPDIR=%SRC0%
xcopy /S /E /Y %INPDIR%*.* %OUTDIR%%INPDIR% >nul 2>nul
del %OUTDIR%%INPDIR%src\peripheral\keymap.vhd >nul 2>nul
ren %OUTDIR%%INPDIR%src\peripheral\keymap.vhd.%LAYOUTFN% keymap.vhd
set INPDIR=%SRC1%
xcopy /S /E /Y %INPDIR%*.* %OUTDIR%%INPDIR% >nul 2>nul
echo cd "%OUTDIR%%INPDIR%">>%DEST%sm_compile_multi-release.cmd
echo start "compile" /d "%OUTDIR%%INPDIR%" /min 4_sm_auto-collect.cmd --no-wait>>%DEST%sm_compile_multi-release.cmd
cd %~dp0

rem --- FR layout
cd ..
set LAYOUT=fr
set LAYOUTFN=french
set OUTDIR=%DEST%%LAYOUT%_dual_epbios\
set INPDIR=%SRC0%
xcopy /S /E /Y %INPDIR%*.* %OUTDIR%%INPDIR% >nul 2>nul
del %OUTDIR%%INPDIR%src\peripheral\keymap.vhd >nul 2>nul
ren %OUTDIR%%INPDIR%src\peripheral\keymap.vhd.%LAYOUTFN% keymap.vhd
set INPDIR=%SRC1%
xcopy /S /E /Y %INPDIR%*.* %OUTDIR%%INPDIR% >nul 2>nul
echo cd "%OUTDIR%%INPDIR%">>%DEST%sm_compile_multi-release.cmd
echo start "compile" /d "%OUTDIR%%INPDIR%" /min 4_sm_auto-collect.cmd --no-wait>>%DEST%sm_compile_multi-release.cmd
cd %~dp0


rem --- JP layout
cd ..
set LAYOUT=jp
set LAYOUTFN=japanese
set OUTDIR=%DEST%%LAYOUT%_dual_epbios\
set INPDIR=%SRC0%
xcopy /S /E /Y %INPDIR%*.* %OUTDIR%%INPDIR% >nul 2>nul
set INPDIR=%SRC1%
xcopy /S /E /Y %INPDIR%*.* %OUTDIR%%INPDIR% >nul 2>nul
del %OUTDIR%%INPDIR%src_addons\peripheral\sm_swioports.vhd >nul 2>nul
ren %OUTDIR%%INPDIR%src_addons\peripheral\sm_swioports.vhd.%LAYOUTFN% sm_swioports.vhd
del %OUTDIR%%INPDIR%%PROJECT%_512k_dual_epbios_backslash.cof >nul 2>nul
ren %OUTDIR%%INPDIR%%PROJECT%_512k_dual_epbios_yen.cof %PROJECT%_512k_dual_epbios_backslash.cof
echo cd "%OUTDIR%%INPDIR%">>%DEST%sm_compile_multi-release.cmd
echo start "compile" /d "%OUTDIR%%INPDIR%" /min 4_sm_auto-collect.cmd --no-wait>>%DEST%sm_compile_multi-release.cmd
cd %~dp0

rem --- US layout
cd ..
set LAYOUT=us
set OUTDIR=%DEST%%LAYOUT%_dual_epbios\
set INPDIR=%SRC0%
xcopy /S /E /Y %INPDIR%*.* %OUTDIR%%INPDIR% >nul 2>nul
set INPDIR=%SRC1%
xcopy /S /E /Y %INPDIR%*.* %OUTDIR%%INPDIR% >nul 2>nul
echo cd "%OUTDIR%%INPDIR%">>%DEST%sm_compile_multi-release.cmd
echo start "compile" /d "%OUTDIR%%INPDIR%" /min 4_sm_auto-collect.cmd --no-wait>>%DEST%sm_compile_multi-release.cmd
cd %~dp0

if "%1"=="" cls&echo.&echo All done!
goto quit_0

:err_init
if "%1"=="" color f0
echo.&echo Please initialize a device first!
goto timer

:err_quartus
if "%1"=="" color f0
echo.&echo Quartus II was not found or unsupported device!
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
