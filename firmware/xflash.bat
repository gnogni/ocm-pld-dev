ECHO
IF {%1} == {} ECHO *** Missing parameter [filename.pld]
IF {%1} == {} EXIT
IF NOT EXIST %1 ECHO *** File not found [%1]
IF NOT EXIST %1 EXIT
CLS
ECHO OCM-PLD UPDATE for 2nd Gen
ECHO ==========================
ECHO
ECHO Firmware: %1
ECHO
SET EXPERT ON
SMXFLASH %1
ECHO
IF {%2} == {} EXIT
ECHO Custom Setup: %2
ECHO
SETSMART %2
