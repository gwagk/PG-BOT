@echo off
setlocal
title PG-BOT - PORT GUARD BOT
color 0A
cls

rem PG-BOT | PORT GUARD BOT
rem Developed by Lung Aunty - Pattani Port
rem Human x AI Collaboration: ChatGPT + Pinta
rem Scope: User TEMP cleanup only. No Admin. No telemetry.

set "RECEIPT=%~dp0PG-BOT-LAST.txt"

echo ========================================
echo              PG-BOT
echo          PORT GUARD BOT
echo ========================================
echo.
echo Scanning...

for /f "delims=" %%A in ('powershell -NoProfile -Command "$s=(Get-ChildItem -LiteralPath $env:TEMP -File -Recurse -Force -ErrorAction SilentlyContinue | Measure-Object Length -Sum).Sum; if($null -eq $s){$s=0}; [math]::Round($s,0)"') do set "BEFORE=%%A"

echo Cleaning...

powershell -NoProfile -Command "Get-ChildItem -LiteralPath $env:TEMP -Force -ErrorAction SilentlyContinue | Remove-Item -Recurse -Force -ErrorAction SilentlyContinue"

echo Verifying...

for /f "delims=" %%A in ('powershell -NoProfile -Command "$s=(Get-ChildItem -LiteralPath $env:TEMP -File -Recurse -Force -ErrorAction SilentlyContinue | Measure-Object Length -Sum).Sum; if($null -eq $s){$s=0}; [math]::Round($s,0)"') do set "AFTER=%%A"

for /f "delims=" %%A in ('powershell -NoProfile -Command "$c=[math]::Max(0,([double]%BEFORE%-[double]%AFTER%)); if($c -ge 1GB){'{0:N2} GB' -f ($c/1GB)}else{'{0:N1} MB' -f ($c/1MB)}"') do set "CLEANED=%%A"

for /f "delims=" %%A in ('powershell -NoProfile -Command "$a=[double]%AFTER%; if($a -ge 1GB){'{0:N2} GB' -f ($a/1GB)}else{'{0:N1} MB' -f ($a/1MB)}"') do set "REMAIN=%%A"

(
echo PG-BOT ^| PORT GUARD BOT
echo.
echo Last run : %date% %time:~0,8%
echo Cleaned  : %CLEANED%
echo Remain   : %REMAIN%
echo Status   : DONE
echo.
echo Developed by Lung Aunty - Pattani Port
echo Human x AI Collaboration: ChatGPT + Pinta
) > "%RECEIPT%"

cls
echo ========================================
echo              PG-BOT
echo          PORT GUARD BOT
echo ========================================
echo.
echo Cleaned : %CLEANED%
echo Remain  : %REMAIN%
echo.
echo                 DONE
echo.
echo Receipt : PG-BOT-LAST.txt
echo ========================================
echo.
timeout /t 5 /nobreak >nul

endlocal
