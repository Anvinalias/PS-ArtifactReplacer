function Write-Log {
    param (
        [Parameter(Mandatory = $true)]
        [string]$Message,

        [Parameter(Mandatory = $true)]
        [string]$LogFile
    )
    $timestamp = Get-Date -Format "dd-MM-yyyy HH:mm"
    Add-Content -Path $LogFile -Value "$timestamp - $Message"
}