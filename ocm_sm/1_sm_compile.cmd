@echo off
rem --- '1_sm_compile.cmd' v2.7 by KdL (2021.08.23)

set TIMEOUT=1
set PROJECT=ocm_sm
set OUTPUT=output_files\
set QPATH=C:\Altera\13.0sp1\quartus\
if "%1"=="" color 87&title COMPILE for %PROJECT%
if not exist %PROJECT%_device.env goto err_init
if not exist %PROJECT%.qpf goto err_msg
if exist %QPATH%bin64\quartus.exe (
    start %QPATH%bin64\quartus.exe %PROJECT%.qpf
    goto init
)
if exist %QPATH%bin\quartus.exe (
    start %QPATH%bin\quartus.exe %PROJECT%.qpf
    goto init
)
if not exist "%QUARTUS_ROOTDIR%\common\devinfo\cycloneive" goto err_quartus
explorer %PROJECT%.qpf

:init
del "## BUILDING FAILED ##.log" >nul 2>nul
md %OUTPUT% >nul 2>nul
echo /* Quartus II 64-Bit Version 13.0.1 Build 232 06/12/2013 Service Pack 1 SJ Web Edition */>%OUTPUT%%PROJECT%.cdf
echo JedecChain;>>%OUTPUT%%PROJECT%.cdf
echo     FileRevision(JESD32A);>>%OUTPUT%%PROJECT%.cdf
echo     DefaultMfr(6E);>>%OUTPUT%%PROJECT%.cdf
echo.>>%OUTPUT%%PROJECT%.cdf
echo     P ActionCode(Cfg)>>%OUTPUT%%PROJECT%.cdf
echo         Device PartName(EP4CE22) Path("../") File("ocm_sm.jic") MfrSpec(OpMask(1) SEC_Device(EPCS64) Child_OpMask(1 1));>>%OUTPUT%%PROJECT%.cdf
echo.>>%OUTPUT%%PROJECT%.cdf
echo ChainEnd;>>%OUTPUT%%PROJECT%.cdf
echo.>>%OUTPUT%%PROJECT%.cdf
echo AlteraBegin;>>%OUTPUT%%PROJECT%.cdf
echo     ChainType(JTAG);>>%OUTPUT%%PROJECT%.cdf
echo AlteraEnd;>>%OUTPUT%%PROJECT%.cdf
goto quit

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
echo.&echo '%PROJECT%.qpf' not found!

:timer
if "%1"=="" waitfor /T %TIMEOUT% pause >nul 2>nul

:quit
