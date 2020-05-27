param
(
    [string]$ipAddress,
    [string]$start,
    [string]$end,
    [string]$mask,
    [int]$cidr
)

. .\Functions\getCertificateData.ps1
. .\Functions\get-IPRange.ps1

$ipAddresses = @()

if ($ipAddress -and !($mask) -and !($cidr)) {
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

if ((Test-Path $resultsPath)) {
    remove-item $resultsPath
    new-item -type file $resultsPath
}
else {
    new-item -type file $resultsPath
}

foreach ($ip in $ipAddresses) {
    "working on $ip"
    $results = get-CertificateData -Ip $ip -ErrorAction SilentlyContinue
	
    if ($null -ne $results){
        Write-Host $results
        $results | export-csv $resultsPath -Append
    }
}