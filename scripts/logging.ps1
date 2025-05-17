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
    $logEntry = "$timestamp [$Level] - $Message"

    switch ($Level) {
        "INFO"  { Write-Host $logEntry -ForegroundColor White }
        "WARN"  { Write-Host $logEntry -ForegroundColor Yellow }
        "ERROR" { Write-Host $logEntry -ForegroundColor Red }
    }

    Write-Host $logEntry
    Add-Content -Path $LogFile -Value $logEntry
}
