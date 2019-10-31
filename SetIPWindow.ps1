# GUI based on WPF
Add-Type -AssemblyName PresentationFramework

$messageBox = [System.Windows.MessageBox]

# Create window
$xamlFile = '.\SetIPWindow.xaml'
$inputXML = Get-Content $xamlFile -Raw
$inputXML = $inputXML -replace 'mc:Ignorable="d"', '' -replace 'x:N', 'N' -replace '^<Win.*', '<Window'
[XML]$xaml = $inputXML

# Read XAML
$reader = [System.Xml.XmlNodeReader]::new($xaml)
$SetIPWindow = [Windows.Markup.XamlReader]::Load($reader)

# Create variables based on form control names.
# Variable will be named as 'SetIPWindow_<control name>'

$xaml.SelectNodes("//*[@Name]") | ForEach-Object {
    Set-Variable -Name "SetIPWindow_$($_.Name)" -Value $SetIPWindow.FindName($_.Name)
}

# Import ip data
$ip = Get-Content '.\ip.json' -Encoding UTF8 | ConvertFrom-Json 

$ip | ForEach-Object {
    $SetIPWindow_IPListView.Items.Add($_)
}

$SetIPWindow_IPListView.Add_SelectionChanged( {
        $SetIPWindow_IPTextBox.Text = $_.AddedItems.StartIP
        $SetIPWindow_PrefixLengthTextBlock.Text = $_.AddedItems.PrefixLength
        $SetIPWindow_DefaultGatewayTextBlock.Text = $_.AddedItems.DefaultGateway
    })

function Get-IP ([IPAddress]$ip, [int]$prefixLength) {
    $bytes = $ip.GetAddressBytes()
    if ([BitConverter]::IsLittleEndian) {
            [Array]::Reverse($bytes)
    }
    [BitConverter]::ToUInt32($bytes, 0)
}

$SetIPWindow_GenerateIPButton.Add_Click( {
        $SetIPWindow_IPListView.SelectedItem
    })

$Null = $SetIPWindow.ShowDialog()
