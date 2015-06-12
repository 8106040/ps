
#function Expand-ZIPFile($file, $destination)
# {
#   $shell = new-object -com shell.application
#   $zip = $shell.NameSpace($file)
#   foreach($item in $zip.items())
#   {
#     $shell.Namespace($destination).copyhere($item)
#   }
# }

#Get Admin rights
If (-NOT ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator"))
{   
  #No Administrative rights, it will display a popup window asking user for Admin rights
  $arguments = "& '" + $myinvocation.mycommand.definition + "'"
  Start-Process "$psHome\powershell.exe" -Verb runAs -ArgumentList $arguments
  break
}

Set-ExecutionPolicy -Scope Process -ExecutionPolicy Unrestricted -Force

#Set-ExecutionPolicy -Scope Process -ExecutionPolicy Bypass -Force

# The script has been tested on Powershell 3.0
Set-StrictMode -Version 3

# Set the output level to verbose and make the script stop on error
$VerbosePreference = "Continue"
$ErrorActionPreference = "Stop"

#Set-ExecutionPolicy -Scope Process Undefined -Force
#if ($(Get-ExecutionPolicy) -eq "Restricted")
#{
#    Set-ExecutionPolicy -Scope Process -ExecutionPolicy RemoteSigned -Force
#}

$timestamp=get-date -UFormat %y%m%d%H%M
$tfsvm="tfs" + $timestamp
$tfsstorage='tfs' + $timestamp
$tfsservice='tfs' + $timestamp
$tfslocation='East Asia'
$tfsadmin='tfsadmin'
$tfsadminpwd='P2ssw0rd'
$imgnm='fb83b3509582419d99629ce476bcb5c8__SQL-Server-2014-RTM-12.0.2048.0-Std-ENU-Win2012R2-cy15su04'
$tfsrdp='C:\'+ $tfsvm + ".rdp"

$secPassword = ConvertTo-SecureString $tfsadminpwd -AsPlainText -Force
$credential = New-Object System.Management.Automation.PSCredential($tfsadmin, $secPassword)

#if (([System.Environment]::OSVersion.Version.Major) -eq 6)
#{
#  $AdminKey = 'HKLM:\SOFTWARE\Microsoft\Active Setup\Installed Components\{A509B1A7-37EF-4b3f-8CFC-4F3A74704073}'
#  $UserKey = 'HKLM:\SOFTWARE\Microsoft\Active Setup\Installed Components\{A509B1A8-37EF-4b3f-8CFC-4F3A74704073}'
#  Set-ItemProperty -Path $AdminKey -Name 'IsInstalled' -Value 0
#  Set-ItemProperty -Path $UserKey -Name 'IsInstalled' -Value 0
  #Stop-Process -Name Explorer
#  Write-Host 'IE Enhanced Security Configuration (ESC) has been disabled.' -ForegroundColor Green
#}

Write-Verbose "Starting Chocolatey installation.."
iex ((new-object net.webclient).DownloadString('https://chocolatey.org/install.ps1'))

# Install Azure PowerShell
Write-Verbose "Starting Azure Web Platform Installer..."
choco install webpicmd -y
webpicmd /Install /Products:"Microsoft Azure Powershell" /AcceptEula

write-host "***** Please input your Subscriber ID in another window !!! *****"
write-host "!!!!! IF Error Occur, Please Reboot and Run This Script Again !!!!!" -BackgroundColor Red

#login to azure
add-azureaccount
$azuresubscriptionname = Get-azuresubscription | select SubscriptionName

#Create Storage Account
Write-Verbose "Creating Storage Account..."
New-AzureStorageAccount -StorageAccountName $tfsstorage -Location $tfslocation
Set-AzureSubscription -SubscriptionName $azuresubscriptionname.SubscriptionName -CurrentStorageAccount $tfsstorage

#Create Cloud Service
Write-Verbose "Creating Cloud Service..."
new-azureservice -ServiceName $tfsservice -Location $tfslocation

#Create Vnet


#Create VM
Write-Verbose "Creating VM..."
#Get image list you want
#$imgs = Get-AzureVMImage
#$imgs | where {$_.Label -like 'sql server*'} | select Label, RecommendedVMSize, PublishedDate | Format-Table -AutoSize
#get image name
#$imgnm = Get-AzureVMImage | where {$_.Label -eq 'SQL Server 2014 RTM Standard on Windows Server 2012 R2' -and $_.PublishedDate -eq '2015/4/15 15:00:00'} | select ImageName
New-AzureVMConfig -Name $tfsvm -InstanceSize Basic_A2 -ImageName $imgnm ` | Add-AzureProvisioningConfig -Windows -AdminUsername $tfsadmin -Password $tfsadminpwd ` | Add-AzureEndpoint -Name "tfs" -Protocol "tcp" -PublicPort 8080 -LocalPort 8080 ` | New-AzureVM -ServiceName $tfsservice -WaitForBoot

Get-AzureRemoteDesktopFile -ServiceName $tfsservice -Name $tfsvm -LocalPath $tfsrdp


#Write-Verbose 'Script Done£¡'
#Write-Verbose 'Please have your RDP in'
#Write-Host $tfsrdp
#Write-Verbose 'Please input any key to continue...'
<#
# Install the WinRM Certificate first to access the VM via Remote PS
# This REQUIRES PowerShell run Elevated
.\InstallWinRMCertAzureVM.ps1 -SubscriptionName $azuresubscriptionname.SubscriptionName -ServiceName $tfsservice -Name $tfsvm 
 
# Get the RemotePS/WinRM Uri to connect to
$uri = Get-AzureWinRMUri -ServiceName $tfsservice -Name $tfsvm
 
# Enter a remote PS session on the VM
#Enter-PSSession -ConnectionUri $uri -Credential $credential

$session = New-PSSession -ConnectionUri $uri -Credential $credential

Invoke-Command -Session $session -ScriptBlock { wget https://xhpi.blob.core.windows.net/xhpicloud/2-tfs-server-installation.ps1 -OutFile C:\script.ps1 }

$session = New-PSSession -ConnectionUri $uri -Credential $credential

Invoke-Command -Session $session -ScriptBlock { C:\script.ps1 3 }

# Could easily have used Invoke-PSCommand to execute a script on the VM for automatic 

#iex ((new-object net.webclient).DownloadString('https://chocolatey.org/install.ps1'))

#wget https://github.com/8106040/tfs2015/archive/v2.zip -OutFile C:\script.zip

#wget https://xhpi.blob.core.windows.net/xhpicloud/2-tfs-server-installation.ps1 -OutFile C:\script.ps1

#Expand-ZIPFile ¨CFile C:\script.zip -destination C:\

#C:\script.ps1 3

$tfsuri='http://' + $tfsservice + ".cloudapp.net:8080/tfs"

Start-Sleep 60

Start-Process $tfsuri
#>
break