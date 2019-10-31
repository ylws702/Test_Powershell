$redirectUri = 'http://192.168.2.135/eportal/redirectortosuccess.jsp'
$loginUri = 'http://192.168.2.135/eportal/InterFace.do?method=login'
$logoutUri = 'http://192.168.2.135/eportal/InterFace.do?method=logout'
$encoding = [System.Text.Encoding]::GetEncoding('gbk')
function Connect-SCUNET ([string]$ID, [string]$Passwd) {
    $redirectResponse = Invoke-WebRequest -Uri $redirectUri
    $redirectHtml = $redirectResponse.Content
    if ($redirectHtml.GetType() -eq [byte[]]) {
        $redirectHtml = $encoding.GetString($redirectHtml)
    }
    if (!$redirectHtml.StartsWith('<script>')) {
        'You''re already logged in'
        return
    }
    $href = ([regex]'index\.jsp\?(.+?)[\''\"]').Matches($redirectHtml)
    if ($href.Count -ne 1) {
        'Cannot find redirect href'
        return
    }
    $loginParams = @{
        userId          = $ID;
        password        = $Passwd;
        service         = 'internet';
        passwordEncrypt = 'false';
        queryString     = $href[0].Groups[1].Value;
    }
    $login = Invoke-WebRequest -Uri $loginUri -Method POST -Body $loginParams
    $loginHtmlResponse = $login.Content
    if ($loginHtml.GetType() -eq [byte[]]) {
        $loginHtml = $encoding.GetString($loginHtmlResponse)
    }
    $json = ConvertFrom-Json $loginHtml
    if ($json.result -eq 'success') {
        'Log in successfully'
    }
    else {
        Write-Output 'Fail to log in: ' $json.message
    }
}

function Disconnect-SCUNET () {
    $logoutResponse = Invoke-WebRequest -Uri $logoutUri
    $logoutHtml =  $logoutResponse.Content
    if ($logoutHtml.GetType() -eq [byte[]]) {
        $logoutHtml = $encoding.GetString($logoutHtml)
    }
    $logoutJson = ConvertFrom-Json $logoutHtml
    Write-Output $logoutJson.result$logoutJson.message
}

for (; ; ) {
    Start-Sleep 10
    Connect-SCUNET 2017141461262 294396
}
Read-Host 'Press Enter to continue'