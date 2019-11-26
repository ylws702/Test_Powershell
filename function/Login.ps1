$redirectUri = 'http://192.168.2.135/eportal/redirectortosuccess.jsp'
$loginUri = 'http://192.168.2.135/eportal/InterFace.do?method=login'
$messageBox = [Windows.MessageBox]
function Invoke-Login ([string]$ID, [string]$Passwd) {
    $redirectResponse = Invoke-WebRequest -Uri $redirectUri
    if ($redirectResponse.Headers.Server -eq 'ruijie') {
        $messageBox::Show('You''re already logged in', 'Logged in')
        return
    }
    $href = ([Regex]'index\.jsp\?(.+?)[\''\"]').Matches($redirectResponse.RawContent)
    if ($href.Count -ne 1) {
        $messageBox::Show('Cannot find redirect href', 'Error')
        return
    }
    $loginParams = @{
        userId          = $ID;
        password        = $Passwd;
        service         = 'internet';
        passwordEncrypt = 'false';
        queryString     = $href[0].Groups[1].Value;
    }
    $loginResponse = Invoke-WebRequest -Uri $loginUri -Method POST -Body $loginParams
    $utf8 = [Text.Encoding]::UTF8
    $loginHtml = [IO.StreamReader]::new($loginResponse.RawContentStream, $utf8).ReadToEnd()
    $json = ConvertFrom-Json $loginHtml
    if ($json.result -eq 'success') {
        $messageBox::Show('Log in successfully', 'Success')
    }
    else {
        $messageBox::Show($json.message, 'Failed')
    }
}