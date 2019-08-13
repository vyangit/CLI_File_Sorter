@echo off & setlocal EnableDelayedExpansion
setlocal
:: Sets the script variables and directory names
echo ------------SERIALIZED FILE SORTER SCRIPT------------
echo ---------------Initializing script----------------
:: Comment out if your file paths are variable

set /p srcDir=Indicate the Source Directory (Folder with scanned pdfs): 
set /p boxDir=Indicate the Box Directory (Folder to store box files): 
set /p destDir=Indicate the Destination Archive (Folder containing file folders): 
:: Comment out if your file paths are constant
REM set "srcDir=testSrc"
REM set "boxDir=testBox\Box 5000"
REM set "destDir=testDest"

echo:
echo Source Directory: %srcDir%
echo Destination Archive: %destDir%
echo Box Directory: %boxDir%
set /p confirmation="Use the following source, destination, and box directories (Y/N): "
set gotoReturn=Confirmed_Directories
goto :check_confirmation
:Confirmed_Directories
set gotoReturn=Checked_Directories
goto check_directories_exist
:Checked_Directories
echo:

:: List out the files to be sorted into the destination directory
echo Finding scanned files...
echo The following files will be renamed and sorted...
set len=-1
for /f delims^=^ eol^= %%f in ('dir %srcDir% /A:-D /B /O:N ^| findstr /B /R [0-9][0-9][0-9][0-9][0-9]\-[A-Z]\.pdf') do (
    set /a len+=1
    set scannedFiles[!len!]=%%f!
    echo %%f
)
if %len% LSS 0 (
    echo No scanned files were found
    goto abort
)
set /p confirmation="Indicated files are reviewed and ready to sort (Y/N): "
set gotoReturn=Confirmed_Files
goto check_confirmation
:Confirmed_Files

:: Copy files to box folder
echo:
echo Copying files to box directory...
for /l %%i in (0,1,%len%) do (
    copy /-Y "!srcDir!\!scannedFiles[%%i]!" "!boxDir!\!scannedFiles[%%i]:.pdf= completed scanned file.pdf!"
    echo !srcDir!\!scannedFiles[%%i]! !boxDir!\!scannedFiles[%%i]:.pdf= completed scanned file.pdf!
)

:: Rename files and find their corresponding folder if the folder exists
echo:
echo Moving files to archive location if possible...
for /l %%i in (0,1,%len%) do (
    echo Sorting !boxDir!\!scannedFiles[%%i]:.pdf= completed scanned file.pdf!...
    set dirCount=0
    for /f delims^=^ eol^= %%f in ('dir /q "!destDir!\*!scannedFiles[%%i]:.pdf=!" /a:d /s /b') do (
        set foundDirs[!dirCount!]=%%f
        set /a dirCount+=1
    )
    if !dirCount! EQU 0 (
        echo         Directory not found.
        pause 
    ) 
    if !dirCount! GTR 1 (
        echo         File not moved. More than 1 file found. 
        set /a foundDirsEndIndex=!dirCount!-1
        for /l %%j in (0,1,!foundDirsEndIndex!)do (
            echo         - !foundDirs[%%j]!
        )
        pause 
    )
    if !dirCount! EQU 1 (
        copy /-Y "!boxDir!\!scannedFiles[%%i]:.pdf= completed scanned file.pdf!" !foundDirs[0]!
    )
)

:: Terminate script
echo:
echo ---------Scanned files renamed and sorted---------
echo ----------------Terminating script----------------
exit /b 0

:: Function to rename the scanned file to following regex format "%d[5]-[A-Z] Completed Scanned File"
:parse_and_rename_scanned_file

:: Function to check if %srcDir%, %destDir%, %boxDir% are valid
:check_directories_exist
echo Checking if directories exist...
if "!srcDir!"=="" (
    goto srcDir_invalid  
) else (
    if not exist !srcDir! goto srcDir_invalid
)

if "!destDir!"=="" (
    goto destDir_invalid  
) else (
    if not exist !destDir! goto destDir_invalid
)
if "!boxDir!"=="" (
    goto boxDir_invalid  
) else (
    if not exist !boxDir! goto boxDir_invalid
)
echo All directories are valid and exists
goto %gotoReturn%

:srcDir_invalid
echo Source Directory is invalid
goto abort

:destDir_invalid
echo Destination Archive Directory is invalid
goto abort

:boxDir_invalid
echo Box Directory is invalid
goto abort

:: Function to check the %confirmation% variable
:check_confirmation
if not [%confirmation%]==[y] if not [%confirmation%]==[Y] (
    goto abort
)
goto %gotoReturn%

:abort
echo -----------------Aborting script------------------
exit /b
endlocal
