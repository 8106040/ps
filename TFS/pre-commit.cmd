@echo off
setlocal enabledelayedexpansion

rem  注释包含:"{TFS工作项编号}:{注释内容}"
svnlook log %1 -t %2  | findstr . >nul 2>nul
if !errorlevel! equ 0 ( goto :success)

echo  "必须包含注释，格式为:"{TFS工作项编号}:{注释内容}"" >&2
goto :fail

:fail
exit 1
goto :end
 
:success
exit 0
