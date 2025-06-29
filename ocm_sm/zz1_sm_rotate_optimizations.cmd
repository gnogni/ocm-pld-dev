@echo off
rem --- 'zz1_sm_rotate_optimizations.cmd' v3.2 by KdL (2025.06.29)

set TIMEOUT=1
set PROJECT=ocm_sm
set SRC=.\
set DEST=C:\altera_lite\multi-release\
if "%1"=="" color 1f&title Optimizations exchange tool for %PROJECT%
if exist %DEST% goto err_msg

if not exist %SRC%%PROJECT%.qsf.performance.higheffort (
    ren %SRC%%PROJECT%.qsf %PROJECT%.qsf.performance.higheffort >nul 2>nul
    ren %SRC%%PROJECT%.qsf.performance.aggressive %PROJECT%.qsf >nul 2>nul
    if "%1"=="" color 5f&cls&echo.&echo [1] PERFORMANCE ^& AGGRESSIVE are set!
    del zz0_sm_*.* >nul 2>nul
    rem.>"zz0_sm_(performance_aggressive)"
    goto timer
)

if not exist %SRC%%PROJECT%.qsf.performance.aggressive (
    ren %SRC%%PROJECT%.qsf %PROJECT%.qsf.performance.aggressive >nul 2>nul
    ren %SRC%%PROJECT%.qsf.area.aggressive %PROJECT%.qsf >nul 2>nul
    if "%1"=="" color 4f&cls&echo.&echo [A] AREA ^& AGGRESSIVE are set!
    del zz0_sm_*.* >nul 2>nul
    rem.>"zz0_sm_(area_aggressive)"
    goto timer
)

if not exist %SRC%%PROJECT%.qsf.area.aggressive (
    ren %SRC%%PROJECT%.qsf %PROJECT%.qsf.area.aggressive >nul 2>nul
    ren %SRC%%PROJECT%.qsf.power.higheffort %PROJECT%.qsf >nul 2>nul
    if "%1"=="" color 6f&cls&echo.&echo [X] POWER ^& HIGH EFFORT are set!
    del zz0_sm_*.* >nul 2>nul
    rem.>"zz0_sm_(power_high_effort)"
    goto timer
)

if not exist %SRC%%PROJECT%.qsf.power.higheffort (
    ren %SRC%%PROJECT%.qsf %PROJECT%.qsf.power.higheffort >nul 2>nul
    ren %SRC%%PROJECT%.qsf.power.aggressive %PROJECT%.qsf >nul 2>nul
    if "%1"=="" color 2f&cls&echo.&echo [2] POWER ^& AGGRESSIVE are set!
    del zz0_sm_*.* >nul 2>nul
    rem.>"zz0_sm_(power_aggressive)"
    goto timer
)

if not exist %SRC%%PROJECT%.qsf.power.aggressive (
    ren %SRC%%PROJECT%.qsf %PROJECT%.qsf.power.aggressive >nul 2>nul
    ren %SRC%%PROJECT%.qsf.balanced.normal %PROJECT%.qsf >nul 2>nul
    if "%1"=="" color 3f&cls&echo.&echo [B] BALANCED ^& NORMAL FLOW are set!  ^(default^)
    del zz0_sm_*.* >nul 2>nul
    rem.>"zz0_sm_(balanced_normal_flow)"
    goto timer
)

if not exist %SRC%%PROJECT%.qsf.balanced.normal (
    ren %SRC%%PROJECT%.qsf %PROJECT%.qsf.balanced.normal >nul 2>nul
    ren %SRC%%PROJECT%.qsf.performance.higheffort %PROJECT%.qsf >nul 2>nul
    if "%1"=="" color 1f&cls&echo.&echo [Y] PERFORMANCE ^& HIGH EFFORT are set!
    del zz0_sm_*.* >nul 2>nul
    rem.>"zz0_sm_(performance_high_effort)"
    goto timer
)

:err_msg
if "%1"=="" color f0
echo.&echo This action is not allowed when the Multi-Release is in progress!
if "%1"=="" waitfor /T %TIMEOUT% pause >nul 2>nul

:timer
if "%1"=="" waitfor /T %TIMEOUT% pause >nul 2>nul

:quit
