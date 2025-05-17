function Test-VersionMatch {
    param (
        [string]$FolderPath
    )

    $versionFile = Join-Path $FolderPath "applicationPages\version.txt"
    if (-not (Test-Path $versionFile)) {
        return $false
    }

    # Read the version from the file and compare it with the folder name
    # Assuming the folder name is the version number
    $actualVersion = Split-Path $FolderPath -Leaf
    $versionContent = (Get-Content $versionFile -Raw).Trim()
            
    return $versionContent -eq $actualVersion
}

function Copy-VersionFolder {
    param (
        [string]$SourceFolder,
        [string]$NewVersion
    )

    $targetFolderPath = Join-Path (Split-Path $SourceFolder -Parent) $NewVersion

    if (-not (Test-Path $targetFolderPath)) {
        New-Item -Path $targetFolderPath -ItemType Directory | Out-Null
    }
    #clone the folder 1.0.0.0 to new version folder 4.0.0.0
    robocopy $SourceFolder $targetFolderPath /E /COPY:DAT /R:2 /W:1 | Out-Null

    return $targetFolderPath
}


function Update-VersionTxt {
    param (
        [string]$FolderPath,
        [string]$NewVersion
    )
    $versionFile = Join-Path $FolderPath "applicationPages\version.txt"
    # Log short path for better readability
    $shortPath = (Split-Path $FolderPath -Parent | Split-Path -Leaf) + "\" + (Split-Path $FolderPath -Leaf)
    Write-Log "Updating version.txt content of $shortPath to $NewVersion" $LogFile -Level "INFO"
    #Modify version.txt to new version
    Set-Content -Path $versionFile -Value $NewVersion
}

Function Invoke-ArtifactVersionClone {
    param (
        [Parameter(Mandatory)]
        [string]$ArtifactPath,

        [Parameter(Mandatory)]
        [string]$BuildPath,

        [Parameter(Mandatory)]
        [string]$SourceVersion,

        [Parameter(Mandatory)]
        [string]$TargetVersion
    )

    # Get all app folders in the ArtifactPath
    $artifactAppFolders = Get-ChildItem -Path $ArtifactPath -Directory
    $buildAppFolders = Get-ChildItem -Path $BuildPath -Directory
    $buildAppNames = $buildAppFolders.Name

    foreach ($artifactApp in $artifactAppFolders) {
        $appName = $artifactApp.Name
        $sourceFolder = Join-Path $artifactApp.FullName $SourceVersion

        # Skip if source version folder doesn't exist
        if (-not (Test-Path $sourceFolder)) {
            Write-Log "Skipping $appName : Source version folder not found" $LogFile -Level "WARN"
            continue
        }

        # Allow only if app exists in build or is API-Application
        if ($appName -ne "API-Application" -and -not ($buildAppNames -contains $appName)) {
            Write-Log "Skipping $appName : not found in BuildPath" $LogFile -Level "WARN"
            continue
        }

        # Ensure version.txt matches
        if (-not (Test-VersionMatch -FolderPath $sourceFolder)) {
            $actualVersion = Split-Path $sourceFolder -Leaf
            Update-VersionTxt -FolderPath $sourceFolder -NewVersion $actualVersion
        }

        # Clone and update version.txt
        $targetVersionFolder = Copy-VersionFolder -SourceFolder $sourceFolder -NewVersion $TargetVersion
        # Extract short folder names (last two folder) for source and target
        $shortSource = (Split-Path $sourceFolder -Parent | Split-Path -Leaf) + "\" + (Split-Path $sourceFolder -Leaf)
        $shortTarget = (Split-Path $targetVersionFolder -Parent | Split-Path -Leaf) + "\" + (Split-Path $targetVersionFolder -Leaf)
        Write-Log "Cloned $shortSource to $shortTarget" $LogFile -Level "INFO"
        Update-VersionTxt -FolderPath $targetVersionFolder -NewVersion $TargetVersion
    }   
}