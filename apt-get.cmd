@echo off

:: echo %1
:: echo %2
:: echo Start installing common packages with chocolatey
Powershell.exe -NoProfile -ExecutionPolicy Bypass -File "%~dp0\apt-get-ps.ps1" %1 %2   