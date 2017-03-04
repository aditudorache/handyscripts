@echo off

echo Removing all the bin and obj folders from the solution
Powershell.exe -NoProfile -ExecutionPolicy Bypass -File "%~dp0\clean-build-ps.ps1" 