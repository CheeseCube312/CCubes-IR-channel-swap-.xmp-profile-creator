@echo off
setlocal enabledelayedexpansion
title XMP Profile Baker - Portable Edition
color 0A

echo ===============================================
echo  XMP Profile Baker - Infrared Photography
echo  Portable Edition - One-Click Setup
echo ===============================================
echo.

REM Set up paths
set "SCRIPT_DIR=%~dp0"
set "PYTHON_DIR=%SCRIPT_DIR%python_portable"
set "PYTHON_EXE=%PYTHON_DIR%\python.exe"
set "PYTHON_VERSION=3.12.7"
set "PYTHON_URL=https://www.python.org/ftp/python/%PYTHON_VERSION%/python-%PYTHON_VERSION%-amd64.exe"
set "PYTHON_TEMP=%SCRIPT_DIR%python_installer.exe"

REM Check if portable Python exists
if exist "%PYTHON_EXE%" (
    echo [V] Portable Python found - Starting program...
    goto :run_program
)

REM Check if system Python exists and works
echo [~] Checking for system Python installation...
python --version >nul 2>&1
if not errorlevel 1 (
    echo [V] System Python found - Starting program...
    set "PYTHON_EXE=python"
    goto :run_program
)

echo [!] No Python installation found
echo [->] Setting up portable Python environment...
echo     This is a one-time setup (~30MB download)

REM Create python directory
if not exist "%PYTHON_DIR%" mkdir "%PYTHON_DIR%"

REM Download Python installer
echo [->] Downloading Python %PYTHON_VERSION%...
powershell -Command "& { [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12; try { $webClient = New-Object System.Net.WebClient; $webClient.DownloadFile('%PYTHON_URL%', '%PYTHON_TEMP%'); Write-Host '[V] Download completed successfully' } catch { Write-Host '[X] Download failed:' $_.Exception.Message; exit 1 } }"

if errorlevel 1 (
    echo [X] Download failed! Check your internet connection.
    goto :error_exit
)

REM Verify download
if not exist "%PYTHON_TEMP%" (
    echo [X] Download file not found after download
    goto :error_exit
)

REM Check PowerShell availability first
powershell -Command "Get-Host" >nul 2>&1
if errorlevel 1 (
    echo [X] PowerShell not available - Cannot continue
    goto :error_exit
)

echo [->] Installing portable Python with GUI support...
REM Install Python to our portable directory
"%PYTHON_TEMP%" /quiet InstallAllUsers=0 TargetDir="%PYTHON_DIR%" Include_tcltk=1 Include_launcher=0 AssociateFiles=0 Shortcuts=0

REM Wait for installation to complete
timeout /t 10 >nul

REM Clean up installer
if exist "%PYTHON_TEMP%" del "%PYTHON_TEMP%"

REM Verify installation
if not exist "%PYTHON_EXE%" (
    echo [X] Python installation failed - executable not found
    echo Expected at: %PYTHON_EXE%
    goto :error_exit
) else (
    echo [V] Python executable found - Testing functionality...
    "%PYTHON_EXE%" --version >nul 2>&1
    if errorlevel 1 (
        echo [X] Python installation is corrupted
        goto :error_exit
    )
)

echo [V] Portable Python setup completed!
echo.

:run_program
echo [->] Starting XMP Profile Baker...
echo.

REM Check if main script exists
if not exist "%SCRIPT_DIR%xmp_profile_baker.py" (
    echo [X] Main script not found: %SCRIPT_DIR%xmp_profile_baker.py
    goto :error_exit
)

REM Run the Python program
"%PYTHON_EXE%" "%SCRIPT_DIR%xmp_profile_baker.py"

REM Check if the program ran successfully
if errorlevel 1 (
    echo.
    echo [X] Program encountered an error (exit code: %errorlevel%)
    echo.
    echo For error details, run:
    echo "%PYTHON_EXE%" "%SCRIPT_DIR%xmp_profile_baker.py"
    echo.
    pause
    goto :error_exit
)

echo.
echo [V] Program completed successfully!
goto :normal_exit

:error_exit
echo.
echo ===============================================
echo  Setup or execution failed!
echo ===============================================
echo.
echo Troubleshooting:
echo - Ensure internet connection for setup
echo - Check Windows Defender isn't blocking downloads
echo - Try running as administrator
echo - Manual run: "%PYTHON_EXE%" "%SCRIPT_DIR%xmp_profile_baker.py"
echo.
echo Press any key to exit...
pause >nul
exit /b 1

:normal_exit
echo.
echo Press any key to exit...
pause >nul
exit /b 0