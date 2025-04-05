# Load config
$config = Get-Content -Raw -Path "./config.json" | ConvertFrom-Json

$config.BuildPath
$config.LogPath

# Load helper script
. "scripts/unzip.ps1"

# # Example path to pass
# $versionFolder = "C:\Users\anvin\Desktop\Practice\Experiment\Compute_hash\Buildfiles\CrewingPALApp\4.0.0.3"

# Define the app name and version dynamically
$appName = "CrewingPALApp"
$version = "4.0.0.3"

# Combine parts to get full version folder path
$versionFolder = Join-Path $config.BuildPath "$appName\$version"

# Output to check
Write-Host "Version folder path: $versionFolder"

# Call the Unzip function
Unzip -VersionFolderPath $versionFolder


