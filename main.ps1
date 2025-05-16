# Load config
$config = Get-Content -Raw -Path "./config.json" | ConvertFrom-Json

# Create logs directory if it doesn't exist
if (-not (Test-Path $config.LogPath)) {
    New-Item -ItemType Directory -Path $config.LogPath | Out-Null
}

# Define log file as "out.HHmmss.log"
$timestamp = Get-Date -Format "HHmmss"
$logFile = Join-Path $config.LogPath "out.$timestamp.log"

# Load helper script
. "$PSScriptRoot/scripts/logging.ps1"
. "$PSScriptRoot/scripts/unzip-build-files.ps1"
. "$PSScriptRoot/scripts/cleanup-artifact-files.ps1"
. "$PSScriptRoot/scripts/clone-artifact-version-folder.ps1"
. "$PSScriptRoot/scripts/copy-build-to-artifact.ps1"

# Remove-UnwantedFiles -ArtifactPath $config.ArtifactPath -LogFile $logFile

# Remove-OldHashFiles -BuildPath $config.BuildPath -ArtifactPath $config.ArtifactPath -LogFile $logFile

# Invoke-BuildFileExpansion -BuildPath $config.BuildPath -SevenZipPath $config.SevenZipPath

# Invoke-ArtifactVersionClone -ArtifactPath $config.ArtifactPath -BuildPath $config.BuildPath -SourceVersion $config.SourceVersion -TargetVersion $config.TargetVersion

Copy-APIApplicationFiles -ArtifactPath $config.ArtifactPath -BuildPath $config.BuildPath -TargetVersion $config.TargetVersion

Copy-DatabaseFiles -ArtifactPath $config.ArtifactPath -BuildPath $config.BuildPath -TargetVersion $config.TargetVersion

Copy-ApplicationPageFiles -ArtifactPath $config.ArtifactPath -BuildPath $config.BuildPath -TargetVersion $config.TargetVersion