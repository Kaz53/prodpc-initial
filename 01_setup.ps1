if (!([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole("Administrators")) {
    Start-Process powershell.exe "-File `"$PSCommandPath`"" -Verb RunAs; exit }

function Find-Command($cmd){
    if (Get-Command * | Where-Object { $_.Name -match $cmd }) {
        Write-Host "Found $cmd"  -ForegroundColor Cyan
        return $true
    }
    if (!(Get-Command * | Where-object { $_.Name -match $cmd })) {
        Write-Host "Not found $cmd" -ForegroundColor Yellow
        return $false
    }
}

Function New-Folder($path) {
    if (!(Test-Path $path)) {
        New-Item -ItemType Directory -Force -Path $path
    }
}

# Change Execution Policy
PowerShell Set-ExecutionPolicy RemoteSigned

# Chocolatey
$cmd = "choco.exe"
if (-Not (Find-Command $cmd)){
    Write-Host "Installing Chocolatey ..."
    Set-ExecutionPolicy Bypass -Scope Process -Force; [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072; iex ((New-Object System.Net.WebClient).DownloadString('https://community.chocolatey.org/install.ps1'))
} else {
    choco upgrade chocolatey
}

# Install essential tools
choco install git -y
choco install notepadplusplus -y
choco install teamviewer -y
choco install googlechrome -y

Copy-Item \\nki-fs01\EXCP_DATA\installer\LibreOffice_24.2.5_Win_x86-64.msi $HOME\Downloads\
Start-Process -FilePath $HOME\Downloads\LibreOffice_24.2.5_Win_x86-64.msi -Wait


Write-Host "You need to re-launch the poewrshell"
Start-Sleep 10
