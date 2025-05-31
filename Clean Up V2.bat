@echo off

:: Check for Administrator privileges
>nul 2>&1 net session
if %errorlevel% neq 0 (
    echo Requesting administrative privileges...
    powershell -Command "Start-Process '%~f0' -Verb RunAs"
    exit /b
)

:: Start the disk cleanup utility
echo Running Disk Cleanup...
cleanmgr /sagerun:1

:: Clear Temporary files
echo Deleting temporary files...
del /q /f /s "%TEMP%\*" >nul 2>&1

:: Clear Temporary files
echo Deleting Temporary files...
rd /s /q "C:\Windows\Temp" >nul 2>&1
md "C:\Windows\Temp" >nul 2>&1

:: Clear Prefetch files
echo Deleting Prefetch files...
rd /s /q "C:\Windows\Prefetch" >nul 2>&1
md "C:\Windows\Prefetch" >nul 2>&1

:: Clear browser cache (for Chrome and Firefox as an example)
echo Clearing browser cache...
del /q /f /s "%LocalAppData%\Google\Chrome\User Data\Default\Cache\*" >nul 2>&1
del /q /f /s "%AppData%\Mozilla\Firefox\Profiles\*.default\cache2\*" >nul 2>&1

:: Remove old system restore points
echo Removing old system restore points...
vssadmin delete shadows /for=C: /oldest

:: Clear DNS cache
echo Flushing DNS Cache...
ipconfig /flushdns

:: Clear Windows Update Cache (requires admin privileges)
echo Clearing Windows Update Cache...
net stop wuauserv
del /f /s /q %windir%\SoftwareDistribution\Download\*
net start wuauserv

:: List all restore points
echo Listing all restore points...
vssadmin list shadows > "%temp%\restorepoints.txt"

:: Find the latest restore point
for /f "skip=1 tokens=2 delims=:" %%a in ('findstr /i "Shadow Copy" "%temp%\restorepoints.txt"') do set latest=%%a

:: Remove all restore points except the latest one
echo Removing old restore points...
for /f "skip=1 tokens=2 delims=:" %%b in ('findstr /i "Shadow Copy" "%temp%\restorepoints.txt"') do (
    if not "%%b"=="%latest%" (
        vssadmin delete shadows /Shadow=%%b /Quiet
    )
)

:: Deleting old restore point...
del "%temp%\restorepoints.txt"

:: Clean up using built-in Windows tool (optimize system performance)
echo Optimizing System Performance...

:: Ask for user confirmation to optimize all drives
set /p userInput="Do you want to optimize all drives? (Y/N): "

:: If user responds with Y or y, proceed with defragmentation
if /i "%userInput%"=="Y" (
    echo Defragmenting all drives...
    for /f "tokens=1" %%a in ('wmic logicaldisk get name ^| findstr /r "^[A-Z]"') do (
        defrag %%a: /O
    )
    echo Optimization complete for all drives.
) else (
    echo Optimization canceled.
)

:: End
echo Cleaning completed.
echo Press any key to end...
pause >nul
