# Get-CertificateData
Get's SSL Certificate Data from IP and Port

## How to Run this script.
- Open powershell and navigate to the location of this script.
- run the Main Script like so:
  - To run the script using CIDR parameters:
    - `path\to\Main.ps1 -ipAddress 5.5.5.0 -cidr 24`
    - This will check every cert from 5.5.5.0 to 5.5.5.255
  - To check a single ip address:
    - `path\to\Main.ps1 -ipAddress 5.5.5.0`
    - This will check for a cert on just 5.5.5.0
  - To check a range:
    - `path\to\Main.ps1 -start 5.5.5.0 -end 5.5.5.10`
    - This will check every cert in 5.5.5.0 to 5.5.5.10

# Results
Results will be spit out in a report called results.csv

# PS
You will see a progress in your powershell window:

![alt text][progress]

[progress]: /images/progress.png
