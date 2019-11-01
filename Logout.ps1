$logoutUri = 'http://192.168.2.135/eportal/InterFace.do?method=logout'
function Invoke-Logout () {
    $logoutResponse = Invoke-WebRequest -Uri $logoutUri
    $utf8 = [Text.Encoding]::UTF8
    $logoutHtml = [IO.StreamReader]::new($logoutResponse.RawContentStream, $utf8).ReadToEnd()
    $logoutJson = ConvertFrom-Json $logoutHtml
    [Windows.MessageBox]::Show($logoutJson.message, $logoutJson.result)
}
