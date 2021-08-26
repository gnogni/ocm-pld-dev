ECHO
IF {%1} == {} ECHO *** Missing parameter [filename.pld]
IF {%1} == {} EXIT
IF NOT EXIST %1 ECHO *** File not found
IF NOT EXIST %1 EXIT
CLS
ECHO OCM-PLD UPDATE
ECHO ==============
ECHO
ECHO Firmware: %1
ECHO
SET EXPERT ON
PLDFLASH %1
ECHO
