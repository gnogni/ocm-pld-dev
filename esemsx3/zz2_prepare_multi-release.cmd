@echo off
rem --- 'zz2_prepare_multi-release.cmd' v2.7 by KdL (2021.08.23)

set TIMEOUT=1
set PROJECT=emsx_top
set SRC=esemsx3\
set DEST=C:\Altera\multi-release\
if "%1"=="" color 1f&title Multi-Release preparing tool for %PROJECT%
if not exist "%QUARTUS_ROOTDIR%\common\devinfo\cyclone" goto err_quartus
if not exist src\ goto err_msg
if "%1"=="" echo.&echo A copy of the "%PROJECT%" project will be prepared
if "%1"=="" echo to compile several variants in parallel.
if "%1"=="" echo.&echo Destination folder: %DEST%&echo.
if "%1"=="" echo Press any key to continue...&pause >nul
if "%1"=="" cls&echo.&echo Please wait...
if exist __zemmixneo__ set DEVICE=__zemmixneo__&call 1_swap.cmd --no-wait&cd %~dp0
rem ---------------cleanup----------------
del "## BUILDING FAILED ##.log" >nul 2>nul
rd /S /Q %DEST% >nul 2>nul
md %DEST% >nul 2>nul
rem --------------------------------------
echo %~dp0>%DEST%source_path.txt
echo @echo off>%DEST%compile_multi-release.cmd
echo rem --- 'compile_multi-release.cmd' v2.7 by KdL (2021.08.23)>>%DEST%compile_multi-release.cmd
echo.>>%DEST%compile_multi-release.cmd

rem --- BR layout
cd ..
set LAYOUT=br
set LAYOUTFN=brazilian
set YENSLASH=backslash
set OUTDIR=%DEST%esemsx3_%LAYOUT%_1chipmsx\
set INPDIR=%SRC%
xcopy /S /E /Y %INPDIR%*.* %OUTDIR% >nul 2>nul
rem --------vdp_vga.vhd.topright25--------
rem del %OUTDIR%src\video\vdp_vga.vhd >nul 2>nul
rem ren %OUTDIR%src\video\vdp_vga.vhd.topright25 vdp_vga.vhd
rem --------------------------------------
del %OUTDIR%src\peripheral\keymap.vhd >nul 2>nul
ren %OUTDIR%src\peripheral\keymap.vhd.%LAYOUTFN% keymap.vhd
echo cd "%OUTDIR%">>%DEST%compile_multi-release.cmd
echo start "compile" /d "%OUTDIR%" /min 5_auto-collect.cmd --no-wait>>%DEST%compile_multi-release.cmd
set INPDIR=%OUTDIR%
set OUTDIR=%DEST%esemsx3_%LAYOUT%_zemmixneo\
xcopy /S /E /Y %INPDIR%*.* %OUTDIR% >nul 2>nul
cd %OUTDIR%
call %OUTDIR%1_swap.cmd --no-wait
echo cd "%OUTDIR%">>%DEST%compile_multi-release.cmd
echo start "compile" /d "%OUTDIR%" /min 5_auto-collect.cmd --no-wait>>%DEST%compile_multi-release.cmd
call :prepare_sx1mini
cd %~dp0

rem --- ES layout
cd ..
set LAYOUT=es
set LAYOUTFN=spanish
set YENSLASH=backslash
set OUTDIR=%DEST%esemsx3_%LAYOUT%_1chipmsx\
set INPDIR=%SRC%
xcopy /S /E /Y %INPDIR%*.* %OUTDIR% >nul 2>nul
rem --------vdp_vga.vhd.topright25--------
rem del %OUTDIR%src\video\vdp_vga.vhd >nul 2>nul
rem ren %OUTDIR%src\video\vdp_vga.vhd.topright25 vdp_vga.vhd
rem --------------------------------------
del %OUTDIR%src\peripheral\keymap.vhd >nul 2>nul
ren %OUTDIR%src\peripheral\keymap.vhd.%LAYOUTFN% keymap.vhd
echo cd "%OUTDIR%">>%DEST%compile_multi-release.cmd
echo start "compile" /d "%OUTDIR%" /min 5_auto-collect.cmd --no-wait>>%DEST%compile_multi-release.cmd
set INPDIR=%OUTDIR%
set OUTDIR=%DEST%esemsx3_%LAYOUT%_zemmixneo\
xcopy /S /E /Y %INPDIR%*.* %OUTDIR% >nul 2>nul
cd %OUTDIR%
call %OUTDIR%1_swap.cmd --no-wait
echo cd "%OUTDIR%">>%DEST%compile_multi-release.cmd
echo start "compile" /d "%OUTDIR%" /min 5_auto-collect.cmd --no-wait>>%DEST%compile_multi-release.cmd
call :prepare_sx1mini
cd %~dp0

rem --- FR layout
cd ..
set LAYOUT=fr
set LAYOUTFN=french
set YENSLASH=backslash
set OUTDIR=%DEST%esemsx3_%LAYOUT%_1chipmsx\
set INPDIR=%SRC%
xcopy /S /E /Y %INPDIR%*.* %OUTDIR% >nul 2>nul
rem --------vdp_vga.vhd.topright25--------
rem del %OUTDIR%src\video\vdp_vga.vhd >nul 2>nul
rem ren %OUTDIR%src\video\vdp_vga.vhd.topright25 vdp_vga.vhd
rem --------------------------------------
del %OUTDIR%src\peripheral\keymap.vhd >nul 2>nul
ren %OUTDIR%src\peripheral\keymap.vhd.%LAYOUTFN% keymap.vhd
echo cd "%OUTDIR%">>%DEST%compile_multi-release.cmd
echo start "compile" /d "%OUTDIR%" /min 5_auto-collect.cmd --no-wait>>%DEST%compile_multi-release.cmd
set INPDIR=%OUTDIR%
set OUTDIR=%DEST%esemsx3_%LAYOUT%_zemmixneo\
xcopy /S /E /Y %INPDIR%*.* %OUTDIR% >nul 2>nul
cd %OUTDIR%
call %OUTDIR%1_swap.cmd --no-wait
echo cd "%OUTDIR%">>%DEST%compile_multi-release.cmd
echo start "compile" /d "%OUTDIR%" /min 5_auto-collect.cmd --no-wait>>%DEST%compile_multi-release.cmd
call :prepare_sx1mini
cd %~dp0

rem --- JP layout
cd ..
set LAYOUT=jp
set LAYOUTFN=japanese
set YENSLASH=yen
set OUTDIR=%DEST%esemsx3_%LAYOUT%_1chipmsx\
set INPDIR=%SRC%
xcopy /S /E /Y %INPDIR%*.* %OUTDIR% >nul 2>nul
rem --------vdp_vga.vhd.topright25--------
rem del %OUTDIR%src\video\vdp_vga.vhd >nul 2>nul
rem ren %OUTDIR%src\video\vdp_vga.vhd.topright25 vdp_vga.vhd
rem --------------------------------------
del %OUTDIR%src\peripheral\swioports.vhd >nul 2>nul
ren %OUTDIR%src\peripheral\swioports.vhd.%LAYOUTFN% swioports.vhd
del %OUTDIR%%PROJECT%_304k.hex >nul 2>nul
ren %OUTDIR%%PROJECT%_304k.hex.%YENSLASH%.msx2plus %PROJECT%_304k.hex
echo cd "%OUTDIR%">>%DEST%compile_multi-release.cmd
echo start "compile" /d "%OUTDIR%" /min 5_auto-collect.cmd --no-wait>>%DEST%compile_multi-release.cmd
set INPDIR=%OUTDIR%
set OUTDIR=%DEST%esemsx3_%LAYOUT%_zemmixneo\
xcopy /S /E /Y %INPDIR%*.* %OUTDIR% >nul 2>nul
cd %OUTDIR%
call %OUTDIR%1_swap.cmd --no-wait
del %OUTDIR%src\peripheral\swioports.vhd >nul 2>nul
ren %OUTDIR%src\peripheral\swioports.vhd.%LAYOUTFN% swioports.vhd
del %OUTDIR%%PROJECT%_304k.hex >nul 2>nul
ren %OUTDIR%%PROJECT%_304k.hex.%YENSLASH%.zemmixneo %PROJECT%_304k.hex
echo cd "%OUTDIR%">>%DEST%compile_multi-release.cmd
echo start "compile" /d "%OUTDIR%" /min 5_auto-collect.cmd --no-wait>>%DEST%compile_multi-release.cmd
call :prepare_sx1mini
cd %~dp0

rem --- US layout
cd ..
set LAYOUT=us
set YENSLASH=backslash
set OUTDIR=%DEST%esemsx3_%LAYOUT%_1chipmsx\
set INPDIR=%SRC%
xcopy /S /E /Y %INPDIR%*.* %OUTDIR% >nul 2>nul
rem --------vdp_vga.vhd.topright25--------
rem del %OUTDIR%src\video\vdp_vga.vhd >nul 2>nul
rem ren %OUTDIR%src\video\vdp_vga.vhd.topright25 vdp_vga.vhd
rem --------------------------------------
echo cd "%OUTDIR%">>%DEST%compile_multi-release.cmd
echo start "compile" /d "%OUTDIR%" /min 5_auto-collect.cmd --no-wait>>%DEST%compile_multi-release.cmd
set INPDIR=%OUTDIR%
set OUTDIR=%DEST%esemsx3_%LAYOUT%_zemmixneo\
xcopy /S /E /Y %INPDIR%*.* %OUTDIR% >nul 2>nul
cd %OUTDIR%
call %OUTDIR%1_swap.cmd --no-wait
echo cd "%OUTDIR%">>%DEST%compile_multi-release.cmd
echo start "compile" /d "%OUTDIR%" /min 5_auto-collect.cmd --no-wait>>%DEST%compile_multi-release.cmd
call :prepare_sx1mini
cd %~dp0

if "%DEVICE%"=="__zemmixneo__" call 1_swap.cmd --no-wait&cd %~dp0
if "%1"=="" cls&echo.&echo All done!
goto quit_0

:prepare_sx1mini
set INPDIR=%OUTDIR%
set OUTDIR=%DEST%esemsx3_%LAYOUT%_sx1mini\
xcopy /S /E /Y %INPDIR%*.* %OUTDIR% >nul 2>nul
del %OUTDIR%src\emsx_top.vhd >nul 2>nul
ren %OUTDIR%src\emsx_top.vhd.zemmixneo.sx1mini emsx_top.vhd >nul 2>nul
echo cd "%OUTDIR%">>%DEST%compile_multi-release.cmd
echo start "compile" /d "%OUTDIR%" /min 5_auto-collect.cmd --no-wait>>%DEST%compile_multi-release.cmd
goto:eof

:err_quartus
if "%1"=="" color f0
echo.&echo Quartus II was not found or unsupported device!
goto timer

:err_msg
if "%1"=="" color f0
echo.&echo 'src\' not found!
goto timer

:quit_0
echo exit>>%DEST%compile_multi-release.cmd

:timer
if "%1"=="" waitfor /T %TIMEOUT% pause >nul 2>nul

:quit
