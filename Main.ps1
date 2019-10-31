# GUI based on WPF
Add-Type -AssemblyName PresentationFramework

$messageBox = [System.Windows.MessageBox]

# Create window
$xamlFile = '.\MainWindow.xaml'
$inputXML = Get-Content $xamlFile -Raw
$inputXML = $inputXML -replace 'mc:Ignorable="d"', '' -replace 'x:N', 'N' -replace '^<Win.*', '<Window'
[XML]$xaml = $inputXML

# Read XAML
$reader = [System.Xml.XmlNodeReader]::new($xaml)
$MainWindow = [Windows.Markup.XamlReader]::Load($reader)

# Create variables based on form control names.
# Variable will be named as 'MainWindow_<control name>'

$xaml.SelectNodes("//*[@Name]") | ForEach-Object {
    Set-Variable -Name "MainWindow_$($_.Name)" -Value $MainWindow.FindName($_.Name)
}

# 
$account = Get-Content '.\account.json' | ConvertFrom-Json

if ($account.Length -ne 0) {
    $MainWindow_IDComboBox.Text = $account[0].id
    $MainWindow_PasswordBox.Password = $account[0].password
    $accountTable = @{ }
    $account | ForEach-Object {
        $MainWindow_IDComboBox.Items.Add($_.id)
        $accountTable += @{ $_.id = $_.password }
    }
    # When selection of IDComboBox changed
    # fill the password according to id
    $MainWindow_IDComboBox.Add_SelectionChanged( {
            $MainWindow_PasswordBox.Password = $accountTable.($_.AddedItems[0])
        })
    # When password box got focus
    # fill the password according to id and select it all
    $MainWindow_PasswordBox.Add_GotFocus( {
            $MainWindow_PasswordBox.Password = $accountTable.[long]$MainWindow_IDComboBox.Text
            $_.Source.Dispatcher.BeginInvoke([action] { $MainWindow_PasswordBox.SelectAll() });
        })
}

# Import functions
. '.\Connect.ps1'
. '.\Login.ps1'
. '.\Logout.ps1'

# Add click events

$MainWindow_ConnectButton.Add_Click( {
        try {
            Connect-SCUNET
        }
        catch {
            $messageBox::Show($Error[0], 'Error')
        }
    })

$MainWindow_SetStaticIPButton.Add_Click( {
        $args = '-Command', "cd $PWD;& '.\startSetIP.ps1';"
        Start-Process -FilePath powershell -ArgumentList $args -Verb runas
    })

$MainWindow_LoginButton.Add_Click( {
        try {
            Invoke-Login $MainWindow_IDComboBox.Text $MainWindow_PasswordBox.Password
        }
        catch {
            $messageBox::Show($Error[0], 'Error')
        }
    })

$MainWindow_LogoutButton.Add_Click( {
        try {
            Invoke-Logout
        }
        catch {
            $messageBox::Show($Error[0], 'Error')
        }
    })

$Null = $MainWindow.ShowDialog()
