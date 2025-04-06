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
            } catch {
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

    foreach ($app in $appFolders) {
        $hashFilePath = Join-Path -Path $ArtifactPath -ChildPath "$($app.Name)\1.0.0.0\hash-file.txt"

        if (Test-Path $hashFilePath) {
            Write-Host "`nHash file found: $hashFilePath" -ForegroundColor Cyan
            $response = Read-Host "Do you want to delete this hash file? (Y/N)"
            if ($response -in @("Y", "y")) {
                try {
                    Remove-Item $hashFilePath -Force
                    Write-Host "Deleted hash file: $hashFilePath" -ForegroundColor Green
                } catch {
                    Write-Host "Failed to delete $hashFilePath : $_" -ForegroundColor Red
                }
            } else {
                Write-Host "Skipped deletion of $hashFilePath" -ForegroundColor Yellow
            }
        }
    }
}