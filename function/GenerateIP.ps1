function Get-RandomIP ([IPAddress]$ip, [int]$prefixLength) {
    if ($prefixLength -lt 0 -or $prefixLength -ge 32) {
        throw [ArgumentException]::new("Invalid prefix length: $prefixLength", '$prefixLength')
    }
    $bytes = $ip.GetAddressBytes()
    if ([BitConverter]::IsLittleEndian) {
        [Array]::Reverse($bytes)
    }
    $numerialIP = [BitConverter]::ToUInt32($bytes, 0)
    $suffixLength = 32 - $prefixLength
    $numerialIP = $numerialIP -shr $suffixLength -shl $suffixLength
    # exclude network address, gateway address and broadcast address
    $rand = Get-Random -Min 1 -Max ((1 -shl $suffixLength) - 2)
    $generateIP = $numerialIP -bor $rand
    $bytes0 = [BitConverter]::GetBytes($generateIP)
    if ([BitConverter]::IsLittleEndian) {
        [Array]::Reverse($bytes0)
    }
    [IPAddress]$bytes0
}