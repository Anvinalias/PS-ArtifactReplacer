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
    }
    
}