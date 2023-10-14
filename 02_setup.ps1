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

# Install ScanApp dependencies
Start-Process -FilePath  \\nki-fs01\EXCP_DATA\installer\aspnetcore-runtime-6.0.21-win-x64.exe -Wait
Start-Process -FilePath  \\nki-fs01\EXCP_DATA\installer\windowsdesktop-runtime-6.0.21-win-x64.exe -Wait

# Setup folders
$FolderList = @(
    "C:\Ripcord",
    "C:\Ripcord\.ssh",
    "C:\Ripcord\code",
    "C:\Ripcord\logs",
    "C:\Ripcord\logs\filebeat",
    "C:\Ripcord\logs\scripts",
    "C:\Ripcord\settings"
)

foreach ($Folder in $FolderList) {
    New-Folder $Folder
}

# Copy files
Copy-Item \\nki-fs01\EXCP_DATA\ishikawa\setup\config C:\Ripcord\.ssh\
Copy-Item \\nki-fs01\EXCP_DATA\ishikawa\setup\id_rsa C:\Ripcord\.ssh\
Copy-Item \\nki-fs01\EXCP_DATA\ishikawa\setup\id_rsa.pub C:\Ripcord\.ssh\

# Setup rip-app repository
Set-Location C:\Ripcord\code
git config --system core.sshCommand "ssh -F /c/Ripcord/.ssh/config"
git config --global http.sslVerify false
git clone git@github.com:fujifilm-ripcord/rip-app-utility.git
Set-Location C:\Ripcord\code\rip-app-utility
git fetch
git pull
New-Item .\tools\creds_tool\creds -ItemType Directory
Copy-Item \\nki-fs01\EXCP_DATA\ishikawa\setup\key .\tools\creds_tool\creds\
Set-Location C:\Ripcord\code\rip-app-utility\tools\creds_tool
Start-Process .\create_creds.bat -Wait
Set-Location C:\Ripcord\code\rip-app-utility
Start-Process .\deploy.bat -Wait
$Script = ".\tools\task_setup\make-task.ps1"
$Argument   = "-Command $Script"
Start-Process -FilePath powershell -ArgumentList $Argument -Wait

# Setup chocolatey
$Script = "C:\Ripcord\code\rip-app-utility\tools\azure_pat\pat_renew_setup.ps1"
$Argument = "-Command $Script"
Start-Process  -FilePath powershell -ArgumentList $Argument -Wait
choco upgrade fbrc-chocolatey-license -y
choco upgrade chocolatey.extension -y

# Setup dot file repository
Set-Location C:\Users\kazuki.ishikawa
New-Item Projects -ItemType Directory
Set-Location C:\Users\kazuki.ishikawa\Projects
git clone git@github.com:Kaz53/dotfile.git
Set-Location C:\Users\kazuki.ishikawa\Projects\dotfile
.\win-setup.ps1

# Setup fluentbit
Start-Process C:\Ripcord\code\rip-app-utility\tools\fluentbit\fluentbit_setup.bat -Wait
