@echo off
chcp 65001 >nul
setlocal
title PG-BOT - PORT GUARD BOT
color 0A
cls

rem PG-BOT | PORT GUARD BOT
rem Version 1.0 RC
rem Developed: 20 Sep 2026
rem Developed by Lung Aunty - Pattani Port
rem Human x AI Collaboration: ChatGPT + Pinta
rem Scope: User TEMP cleanup only. No Admin. No telemetry.

set "RECEIPT=%~dp0PG-BOT-LAST.txt"
set "COMPUTER_NAME=%COMPUTERNAME%"
set "PLATFORM=Windows"

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
echo Version       : 1.0 RC
echo Developed     : 20 Sep 2026
echo.
echo Last run      : %date% %time:~0,8%
echo Cleaned       : %CLEANED%
echo Remain        : %REMAIN%
echo Status        : DONE
echo.
echo Computer Name : %COMPUTER_NAME%
echo Platform      : %PLATFORM%
echo.
echo กรุณาคัดลอก Computer Name ของเครื่องนี้
echo ไปกรอกในแอป DTMC ให้ตรงกับเลขครุภัณฑ์ของเครื่อง
echo.
echo Developed by Lung Aunty - Pattani Port
echo Human x AI Collaboration ^| ChatGPT + Pinta
echo.
echo Note: Last run uses this computer's local date/time.
) > "%RECEIPT%"

cls
echo ========================================
echo              PG-BOT
echo          PORT GUARD BOT
echo ========================================
echo.
echo Cleaned       : %CLEANED%
echo Remain        : %REMAIN%
echo Status        : DONE
echo.
echo ========================================
echo Computer Name : %COMPUTER_NAME%
echo Platform      : %PLATFORM%
echo ========================================
echo.
echo กรุณาคัดลอก Computer Name ของเครื่องนี้
echo ไปกรอกในแอป DTMC ให้ตรงกับเลขครุภัณฑ์ของเครื่อง
echo.
echo กดปุ่มใดก็ได้เพื่อออกจากหน้านี้
echo.
pause >nul

endlocal
