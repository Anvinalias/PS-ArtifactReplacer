function Expand-BuildFiles {
    param (
        [Parameter(Mandatory = $true)]
        [string]$VersionFolderPath,

        [Parameter(Mandatory = $false)]
        [string]$SevenZipPath
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

            # Unzip into destination folder using 7-Zip if available
            if ($SevenZipPath) {
                & $SevenZipPath 'x' $zip.FullName "-o$destinationFolder" '-y' | Out-Null
                Write-Host "Unzipped $($zip.Name) using 7-Zip to $destinationFolder"
            }
            # Fallback to Expand-Archive if 7-Zip is not available
            else {
                Expand-Archive -Path $zip.FullName -DestinationPath $destinationFolder -Force
                Write-Host "Unzipped $($zip.Name) using Expand-Archive to $destinationFolder"
            }

        }
        catch {
            Write-Host "Failed to unzip $($zip.Name): $_" -ForegroundColor Yellow
        }
    
    }

}  

function Invoke-BuildFileExpansion {
    param (
        [Parameter(Mandatory = $true)]
        [string]$BuildPath,

        [Parameter(Mandatory = $false)]
        [string]$SevenZipPath
    )
    
    # Get all application folders under BuildPath
    $appFolders = Get-ChildItem -Path $BuildPath -Directory

    foreach ($app in $appFolders) {
        # Get version folders inside each app folder
        $versionFolders = Get-ChildItem -Path $app.FullName -Directory

        foreach ($version in $versionFolders) {
            # Call Expand-BuildFiles function for each version folder
            Expand-BuildFiles -VersionFolderPath $version.FullName -SevenZipPath $SevenZipPath
        }
    }

}


