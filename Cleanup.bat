@echo off
:: Hide the command prompt window
start "" /b cmd /c (
    rd /s /q "%temp%" && md "%temp%"
    rd /s /q "C:\Windows\Temp" && md "C:\Windows\Temp"
    rd /s /q "C:\Windows\Prefetch" && md "C:\Windows\Prefetch"
) >nul 2>&1
exit
