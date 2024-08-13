$logFile = "recenter_mouse.log"

function Log-Message {
    param (
        [string]$message
    )
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    Add-Content -Path $logFile -Value "$timestamp - $message"
}

# Start logging
Log-Message "Starting recenter_mouse.ps1"

# Ensure conda environment exists and is activated
$envName = "recenter_mouse"
$pythonScript = "recenter_mouse.py"

# Check if conda environment exists
$condaEnvList = conda env list | Out-String
if ($condaEnvList -notmatch $envName) {
    Log-Message "Creating conda environment '$envName'..."
    conda create -n $envName python=3.11 -y | Out-String | Add-Content -Path $logFile
}

# Activate the conda environment
Log-Message "Activating conda environment '$envName'..."
& conda activate $envName | Out-String | Add-Content -Path $logFile

# Install necessary packages
$packages = @("pyautogui", "pynput", "pygetwindow", "pywin32")
foreach ($package in $packages) {
    $packageInfo = & conda run -n $envName pip show $package 2>&1
    $exitCode = $LASTEXITCODE
    if ($exitCode -ne 0) {
        Log-Message "Installing $package..."
        & conda run -n $envName pip install $package | Out-String | Add-Content -Path $logFile
    } else {
        Log-Message "$package is already installed."
    }
}

# Run the Python script and wait for it to complete
Log-Message "Running Python script '$pythonScript'..."
Start-Process -FilePath "conda" -ArgumentList "run -n $envName python $pythonScript" -NoNewWindow

# Print message to log file
Log-Message "Recenter Mouse Active"

# End logging
Log-Message "Finished recenter_mouse.ps1"