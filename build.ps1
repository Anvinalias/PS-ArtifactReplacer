# build.ps1 - Script to build artifact-manager.exe from launcher.ps1

Write-Host "`nBuilding artifact-manager.exe..." -ForegroundColor Cyan

# Check for ps2exe module
if (-not (Get-Command Invoke-ps2exe -ErrorAction SilentlyContinue)) {
    Write-Host "ps2exe not found. Installing..." -ForegroundColor Yellow
    Install-Module -Name ps2exe -Scope CurrentUser -Force
}

# Compile the launcher into an EXE
Invoke-ps2exe .\launcher.ps1 .\artifact-manager.exe -noConsole

Write-Host "Build complete." -ForegroundColor Green
