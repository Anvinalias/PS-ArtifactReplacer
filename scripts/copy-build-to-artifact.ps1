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
