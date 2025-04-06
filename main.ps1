# Load config
$config = Get-Content -Raw -Path "./config.json" | ConvertFrom-Json

# Load helper script
. "$PSScriptRoot/scripts/unzip-build-files.ps1"
. "$PSScriptRoot/scripts/cleanup-artifact-files.ps1"
. "$PSScriptRoot/scripts/clone-artifact-version-folder.ps1"
. "$PSScriptRoot/scripts/copy-build-to-artifact.ps1"

# Remove-UnwantedFiles -ArtifactPath $config.ArtifactPath

# Remove-OldHashFiles -BuildPath $config.BuildPath -ArtifactPath $config.ArtifactPath

Invoke-BuildFileExpansion -BuildPath $config.BuildPath -SevenZipPath $config.SevenZipPath

# Invoke-ArtifactVersionClone -ArtifactPath $config.ArtifactPath -BuildPath $config.BuildPath -SourceVersion $config.SourceVersion -TargetVersion $config.TargetVersion
