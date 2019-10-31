$interface = Get-NetAdapter -Physical |
    Where-Object -FilterScript { $_.MediaType -eq 'Native 802.11' }
$ifIndex = $interface.ifIndex


$info = @{
    Location       = '一教ABCD';
    DefaultGateway = '10.132.15.254';
    PrefixLength   = 20;
    StartIP        = '10.132.0.2';
}, @{
    Location       = '建环学院';
    DefaultGateway = '10.132.19.254';
    PrefixLength   = 22;
    StartIP        = '10.132.16.1';
}, @{
    Location       = '文科楼';
    DefaultGateway = '10.132.23.254';
    PrefixLength   = 22;
    StartIP        = '10.132.20.1';
}, @{
    Location       = '法学院';
    DefaultGateway = '10.132.27.254';
    PrefixLength   = 22;
    StartIP        = '10.132.24.1';
}, @{
    Location       = '江安图书馆';
    DefaultGateway = '10.132.31.254';
    PrefixLength   = 22;
    StartIP        = '10.132.28.1';
}, @{
    Location       = '新能源研究院';
    DefaultGateway = '10.132.32.254';
    PrefixLength   = 24;
    StartIP        = '10.132.32.1';
}, @{
    Location       = '艺术学院';
    DefaultGateway = '10.132.35.254';
    PrefixLength   = 23;
    StartIP        = '10.132.34.1';
}, @{
    Location       = '综合楼';
    DefaultGateway = '10.132.39.254';
    PrefixLength   = 22;
    StartIP        = '10.132.36.1';
}, @{
    Location       = '江安校医院';
    DefaultGateway = '10.132.40.254';
    PrefixLength   = 24;
    StartIP        = '10.132.40.1';
}, @{
    Location       = '二餐';
    DefaultGateway = '10.132.41.254';
    PrefixLength   = 24;
    StartIP        = '10.132.41.1';
}, @{
    Location       = '？';
    DefaultGateway = '10.132.42.254';
    PrefixLength   = 24;
    StartIP        = '10.132.42.1';
}, @{
    Location       = '一餐';
    DefaultGateway = '10.132.43.254';
    PrefixLength   = 24;
    StartIP        = '10.132.43.1';
}, @{
    Location       = '二号体育场';
    DefaultGateway = '10.132.44.254';
    PrefixLength   = 24;
    StartIP        = '10.132.44.1';
}, @{
    Location       = '江安体育馆';
    DefaultGateway = '10.132.45.254';
    PrefixLength   = 24;
    StartIP        = '10.132.45.1';
}, @{
    Location       = '？';
    DefaultGateway = '10.132.46.254';
    PrefixLength   = 24;
    StartIP        = '10.132.46.1';
}, @{
    Location       = '？';
    DefaultGateway = '10.132.47.254';
    PrefixLength   = 24;
    StartIP        = '10.132.47.1';
}, @{
    Location       = '二基楼';
    DefaultGateway = '10.132.51.254';
    PrefixLength   = 22;
    StartIP        = '10.132.48.1';
}, @{
    Location       = '一基楼';
    DefaultGateway = '10.132.55.254';
    PrefixLength   = 22;
    StartIP        = '10.132.52.1';
}, @{
    Location       = '行政楼（SCUNET-XZ）';
    DefaultGateway = '10.132.57.254';
    PrefixLength   = 23;
    StartIP        = '10.132.56.1';
}, @{
    Location       = '工程训练中心';
    DefaultGateway = '10.132.96.254';
    PrefixLength   = 24;
    StartIP        = '10.132.96.1';
}

$info | ForEach-Object {
    '{'
    '"Location":"' + ($_.Location.Trim()) + '",'
    '"DefaultGateway":"' + ($_.DefaultGateway) + '",'
    '"PrefixLength":' + ($_.PrefixLength).ToString()+','
    '"StartIP":"' + ($_.StartIP) + '"'
    '},'
}

# Set-DNSClientServerAddress `
#     -InterfaceIndex $ifIndex `
#     -ServerAddresses 202.115.32.39 202.115.32.36 `

# $info | ForEach-Object -Process {
#     New-NetIPAddress `
#         -InterfaceIndex $ifIndex `
#         -IPAddress 192.168.1.13 `
#         -DefaultGateway 192.168.1.1 `
#         -PrefixLength 24 `
# }



# Read-Host 'Press Enter to continue'