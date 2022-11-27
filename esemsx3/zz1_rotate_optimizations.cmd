@echo off
rem --- 'zz1_rotate_optimizations.cmd' v2.9 by KdL (2022.11.27)

set TIMEOUT=1
set PROJECT=emsx_top
set SRC=.\
set DEST=C:\Altera\multi-release\
if "%1"=="" color 1f&title Optimizations exchange tool for %PROJECT%
if exist %DEST% goto err_msg

if not exist %SRC%%PROJECT%.qsf.area.off (
    ren %SRC%%PROJECT%.qsf %PROJECT%.qsf.area.off >nul 2>nul
    ren %SRC%%PROJECT%.qsf.area.normal %PROJECT%.qsf >nul 2>nul
    if "%1"=="" color 1f&cls&echo.&echo [A] AREA ^& NORMAL COMPILATION are set!  ^(default^)
    del zz0_*.* >nul 2>nul
    rem.>"zz0_(area_normal_compilation)"
    goto timer
)

if not exist %SRC%%PROJECT%.qsf.area.normal (
    ren %SRC%%PROJECT%.qsf %PROJECT%.qsf.area.normal >nul 2>nul
    ren %SRC%%PROJECT%.qsf.area.extraeffort %PROJECT%.qsf >nul 2>nul
    if "%1"=="" color 5f&cls&echo.&echo [X] AREA ^& EXTRA EFFORT are set!
    del zz0_*.* >nul 2>nul
    rem.>"zz0_(area_extra_effort)"
    goto timer
)

if not exist %SRC%%PROJECT%.qsf.area.extraeffort (
    ren %SRC%%PROJECT%.qsf %PROJECT%.qsf.area.extraeffort >nul 2>nul
    ren %SRC%%PROJECT%.qsf.balanced.off %PROJECT%.qsf >nul 2>nul
    if "%1"=="" color 4f&cls&echo.&echo [2] BALANCED ^& POWERPLAY OFF are set!
    del zz0_*.* >nul 2>nul
    rem.>"zz0_(balanced_powerplay_off)"
    goto timer
)

if not exist %SRC%%PROJECT%.qsf.balanced.off (
    ren %SRC%%PROJECT%.qsf %PROJECT%.qsf.balanced.off >nul 2>nul
    ren %SRC%%PROJECT%.qsf.balanced.normal %PROJECT%.qsf >nul 2>nul
    if "%1"=="" color 6f&cls&echo.&echo [B] BALANCED ^& NORMAL COMPILATION are set!
    del zz0_*.* >nul 2>nul
    rem.>"zz0_(balanced_normal_compilation)"
    goto timer
)

if not exist %SRC%%PROJECT%.qsf.balanced.normal (
    ren %SRC%%PROJECT%.qsf %PROJECT%.qsf.balanced.normal >nul 2>nul
    ren %SRC%%PROJECT%.qsf.balanced.extraeffort %PROJECT%.qsf >nul 2>nul
    if "%1"=="" color 2f&cls&echo.&echo [Y] BALANCED ^& EXTRA EFFORT are set!
    del zz0_*.* >nul 2>nul
    rem.>"zz0_(balanced_extra_effort)"
    goto timer
)

if not exist %SRC%%PROJECT%.qsf.balanced.extraeffort (
    ren %SRC%%PROJECT%.qsf %PROJECT%.qsf.balanced.extraeffort >nul 2>nul
    ren %SRC%%PROJECT%.qsf.area.off %PROJECT%.qsf >nul 2>nul
    if "%1"=="" color 3f&cls&echo.&echo [1] AREA ^& POWERPLAY OFF are set!
    del zz0_*.* >nul 2>nul
    rem.>"zz0_(area_powerplay_off)"
    goto timer
)

:err_msg
if "%1"=="" color f0
echo.&echo This action is not allowed when the Multi-Release is in progress!
if "%1"=="" waitfor /T %TIMEOUT% pause >nul 2>nul

:timer
if "%1"=="" waitfor /T %TIMEOUT% pause >nul 2>nul

:quit
