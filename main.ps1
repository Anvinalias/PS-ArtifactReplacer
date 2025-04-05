# Load config
$config = Get-Content -Raw -Path "./config.json" | ConvertFrom-Json

$config.BuildPath
$config.LogPath

# Load helper script
. "scripts/unzip.ps1"

# Get all application folders under BuildPath
$appFolders = Get-ChildItem -Path $config.BuildPath -Directory

foreach ($app in $appFolders) {
    # Get version folders inside each app folder
    $versionFolders = Get-ChildItem -Path $app.FullName -Directory

    foreach ($version in $versionFolders) {
        # Prompt the user to continue or skip
        Write-Host "`nFound version folder: $($version.FullName)" -ForegroundColor Cyan
        $response = Read-Host "Do you want to process this folder? (Y/N)"

        if ($response -eq "Y" -or $response -eq "y") {
            # Call your unzip function here
            Expand-BuildFiles -VersionFolderPath $version.FullName
        } else {
            Write-Host "Skipping $($version.Name)`n" -ForegroundColor Yellow
        }
    }
}



