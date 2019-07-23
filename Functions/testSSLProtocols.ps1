function Test-SslProtocols {
    param(
      [Parameter(Mandatory=$true,ValueFromPipelineByPropertyName=$true,ValueFromPipeline=$true)]
      $ComputerName,
      
      [Parameter(ValueFromPipelineByPropertyName=$true)]
      [int]$Port = 443
    )
    begin {
      $ProtocolNames = [System.Security.Authentication.SslProtocols] | gm -static -MemberType Property | ?{$_.Name -notin @("Default","None")} | %{$_.Name}
    }
    process {
      $ProtocolStatus = [Ordered]@{}
      $ProtocolStatus.Add("ComputerName", $ComputerName)
      $ProtocolStatus.Add("Port", $Port)
      $ProtocolStatus.Add("KeyLength", $null)
      $ProtocolStatus.Add("SignatureAlgorithm", $null)
      
      $ProtocolNames | %{
        $ProtocolName = $_
        $Socket = New-Object System.Net.Sockets.Socket([System.Net.Sockets.SocketType]::Stream, [System.Net.Sockets.ProtocolType]::Tcp)
        $Socket.Connect($ComputerName, $Port)
        try {
          $NetStream = New-Object System.Net.Sockets.NetworkStream($Socket, $true)
          $SslStream = New-Object System.Net.Security.SslStream($NetStream, $true)
          $SslStream.AuthenticateAsClient($ComputerName,  $null, $ProtocolName, $false )
          $RemoteCertificate = [System.Security.Cryptography.X509Certificates.X509Certificate2]$SslStream.RemoteCertificate
          $ProtocolStatus["KeyLength"] = $RemoteCertificate.PublicKey.Key.KeySize
          $ProtocolStatus["SignatureAlgorithm"] = $RemoteCertificate.SignatureAlgorithm.FriendlyName
          $ProtocolStatus["Certificate"] = $RemoteCertificate
          $ProtocolStatus.Add($ProtocolName, $true)
        } catch  {
          $ProtocolStatus.Add($ProtocolName, $false)
        } finally {
          $SslStream.Close()
        }
      }
      [PSCustomObject]$ProtocolStatus
    }
  }
 