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

function Clone-VersionFolder {
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
    Write-Host "Updating version.txt in $FolderPath to $NewVersion" -ForegroundColor Green
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
        Write-Host "Skipping $appName : Source version folder not found" -ForegroundColor Yellow
        continue
    }

    # Allow only if app exists in build or is API-Application
    if ($appName -ne "API-Application" -and -not ($buildAppNames -contains $appName)) {
        Write-Host "Skipping $appName : not found in BuildPath" -ForegroundColor Yellow
        continue
    }

    # Ensure version.txt matches
    if (-not (Test-VersionMatch -FolderPath $sourceFolder)) {
        Write-Host "Skipping $appName : version.txt mismatch" -ForegroundColor Red
        continue
    }

    # Clone and update version.txt
    $targetVersionFolder = Clone-VersionFolder -SourceFolder $sourceFolder -NewVersion $TargetVersion
    Write-Host "Cloned $sourceFolder to $targetVersionFolder" -ForegroundColor Green
    Update-VersionTxt -FolderPath $targetVersionFolder -NewVersion $TargetVersion
}

    
}