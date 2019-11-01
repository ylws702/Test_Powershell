function Get-RandomIP ([IPAddress]$ip, [int]$prefixLength) {
    $bytes = $ip.GetAddressBytes()
    if ([BitConverter]::IsLittleEndian) {
        [Array]::Reverse($bytes)
    }
    $numerialIP = [BitConverter]::ToUInt32($bytes, 0)
    $rand = Get-Random (1 -shl (32 - $prefixLength))
    $numerialIP0 = $numerialIP -bxor $rand
    $bytes0 = [BitConverter]::GetBytes($numerialIP0)
    if ([BitConverter]::IsLittleEndian) {
        [Array]::Reverse($bytes0)
    }
    [IPAddress]$bytes0
}