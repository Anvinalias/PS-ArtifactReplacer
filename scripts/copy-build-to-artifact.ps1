function Copy-APIApplicationFiles {
    param (
        [Parameter(Mandatory)]
        [string]$ArtifactPath,

        [Parameter(Mandatory)]
        [string]$BuildPath,

        [Parameter(Mandatory)]
        [string]$TargetVersion
    )

    # Define the fixed version folder in the Artifact structure
    $targetPath = Join-Path -Path $ArtifactPath -ChildPath "API-Application\$TargetVersion\applicationPages"

    $appFolders = Get-ChildItem -Path $BuildPath -Directory

    foreach ($appFolder in $appFolders) {
        # Loop through version folders for each application
        $versionFolders = Get-ChildItem -Path $appFolder.FullName -Directory

        foreach ($versionFolder in $versionFolders) {
            $apiAppPath = Join-Path -Path $versionFolder.FullName -ChildPath "API-Application"

            # Check if API-Application folder exists in the version folder
            if (Test-Path $apiAppPath) {
                Write-Host "Copying from $apiAppPath to $targetPath"
                Copy-Item -Path $apiAppPath\* -Destination $targetPath -Recurse -Force
            } else {
                Write-Host "No API-Application folder found in version $($versionFolder.Name) for $($appFolder.Name)"
            }
        }
    }
}

function Copy-DatabaseFiles {
    param (
        [Parameter(Mandatory)]
        [string]$ArtifactPath,

        [Parameter(Mandatory)]
        [string]$BuildPath,

        [Parameter(Mandatory)]
        [string]$TargetVersion
    )

    $appFolders = Get-ChildItem -Path $BuildPath -Directory

    foreach ($appFolder in $appFolders) {
        $appName = $appFolder.Name
        $versionFolders = Get-ChildItem -Path $appFolder.FullName -Directory

        foreach ($versionFolder in $versionFolders) {
            $dbParentPath = Join-Path -Path $versionFolder.FullName -ChildPath "Database"

            if (Test-Path $dbParentPath) {
                # Find folder under Database that matches the app name (partially or fully)
                $dbAppFolder = Get-ChildItem -Path $dbParentPath -Directory |
                    Where-Object { $_.Name -like "*$appName*" -or $appName -like "*$($_.Name)*" } |
                    Select-Object -First 1

                if ($dbAppFolder) {
                    $sourcePath = $dbAppFolder.FullName
                    $destinationPath = Join-Path -Path $ArtifactPath -ChildPath "$appName\$TargetVersion\scripts"

                    Write-Host "Copying DB files from '$sourcePath' to '$destinationPath'" -ForegroundColor Cyan
                    robocopy $sourcePath $destinationPath /E /IS /IT /NFL /NDL /NJH /NJS /NP | Out-Null
                } else {
                    Write-Host "No matching DB subfolder found for '$appName' in $dbParentPath" -ForegroundColor Yellow
                }
            }
        }
    }
}

