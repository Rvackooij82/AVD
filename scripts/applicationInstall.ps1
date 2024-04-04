#############################################################################################
# PROD TTNA POOL INSTALLATION SCRIPT FOR IMAGE CREATION THROUGH AZURE IMAGE BUILDER PROCESS
#############################################################################################
#
# CREATE LOCAL FOLDERS FOR SOFTWARE AND TOOLS
# APPLICATIONS TO INSTALL:
# - 7Zip                                            (General)
# - DotNet 3.5                                      (Not sure which application requires this)
# - Microsoft 365 Apps for Enterprise + Version     (General)
# - Install Microsoft teams                         (General)
# - Adobe Reader DC                                 (General)
# - Google Chrome Enterprise                        (General)
# - Microsoft ToDo                                  (General)

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

# # Wallpaper download (GPO Applied)
# $wallpaperUrl="https://tcarwvdinfrasa.blob.core.windows.net/aib-tcar-win10-21h1-prod/trident/Wallpaper-Proof3.jpg?sv=2020-08-04&st=2021-12-08T21%3A13%3A25Z&se=2025-12-09T21%3A13%3A00Z&sr=b&sp=r&sig=c5orrNpV%2FJExVq11NZjfSDqZF4Oc972wMQXvOq8AZJc%3D"
# $wallpaperPath = "C:\_curtoso\"
# Invoke-WebRequest -Uri $wallpaperUrl -OutFile $wallpaperPath -UseBasicParsing

# # Screen saver download and extract (GPO Applied)
# $screensaverUrl="https://tcarwvdinfrasa.blob.core.windows.net/aib-tcar-win10-21h1-prod/trident/screensaver.zip?sv=2020-08-04&st=2021-12-08T21%3A14%3A31Z&se=2025-12-09T21%3A14%3A00Z&sr=b&sp=r&sig=YfbnE2tgH5buBlaUye%2B0%2BbnJc92Vib3LIJdnv6XuZOY%3D"
# $screensaverPath = "C:\deploy\screensaver.zip"
# Invoke-WebRequest -Uri $screensaverUrl -OutFile $screensaverPath -UseBasicParsing
# Expand-Archive -path "C:\deploy\screensaver.zip" -DestinationPath "C:\_trident\screensaver" 

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
$javax64downloadUrl="https://tcarwvdinfrasa.blob.core.windows.net/aib-tcar-win10-21h1-prod/Java/jre-8u391-windows-x64.exe?sp=r&st=2023-10-25T20:16:05Z&se=2025-10-26T04:16:05Z&spr=https&sv=2022-11-02&sr=b&sig=1VC1hqURcRHIlDrFTNXk7ILaeNHbtHZh7IiwvbBOrT0%3D"
if (!(Test-Path -Path "C:\deploy\java")) { New-Item -Path "C:\deploy" -Name "java" -ItemType "Directory" -ErrorAction SilentlyContinue }
$javax64InstallPath = "c:\deploy\java\jre-windows-x64.exe"
Invoke-WebRequest -Uri $javax64downloadUrl -OutFile $javax64InstallPath -UseBasicParsing
# Download Java JRE x86:
$javax86downloadUrl="https://tcarwvdinfrasa.blob.core.windows.net/aib-tcar-win10-21h1-prod/Java/jre-8u391-windows-i586.exe?sp=r&st=2023-10-25T20:15:17Z&se=2025-10-26T04:15:17Z&spr=https&sv=2022-11-02&sr=b&sig=3YZ9qFZzDEynQYWYcMdWYlg16ylSS3H9LvF5aStBM4k%3D"
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
$adobeInstallUrl="https://tcarwvdinfrasa.blob.core.windows.net/aib-tcar-win10-21h1-prod/Adobe/AcroRdrDC2300620320_en_US.exe?sv=2021-10-04&st=2023-09-18T08%3A23%3A20Z&se=2025-09-19T08%3A23%3A00Z&sr=b&sp=r&sig=7eBuFfrO4wt3knp%2Bsz2aQYhNQzv33UhByGuLEZ%2BIbsE%3D"
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
$chromeInstallUrl="https://tcarwvdinfrasa.blob.core.windows.net/aib-tcar-win10-21h1-prod/Google/GoogleChromeStandaloneEnterprise64.msi?sp=r&st=2023-11-13T15:15:25Z&se=2026-11-13T23:15:25Z&spr=https&sv=2022-11-02&sr=b&sig=%2Bo5DuTdmOWxlDuWQ47VNRAOO9Z7AS9hU9JH48gmIc2Y%3D"
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
# START Region Microsoft ToDo 2.57.43142.0
#############################################################################################
Write-Host "START Region Microsoft ToDo 2.57.43142.0"
# Download Microsoft ToDo Zip:
$ToDoUrl="https://tcarwvdinfrasa.blob.core.windows.net/aib-tcar-win10-21h1-prod/Microsoft/MicrosoftToDo.zip?sv=2021-08-06&st=2022-12-19T20%3A11%3A28Z&se=2025-12-20T20%3A11%3A00Z&sr=b&sp=r&sig=Ubf2BXZgHt3BiLCwHML%2F7Byc%2FimUHHpPOAC%2BYFPai4Q%3D"
if (!(Test-Path -Path "C:\deploy\MicrosoftToDo")) { New-Item -Path "C:\deploy" -Name "MicrosoftToDo" -ItemType "Directory" -ErrorAction SilentlyContinue }
$ToDoPath = "c:\deploy\MicrosoftToDo\MicrosoftToDo.zip"
Invoke-WebRequest -Uri $ToDoUrl -OutFile $ToDoPath -UseBasicParsing
Expand-Archive -path "c:\deploy\MicrosoftToDo\MicrosoftToDo.zip" -DestinationPath "c:\deploy\MicrosoftToDo" -Force

DISM /Online /Add-ProvisionedAppxPackage /PackagePath:c:\deploy\MicrosoftToDo\Microsoft.Todos_2.108.62932.0_neutral_~_8wekyb3d8bbwe.Msixbundle /DependencyPackagePath:c:\deploy\MicrosoftToDo\Microsoft.VCLibs.140.00_14.0.32530.0_x64__8wekyb3d8bbwe.Appx /DependencyPackagePath:c:\deploy\MicrosoftToDo\Microsoft.NET.Native.Framework.2.2_2.2.29512.0_x64__8wekyb3d8bbwe.Appx /DependencyPackagePath:c:\deploy\MicrosoftToDo\Microsoft.NET.Native.Runtime.2.2_2.2.28604.0_x64__8wekyb3d8bbwe.Appx /DependencyPackagePath:c:\deploy\MicrosoftToDo\Microsoft.UI.Xaml.2.8_8.2310.30001.0_x64__8wekyb3d8bbwe.Appx /SkipLicense /region="all"

#############################################################################################
# END Region Microsoft ToDo 2.57.43142.0
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