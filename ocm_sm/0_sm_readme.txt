Collect the firmware using the scripts for SM-X and SX-2
========================================================

Prerequisites:
--------------
a.  Install Quartus Prime v21.1.1 Lite Edition on a Windows OS.

b.  Copy the full project in a folder (both 'esemsx3\' and 'ocm_sm\' subfolders).


How to:
-------
1.  Run one of the "!!-init-*.cmd" scripts to initialize the desired device.

2.  Run '1_sm_compile.cmd' and go with 'Start Compilation' of Quartus Prime.
    When done select 'Convert Programming Files...' from the 'File' menu,
    open your favorite '.cof' file and press the 'Generate' button.
    By jumping the conversion you obtain a PLD firmware without the EPBIOS:
    the machine will run using the SDBIOS only, useful for manufacturers.

3.  Get out from Quartus Prime and run '2_sm_finalize.cmd'.

4.  And proceed with '3_sm_collect.cmd'.
    The firmware is stored in the 'fw\' subfolder.

5.  If you are bored then collect the firmware using '4_sm_auto-collect.cmd'
    and run '5_sm_fw-upload.cmd' to start programming via USB-Blaster [USB-0].
    The 'ocm_sm_512k_dual_epbios_backslash.cof' file is used by default.


Note: 
-----
The 'zz*.cmd' scripts are used to get the Multi-Release in a short time.


__________________________________________
'0_sm_readme.txt' v2.9 by KdL (2022.11.27)
