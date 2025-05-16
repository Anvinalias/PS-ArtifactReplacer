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
        Write-Log "Error: Folder does not exist or couldn't read contents: $VersionFolderPath" $LogFile
        return
    }

    $use7Zip = $false
    if ($SevenZipPath -and (Test-Path $SevenZipPath) -and ($SevenZipPath -like '*.exe')) {
        $use7Zip = $true
    }
    elseif ($SevenZipPath) {
        Write-Host "Warning: 7-Zip executable not found at '$SevenZipPath'. Falling back to Expand-Archive." -ForegroundColor Yellow
        Write-Log "7-Zip path invalid: '$SevenZipPath'. Falling back to Expand-Archive." $LogFile
    }

    foreach ($zip in $zipFiles) {
        $destinationFolder = Join-Path $VersionFolderPath ($zip.BaseName)

        try {
            
            if (-not (Test-Path $destinationFolder)) {
                New-Item -ItemType Directory -Path $destinationFolder -ErrorAction Stop | Out-Null
            }

            # Unzip into destination folder using 7-Zip if available
            if ($use7Zip) {
                & $SevenZipPath 'x' $zip.FullName "-o$destinationFolder" '-y' | Out-Null

                # Extract last 3 folders from destination folder path
                $shortDest = ($destinationFolder -split '\\')[-3..-1] -join '\'
                Write-Log "Unzipped $shortDest\$($zip.Name) using 7-Zip" $LogFile
            }
            # Fallback to Expand-Archive if 7-Zip is not available
            else {
                Expand-Archive -Path $zip.FullName -DestinationPath $destinationFolder -Force

                # Extract last 3 folders from destination folder path
                $shortDest = ($destinationFolder -split '\\')[-3..-1] -join '\'
                Write-Log "Unzipped $shortDest\$($zip.Name) using Expand-Archive" $LogFile
            }

        }
        catch {
            Write-Log "Failed to unzip $($zip.Name): $_" $LogFile
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


