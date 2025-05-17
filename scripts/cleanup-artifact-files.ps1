# Function to remove unwanted files from the artifact path
function Remove-UnwantedFiles {
    param (
        [Parameter(Mandatory = $true)]
        [string]$ArtifactPath,

        [Parameter(Mandatory = $true)]
        [string]$LogFile
    )

    $filesToDelete = @("allAppList.txt", "allfilesdetails.txt", "uploadedversion.txt")

    foreach ($file in $filesToDelete) {
        $filePath = Join-Path $ArtifactPath $file
        if (Test-Path $filePath) {
            try {
                Remove-Item $filePath -Force
                Write-Log "Deleted $file" $LogFile -Level "INFO"
            }
            catch {
                Write-Log "Failed to delete $file : $_" $LogFile -Level "ERROR"
            }
        }
        else {
            Write-Log "$file not found" $LogFile -Level "WARN"
        }
    }
}

# Function to remove old hash files if they exist
function Remove-OldHashFiles {
    param (
        [Parameter(Mandatory = $true)]
        [string]$BuildPath,

        [Parameter(Mandatory = $true)]
        [string]$ArtifactPath,

        [Parameter(Mandatory = $true)]
        [string]$LogFile
    )

    $appFolders = Get-ChildItem -Path $BuildPath -Directory

    # Collect app names from BuildFiles
    $appNames = $appFolders.Name

    # Add API-Application to the list
    $appNames += 'API-Application'

    foreach ($appName in $appNames) {
        $hashFilePath = Join-Path -Path $ArtifactPath -ChildPath "$appName\1.0.0.0\hash-file.txt"

        if (Test-Path $hashFilePath) {
            try {
                Remove-Item $hashFilePath -Force
                Write-Log "Deleted hash file from $appName" $LogFile -Level "INFO"
            }
            catch {
                Write-Log "Failed to delete from $appName : $_" $LogFile -Level "ERROR"
            }
        }
        else {
            Write-Log "Hash file not found in $appName" $LogFile -Level "WARN"
        }
    }
}