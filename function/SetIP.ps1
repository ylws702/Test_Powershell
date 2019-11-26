function Set-IPConfig ([int]$ifIndex, [string]$ip, [int]$prefixLength, [string]$defaultGateWay) {
    Set-DnsClientServerAddress -InterfaceIndex $ifIndex -ServerAddresses  '202.115.32.39', '202.115.32.36'
    New-NetIPAddress -IPAddress $ip -InterfaceIndex $ifIndex -DefaultGateway $defaultGateWay -PrefixLength $prefixLength
}