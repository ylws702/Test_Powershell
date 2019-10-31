# GUI based on WPF
Add-Type -AssemblyName PresentationFramework

$messageBox = [System.Windows.MessageBox]

# Create window
$xamlFile = '.\SetIP.xaml'
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

# 
$ip = Get-Content '.\ip.json' -Encoding UTF8 | ConvertFrom-Json 
$ip | ForEach-Object {
    $_
    $SetIPWindow_IPListView.Items.Add($_)
}

$Null = $SetIPWindow.ShowDialog()
