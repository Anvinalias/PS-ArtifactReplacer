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

    # Get only app folders that exist in the BuildPath
    $buildAppFolders = Get-ChildItem -Path $BuildPath -Directory
 
    foreach ($buildApp in $buildAppFolders) {
        $appName = $buildApp.Name
        $artifactAppPath = Join-Path $ArtifactPath $appName

        if (-not (Test-Path $artifactAppPath)) {
            Write-Host "Skipping $appName : not found in ArtifactPath" -ForegroundColor Yellow
            continue
        }

        $sourceFolder = Join-Path $artifactAppPath $SourceVersion        
        if (-not (Test-Path $sourceFolder)) {
            Write-Host "Skipping $appName : Source version folder not found" -ForegroundColor Yellow
            continue
        }
        
        if (-not (Test-VersionMatch -FolderPath $sourceFolder)) {
            Write-Host "Skipping $appName : version.txt mismatch" -ForegroundColor Red
            continue
        }

        $targetVersionFolder = Clone-VersionFolder -SourceFolder $sourceFolder -NewVersion $TargetVersion
        Write-Host "Cloned $sourceFolder to $targetVersionFolder" -ForegroundColor Green
        #Update version.txt in the new version folder
        Update-VersionTxt -FolderPath $targetVersionFolder -NewVersion $TargetVersion
    }
    
}