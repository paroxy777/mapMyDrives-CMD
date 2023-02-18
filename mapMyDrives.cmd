@ECHO OFF
:: =================================================================================================
:: INIT ENVIROMENT
:: =================================================================================================
SET _exitErrorLevel=0
SET _error_command=0
SET _error_message=0
SET _error_forceAbort=0
SET "scriptTitle=    MAP MY DRIVES"
SET barDouble=====================================================================
SET barSingle=--------------------------------------------------------------------
SET mapHome=0
SET mapWTC=0
SET clearMaps=0
SET smbUser=0
SET smbPass=0

REM Load external resources
CALL :sub_init_main
REM Display HEADER text
CALL :sub_print_header
REM Display currently mapped drives
CALL :sub_print_mappings
ECHO %barSingle%

:: =================================================================================================
:: MAIN
:: =================================================================================================
REM Get user preferences
ECHO -- What are we doing today?
ECHO %barSingle%
CHOICE /C YN /M "Remove all exisiting mapped drives?"
IF %ERRORLEVEL% EQU 1 SET clearMaps=1
CHOICE /C YN /M "Map drives for Home Server 10.77.80.50?"
IF %ERRORLEVEL% EQU 1 SET mapHome=1
CHOICE /C YN /M "Map drives for WTC Server 192.168.10.10?"
IF %ERRORLEVEL% EQU 1 SET mapWTC=1

REM Do actions selected by user
IF %clearMaps% EQU 1 (CALL :sub_clear_all_mappings) ELSE (ECHO --Keeping current mapped drives.)
IF %mapHome% EQU 1 (CALL :sub_map_home) ELSE (ECHO --SKIP:Mapping drives for Home Server 10.77.80.50.)
IF %mapWTC% EQU 1 (CALL :sub_map_wtc) ELSE (ECHO --SKIP:Mapping drives for WTC Server 192.168.1.10.)

REM Show results to user
ECHO %barSingle%
CALL :sub_print_mappings

REM End Script
GOTO end


:: =================================================================================================
:: SUB-ROUTINES
:: =================================================================================================
:sub_init_main
ECHO .
EXIT /B

:sub_print_header
CLS
ECHO %barDouble%
ECHO --
ECHO -- %scriptTitle%
ECHO --
ECHO %barDouble%
EXIT /B

:sub_error_abort
REM sub_error_abort STR(_error_command) STR(_error_message) INT(_error_forceAbort)
REM   - Display error messages to user.
REM   - Offer choice to abort script, or force the abort (see: _error_forceAbort)
REM   - Set these global vars to use:
REM         STR(_error_command): Command that was tested for ERRORLEVEL.
REM         STR(_error_message): Error message to display to user.
REM         INT(_error_forceAbort): 1==Force Abort.  Any other value==Ask user.
REM =============================================================================
REM Clear saved SMB credentials first
CALL :sub_clear_smb_creds
SET _exitErrorLevel=1
REM Print error details
ECHO %barDouble%
ECHO  -- ERROR in %_error_command%
ECHO %barSingle%
ECHO -- 
ECHO -- MESSAGE: %_error_message%
ECHO -- 
REM ECHO %barSingle%
REM Force Abort script?
IF %_error_forceAbort% EQU 1 (GOTO end)
REM Ask user to Abort (Broken, too many subs and exits)
REM CHOICE /C AC /M "Would you like to ABORT or CONTINUE the script?"
REM IF %ERRORLEVEL% EQU 0 (ECHO "CHOICE: 0")
REM IF %ERRORLEVEL% EQU 1 (GOTO end)
REM IF %ERRORLEVEL% EQU 2 (ECHO "-- RESUMING SCRIPT ...")
ECHO %barDouble%
ECHO -- Press CTRL+C to abort, or
PAUSE
EXIT /B

:sub_set_smb_creds
SET smbServer=%1%
REM %1 == (STR) SMB Server Name or IP
SET /P smbUser="Enter SMB USERNAME on [%smbServer%]: "
SET /P smbPass="Enter SMB PASSWORD for [%smbUser%]: "
EXIT /B

:sub_clear_smb_creds
SET "smbUser="
SET "smbPass="
EXIT /B

:sub_print_mappings
ECHO -- YOUR CURRENTLY MAPPED DRIVES:
NET USE
EXIT /B

:sub_clear_all_mappings
ECHO %barDouble%
ECHO -- REMOVING CURRENTLY MAPPED DRIVES
ECHO %barDouble%
NET USE * /delete
EXIT /B

:sub_map_home
ECHO %barDouble%
ECHO -- MAPPING DRIVES FOR HOME SERVER
ECHO %barDouble%
REM Get SMB credentials from user
CALL :sub_set_smb_creds 10.77.80.50
REM Attempt first mount with provided credentials
ECHO --- H: for "Downloads"
NET USE H: \\10.77.80.50\Downloads %smbPass% /user:%smbUser% /persistent:yes
IF %ERRORLEVEL% GTR 0 (
    SET _error_command="NET USE"
    SET _error_message="Drive mapping probably FAILED!"
    SET _error_forceAbort=0
    GOTO :sub_error_abort
) ELSE (
    CALL :sub_clear_smb_creds
)
REM Map other drives on this server
ECHO --- I: for "David Stuff"
NET USE I: "\\10.77.80.50\David Stuff" /persistent:yes
ECHO --- J: for "isos"
NET USE J: \\10.77.80.50\isos /persistent:yes
EXIT /B

:sub_map_wtc
ECHO %barDouble%
ECHO -- MAPPING DRIVES FOR WTC
ECHO %barDouble%
REM Get SMB credentials from user
CALL :sub_set_smb_creds 192.168.1.10
REM Attempt first mount with provided credentials
ECHO --- S: for "isos"
NET USE S: \\192.168.1.10\isos %smbPass% /user:%smbUser% /persistent:yes
IF %ERRORLEVEL% GTR 0 (
    SET _error_command="NET USE"
    SET _error_message="Drive mapping probably FAILED!"
    SET _error_forceAbort=0
    GOTO :sub_error_abort
) ELSE (
    CALL :sub_clear_smb_creds
)
REM Map other drives on this server
ECHO --- T: for "Tools"
NET USE T: \\192.168.1.10\Tools /persistent:yes
EXIT /B



:: =================================================================================================
:: CLEAN-UP AND EXIT
:: =================================================================================================
:sub_clear_error_vars
SET "_error_command="
SET "_error_message="
SET "_error_forceAbort="
EXIT /B

:end
REM Clear VARs
CALL :sub_clear_smb_creds
CALL :sub_clear_error_vars
SET "scriptTitle="
SET "barDouble="
SET "barSingle="
SET "mapHome="
SET "mapWTC="
SET "clearMaps="
SET "smbUser="
SET "smbPass="
ECHO %barDouble%
ECHO -- DONE
ECHO %barDouble%
REM Exit script and return an errorlevel code.
EXIT /B %_exitErrorLevel%