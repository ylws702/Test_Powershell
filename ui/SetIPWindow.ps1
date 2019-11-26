# GUI based on WPF
Add-Type -AssemblyName PresentationFramework

if (!(Test-Path '.\SetIPWindow.xaml')) {
    Set-Location '.\ui'
    if (!(Test-Path '.\SetIPWindow.xaml')) {
        break
    }
}

$messageBox = [Windows.MessageBox]

# Create window
$xamlFile = '.\SetIPWindow.xaml'
$inputXML = Get-Content $xamlFile -Raw
$inputXML = $inputXML -replace 'mc:Ignorable="d"', '' -replace 'x:N', 'N' -replace '^<Win.*', '<Window'
[XML]$xaml = $inputXML

# Read XAML
$reader = [Xml.XmlNodeReader]::new($xaml)
$SetIPWindow = [Windows.Markup.XamlReader]::Load($reader)

# Create variables based on form control names.
# Variable will be named as 'SetIPWindow_<control name>'

$xaml.SelectNodes("//*[@Name]") | ForEach-Object {
    Set-Variable -Name "SetIPWindow_$($_.Name)" -Value $SetIPWindow.FindName($_.Name)
}

# Import ip data
$ip = Get-Content '..\data\ip.json' -Encoding UTF8 | ConvertFrom-Json 

$ip | ForEach-Object {
    $SetIPWindow_IPListView.Items.Add($_)
}

$interface = Get-NetAdapter -Physical |
Where-Object -FilterScript { $_.MediaType -eq 'Native 802.11' }
    
if ($interface.Count -ne 0) {
    $interfaceTable = @{ }
    $interface | ForEach-Object {
        $SetIPWindow_WiFiAdapterComboBox.Items.Add($_.InterfaceDescription)
        $interfaceTable += @{ $_.InterfaceDescription = $_.ifIndex }
    }
    $SetIPWindow_WiFiAdapterComboBox.SelectedIndex = 0
}

# Import functions
. '..\function\GenerateIP.ps1'
. '..\function\SetIP.ps1'

# When the selection of IPListView changed
# update DefaultGateway, PrefixLength and generate a random IP
$SetIPWindow_IPListView.Add_SelectionChanged( {
        $defaultGateway = $_.AddedItems.DefaultGateway
        $prefixLength = $_.AddedItems.PrefixLength
        $SetIPWindow_PrefixLengthTextBlock.Text = $prefixLength
        $SetIPWindow_DefaultGatewayTextBlock.Text = $defaultGateway
        do {
            $randIP = Get-RandomIP $defaultGateway $prefixLength
        } while ($randIP -eq $defaultGateway)
        $SetIPWindow_IPTextBox.Text = $randIP
    })

# Generate IP in the same subnet
$SetIPWindow_GenerateIPButton.Add_Click( {
        $defaultGateway = $SetIPWindow_DefaultGatewayTextBlock.Text
        if ($defaultGateway -eq '') {
            $messageBox::Show('Please select a location first.', 'Error')
            return
        }
        $prefixLength = $SetIPWindow_PrefixLengthTextBlock.Text
        $SetIPWindow_IPTextBox.Text = Get-RandomIP $defaultGateway $prefixLength
    })
$SetIPWindow_ApplyButton.Add_Click( {
        $defaultGateway = $SetIPWindow_DefaultGatewayTextBlock.Text
        if ($defaultGateway -eq '') {
            $messageBox::Show('Please select a location first.', 'Error')
            return
        }
        $prefixLength = $SetIPWindow_PrefixLengthTextBlock.Text
        $ifIndex = $SetIPWindow_WiFiAdapterComboBox
        # Set-IPConfig $ifI
    })

$null = $SetIPWindow.ShowDialog()
