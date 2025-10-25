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
set "PYTHON_URL=https://www.python.org/ftp/python/%PYTHON_VERSION%/python-%PYTHON_VERSION%-embed-amd64.zip"
set "PYTHON_ZIP=%SCRIPT_DIR%python_temp.zip"

REM Check if portable Python exists
if exist "%PYTHON_EXE%" (
    echo [✓] Portable Python found - Starting program...
    goto :run_program
)

REM Check if system Python exists and is usable
echo [~] Checking for system Python installation...
python --version >nul 2>&1
if not errorlevel 1 (
    echo [✓] System Python found - Starting program...
    set "PYTHON_EXE=python"
    goto :run_program
)

echo [!] No Python installation found
echo [→] Setting up portable Python environment...
echo.

REM Create python directory
if not exist "%PYTHON_DIR%" mkdir "%PYTHON_DIR%"

REM Check if we have PowerShell (Windows 10+ method)
powershell -Command "Get-Host" >nul 2>&1
if not errorlevel 1 (
    echo [→] Downloading Python %PYTHON_VERSION% (Embedded, ~10MB)...
    echo     This is a one-time setup, please wait...
    
    powershell -Command "& { [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12; $ProgressPreference = 'SilentlyContinue'; try { Invoke-WebRequest -Uri '%PYTHON_URL%' -OutFile '%PYTHON_ZIP%' -UseBasicParsing; Write-Host '[✓] Download completed successfully' } catch { Write-Host '[✗] Download failed:' $_.Exception.Message; exit 1 } }"
    
    if errorlevel 1 (
        echo [✗] Download failed! Please check your internet connection.
        goto :error_exit
    )
    
    echo [→] Extracting Python...
    
    REM Try Windows 10+ built-in tar command first
    tar -xf "%PYTHON_ZIP%" -C "%PYTHON_DIR%" >nul 2>&1
    if not errorlevel 1 (
        echo [✓] Extraction completed using built-in tools
    ) else (
        REM Fallback to PowerShell extraction
        echo [→] Using PowerShell extraction method...
        powershell -Command "& { try { Expand-Archive -Path '%PYTHON_ZIP%' -DestinationPath '%PYTHON_DIR%' -Force; Write-Host '[✓] Extraction completed' } catch { Write-Host '[✗] Extraction failed:' $_.Exception.Message; exit 1 } }"
        if errorlevel 1 (
            echo [✗] Extraction failed!
            goto :error_exit
        )
    )
) else (
    echo [✗] PowerShell not available - Cannot download Python automatically
    echo.
    echo Please manually install Python from https://python.org
    echo Or use a Windows 10+ system for automatic setup
    goto :error_exit
)

REM Clean up download file
if exist "%PYTHON_ZIP%" del "%PYTHON_ZIP%"

REM Verify Python installation
if not exist "%PYTHON_EXE%" (
    echo [✗] Python setup failed - Executable not found
    goto :error_exit
)

echo [✓] Portable Python setup completed successfully!
echo.

:run_program
echo [→] Starting XMP Profile Baker...
echo.

REM Run the Python program
"%PYTHON_EXE%" "%SCRIPT_DIR%xmp_profile_baker.py"

REM Check if the program ran successfully
if errorlevel 1 (
    echo.
    echo [✗] Program encountered an error
    goto :error_exit
)

echo.
echo [✓] Program completed successfully!
goto :normal_exit

:error_exit
echo.
echo ===============================================
echo  Setup or execution failed!
echo ===============================================
echo.
echo Troubleshooting:
echo - Ensure you have internet connection for first-time setup
echo - Check that Windows Defender isn't blocking downloads
echo - Try running as administrator if permission issues occur
echo - For manual setup: Install Python from https://python.org
echo.
echo Press any key to exit...
pause >nul
exit /b 1

:normal_exit
echo.
echo Press any key to exit...
pause >nul
exit /b 0