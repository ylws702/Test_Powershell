function Clear-IPConfig ([int]$ifIndex) {
    Remove-NetRoute -AddressFamily IPv4 -ifIndex $ifIndex -Confirm:$false
    Set-DnsClientServerAddress -ResetServerAddresses
}