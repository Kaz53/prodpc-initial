if (!([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole("Administrators")) {
    Start-Process powershell.exe "-File `"$PSCommandPath`"" -Verb RunAs; exit }

Function New-Folder($path) {
    if (!(Test-Path $path)) {
        New-Item -ItemType Directory -Force -Path $path
    }
}

# Change Execution Policy
PowerShell Set-ExecutionPolicy RemoteSigned

# Setup folders
$FolderList = @(
    "C:\Ripcord\.ssh"
)

foreach ($Folder in $FolderList) {
    New-Folder $Folder
}

# Copy files
Copy-Item \\nki-fs01\EXCP_DATA\ishikawa\setup\config C:\Ripcord\.ssh\
Copy-Item \\nki-fs01\EXCP_DATA\ishikawa\setup\id_rsa C:\Ripcord\.ssh\
Copy-Item \\nki-fs01\EXCP_DATA\ishikawa\setup\id_rsa.pub C:\Ripcord\.ssh\

# Setup git
git config --system core.sshCommand "ssh -F /c/Ripcord/.ssh/config"
git config --global http.sslVerify false

# Setup rip-app repository
if (Test-Path C:\Ripcord\code\rip-app-utility) {
    Set-Location C:\Ripcord\code\rip-app-utility
    git remote set-url origin git@github.com:fujifilm-ripcord/rip-app-utility.git
}

Set-Location C:\Ripcord\code\rip-app-utility
$Script = ".\tools\task_setup\make-task.ps1"
$Argument   = "-Command $Script"
Start-Process -FilePath powershell -ArgumentList $Argument -Wait

# Setup dot file repository
Set-Location C:\Users\kazuki.ishikawa
New-Item Projects -ItemType Directory
Set-Location C:\Users\kazuki.ishikawa\Projects
git clone git@github.com:Kaz53/dotfile.git
Set-Location C:\Users\kazuki.ishikawa\Projects\dotfile
.\win-setup.ps1

# Setup fluentbit
Start-Process C:\Ripcord\code\rip-app-utility\tools\fluentbit\fluentbit_setup.bat -Wait

# Setup nakai-scan-app-settings repo
if (Test-Path C:\Ripcord\code\nakai-scanapp-settings) {
    Set-Location C:\Ripcord\code\nakai-scanapp-settings
    git remote set-url origin git@github.com:MoffettData/nakai-scanapp-settings.git
}

