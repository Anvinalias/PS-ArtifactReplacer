# Function to remove unwanted files from the artifact path
function Remove-UnwantedFiles {
    param (
        [Parameter(Mandatory = $true)]
        [string]$ArtifactPath
    )

    $filesToDelete = @("allAppList.txt", "allfilesdetails.txt", "uploadedversion.txt")

    foreach ($file in $filesToDelete) {
        $filePath = Join-Path $ArtifactPath $file
        if (Test-Path $filePath) {
            try {
                Remove-Item $filePath -Force
                Write-Host "Deleted $file" -ForegroundColor Green
            }
            catch {
                Write-Host "Failed to delete $file : $_" -ForegroundColor Red
            }
        }
    }
}

# Function to remove old hash files if they exist
function Remove-OldHashFiles {
    param (
        [Parameter(Mandatory = $true)]
        [string]$BuildPath,

        [Parameter(Mandatory = $true)]
        [string]$ArtifactPath
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
                Write-Host "Deleted hash file: $hashFilePath" -ForegroundColor Green
            }
            catch {
                Write-Host "Failed to delete $hashFilePath : $_" -ForegroundColor Red
            }
        }
    }
}