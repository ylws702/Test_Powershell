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
    '"PrefixLength":' + ($_.PrefixLength).ToString() + ','
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
function Copy-RawItem
{
<#
.SYNOPSIS
    Copies a file from one location to another including files contained within DeviceObject paths.
.PARAMETER Path
    Specifies the path to the file to copy.
.PARAMETER Destination
    Specifies the path to the location where the item is to be copied.
.PARAMETER FailIfExists
    Do not copy the file if it already exists in the specified destination.
.OUTPUTS
    None or an object representing the copied item.
.EXAMPLE
    Copy-RawItem ‘\\?\GLOBALROOT\Device\HarddiskVolumeShadowCopy2\Windows\System32\config\SAM’ ‘C:\temp\SAM’
#>
    [CmdletBinding()]
    [OutputType([System.IO.FileSystemInfo])]
    Param (
        [Parameter(Mandatory = $True, Position = 0)]
        [ValidateNotNullOrEmpty()]
        [String]
        $Path,
        [Parameter(Mandatory = $True, Position = 1)]
        [ValidateNotNullOrEmpty()]
        [String]
        $Destination,
        $FailIfExists
    )
    # Create a new dynamic assembly. An assembly (typically a dll file) is the container for modules
    $DynAssembly = New-Object System.Reflection.AssemblyName('Win32Lib')
    # Define the assembly and tell is to remain in memory only (via [Reflection.Emit.AssemblyBuilderAccess]::Run)
    $AssemblyBuilder = [AppDomain]::CurrentDomain.DefineDynamicAssembly($DynAssembly, [Reflection.Emit.AssemblyBuilderAccess]::Run)
    # Define a new dynamic module. A module is the container for types (a.k.a. classes)
    $ModuleBuilder = $AssemblyBuilder.DefineDynamicModule('Win32Lib', $False)
    # Define a new type (class). This class will contain our method – CopyFile
    # I’m naming it ‘Kernel32’ so that you will be able to call CopyFile like this:
    # [Kernel32]::CopyFile(src, dst, FailIfExists)
    $TypeBuilder = $ModuleBuilder.DefineType('Kernel32', 'Public, Class')
    # Define the CopyFile method. This method is a special type of method called a P/Invoke method.
    # A P/Invoke method is an unmanaged exported function from a module – like kernel32.dll
    $PInvokeMethod = $TypeBuilder.DefineMethod(
‘CopyFile’,
[Reflection.MethodAttributes] ‘Public, Static’,
[Bool],
[Type[]] @([String], [String], [Bool]))
    #region DllImportAttribute
    # Set the equivalent of: [DllImport(
    #   “kernel32.dll”,
    #   SetLastError = true,
    #   PreserveSig = true,
    #   CallingConvention = CallingConvention.WinApi,
    #   CharSet = CharSet.Unicode)]
    # Note: DefinePInvokeMethod cannot be used if SetLastError needs to be set
    $DllImportConstructor = [Runtime.InteropServices.DllImportAttribute].GetConstructor(@([String]))
    $FieldArray = [Reflection.FieldInfo[]] @(
        [Runtime.InteropServices.DllImportAttribute].GetField(‘EntryPoint’),
        [Runtime.InteropServices.DllImportAttribute].GetField(‘PreserveSig’),
        [Runtime.InteropServices.DllImportAttribute].GetField(‘SetLastError’),
        [Runtime.InteropServices.DllImportAttribute].GetField(‘CallingConvention’),
        [Runtime.InteropServices.DllImportAttribute].GetField(‘CharSet’)
    )
    $FieldValueArray = [Object[]] @(
        ‘CopyFile’,
        $True,
        $True,
        [Runtime.InteropServices.CallingConvention]::Winapi,
        [Runtime.InteropServices.CharSet]::Unicode
    )
    $SetLastErrorCustomAttribute = New-Object Reflection.Emit.CustomAttributeBuilder(
$DllImportConstructor,
@(‘kernel32.dll’),
$FieldArray,
$FieldValueArray)
    $PInvokeMethod.SetCustomAttribute($SetLastErrorCustomAttribute)
    #endregion
    # Make our method accesible to PowerShell
    $Kernel32 = $TypeBuilder.CreateType()
    # Perform the copy
    $CopyResult = $Kernel32::CopyFile($Path, $Destination, ([Bool] $PSBoundParameters[‘FailIfExists’]))
    if ($CopyResult -eq $False)
    {
        # An error occured. Display the Win32 error set by CopyFile
        throw ( New-Object ComponentModel.Win32Exception )
    }
    else
    {
        Write-Output (Get-ChildItem $Destination)
    }
}
