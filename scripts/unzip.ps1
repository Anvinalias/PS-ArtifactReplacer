function Unzip {
    param (
        [Parameter(Mandatory = $true)]
        [string]$VersionFolderPath
    )
    try {
        # Try to get all zip files 
        $zipFiles = Get-ChildItem -Path $VersionFolderPath -Filter *.zip -ErrorAction Stop
    }
    catch {
        Write-Host "Error: Folder does not exist or couldn't read contents: $VersionFolderPath" -ForegroundColor Red
        return
    }

    foreach ($zip in $zipFiles) {
        $destinationFolder = Join-Path $VersionFolderPath ($zip.BaseName)

        try {
            
            if (-not (Test-Path $destinationFolder)) {
                New-Item -ItemType Directory -Path $destinationFolder -ErrorAction Stop | Out-Null
            }

            # Unzip into destination folder
            Expand-Archive -Path $zip.FullName -DestinationPath $destinationFolder -Force

            Write-Host "Unzipped $($zip.Name) to $destinationFolder"

        }
        catch {
            Write-Host "Failed to unzip $($zip.Name): $_" -ForegroundColor Yellow
        }
    
    }

}
