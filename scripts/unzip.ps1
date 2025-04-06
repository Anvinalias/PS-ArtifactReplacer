function Expand-BuildFiles {
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

function Invoke-UnzipFlow {
    param (
        [Parameter(Mandatory = $true)]
        [string]$BuildPath
    )
    
    # Get all application folders under BuildPath
    $appFolders = Get-ChildItem -Path $BuildPath -Directory

    foreach ($app in $appFolders) {
        # Get version folders inside each app folder
        $versionFolders = Get-ChildItem -Path $app.FullName -Directory

        foreach ($version in $versionFolders) {
            # Prompt the user to continue or skip
            Write-Host "`nFound version folder: $($version.FullName)" -ForegroundColor Cyan
            $response = Read-Host "Do you want to process this folder? (Y/N)"

            if ($response -in @("Y", "y")) {
                # Call your unzip function here
                Expand-BuildFiles -VersionFolderPath $version.FullName
            }
            else {
                Write-Host "Skipping $($version.Name)`n" -ForegroundColor Yellow
            }
        }
    }

}


