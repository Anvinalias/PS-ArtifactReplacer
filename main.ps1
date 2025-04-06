# Load config
$config = Get-Content -Raw -Path "./config.json" | ConvertFrom-Json

$config.BuildPath
$config.LogPath

# Load helper script
. "$PSScriptRoot/scripts/unzip-build-files.ps1"
. "$PSScriptRoot/scripts/cleanup-artifact-files.ps1"
. "$PSScriptRoot/scripts/clone-artifact-version-folder.ps1"


# Remove-UnwantedFiles -ArtifactPath $config.ArtifactPath

# Remove-OldHashFiles -BuildPath $config.BuildPath -ArtifactPath $config.ArtifactPath

Invoke-BuildFileExpansion -BuildPath $config.BuildPath
