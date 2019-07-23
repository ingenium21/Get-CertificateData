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

if (!(Test-Path $resultsPath)) {
    new-item -type file .\results.csv
}

foreach ($ip in $ipAddresses) {
    "working on $ip"
    $results = get-CertificateData -Ip $ip -ErrorAction SilentlyContinue
    if ($results -ne $null){
        $SSLProtocols = Test-SslProtocols -ComputerName $ip -ErrorAction SilentlyContinue
        $results | Add-Member -MemberType NoteProperty -Name "SSL2" -Value $SSLProtocols.Ssl2
        $results | Add-Member -MemberType NoteProperty -Name "SSL3" -Value $SSLProtocols.Ssl3
        $results | Add-Member -MemberType NoteProperty -Name "TLS" -Value $SSLProtocols.Tls
        $results | Add-Member -MemberType NoteProperty -Name "TLS 1.1" -Value $SSLProtocols.Tls11
        $results | Add-Member -MemberType NoteProperty -Name "TLS 1.2" -Value $SSLProtocols.Tls12
    }
    if ($null -ne $results){
        Write-Host $results
        $results | export-csv .\results.csv -Append
    }
}