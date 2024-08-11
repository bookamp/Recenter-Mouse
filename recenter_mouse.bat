@echo off
setlocal

REM Define the log file
set logFile=%~dp0recenter_mouse.log

REM Check if the Python script is already running
echo Checking for running instances of recenter_mouse.py...
set scriptRunning=0

for /f "tokens=2 delims=," %%i in ('tasklist /FI "IMAGENAME eq python.exe" /FO CSV /NH') do (
    echo Checking process ID: %%i
    for /f "tokens=*" %%j in ('wmic process where "processid=%%i" get commandline /value 2^>nul') do (
        echo Command line: %%j
        echo %%j | findstr /i "recenter_mouse.py" >nul
        if not errorlevel 1 (
            echo Found process ID: %%i with command line: %%j
            set scriptRunning=1
            goto endLoop
        )
    )
)

:endLoop

echo scriptRunning=%scriptRunning%

if %scriptRunning% equ 1 (
    echo recenter_mouse.py is already running. Exiting batch file.
    goto end
)

echo recenter_mouse.py is not running. Continuing with the script...

REM Clear the contents of the log file at the beginning of each run
if exist "%logFile%" (
    echo Clearing log file...
    echo. > "%logFile%"
) else (
    echo Log file does not exist, creating log file...
    echo. > "%logFile%"
)

REM Run the PowerShell script in a hidden window
echo Starting PowerShell script...
powershell -Command "Start-Process powershell -ArgumentList '-NoProfile -ExecutionPolicy Bypass -File ""%~dp0recenter_mouse.ps1""' -WindowStyle Hidden"

REM Wait for the listener setup in the Python script
echo Waiting for Python script to set up the listener...
:waitForListener
timeout /t 1 /nobreak >nul
if exist "%logFile%" (
    echo Log file found, checking for listener setup...
    type "%logFile%"
    REM Debugging: Display the content of the log file
    findstr /C:"Keyboard listener is now running" "%logFile%" >nul && (
        echo Found the listener setup in recenter_mouse.py
        echo Exiting batch file.
        goto end
    ) || (
        echo Listener setup not found, still waiting...
        timeout /t 1 /nobreak >nul
        goto waitForListener
    )
) else (
    echo Log file not found, still waiting...
    timeout /t 1 /nobreak >nul
    goto waitForListener
)


:end
endlocal
