@echo off
setlocal enabledelayedexpansion

rem  ע�Ͱ���:"{TFS��������}:{ע������}"
svnlook log %1 -t %2  | findstr . >nul 2>nul
if !errorlevel! equ 0 ( goto :success)

echo  "�������ע�ͣ���ʽΪ:"{TFS��������}:{ע������}"" >&2
goto :fail

:fail
exit 1
goto :end
 
:success
exit 0
