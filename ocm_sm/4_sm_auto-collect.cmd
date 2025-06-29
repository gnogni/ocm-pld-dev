@echo off
rem --- '4_sm_auto-collect.cmd' v3.2 by KdL (2025.06.29)

set TIMEOUT=1
set PROJECT=ocm_sm
set PARKING=fw
set OUTPUT=output_files\
set CURSEED=Not detected
set SEEDENV=%PROJECT%_synthesis_seed.env
set EPCSDEV=EPCS64
if "%1"=="" color 1f&title AUTO-COLLECT for %PROJECT%
if not exist %PROJECT%_device.env goto err_init
set DEVSTR=&set /P DEVICE=<%PROJECT%_device.env
if "%DEVICE%"=="smx" set DEVSTR= for SM-X
if "%DEVICE%"=="sx2" set DEVSTR= for SX-2
if "%DEVICE%"=="sxe" set DEVSTR= for SX-E&set EPCSDEV=EPCQ64
if "%1"=="--no-wait" color 1f&title Task "%~dp0%PROJECT%.qpf"%DEVSTR%
if not exist "%QUARTUS_ROOTDIR%\common\devinfo\cycloneive" goto err_quartus
if not exist src_addons\ goto err_msg
if exist %SEEDENV% set /P CURSEED=<%SEEDENV%

:auto_collect
if "%1"=="" echo.&echo Press any key to start building...&pause >nul 2>nul
cls&echo.&echo Please wait...
if exist %SEEDENV% set /P CURSEED=<%SEEDENV%
if defined CURSEED echo.&echo Current Synthesis Seed = %CURSEED%
echo.&if not "%1"=="--no-wait" echo Output path: "%~dp0%PARKING%\"&echo.
rem ---------------cleanup----------------
call 2_sm_finalize.cmd --no-wait
call 3_sm_collect.cmd --no-wait
rem --------------------------------------
if exist "%QUARTUS_ROOTDIR%\bin64" set BIT=64
set STARTDATE=%DATE%
set STARTTIME=%TIME%
set KILLALL="%TEMP%\_multi-release_.killall"
del %KILLALL% >nul 2>nul
echo ^>^> Compile Design
echo   ^>^> Phase 1 - Analysis ^& Synthesis
set PHASE1="%QUARTUS_ROOTDIR%\bin%BIT%\quartus_map.exe" %PROJECT%.qpf
if not exist %KILLALL% %PHASE1% >nul 2>nul
echo   ^>^> Phase 2 - Fitter (Place ^& Route)
set PHASE2="%QUARTUS_ROOTDIR%\bin%BIT%\quartus_fit.exe" %PROJECT%.qpf
if not exist %KILLALL% %PHASE2% >nul 2>nul
set FITSUMMARY=%OUTPUT%%PROJECT%.fit.summary
rem ----------------retry-----------------
if "%1"=="--no-wait" if not exist %FITSUMMARY% echo              - Fitter (Second attempt)
if "%1"=="--no-wait" if not exist %FITSUMMARY% if not exist %KILLALL% %PHASE1% >nul 2>nul&%PHASE2% >nul 2>nul
if "%1"=="--no-wait" if not exist %FITSUMMARY% echo              - Fitter (Final attempt)
if "%1"=="--no-wait" if not exist %FITSUMMARY% if not exist %KILLALL% %PHASE1% >nul 2>nul&%PHASE2% >nul 2>nul
rem --------------------------------------
echo   ^>^> Phase 3 - Assembler (Generate programming files)
if not exist %KILLALL% "%QUARTUS_ROOTDIR%\bin%BIT%\quartus_asm.exe" %PROJECT%.qpf >nul 2>nul
echo   ^>^> Phase 4 - Convert programming files (%EPCSDEV% Device)
set CONFIG=%PROJECT%_512k_dual_epbios_backslash
if not exist %PROJECT%_512k.cof copy /Y %CONFIG%.cof %PROJECT%_512k.cof >nul 2>nul
if exist %KILLALL% goto skip_cpf
"%QUARTUS_ROOTDIR%\bin%BIT%\quartus_cpf.exe" -c %PROJECT%_512k.cof >nul 2>nul
if %ERRORLEVEL% neq 0 (
    del %PROJECT%.jic >nul 2>nul
    del %FITSUMMARY% >nul 2>nul
)

:skip_cpf
del %PROJECT%_512k.cof >nul 2>nul
set ENDTIME=%TIME%
rem ---------------collect----------------
call 2_sm_finalize.cmd --no-wait
call 3_sm_collect.cmd --no-wait
if "%1"=="" rd /S /Q %OUTPUT% >nul 2>nul
rem --------------------------------------
for /F "tokens=1-4 delims=:.," %%a in ("%STARTTIME%") do (
    set /A "start=(((%%a*60)+1%%b %% 100)*60+1%%c %% 100)*100+1%%d %% 100"
)
for /F "tokens=1-4 delims=:.," %%a in ("%ENDTIME%") do (
    set /A "end=(((%%a*60)+1%%b %% 100)*60+1%%c %% 100)*100+1%%d %% 100"
)
set /A elapsed=end-start
set /A hh=elapsed/(60*60*100), rest=elapsed%%(60*60*100), mm=rest/(60*100), rest%%=60*100, ss=rest/100
set SUMMARYLOG=%PARKING%\fit_summary.log
if exist %SUMMARYLOG% (echo Synthesis Seed : %CURSEED%)>>%SUMMARYLOG%
if "%STARTDATE%" == "%DATE%" if exist %SUMMARYLOG% (echo Building time : %hh%h %mm%m %ss%s)>>%SUMMARYLOG%
cls&if not exist %SUMMARYLOG% goto not_done
echo.&echo All done!&echo.&type %SUMMARYLOG%
goto timer

:not_done
if exist %KILLALL% exit
if "%1"=="" color f0
echo.&echo Building failed!
if exist %PARKING% if not exist %PARKING%\ del %PARKING% >nul 2>nul
rem.>"## BUILDING FAILED ##.log"
if "%1"=="" goto timer

:killall
if not "%1"=="--no-wait" goto timer
rem.>%KILLALL%
taskkill /f /im quartus_map.exe >nul 2>nul
taskkill /f /im quartus_fit.exe >nul 2>nul
taskkill /f /im quartus_asm.exe >nul 2>nul
taskkill /f /im quartus_cpf.exe >nul 2>nul
goto timer

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

:timer
waitfor /T %TIMEOUT% pause >nul 2>nul

:quit
rem --- if "%1"=="" call 5_sm_fw-upload.cmd --auto-collect --full-erase
del %KILLALL% >nul 2>nul
exit
