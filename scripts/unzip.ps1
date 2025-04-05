function Unzip {
    param (
        [Parameter(Mandatory = $true)]
        [string]$VersionFolderPath
    )

    # Make sure the folder exists
    if (-not (Test-Path $VersionFolderPath)) {
        Write-Host "Folder does not exist: $VersionFolderPath" -ForegroundColor Red
        return
    }

    # Get all zip files in the folder
    $zipFiles = Get-ChildItem -Path $VersionFolderPath -Filter *.zip

    foreach ($zip in $zipFiles) {
        $destinationFolder = Join-Path $VersionFolderPath ($zip.BaseName)

        # Create folder if it doesn't exist
        if (-not (Test-Path $destinationFolder)) {
            New-Item -ItemType Directory -Path $destinationFolder | Out-Null
        }

        # Unzip into destination folder
        Expand-Archive -Path $zip.FullName -DestinationPath $destinationFolder -Force

        Write-Host "Unzipped $($zip.Name) to $destinationFolder"
    }
}
