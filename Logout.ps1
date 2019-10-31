$logoutUri = 'http://192.168.2.135/eportal/InterFace.do?method=logout'
function Invoke-Logout () {
    $logoutResponse = Invoke-WebRequest -Uri $logoutUri
    $utf8 = [System.Text.Encoding]::UTF8
    $logoutHtml = [System.IO.StreamReader]::new($logoutResponse.RawContentStream, $utf8).ReadToEnd()
    $logoutJson = ConvertFrom-Json $logoutHtml
    $messagBox::Show($logoutJson.message, $logoutJson.result)
}
