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
set "TKINTER_URL=https://www.python.org/ftp/python/%PYTHON_VERSION%/python-%PYTHON_VERSION%-amd64.exe"
set "TKINTER_TEMP=%SCRIPT_DIR%python_full_temp.exe"
set "TKINTER_EXTRACT=%SCRIPT_DIR%tkinter_temp"

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

:install_python
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

echo [→] Adding GUI support (tkinter)...

REM Download tkinter components
powershell -Command "& { [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12; $ProgressPreference = 'SilentlyContinue'; try { Invoke-WebRequest -Uri '%TKINTER_URL%' -OutFile '%TKINTER_TEMP%' -UseBasicParsing; Write-Host '[✓] GUI components download completed' } catch { Write-Host '[!] GUI download failed - program may not work' } }"

REM Simple tkinter setup - extract what we need
if exist "%TKINTER_TEMP%" (
    echo [→] Setting up GUI support...
    if not exist "%TKINTER_EXTRACT%" mkdir "%TKINTER_EXTRACT%"
    
    REM Extract installer
    powershell -Command "Start-Process '%TKINTER_TEMP%' -ArgumentList '/quiet', '/layout', '%TKINTER_EXTRACT%' -Wait" >nul 2>&1
    
    REM Copy tkinter files (simple approach)
    for /r "%TKINTER_EXTRACT%" %%f in (core.msi) do (
        if exist "%%f" (
            msiexec /a "%%f" /qn TARGETDIR="%TKINTER_EXTRACT%\core" >nul 2>&1
            if exist "%TKINTER_EXTRACT%\core\Lib\tkinter" (
                if not exist "%PYTHON_DIR%\Lib" mkdir "%PYTHON_DIR%\Lib"
                xcopy "%TKINTER_EXTRACT%\core\Lib\tkinter" "%PYTHON_DIR%\Lib\tkinter\" /E /I /Q >nul 2>&1
            )
            if exist "%TKINTER_EXTRACT%\core\DLLs\_tkinter.pyd" (
                if not exist "%PYTHON_DIR%\DLLs" mkdir "%PYTHON_DIR%\DLLs"
                copy "%TKINTER_EXTRACT%\core\DLLs\_tkinter.pyd" "%PYTHON_DIR%\DLLs\" >nul 2>&1
            )
        )
    )
    
    REM Cleanup
    rmdir /s /q "%TKINTER_EXTRACT%" 2>nul
    del "%TKINTER_TEMP%" 2>nul
    
    echo [✓] GUI support added
)

echo [✓] Portable Python setup completed!
echo.



:install_python
echo [→] Setting up portable Python environment...

:run_program
echo [→] Starting XMP Profile Baker...
echo.

REM Run the Python program
"%PYTHON_EXE%" "%SCRIPT_DIR%xmp_profile_baker.py"

REM Check if the program ran successfully
if errorlevel 1 (
    echo.
    echo [✗] Program encountered an error
    echo.
    echo Try running this to see the error details:
    echo "%PYTHON_EXE%" "%SCRIPT_DIR%xmp_profile_baker.py"
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
echo - Ensure internet connection for first-time setup
echo - Check Windows Defender isn't blocking downloads
echo - Try running as administrator if needed
echo - Manual debug: "%PYTHON_EXE%" "%SCRIPT_DIR%xmp_profile_baker.py"
echo.
echo Press any key to exit...
pause >nul
exit /b 1

:normal_exit
echo.
echo Press any key to exit...
pause >nul
exit /b 0