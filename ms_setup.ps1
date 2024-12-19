if (!([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole("Administrators")) {
    Start-Process powershell.exe "-File `"$PSCommandPath`"" -Verb RunAs; exit }


Function New-Folder($path) {
    if (!(Test-Path $path)) {
        New-Item -ItemType Directory -Force -Path $path
    }
}

# Setup nakai-scan-app-settings repo
Set-Location C:\Ripcord\code
if (Test-Path C:\Ripcord\code\nakai-scanapp-settings) {
    Remove-Item C:\Ripcord\code\nakai-scanapp-settings -Recurse -Force
}
git clone git@github.com:MoffettData/nakai-scanapp-settings.git
Set-Location C:\Ripcord\code\nakai-scanapp-settings

# Setup setting folders
$FolderList = @(
    "C:\Ripcord\settings"
)
foreach ($Folder in $FolderList) {
    New-Folder $Folder
}

# Copy common files
Copy-Item C:\Ripcord\code\nakai-scanapp-settings\MS\* C:\Ripcord\settings\ -Recurse -Force

Write-Host "Setup complete. Ready to install ScanApp."
Start-Sleep 3

Write-Host "Setup stream counter? [Y/n]"
$answer = Read-Host
if ($answer -ne "Y")
{
    exit
}

choco install streamdeck -y
Set-Location C:\Ripcord\code
git clone git@github.com:MoffettData/stream-counter.git
Set-Location C:\Ripcord\code\rip-app-utility\tools\stream-counter\
. stream-counter_setup.ps1

