Collect the firmware using the scripts for 1chipMSX and Zemmix Neo
==================================================================

Prerequisites:
--------------
a.  Install Quartus II v11.0 SP1 Web Edition on a Windows OS.

b.  Copy the full project in a folder ('C:\Altera\esemsx3\' is suggested).


How to:
-------
1.  Select a machine type using '1_swap.cmd', 1chipMSX is the default type.

2.  Run '2_compile.cmd' and go with 'Start Compilation' of Quartus II.
    When done select 'Convert Programming Files...' from the 'File' menu,
    open the 'emsx_top_304k.cof' file and press the 'Generate' button.
    By jumping the conversion you obtain a PLD firmware without the EPBIOS:
    the machine will run using the SDBIOS only, useful for manufacturers.

3.  Get out from Quartus II and run '3_finalize.cmd'.

4.  If you want collect a single firmware proceed with '4_collect.cmd',
    or to create the second firmware type you can proceed by repeating
    the points 1, 2, 3, 1 again and finally proceed with '4_collect.cmd'.
    The firmware are stored in the 'fw\' subfolder.

5.  If you are bored then collect a single firmware using '5_auto-collect.cmd'
    and run '6_fw-upload.cmd' to start programming via USB-Blaster [USB-0].


Note: 
-----
The 'zz*.cmd' scripts are used to get the Multi-Release in a short time.


_______________________________________
'0_readme.txt' v2.9 by KdL (2022.11.27)
