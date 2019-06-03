. .\Functions\getCertificateData.ps1

$ipAddresses = get-content .\ipaddresses.txt
$resultsPath = ".\results.csv"

if (!(Test-Path $resultsPath)) {
    new-item -type file .\results.csv
}

foreach ($ip in $ipAddresses) {
    $results = get-CertificateData -Ip $ip -ErrorAction SilentlyContinue
     
    if ($results -ne $null){
        $results | export-csv .\results.csv -Append
    }
}