if (!(Test-Path '.\ui')) {
    Set-Location ..
    if (!(Test-Path '.\ui')) {
        break
    }
}

powershell -WindowStyle Hidden -File '.\ui\SetIPWindow.ps1'