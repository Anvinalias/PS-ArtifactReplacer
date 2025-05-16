# Load config
$config = Get-Content -Raw -Path "./config.json" | ConvertFrom-Json

# Ensure logs directory exists
$logDir = Split-Path -Path $config.LogFile
if (-not (Test-Path $logDir)) {
    New-Item -ItemType Directory -Path $logDir | Out-Null
}

# Load helper script
. "$PSScriptRoot/scripts/logging.ps1"
. "$PSScriptRoot/scripts/unzip-build-files.ps1"
. "$PSScriptRoot/scripts/cleanup-artifact-files.ps1"
. "$PSScriptRoot/scripts/clone-artifact-version-folder.ps1"
. "$PSScriptRoot/scripts/copy-build-to-artifact.ps1"

Remove-UnwantedFiles -ArtifactPath $config.ArtifactPath

Remove-OldHashFiles -BuildPath $config.BuildPath -ArtifactPath $config.ArtifactPath

Invoke-BuildFileExpansion -BuildPath $config.BuildPath -SevenZipPath $config.SevenZipPath

Invoke-ArtifactVersionClone -ArtifactPath $config.ArtifactPath -BuildPath $config.BuildPath -SourceVersion $config.SourceVersion -TargetVersion $config.TargetVersion

Copy-APIApplicationFiles -ArtifactPath $config.ArtifactPath -BuildPath $config.BuildPath -TargetVersion $config.TargetVersion

Copy-DatabaseFiles -ArtifactPath $config.ArtifactPath -BuildPath $config.BuildPath -TargetVersion $config.TargetVersion

Copy-ApplicationPageFiles -ArtifactPath $config.ArtifactPath -BuildPath $config.BuildPath -TargetVersion $config.TargetVersion