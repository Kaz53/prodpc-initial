if (!([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole("Administrators"))
{
    Start-Process powershell.exe "-File `"$PSCommandPath`"" -Verb RunAs; exit 
}

Function New-Folder($path)
{
    if (!(Test-Path $path))
    {
        New-Item -ItemType Directory -Force -Path $path
    }
}

# Change Execution Policy
PowerShell Set-ExecutionPolicy RemoteSigned

# Setup dot file repository
Set-Location C:\Users\kazuki.ishikawa
New-Item Projects -ItemType Directory
Set-Location C:\Users\kazuki.ishikawa\Projects
git clone git@github.com:Kaz53/dotfile.git
Set-Location C:\Users\kazuki.ishikawa\Projects\dotfile
.\win-setup.ps1

# Setup fluentbit
Start-Process C:\Ripcord\code\rip-app-utility\tools\fluentbit\fluentbit_setup.bat -Wait


