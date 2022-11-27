@echo off
call :cleanup

@rem ==========================================================================
@rem  1st generation
@rem ==========================================================================
echo.&echo [ small icon 304k ]
zma.exe ../iplrom_304k_rev300.asm iplrom_304k_rev300.bin
if %ERRORLEVEL% == 0 (
bin2v iplrom_304k_rev300.bin iplrom_body.v 10 >nul
copy /b iplrom_header_304k.v+iplrom_body.v+iplrom_footer.v ..\..\iplrom_304k.v >nul
)
ren zma.log zma_304k.log

echo.&echo [ preloader 304k ]
zma.exe ../hex_iplrom_304k_rev300_preloader.asm hex_iplrom_304k_rev300_preloader.bin
if %ERRORLEVEL% == 0 (
bin2v hex_iplrom_304k_rev300_preloader.bin iplrom_body.v 9 >nul
copy /b preloader_header_304k.v+iplrom_body.v+iplrom_footer.v ..\..\hex_iplrom\iplrom_304k.v >nul
)
ren zma.log zma_304k_preloader.log

echo.&echo [ hex standard icon 304k ]
zma.exe ../hex_iplrom_304k_rev300.asm hex_iplrom_304k_rev300.bin
if %ERRORLEVEL% == 0 (
bin2hex hex_iplrom_304k_rev300.bin iplrom_body_304k.hex >nul
copy /b iplrom_header_304k.hex+iplrom_body_304k.hex ..\..\hex_iplrom\iplrom_304k.hex >nul
)
ren zma.log zma_304k_hex.log

echo.&echo [ IPL standard icon 304k ]
zma.exe ../ipl_iplrom_304k_rev300.asm ..\..\ipl_iplrom\GEN1ROM.IPL
ren zma.log zma_304k_ipl.log

@rem ==========================================================================
@rem  2nd generation
@rem ==========================================================================
echo.&echo [ standard icon 512k ]
zma.exe ../iplrom_512k_rev300.asm iplrom_512k_rev300.bin
if %ERRORLEVEL% == 0 (
bin2v iplrom_512k_rev300.bin iplrom_body.v 11 >nul
copy /b iplrom_header_512k.v+iplrom_body.v+iplrom_footer.v ..\..\iplrom_512k.v >nul
)
ren zma.log zma_512k.log

echo.&echo [ preloader 512k ]
zma.exe ../hex_iplrom_512k_rev300_preloader.asm hex_iplrom_512k_rev300_preloader.bin
if %ERRORLEVEL% == 0 (
bin2v hex_iplrom_512k_rev300_preloader.bin iplrom_body.v 9 >nul
copy /b preloader_header_512k.v+iplrom_body.v+iplrom_footer.v ..\..\hex_iplrom\iplrom_512k.v >nul
)
ren zma.log zma_512k_preloader.log

echo.&echo [ hex standard icon 512k single epbios ]
zma.exe ../hex_iplrom_512k_rev300_single_epbios.asm hex_iplrom_512k_rev300_single_epbios.bin
if %ERRORLEVEL% == 0 (
bin2hex hex_iplrom_512k_rev300_single_epbios.bin iplrom_body_512k.hex >nul
copy /b iplrom_header_512k_single_epbios.hex+iplrom_body_512k.hex ..\..\hex_iplrom\iplrom_512k_single_epbios.hex >nul
)
ren zma.log zma_512k_hex_single_epbios.log

echo.&echo [ IPL standard icon 512k single epbios ]
zma.exe ../ipl_iplrom_512k_rev300_single_epbios.asm ..\..\ipl_iplrom\GEN2ROMS.IPL
ren zma.log zma_512k_ipl_single_epbios.log

echo.&echo [ hex standard icon 512k dual epbios ]
zma.exe ../hex_iplrom_512k_rev300_dual_epbios.asm hex_iplrom_512k_rev300_dual_epbios.bin
if %ERRORLEVEL% == 0 (
bin2hex hex_iplrom_512k_rev300_dual_epbios.bin iplrom_body_512k.hex >nul
copy /b iplrom_header_512k_dual_epbios.hex+iplrom_body_512k.hex ..\..\hex_iplrom\iplrom_512k_dual_epbios.hex >nul
)
ren zma.log zma_512k_hex_dual_epbios.log

echo.&echo [ IPL standard icon 512k dual epbios ]
zma.exe ../ipl_iplrom_512k_rev300_dual_epbios.asm ..\..\ipl_iplrom\GEN2ROMD.IPL
ren zma.log zma_512k_ipl_dual_epbios.log

del iplrom_body*.*
echo.
if not "%1"=="--cleanup" pause&exit
del /S /Q ..\..\*.bak >nul 2>nul

:cleanup
del *.bin >nul 2>nul
del zma.sym >nul 2>nul
del zma*.log >nul 2>nul
del ..\..\iplrom*.* >nul 2>nul
del ..\..\hex_iplrom\iplrom*.* >nul 2>nul
del ..\..\ipl_iplrom\*.ipl >nul 2>nul
goto:eof
