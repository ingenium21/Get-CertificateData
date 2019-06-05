. .\Functions\getCertificateData.ps1
. .\Functions\get-IPRange.ps1

param (
    [Parameter(Mandatory=$true)][string]$ipAddress,
    [string]$start,
    [string]$end,
    [string]$mask,
    [int]$cidr
)

$ipAddresses = @()

if ($ipAddress) {
    $ipAddresses = $ipAddress
}

elseif ($start -and $end) {
    $ipAddresses = get-IPRange -start $start -end $end
}

elseif ($ipAddress -and $mask) {
    $ipAddresses = get-IPRange -ip $ipAddress -mask $mask
}

elseif ($ipAddress -and $cidr) {
    $ipAddresses = get-IPRange -ip $ipAddress -cidr $cidr
}

else {
    Write-host -ForegroundColor Red "No valid IP information was input"
}

$resultsPath = ".\results.csv"

if (!(Test-Path $resultsPath)) {
    new-item -type file .\results.csv
}

foreach ($ip in $ipAddresses) {
    $results = get-CertificateData -Ip $ip -ErrorAction SilentlyContinue
     
    if ($null -ne $results){
        $results | export-csv .\results.csv -Append
    }
}