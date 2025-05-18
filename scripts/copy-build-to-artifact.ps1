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
                # Log the short path for better readability
                # Extract last 4 folders from source
                $shortSource = ($apiAppPath -split '\\')[-4..-1] -join '\'
                # Extract last 4 folders from target
                $shortTarget = ($targetPath -split '\\')[-4..-1] -join '\'

                Write-Log "Copying API Files from $shortSource to $shortTarget" $LogFile -Level "INFO"
                robocopy $apiAppPath $targetPath /E /IS /IT /NFL /NDL /NJH /NJS /NP | Out-Null
            }
            else {
                Write-Log "No API-Application folder found in version $($versionFolder.Name) for $($appFolder.Name)" $LogFile -Level "WARN"
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

        #Home database files are handled differently
        if ($appName -eq "Home") {
            Copy-HomeDatabaseFiles -ArtifactPath $config.ArtifactPath -BuildPath $config.BuildPath -TargetVersion $config.TargetVersion
            continue
        }

        $versionFolders = Get-ChildItem -Path $appFolder.FullName -Directory

        foreach ($versionFolder in $versionFolders) {
            $dbParentPath = Join-Path -Path $versionFolder.FullName -ChildPath "Database"

            if (Test-Path $dbParentPath) {
                
                #calls to another function for verifying database file path
                $dbAppFolder = Get-DatabaseSourceFolder -DatabasePath $dbParentPath -AppName $appName

                if ($dbAppFolder) {
                    $sourcePath = $dbAppFolder.FullName
                    $destinationPath = Join-Path -Path $ArtifactPath -ChildPath "$appName\$TargetVersion\scripts"
                    # Log the short path for better readability
                    # Extract last 4 folders from source
                    $shortSource = ($sourcePath -split '\\')[-4..-1] -join '\'
                    # Extract last 4 folders from target
                    $shortTarget = ($destinationPath -split '\\')[-4..-1] -join '\'

                    Write-Log "Copying DB Files from $shortSource to $shortTarget" $LogFile -Level "INFO"
                    robocopy $sourcePath $destinationPath /E /IS /IT /NFL /NDL /NJH /NJS /NP | Out-Null
                }
            }
            else {
                Write-Log "No matching DB files found for '$appName' in $dbParentPath" $LogFile -Level "WARN"
            }
        }
    }
}

function Get-DatabaseSourceFolder {
    param (
        [string]$DatabasePath,
        [string]$AppName
    )

    if (-not (Test-Path $DatabasePath)) {
        return $null
    }

    # Find folder under Database that matches the app name (partially or fully)
    $match = Get-ChildItem -Path $DatabasePath -Directory |
    Where-Object { $_.Name -like "*$AppName*" -or $AppName -like "*$($_.Name)*" } |
    Select-Object -First 1

    # Check for DB folders directly under Database
    if (-not $match) {
        $containsValidFolders = Get-ChildItem -Path $DatabasePath -Directory |
        Where-Object { $_.Name -match 'Scripts|Functions|StoredProcedures' }

        if ($containsValidFolders) {
            return Get-Item $DatabasePath
        }
    }

    return $match
}


function Copy-HomeDatabaseFiles {
    param (
        [Parameter(Mandatory)]
        [string]$ArtifactPath,

        [Parameter(Mandatory)]
        [string]$BuildPath,

        [Parameter(Mandatory)]
        [string]$TargetVersion
    )

    $HomeBuildPath = Join-Path -Path $BuildPath -ChildPath "Home"
    $versionFolders = Get-ChildItem -Path $HomeBuildPath -Directory

    foreach ($versionFolder in $versionFolders) {
        $apiDbPath = Join-Path -Path $versionFolder.FullName -ChildPath "Database\API-Application"

        if (Test-Path $apiDbPath) {
            $destinationPath = Join-Path -Path $ArtifactPath -ChildPath "API-Application\$TargetVersion\scripts"
            
            # Log the short path for better readability
            # Extract last 4 folders from source
            $shortSource = ($apiDbPath -split '\\')[-4..-1] -join '\'
            # Extract last 4 folders from target
            $shortTarget = ($destinationPath -split '\\')[-4..-1] -join '\'

            Write-Log "Copying API DB Files from $shortSource to $shortTarget" $LogFile -Level "INFO"
            robocopy $apiDbPath $destinationPath /E /IS /IT /NFL /NDL /NJH /NJS /NP | Out-Null
        }
        else {
            Write-Log "No 'API-Application' folder found in $($versionFolder.FullName)" $LogFile -Level "WARN"
        }
    }
}


function Copy-ApplicationPageFiles {
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
            $applicationBuildPath = Join-Path -Path $versionFolder.FullName -ChildPath $appName

            if (Test-Path $applicationBuildPath) {

                $targetApplicationPath = Join-Path -Path $ArtifactPath -ChildPath "$appName\$TargetVersion\applicationPages"
                # Log the short path for better readability
                # Extract last 4 folders from source
                $shortSource = ($applicationBuildPath -split '\\')[-4..-1] -join '\'
                # Extract last 4 folders from target
                $shortTarget = ($targetApplicationPath -split '\\')[-4..-1] -join '\'

                Write-Log "Copying Application Files from $shortSource to $shortTarget" $LogFile -Level "INFO"

                robocopy $applicationBuildPath $targetApplicationPath /E /IS /IT /NFL /NDL /NJH /NJS /NP | Out-Null
            }
            else {
                Write-Log "No Application folder found in version $($versionFolder.Name) for $($appFolder.Name)" $LogFile -Level "WARN"
            }
        }
    }
}


