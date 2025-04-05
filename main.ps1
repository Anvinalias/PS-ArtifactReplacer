# Load config
$config = Get-Content -Raw -Path "./config.json" | ConvertFrom-Json

$config.BuildPath
$config.LogPath

# Load helper script
. "scripts/unzip.ps1"

Invoke-UnzipFlow -BuildPath $config.BuildPath