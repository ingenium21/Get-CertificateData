##############################################
# Author: Renato Regalado
# Office: Mindshift Systems Engineer
# Project: cert report
# Date: 01/11/2019
# License: GPLv3
##############################################

function get-CertificateData {

    [CmdletBinding()]
    Param (
	    [Parameter(Mandatory = $True, Position = 0)]
	    [string]$Ip,
	    [Parameter(Mandatory = $False, Position = 1)]
	    [string]$Port = "443"
	    )
	
    #$Ip = "10.1.240.1"
    #write-host "working on $Ip"
    $testConnect = test-connection $Ip -Count 1

    if($testConnect){
        #$Port = 443
        $nsname = (Resolve-DnsName $Ip).NameHost
        $Connection = New-Object System.Net.Sockets.TcpClient($Ip,$Port)
        $Connection.SendTimeout = 5000
        $Connection.ReceiveTimeout = 5000
        $Stream = $Connection.GetStream()

        try {
            $sslStream = New-Object System.Net.Security.SslStream($Stream,$False,([Net.ServicePointManager]::ServerCertificateValidationCallback = {$true}))
            $sslStream.AuthenticateAsClient($null)

            #$Certificate = [Security.Cryptography.X509Certificates.X509Certificate2]$sslStream.RemoteCertificate

            $cert = $sslStream.get_remotecertificate()
            $cert2 = New-Object system.security.cryptography.x509certificates.x509certificate2($cert)

            $validto = [datetime]::Parse($cert.getexpirationdatestring())
            $validfrom = [datetime]::Parse($cert.geteffectivedatestring())

            if ($cert.get_issuer().CompareTo($cert.get_subject())) {
                $selfsigned = "no";
            } else {
                $selfsigned = "yes";
            }

	        $certObject = New-Object -TypeName PSObject -property ([Ordered] @{
            'Server Name from DNS' = $nsname
	        'IP Address' = $Ip
	        'Port' = $Port
	        'Subject' = $cert.get_subject()
	        'Issuer' = $cert.get_issuer()
	        'Public Key' = $cert2.PublicKey.Key.KeySize
	        'Serial Number' = $cert.getserialnumberstring()
	        'Valid From' = $validfrom
	        'Valid to' = $validto
	        'Self Signed' = $selfsigned
	        'Signature Algorithm' = $cert2.SignatureAlgorithm.FriendlyName
	        })
		

        }
        finally {
            $Connection.Close()
        }
        return $certObject
        }
    else {
        #write-host "Could not connect to $Ip"
        }
}


