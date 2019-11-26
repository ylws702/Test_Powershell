$Shell32 = Add-Type -MemberDefinition @'
[StructLayout(LayoutKind.Sequential, CharSet = CharSet.Unicode)]
public struct SHSTOCKICONINFO
{
    public uint cbSize;
    public IntPtr hIcon;
    public int iSysIconIndex;
    public int iIcon;
    [MarshalAs(UnmanagedType.ByValTStr, SizeConst = 260)]
    public string szPath;
    public SHSTOCKICONINFO(uint cbSize, 
        IntPtr hIcon,
        int iSysIconIndex,
        int iIcon,
        string szPath)
    {
        this.cbSize = cbSize;
        this.hIcon = hIcon;
        this.iSysIconIndex = iSysIconIndex;
        this.iIcon = iIcon;
        this.szPath = szPath;
    }
}
[DllImport("Shell32.dll", SetLastError = false)]
public static extern int SHGetStockIconInfo(uint siid, uint uFlags, ref SHSTOCKICONINFO psii);
'@ -Name 'Shell32' -Namespace 'Win32' -PassThru

$user32 = Add-Type -MemberDefinition @'
[DllImport("user32.dll", SetLastError = true)]
public static extern bool DestroyIcon(IntPtr hIcon);
'@ -Name 'user32' -Namespace 'Win32' -PassThru

$SHGSI_ICON = 0x000000100;
$SHGSI_SMALLICON = 0x000000001;
$SIID_SHIELD = 77;
function Add-Shield ($button) {
    $button.Add_Loaded( {
            $siiType = $shell32[1]

            $siiConstructor = $siiType.GetConstructor([Type[]]@([Uint32], [IntPtr], [int], [int], [string]))
            $sii = $siiConstructor.Invoke(@($null, $null, $null, $null, $null))
            $cbSize = [Uint32][Runtime.InteropServices.Marshal]::SizeOf($sii)
            $sii.cbSize = $cbSize

            [Runtime.InteropServices.Marshal]::ThrowExceptionForHR(
                $shell32[0]::SHGetStockIconInfo(
                    $SIID_SHIELD,
                    $SHGSI_ICON -bor $SHGSI_SMALLICON,
                    [ref]$sii
                )
            )

            $hIcon=[IntPtr]$siiType.GetField('hIcon').GetValue($sii)

            
            $MainWindow_SetStaticIPImage.Height = [Windows.SystemParameters]::SmallIconHeight;
            $MainWindow_SetStaticIPImage.Width = [Windows.SystemParameters]::SmallIconWidth;
            $MainWindow_SetStaticIPImage.Source = [Windows.Interop.Imaging]::CreateBitmapSourceFromHIcon(
                $hIcon,
                [Windows.Int32Rect]::Empty,
                [Windows.Media.Imaging.BitmapSizeOptions]::FromEmptyOptions()
            )
            $user32::DestroyIcon($hIcon)
        })
}