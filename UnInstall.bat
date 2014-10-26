@ECHO OFF
@PowerShell -Command "&{ Start-Process PowerShell.exe -ArgumentList @('-ExecutionPolicy UnRestricted -Command "%~dp0UnInstall.ps1"';) -Verb runas -Wait; }"

