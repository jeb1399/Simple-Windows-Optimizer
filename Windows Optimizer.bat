@echo off

REM This is version 1 it has less

TITLE Windows Optimizer - Version 1
setlocal enabledelayedexpansion
net session >nul 2>&1
if %errorLevel% neq 0 (
    powershell -Command "Start-Process '%~f0' -Verb RunAs"
    exit /b
)
:disableServices
set "task1=false"
set services[0]=SysMain
set services[1]=Fax
set services[2]=ConnectedUserExperiencesAndTelemetry
set services[3]=WindowsErrorReporting
set services[4]=AeLookupSvc
set services[5]=DPS
set services[6]=WMPNetworkSvc
set services[7]=SCardSvr
set services[8]=ehRecvr
set services[9]=ScDeviceEnum
set services[10]=WAS
set services[11]=SENS
set services[12]=PLA
set services[13]=TrkWks
set serviceCount=14
echo Disabling unused services...
echo.
echo Options: 
echo     (Y)es
echo     (N)o
echo     (C)hoose which services
echo.
echo This will disable the following: 
echo     SysMain - This service is used for caching of programs on the drive to open faster. (Usually does the opposite)
echo     Fax - Who tf actually uses fax anymore.
echo     Connected User Experiences and Telemetry - A service that gathers and sends anonymous information about how you use your device to Microsoft.
echo     Windows Error Reporting - This shows up after you terminate a program that is frozen but also programs that encounter an error (sometimes).
echo     AeLookupSvc - This is for checking the compatibility of programs. Not really needed cause unsupported programs will most likely just not work.
echo     DPS - This is the diagnostics service for logging diagnostics. I dont ever use this so I added it to the list.
echo     WMPNetworkSvc - This service is used for sharing media libraries from Windows Media Player to other devices on your local network.
echo     SCardSvr - This services is for smart card whatever that is. I dont think anybody has ever even known about this.
echo     ehRecvr - This is the service to control Windows Media Center it was pretty cool... in 2005.
echo     ScDeviceEnum - This service is a part of smart card so if you disable smart card I would recommend disabling this too.
echo     WAS - This is just http server keepalive for windows. If you disable this you can still host http servers just not forever. (requires you to restart the server)
echo     SENS - This controls whether or not you can see stuff like "Setting up keyboard". Disables SYSTEM notifications (NOT ALL NOTIFICATIONS).
echo     dhcp - Like "DPS" "dhcp" is a service for diagnostics. And thats all I know.
echo     PLA - This service is designed to constantly log the performance.
echo     TrkWks - Controls link tracking which means it tracks whenever a file is moved, deleted, or renamed.
echo.
choice /M "Do you want to disable all these services? " /C YNC /N
if errorlevel 3 goto chooseServices
if errorlevel 2 goto defragEverything
if errorlevel 1 goto disAllServices
:chooseServices
echo Choose which services to disable (Y to disable, N to keep enabled):
for /L %%i in (0,1,%serviceCount%) do (
    set "service=!services[%%i]!"
    choice /M "!service! (Y/N)"
    if errorlevel 2 (
        echo Keeping "!service!" enabled.
    ) else (
        echo Disabling "!service!"...
        sc stop "!service!" >nul 2>&1
        sc config "!service!" start= disabled >nul 2>&1
        set "task1=true"
    )
)
:disAllServices
for /L %%i in (0,1,%serviceCount%) do (
    set "service=!services[%%i]!"
    sc stop "!service!" >nul 2>&1
    sc config "!service!" start= disabled >nul 2>&1
    set "task1=true"
)
cls
goto defragEverything
:defragEverything
set "task2=false"
cls
echo Optimizing disks...
echo.
choice /M "Defragment all disks? (Y/N)" /C YN /N
if errorlevel 2 goto compressWin
for %%a in (C D E F G H I J K L M N O P Q R S T U V W X Y Z) do (
    if exist %%a:\ (
        defrag %%a: /o /u >nul
        set "task2=true"
    )
)
:compressWin
set "task3=false"
cls
echo Compressing windows...
echo.
choice /M "Compress Windows (may take time)? (Y/N)" /C YN /N
if errorlevel 2 goto rmOnedrive
compact /compactos:always >nul
set "task3=true"
:rmOnedrive
set "task4=false"
cls
echo Removing OneDrive...
echo.
echo Don't worry your files will stay saved on whatever storage device you have.
echo.
choice /M "Remove OneDrive? (Y/N)" /C YN /N
if errorlevel 2 goto delApps
if errorlevel 1 (
    taskkill /f /im OneDrive.exe
    echo If a window opens asking for you to sign in to OneDrive, simply close it.
    rd /s /q "%LOCALAPPDATA%\Microsoft\OneDrive"
    rd /s /q "%PROGRAMDATA%\Microsoft\OneDrive"
    taskkill /f /im OneDrive.exe
    %SystemRoot%\SysWOW64\OneDriveSetup.exe /uninstall # Remove 32 bit onedrive
    %SystemRoot%\System32\OneDriveSetup.exe /uninstall # Remove 64 bit onedrive
    set "task4=true"
)
cls
echo Only use this if your files are stuck in "Sync pending"
echo.
choice /M "Reclaim files from OneDrive? (Y/N)" /C YN /N
if errorlevel 2 goto delApps
if errorlevel 1 (
    echo.
    echo This may take a long time depending on how many files you have.
    echo.
    echo Please wait...
    echo.
    powershell -NoProfile -ExecutionPolicy Bypass -Command "Get-ChildItem -Path C:\ -Recurse -Force -ErrorAction SilentlyContinue ^| ForEach-Object { attrib -p -u $_.FullName }"
    cls
    echo Done!
    goto delApps
)
:delApps
cls
echo Deleting bloat...
echo.
echo The following apps will be removed: 
echo.
echo     - Microsoft Edge
echo     - Copilot
echo     - Outlook
echo     - OneNote
echo     - Skype
echo     - Xbox game overlay
echo     - Bing news
echo     - Bing finance
echo     - Bing weather
echo     - Bing sports
echo     - Paint 3D
echo     - 3D Viewer
echo     - Windows Feedback
echo     - Windows Mail
echo     - Solitaire
echo     - Clock
echo     - Cortana
echo     - Calendar
echo     - Mail
echo     - Maps
echo     - Mixed Reality Portal
echo     - Movies and TV
echo     - Tips
echo     - Voice Recorder
echo     - Math Input Panel
echo     - Quick Assist
echo     - Windows Assist
echo     - Wordpad
echo.

set "task5=false"
choice /M "Do you want to delete some unnecessarily installed apps? (Y/N)" /C YN /N
if errorlevel 2 goto modifyPwr
if errorlevel 1 (
    for /d %%i in ("C:\Program Files (x86)\Microsoft\*Edge*") do (
        rmdir /s /q "%%i" > NUL 2>&1
    )
    rmdir /s /q "C:\Program Files (x86)\Microsoft\Edge" > NUL 2>&1
    rmdir /s /q "C:\Program Files (x86)\EdgeUpdate" > NUL 2>&1

    del /q "%ProgramData%\Microsoft\Windows\Start Menu\Programs\Microsoft Edge.lnk" > NUL 2>&1
    del /q "%APPDATA%\Microsoft\Windows\Start Menu\Programs\Microsoft Edge.lnk" > NUL 2>&1
    del /q "%APPDATA%\Microsoft\Internet Explorer\Quick Launch\User Pinned\TaskBar\Microsoft Edge.lnk" > NUL 2>&1

    for %%p in (
        "Microsoft.Copilot"
        "OutlookForWindows"
        "Microsoft.SkypeApp"
        "OneNote"
        "Microsoft.XboxGamingOverlay"
        "Microsoft.BingNews"
        "Microsoft.BingFinance"
        "Microsoft.BingWeather"
        "Microsoft.BingSports"
        "Microsoft.Paint3D"
        "Microsoft.3DViewer"
        "Microsoft.WindowsFeedback"
        "Microsoft.MicrosoftSolitaireCollection"
        "Microsoft.WindowsAlarms"
        "Microsoft.549981C3F5F10"
        "microsoft.windowscommunicationsapps"
        "Microsoft.BingMaps"
        "Microsoft.Windows.Holographic"
        "Microsoft.ZuneVideo"
        "Microsoft.GetStarted"
        "Microsoft.WindowsSoundRecorder"
        "Microsoft.MicrosoftMathInputControl"
        "Microsoft.GetHelp"
        "Microsoft.Windows.HelpExperience"
        "Microsoft.Windows.WordPad"
    ) do (
        powershell -Command "Get-AppxPackage *%%~p* | Remove-AppxPackage"
    )

    set "task5=true"
)

:modifyPwr
set "task6=false"
cls
echo Optimizing power plans...
echo.
choice /M "Do you want to modify your power plan? (Y/N)" /C YN /N
if errorlevel 2 goto editUva
if errorlevel 1 (
    for /f "tokens=2 delims=:(" %%a in ('powercfg /duplicatescheme e9a42b02-d5df-448d-aa00-03f14749eb61 ^| findstr /i "GUID"') do (
        powercfg /changename %%~a "Optimized     Performance"
        powercfg /setacvalueindex %%~a 0012ee47-9041-4b5d-9b77-535fba8b1442 6738e2c4-e8a5-4a42-b16a-e040e769756e 120
        powercfg /setdcvalueindex %%~a 0012ee47-9041-4b5d-9b77-535fba8b1442 6738e2c4-e8a5-4a42-b16a-e040e769756e 120
    )
    powercfg /setactive SCHEME_MIN
    set "task6=true"
)

:editUva
set "task7=false"
cls
echo Allocating more VA space...
echo.
choice /M "Do you want to allocate more virtual address space to applications? (Y/N)" /C YN /N
if errorlevel 2 goto showSummary
if errorlevel 1 (
    bcdedit /set increaseuserva 3072
    set "task7=true"
)


rem   _______ _________ _______  ________ 
rem  [  ____ \[__   __][  ___  ][  ____  ]
rem  | [    \/   | |   | [   ] || [    ] |
rem  | [_____    | |   | |   | || [____] |
rem  [_____  ]   | |   | |   | ||  ______]
rem        ] |   | |   | |   | || |      
rem   _____] |   | |   | [___] || |      
rem  [_______]   [_]   [_______][_]      

rem !!!DO NOT MODIFY THE CODE BELOW UNLESS YOU KNOW WHAT YOU ARE DOING AND HAVE ADDED ANOTHER STEP!!!
:showSummary
cls
for /f "tokens=2 delims=:" %%A in ('mode con ^| findstr "Columns"') do set /a termWidth=%%A
for /f "tokens=2 delims=:" %%A in ('mode con ^| findstr "Lines"') do set /a termHeight=%%A
set "border="
for /L %%A in (1,1,%termWidth%) do set "border=!border!*"
set /a contentWidth=termWidth-2
set "emptyLine=*"
for /L %%A in (1,1,%contentWidth%) do set "emptyLine=!emptyLine! "
set "emptyLine=!emptyLine!*"
call :centerText "**IMPORTANT**: You **MUST** restart your device for all changes to take effect." contentWidth
set "msg1=!centeredText!"
call :centerText "Thanks for using my script (:" contentWidth
set "msg2=!centeredText!"
call :centerText "Completed tasks:" contentWidth
set "msg3=!centeredText!"
call :centerText "* Disabled unused services: %task1%" contentWidth
set "t1=!centeredText!"
call :centerText "* Defragmented EVERY disk: %task2%" contentWidth
set "t2=!centeredText!"
call :centerText "* Compressed Windows: %task3%" contentWidth
set "t3=!centeredText!"
call :centerText "* Removed OneDrive: %task4%" contentWidth
set "t4=!centeredText!"
call :centerText "* Removed the worlds worst apps: %task5%" contentWidth
set "t5=!centeredText!"
call :centerText "* Optimized power plan: %task6%" contentWidth
set "t6=!centeredText!"
call :centerText "* Allocated more virtual address space: %task7%" contentWidth
set "t7=!centeredText!"
call :centerText "Press any key to exit" contentWidth
set "exitMsg=*!centeredText!*"
echo %border%
echo *%msg1%*
echo %emptyLine%
echo *%msg2%*
echo %emptyLine%
echo *%msg3%*
echo %emptyLine%
echo *%t1%*
echo %emptyLine%
echo *%t2%*
echo %emptyLine%
echo *%t3%*
echo %emptyLine%
echo *%t4%*
echo %emptyLine%
echo *%t5%*
echo %emptyLine%
echo *%t6%*
echo %emptyLine%
echo *%t7%*
echo %emptyLine%
echo %emptyLine%
echo %emptyLine%
echo %exitMsg%
echo %border%
pause >nul
exit /b
:centerText
setlocal
set "text=%~1"
set /a width=!%~2!
call :strLen "%text%" len
set /a pad=(width - len)/2
set "spaces="
for /L %%A in (1,1,%pad%) do set "spaces=!spaces! "
set "centered=!spaces!!text!"
set /a rem=width - pad - len
for /L %%A in (1,1,%rem%) do set "centered=!centered! "
endlocal & set "centeredText=%centered%"
exit /b
:strLen
setlocal enabledelayedexpansion
set "s=%~1"
set "len=0"
if defined s (
    set "s=!s!""<nul
    for %%# in (4096 2048 1024 512 256 128 64 32 16 8 4 2 1) do (
        if "!s:~%%#,1!" neq "" (
            set /a "len+=%%#"
            set "s=!s:~%%#!"
        )
    )
)
endlocal & set "%~2=%len%"
exit /b
