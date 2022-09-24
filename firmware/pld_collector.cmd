@echo off
rem --- 'pld_collector.cmd' v3.9.1 by KdL (2022.09.24)

set VERSION=3.9.1
set VER=391

set TIMEOUT=1
set PROJECT=emsx_top
set DEST=PLD%VER%\
if "%1"=="" color 1f&title PLD collector tool
if not exist pldflash.com goto err_PLDFLASH_COM
rd /S /Q %DEST% >nul 2>nul
md %DEST% >nul 2>nul
copy pldflash.com %DEST%PLDFLASH.COM >nul 2>nul
call :create_FLASH_BAT
rem --- 1chipMSX ---
set FNAME=OCM
call :collect_all
rem --- Zemmix Neo ---
set FNAME=ZEM
call :collect_all
rem --- SX-1 ---
set FNAME=SX1
call :collect_all
if not exist %DEST%*.PLD rd /S /Q %DEST% >nul 2>nul

:ocm_sm
set PROJECT=ocm_sm
set DEVNAME=SM-X
set UNDERLN=====
set FNAME=SMX
set DEST=PLD%VER%.%FNAME%\
if not exist smxflash.com goto err_SMXFLASH_COM
rd /S /Q %DEST% >nul 2>nul
md %DEST% >nul 2>nul
copy smxflash.com %DEST%SMXFLASH.COM >nul 2>nul
call :create_XFLASH_BAT
rem --- SM-X ---
call :collect_all
if not exist %DEST%*.PLD rd /S /Q %DEST% >nul 2>nul
set DEVNAME=SX-2
set UNDERLN=====
set FNAME=SX2
set DEST=PLD%VER%.%FNAME%\
if not exist smxflash.com goto err_SMXFLASH_COM
rd /S /Q %DEST% >nul 2>nul
md %DEST% >nul 2>nul
copy smxflash.com %DEST%SMXFLASH.COM >nul 2>nul
call :create_XFLASH_BAT
rem --- SX-2 ---
call :collect_all
if not exist %DEST%*.PLD rd /S /Q %DEST% >nul 2>nul
if "%1"=="" cls&echo.&echo All done!
goto quit

:collect_all
set YENSLASH=backslash
set LAYOUT=BR
call :collect_%FNAME%
set LAYOUT=ES
call :collect_%FNAME%
set LAYOUT=FR
call :collect_%FNAME%
set LAYOUT=IT
call :collect_%FNAME%
set LAYOUT=US
call :collect_%FNAME%
set YENSLASH=yen
set LAYOUT=JP
call :collect_%FNAME%
goto:eof

:collect_OCM
copy 1chipmsx_%LAYOUT%_layout\single_epbios_msxplusplus_%YENSLASH%\%PROJECT%.pld %DEST%%FNAME%PP-%LAYOUT%.PLD >nul 2>nul
copy 1chipmsx_%LAYOUT%_layout\single_epbios_msx2plus_%YENSLASH%\%PROJECT%.pld %DEST%%FNAME%2P-%LAYOUT%.PLD >nul 2>nul
goto:eof

:collect_SX1
copy sx1mini_%LAYOUT%_layout\single_epbios_sx1_%YENSLASH%\%PROJECT%.pld %DEST%%FNAME%MN-%LAYOUT%.PLD >nul 2>nul
copy zemmixneo_%LAYOUT%_layout\single_epbios_sx1_%YENSLASH%\%PROJECT%.pld %DEST%%FNAME%ES-%LAYOUT%.PLD >nul 2>nul
goto:eof

:collect_ZEM
copy zemmixneo_%LAYOUT%_layout\single_epbios_zemmixneo_%YENSLASH%\%PROJECT%.pld %DEST%%FNAME%KR-%LAYOUT%.PLD >nul 2>nul
copy zemmixneo_%LAYOUT%_layout\single_epbios_zemmixneobr_%YENSLASH%\%PROJECT%.pld %DEST%%FNAME%BR-%LAYOUT%.PLD >nul 2>nul
goto:eof

:collect_SMX
copy smx_%LAYOUT%_layout\dual_epbios_smx_%YENSLASH%\%PROJECT%.pld %DEST%%FNAME%DE-%LAYOUT%.PLD >nul 2>nul
copy smx_%LAYOUT%_layout\single_epbios_smx_%YENSLASH%\%PROJECT%.pld %DEST%%FNAME%SE-%LAYOUT%.PLD >nul 2>nul
goto:eof

:collect_SMN
copy smxmini_%LAYOUT%_layout\dual_epbios_smx_%YENSLASH%\%PROJECT%.pld %DEST%%FNAME%DE-%LAYOUT%.PLD >nul 2>nul
copy smxmini_%LAYOUT%_layout\single_epbios_smx_%YENSLASH%\%PROJECT%.pld %DEST%%FNAME%SE-%LAYOUT%.PLD >nul 2>nul
goto:eof

:collect_SX2
copy sx2_%LAYOUT%_layout\dual_epbios_sx2_%YENSLASH%\%PROJECT%.pld %DEST%%FNAME%DE-%LAYOUT%.PLD >nul 2>nul
copy sx2_%LAYOUT%_layout\single_epbios_sx2_%YENSLASH%\%PROJECT%.pld %DEST%%FNAME%SE-%LAYOUT%.PLD >nul 2>nul
goto:eof

:create_FLASH_BAT
set OUTPUT=%DEST%FLASH.BAT
rem.>%OUTPUT%
echo ECHO>>%OUTPUT%
echo IF {%%1} == {} ECHO *** Missing parameter [filename.pld]>>%OUTPUT%
echo IF {%%1} == {} EXIT>>%OUTPUT%
echo IF NOT EXIST %%1 ECHO *** File not found>>%OUTPUT%
echo IF NOT EXIST %%1 EXIT>>%OUTPUT%
echo CLS>>%OUTPUT%
echo ECHO OCM-PLD UPDATE>>%OUTPUT%
echo ECHO ==============>>%OUTPUT%
echo ECHO>>%OUTPUT%
echo ECHO Firmware: %%1>>%OUTPUT%
echo ECHO Version:  %VERSION%>>%OUTPUT%
echo ECHO>>%OUTPUT%
echo SET EXPERT ON>>%OUTPUT%
echo PLDFLASH %%1>>%OUTPUT%
echo ECHO>>%OUTPUT%
set OUTPUT=%DEST%FLASH.TXT
rem.>%OUTPUT%
echo.>>%OUTPUT%
echo OCM-PLD UPDATE>>%OUTPUT%
echo ==============>>%OUTPUT%
echo.>>%OUTPUT%
echo OCMPP-??.PLD ... 1chipMSX (MSX++ logo)>>%OUTPUT%
echo OCM2P-??.PLD ... 1chipMSX (MSX2+ logo)>>%OUTPUT%
echo SX1ES-??.PLD ... SX-1 (regular)>>%OUTPUT%
echo SX1MN-??.PLD ... SX-1 Mini/Mini+>>%OUTPUT%
echo ZEMBR-??.PLD ... Zemmix Neo Brazilian>>%OUTPUT%
echo ZEMKR-??.PLD ... Zemmix Neo Korean>>%OUTPUT%
echo.>>%OUTPUT%
echo ?? = keyboard layouts>>%OUTPUT%
echo.>>%OUTPUT%
echo Examples:>>%OUTPUT%
echo.>>%OUTPUT%
echo FLASH OCMPP-JP.PLD>>%OUTPUT%
echo FLASH OCM2P-US.PLD>>%OUTPUT%
echo.>>%OUTPUT%
goto:eof

:create_XFLASH_BAT
set OUTPUT=%DEST%XFLASH.BAT
rem.>%OUTPUT%
echo ECHO>>%OUTPUT%
echo IF {%%1} == {} ECHO *** Missing parameter [filename.pld]>>%OUTPUT%
echo IF {%%1} == {} EXIT>>%OUTPUT%
echo IF NOT EXIST %%1 ECHO *** File not found>>%OUTPUT%
echo IF NOT EXIST %%1 EXIT>>%OUTPUT%
echo CLS>>%OUTPUT%
echo ECHO OCM-PLD UPDATE for %DEVNAME%>>%OUTPUT%
echo ECHO ===================%UNDERLN%>>%OUTPUT%
echo ECHO>>%OUTPUT%
echo ECHO Firmware: %%1>>%OUTPUT%
echo ECHO Version:  %VERSION%>>%OUTPUT%
echo ECHO>>%OUTPUT%
echo SET EXPERT ON>>%OUTPUT%
echo SMXFLASH %%1>>%OUTPUT%
echo ECHO>>%OUTPUT%
set OUTPUT=%DEST%XFLASH.TXT
rem.>%OUTPUT%
echo.>>%OUTPUT%
echo OCM-PLD UPDATE for %DEVNAME%>>%OUTPUT%
echo ===================%UNDERLN%>>%OUTPUT%
echo.>>%OUTPUT%
echo %FNAME%DE-??.PLD ... Dual-EPBIOS>>%OUTPUT%
echo %FNAME%SE-??.PLD ... Single-EPBIOS>>%OUTPUT%
echo.>>%OUTPUT%
echo ?? = keyboard layouts>>%OUTPUT%
echo.>>%OUTPUT%
echo Examples:>>%OUTPUT%
echo.>>%OUTPUT%
echo XFLASH %FNAME%DE-JP.PLD>>%OUTPUT%
echo XFLASH %FNAME%SE-US.PLD>>%OUTPUT%
echo.>>%OUTPUT%
goto:eof

:err_PLDFLASH_COM
if "%1"=="" color f0
echo.&echo 'pldflash.com' not found!
goto ocm_sm

:err_SMXFLASH_COM
if "%1"=="" color f0
echo.&echo 'smxflash.com' not found!

:quit
if "%1"=="" waitfor /T %TIMEOUT% pause 2>nul
