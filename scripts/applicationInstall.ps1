#############################################################################################
# PROD TTNA POOL INSTALLATION SCRIPT FOR IMAGE CREATION THROUGH AZURE IMAGE BUILDER PROCESS
#############################################################################################
#
# CREATE LOCAL FOLDERS FOR SOFTWARE AND TOOLS
# APPLICATIONS TO INSTALL:
# - Java JRE x64 & x86                              (Coris website TCAY)
# - 7Zip                                            (General)
# - DotNet 3.5                                      (Not sure which application requires this)
# - Microsoft 365 Apps for Enterprise + Version     (General)
# - Install Microsoft teams                         (General)
# - Adobe Reader DC                                 (General)
# - Google Chrome Enterprise                        (General)

#############################################################################################
# START Region Set Stage for download and Logging
#############################################################################################
Write-Host "START Region Set Stage for download and Logging"
if (!(Test-Path -Path "C:\deploy"))
{
    New-Item -Path "C:\" -Name "deploy" -ItemType "Directory" -ErrorAction SilentlyContinue
}

$logFile = "c:\deploy\" + (get-date -format 'yyyyMMdd') + '_softwareinstall.log'
function Write-Log {
    Param($message)
    Write-Output "$(get-date -format 'yyyyMMdd HH:mm:ss') $message" | Out-File -Encoding utf8 $logFile -Append
}
#############################################################################################
# END Region Set Stage for download and Logging
#############################################################################################

#############################################################################################
# START Region Configuration, files and fonts
#############################################################################################
Write-Host "START Region Configuration, files and fonts"
if (!(Test-Path -Path "c:\_curtoso")) { New-Item -Path "C:\" -Name "_curtoso" -ItemType "Directory" -ErrorAction SilentlyContinue }

# Remove Quick Assist
Remove-WindowsCapability -online -name App.Support.QuickAssist~~~~0.0.1.0
#############################################################################################
# END Region Configuration, files and fonts
#############################################################################################

#############################################################################################
# START Region Download and expand sysinternals toolset
#############################################################################################
Write-Host "START Region Download and expand sysinternals toolset"
# $appName = 'sysinternals'
if (!(Test-Path -Path "c:\tools\sysinternals")) { New-Item -Path "c:\tools\sysinternals" -ItemType "Directory" -ErrorAction SilentlyContinue }
$LocalPath = "c:\tools\sysinternals" 
set-Location $LocalPath
$appURL = "https://download.sysinternals.com/files/SysinternalsSuite.zip"
# $appURL = 'https://tcarwvdinfrasa.blob.core.windows.net/aib-tcar-win10-21h1-prod/Microsoft/SysinternalsSuite.zip?sv=2021-08-06&st=2022-12-19T20%3A06%3A55Z&se=2025-12-20T20%3A06%3A00Z&sr=b&sp=r&sig=6%2FgqnJZTqcfHV0TfJEj4gXpZt%2BbvZCS7g17ZJ0hSajo%3D'
$appFile = 'SysinternalsSuite.zip'
$outputPath = $LocalPath + '\' + $appFile
Invoke-WebRequest -Uri $appURL -OutFile $outputPath
Expand-Archive -LiteralPath 'C:\\Tools\\sysinternals\\SysinternalsSuite.zip' -DestinationPath $Localpath -Force
#############################################################################################
# END Region Download and expand sysinternals toolset
#############################################################################################

#############################################################################################
# START Region Java JRE install (X86 and X64)
############################################################################################# 
Write-Host "START Region Java JRE install (X86 and X64)"
# Download Java JRE x64:
$javax64downloadUrl="https://tcarwvdinfrasa.blob.core.windows.net/aib-tcar-win10-21h1-prod/Java/jre-8u401-windows-x64.exe?sp=r&st=2024-02-14T18:14:08Z&se=2026-02-15T02:14:08Z&spr=https&sv=2022-11-02&sr=b&sig=la7OLxUOKCMN4dzuJCgEuS4%2FFW44SkHQg6r5thV%2F%2BRw%3D"
if (!(Test-Path -Path "C:\deploy\java")) { New-Item -Path "C:\deploy" -Name "java" -ItemType "Directory" -ErrorAction SilentlyContinue }
$javax64InstallPath = "c:\deploy\java\jre-windows-x64.exe"
Invoke-WebRequest -Uri $javax64downloadUrl -OutFile $javax64InstallPath -UseBasicParsing
# Download Java JRE x86:
$javax86downloadUrl="https://tcarwvdinfrasa.blob.core.windows.net/aib-tcar-win10-21h1-prod/Java/jre-8u401-windows-i586.exe?sp=r&st=2024-02-14T18:14:50Z&se=2026-02-15T02:14:50Z&spr=https&sv=2022-11-02&sr=b&sig=1rPuD%2FyGb26HIoEu80PHyU3rGe7IXJKdNgBVOraclMo%3D"
if (!(Test-Path -Path "C:\deploy\java")) { New-Item -Path "C:\deploy" -Name "java" -ItemType "Directory" -ErrorAction SilentlyContinue }
$javax86InstallPath = "c:\deploy\java\jre-windows-i586.exe"
Invoke-WebRequest -Uri $javax86downloadUrl -OutFile $javax86InstallPath -UseBasicParsing

Write-Host "Install Java JRE x64"
# Install Java JRE x64:
try {
    start-process -filepath "c:\deploy\java\jre-windows-x64.exe" -ArgumentList "/qn INSTALL_SILENT=Enable AUTO_UPDATE=Disable EULA=Disable INSTALLDIR=C:\java\jre REBOOT=Disable WEB_ANALYTICS=Disable NOSTARTMENU=Enable REMOVEOUTOFDATEJRES=Disable" -Wait
    if (Test-Path "C:\java\jre\bin\java.exe") { 
        Write-Log "SUCCESS - Java JRE X64 Installed"
        Write-Host "SUCCESS - Java JRE X64 Installed"
    }
    else { 
        write-log "ERROR - locating the Java JRE X64 executable"
        Write-Host "ERROR - locating the Java JRE X64 executable"
    }
}
catch {
    $ErrorMessage = $_.Exception.message
    write-log "ERROR - installing Java JRE X64: $ErrorMessage"
    Write-Host "ERROR - installing Java JRE X64: $ErrorMessage"
}
Write-Host "Install Java JRE x86"
# Install Java JRE x86:
try {
    start-process -filepath "c:\deploy\java\jre-windows-i586.exe" -ArgumentList "/qn INSTALL_SILENT=Enable AUTO_UPDATE=Disable EULA=Disable INSTALLDIR=C:\java\jrex86 REBOOT=Disable WEB_ANALYTICS=Disable NOSTARTMENU=Enable REMOVEOUTOFDATEJRES=Disable" -Wait
    if (Test-Path "C:\java\jrex86\bin\java.exe") { 
        Write-Log "SUCCESS - Java JRE X86 Installed" 
        Write-Host "SUCCESS - Java JRE X86 Installed"
    }
    else { 
        write-log "ERROR - locating the Java JRE X86 executable" 
        Write-Host "ERROR - locating the Java JRE X86 executable" 
    }
}
catch {
    $ErrorMessage = $_.Exception.message
    write-log "ERROR - installing Java JRE X86: $ErrorMessage"
    Write-Host "ERROR - installing Java JRE X86: $ErrorMessage"
}
#############################################################################################
# END Region Java JRE install (X86 and X64)
############################################################################################# 

#############################################################################################
# START Region 7Zip
#############################################################################################
Write-Host "START Region 7Zip"
# Download 7Zip 2200 x64:
$7zipDownloadUrl="https://tcarwvdinfrasa.blob.core.windows.net/aib-tcar-win10-21h1-prod/7Zip/7z2301-x64.msi?sv=2021-10-04&st=2023-08-02T15%3A06%3A49Z&se=2025-08-03T15%3A06%3A00Z&sr=b&sp=r&sig=96%2FhHrSjpCcI9EHEGdi1N%2BpnXrIRYVCszDM3pTrPytU%3D"
if (!(Test-Path -Path "C:\deploy\7zip")) { New-Item -Path "C:\deploy" -Name "7zip" -ItemType "Directory" -ErrorAction SilentlyContinue }
$7zipInstallPath = "c:\deploy\7zip\7z-x64.msi"
Invoke-WebRequest -Uri $7zipDownloadUrl -OutFile $7zipInstallPath -UseBasicParsing

Write-Host "Install 7Zip"
# Install 7Zip 2200 x64 
try {
    Start-Process msiexec.exe -ArgumentList '/i "c:\deploy\7zip\7z-x64.msi" /norestart /qn' -wait
    if (Test-Path "C:\Program Files\7-Zip\7z.exe") { 
        Write-Log "SUCCESS - 7Zip Installed" 
        Write-Host "SUCCESS - 7Zip Installed" 
    }
    else { 
        write-log "ERROR - locating the 7Zip executable"
        Write-Host "ERROR - locating the 7Zip executable"  
    }
}
catch {
    $ErrorMessage = $_.Exception.message
    write-log "ERROR - installing 7Zip: $ErrorMessage"
    Write-Host "ERROR - installing 7Zip: $ErrorMessage"
}
#############################################################################################
# END Region 7Zip
#############################################################################################

#############################################################################################
# START Region Install DotNet 3.5
#############################################################################################
Write-Host "START Region Install DotNet 3.5"
# Enable Microsoft DotNet 3.5:
$NetFx3AUrl="https://tcarwvdinfrasa.blob.core.windows.net/aib-tcar-win10-21h1-prod/Microsoft/NetFx3/microsoft-windows-netfx3-ondemand-package~31bf3856ad364e35~amd64~~.cab?sv=2021-10-04&st=2023-04-15T20%3A26%3A36Z&se=2025-04-16T20%3A26%3A00Z&sr=b&sp=r&sig=QDi9CezcX149eSvgFxy37%2Fl32cPNqXJAg0dZPus1%2BuM%3D"
if (!(Test-Path -Path "C:\deploy\NetFx3")) { New-Item -Path "C:\deploy" -Name "NetFx3" -ItemType "Directory" -ErrorAction SilentlyContinue }
$NetFx3APath = "c:\deploy\NetFx3\microsoft-windows-netfx3-ondemand-package~31bf3856ad364e35~amd64~~.cab"
Invoke-WebRequest -Uri $NetFx3AUrl -OutFile $NetFx3APath -UseBasicParsing

$NetFx3BUrl="https://tcarwvdinfrasa.blob.core.windows.net/aib-tcar-win10-21h1-prod/Microsoft/NetFx3/Microsoft-Windows-NetFx3-OnDemand-Package~31bf3856ad364e35~amd64~en-US~.cab?sv=2021-10-04&st=2023-04-15T20%3A25%3A46Z&se=2025-04-16T20%3A25%3A00Z&sr=b&sp=r&sig=N8WHrV3ml6fGT3qCo3Qx78rCEZtDU6AIm8sLIFMoC8w%3D"
if (!(Test-Path -Path "C:\deploy\NetFx3")) { New-Item -Path "C:\deploy" -Name "NetFx3" -ItemType "Directory" -ErrorAction SilentlyContinue }
$NetFx3BPath = "c:\deploy\NetFx3\Microsoft-Windows-NetFx3-OnDemand-Package~31bf3856ad364e35~amd64~en-US~.cab"
Invoke-WebRequest -Uri $NetFx3BUrl -OutFile $NetFx3BPath -UseBasicParsing

Write-host "Enabled .NET 3.5"
try {
    DISM /Online /Enable-Feature /FeatureName:NetFx3 /All /LimitAccess /Source:c:\deploy\NetFx3
    # Enable-WindowsOptionalFeature -Online -FeatureName “NetFx3”
    $checkNetFx3 = Get-WindowsOptionalFeature -online -FeatureName "NetFx3"
    if ($checkNetFx3.state -eq "Enabled") { 
        Write-Log "SUCCESS - DotNet 3.5 installed successfully" 
        Write-Host "SUCCESS - DotNet 3.5 installed successfully" 
    }
    else { 
        Write-Log "ERROR - DotNet 3.5 Failed installing" 
        Write-Host "ERROR - DotNet 3.5 Failed installing" 
    }
}
Catch {
    $ErrorMessage = $_.Exception.message
    Write-Log "ERROR - Installing DotNet 3.5 : $ErrorMessage"
    Write-Host "ERROR - Installing DotNet 3.5 : $ErrorMessage"
}
#############################################################################################
# END Region Install DotNet 3.5
#############################################################################################

#############################################################################################
# START Region Microsoft 365 Apps for Enterprise + Visio custom 
#############################################################################################
Write-Host "START Region Microsoft 365 Apps for Enterprise + Visio custom "
# Download Office ODT:
$officeInstallUrl="https://tcarwvdinfrasa.blob.core.windows.net/aib-tcar-win10-21h1-prod/Microsoft/TCAR-ProdM365AppsConfig.zip?sv=2021-10-04&st=2023-10-17T13%3A19%3A49Z&se=2026-10-18T13%3A19%3A00Z&sr=b&sp=r&sig=16QyveTf%2FUC%2FyV2oOgyUS%2FJ7vytQNbIUYEgaEqqH5Vc%3D"
if (!(Test-Path -Path "C:\deploy\M365Apps")) { New-Item -Path "C:\deploy" -Name "M365Apps" -ItemType "Directory" -ErrorAction SilentlyContinue }
$officeInstallPath = "c:\deploy\M365Apps\TCAR-ProdM365AppsInstall.zip"
Invoke-WebRequest -Uri $officeInstallUrl -OutFile $officeInstallPath -UseBasicParsing
Expand-Archive -path "c:\deploy\M365Apps\TCAR-ProdM365AppsInstall.zip" -DestinationPath "c:\deploy\M365Apps\" -Force

Write-Host "Install Microsoft 365 Apps for Enterprise + Visio Custom"
# Install Microsoft 365 Apps for Enterprise + Visio custom:
try {
    Start-Process -filepath "c:\deploy\M365Apps\setup.exe" -ArgumentList '/configure "c:\deploy\M365Apps\TCAR-ProdM365AppsConfig.xml"' -Wait
    if (Test-Path "C:\Program Files\Microsoft Office\root\Office16\WINWORD.EXE") { 
        Write-Log "SUCCESS - Microsoft 365 Apps for Enterprise have been installed Successfully" 
        Write-Host "SUCCESS - Microsoft 365 Apps for Enterprise have been installed Successfully" 
    }
    else { 
        write-log "ERROR - locating the Word Executable" 
        Write-Host "ERROR - locating the Word Executable" 
    }
}
catch {
    $ErrorMessage = $_.Exception.message
    write-log "ERROR - installing Microsoft 365 Apps for Enterprise: $ErrorMessage"
    Write-Host "ERROR - installing Microsoft 365 Apps for Enterprise: $ErrorMessage"
}
#############################################################################################
# END Region Microsoft 365 Apps for Enterprise + Visio custom 
#############################################################################################

#############################################################################################
# START Region OneDrive per Machine install
#############################################################################################
Write-Host "START Region OneDrive per Machine install"
# Download OneDrive:
$OneDriveUrl="https://go.microsoft.com/fwlink/p/?LinkID=2182910&clcid=0x413&culture=en-us&country=US"
# $OneDriveUrl="https://tcarwvdinfrasa.blob.core.windows.net/aib-tcar-win10-21h1-prod/Microsoft/OneDriveSetup.exe?sv=2021-10-04&st=2022-12-14T20%3A52%3A23Z&se=2025-12-15T20%3A52%3A00Z&sr=b&sp=r&sig=pIeb6heDfzU1MZgfxwTT1Ew0Cv49lAQ5jW%2FvsNEPi%2F4%3D"
if (!(Test-Path -Path "C:\deploy\OneDrive")) { New-Item -Path "C:\deploy" -Name "OneDrive" -ItemType "Directory" -ErrorAction SilentlyContinue }
$OneDrivePath = "c:\deploy\OneDrive\OneDriveSetup.exe"
Invoke-WebRequest -Uri $OneDriveUrl -OutFile $OneDrivePath -UseBasicParsing

Write-Host "Install OneDrive per Machine"
# Install OneDrive per Machine:
try {
    Start-Process -filepath "c:\deploy\OneDrive\OneDriveSetup.exe" -ArgumentList '/silent /allusers' -Wait
    if (Test-Path "C:\Program Files\Microsoft OneDrive\OneDrive.exe") { 
        Write-Log "SUCCESS - OneDrive has been installed Successfully" 
        Write-Host "SUCCESS - OneDrive has been installed Successfully" 
    }
    else { 
        write-log "ERROR - locating OneDrive Executable" 
        Write-Host "ERROR - locating OneDrive Executable" 
    }
}
catch {
    $ErrorMessage = $_.Exception.message
    write-log "ERROR - installing OneDrive per Machine: $ErrorMessage"
    Write-Host "ERROR - installing OneDrive per Machine: $ErrorMessage"
}
#############################################################################################
# END Region OneDrive per Machine install
#############################################################################################

#############################################################################################
# START Region Install Microsoft Teams
#############################################################################################
Write-Host "START Region Install Microsoft Teams"
# Set Reg key IsWVDEnvironment
$Name = "IsWVDEnvironment"
$value = "1"
# Add Registry value
try {
    New-Item -Path "HKLM:\SOFTWARE\Microsoft" -Name "Teams" -Force
    New-ItemProperty -ErrorAction Stop -Path "HKLM:\SOFTWARE\Microsoft\Teams" -Name $name -Value $value -PropertyType DWORD -Force
    if ((Get-ItemProperty "HKLM:\SOFTWARE\Microsoft\Teams").PSObject.Properties.Name -contains $name) { 
        Write-log "SUCCESS - Added Teams registry key created successfully" 
        Write-Host "SUCCESS - Added Teams registry key created successfully" 
    }
    else { 
        write-log "ERROR - locating Teams registry key" 
        Write-Host "ERROR - locating Teams registry key" 
    }
}
catch {
    $ErrorMessage = $_.Exception.message
    write-log "ERROR - adding teams registry KEY: $ErrorMessage"
    Write-Host "ERROR - adding teams registry KEY: $ErrorMessage"
}

# Download the Teams WebSocket Service:
$MsRdcWebRTCSvcDownloadUrl="https://aka.ms/msrdcwebrtcsvc/msi"
# $MsRdcWebRTCSvcDownloadUrl="https://tcarwvdinfrasa.blob.core.windows.net/aib-tcar-win10-21h1-prod/Microsoft/MsRdcWebRTCSvc_HostSetup_1.31.2211.15001_x64.msi?sv=2021-10-04&st=2023-02-14T21%3A40%3A10Z&se=2025-02-15T21%3A40%3A00Z&sr=b&sp=r&sig=7SEDmN3%2B7oJ2t7u3IyvR8FFWBh46t0C7l0N5cGWS3zg%3D"
if (!(Test-Path -Path "C:\deploy\Teams")) { New-Item -Path "C:\deploy" -Name "Teams" -ItemType "Directory" -ErrorAction SilentlyContinue }
$MsRdcWebRTCSvcInstallPath = "c:\deploy\Teams\MsRdcWebRTCSvc_HostSetup.msi"
Invoke-WebRequest -Uri $MsRdcWebRTCSvcDownloadUrl -OutFile $MsRdcWebRTCSvcInstallPath -UseBasicParsing

# Install the Teams WebSocket Service
try {
    Start-Process msiexec.exe -ArgumentList '/i "c:\deploy\Teams\MsRdcWebRTCSvc_HostSetup.msi" /norestart /qn' -wait
    if (Test-Path "C:\Program Files\Remote Desktop WebRTC Redirector\MsRdcWebRTCSvc.exe") { 
        Write-Log "SUCCESS - Teams WebSocket Service Installed Successfully" 
        Write-Host "SUCCESS - Teams WebSocket Service Installed Successfully" 
    }
    else { 
        write-log "ERROR - locating the Teams WebSocket Service executable" 
        Write-Host "ERROR - locating the Teams WebSocket Service executable" 
    }
}
catch {
    $ErrorMessage = $_.Exception.message
    write-log "ERROR - installing Teams WebSocket Service: $ErrorMessage"
    Write-Host "ERROR - installing Teams WebSocket Service: $ErrorMessage"
}

# Download Microsoft Teams:
$MsTeamsDownloadUrl="https://teams.microsoft.com/downloads/desktopurl?env=production&plat=windows&arch=x64&managedInstaller=true&download=true"
# $MsTeamsDownloadUrl="https://tcarwvdinfrasa.blob.core.windows.net/aib-tcar-win10-21h1-prod/Microsoft/Teams_windows_x64.msi?sv=2021-08-06&st=2022-11-15T08%3A54%3A52Z&se=2023-11-16T08%3A54%3A00Z&sr=b&sp=r&sig=0Psh9R3C8Tb8sA6xPRvKGmDAsbVYcDkBgojke30ZAPE%3D"
if (!(Test-Path -Path "C:\deploy\Teams")) { New-Item -Path "C:\deploy" -Name "Teams" -ItemType "Directory" -ErrorAction SilentlyContinue }
$MsTeamsInstallPath = "c:\deploy\Teams\Teams_windows_x64.msi"
Invoke-WebRequest -Uri $MsTeamsDownloadUrl -OutFile $MsTeamsInstallPath -UseBasicParsing

# Install Microsoft Teams
try {
    Start-Process msiexec.exe -ArgumentList '/i "c:\deploy\Teams\Teams_windows_x64.msi" ALLUSER=1 ALLUSERS=1 /norestart /qn' -wait
    if (Test-Path "C:\Program Files (x86)\Teams Installer\Teams.exe") { 
        Write-Log "SUCCESS - Teams Installed Successfully" 
        Write-Host "SUCCESS - Teams Installed Successfully" 
    }
    else { 
        write-log "ERROR - locating the Teams executable" 
        Write-Host "ERROR - locating the Teams executable" 
    }
}
catch {
    $ErrorMessage = $_.Exception.message
    write-log "ERROR - installing Teams: $ErrorMessage"
    Write-Host "ERROR - installing Teams: $ErrorMessage"
}
#############################################################################################
# END Region Install Microsoft Teams
#############################################################################################

#############################################################################################
# START Region Adobe Reader DC 
#############################################################################################
Write-Host "START Region Adobe Reader DC "
# Download Adobe Reader DC:
# https://get.adobe.com/nl/reader/enterprise/
$adobeInstallUrl="https://tcarwvdinfrasa.blob.core.windows.net/aib-tcar-win10-21h1-prod/Adobe/AcroRdrDC2300820555_en_US.exe?sp=r&st=2024-03-07T20:08:17Z&se=2026-03-08T04:08:17Z&spr=https&sv=2022-11-02&sr=b&sig=onkIZ%2Fn8ttnWSqQ6Imj8SBXMQ%2F2hz87Si1YfxVKQX%2Fo%3D"
if (!(Test-Path -Path "C:\deploy\AdobeReaderDC")) { New-Item -Path "C:\deploy" -Name "AdobeReaderDC" -ItemType "Directory" -ErrorAction SilentlyContinue }
$adobeInstallPath = "c:\deploy\AdobeReaderDC\AcroRdrDC.exe"
Invoke-WebRequest -Uri $adobeInstallUrl -OutFile $adobeInstallPath -UseBasicParsing

Write-Host "Install Adobe Reader DC"
# Install Adobe Reader DC:
try {
    Start-Process -FilePath "c:\deploy\AdobeReaderDC\AcroRdrDC.exe" -ArgumentList "-sfx_nu /sALL /msi EULA_ACCEPT=YES" -Wait
    if (Test-Path "C:\Program Files (x86)\Adobe\Acrobat Reader DC\Reader\AcroRd32.exe") { 
        Write-Log "SUCCESS - Adobe Reader DC Installed Successfully" 
        Write-Host "SUCCESS - Adobe Reader DC Installed Successfully" 
    }
    else { 
        write-log "ERROR - installing Adobe Reader DC" 
        Write-Host "ERROR - installing Adobe Reader DC" 
    }
}
catch {
    $ErrorMessage = $_.Exception.message
    write-log "ERROR - installing Adobe Reader DC: $ErrorMessage"
    Write-Host "ERROR - installing Adobe Reader DC: $ErrorMessage"
}
#############################################################################################
# END Region Adobe Reader DC 
#############################################################################################

#############################################################################################
# START Region Google Chrome Enterprise
############################################################################################# 
Write-Host "START Region Google Chrome Enterprise"
# Download Google Chrome Enterprise:
$chromeInstallUrl="https://tcarwvdinfrasa.blob.core.windows.net/aib-tcar-win10-21h1-prod/Google/googlechromestandaloneenterprise64-122-0-6261-1111.msi?sp=r&st=2024-03-07T20:11:53Z&se=2026-03-08T04:11:53Z&spr=https&sv=2022-11-02&sr=b&sig=vZ3Lx%2BO1HnoJyoMOTMbJ4xVlUhf4xnEgEZMo9kFiA3M%3D"
if (!(Test-Path -Path "C:\deploy\Google")) { New-Item -Path "C:\deploy" -Name "Google" -ItemType "Directory" -ErrorAction SilentlyContinue }
$chromeInstallPath = "c:\deploy\Google\googlechromestandaloneenterprise64.msi"
Invoke-WebRequest -Uri $chromeInstallUrl -OutFile $chromeInstallPath -UseBasicParsing

Write-Host "Install Google Chrome Enterprise"
# Install Google Chrome Enterprise:
try {
    Start-Process msiexec.exe -ArgumentList '/i "c:\deploy\Google\googlechromestandaloneenterprise64.msi" /norestart /qn' -wait
    if (Test-Path "C:\Program Files\Google\Chrome\Application\chrome.exe") { 
        Write-Log "SUCCESS - Google Chrome Enterprise Installed Successfully" 
        Write-Host "SUCCESS - Google Chrome Enterprise Installed Successfully" 
    }
    else { 
        write-log "ERROR - installing Google Chrome Enterprise" 
        Write-Host "ERROR - installing Google Chrome Enterprise" 
    }
}
catch {
    $ErrorMessage = $_.Exception.message
    write-log "ERROR - installing Google Chrome Enterprise: $ErrorMessage"
    Write-Host "ERROR - installing Google Chrome Enterprise: $ErrorMessage"
}
#############################################################################################
# END Region Google Chrome Enterprise
#############################################################################################

#############################################################################################
# START Region Sysprep Fixs 
# Fix for first login delays due to Windows Module Installer
#############################################################################################
try {
    ((Get-Content -path C:\DeprovisioningScript.ps1 -Raw) -replace 'Sysprep.exe /oobe /generalize /quiet /quit', 'Sysprep.exe /oobe /generalize /quit /mode:vm' ) | Set-Content -Path C:\DeprovisioningScript.ps1
    write-log "Sysprep Mode:VM fix applied"
    Write-Host "Sysprep Mode:VM fix applied"
}
catch {
    $ErrorMessage = $_.Exception.message
    write-log "Error updating script: $ErrorMessage"
    Write-Host "Error updating script: $ErrorMessage"
}
#############################################################################################
# END Region Sysprep Fixs 
#############################################################################################

#############################################################################################
# START Region Time Zone Redirection
#############################################################################################
$Name = "fEnableTimeZoneRedirection"
$value = "1"
# Add Registry value
try {
    New-ItemProperty -ErrorAction Stop -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows NT\Terminal Services" -Name $name -Value $value -PropertyType DWORD -Force
    if ((Get-ItemProperty "HKLM:\SOFTWARE\Policies\Microsoft\Windows NT\Terminal Services").PSObject.Properties.Name -contains $name) {
        Write-log "Added time zone redirection registry key"
        Write-Host "Added time zone redirection registry key"
    }
    else {
        write-log "Error locating time zone redirection registry key"
        Write-Host "Error locating time zone redirection registry key"
    }
}
catch {
    $ErrorMessage = $_.Exception.message
    write-log "Error adding time zone redirection registry KEY: $ErrorMessage"
    Write-Host "Error adding time zone redirection registry KEY: $ErrorMessage"
}
#############################################################################################
# END Region Time Zone Redirection
#############################################################################################