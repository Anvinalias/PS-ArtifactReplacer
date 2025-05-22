# Stop script execution when an error is raised
$ErrorActionPreference = "Stop"

try {
# Load config
$config = Get-Content -Raw -Path (Join-Path $PSScriptRoot 'config.json') | ConvertFrom-Json

# Load helper script
. "$PSScriptRoot/scripts/logging.ps1"
. "$PSScriptRoot/scripts/unzip-build-files.ps1"
. "$PSScriptRoot/scripts/delete-artifact-hashfiles.ps1"
. "$PSScriptRoot/scripts/clone-artifact-version-folder.ps1"
. "$PSScriptRoot/scripts/copy-build-to-artifact.ps1"

# ===== Configuration validation =====
function Test-ConfigurationPaths {
    param ($Config)
    
    $requiredPaths = @(
        @{Path = $Config.BuildPath; Name = "BuildPath" },
        @{Path = $Config.ArtifactPath; Name = "ArtifactPath" },
        @{Path = $Config.LogPath; Name = "LogPath" }
    )

    foreach ($item in $requiredPaths) {
        if ([string]::IsNullOrEmpty($item.Path)) {
            throw "Configuration Error: $($item.Name) cannot be empty"
        }
    }
}

# Create logs directory if it doesn't exist
if (-not (Test-Path $config.LogPath)) {
    New-Item -ItemType Directory -Path $config.LogPath | Out-Null
}

# Define log file as "out.HHmmss.log"
$timestamp = Get-Date -Format "HHmmss"
$logFile = Join-Path $config.LogPath "out.$timestamp.log"

# ===== Main flow =====

Test-ConfigurationPaths $config

Write-LogBanner -Title "REMOVING OLD HASH FILES" -LogFile $LogFile
Remove-OldHashFiles -BuildPath $config.BuildPath -ArtifactPath $config.ArtifactPath -LogFile $LogFile

Write-LogBanner -Title "UNZIPPING BUILD FILES" -LogFile $LogFile
Invoke-BuildFileExpansion -BuildPath $config.BuildPath -SevenZipPath $config.SevenZipPath

Write-LogBanner -Title "CLONING ARTIFACT VERSION FOLDERS" -LogFile $LogFile
Invoke-ArtifactVersionClone -ArtifactPath $config.ArtifactPath -BuildPath $config.BuildPath -SourceVersion $config.SourceVersion -TargetVersion $config.TargetVersion

Write-LogBanner -Title "COPYING API APPLICATION FILES" -LogFile $LogFile
Copy-APIApplicationFiles -ArtifactPath $config.ArtifactPath -BuildPath $config.BuildPath -TargetVersion $config.TargetVersion

Write-LogBanner -Title "COPYING DATABASE SCRIPT FILES" -LogFile $LogFile
Copy-DatabaseFiles -ArtifactPath $config.ArtifactPath -BuildPath $config.BuildPath -TargetVersion $config.TargetVersion

Write-LogBanner -Title "COPYING APPLICATION PAGE FILES" -LogFile $LogFile
Copy-ApplicationPageFiles -ArtifactPath $config.ArtifactPath -BuildPath $config.BuildPath -TargetVersion $config.TargetVersion
}
catch {
    # Extract error details
    $errorMessage = $_.Exception.Message
    $errorDetails = $_ | Out-String
    $scriptName = if ($_.InvocationInfo) { $_.InvocationInfo.ScriptName } else { "Unknown script" }
    $lineNumber = if ($_.InvocationInfo) { $_.InvocationInfo.ScriptLineNumber } else { "Unknown line" }

    # Ensure $logFile exists, fallback if needed
    if (-not $logFile) {
        $logFile = Join-Path $PSScriptRoot "error.$(Get-Date -Format 'HHmmss').log"
    }

    # Log error information
    Write-Log -Message "Script failed: $errorMessage" -LogFile $logFile -Level "ERROR"
    Write-Log -Message "Location: $scriptName at line $lineNumber" -LogFile $logFile -Level "ERROR"
    Write-Log -Message "Full error details:`n$errorDetails" -LogFile $logFile -Level "ERROR"

    # Exit with error code
    exit 1
}