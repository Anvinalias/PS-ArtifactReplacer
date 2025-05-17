function Write-Log {
    param (
        [Parameter(Mandatory = $true)]
        [string]$Message,

        [Parameter(Mandatory = $true)]
        [string]$LogFile,

        [ValidateSet("INFO", "WARN", "ERROR")]
        [string]$Level = "INFO"
    )

    $timestamp = Get-Date -Format "dd-MM-yyyy HH:mm"
    $logConsoleEntry = "[$Level] - $Message"
    $logFileEntry = "$timestamp [$Level] - $Message"

    switch ($Level) {
        "INFO"  { Write-Host $logConsoleEntry -ForegroundColor White }
        "WARN"  { Write-Host $logConsoleEntry -ForegroundColor Yellow }
        "ERROR" { Write-Host $logConsoleEntry -ForegroundColor Red }
    }

    Add-Content -Path $LogFile -Value $logFileEntry
}


function Write-LogBanner {
    param (
        [Parameter(Mandatory = $true)]
        [string]$Title,

        [Parameter(Mandatory = $true)]
        [string]$LogFile
    )

    $banner = "==== $Title ===="

    # Console + Log File
    Write-Host "`n$banner" -ForegroundColor Cyan
    Add-Content -Path $LogFile -Value "`n$banner"
}
