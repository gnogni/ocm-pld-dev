@echo off
rem --- 'zz5_sm_set_synthesis_seed.cmd' v3.2 by KdL (2025.06.29)

set TIMEOUT=1
set PROJECT=ocm_sm
set SRC=.\
set DEFSEED=1
set STRSEED=set_global_assignment -name SEED
set INPUTNR=Press [ENTER] for the default, or input a new value
set QDFNAME=%SRC%%PROJECT%_synthesis_seed.qsf
set SEEDENV=%SRC%%PROJECT%_synthesis_seed.env
if "%1"=="" (color 1f&title Synthesis Seed setup tool for %PROJECT%) else (set "SEED=%1"&goto store_seed)
call :rw_seed_env

:input_seed
set SEED=
cls
echo.
echo Output filename: "%QDFNAME%"
echo.
echo Specify the seed that Synthesis uses to randomly do synthesis in a
echo slightly different way. This seed can be used when a design is close
echo to meeting requirements, in order to get a slightly different result.
echo The value can be any non-negative integer value (default = %DEFSEED%).
echo Changing the starting value may or may not produce better results.
echo.
echo Current Synthesis Seed = %CURSEED%
echo.
set /P SEED="%INPUTNR% (1-100): "
for %%I in ( "1"   "2"   "3"   "4"   "5"   "6"   "7"   "8"   "9"  "10") do if "%SEED%"==%%I goto store_seed
for %%I in ("11"  "12"  "13"  "14"  "15"  "16"  "17"  "18"  "19"  "20") do if "%SEED%"==%%I goto store_seed
for %%I in ("21"  "22"  "23"  "24"  "25"  "26"  "27"  "28"  "29"  "30") do if "%SEED%"==%%I goto store_seed
for %%I in ("31"  "32"  "33"  "34"  "35"  "36"  "37"  "38"  "39"  "40") do if "%SEED%"==%%I goto store_seed
for %%I in ("41"  "42"  "43"  "44"  "45"  "46"  "47"  "48"  "49"  "50") do if "%SEED%"==%%I goto store_seed
for %%I in ("51"  "52"  "53"  "54"  "55"  "56"  "57"  "58"  "59"  "60") do if "%SEED%"==%%I goto store_seed
for %%I in ("61"  "62"  "63"  "64"  "65"  "66"  "67"  "68"  "69"  "70") do if "%SEED%"==%%I goto store_seed
for %%I in ("71"  "72"  "73"  "74"  "75"  "76"  "77"  "78"  "79"  "80") do if "%SEED%"==%%I goto store_seed
for %%I in ("81"  "82"  "83"  "84"  "85"  "86"  "87"  "88"  "89"  "90") do if "%SEED%"==%%I goto store_seed
for %%I in ("91"  "92"  "93"  "94"  "95"  "96"  "97"  "98"  "99" "100") do if "%SEED%"==%%I goto store_seed
if not "%SEED%"=="" goto input_seed
set SEED=%DEFSEED%

:store_seed
(echo %SEED%)>%SEEDENV%
call :rw_seed_env
if exist %QDFNAME% set /P CURSEED=<%QDFNAME%
if "%1"=="" cls&echo.
echo %CURSEED%
if "%1"=="" echo.&echo Done!
goto timer

:rw_seed_env
if not exist %SEEDENV% (echo %DEFSEED%)>%SEEDENV%
if exist %SEEDENV% set /P CURSEED=<%SEEDENV%
(echo %STRSEED% %CURSEED%)>%QDFNAME%
goto:eof

:timer
if "%1"=="" waitfor /T %TIMEOUT% pause >nul 2>nul

:quit
