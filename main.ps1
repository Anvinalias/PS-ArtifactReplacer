# Load config
$config = Get-Content -Raw -Path "./config.json" | ConvertFrom-Json

$config.BuildPath
$config.LogPath

# Load helper script
. "$PSScriptRoot/scripts/unzip.ps1"
. "$PSScriptRoot/scripts/cleanup.ps1"


Remove-UnwantedFiles -ArtifactPath $config.ArtifactPath

# Invoke-UnzipFlow -BuildPath $config.BuildPath
