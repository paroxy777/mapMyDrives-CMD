@ECHO OFF
CLS
SET "scriptTitle=    MAP MY DRIVES"
SET barDouble=====================================================================
SET barSingle=--------------------------------------------------------------------
SET mapHome=0
SET mapWTC=0
SET clearMaps=0
SET smbUser=0
SET smbPass=0

:: Display HEADER text
ECHO %barDouble%
ECHO %scriptTitle%
ECHO %barDouble%

ECHO -- YOUR EXISTING MAPPED DRIVES:
ECHO %barSingle%
NET USE


:: Choices, choices, choices.
ECHO %barSingle%
ECHO -- What are we doing today?
ECHO %barSingle%
CHOICE /C YN /M "Remove all exisiting mapped drives?"
IF %ERRORLEVEL% EQU 1 SET clearMaps=1
CHOICE /C YN /M "Map drives for Home Server 10.77.80.50?"
IF %ERRORLEVEL% EQU 1 SET mapHome=1
CHOICE /C YN /M "Map drives for WTC Server 192.168.10.10?"
SET mapWTC=%ERRORLEVEL%

:: MAIN APP BODY
IF %clearMaps% EQU 1 (CALL :sub_clear_exisiting) ELSE (ECHO --Keeping current mapped drives.)
IF %clearMaps% EQU 1 (CALL :sub_map_home) ELSE (ECHO --SKIP:Mapping drives for Home Server 10.77.80.50.)
IF %clearMaps% EQU 1 (CALL :sub_map_wtc) ELSE (ECHO --SKIP:Mapping drives for WTC Server 192.168.1.10.)
GOTO eof

:: SUB-ROUTINES
:sub_clear_exisiting
ECHO %barSingle%
ECHO -- REMOVING CURRENTLY MAPPED DRIVES
ECHO %barSingle%
NET USE * /delete
EXIT /B

:sub_map_home
ECHO %barSingle%
ECHO -- MAPPING DRIVES FOR HOME SERVER
ECHO %barSingle%
SET /P smbUser=Enter SMB username on [10.77.80.50]: 
SET /P smbPass=Enter SMB password for [%smbUser%] on [10.77.80.50]: 
ECHO --- H: for "Downloads"
NET USE H: \\10.77.80.50\Downloads %smbPass% /user:%smbUser% /persistent:yes <NUL
SET "smbUser="
SET "smbPass="
ECHO --- I: for "David Stuff"
NET USE I: "\\10.77.80.50\David Stuff" /persistent:yes <NUL
ECHO --- J: for "isos"
NET USE J:  \\10.77.80.50\isos /persistent:yes <NUL
EXIT /B

:sub_map_wtc
ECHO %barSingle%
ECHO -- MAPPING DRIVES FOR WTC
ECHO %barSingle%
SET /P smbUser=Enter SMB username on [192.168.1.10]: 
SET /P smbPass=Enter SMB password for [%smbUser%] on [192.168.1.10]: 
ECHO --- S: for "isos"
NET USE S: \\192.168.1.10\isos %smbPass% /user:%smbUser% /persistent:yes <NUL
SET "smbUser="
SET "smbPass="
ECHO --- T: for "Tools"
NET USE T: \\192.168.1.10\Tools /persistent:yes <NUL
EXIT /B

:: CLEAN-UP AND EXIT
:eof
REM Show results to user
ECHO %barSingle%
ECHO -- YOUR MAPPED DRIVES:
ECHO %barSingle%
NET USE
ECHO -- DONE
REM Clear VARs
SET "scriptTitle="
SET "barDouble="
SET "barSingle="
SET "mapHome="
SET "mapWTC="
SET "clearMaps="
SET "smbUser="
SET "smbPass="
EXIT /B 0
