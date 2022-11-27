@echo off
rem --- 'zz1_sm_rotate_optimizations.cmd' v3.0 by KdL (2022.11.27)

set TIMEOUT=1
set PROJECT=ocm_sm
set SRC=.\
set DEST=C:\intelFPGA_lite\multi-release\
if "%1"=="" color 1f&title Optimizations exchange tool for %PROJECT%
if not exist %PROJECT%_device.env goto err_init
if exist %DEST% goto err_msg

if not exist %SRC%%PROJECT%.qsf.area.off (
    ren %SRC%%PROJECT%.qsf %PROJECT%.qsf.area.off >nul 2>nul
    ren %SRC%%PROJECT%.qsf.area.normal %PROJECT%.qsf >nul 2>nul
    if "%1"=="" color 1f&cls&echo.&echo [A] AREA ^& NORMAL COMPILATION are set!  ^(default^)
    del zz0_sm_*.* >nul 2>nul
    rem.>"zz0_sm_(area_normal_compilation)"
    goto timer
)

if not exist %SRC%%PROJECT%.qsf.area.normal (
    ren %SRC%%PROJECT%.qsf %PROJECT%.qsf.area.normal >nul 2>nul
    ren %SRC%%PROJECT%.qsf.area.extraeffort %PROJECT%.qsf >nul 2>nul
    if "%1"=="" color 5f&cls&echo.&echo [X] AREA ^& EXTRA EFFORT are set!
    del zz0_sm_*.* >nul 2>nul
    rem.>"zz0_sm_(area_extra_effort)"
    goto timer
)

if not exist %SRC%%PROJECT%.qsf.area.extraeffort (
    ren %SRC%%PROJECT%.qsf %PROJECT%.qsf.area.extraeffort >nul 2>nul
    ren %SRC%%PROJECT%.qsf.balanced.off %PROJECT%.qsf >nul 2>nul
    if "%1"=="" color 4f&cls&echo.&echo [2] BALANCED ^& POWERPLAY OFF are set!
    del zz0_sm_*.* >nul 2>nul
    rem.>"zz0_sm_(balanced_powerplay_off)"
    goto timer
)

if not exist %SRC%%PROJECT%.qsf.balanced.off (
    ren %SRC%%PROJECT%.qsf %PROJECT%.qsf.balanced.off >nul 2>nul
    ren %SRC%%PROJECT%.qsf.balanced.normal %PROJECT%.qsf >nul 2>nul
    if "%1"=="" color 6f&cls&echo.&echo [B] BALANCED ^& NORMAL COMPILATION are set!
    del zz0_sm_*.* >nul 2>nul
    rem.>"zz0_sm_(balanced_normal_compilation)"
    goto timer
)

if not exist %SRC%%PROJECT%.qsf.balanced.normal (
    ren %SRC%%PROJECT%.qsf %PROJECT%.qsf.balanced.normal >nul 2>nul
    ren %SRC%%PROJECT%.qsf.balanced.extraeffort %PROJECT%.qsf >nul 2>nul
    if "%1"=="" color 2f&cls&echo.&echo [Y] BALANCED ^& EXTRA EFFORT are set!
    del zz0_sm_*.* >nul 2>nul
    rem.>"zz0_sm_(balanced_extra_effort)"
    goto timer
)

if not exist %SRC%%PROJECT%.qsf.balanced.extraeffort (
    ren %SRC%%PROJECT%.qsf %PROJECT%.qsf.balanced.extraeffort >nul 2>nul
    ren %SRC%%PROJECT%.qsf.area.off %PROJECT%.qsf >nul 2>nul
    if "%1"=="" color 3f&cls&echo.&echo [1] AREA ^& POWERPLAY OFF are set!
    del zz0_sm_*.* >nul 2>nul
    rem.>"zz0_sm_(area_powerplay_off)"
    goto timer
)

:err_init
if "%1"=="" color f0
echo.&echo Please initialize a device first!
goto timer

:err_msg
if "%1"=="" color f0
echo.&echo This action is not allowed when the Multi-Release is in progress!
if "%1"=="" waitfor /T %TIMEOUT% pause >nul 2>nul

:timer
if "%1"=="" waitfor /T %TIMEOUT% pause >nul 2>nul

:quit
