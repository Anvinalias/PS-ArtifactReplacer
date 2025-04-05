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