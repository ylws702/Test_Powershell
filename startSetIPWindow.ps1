for(;;){
    Write-Output $PWD
}

if (!(Test-Path '.\ui')) {
    cd ..
    if (!(Test-Path '.\ui')) {
        break
    }
}

powershell -File '.\ui\SetIPWindow.ps1'
Pause