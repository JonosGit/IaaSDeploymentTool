<#
.SYNOPSIS
Written By John Lewis
email: jonos@live.com
Ver 6.11
This script provides the following functionality for deploying IaaS environments in Azure. The script will deploy VNET in addition to numerour Market Place VMs or make use of an existing VNETs.
The script supports dual homed servers (PFSense/Checkpoint/FreeBSD/F5/Barracuda)
The script allows select of subnet prior to VM Deployment
The script supports deploying Availability Sets as well as adding new servers to existing Availability Sets through the -AvailabilitySet "True" and -AvailSetName switches.
The script will generate a name for azure storage endpoint unless the -StorageName variable is updated or referenced at runtime.

v6.11 updates - Modified Prodile to save to script execution directory, added -help switch.
v6.0 updates - Added Remove Functions to script, added subnet correction validation for static IPs and Storage
v5.9 updates - Moved -add parameters to [switch]
v5.8 updates - Updated UI to align with .Sourcing
v5.71 updates - HF Provisioning Function
v5.7 updates - .Sourcing Functions Now Supported
v5.6 updates - Added Ability to upload custom scripts to blob for use by VM
v5.5 updates - Logic Checking for Extensions
v5.4 updates - Aligned Syntax with User Guide
v5.3 updates - Added Puppet Agent and OMS Agents to Extensions
v5.2 updates - Moved VNET configuration to global parameters
v5.1 updates - Added VPN Creation Function
v5.0 updates - Added Alias' to command parameters
v4.9 updates - additional validation functions, note changes to AddVNET and NSGEnabled field types (was string now bool)
v4.8 updates - Added F5/Barracuda as well as Bitnami images
v4.7 updates - Added Step Logging
v4.6 Updates - Added Support for F5, Barracuda, SAP and Solar Winds
v4.5 Updates - Fixes for Azure PowerShell 2.1

.DESCRIPTION
Deploys 30 different Market Images on a new or existing VNET. Supports post deployment configuration through Azure Extensions.
Market Images supported: Redhat 6.7 and 7.2, PFSense 2.5, Windows 2008 R2, Windows 2012 R2, Ubuntu 14.04, CentOs 7.2, SUSE, SQL 2016 (on W2K12R2), R Server on Windows, Windows 2016 (Preview), Checkpoint Firewall, FreeBsd, Oracle Linux, Puppet, Splunk, Oracle Web-Logic, Oracle DB, Bitnami Lamp, Bitnami PostGresSql, Bitnami nodejs, Bitnami Elastics, Bitnami MySql, SharePoint 2013/2016, Barracuda NG, Barracuda SPAM, F5 BigIP, F5 App Firewall, SAP, Solar Winds, Bitnami JRuby, Bitnami Neos, Bitnami TomCat, Bitnami redis, Bitnami hadoop

.PARAMETER vmMarketImage

.PARAMETER AddVnet

.PARAMETER VMName

.PARAMETER rg

.PARAMETER vnetrg

.PARAMETER VNetName

.PARAMETER ConfigIPs

.PARAMETER VMSize

.PARAMETER locadmin

.PARAMETER locpassword

.PARAMETER NSGEnabled

.PARAMETER Location

.PARAMETER SubscriptionID

.PARAMETER TenantID

.PARAMETER GenerateName

.PARAMETER StorageName

.PARAMETER StorageType

.PARAMETER InterfaceName1

.PARAMETER InterfaceName2

.PARAMETER NSGName

.PARAMETER Subnet1

.PARAMETER Subnet2

.PARAMETER AddAvailabilitySet

.PARAMETER AvailSetName

.PARAMETER DNLabel

.PARAMETER AddFQDN

.PARAMETER PvtIPNic1

.PARAMETER PvtIPNic2

.PARAMETER AddVPN

.PARAMETER LocalNetPip

.PARAMETER LocalAddPrefix

.PARAMETER AddRange

.PARAMETER SubnetAddPrefix1

.PARAMETER SubnetNameAddPrefix1

.PARAMETER SubnetAddPrefix2

.PARAMETER SubnetNameAddPrefix2

.PARAMETER SubnetAddPrefix3

.PARAMETER SubnetNameAddPrefix3

.PARAMETER SubnetAddPrefix4

.PARAMETER SubnetNameAddPrefix4

.PARAMETER SubnetAddPrefix5

.PARAMETER SubnetNameAddPrefix5

.PARAMETER SubnetAddPrefix6

.PARAMETER SubnetNameAddPrefix6

.PARAMETER SubnetAddPrefix7

.PARAMETER SubnetNameAddPrefix7

.PARAMETER SubnetAddPrefix8

.PARAMETER SubnetNameAddPrefix8

.PARAMETER Azautoacct

.PARAMETER AzExtConfig

.PARAMETER RemoveObject

.PARAMETER Help

.EXAMPLE
\.azdeploy.ps1 -vm pf001 -image pfsense -rg ResGroup1 -vnetrg ResGroup2 -addvnet -vnet VNET -sub1 3 -sub2 4 -ConfigIPs DualPvtNoPub -Nic1 10.120.2.7 -Nic2 10.120.3.7
.EXAMPLE
\.azdeploy.ps1 -vm red76 -image red67 -rg ResGroup1 -vnetrg ResGroup2 -vnet VNET -sub1 7 -ConfigIPs SinglePvtNoPub -Nic1 10.120.6.124 -Ext linuxbackup
.EXAMPLE
\.azdeploy.ps1 -vm win006 -image w2k12 -rg ResGroup1 -vnetrg ResGroup2 -vnet VNE T-sub1 2 -ConfigIPs Single -AvSet $True -NSGEnabled $True -NSGName NSG
.EXAMPLE
\.azdeploy.ps1 -vm win008 -image w2k16 -rg ResGroup1 -vnetrg ResGroup2 -vnet VNET -sub1 5 -ConfigIPs PvtSingleStat -Nic1 10.120.4.169 -AddFQDN -fqdn mydns1
.EXAMPLE
\.azdeploy.ps1 -vm ubu001 -image ubuntu -RG ResGroup1 -vnetrg ResGroup2 -VNet VNET -sub1 6 -ConfigIPs PvtSingleStat -Nic1 10.120.5.169 -AddFQDN fqdn mydns2
.EXAMPLE
\.azdeploy.ps1 -vm ubu001 -RG ResGroup1 -RemoveObject VM
.EXAMPLE
\.azdeploy.ps1 -RG ResGroup1 -RemoveObject rg
.NOTES
-ConfigIps  <Configuration>
			PvtSingleStat & PvtDualStat – Deploys the server with a Public IP and the private IP(s) specified by the user.
			NoPubSingle & NoPubDual - Deploys the server without Public IP using automatically generated private IP(s).
			Single & Dual – Deploys the default configuration of a Public IP and automatically generated private IP(s).
			StatPvtNoPubDual & StatPvtNoPubSingle – Deploys the server without a Public IP using the private IP(s) specified by the user.
-VMMarketImage <Image ShortName>
			Redhat 6.7 – Red67
			Redhat7.2 – Red72
			Windows 2012 R2 – w2k12
			PFSense 2.5 – pfsense
			Free BSD – free
			Suse – suse
			CentOs 7.2 – cent
			Ubuntu 14.04 – ubuntu
			SQL Server 2016 (on Windows 2012 host) – sql2016
			MySql – mysql
			CheckPoint – check
			Windows 2008 R2 – w2k8
			Windows 2016 – w2k16
			Chef v12 - chef
			Bitnami LampStack - lamp
			Bitnami MySql - mysql
			Bitnami NodeJs - node
			Bitnami Elastics Search - elastics
			Bitnami Jenkins - jenkins
			Bitnami PostGresSql - postgressql
			Bitnami Git Lab - gitlab
			Bitnami Redis - redis
			Bitnami Hadoop - hadoop
			Bitnami Tom-Cat - tomcat
			Bitnami jRubyStack - jruby
			Bitnami neos - neos
			Puppet Enterprise - puppet
			Solar Winds - solarwinds
			F5 BIG IP - f5bigip
			F5 Application Firewall - f5appfire
			Barracuda NG Firewall (hourly) - barrahourngfw
			Barracuda NG Firewall (BYOL) - barrabyolngfw
			Barracuda spam Firewall (hourly) - barrahourspam
			Barracuda spam Firewall (byol) - barrabyolspam
			SharePoint 2016 - Share2016
			SharePoint 2013 - share2013
			Server R - serverr

-AzExtConfig <Extension Type>
			access – Adds Azure Access Extension – Added by default during VM creation
			msav – Adds Azure Antivirus Extension
			custScript – Adds Custom Script for Execution (Requires Table Storage Configuration first)
			diag – Adds Azure Diagnostics Extension
			linuxOsPatch - Deploy Latest updates for Linux platforms
			linuxbackup - Deploys Azure Linux bacup Extension
			addDom – Adds Azure Domain Join Extension
			chef – Adds Azure Chef Extension (Requires Chef Certificate and Settings info first)
			opsinsightLinux - OMS Agent
			opsinsightWin - OMS Agent
			eset - File Security Ext
			WinPuppet - Puppet Agent Install for Windows
.LINK
https://github.com/JonosGit/IaaSDeploymentTool
https://github.com/JonosGit/IaaSDeploymentTool/blob/master/The%20IaaS%20Deployment%20Tool%20User%20Guide.pdf
#>

[CmdletBinding()]
Param(
[Parameter(Mandatory=$False,ValueFromPipelinebyPropertyName=$true,Position=1)]
[ValidateNotNullorEmpty()]
[ValidateSet("w2k12","w2k8","red67","red72","suse","free","ubuntu","centos","w2k16","sql2016","chef","check","pfsense","lamp","jenkins","nodejs","elastics","postgressql","splunk","puppet","serverr","solarwinds","f5bigip","f5appfire","barrahourngfw","barrabyolngfw","barrahourspam","barrabyolspam","mysql","share2013","share2016","mongodb","nginxstack","hadoop","neos","tomcat","redis","gitlab","jruby")]
[Alias("image")]
[string]
$vmMarketImage = 'w2k12',
[Parameter(Mandatory=$False,ValueFromPipelinebyPropertyName=$true,Position=0)]
[ValidateNotNullorEmpty()]
[Alias("vm")]
[string]
$VMName = '',
[ValidateNotNullorEmpty()]
[Parameter(Mandatory=$False,ValueFromPipelinebyPropertyName=$true,Position=2)]
[string]
$rg = '',
[Parameter(Mandatory=$False,ValueFromPipelinebyPropertyName=$true)]
[ValidateNotNullorEmpty()]
[string]
$vnetrg = '',
[Parameter(Mandatory=$False,ValueFromPipelinebyPropertyName=$true)]
[switch]
$AddVnet,
[Parameter(Mandatory=$False,ValueFromPipelinebyPropertyName=$true)]
[Alias("vnet")]
[string]
$VNetName = '',
[Parameter(Mandatory=$False,ValueFromPipelinebyPropertyName=$true)]
[ValidateSet("Single","Dual","NoPubDual","PvtDualStat","StatPvtNoPubSingle","PvtSingleStat","StatPvtNoPubDual","NoPubSingle")]
[ValidateNotNullorEmpty()]
[string]
$ConfigIPs = '',
[Parameter(Mandatory=$False,ValueFromPipelinebyPropertyName=$true)]
[Alias("nsg")]
[switch]
$NSGEnabled,
[Parameter(Mandatory=$False,ValueFromPipelinebyPropertyName=$true)]
[ValidateSet("vm","vnet","rg","nsg","extension","storage","availabilityset")]
[string]
$RemoveObject = '',
[Parameter(Mandatory=$False,ValueFromPipelinebyPropertyName=$true)]
[ValidateNotNullorEmpty()]
[ValidateSet("Standard_A3","Standard_A4","Standard_A2")]
[string]
$VMSize = 'Standard_A3',
[Parameter(Mandatory=$False,ValueFromPipelinebyPropertyName=$true)]
[ValidateNotNullorEmpty()]
[string]
$locadmin = 'localadmin',
[Parameter(Mandatory=$false,ValueFromPipelinebyPropertyName=$true)]
[ValidateNotNullorEmpty()]
[string]
$locpassword = 'P@ssW0rd!',
[Parameter(Mandatory=$False,ValueFromPipelinebyPropertyName=$true)]
[ValidateNotNullorEmpty()]
[string]
$Location = 'WestUs',
[Parameter(Mandatory=$False,ValueFromPipelinebyPropertyName=$true)]
[string]
$SubscriptionID = '',
[Parameter(Mandatory=$False,ValueFromPipelinebyPropertyName=$true)]
[string]
$TenantID = '',
[Parameter(Mandatory=$False)]
[string]
$GenerateName = -join ((65..90) + (97..122) | Get-Random -Count 6 | % {[char]$_}) + "aip",
[Parameter(Mandatory=$False)]
[string]
$StorageName = $VMName + 'str',
[Parameter(Mandatory=$False,ValueFromPipelinebyPropertyName=$true)]
[ValidateSet("Standard_LRS","Standard_GRS")]
[string]
$StorageType = 'Standard_GRS',
[Parameter(Mandatory=$False,ValueFromPipelinebyPropertyName=$true)]
[ValidateNotNullorEmpty()]
[Alias("int1")]
[string]
$InterfaceName1 = $VMName + '_nic1',
[Parameter(Mandatory=$False,ValueFromPipelinebyPropertyName=$true)]
[Alias("int2")]
[string]
$InterfaceName2 = $VMName + "_nic2",
[Parameter(Mandatory=$False,ValueFromPipelinebyPropertyName=$true)]
[ValidateNotNullorEmpty()]
[string]
$NSGName = '',
[Parameter(Mandatory=$False,ValueFromPipelinebyPropertyName=$true)]
[ValidateRange(1,8)]
[Alias("sub1")]
[Int]
$Subnet1 = $global:Subnet1,
[Parameter(Mandatory=$False,ValueFromPipelinebyPropertyName=$true)]
[ValidateRange(1,8)]
[ValidateNotNullorEmpty()]
[Alias("sub2")]
[int]
$Subnet2 = $global:Subnet2,
[Parameter(Mandatory=$False,ValueFromPipelinebyPropertyName=$true)]
[ValidateSet("True","False")]
[Alias("avset")]
[switch]
$AddAvailabilitySet,
[Parameter(Mandatory=$False,ValueFromPipelinebyPropertyName=$true)]
[string]
$AvailSetName = $GenerateName,
[Parameter(Mandatory=$False,ValueFromPipelinebyPropertyName=$true)]
[Alias("fqdn")]
[string]
$DNLabel = 'mytesr1',
[Parameter(Mandatory=$False,ValueFromPipelinebyPropertyName=$true)]
[switch]
$AddFQDN,
[Parameter(Mandatory=$False,ValueFromPipelinebyPropertyName=$true)]
[ValidateNotNullorEmpty()]
[Alias("nic1")]
$PvtIPNic1 = '10.10.0.0',
[Parameter(Mandatory=$False,ValueFromPipelinebyPropertyName=$true)]
[ValidateNotNullorEmpty()]
[Alias("nic2")]
$PvtIPNic2 = '10.10.0.0',
[Parameter(Mandatory=$False,ValueFromPipelinebyPropertyName=$true)]
[string]
$AddVPN = $False,
[Parameter(Mandatory=$False,ValueFromPipelinebyPropertyName=$true)]
[ipaddress]
$LocalNetPip = "207.21.2.1",
[Parameter(Mandatory=$False,ValueFromPipelinebyPropertyName=$true)]
[string]
$LocalAddPrefix = "10.10.0.0/24",
[Parameter(Mandatory=$False,ValueFromPipelinebyPropertyName=$true)]
[string]
$AddRange = '10.120.0.0/21',
[Parameter(Mandatory=$False,ValueFromPipelinebyPropertyName=$true)]
[string]
$SubnetAddPrefix1 = "10.120.0.0/25",
[Parameter(Mandatory=$False,ValueFromPipelinebyPropertyName=$true)]
[string]
$SubnetNameAddPrefix1 = "gatewaysubnet",
[Parameter(Mandatory=$False,ValueFromPipelinebyPropertyName=$true)]
[string]
$SubnetAddPrefix2 = "10.120.0.128/25",
[Parameter(Mandatory=$False,ValueFromPipelinebyPropertyName=$true)]
[string]
$SubnetNameAddPrefix2 = 'perimeter',
[Parameter(Mandatory=$False,ValueFromPipelinebyPropertyName=$true)]
[string]
$SubnetAddPrefix3 = "10.120.1.0/24",
[Parameter(Mandatory=$False,ValueFromPipelinebyPropertyName=$true)]
[string]
$SubnetNameAddPrefix3 = "data",
[Parameter(Mandatory=$False,ValueFromPipelinebyPropertyName=$true)]
[string]
$SubnetAddPrefix4 = "10.120.2.0/24",
[Parameter(Mandatory=$False,ValueFromPipelinebyPropertyName=$true)]
[string]
$SubnetNameAddPrefix4 = "monitor",
[Parameter(Mandatory=$False,ValueFromPipelinebyPropertyName=$true)]
[string]
$SubnetAddPrefix5 = "10.120.3.0/24",
[Parameter(Mandatory=$False,ValueFromPipelinebyPropertyName=$true)]
[string]
$SubnetNameAddPrefix5 = "reporting",
[Parameter(Mandatory=$False,ValueFromPipelinebyPropertyName=$true)]
[string]
$SubnetAddPrefix6 = "10.120.4.0/24",
[Parameter(Mandatory=$False,ValueFromPipelinebyPropertyName=$true)]
[string]
$SubnetNameAddPrefix6 = "analytics",
[Parameter(Mandatory=$False,ValueFromPipelinebyPropertyName=$true)]
[string]
$SubnetAddPrefix7 = "10.120.5.0/24",
[Parameter(Mandatory=$False,ValueFromPipelinebyPropertyName=$true)]
[string]
$SubnetNameAddPrefix7 = "management",
[Parameter(Mandatory=$False,ValueFromPipelinebyPropertyName=$true)]
[string]
$SubnetAddPrefix8 = "10.120.6.0/24",
[Parameter(Mandatory=$False,ValueFromPipelinebyPropertyName=$true)]
[string]
$SubnetNameAddPrefix8 = "deployment",
[Parameter(Mandatory=$False,ValueFromPipelinebyPropertyName=$true)]
[string]
$Azautoacct = "DSC-Auto",
[Parameter(Mandatory=$False,ValueFromPipelinebyPropertyName=$true)]
[string]
$Profile = "profile",
[Parameter(Mandatory=$False,ValueFromPipelinebyPropertyName=$true)]
[ValidateSet("diag","msav","access","linuxbackup","chefagent","eset","customscript","opsinsightLinux","opsinsightWin","WinPuppet","domjoin","RegisterAzDSC")]
[Alias("ext")]
[string]
$AzExtConfig = 'diag',
[Parameter(Mandatory=$False,ValueFromPipelinebyPropertyName=$true)]
[Alias("addext")]
[switch]
$AddExtension,
[Parameter(Mandatory=$False,ValueFromPipelinebyPropertyName=$true)]
[ValidateSet("True","False")]
[Alias("upload")]
[string]
$CustomScriptUpload = 'False',
[Parameter(Mandatory=$False,ValueFromPipelinebyPropertyName=$true)]
[Alias("customscriptname")]
[string]
$scriptname = 'WFirewall.ps1',
[Parameter(Mandatory=$False,ValueFromPipelinebyPropertyName=$true)]
[string]
$containername = 'scripts',
[Parameter(Mandatory=$False,ValueFromPipelinebyPropertyName=$true)]
[string]
$customextname = 'customscript',
[Parameter(Mandatory=$False,ValueFromPipelinebyPropertyName=$true)]
[string]
$scriptfolder = "C:\Temp",
[Parameter(Mandatory=$False,ValueFromPipelinebyPropertyName=$true)]
[string]
$localfolder = "$scriptfolder\customscripts",
[Parameter(Mandatory=$False,ValueFromPipelinebyPropertyName=$true)]
[ValidateSet("network","vm","summary","extension")]
[string]
$infoset = 'network',
[Parameter(Mandatory=$False,ValueFromPipelinebyPropertyName=$true)]
[switch]
$getinfo,
[Parameter(Mandatory=$False,ValueFromPipelinebyPropertyName=$true)]
[Alias("h")]
[Alias("?")]
[switch]
$help
)

$SecureLocPassword=Convertto-SecureString $locpassword –asplaintext -Force
$Credential1 = New-Object System.Management.Automation.PSCredential ($locadmin,$SecureLocPassword)

Function validate-profile {
$comparedate = (Get-Date).AddDays(-14)
$fileexist = Test-Path $ProfileFile -NewerThan $comparedate
  if($fileexist)
  {
  Select-AzureRmProfile -Path $ProfileFile | Out-Null
  }
  else
  {
  Write-Host "Please enter your credentials"
  Add-AzureRmAccount
  Save-AzureRmProfile -Path $ProfileFile -Force
  Write-Host "Saved Profile to $ProfileFile"
  exit
  }
}

Function Help-User {
Write-Host "Don't know where to start? Here are some examples:"
Write-Host "                                                       "
Write-Host "Deploy PFSense"
Write-Host "azurerm_deploy.ps1 -vm pf001 -image pfsense -rg ResGroup1 -vnetrg ResGroup2 -vnet VNET -ConfigIPs DualPvtNoPub -Nic1 10.120.2.7 -Nic2 10.120.3.7"
Write-Host "Deploy RedHat"
Write-Host "azurerm_deploy.ps1 -vm red76 -image red67 -rg ResGroup1 -vnetrg ResGroup2 -vnet VNET -ConfigIPs SinglePvtNoPub -Nic1 10.120.6.124 -Ext linuxbackup"
Write-Host "Deploy Windows 2012"
Write-Host "azurerm_deploy.ps1 -vm win006 -image w2k12 -rg ResGroup1 -vnetrg ResGroup2 -vnet VNET -ConfigIPs Single -AvSet -NSGEnabled -NSGName NSG"
Write-Host "Deploy Windows 2016"
Write-Host "azurerm_deploy.ps1 -vm win008 -image w2k16 -rg ResGroup1 -vnetrg ResGroup2 -vnet VNET -ConfigIPs PvtSingleStat -Nic1 10.120.4.169"
Write-Host "Deploy Ubuntu"
Write-Host "azurerm_deploy.ps1 -vm ubu001 -image ubuntu -RG ResGroup1 -vnetrg ResGroup2 -VNet VNET -ConfigIPs PvtSingleStat -Nic1 10.120.5.169 -AddFQDN fqdn mydns2"
Write-Host "Remove VM:"
Write-Host "azurerm_deploy.ps1 -vm ubu001 -RG ResGroup1 -RemoveObject VM"
Write-Host "Remove RG:"
Write-Host "azurerm_deploy.ps1 -RG ResGroup1 -RemoveObject rg"
Write-Host "                                                       "
Write-Host "Required command switches"
Write-Host "              -vmname - Name of VM to create"
Write-Host "              -configips - configures network interfaces"
Write-Host "              -VMMarketImage - Image type to deploy"
Write-Host "              -rg - Resource Group"
Write-Host "              -vnetrg - VNET Resource Group"
Write-Host "              -vnetname - VNET Name"
Write-Host "                                                       "
Write-Host "Important command switches"
Write-Host "             -addvnet - adds new VNET"
Write-Host "             -nsgenabled - adds new NSG/Configures VM to use existing NSG"
Write-Host "             -addavailabilityset - adds new Availability Set"
Write-Host "             -addfqdn - adds FQDN to Public IP address of VM"
Write-Host "             -addextension - adds VM extension"
Write-Host "                                                       "
}

Function Log-Command ([string]$Description, [string]$logFile, [string]$VMName){
$Output = $LogOut+'. '
Write-Host $Output -ForegroundColor white
((Get-Date -UFormat "[%d-%m-%Y %H:%M:%S] ") + $Output) | Out-File -FilePath $LogOutFile -Append -Force
}

Function VerifyPvtIp {
if($PvtIPNic1)
	{
	[int]$subnet = $Subnet1
	$ip = $PvtIPNic1
	$array = $ip.Split(".")
	[int]$subnetint = $array[2]
	[int]$subnetcalc = ($subnetint + 1)
if($subnetcalc -ne $subnet){
$global:Subnet1 = $subnetcalc
Write-Host "Updating Subnet1 to correct subnet"
Write-Host "Subnet1: $global:Subnet1"
}
else
{
Write-Host "correct subnet"
$global:Subnet1 = $Subnet1
}
}
}

Function VerifyPvtIp2 {
if($PvtIPNic2)
	{
	[int]$subnet = $Subnet2
	$ip = $PvtIPNic2
	$array = $ip.Split(".")
	[int]$subnetint = $array[2]
	[int]$subnetcalc = ($subnetint + 1)
if($subnetcalc -ne $subnet){
$global:Subnet2 = $subnetcalc
Write-Host "Updating Subnet2 to correct subnet"
Write-Host "Subnet1: $global:Subnet2"
}
else
{
Write-Host "correct subnet"
$global:Subnet2 = $Subnet2
}
}
}

Function VerifyNicValue1 {
if($PvtIPNic1.Length -le 7) {Write-Host "Invalid IP"
exit
}
}

Function VerifyNicValue2 {
if($PvtIPNic1.Length -le 7) {Write-Host "Invalid IP"
exit
}
}

Function VerifyNet {
If ($ConfigIPs -eq "StatPvtNoPubSingle")
{ Write-Host "Subnet IP Validation" -ForegroundColor White
VerifyPvtIp
}
If ($ConfigIPs -eq "StatPvtNoPubDual")
{ Write-Host "Subnet IP Validation" -ForegroundColor White
VerifyPvtIp
VerifyPvtIp2
}
If ($ConfigIPs -eq "Single")
{ Write-Host "Skipping Subnet IP Validation"
if($Subnet1 -le 2)
{$subnet1 = 2}
$global:Subnet1 = $Subnet1
}

If ($ConfigIPs -eq "Dual")
{ Write-Host "Skipping Subnet IP Validation"
if($Subnet1 -le 2){$subnet1 = 2}
if($Subnet2 -le 2){$subnet2 = 2}
$global:Subnet1 = $Subnet1
$global:Subnet2 = $Subnet2
}
If ($ConfigIPs -eq "PvtSingleStat")
{ Write-Host "Subnet IP Validation"
VerifyPvtIp
}
If ($ConfigIPs -eq "PvtDualStat")
{ Write-Host "Subnet IP Validation"
VerifyPvtIp
VerifyPvtIp2
}
}

function chknull {
if(!$vmMarketImage) {
Write-Host "Please Enter vmMarketImage"
exit }
	elseif(!$VMName) {
	Write-Host "Please Enter vmName"
	exit}
		elseif(!$VNetName) {
		Write-Host "Please Enter vNet Name"
		exit}
			elseif(!$rg) {
			Write-Host "Please Enter Resource Group Name"
			exit}
				elseif(!$Location) {
				Write-Host "Please Enter Location"
				exit}
					elseif(!$ConfigIPs) {
					Write-Host "Please Enter IP Configuration"
					exit }
}

Function PubIPconfig {
	param(
	[string]$vnetrg = $vnetrg,
	[string]$Location = $Location,
	[string]$rg = $rg,
	[string]$InterfaceName1 = $InterfaceName1,
	[string]$DNLabel = $DNLabel
	)
if($AddFQDN)
{
$global:PIp = New-AzureRmPublicIpAddress -Name $InterfaceName1 -ResourceGroupName $rg -Location $Location -AllocationMethod "Dynamic" -DomainNameLabel $DNLabel –Confirm:$false -WarningAction SilentlyContinue
$LogOut = "Completed Public DNS record creation $DNLabel.$Location.cloudapp.azure.com"
Log-Command -Description $LogOut -LogFile $LogOutFile
}
else
{
$global:PIp = New-AzureRmPublicIpAddress -Name $InterfaceName1 -ResourceGroupName $rg -Location $Location -AllocationMethod "Dynamic" –Confirm:$false -WarningAction SilentlyContinue
}
}

Function PubDNSconfig {
if($AddFQDN)
{
Write-Host "Creating FQDN: " $DNLabel.$Location.cloudapp.azure.com
}
else
{
Write-Host "No DNS Name Specified"
}
}
Function StorageNameCheck
{
	param(
		[string]$StorageName  = $StorageName
	)
$checkname =  Get-AzureRmStorageAccountNameAvailability -Name $StorageName | Select-Object -ExpandProperty NameAvailable
if($checkname -ne 'True') {
Write-Host "Storage Account Name in use, generating random name for storage..."
Start-Sleep 5
$global:StorageNameVerified = $GenerateName.ToLower()
Write-Host $StorageNameVerified
}
else
{
$global:StorageNameVerified = $StorageName.ToLower()
Write-Host $StorageNameVerified
 }
}
Function ConfigNet {
	param(
	[string]$vnetrg = $vnetrg,
	[string]$Location = $Location,
	[string]$rg = $rg,
	[string]$InterfaceName1 = $InterfaceName1,
	[string]$InterfaceName2 = $InterfaceName2,
	[int]$Subnet1 = $global:Subnet1,
	[int]$Subnet2 = $global:Subnet2,
	[ipaddress]$PvtIPNic1 = $PvtIPNic1,
	[ipaddress]$PvtIPNic2 = $PvtIPNic2,
	[string]$ConfigIps = $ConfigIps
	)
switch ($ConfigIPs)
	{
		"PvtDualStat" {
Write-Host "Dual IP Configuration - Static"
PubIPconfig
$global:VNet = Get-AzureRMVirtualNetwork -Name $VNetName -ResourceGroupName $vnetrg | Set-AzureRmVirtualNetwork
$global:Interface1 = New-AzureRmNetworkInterface -Name $InterfaceName1 -ResourceGroupName $rg -Location $Location -SubnetId $VNet.Subnets[$Subnet1].Id -PublicIpAddressId $PIp.Id -PrivateIpAddress $PvtIPNic1 –Confirm:$false -WarningAction SilentlyContinue
$global:Interface2 = New-AzureRmNetworkInterface -Name $InterfaceName2 -ResourceGroupName $rg -Location $Location -SubnetId $VNet.Subnets[$Subnet2].Id -PrivateIpAddress $PvtIPNic2 –Confirm:$false -WarningAction SilentlyContinue
}
		"PvtSingleStat" {
Write-Host "Single IP Configuration - Static"
PubIPconfig
$global:VNet = Get-AzureRMVirtualNetwork -Name $VNetName -ResourceGroupName $vnetrg | Set-AzureRmVirtualNetwork
$global:Interface1 = New-AzureRmNetworkInterface -Name $InterfaceName1 -ResourceGroupName $rg -Location $Location -SubnetId $VNet.Subnets[$Subnet1].Id -PublicIpAddressId $PIp.Id -PrivateIpAddress $PvtIPNic1 –Confirm:$false -WarningAction SilentlyContinue
}
		"StatPvtNoPubDual" {
Write-Host "Dual IP Configuration- Static - No Public"
$global:VNet = Get-AzureRMVirtualNetwork -Name $VNetName -ResourceGroupName $vnetrg | Set-AzureRmVirtualNetwork
$global:Interface1 = New-AzureRmNetworkInterface -Name $InterfaceName1 -ResourceGroupName $rg -Location $Location -SubnetId $VNet.Subnets[$Subnet1].Id -PrivateIpAddress $PvtIPNic1 –Confirm:$false -WarningAction SilentlyContinue
$global:Interface2 = New-AzureRmNetworkInterface -Name $InterfaceName2 -ResourceGroupName $rg -Location $Location -SubnetId $VNet.Subnets[$Subnet2].Id -PrivateIpAddress $PvtIPNic2 –Confirm:$false -WarningAction SilentlyContinue
}
		"StatPvtNoPubSingle" {
Write-Host "Single IP Configuration - Static - No Public"
$global:VNet = Get-AzureRMVirtualNetwork -Name $VNetName -ResourceGroupName $vnetrg | Set-AzureRmVirtualNetwork
$global:Interface1 = New-AzureRmNetworkInterface -Name $InterfaceName1 -ResourceGroupName $rg -Location $Location -SubnetId $VNet.Subnets[$Subnet1].Id -PrivateIpAddress $PvtIPNic1 –Confirm:$false -WarningAction SilentlyContinue
}
		"Single" {
Write-Host "Default Single IP Configuration"
PubIPconfig
$global:VNet = Get-AzureRMVirtualNetwork -Name $VNetName -ResourceGroupName $vnetrg | Set-AzureRmVirtualNetwork
$global:Interface1 = New-AzureRmNetworkInterface -Name $InterfaceName1 -ResourceGroupName $rg -Location $Location -SubnetId $VNet.Subnets[$Subnet1].Id -PublicIpAddressId $PIp.Id –Confirm:$false -WarningAction SilentlyContinue
}
		"Dual" {
Write-Host "Default Dual IP Configuration"
PubIPconfig
$global:VNet = Get-AzureRMVirtualNetwork -Name $VNetName -ResourceGroupName $vnetrg | Set-AzureRmVirtualNetwork
$global:Interface1 = New-AzureRmNetworkInterface -Name $InterfaceName1 -ResourceGroupName $rg -Location $Location -SubnetId $VNet.Subnets[$Subnet1].Id -PublicIpAddressId $PIp.Id –Confirm:$false -WarningAction SilentlyContinue
$global:Interface2 = New-AzureRmNetworkInterface -Name $InterfaceName2 -ResourceGroupName $rg -Location $Location -SubnetId $VNet.Subnets[$Subnet2].Id –Confirm:$false -WarningAction SilentlyContinue
}
		"NoPubSingle" {
Write-Host "Single IP - No Public"
$global:VNet = Get-AzureRMVirtualNetwork -Name $VNetName -ResourceGroupName $vnetrg | Set-AzureRmVirtualNetwork
$global:Interface1 = New-AzureRmNetworkInterface -Name $InterfaceName1 -ResourceGroupName $rg -Location $Location -SubnetId $VNet.Subnets[$Subnet1].Id –Confirm:$false -WarningAction SilentlyContinue
}
		"NoPubDual" {
Write-Host "Dual IP - No Public"
$global:VNet = Get-AzureRMVirtualNetwork -Name $VNetName -ResourceGroupName $vnetrg | Set-AzureRmVirtualNetwork
$global:Interface1 = New-AzureRmNetworkInterface -Name $InterfaceName1 -ResourceGroupName $rg -Location $Location -SubnetId $VNet.Subnets[$Subnet1].Id –Confirm:$false -WarningAction SilentlyContinue
$global:Interface2 = New-AzureRmNetworkInterface -Name $InterfaceName2 -ResourceGroupName $rg -Location $Location -SubnetId $VNet.Subnets[$Subnet2].Id –Confirm:$false -WarningAction SilentlyContinue
}
		default{"Nothing matched entry criteria"}
}
}

Function AddNICs {
Write-Host "Adding 2 Network Interface(s) $InterfaceName1 $InterfaceName2" -ForegroundColor White
$global:VirtualMachine = Add-AzureRmVMNetworkInterface -VM $VirtualMachine -Id $global:Interface1.Id -Primary -WarningAction SilentlyContinue
$global:VirtualMachine = Add-AzureRmVMNetworkInterface -VM $VirtualMachine -Id $global:Interface2.Id -WarningAction SilentlyContinue
$LogOut = "Completed adding NICs"
Log-Command -Description $LogOut -LogFile $LogOutFile
}

Function AddNIC {
Write-Host "Adding Network Interface $InterfaceName1" -ForegroundColor White
$global:VirtualMachine = Add-AzureRmVMNetworkInterface -VM $VirtualMachine -Id $global:Interface1.Id -Primary -WarningAction SilentlyContinue
$LogOut = "Completed adding NIC"
Log-Command -Description $LogOut -LogFile $LogOutFile
}

Function ConfigSet {
switch  ($ConfigIPs)
	{
		"PvtDualStat" {
AddNICs
}
		"PvtSingleStat" {
AddNIC
}
		"StatPvtNoPubDual" {
AddNICs
}
		"StatPvtNoPubSingle" {
AddNIC
}
		"Single" {
AddNIC
}
		"Dual" {
AddNICs
}
		"NoPubSingle" {
AddNIC
}
		"NoPubDual" {
AddNICs
}
		default{"An unsupported network configuration was referenced"
		break
					}
}
}
Function NSGEnabled
{
if($NSGEnabled){
$nic1 = Get-AzureRmNetworkInterface -Name $InterfaceName1 -ResourceGroupName $rg -ErrorAction SilentlyContinue
$nic2 = Get-AzureRmNetworkInterface -Name $InterfaceName2 -ResourceGroupName $rg -ErrorAction SilentlyContinue
if($nic1)
{
$nsg = Get-AzureRmNetworkSecurityGroup -ResourceGroupName $vnetrg -Name $NSGName
$nic = Get-AzureRmNetworkInterface -ResourceGroupName $rg -Name $InterfaceName1
$nic.NetworkSecurityGroup = $nsg
Set-AzureRmNetworkInterface -NetworkInterface $nic | Out-Null
$LogOut = "Completed Image NSG Post Configuration. Added $InterfaceName1 to $NSGName"
Log-Command -Description $LogOut -LogFile $LogOutFile
}
if($nic2)
{
$nsg = Get-AzureRmNetworkSecurityGroup -ResourceGroupName $vnetrg -Name $NSGName
$nic = Get-AzureRmNetworkInterface -ResourceGroupName $rg -Name $InterfaceName2
$nic.NetworkSecurityGroup = $nsg
Set-AzureRmNetworkInterface -NetworkInterface $nic | Out-Null
$secrules = Get-AzureRmNetworkSecurityGroup -Name $NSGName -ResourceGroupName $vnetrg | Get-AzureRmNetworkSecurityRuleConfig | Ft Name,Description,Direction,SourcePortRange,DestinationPortRange,DestinationPortRange,SourceAddressPrefix,Access | Format-Table | Out-Null
$defsecrules = Get-AzureRmNetworkSecurityGroup -Name $NSGName -ResourceGroupName $vnetrg | Get-AzureRmNetworkSecurityRuleConfig -DefaultRules | Format-Table | Out-Null
$LogOut = "Completed Image NSG Post Configuration. Added $InterfaceName2 to $NSGName"
Log-Command -Description $LogOut -LogFile $LogOutFile
}
}
}
Function CreateVPN {
Write-Host "VPN Creation can take up to 45 minutes!"
New-AzureRmLocalNetworkGateway -Name LocalSite -ResourceGroupName $vnetrg -Location $Location -GatewayIpAddress $LocalNetPip -AddressPrefix $LocalAddPrefix -ErrorAction Stop -WarningAction SilentlyContinue | Out-Null
Write-Host "Completed Local Network GW Creation"
$vpnpip= New-AzureRmPublicIpAddress -Name vpnpip -ResourceGroupName $vnetrg -Location $Location -AllocationMethod Dynamic -ErrorAction Stop -WarningAction SilentlyContinue
$vnet = Get-AzureRmVirtualNetwork -Name $VNetName -ResourceGroupName $vnetrg -ErrorAction Stop -WarningAction SilentlyContinue
$subnet = Get-AzureRmVirtualNetworkSubnetConfig -Name 'GatewaySubnet' -VirtualNetwork $vnet -WarningAction SilentlyContinue
$vpnipconfig = New-AzureRmVirtualNetworkGatewayIpConfig -Name vpnipconfig1 -SubnetId $subnet.Id -PublicIpAddressId $vpnpip.Id -WarningAction SilentlyContinue
New-AzureRmVirtualNetworkGateway -Name vnetvpn1 -ResourceGroupName $vnetrg -Location $Location -IpConfigurations $vpnipconfig -GatewayType Vpn -VpnType RouteBased -GatewaySku Standard -ErrorAction Stop -WarningAction SilentlyContinue | Out-Null
Write-Host "Completed VNET Network GW Creation"
Get-AzureRmPublicIpAddress -Name vpnpip -ResourceGroupName $rg -WarningAction SilentlyContinue
Write-Host "Configure Local Device with Azure VNET vpn Public IP"
}
Function ConnectVPN {
[PSObject]$gateway1 = Get-AzureRmVirtualNetworkGateway -Name vnetvpn1 -ResourceGroupName $vnetrg -WarningAction SilentlyContinue
[PSObject]$local = Get-AzureRmLocalNetworkGateway -Name LocalSite -ResourceGroupName $vnetrg -WarningAction SilentlyContinue
New-AzureRmVirtualNetworkGatewayConnection -ConnectionType IPSEC  -Name sitetosite -ResourceGroupName $vnetrg -Location $Location -VirtualNetworkGateway1 $gateway1 -LocalNetworkGateway2 $local -SharedKey '4321avfe' -Verbose -Force -RoutingWeight 10 -WarningAction SilentlyContinue| Out-Null
}
Function SelectNicDescrtipt {
if($ConfigIPs-EQ "Dual"){Write-Host "Dual Pvt IP & Public IP will be created" }
	elseif($ConfigIPs-EQ "Single"){Write-Host "Single Pvt IP & Public IP will be created" }
		elseif($ConfigIPs-EQ "PvtDualStat"){Write-Host "Dual Static Pvt IP & Public IP will be created" }
			elseif($ConfigIPs-EQ"PvtSingleStat"){Write-Host "Single Static Pvt IP & Public IP will be created" }
				elseif($ConfigIPs-EQ "SinglePvtNoPub"){Write-Host "Single Static Pvt IP & No Public IP" }
					elseif($ConfigIPs-EQ "StatPvtNoPubDual"){Write-Host "Dual Static Pvt IP & No Public IP"}
						elseif($ConfigIPs-EQ "StatPvtNoPubSingle"){Write-Host "Single Static Pvt IP & No Public IP"}
							elseif($ConfigIPs-EQ "NoPubDual"){Write-Host "Dual Pvt IP & No Public IP"}
	else {
	Write-Host "No Network Config Found - Warning" -ForegroundColor Red
	}
}

Function RegisterRP {
	Param(
		[string]$ResourceProviderNamespace
	)

	# Write-Host "Registering resource provider '$ResourceProviderNamespace'";
	Register-AzureRmResourceProvider -ProviderNamespace $ResourceProviderNamespace –Confirm:$false -WarningAction SilentlyContinue | Out-Null;
}

Function AvailSet {
	param(
		[string]$rg = $rg,
		[string]$Location = $Location,
		[string]$AvailSetName = $AvailSetName
)
 try {
 If ($AddAvailabilitySet)
 {
 Write-Host "Availability Set configuration in process.." -ForegroundColor White
New-AzureRmAvailabilitySet -ResourceGroupName $rg -Name $AvailSetName -Location $Location -WarningAction SilentlyContinue | Out-Null
$AddAvailabilitySet = (Get-AzureRmAvailabilitySet -ResourceGroupName $rg -Name $AvailSetName).Id
$global:VirtualMachine = New-AzureRmVMConfig -VMName $VMName -VMSize $VMSize -AvailabilitySetID $AddAvailabilitySet -WarningAction SilentlyContinue
Write-Host "Availability Set has been configured" -ForegroundColor White
$LogOut = "Completed Availability Set configuration $AvailSetName"
Log-Command -Description $LogOut -LogFile $LogOutFile
}
else
{
Write-Host "Skipping Availability Set configuration" -ForegroundColor White
$global:VirtualMachine = New-AzureRmVMConfig -VMName $VMName -VMSize $VMSize -WarningAction SilentlyContinue
$LogOut = "Skipped Availability Set Configuration"
Log-Command -Description $LogOut -LogFile $LogOutFile
}
	}

catch {
	Write-Host -foregroundcolor Red `
	"$($_.Exception.Message)"; `
	break
}
 }

 function Provvms {
	 param (
	[string]$rg = $rg,
	[string]$Location = $Location
	 )
	$ProvisionVMs = @($VirtualMachine);
try {
   foreach($provisionvm in $ProvisionVMs) {
		New-AzureRmVM -ResourceGroupName $rg -Location $Location -VM $VirtualMachine –Confirm:$false -WarningAction SilentlyContinue | Out-Null
		$LogOut = "Completed Creation of $VMName from $vmMarketImage"
		Log-Command -Description $LogOut -LogFile $LogOutFile
						}
	}
catch {
	Write-Host -foregroundcolor Red `
	"$($_.Exception.Message)"; `
	break
}
	 }

Function AddDiskImage {
Write-Host "Completing image creation..." -ForegroundColor White
$global:osDiskCaching = "ReadWrite"
$global:OSDiskName = $VMName + "OSDisk"
$global:OSDiskUri = $StorageAccount.PrimaryEndpoints.Blob.ToString() + "vhds/" + $OSDiskName + ".vhd"
$global:VirtualMachine = Set-AzureRmVMOSDisk -VM $VirtualMachine -Name $OSDiskName -VhdUri $OSDiskUri -CreateOption "FromImage" -Caching $osDiskCaching -WarningAction SilentlyContinue
}

Function MakeImagePlanInfo_Bitnami_Lamp {
param(
	[string]$VMName = $VMName,
	[string]$Publisher = 'bitnami',
	[string]$offer = 'lampstack',
	[string]$Skus = '5-6',
	[string]$version = 'latest',
	[string]$Product = 'lampstack',
	[string]$name = '5-6'
)
Write-Host "Image Creation in Process - Plan Info - LampStack" -ForegroundColor White
Write-Host 'Publisher:'$Publisher 'Offer:'$offer 'Sku:'$Skus 'Version:'$version
$global:VirtualMachine= Set-AzureRmVMPlan -VM $VirtualMachine -Name $name -Publisher $Publisher -Product $Product
$global:VirtualMachine = Set-AzureRmVMOperatingSystem -VM $VirtualMachine -linux -ComputerName $VMName -Credential $Credential1
$global:VirtualMachine = Set-AzureRmVMSourceImage -VM $VirtualMachine -PublisherName $Publisher -Offer $offer -Skus $Skus -Version $version
$LogOut = "Completed image prep 'Publisher:'$Publisher 'Offer:'$offer 'Sku:'$Skus 'Version:'$version"
Log-Command -Description $LogOut -LogFile $LogOutFile
}
Function MakeImagePlanInfo_Bitnami_elastic {
param(
	[string]$VMName = $VMName,
	[string]$Publisher = 'bitnami',
	[string]$offer = 'elastic-search',
	[string]$Skus = '2-2',
	[string]$version = 'latest',
	[string]$Product = 'elastic-search',
	[string]$name = '2-2'
)
Write-Host "Image Creation in Process - Plan Info - Elastic Search" -ForegroundColor White
Write-Host 'Publisher:'$Publisher 'Offer:'$offer 'Sku:'$Skus 'Version:'$version
$global:VirtualMachine= Set-AzureRmVMPlan -VM $VirtualMachine -Name $name -Publisher $Publisher -Product $Product
$global:VirtualMachine = Set-AzureRmVMOperatingSystem -VM $VirtualMachine -linux -ComputerName $VMName -Credential $Credential1
$global:VirtualMachine = Set-AzureRmVMSourceImage -VM $VirtualMachine -PublisherName $Publisher -Offer $offer -Skus $Skus -Version $version
}
Function MakeImagePlanInfo_Bitnami_jenkins {
param(
	[string]$VMName = $VMName,
	[string]$Publisher = 'bitnami',
	[string]$offer = 'jenkins',
	[string]$Skus = '1-650',
	[string]$version = 'latest',
	[string]$Product = 'jenkins',
	[string]$name = '1-650'
)
Write-Host "Image Creation in Process - Plan Info - Jenkins" -ForegroundColor White
Write-Host 'Publisher:'$Publisher 'Offer:'$offer 'Sku:'$Skus 'Version:'$version
$global:VirtualMachine= Set-AzureRmVMPlan -VM $VirtualMachine -Name $name -Publisher $Publisher -Product $Product
$global:VirtualMachine = Set-AzureRmVMOperatingSystem -VM $VirtualMachine -linux -ComputerName $VMName -Credential $Credential1
$global:VirtualMachine = Set-AzureRmVMSourceImage -VM $VirtualMachine -PublisherName $Publisher -Offer $offer -Skus $Skus -Version $version
}

Function MakeImagePlanInfo_Microsoft_ServerR {
param(
	[string]$VMName = $VMName,
	[string]$Publisher = 'microsoft-r-products',
	[string]$offer = 'microsoft-r-server',
	[string]$Skus = 'msr80-win2012r2',
	[string]$version = 'latest',
	[string]$Product = 'microsoft-r-server',
	[string]$name = 'msr80-win2012r2'
)
Write-Host "Image Creation in Process - Plan Info - Microsoft R Server" -ForegroundColor White
Write-Host 'Publisher:'$Publisher 'Offer:'$offer 'Sku:'$Skus 'Version:'$version
$global:VirtualMachine= Set-AzureRmVMPlan -VM $VirtualMachine -Name $name -Publisher $Publisher -Product $Product
$global:VirtualMachine = Set-AzureRmVMOperatingSystem -VM $VirtualMachine -Windows -ComputerName $VMName -Credential $Credential1
$global:VirtualMachine = Set-AzureRmVMSourceImage -VM $VirtualMachine -PublisherName $Publisher -Offer $offer -Skus $Skus -Version $version
}
Function MakeImagePlanInfo_Bitnami_tomcat {
param(
	[string]$VMName = $VMName,
	[string]$Publisher = 'bitnami',
	[string]$offer = 'tom-cat',
	[string]$Skus = '7-0',
	[string]$version = 'latest',
	[string]$Product = 'tom-cat',
	[string]$name = '7-0'
)
Write-Host "Image Creation in Process - Plan Info - Tom-Cat" -ForegroundColor White
Write-Host 'Publisher:'$Publisher 'Offer:'$offer 'Sku:'$Skus 'Version:'$version
$global:VirtualMachine= Set-AzureRmVMPlan -VM $VirtualMachine -Name $name -Publisher $Publisher -Product $Product
$global:VirtualMachine = Set-AzureRmVMOperatingSystem -VM $VirtualMachine -linux -ComputerName $VMName -Credential $Credential1
$global:VirtualMachine = Set-AzureRmVMSourceImage -VM $VirtualMachine -PublisherName $Publisher -Offer $offer -Skus $Skus -Version $version
}

Function MakeImagePlanInfo_Bitnami_redis {
param(
	[string]$VMName = $VMName,
	[string]$Publisher = 'bitnami',
	[string]$offer = 'redis',
	[string]$Skus = '3-2',
	[string]$version = 'latest',
	[string]$Product = 'redis',
	[string]$name = '3-2'
)
Write-Host "Image Creation in Process - Plan Info - Redis"
Write-Host 'Publisher:'$Publisher 'Offer:'$offer 'Sku:'$Skus 'Version:'$version
$global:VirtualMachine= Set-AzureRmVMPlan -VM $VirtualMachine -Name $name -Publisher $Publisher -Product $Product
$global:VirtualMachine = Set-AzureRmVMOperatingSystem -VM $VirtualMachine -linux -ComputerName $VMName -Credential $Credential1
$global:VirtualMachine = Set-AzureRmVMSourceImage -VM $VirtualMachine -PublisherName $Publisher -Offer $offer -Skus $Skus -Version $version
}
Function MakeImagePlanInfo_Bitnami_neos {
param(
	[string]$VMName = $VMName,
	[string]$Publisher = 'bitnami',
	[string]$offer = 'neos',
	[string]$Skus = '2-0',
	[string]$version = 'latest',
	[string]$Product = 'neos',
	[string]$name = '2-0'
)
Write-Host "Image Creation in Process - Plan Info - neos"
Write-Host 'Publisher:'$Publisher 'Offer:'$offer 'Sku:'$Skus 'Version:'$version
$global:VirtualMachine= Set-AzureRmVMPlan -VM $VirtualMachine -Name $name -Publisher $Publisher -Product $Product
$global:VirtualMachine = Set-AzureRmVMOperatingSystem -VM $VirtualMachine -linux -ComputerName $VMName -Credential $Credential1
$global:VirtualMachine = Set-AzureRmVMSourceImage -VM $VirtualMachine -PublisherName $Publisher -Offer $offer -Skus $Skus -Version $version
}
Function MakeImagePlanInfo_Bitnami_hadoop {
param(
	[string]$VMName = $VMName,
	[string]$Publisher = 'bitnami',
	[string]$offer = 'hadoop',
	[string]$Skus = '2-7',
	[string]$version = 'latest',
	[string]$Product = 'hadoop',
	[string]$name = '2-7'
)
Write-Host "Image Creation in Process - Plan Info - hadoop"
Write-Host 'Publisher:'$Publisher 'Offer:'$offer 'Sku:'$Skus 'Version:'$version
$global:VirtualMachine= Set-AzureRmVMPlan -VM $VirtualMachine -Name $name -Publisher $Publisher -Product $Product
$global:VirtualMachine = Set-AzureRmVMOperatingSystem -VM $VirtualMachine -linux -ComputerName $VMName -Credential $Credential1
$global:VirtualMachine = Set-AzureRmVMSourceImage -VM $VirtualMachine -PublisherName $Publisher -Offer $offer -Skus $Skus -Version $version
}
Function MakeImagePlanInfo_Bitnami_gitlab {
param(
	[string]$VMName = $VMName,
	[string]$Publisher = 'bitnami',
	[string]$offer = 'gitlab',
	[string]$Skus = '8-5',
	[string]$version = 'latest',
	[string]$Product = 'gitlab',
	[string]$name = '8-5'
)
Write-Host "Image Creation in Process - Plan Info - gitlab"
Write-Host 'Publisher:'$Publisher 'Offer:'$offer 'Sku:'$Skus 'Version:'$version
$global:VirtualMachine= Set-AzureRmVMPlan -VM $VirtualMachine -Name $name -Publisher $Publisher -Product $Product
$global:VirtualMachine = Set-AzureRmVMOperatingSystem -VM $VirtualMachine -linux -ComputerName $VMName -Credential $Credential1
$global:VirtualMachine = Set-AzureRmVMSourceImage -VM $VirtualMachine -PublisherName $Publisher -Offer $offer -Skus $Skus -Version $version
}
Function MakeImagePlanInfo_Bitnami_jrubystack {
param(
	[string]$VMName = $VMName,
	[string]$Publisher = 'bitnami',
	[string]$offer = 'jrubystack',
	[string]$Skus = '9-0',
	[string]$version = 'latest',
	[string]$Product = 'jrubystack',
	[string]$name = '9-0'
)
Write-Host "Image Creation in Process - Plan Info - jrubystack"
Write-Host 'Publisher:'$Publisher 'Offer:'$offer 'Sku:'$Skus 'Version:'$version
$global:VirtualMachine= Set-AzureRmVMPlan -VM $VirtualMachine -Name $name -Publisher $Publisher -Product $Product
$global:VirtualMachine = Set-AzureRmVMOperatingSystem -VM $VirtualMachine -linux -ComputerName $VMName -Credential $Credential1
$global:VirtualMachine = Set-AzureRmVMSourceImage -VM $VirtualMachine -PublisherName $Publisher -Offer $offer -Skus $Skus -Version $version
}

Function MakeImagePlanInfo_Bitnami_mongodb {
param(
	[string]$VMName = $VMName,
	[string]$Publisher = 'bitnami',
	[string]$offer = 'mongodb',
	[string]$Skus = '3-2',
	[string]$version = 'latest',
	[string]$Product = 'mongodb',
	[string]$name = '3-2'
)
Write-Host "Image Creation in Process - Plan Info - MongoDb" -ForegroundColor White
Write-Host 'Publisher:'$Publisher 'Offer:'$offer 'Sku:'$Skus 'Version:'$version
$global:VirtualMachine= Set-AzureRmVMPlan -VM $VirtualMachine -Name $name -Publisher $Publisher -Product $Product
$global:VirtualMachine = Set-AzureRmVMOperatingSystem -VM $VirtualMachine -linux -ComputerName $VMName -Credential $Credential1
$global:VirtualMachine = Set-AzureRmVMSourceImage -VM $VirtualMachine -PublisherName $Publisher -Offer $offer -Skus $Skus -Version $version
}
Function MakeImagePlanInfo_Bitnami_mysql {
param(
	[string]$VMName = $VMName,
	[string]$Publisher = 'bitnami',
	[string]$offer = 'mysql',
	[string]$Skus = '5-6',
	[string]$version = 'latest',
	[string]$Product = 'mysql',
	[string]$name = '5-6'
)
Write-Host "Image Creation in Process - Plan Info - MySql" -ForegroundColor White
Write-Host 'Publisher:'$Publisher 'Offer:'$offer 'Sku:'$Skus 'Version:'$version
$global:VirtualMachine= Set-AzureRmVMPlan -VM $VirtualMachine -Name $name -Publisher $Publisher -Product $Product
$global:VirtualMachine = Set-AzureRmVMOperatingSystem -VM $VirtualMachine -linux -ComputerName $VMName -Credential $Credential1
$global:VirtualMachine = Set-AzureRmVMSourceImage -VM $VirtualMachine -PublisherName $Publisher -Offer $offer -Skus $Skus -Version $version
$LogOut = "Completed image prep 'Publisher:'$Publisher 'Offer:'$offer 'Sku:'$Skus 'Version:'$version"
Log-Command -Description $LogOut -LogFile $LogOutFile
}
Function MakeImagePlanInfo_Bitnami_nginxstack {
param(
	[string]$VMName = $VMName,
	[string]$Publisher = 'bitnami',
	[string]$offer = 'nginxstack',
	[string]$Skus = '1-9',
	[string]$version = 'latest',
	[string]$Product = 'nginxstack',
	[string]$name = '1-9'
)
Write-Host "Image Creation in Process - Plan Info - Nginxstack" -ForegroundColor White
Write-Host 'Publisher:'$Publisher 'Offer:'$offer 'Sku:'$Skus 'Version:'$version
$global:VirtualMachine= Set-AzureRmVMPlan -VM $VirtualMachine -Name $name -Publisher $Publisher -Product $Product
$global:VirtualMachine = Set-AzureRmVMOperatingSystem -VM $VirtualMachine -linux -ComputerName $VMName -Credential $Credential1
$global:VirtualMachine = Set-AzureRmVMSourceImage -VM $VirtualMachine -PublisherName $Publisher -Offer $offer -Skus $Skus -Version $version
$LogOut = "Completed image prep 'Publisher:'$Publisher 'Offer:'$offer 'Sku:'$Skus 'Version:'$version"
Log-Command -Description $LogOut -LogFile $LogOutFile
}
Function MakeImagePlanInfo_Bitnami_nodejs {
param(
	[string]$VMName = $VMName,
	[string]$Publisher = 'bitnami',
	[string]$offer = 'nodejs',
	[string]$Skus = '4-3',
	[string]$version = 'latest',
	[string]$Product = 'nodejs',
	[string]$name = '4-3'
)
Write-Host "Image Creation in Process - Plan Info - Nodejs" -ForegroundColor White
Write-Host 'Publisher:'$Publisher 'Offer:'$offer 'Sku:'$Skus 'Version:'$version
$global:VirtualMachine= Set-AzureRmVMPlan -VM $VirtualMachine -Name $name -Publisher $Publisher -Product $Product
$global:VirtualMachine = Set-AzureRmVMOperatingSystem -VM $VirtualMachine -linux -ComputerName $VMName -Credential $Credential1
$global:VirtualMachine = Set-AzureRmVMSourceImage -VM $VirtualMachine -PublisherName $Publisher -Offer $offer -Skus $Skus -Version $version
$LogOut = "Completed image prep 'Publisher:'$Publisher 'Offer:'$offer 'Sku:'$Skus 'Version:'$version"
Log-Command -Description $LogOut -LogFile $LogOutFile
}
Function MakeImagePlanInfo_Bitnami_postgresql {
param(
	[string]$VMName = $VMName,
	[string]$Publisher = 'bitnami',
	[string]$offer = 'postgresql',
	[string]$Skus = '9-5',
	[string]$version = 'latest',
	[string]$Product = 'postgresql',
	[string]$name = '9-5'
)
Write-Host "Image Creation in Process - Plan Info - postgresql" -ForegroundColor White
Write-Host 'Publisher:'$Publisher 'Offer:'$offer 'Sku:'$Skus 'Version:'$version
$global:VirtualMachine= Set-AzureRmVMPlan -VM $VirtualMachine -Name $name -Publisher $Publisher -Product $Product
$global:VirtualMachine = Set-AzureRmVMOperatingSystem -VM $VirtualMachine -linux -ComputerName $VMName -Credential $Credential1
$global:VirtualMachine = Set-AzureRmVMSourceImage -VM $VirtualMachine -PublisherName $Publisher -Offer $offer -Skus $Skus -Version $version
$LogOut = "Completed image prep 'Publisher:'$Publisher 'Offer:'$offer 'Sku:'$Skus 'Version:'$version"
Log-Command -Description $LogOut -LogFile $LogOutFile
}
Function MakeImagePlanInfo_Oracle_linux {
param(
	[string]$VMName = $VMName,
	[string]$Publisher = 'Oracle',
	[string]$offer = 'Oracle-Linux',
	[string]$Skus = '7.2',
	[string]$version = 'latest',
	[string]$Product = 'Oracle-Linux',
	[string]$name = '7.2'
)
Write-Host "Image Creation in Process - Plan Info - Oracle Linux" -ForegroundColor White
Write-Host 'Publisher:'$Publisher 'Offer:'$offer 'Sku:'$Skus 'Version:'$version
$global:VirtualMachine= Set-AzureRmVMPlan -VM $VirtualMachine -Name $name -Publisher $Publisher -Product $Product
$global:VirtualMachine = Set-AzureRmVMOperatingSystem -VM $VirtualMachine -linux -ComputerName $VMName -Credential $Credential1
$global:VirtualMachine = Set-AzureRmVMSourceImage -VM $VirtualMachine -PublisherName $Publisher -Offer $offer -Skus $Skus -Version $version
$LogOut = "Completed image prep 'Publisher:'$Publisher 'Offer:'$offer 'Sku:'$Skus 'Version:'$version"
Log-Command -Description $LogOut -LogFile $LogOutFile
}
Function MakeImagePlanInfo_Oracle_weblogic {
param(
	[string]$VMName = $VMName,
	[string]$Publisher = 'Oracle',
	[string]$offer = 'Oracle-WebLogic-server',
	[string]$Skus = 'Oracle-WebLogic-Server',
	[string]$version = 'latest',
	[string]$Product = 'Oracle-WebLogic-Server',
	[string]$name = 'Oracle-WebLogic-Server'
)
Write-Host "Image Creation in Process - Plan Info - Oracle WebLogic" -ForegroundColor White
Write-Host 'Publisher:'$Publisher 'Offer:'$offer 'Sku:'$Skus 'Version:'$version
$global:VirtualMachine= Set-AzureRmVMPlan -VM $VirtualMachine -Name $name -Publisher $Publisher -Product $Product
$global:VirtualMachine = Set-AzureRmVMOperatingSystem -VM $VirtualMachine -linux -ComputerName $VMName -Credential $Credential1
$global:VirtualMachine = Set-AzureRmVMSourceImage -VM $VirtualMachine -PublisherName $Publisher -Offer $offer -Skus $Skus -Version $version
$LogOut = "Completed image prep 'Publisher:'$Publisher 'Offer:'$offer 'Sku:'$Skus 'Version:'$version"
Log-Command -Description $LogOut -LogFile $LogOutFile
}
Function MakeImagePlanInfo_Oracle_EntDB {
param(
	[string]$VMName = $VMName,
	[string]$Publisher = 'Oracle',
	[string]$offer = 'Oracle-database-Ee',
	[string]$Skus = '12.1.0.2',
	[string]$version = 'latest',
	[string]$Product = '12.1.0.2',
	[string]$name = 'Oracle-database-Ee'
)
Write-Host "Image Creation in Process - Plan Info - Oracle Enterprise Edition" -ForegroundColor White
Write-Host 'Publisher:'$Publisher 'Offer:'$offer 'Sku:'$Skus 'Version:'$version
$global:VirtualMachine= Set-AzureRmVMPlan -VM $VirtualMachine -Name $name -Publisher $Publisher -Product $Product
$global:VirtualMachine = Set-AzureRmVMOperatingSystem -VM $VirtualMachine -linux -ComputerName $VMName -Credential $Credential1
$global:VirtualMachine = Set-AzureRmVMSourceImage -VM $VirtualMachine -PublisherName $Publisher -Offer $offer -Skus $Skus -Version $version
$LogOut = "Completed image prep 'Publisher:'$Publisher 'Offer:'$offer 'Sku:'$Skus 'Version:'$version"
Log-Command -Description $LogOut -LogFile $LogOutFile
}
Function MakeImagePlanInfo_Oracle_StdDB {
param(
	[string]$VMName = $VMName,
	[string]$Publisher = 'Oracle',
	[string]$offer = 'Oracle-database-Se',
	[string]$Skus = '12.1.0.2',
	[string]$version = 'latest',
	[string]$Product = '12.1.0.2',
	[string]$name = 'Oracle-database-Se'
)
Write-Host "Image Creation in Process - Plan Info - Oracle Standard Edition" -ForegroundColor White
Write-Host 'Publisher:'$Publisher 'Offer:'$offer 'Sku:'$Skus 'Version:'$version
$global:VirtualMachine= Set-AzureRmVMPlan -VM $VirtualMachine -Name $name -Publisher $Publisher -Product $Product
$global:VirtualMachine = Set-AzureRmVMOperatingSystem -VM $VirtualMachine -linux -ComputerName $VMName -Credential $Credential1
$global:VirtualMachine = Set-AzureRmVMSourceImage -VM $VirtualMachine -PublisherName $Publisher -Offer $offer -Skus $Skus -Version $version
$LogOut = "Completed image prep 'Publisher:'$Publisher 'Offer:'$offer 'Sku:'$Skus 'Version:'$version"
Log-Command -Description $LogOut -LogFile $LogOutFile
}
Function MakeImagePlanInfo_SAP_ase {
param(
	[string]$VMName = $VMName,
	[string]$Publisher = 'sap',
	[string]$offer = 'ase',
	[string]$Skus = 'ase_hourly',
	[string]$version = 'latest',
	[string]$Product = 'ase_hourly',
	[string]$name = 'ase'
)
Write-Host "Image Creation in Process - Plan Info - SAP - ASE" -ForegroundColor White
Write-Host 'Publisher:'$Publisher 'Offer:'$offer 'Sku:'$Skus 'Version:'$version
$global:VirtualMachine= Set-AzureRmVMPlan -VM $VirtualMachine -Name $name -Publisher $Publisher -Product $Product
$global:VirtualMachine = Set-AzureRmVMOperatingSystem -VM $VirtualMachine -linux -ComputerName $VMName -Credential $Credential1
$global:VirtualMachine = Set-AzureRmVMSourceImage -VM $VirtualMachine -PublisherName $Publisher -Offer $offer -Skus $Skus -Version $version
$LogOut = "Completed image prep 'Publisher:'$Publisher 'Offer:'$offer 'Sku:'$Skus 'Version:'$version"
Log-Command -Description $LogOut -LogFile $LogOutFile
}

Function MakeImagePlanInfo_puppet_puppetent {
param(
	[string]$VMName = $VMName,
	[string]$Publisher = 'Puppet',
	[string]$offer = 'Puppet-Enterprise',
	[string]$Skus = '2016-1',
	[string]$version = 'latest',
	[string]$Product = '2016-1',
	[string]$name = 'Puppet-Enterprise'
)
Write-Host "Image Creation in Process - Plan Info - Puppet Enterprise" -ForegroundColor White
Write-Host 'Publisher:'$Publisher 'Offer:'$offer 'Sku:'$Skus 'Version:'$version
$global:VirtualMachine= Set-AzureRmVMPlan -VM $VirtualMachine -Name $name -Publisher $Publisher -Product $Product
$global:VirtualMachine = Set-AzureRmVMOperatingSystem -VM $VirtualMachine -linux -ComputerName $VMName -Credential $Credential1
$global:VirtualMachine = Set-AzureRmVMSourceImage -VM $VirtualMachine -PublisherName $Publisher -Offer $offer -Skus $Skus -Version $version
$LogOut = "Completed image prep 'Publisher:'$Publisher 'Offer:'$offer 'Sku:'$Skus 'Version:'$version"
Log-Command -Description $LogOut -LogFile $LogOutFile
}
Function MakeImagePlanInfo_splunk {
param(
	[string]$VMName = $VMName,
	[string]$Publisher = 'Splunk',
	[string]$offer = 'splunk-enterprise-base-image',
	[string]$Skus = 'splunk-on-ubuntu-14-04-lts',
	[string]$version = 'latest',
	[string]$Product = 'splunk-on-ubuntu-14-04-lts',
	[string]$name = 'splunk-enterprise-base-image'
)
Write-Host "Image Creation in Process - Plan Info - Puppet Enterprise" -ForegroundColor White
Write-Host 'Publisher:'$Publisher 'Offer:'$offer 'Sku:'$Skus 'Version:'$version
$global:VirtualMachine= Set-AzureRmVMPlan -VM $VirtualMachine -Name $name -Publisher $Publisher -Product $Product
$global:VirtualMachine = Set-AzureRmVMOperatingSystem -VM $VirtualMachine -linux -ComputerName $VMName -Credential $Credential1
$global:VirtualMachine = Set-AzureRmVMSourceImage -VM $VirtualMachine -PublisherName $Publisher -Offer $offer -Skus $Skus -Version $version
$LogOut = "Completed image prep 'Publisher:'$Publisher 'Offer:'$offer 'Sku:'$Skus 'Version:'$version"
Log-Command -Description $LogOut -LogFile $LogOutFile
}
Function MakeImagePlanInfo_SolarWinds {
param(
	[string]$VMName = $VMName,
	[string]$Publisher = 'solarwinds',
	[string]$offer = 'solarwinds-database-performance-analyzer',
	[string]$Skus = 'dpa-byol',
	[string]$version = 'latest',
	[string]$Product = 'solarwinds-database-performance-analyzer',
	[string]$name = 'dpa-byol'
)
Write-Host "Image Creation in Process - Plan Info - SolarWinds" -ForegroundColor White
Write-Host 'Publisher:'$Publisher 'Offer:'$offer 'Sku:'$Skus 'Version:'$version
$global:VirtualMachine= Set-AzureRmVMPlan -VM $VirtualMachine -Name $name -Publisher $Publisher -Product $Product
$global:VirtualMachine = Set-AzureRmVMOperatingSystem -VM $VirtualMachine -linux -ComputerName $VMName -Credential $Credential1
$global:VirtualMachine = Set-AzureRmVMSourceImage -VM $VirtualMachine -PublisherName $Publisher -Offer $offer -Skus $Skus -Version $version
$LogOut = "Completed image prep 'Publisher:'$Publisher 'Offer:'$offer 'Sku:'$Skus 'Version:'$version"
Log-Command -Description $LogOut -LogFile $LogOutFile
}

Function MakeImagePlanInfo_Barracuda_ng_firewall_hourly {
param(
	[string]$VMName = $VMName,
	[string]$Publisher = 'Barracudanetworks',
	[string]$offer = 'barracuda-ng-firewall',
	[string]$Skus = 'hourly',
	[string]$version = 'latest',
	[string]$Product = 'barracuda-ng-firewall',
	[string]$name = 'hourly'
)
Write-Host "Image Creation in Process - Plan Info - Barracuda Firewall " -ForegroundColor White
Write-Host 'Publisher:'$Publisher 'Offer:'$offer 'Sku:'$Skus 'Version:'$version
$global:VirtualMachine= Set-AzureRmVMPlan -VM $VirtualMachine -Name $name -Publisher $Publisher -Product $Product
$global:VirtualMachine = Set-AzureRmVMOperatingSystem -VM $VirtualMachine -linux -ComputerName $VMName -Credential $Credential1
$global:VirtualMachine = Set-AzureRmVMSourceImage -VM $VirtualMachine -PublisherName $Publisher -Offer $offer -Skus $Skus -Version $version
$LogOut = "Completed image prep 'Publisher:'$Publisher 'Offer:'$offer 'Sku:'$Skus 'Version:'$version"
Log-Command -Description $LogOut -LogFile $LogOutFile
}

Function MakeImagePlanInfo_Barracuda_ng_firewall_byol {
param(
	[string]$VMName = $VMName,
	[string]$Publisher = 'Barracudanetworks',
	[string]$offer = 'barracuda-ng-firewall',
	[string]$Skus = 'byol',
	[string]$version = 'latest',
	[string]$Product = 'barracuda-ng-firewall',
	[string]$name = 'byol'
)
Write-Host "Image Creation in Process - Plan Info - Barracuda NG Firewall " -ForegroundColor White
Write-Host 'Publisher:'$Publisher 'Offer:'$offer 'Sku:'$Skus 'Version:'$version
$global:VirtualMachine= Set-AzureRmVMPlan -VM $VirtualMachine -Name $name -Publisher $Publisher -Product $Product
$global:VirtualMachine = Set-AzureRmVMOperatingSystem -VM $VirtualMachine -linux -ComputerName $VMName -Credential $Credential1
$global:VirtualMachine = Set-AzureRmVMSourceImage -VM $VirtualMachine -PublisherName $Publisher -Offer $offer -Skus $Skus -Version $version
$LogOut = "Completed image prep 'Publisher:'$Publisher 'Offer:'$offer 'Sku:'$Skus 'Version:'$version"
Log-Command -Description $LogOut -LogFile $LogOutFile
}

Function MakeImagePlanInfo_Barracuda_spam_firewall_byol {
param(
	[string]$VMName = $VMName,
	[string]$Publisher = 'Barracudanetworks',
	[string]$offer = 'barracuda-spam-firewall',
	[string]$Skus = 'byol',
	[string]$version = 'latest',
	[string]$Product = 'barracuda-spam-firewall',
	[string]$name = 'byol'
)
Write-Host "Image Creation in Process - Plan Info - Barracuda SPAM Firewall " -ForegroundColor White
Write-Host 'Publisher:'$Publisher 'Offer:'$offer 'Sku:'$Skus 'Version:'$version
$global:VirtualMachine= Set-AzureRmVMPlan -VM $VirtualMachine -Name $name -Publisher $Publisher -Product $Product
$global:VirtualMachine = Set-AzureRmVMOperatingSystem -VM $VirtualMachine -linux -ComputerName $VMName -Credential $Credential1
$global:VirtualMachine = Set-AzureRmVMSourceImage -VM $VirtualMachine -PublisherName $Publisher -Offer $offer -Skus $Skus -Version $version
$LogOut = "Completed image prep 'Publisher:'$Publisher 'Offer:'$offer 'Sku:'$Skus 'Version:'$version"
Log-Command -Description $LogOut -LogFile $LogOutFile
}

Function MakeImagePlanInfo_Barracuda_spam_firewall_hourly {
param(
	[string]$VMName = $VMName,
	[string]$Publisher = 'Barracudanetworks',
	[string]$offer = 'barracuda-spam-firewall',
	[string]$Skus = 'hourly',
	[string]$version = 'latest',
	[string]$Product = 'barracuda-spam-firewall',
	[string]$name = 'hourly'
)
Write-Host "Image Creation in Process - Plan Info - Barracuda SPAM Firewall " -ForegroundColor White
Write-Host 'Publisher:'$Publisher 'Offer:'$offer 'Sku:'$Skus 'Version:'$version
$global:VirtualMachine= Set-AzureRmVMPlan -VM $VirtualMachine -Name $name -Publisher $Publisher -Product $Product
$global:VirtualMachine = Set-AzureRmVMOperatingSystem -VM $VirtualMachine -linux -ComputerName $VMName -Credential $Credential1
$global:VirtualMachine = Set-AzureRmVMSourceImage -VM $VirtualMachine -PublisherName $Publisher -Offer $offer -Skus $Skus -Version $version
$LogOut = "Completed image prep 'Publisher:'$Publisher 'Offer:'$offer 'Sku:'$Skus 'Version:'$version"
Log-Command -Description $LogOut -LogFile $LogOutFile
}

Function MakeImagePlanInfo_f5_bigip_good_byol {
param(
	[string]$VMName = $VMName,
	[string]$Publisher = 'F5-networks',
	[string]$offer = 'f5-big-ip',
	[string]$Skus = 'f5-bigip-virtual-edition-good-byol',
	[string]$version = 'latest',
	[string]$Product = 'f5-big-ip',
	[string]$name = 'f5-bigip-virtual-edition-good-byol'
)
Write-Host "Image Creation in Process - Plan Info - F5 BIG IP - BYOL" -ForegroundColor White
Write-Host 'Publisher:'$Publisher 'Offer:'$offer 'Sku:'$Skus 'Version:'$version
$global:VirtualMachine= Set-AzureRmVMPlan -VM $VirtualMachine -Name $name -Publisher $Publisher -Product $Product
$global:VirtualMachine = Set-AzureRmVMOperatingSystem -VM $VirtualMachine -linux -ComputerName $VMName -Credential $Credential1
$global:VirtualMachine = Set-AzureRmVMSourceImage -VM $VirtualMachine -PublisherName $Publisher -Offer $offer -Skus $Skus -Version $version
$LogOut = "Completed image prep 'Publisher:'$Publisher 'Offer:'$offer 'Sku:'$Skus 'Version:'$version"
Log-Command -Description $LogOut -LogFile $LogOutFile
}

Function MakeImagePlanInfo_f5_webappfire_byol {
param(
	[string]$VMName = $VMName,
	[string]$Publisher = 'F5-networks',
	[string]$offer = 'f5-web-application-firewall',
	[string]$Skus = 'f5-waf-solution-byol',
	[string]$version = 'latest',
	[string]$Product = 'f5-web-application-firewall',
	[string]$name = 'f5-waf-solution-byol'
)
Write-Host "Image Creation in Process - Plan Info - F5 WebApp Firewall- BYOL" -ForegroundColor White
Write-Host 'Publisher:'$Publisher 'Offer:'$offer 'Sku:'$Skus 'Version:'$version
$global:VirtualMachine= Set-AzureRmVMPlan -VM $VirtualMachine -Name $name -Publisher $Publisher -Product $Product
$global:VirtualMachine = Set-AzureRmVMOperatingSystem -VM $VirtualMachine -linux -ComputerName $VMName -Credential $Credential1
$global:VirtualMachine = Set-AzureRmVMSourceImage -VM $VirtualMachine -PublisherName $Publisher -Offer $offer -Skus $Skus -Version $version
$LogOut = "Completed image prep 'Publisher:'$Publisher 'Offer:'$offer 'Sku:'$Skus 'Version:'$version"
Log-Command -Description $LogOut -LogFile $LogOutFile
}

Function MakeImagePlanInfo_Pfsense {
param(
	[string]$VMName = $VMName,
	[string]$Publisher = 'netgate',
	[string]$offer = 'netgate-pfsense-appliance',
	[string]$Skus = 'pfsense-router-fw-vpn-225',
	[string]$version = 'latest',
	[string]$Product = 'netgate-pfsense-appliance',
	[string]$name = 'pfsense-router-fw-vpn-225'
)
Write-Host "Image Creation in Process - Plan Info - Pfsense" -ForegroundColor White
Write-Host 'Publisher:'$Publisher 'Offer:'$offer 'Sku:'$Skus 'Version:'$version
$global:VirtualMachine= Set-AzureRmVMPlan -VM $VirtualMachine -Name $name -Publisher $Publisher -Product $Product
$global:VirtualMachine = Set-AzureRmVMOperatingSystem -VM $VirtualMachine -linux -ComputerName $VMName -Credential $Credential1
$global:VirtualMachine = Set-AzureRmVMSourceImage -VM $VirtualMachine -PublisherName $Publisher -Offer $offer -Skus $Skus -Version $version
$LogOut = "Completed image prep 'Publisher:'$Publisher 'Offer:'$offer 'Sku:'$Skus 'Version:'$version"
Log-Command -Description $LogOut -LogFile $LogOutFile
}

Function MakeImagePlanInfo_Checkpoint {
param(
	[string]$VMName = $VMName,
	[string]$Publisher = 'checkpoint',
	[string]$offer = 'check-point-r77-10',
	[string]$Skus = 'sg-ngtp',
	[string]$version = 'latest',
	[string]$Product = 'check-point-r77-10',
	[string]$name = 'sg-ngtp'
)
Write-Host "Image Creation in Process - Plan Info - Checkpoint" -ForegroundColor White
Write-Host 'Publisher:'$Publisher 'Offer:'$offer 'Sku:'$Skus 'Version:'$version
$global:VirtualMachine = Set-AzureRmVMPlan -VM $VirtualMachine -Name $name -Publisher $Publisher -Product $Product
$global:VirtualMachine = Set-AzureRmVMOperatingSystem -VM $VirtualMachine -linux -ComputerName $VMName -Credential $Credential1
$global:VirtualMachine = Set-AzureRmVMSourceImage -VM $VirtualMachine -PublisherName $Publisher -Offer $offer -Skus $Skus -Version $version
$LogOut = "Completed image prep 'Publisher:'$Publisher 'Offer:'$offer 'Sku:'$Skus 'Version:'$version"
Log-Command -Description $LogOut -LogFile $LogOutFile
}

Function MakeImageNoPlanInfo_RedHat67 {
param(
	[string]$VMName = $VMName,
	[string]$Publisher = "Redhat",
	[string]$offer = "rhel",
	[string]$Skus = "6.7",
	[string]$version = "latest"
)
Write-Host "Image Creation in Process - No Plan Info - RedHat 6.7" -ForegroundColor White
Write-Host 'Publisher:'$Publisher 'Offer:'$offer 'Sku:'$Skus 'Version:'$version
$global:VirtualMachine = Set-AzureRmVMOperatingSystem -VM $VirtualMachine -linux -ComputerName $VMName -Credential $Credential1
$global:VirtualMachine = Set-AzureRmVMSourceImage -VM $VirtualMachine -PublisherName $Publisher -Offer $offer -Skus $Skus -Version $version
$LogOut = "Completed image prep 'Publisher:'$Publisher 'Offer:'$offer 'Sku:'$Skus 'Version:'$version"
Log-Command -Description $LogOut -LogFile $LogOutFile
}

Function MakeImageNoPlanInfo_RedHat72 {
param(
	[string]$VMName = $VMName,
	[string]$Publisher = "Redhat",
	[string]$offer = "rhel",
	[string]$Skus = "7.2",
	[string]$version = "latest"
)
Write-Host "Image Creation in Process - No Plan Info - Redhat 7.2" -ForegroundColor White
Write-Host 'Publisher:'$Publisher 'Offer:'$offer 'Sku:'$Skus 'Version:'$version
$global:VirtualMachine = Set-AzureRmVMOperatingSystem -VM $VirtualMachine -linux -ComputerName $VMName -Credential $Credential1
$global:VirtualMachine = Set-AzureRmVMSourceImage -VM $VirtualMachine -PublisherName $Publisher -Offer $offer -Skus $Skus -Version $version
$LogOut = "Completed image prep 'Publisher:'$Publisher 'Offer:'$offer 'Sku:'$Skus 'Version:'$version"
Log-Command -Description $LogOut -LogFile $LogOutFile
}

Function MakeImageNoPlanInfo_FreeBsd {
param(
	[string]$VMName = $VMName,
	[string]$Publisher = "MicrosoftOSTC",
	[string]$offer = "FreeBSD",
	[string]$Skus = "10.3",
	[string]$version = "latest"
)
Write-Host "Image Creation in Process - No Plan Info - FreeBsd" -ForegroundColor White
Write-Host 'Publisher:'$Publisher 'Offer:'$offer 'Sku:'$Skus 'Version:'$version
$global:VirtualMachine = Set-AzureRmVMOperatingSystem -VM $VirtualMachine -linux -ComputerName $VMName -Credential $Credential1
$global:VirtualMachine = Set-AzureRmVMSourceImage -VM $VirtualMachine -PublisherName $Publisher -Offer $offer -Skus $Skus -Version $version
$LogOut = "Completed image prep 'Publisher:'$Publisher 'Offer:'$offer 'Sku:'$Skus 'Version:'$version"
Log-Command -Description $LogOut -LogFile $LogOutFile
}

Function MakeImageNoPlanInfo_CentOs {
param(
	[string]$VMName = $VMName,
	[string]$Publisher = "OpenLogic",
	[string]$offer = "Centos",
	[string]$Skus = "7.2",
	[string]$version = "latest"

)
Write-Host "Image Creation in Process - No Plan Info - CentOs" -ForegroundColor White
Write-Host 'Publisher:'$Publisher 'Offer:'$offer 'Sku:'$Skus 'Version:'$version
$global:VirtualMachine = Set-AzureRmVMOperatingSystem -VM $VirtualMachine -linux -ComputerName $VMName -Credential $Credential1
$global:VirtualMachine = Set-AzureRmVMSourceImage -VM $VirtualMachine -PublisherName $Publisher -Offer $offer -Skus $Skus -Version $version
$LogOut = "Completed image prep 'Publisher:'$Publisher 'Offer:'$offer 'Sku:'$Skus 'Version:'$version"
Log-Command -Description $LogOut -LogFile $LogOutFile
}

Function MakeImageNoPlanInfo_Suse {
param(
	[string]$VMName = $VMName,
	[string]$Publisher = "Suse",
	[string]$offer = "openSUSE",
	[string]$Skus = "13.2",
	[string]$version = "latest"
)
Write-Host "Image Creation in Process - No Plan Info - SUSE" -ForegroundColor White
Write-Host 'Publisher:'$Publisher 'Offer:'$offer 'Sku:'$Skus 'Version:'$version
$global:VirtualMachine = Set-AzureRmVMOperatingSystem -VM $VirtualMachine -linux -ComputerName $VMName -Credential $Credential1
$global:VirtualMachine = Set-AzureRmVMSourceImage -VM $VirtualMachine -PublisherName $Publisher -Offer $offer -Skus $Skus -Version $version
$LogOut = "Completed image prep 'Publisher:'$Publisher 'Offer:'$offer 'Sku:'$Skus 'Version:'$version"
Log-Command -Description $LogOut -LogFile $LogOutFile
}

Function MakeImageNoPlanInfo_Ubuntu {
param(
	[string]$VMName = $VMName,
	[string]$Publisher = "Canonical",
	[string]$offer = "UbuntuServer",
	[string]$Skus = "14.04.4-LTS",
	[string]$version = "latest"
)
Write-Host "Image Creation in Process - No Plan Info - Ubuntu" -ForegroundColor White
Write-Host 'Publisher:'$Publisher 'Offer:'$offer 'Sku:'$Skus 'Version:'$version
$global:VirtualMachine = Set-AzureRmVMOperatingSystem -VM $VirtualMachine -linux -ComputerName $VMName -Credential $Credential1
$global:VirtualMachine = Set-AzureRmVMSourceImage -VM $VirtualMachine -PublisherName $Publisher -Offer $offer -Skus $Skus -Version $version
$LogOut = "Completed image prep 'Publisher:'$Publisher 'Offer:'$offer 'Sku:'$Skus 'Version:'$version"
Log-Command -Description $LogOut -LogFile $LogOutFile
}

Function MakeImagePlanInfo_Chef {
param(
	[string]$VMName = $VMName,
	[string]$Publisher = 'chef-software',
	[string]$offer = 'chef-server',
	[string]$Skus = 'azure_marketplace_100',
	[string]$version = 'latest',
	[string]$Product = 'chef-server',
	[string]$name = 'azure_marketplace_100'
)
Write-Host "Image Creation in Process - Plan Info - Chef" -ForegroundColor White
Write-Host 'Publisher:'$Publisher 'Offer:'$offer 'Sku:'$Skus 'Version:'$version
$global:VirtualMachine = Set-AzureRmVMPlan -VM $VirtualMachine -Name $name -Publisher $Publisher -Product $Product
$global:VirtualMachine = Set-AzureRmVMOperatingSystem -VM $VirtualMachine -linux -ComputerName $VMName -Credential $Credential1
$global:VirtualMachine = Set-AzureRmVMSourceImage -VM $VirtualMachine -PublisherName $Publisher -Offer $offer -Skus $Skus -Version $version
$LogOut = "Completed image prep 'Publisher:'$Publisher 'Offer:'$offer 'Sku:'$Skus 'Version:'$version"
Log-Command -Description $LogOut -LogFile $LogOutFile
}

Function MakeImageNoPlanInfo_w2k12 {
param(
	[string]$VMName = $VMName,
	[string]$Publisher = "MicrosoftWindowsServer",
	[string]$offer = "WindowsServer",
	[string]$Skus = "2012-R2-Datacenter",
	[string]$version = "latest"
)
Write-Host "Image Creation in Process - No Plan Info - W2k12 server" -ForegroundColor White
Write-Host 'Publisher:'$Publisher 'Offer:'$offer 'Sku:'$Skus 'Version:'$version
$global:VirtualMachine = Set-AzureRmVMOperatingSystem -VM $VirtualMachine -Windows -ComputerName $VMName -Credential $Credential1 -ProvisionVMAgent -EnableAutoUpdate -WinRMHttp -Verbose
$global:VirtualMachine = Set-AzureRmVMSourceImage -VM $VirtualMachine -PublisherName $Publisher -Offer $offer -Skus $Skus -Version $version
$LogOut = "Completed image prep 'Publisher:'$Publisher 'Offer:'$offer 'Sku:'$Skus 'Version:'$version"
Log-Command -Description $LogOut -LogFile $LogOutFile
}

Function MakeImageNoPlanInfo_w2k8 {
param(
	[string]$VMName = $VMName,
	[string]$Publisher = "MicrosoftWindowsServer",
	[string]$offer = "WindowsServer",
	[string]$Skus = "2008-R2-SP1",
	[string]$version = "latest"
)
Write-Host "Image Creation in Process - No Plan Info - W2k8 server" -ForegroundColor White
Write-Host 'Publisher:'$Publisher 'Offer:'$offer 'Sku:'$Skus 'Version:'$version
$global:VirtualMachine = Set-AzureRmVMOperatingSystem -VM $VirtualMachine -Windows -ComputerName $VMName -Credential $Credential1 -ProvisionVMAgent -EnableAutoUpdate -WinRMHttp -Verbose
$global:VirtualMachine = Set-AzureRmVMSourceImage -VM $VirtualMachine -PublisherName $Publisher -Offer $offer -Skus $Skus -Version $version
$LogOut = "Completed image prep 'Publisher:'$Publisher 'Offer:'$offer 'Sku:'$Skus 'Version:'$version"
Log-Command -Description $LogOut -LogFile $LogOutFile
}

Function MakeImageNoPlanInfo_SharePoint2k13 {
param(
	[string]$VMName = $VMName,
	[string]$Publisher = "MicrosoftSharePoint",
	[string]$offer = "MicrosoftSharePointServer",
	[string]$Skus = "2013",
	[string]$version = "latest"
)
Write-Host "Image Creation in Process - No Plan Info - SharePoint 2013 server" -ForegroundColor White
Write-Host 'Publisher:'$Publisher 'Offer:'$offer 'Sku:'$Skus 'Version:'$version
$global:VirtualMachine = Set-AzureRmVMOperatingSystem -VM $VirtualMachine -Windows -ComputerName $VMName -Credential $Credential1 -ProvisionVMAgent -EnableAutoUpdate -WinRMHttp -Verbose
$global:VirtualMachine = Set-AzureRmVMSourceImage -VM $VirtualMachine -PublisherName $Publisher -Offer $offer -Skus $Skus -Version $version
$LogOut = "Completed image prep 'Publisher:'$Publisher 'Offer:'$offer 'Sku:'$Skus 'Version:'$version"
Log-Command -Description $LogOut -LogFile $LogOutFile
}

Function MakeImageNoPlanInfo_SharePoint2k16 {
param(
	[string]$VMName = $VMName,
	[string]$Publisher = "MicrosoftSharePoint",
	[string]$offer = "MicrosoftSharePointServer",
	[string]$Skus = "2016",
	[string]$version = "latest"
)
Write-Host "Image Creation in Process - No Plan Info - SharePoint 2016 server" -ForegroundColor White
Write-Host 'Publisher:'$Publisher 'Offer:'$offer 'Sku:'$Skus 'Version:'$version
$global:VirtualMachine = Set-AzureRmVMOperatingSystem -VM $VirtualMachine -Windows -ComputerName $VMName -Credential $Credential1 -ProvisionVMAgent -EnableAutoUpdate -WinRMHttp -Verbose
$global:VirtualMachine = Set-AzureRmVMSourceImage -VM $VirtualMachine -PublisherName $Publisher -Offer $offer -Skus $Skus -Version $version
$LogOut = "Completed image prep 'Publisher:'$Publisher 'Offer:'$offer 'Sku:'$Skus 'Version:'$version"
Log-Command -Description $LogOut -LogFile $LogOutFile
}

Function MakeImageNoPlanInfo_w2k16 {
param(
	[string]$VMName = $VMName,
	[string]$Publisher = "MicrosoftWindowsServer",
	[string]$offer = "WindowsServer",
	[string]$Skus = "Windows-Server-Technical-Preview",
	[string]$version = "latest"
)
Write-Host "Image Creation in Process - No Plan Info - W2k16 server" -ForegroundColor White
Write-Host 'Publisher:'$Publisher 'Offer:'$offer 'Sku:'$Skus 'Version:'$version
$global:VirtualMachine = Set-AzureRmVMOperatingSystem -VM $VirtualMachine -Windows -ComputerName $VMName -Credential $Credential1 -ProvisionVMAgent -EnableAutoUpdate -WinRMHttp -Verbose
$global:VirtualMachine = Set-AzureRmVMSourceImage -VM $VirtualMachine -PublisherName $Publisher -Offer $offer -Skus $Skus -Version $version
$LogOut = "Completed image prep 'Publisher:'$Publisher 'Offer:'$offer 'Sku:'$Skus 'Version:'$version"
Log-Command -Description $LogOut -LogFile $LogOutFile
}

Function MakeImageNoPlanInfo_sql2k16 {
param(
	[string]$VMName = $VMName,
	[string]$Publisher = "MicrosoftSQLServer",
	[string]$offer = "SQL2016-WS2012R2",
	[string]$Skus = "Enterprise",
	[string]$version = "latest"
)
Write-Host "Image Creation in Process - No Plan Info - SQL 2016" -ForegroundColor White
Write-Host $Publisher $offer $Skus $version
$global:VirtualMachine = Set-AzureRmVMOperatingSystem -VM $VirtualMachine -Windows -ComputerName $VMName -Credential $Credential1 -ProvisionVMAgent -EnableAutoUpdate -WinRMHttp -Verbose
$global:VirtualMachine = Set-AzureRmVMSourceImage -VM $VirtualMachine -PublisherName $Publisher -Offer $offer -Skus $Skus -Version $version
$LogOut = "Completed image prep 'Publisher:'$Publisher 'Offer:'$offer 'Sku:'$Skus 'Version:'$version"
Log-Command -Description $LogOut -LogFile $LogOutFile
}

Function CreateVnet {
param(
[string]$VNETName = $VNetName,
[string]$vnetrg = $vnetrg,
[string]$AddRange = $AddRange,
[string]$Location = $Location,
[string]$SubnetAddPrefix1 = $SubnetAddPrefix1,
[string]$SubnetNameAddPrefix1 = $SubnetNameAddPrefix1,
[string]$SubnetAddPrefix2 = $SubnetAddPrefix2,
[string]$SubnetNameAddPrefix2 = $SubnetNameAddPrefix2,
[string]$SubnetAddPrefix3 = $SubnetAddPrefix3,
[string]$SubnetNameAddPrefix3 = $SubnetNameAddPrefix3,
[string]$SubnetAddPrefix4 = $SubnetAddPrefix4,
[string]$SubnetNameAddPrefix4 = $SubnetNameAddPrefix4,
[string]$SubnetAddPrefix5 = $SubnetAddPrefix5,
[string]$SubnetNameAddPrefix5 = $SubnetNameAddPrefix5,
[string]$SubnetAddPrefix6 = $SubnetAddPrefix6,
[string]$SubnetNameAddPrefix6 = $SubnetNameAddPrefix6,
[string]$SubnetAddPrefix7 = $SubnetAddPrefix7,
[string]$SubnetNameAddPrefix7 = $SubnetNameAddPrefix7,
[string]$SubnetAddPrefix8 = $SubnetAddPrefix8,
[string]$SubnetNameAddPrefix8 = $SubnetNameAddPrefix8
)
Write-Host "Network Preparation in Process.."
$subnet1 = New-AzureRmVirtualNetworkSubnetConfig -AddressPrefix $SubnetAddPrefix1 -Name $SubnetNameAddPrefix1
$subnet2 = New-AzureRmVirtualNetworkSubnetConfig -AddressPrefix $SubnetAddPrefix2 -Name $SubnetNameAddPrefix2
$subnet3 = New-AzureRmVirtualNetworkSubnetConfig -AddressPrefix $SubnetAddPrefix3 -Name $SubnetNameAddPrefix3
$subnet4 = New-AzureRmVirtualNetworkSubnetConfig -AddressPrefix $SubnetAddPrefix4 -Name $SubnetNameAddPrefix4
$subnet5 = New-AzureRmVirtualNetworkSubnetConfig -AddressPrefix $SubnetAddPrefix5 -Name $SubnetNameAddPrefix5
$subnet6 = New-AzureRmVirtualNetworkSubnetConfig -AddressPrefix $SubnetAddPrefix6 -Name $SubnetNameAddPrefix6
$subnet7 = New-AzureRmVirtualNetworkSubnetConfig -AddressPrefix $SubnetAddPrefix7 -Name $SubnetNameAddPrefix7
$subnet8 = New-AzureRmVirtualNetworkSubnetConfig -AddressPrefix $SubnetAddPrefix8 -Name $SubnetNameAddPrefix8
New-AzureRmVirtualNetwork -Location $Location -Name $VNetName -ResourceGroupName $vnetrg -AddressPrefix $AddRange -Subnet $subnet1,$subnet2,$subnet3,$subnet4,$subnet5,$subnet6,$subnet7,$subnet8 –Confirm:$false -WarningAction SilentlyContinue -Force | Out-Null
Get-AzureRmVirtualNetwork -Name $VNetName -ResourceGroupName $vnetrg | Get-AzureRmVirtualNetworkSubnetConfig -WarningAction SilentlyContinue | Out-Null
Write-Host "Network Preparation completed" -ForegroundColor White
$LogOut = "Completed Network Configuration of $VNetName"
Log-Command -Description $LogOut -LogFile $LogOutFile
}

# End of Provision VNET Function
Function CreateNSG {
param(
[string]$NSGName = $NSGName,
[string]$Location = $Location,
[string]$vnetrg = $vnetrg
)
Write-Host "Network Security Group Preparation in Process.."
$httprule = New-AzureRmNetworkSecurityRuleConfig -Name "FrontEnd_HTTP" -Description "HTTP Exception for Web frontends" -Protocol Tcp -SourcePortRange "80" -DestinationPortRange "80" -SourceAddressPrefix "*" -DestinationAddressPrefix "10.120.0.0/21" -Access Allow -Direction Inbound -Priority 200
$httpsrule = New-AzureRmNetworkSecurityRuleConfig -Name "FrontEnd_HTTPS" -Description "HTTPS Exception for Web frontends" -Protocol Tcp -SourcePortRange "443" -DestinationPortRange "443" -SourceAddressPrefix "*" -DestinationAddressPrefix "10.120.0.0/21" -Access Allow -Direction Inbound -Priority 201
$sshrule = New-AzureRmNetworkSecurityRuleConfig -Name "FrontEnd_SSH" -Description "SSH Exception for Web frontends" -Protocol Tcp -SourcePortRange "22" -DestinationPortRange "22" -SourceAddressPrefix "*" -DestinationAddressPrefix "10.120.0.0/21" -Access Allow -Direction Inbound ` -Priority 203
$nsg = New-AzureRmNetworkSecurityGroup -ResourceGroupName $vnetrg -Location $Location -Name $NSGName -SecurityRules $httprule,$httpsrule, $sshrule –Confirm:$false -WarningAction SilentlyContinue -Force | Out-Null
Get-AzureRmNetworkSecurityGroup -Name $NSGName -ResourceGroupName $vnetrg -WarningAction SilentlyContinue | Out-Null
Write-Host "Network Security Group configuration completed" -ForegroundColor White
$LogOut = "Security Rules added for $NSGName"
$secrules = Get-AzureRmNetworkSecurityGroup -Name $NSGName -ResourceGroupName $vnetrg -ExpandResource NetworkInterfaces | Get-AzureRmNetworkSecurityRuleConfig | Ft Name,Description,Direction,SourcePortRange,DestinationPortRange,DestinationPortRange,SourceAddressPrefix,Access
$defsecrules = Get-AzureRmNetworkSecurityGroup -Name $NSGName -ResourceGroupName $vnetrg -ExpandResource NetworkInterfaces | Get-AzureRmNetworkSecurityRuleConfig -DefaultRules | Ft Name,Description,Direction,SourcePortRange,DestinationPortRange,DestinationAddressPrefix,SourceAddressPrefix,Access
Log-Command -Description $LogOut -LogFile $LogOutFile
$LogOut = "Completed NSG Configuration of $NSGName"
Log-Command -Description $LogOut -LogFile $LogOutFile
}
# End of Provision Network Security Groups Function

Function SubnetMatch {
	Param(
		[INT]$Subnet
	)
switch ($Subnet)
{
0 {Write-Host "Deploying to Subnet 10.120.0.0/25"}
1 {Write-Host "Deploying to Subnet 10.120.1.128/25"}
2 {Write-Host "Deploying to Subnet 10.120.1.0/24"}
3 {Write-Host "Deploying to Subnet 10.120.2.0/24"}
4 {Write-Host "Deploying to Subnet 10.120.3.0/24"}
5 {Write-Host "Deploying to Subnet 10.120.4.0/24"}
6 {Write-Host "Deploying to Subnet 10.120.5.0/24"}
7 {Write-Host "Deploying to Subnet 10.120.6.0/24"}
8 {Write-Host "Deploying to Subnet 10.120.7.0/24"}
9 {Write-Host "Deploying to Subnet 10.120.8.0/24"}
default {No Subnet Found}
}
}

Function WriteConfig {
param(
$Subnet1 = $global:Subnet1,
$Subnet2 = $global:Subnet2
)
Write-Host "                                                               "
$time = " Start Time " + (Get-Date -UFormat "%d-%m-%Y %H:%M:%S")
Write-Host -------------- $time --------------- -ForegroundColor Cyan
Write-Host "                                                               "
Write-Host "Current configuration"

Write-Host "VM Name: $VMName " -ForegroundColor White
Write-Host "Resource Group Name: $rg"
Write-Host "Server Type: $vmMarketImage"
Write-Host "VNET Name: $vNetName"
Write-Host "VNET Resource Group Name: $vnetrg"
Write-Host "Storage Account Name:  $StorageName"
SelectNicDescrtipt
If ($ConfigIPs -eq "StatPvtNoPubSingle")
{ Write-Host "Public Ip Will not be created" -ForegroundColor White
Write-Host "Nic1: $PvtIPNic1"
SubnetMatch $Subnet1
}
If ($ConfigIPs -eq "StatPvtNoPubDual")
{ Write-Host "Public Ip Will not be created" -ForegroundColor White
Write-Host "Nic1: $PvtIPNic1"
Write-Host "Nic2: $PvtIPNic2"
SubnetMatch $Subnet1
SubnetMatch $Subnet2
}
If ($ConfigIPs -eq "Single")
{ Write-Host "Public Ip Will be created"
SubnetMatch $Subnet1
}

If ($ConfigIPs -eq "Dual")
{ Write-Host "Public Ip Will be created"
SubnetMatch $Subnet1
SubnetMatch $Subnet2
}
If ($ConfigIPs -eq "PvtSingleStat")
{ Write-Host "Public Ip Will be created"
SubnetMatch $Subnet1
Write-Host "Nic1: $PvtIPNic1"
}
If ($ConfigIPs -eq "PvtDualStat")
{ Write-Host "Public Ip Will be created"
SubnetMatch $Subnet1
SubnetMatch $Subnet2
Write-Host "Nic1: $PvtIPNic1"
Write-Host "Nic2: $PvtIPNic2"
}
if($AddExtension) {
Write-Host "Extension selected for deployment: $AzExtConfig "
}
if($AddAvailabilitySet) {
Write-Host "Availability Set to 'True'"
Write-Host "Availability Set Name:  '$AvailSetName'"
Write-Host "                                                               "
Write-Host "--------------------------------------------------------------" -ForegroundColor Cyan
Write-Host "                                                               "
}
else
{
Write-Host "Availability Set to 'False'" -ForegroundColor White
Write-Host "--------------------------------------------------------------" -ForegroundColor Cyan
Write-Host "                                                               "
}
}

Function WriteConfigVM {
param(
$Subnet1 = $global:Subnet1,
$Subnet2 = $global:Subnet2
)

Write-Host "                                                               "
$time = " Start Time " + (Get-Date -UFormat "%d-%m-%Y %H:%M:%S")
Write-Host VM CONFIGURATION - $time ----------- -ForegroundColor Cyan
Write-Host "                                                               "
Write-Host "VM Name: $VMName " -ForegroundColor White
Write-Host "Resource Group Name: $rg"
Write-Host "Server Type: $vmMarketImage"
Write-Host "Geo Location: $Location"
Write-Host "VNET Name: $vNetName"
Write-Host "Storage Account Name: $StorageName"
Write-Host "Storage Account Type: $StorageType"
SelectNicDescrtipt
If ($ConfigIPs -eq "StatPvtNoPubSingle")
{ Write-Host "Public Ip Will not be created" -ForegroundColor White
Write-Host "Nic1: $PvtIPNic1"
SubnetMatch $Subnet1
}
If ($ConfigIPs -eq "StatPvtNoPubDual")
{ Write-Host "Public Ip Will not be created" -ForegroundColor White
Write-Host "Nic1: $PvtIPNic1"
Write-Host "Nic2: $PvtIPNic2"
SubnetMatch $Subnet1
SubnetMatch $Subnet2
}
If ($ConfigIPs -eq "Single")
{ Write-Host "Public Ip Will be created"
SubnetMatch $Subnet1
}
If ($ConfigIPs -eq "Dual")
{ Write-Host "Public Ip Will be created"
SubnetMatch $Subnet1
SubnetMatch $Subnet2
}
If ($ConfigIPs -eq "PvtSingleStat")
{ Write-Host "Public Ip Will be created"
SubnetMatch $Subnet1
Write-Host "Nic1: $PvtIPNic1"
}
If ($ConfigIPs -eq "PvtDualStat")
{ Write-Host "Public Ip Will be created"
SubnetMatch $Subnet1
SubnetMatch $Subnet2
Write-Host "Nic1: $PvtIPNic1"
Write-Host "Nic2: $PvtIPNic2"
}
if($AddExtension) {
Write-Host "Extension selected for deployment: $AzExtConfig "
}
if($AddAvailabilitySet) {
Write-Host "Availability Set to 'True'"
Write-Host "Availability Set Name:  '$AvailSetName'"
Write-Host "                                                               "
}
else
{
Write-Host "Availability Set to 'False'" -ForegroundColor White
Write-Host "                                                               "
}
}

Function WriteConfigVnet {
Write-Host "                                                               "
$time = " Start Time " + (Get-Date -UFormat "%d-%m-%Y %H:%M:%S")
Write-Host VNET CONFIGURATION - $time --------- -ForegroundColor Cyan
Write-Host "                                                               "
Write-Host "Geo Location: $Location"
Write-Host "VNET Name: $vNetName"
Write-Host "VNET Resource Group Name: $vnetrg"
Write-Host "Address Range:  $AddRange"
if($NSGEnabled)
{
Write-Host "NSG Name: $NSGName"
}
Write-Host "                                                               "
}

Function WriteResults {
param(
$Subnet1 = $global:Subnet1,
$Subnet2 = $global:Subnet2
)
Write-Host "                                                               "
Write-Host "--------------------------------------------------------------" -ForegroundColor Cyan
Write-Host "                                                               "
Write-Host "Completed Deployment of:"  -ForegroundColor Cyan
Write-Host "VM Name: $VMName " -ForegroundColor White
Write-Host "Resource Group Name: $rg"
Write-Host "Server Type: $vmMarketImage"
Write-Host "VNET Resource Group Name: $vnetrg" -ForegroundColor White
Write-Host "VNET Name: $VNetName" -ForegroundColor White
Write-Host "Storage Account Name:  $StorageNameVerified"

$vm = Get-AzureRmvm -ResourceGroupName $rg -Name $VMName
$strprofile = $vm.StorageProfile
$disktype = $strprofile.OsDisk | Select-Object -ExpandProperty OSType
$osdiskuri = $strprofile.OsDisk | Select-Object -ExpandProperty Vhd
$storage = $vm.StorageProfile
$disk = $storage.OsDisk
$Name = $disk.Name
$uri = $disk.Vhd
$avset = $vm.AvailabilitySetReference
$extension = $vm.Extensions | Select-Object -ExpandProperty VirtualMachineExtensionType
$extcount = $extension.Count
$statuscode = $vm.StatusCode
$availsetid = $avset.Id
$name = $vm.Name
$nicids = $vm.NetworkInterfaceIDs
$nicprofile = $vm.NetworkProfile
$nicprofiles = $nicprofile.NetworkInterfaces
$niccount = $nicprofiles.Count
$osprofile = $vm.OSProfile
$localadmin = $osprofile.AdminUsername
$provstate = $vm.ProvisioningState
$datad = $vm.DataDiskNames
$datadiskcount = $datad.Count

Write-Host "Server Name:"$name
Write-Host "OS Type:" $disktype
Write-Host "Local admin:" $localadmin
Write-Host "Installed Azure Extensions Count:" $extcount
Write-Host "Installed Extensions:" $extension
Write-Host "Provisioning State:" $provstate
Write-Host "Status Code:" $statuscode
Write-Host "Network Adapter Count:" $niccount
Write-Host "Availability Set:"$availsetid
Write-Host "Data Disk Count:" $datadiskcount

if($AddExtension) {
Write-Host "Extension deployed: $AzExtConfig "
}
if($AddAvailabilitySet) {
Write-Host "Availability Set Configured"
Write-Host "Availability Set Name:  '$AvailSetName'"
$time = " Completed Time " + (Get-Date -UFormat "%d-%m-%Y %H:%M:%S")
Write-Host -------------- $time ------------- -ForegroundColor Cyan
Write-Host "                                                               "
}
else
{
$time = " Completed Time " + (Get-Date -UFormat "%d-%m-%Y %H:%M:%S")
Write-Host -------------- $time ------------- -ForegroundColor Cyan
Write-Host "                                                               "
}
EndState
}

Function EndState {
Write-Host "                                                               "
Write-Host "Private Network Interfaces for $rg"
$vms = get-azurermvm -ResourceGroupName $rg
$nics = get-azurermnetworkinterface -ResourceGroupName $rg | where VirtualMachine -NE $null #skip Nics with no VM
foreach($nic in $nics)
{
	$vm = $vms | where-object -Property Id -EQ $nic.VirtualMachine.id
	$prv =  $nic.IpConfigurations | select-object -ExpandProperty PrivateIpAddress
	$alloc =  $nic.IpConfigurations | select-object -ExpandProperty PrivateIpAllocationMethod
	Write-Output "$($vm.Name) : $prv , $alloc" | Format-Table
}

$pubip = Get-AzureRmPublicIpAddress -Name $InterfaceName1 -ResourceGroupName $rg -ErrorAction SilentlyContinue
$dns = Get-AzureRmPublicIpAddress -ExpandResource IPConfiguration -Name $InterfaceName1 -ResourceGroupName $rg -ErrorAction SilentlyContinue | select-object -ExpandProperty DNSSettings | select-object -ExpandProperty FQDN
if($pubip)
{
Write-Host "Public Network Interfaces for $rg"
Get-AzureRmPublicIpAddress -ResourceGroupName $rg| ft "Name","IpAddress" -Wrap
Get-AzureRmPublicIpAddress -ResourceGroupName $rg | select-object -ExpandProperty DNSSettings | FT FQDN -Wrap
}
ResultsRollup
Write-Host "                                                               "
break
}

Function ResultsRollup {
Write-Host "                                                               "
Write-Host "Storage Accounts for $rg" -NoNewLine
Get-AzurermStorageAccount -ResourceGroupName $rg -WarningAction SilentlyContinue | ft StorageAccountName,Location,ResourceGroupname -Wrap

if($AddAvailabilitySet){
Write-Host "Availability Sets for $rg"
Get-AzurermAvailabilitySet -ResourceGroupName $rg -WarningAction SilentlyContinue | ft Name,ResourceGroupName -Wrap
}
}

Function ProvisionResGrp
{
	Param(
		[string]$rg
	)
New-AzureRmResourceGroup -Name $rg -Location $Location –Confirm:$false -WarningAction SilentlyContinue -Force | Out-Null
}

Function Get-azinfo  {
	param(
		[Parameter(Mandatory=$False,ValueFromPipelinebyPropertyName=$true)]
		[ValidateSet("network","vm","summary","extension")]
		[string]
		$infoset = $infoset,
		[Parameter(Mandatory=$False,ValueFromPipelinebyPropertyName=$true,Position=0)]
		[string]
		$rg = $rg
	)
validate-profile
switch ($infoset)
	{
		"network" {
Write-Host "VNETs in RG" $rg -NoNewline
Get-AzureRmVirtualNetwork -ResourceGroupName $rg -WarningAction SilentlyContinue | ft Name, ResourceGroupName -Wrap -AutoSize

Write-Host "Subnets located in RG" $rg
Get-AzureRmVirtualNetwork -ResourceGroupName $rg | Get-AzureRmVirtualNetworkSubnetConfig | ft Name,AddressPrefix

Write-Host "Network Security Groups located in RG" $rg
Get-AzureRmNetworkSecurityGroup -ResourceGroupName $rg -WarningAction SilentlyContinue | ft "Name"
if($NSGName){
Get-AzureRmNetworkSecurityGroup -Name $NSGName -ResourceGroupName $rg -ExpandResource NetworkInterfaces | Get-AzureRmNetworkSecurityRuleConfig | Ft Name,Description,Direction,SourcePortRange,DestinationPortRange,DestinationPortRange,SourceAddressPrefix,Access
Get-AzureRmNetworkSecurityGroup -Name $NSGName -ResourceGroupName $rg -ExpandResource NetworkInterfaces | Get-AzureRmNetworkSecurityRuleConfig -DefaultRules | Ft Name,Description,Direction,SourcePortRange,DestinationPortRange,DestinationAddressPrefix,SourceAddressPrefix,Access
}
Write-Host "Public Ips located in RG" $rg
Get-AzureRmPublicIpAddress -ResourceGroupName $rg | ft "Name","IpAddress"

Write-Host "Public DNS Records located in RG" $rg
Get-AzureRmPublicIpAddress -ResourceGroupName $rg | select-object -ExpandProperty DNSSettings | FT FQDN -Wrap
exit
}
		"vm" {
Write-Host "VMs located in RG" $rg
Get-AzureRmVM -ResourceGroupName $rg | ft "Name"

Write-Host "NICs located in RG" $rg
Get-AzureRmNetworkInterface -ResourceGroupName $rg | ft Name,Location,ResourceGroupName

Write-Host "Private Network Interfaces located in " $rg
$vms = get-azurermvm -ResourceGroupName $rg
$nics = get-azurermnetworkinterface -ResourceGroupName $rg | where VirtualMachine -NE $null #skip Nics with no VM
foreach($nic in $nics)
{
	$vm = $vms | where-object -Property Id -EQ $nic.VirtualMachine.id
	$prv =  $nic.IpConfigurations | select-object -ExpandProperty PrivateIpAddress
	$alloc =  $nic.IpConfigurations | select-object -ExpandProperty PrivateIpAllocationMethod
	Write-Output "$($vm.Name): $prv - $alloc" | Format-Table

$vms = Get-AzureRmVM -ResourceGroupName $rg
$Countvm = $vms.Count
Write-Host "                                            "
Write-Host "Total VMs in RG:"$Countvm
foreach($vm in $vms) {
$strprofile = $vm.StorageProfile
$disktype = $strprofile.OsDisk | Select-Object -ExpandProperty OSType
$osdiskuri = $strprofile.OsDisk | Select-Object -ExpandProperty Vhd
$storage = $vm.StorageProfile
$disk = $storage.OsDisk
$Name = $disk.Name
$uri = $disk.Vhd
$avset = $vm.AvailabilitySetReference
$extension = $vm.Extensions | Select-Object -ExpandProperty VirtualMachineExtensionType
$extcount = $extension.Count
$statuscode = $vm.StatusCode
$availsetid = $avset.Id
$name = $vm.Name
$nicids = $vm.NetworkInterfaceIDs
$nicprofile = $vm.NetworkProfile
$nicprofiles = $nicprofile.NetworkInterfaces
$niccount = $nicprofiles.Count
$osprofile = $vm.OSProfile
$localadmin = $osprofile.AdminUsername
$provstate = $vm.ProvisioningState
$datad = $vm.DataDiskNames
$datadiskcount = $datad.Count

Write-Host "                                            "
Write-Host "Server Name:"$name
Write-Host "OS Type:" $disktype
Write-Host "Local admin:" $localadmin
Write-Host "Installed Azure Extensions Count:" $extcount
Write-Host "Installed Extensions:" $extension
Write-Host "Provisioning State:" $provstate
Write-Host "Status Code:" $statuscode
Write-Host "Network Adapter Count:" $niccount
Write-Host "Availability Set:"$availsetid
Write-Host "Data Disk Count:" $datadiskcount
Write-Host "                                            "
}

exit
}
}
		"extension" {
}
		"storage" {
}
		"summary" {
}
		default{"An unsupported information set command was used"
break
}
	}
}

Function CreateStorage {
		param(
		[string]$StorageName = $global:StorageNameVerified,
		[string]$rg = $rg,
		[string]$StorageType = $StorageType,
		[string]$Location = $Location
	)
Write-Host "Starting Storage Creation.."
$Global:StorageAccount = New-AzureRmStorageAccount -ResourceGroupName $rg -Name $StorageName.ToLower() -Type $StorageType -Location $Location -ErrorAction Stop -WarningAction SilentlyContinue
Write-Host "Completed Storage Creation" -ForegroundColor White
$LogOut = "Storage Configuration completed: $StorageName"
Log-Command -Description $LogOut -LogFile $LogOutFile
} # Creates Storage

Function CreateVM {
	param(
	[string]$VMName = $VMName,
	[ValidateSet("w2k12","w2k8","red67","red72","suse","free","ubuntu","centos","w2k16","sql2016","chef","check","pfsense","lamp","jenkins","nodejs","elastics","postgressql","splunk","puppet","serverr","solarwinds","f5bigip","f5appfire","barrahourngfw","barrabyolngfw","barrahourspam","barrabyolspam","mysql","share2013","share2016","mongodb","nginxstack","hadoop","neos","tomcat","redis","gitlab","jruby")]
	[string]
	$vmMarketImage = $vmMarketImage,
	[string]
	[ValidateSet("Single","Dual","NoPubDual","PvtDualStat","StatPvtNoPubSingle","PvtSingleStat","StatPvtNoPubDual","NoPubSingle")]
	$ConfigIps = $ConfigIps,
	[string]
	$StorageName = 	$StorageName,
	[string]
	$rg = $rg,
	[switch]
	$NSGEnabled = $NSGEnabled,
	[string]
	$NSGName = $NSGName,
	[string]
	$vnetrg = $vnetrg,
	[string]
	$StorageType = $StorageType,
	[string]
	$Location = $Location,
	[switch]
	$AddAvailabilitySet = $AddAvailabilitySet,
	[string]
	$VNETName = $VNetName,
	[string]
	$InterfaceName1 = $VMName + "_nic1",
	[string]
	$InterfaceName2 = $VMName + "_nic2",
	[int]
	$Subnet1 = $Subnet1,
	[int]
	$Subnet2 = $Subnet2,
	[ipaddress]
	$PvtIPNic1 = $PvtIPNic1,
	[ipaddress]
	$PvtIPNic2 = $PvtIPNic2,
	[string]
	$DNLabel = $DNLabel,
	[switch]
	$AddFQDN = $AddFQDN
	)
switch -Wildcard ($vmMarketImage)
	{
		"*pfsense*" {
			WriteConfigVM
			CreateStorage
			AvailSet
			ConfigNet  #Sets network connection info
			MakeImagePlanInfo_Pfsense # Begins Image Creation
			ConfigSet # Adds Network Interfaces
			AddDiskImage # Completes Image Creation
			Provvms
}
		"*free*" {
			WriteConfigVM
			CreateStorage
			AvailSet
			ConfigNet  #Sets network connection info
			MakeImageNoPlanInfo_FreeBsd  # Begins Image Creation
			ConfigSet # Adds Network Interfaces
			AddDiskImage # Completes Image Creation
			Provvms
}
		"*red72*" {
			WriteConfigVM
			CreateStorage
			AvailSet
			ConfigNet  #Sets network connection info
			MakeImageNoPlanInfo_RedHat72  # Begins Image Creation
			ConfigSet # Adds Network Interfaces
			AddDiskImage # Completes Image Creation
			Provvms
}
		"*red67*" {
			WriteConfigVM
			CreateStorage
			AvailSet
			ConfigNet  #Sets network connection info
			MakeImageNoPlanInfo_RedHat67  # Begins Image Creation
			ConfigSet # Adds Network Interfaces
			AddDiskImage # Completes Image Creation
			Provvms
}
		"*w2k12*" {
			WriteConfigVM
			CreateStorage
			AvailSet
			ConfigNet  #Sets network connection info
			MakeImageNoPlanInfo_w2k12  # Begins Image Creation
			ConfigSet # Adds Network Interfaces
			AddDiskImage # Completes Image Creation
			Provvms
}
		"*sql2016*" {
			WriteConfigVM
			CreateStorage
			AvailSet
			ConfigNet  #Sets network connection info
			MakeImageNoPlanInfo_sql2k16  # Begins Image Creation
			ConfigSet # Adds Network Interfaces
			AddDiskImage # Completes Image Creation
			Provvms
}
		"*check*" {
			WriteConfigVM
			CreateStorage
			AvailSet
			ConfigNet  #Sets network connection info
			MakeImagePlanInfo_Checkpoint  # Begins Image Creation
			ConfigSet # Adds Network Interfaces
			AddDiskImage # Completes Image Creation
			Provvms
}
		"*cent*" {
			WriteConfigVM
			CreateStorage
			AvailSet
			ConfigNet  #Sets network connection info
			MakeImageNoPlanInfo_CentOs  # Begins Image Creation
			ConfigSet # Adds Network Interfaces
			AddDiskImage # Completes Image Creation
			Provvms
}
		"*Suse*" {
			WriteConfigVM
			CreateStorage
			AvailSet
			ConfigNet  #Sets network connection info
			MakeImageNoPlanInfo_Suse  # Begins Image Creation
			ConfigSet # Adds Network Interfaces
			AddDiskImage # Completes Image Creation
			Provvms
}
		"*w2k8*" {
			WriteConfigVM
			CreateStorage
			AvailSet
			ConfigNet  #Sets network connection info
			MakeImageNoPlanInfo_w2k8  # Begins Image Creation
			ConfigSet # Adds Network Interfaces
			AddDiskImage # Completes Image Creation
			Provvms
}
		"*w2k16*" {
			WriteConfigVM
			CreateStorage
			AvailSet
			ConfigNet  #Sets network connection info
			MakeImageNoPlanInfo_w2k16  # Begins Image Creation
			ConfigSet # Adds Network Interfaces
			AddDiskImage # Completes Image Creation
			Provvms
}
		"*chef*" {
			WriteConfigVM
			CreateStorage
			AvailSet
			ConfigNet  #Sets network connection info
			MakeImagePlanInfo_Chef  # Begins Image Creation
			ConfigSet # Adds Network Interfaces
			AddDiskImage # Completes Image Creation
			Provvms
}
		"*lamp*" {
			WriteConfigVM
			CreateStorage
			AvailSet
			ConfigNet  #Sets network connection info
			MakeImagePlanInfo_Bitnami_Lamp # Begins Image Creation
			ConfigSet # Adds Network Interfaces
			AddDiskImage # Completes Image Creation
			Provvms
}
		"*mongodb*" {
			WriteConfigVM
			CreateStorage
			AvailSet
			ConfigNet  #Sets network connection info
			MakeImagePlanInfo_Bitnami_mongodb # Begins Image Creation
			ConfigSet # Adds Network Interfaces
			AddDiskImage # Completes Image Creation
			Provvms
}
		"*mysql*" {
			WriteConfigVM
			CreateStorage
			AvailSet
			ConfigNet  #Sets network connection info
			MakeImagePlanInfo_Bitnami_mysql # Begins Image Creation
			ConfigSet # Adds Network Interfaces
			AddDiskImage # Completes Image Creation
			Provvms
}
		"*elastics*" {
			WriteConfigVM
			CreateStorage
			AvailSet
			ConfigNet  #Sets network connection info
			MakeImagePlanInfo_Bitnami_elastic # Begins Image Creation
			ConfigSet # Adds Network Interfaces
			AddDiskImage # Completes Image Creation
			Provvms
}
		"*nodejs*" {
			WriteConfigVM
			CreateStorage
			AvailSet
			ConfigNet  #Sets network connection info
			MakeImagePlanInfo_Bitnami_nodejs # Begins Image Creation
			ConfigSet # Adds Network Interfaces
			AddDiskImage # Completes Image Creation
			Provvms
}
		"*nginxstack*" {
			WriteConfigVM
			CreateStorage
			AvailSet
			ConfigNet  #Sets network connection info
			MakeImagePlanInfo_Bitnami_nginxstack # Begins Image Creation
			ConfigSet # Adds Network Interfaces
			AddDiskImage # Completes Image Creation
			Provvms
}
		"*postgressql*" {
			WriteConfigVM
			CreateStorage
			AvailSet
			ConfigNet  #Sets network connection info
			MakeImagePlanInfo_Bitnami_postgresql # Begins Image Creation
			ConfigSet # Adds Network Interfaces
			AddDiskImage # Completes Image Creation
			Provvms
}
		"*oracle-linux*" {
			WriteConfigVM
			CreateStorage
			AvailSet
			ConfigNet  #Sets network connection info
			MakeImagePlanInfo_Oracle_linux # Begins Image Creation
			ConfigSet # Adds Network Interfaces
			AddDiskImage # Completes Image Creation
			Provvms
}
		"*web-logic*" {
			WriteConfigVM
			CreateStorage
			AvailSet
			ConfigNet  #Sets network connection info
			MakeImagePlanInfo_Oracle_weblogic # Begins Image Creation
			ConfigSet # Adds Network Interfaces
			AddDiskImage # Completes Image Creation
			Provvms
}
		"*entdb-oracle*" {
			WriteConfigVM
			CreateStorage
			AvailSet
			ConfigNet  #Sets network connection info
			MakeImagePlanInfo_Oracle_EntDB  # Begins Image Creation
			ConfigSet # Adds Network Interfaces
			AddDiskImage # Completes Image Creation
			Provvms
}
		"*stddb-oracle*" {
			WriteConfigVM
			CreateStorage
			AvailSet
			ConfigNet  #Sets network connection info
			MakeImagePlanInfo_Oracle_StdDB # Begins Image Creation
			ConfigSet # Adds Network Interfaces
			AddDiskImage # Completes Image Creation
			Provvms
}
		"*puppet*" {
			WriteConfigVM
			CreateStorage
			AvailSet
			ConfigNet  #Sets network connection info
			MakeImagePlanInfo_puppet_puppetent # Begins Image Creation
			ConfigSet # Adds Network Interfaces
			AddDiskImage # Completes Image Creation
			Provvms
}
		"*splunk*" {
			WriteConfigVM
			CreateStorage
			AvailSet
			ConfigNet  #Sets network connection info
			MakeImagePlanInfo_splunk # Begins Image Creation
			ConfigSet # Adds Network Interfaces
			AddDiskImage # Completes Image Creation
			Provvms
}
		"*share2013*" {
			WriteConfigVM
			CreateStorage
			AvailSet
			ConfigNet  #Sets network connection info
			MakeImageNoPlanInfo_SharePoint2k13 # Begins Image Creation
			ConfigSet # Adds Network Interfaces
			AddDiskImage # Completes Image Creation
			Provvms
}
		"*share2016*" {
			WriteConfigVM
			CreateStorage
			AvailSet
			ConfigNet  #Sets network connection info
			MakeImageNoPlanInfo_SharePoint2k16 # Begins Image Creation
			ConfigSet # Adds Network Interfaces
			AddDiskImage # Completes Image Creation
			Provvms
}
		"*serverr*" {
			WriteConfigVM
			CreateStorage
			AvailSet
			ConfigNet  #Sets network connection info
			MakeImagePlanInfo_Microsoft_Serverr # Begins Image Creation
			ConfigSet # Adds Network Interfaces
			AddDiskImage # Completes Image Creation
			Provvms
}
		"*ubuntu*" {
			WriteConfigVM
			CreateStorage
			AvailSet
			ConfigNet  #Sets network connection info
			MakeImageNoPlanInfo_Ubuntu # Begins Image Creation
			ConfigSet # Adds Network Interfaces
			AddDiskImage # Completes Image Creation
			Provvms
}
		"*f5bigip*" {
			WriteConfigVM
			CreateStorage
			AvailSet
			ConfigNet  #Sets network connection info
			MakeImagePlanInfo_f5_bigip_good_byol # Begins Image Creation
			ConfigSet # Adds Network Interfaces
			AddDiskImage # Completes Image Creation
			Provvms
}
		"*f5appfire*" {
			WriteConfigVM
			CreateStorage
			AvailSet
			ConfigNet  #Sets network connection info
			MakeImagePlanInfo_f5_webappfire_byol # Begins Image Creation
			ConfigSet # Adds Network Interfaces
			AddDiskImage # Completes Image Creation
			Provvms
}
		"*barrahourngfw*" {
			WriteConfigVM
			CreateStorage
			AvailSet
			ConfigNet  #Sets network connection info
			MakeImagePlanInfo_Barracuda_ng_firewall_hourly # Begins Image Creation
			ConfigSet # Adds Network Interfaces
			AddDiskImage # Completes Image Creation
			Provvms
}
		"*barrabyolngfw*" {
			WriteConfigVM
			CreateStorage
			AvailSet
			ConfigNet  #Sets network connection info
			MakeImagePlanInfo_Barracuda_ng_firewall_byol # Begins Image Creation
			ConfigSet # Adds Network Interfaces
			AddDiskImage # Completes Image Creation
			Provvms
}
		"*barrahourspam*" {
			WriteConfigVM
			CreateStorage
			AvailSet
			ConfigNet  #Sets network connection info
			MakeImagePlanInfo_Barracuda_spam_firewall_hourly # Begins Image Creation
			ConfigSet # Adds Network Interfaces
			AddDiskImage # Completes Image Creation
			Provvms
}
		"*barrabyolspam*" {
			WriteConfigVM
			CreateStorage
			AvailSet
			ConfigNet  #Sets network connection info
			MakeImagePlanInfo_Barracuda_spam_firewall_byol # Begins Image Creation
			ConfigSet # Adds Network Interfaces
			AddDiskImage # Completes Image Creation
			Provvms
}
		"*sap*" {
			WriteConfigVM
			CreateStorage
			AvailSet
			ConfigNet  #Sets network connection info
			MakeImagePlanInfo_SAP_ase # Begins Image Creation
			ConfigSet # Adds Network Interfaces
			AddDiskImage # Completes Image Creation
			Provvms
}
		"*solarwinds*" {
			WriteConfigVM
			CreateStorage
			AvailSet
			ConfigNet  #Sets network connection info
			MakeImagePlanInfo_SolarWinds # Begins Image Creation
			ConfigSet # Adds Network Interfaces
			AddDiskImage # Completes Image Creation
			Provvms
}
		"*hadoop*" {
			WriteConfigVM
			CreateStorage
			AvailSet
			ConfigNet  #Sets network connection info
			MakeImagePlanInfo_Bitnami_hadoop # Begins Image Creation
			ConfigSet # Adds Network Interfaces
			AddDiskImage # Completes Image Creation
			Provvms
}
		"*tomcat*" {
			WriteConfigVM
			CreateStorage
			AvailSet
			ConfigNet  #Sets network connection info
			MakeImagePlanInfo_Bitnami_tomcat # Begins Image Creation
			ConfigSet # Adds Network Interfaces
			AddDiskImage # Completes Image Creation
			Provvms
}
		"*redis*" {
			WriteConfigVM
			CreateStorage
			AvailSet
			ConfigNet  #Sets network connection info
			MakeImagePlanInfo_Bitnami_redis # Begins Image Creation
			ConfigSet # Adds Network Interfaces
			AddDiskImage # Completes Image Creation
			Provvms
}
		"*neos*" {
			WriteConfigVM
			CreateStorage
			AvailSet
			ConfigNet  #Sets network connection info
			MakeImagePlanInfo_Bitnami_neos # Begins Image Creation
			ConfigSet # Adds Network Interfaces
			AddDiskImage # Completes Image Creation
			Provvms
}
		"*gitlab*" {
			WriteConfigVM
			CreateStorage
			AvailSet
			ConfigNet  #Sets network connection info
			MakeImagePlanInfo_Bitnami_gitlab # Begins Image Creation
			ConfigSet # Adds Network Interfaces
			AddDiskImage # Completes Image Creation
			Provvms
}
		"*jruby*" {
			WriteConfigVM
			CreateStorage
			AvailSet
			ConfigNet  #Sets network connection info
			MakeImagePlanInfo_Bitnami_jrubystack # Begins Image Creation
			ConfigSet # Adds Network Interfaces
			AddDiskImage # Completes Image Creation
			Provvms
}
		"*jenkins*" {
			WriteConfigVM
			CreateStorage
			AvailSet
			ConfigNet  #Sets network connection info
			MakeImagePlanInfo_Bitnami_jenkins # Begins Image Creation
			ConfigSet # Adds Network Interfaces
			AddDiskImage # Completes Image Creation
			Provvms
}
		default{"An unsupported image was referenced"}
	}
}

Function ExtCompatWin {
if($vmMarketImage -eq 'w2k12') {Write-Host "Found Windows $vmMarketImage"}
	elseif($vmMarketImage -eq 'w2k8') {Write-Host "Found Windows $vmMarketImage"}
		elseif($vmMarketImage -eq 'w2k16') {Write-Host "Found Windows $vmMarketImage"}
			elseif($vmMarketImage -eq 'share2013'){Write-Host "Found Windows $vmMarketImage"}
				elseif($vmMarketImage -eq 'sql2016') {Write-Host "Found Windows $vmMarketImage"}
					elseif($vmMarketImage -eq 'share2016') {Write-Host "Found Windows $vmMarketImage"}
else {
Write-Host "No Compatble OS Found, please verify the extension is compatible with $vmMarketImage"
exit
}
}
Function ExtCompatLin {
if($vmMarketImage -eq 'red67') {Write-Host "Found Linux" $vmMarketImage}
	elseif($vmMarketImage -eq 'suse') {Write-Host "Found Linux $vmMarketImage"}
		elseif($vmMarketImage -eq 'ubuntu') {Write-Host "Found Linux $vmMarketImage"}
			elseif($vmMarketImage -eq 'free'){Write-Host "Found Linux $vmMarketImage"}
				elseif($vmMarketImage -eq 'centos') {Write-Host "Found Linux $vmMarketImage"}
					elseif($vmMarketImage -eq 'red72') {Write-Host "Found Linux $vmMarketImage"}
else {
Write-Host "No Compatble OS Found, please verify the extension is compatible with $vmMarketImage"
exit
}
}
Function TestUpload {
$folderexist = Test-Path -Path $localFolder
if(!$folderexist)
{
Write-Host "Folder Doesn't Exist"
exit }
else
{ Upload }
}

Function Upload {
$Keys = Get-AzureRmStorageAccountKey -ResourceGroupName $rg -Name $StorageName;
$StorageContext = New-AzureStorageContext -StorageAccountName $StorageName -StorageAccountKey $Keys[0].Value;
New-AzureStorageContainer -Context $StorageContext -Name $containerName;
$storageAccountKey = Get-AzureRmStorageAccountKey -ResourceGroupName $rg -Name $StorageName;
$blobContext = New-AzureStorageContext -StorageAccountName $StorageName -StorageAccountKey $Keys[0].Value;
$files = Get-ChildItem $localFolder
foreach($file in $files)
{
  $fileName = "$localFolder\$file"
  $blobName = "$file"
  write-host "copying $fileName to $blobName"
  Set-AzureStorageBlobContent -File $filename -Container $containerName -Blob $blobName -Context $blobContext -Force -BlobType Append
  Get-AzureStorageBlob -Container $containerName -Context $blobContext -Blob $blobName
}
write-host "All files in $localFolder uploaded to $containerName!"
}

Function UnInstallExt {
	param(
		[string]$Location = $Location,
		[string]$rg = $rg,
		[string]$VMName = $VMName,
		[string]$customextname = $customextname

	)
switch ($AzExtConfig)
	{
		"access" {
Write-Host "VM Access Agent VM Image Preparation in Process"
Remove-AzureRmVMAccessExtension -ResourceGroupName $rg -VMName $VMName -Name "VMAccess" -Force -Confirm:$false
}
		"msav" {
Write-Host "MSAV Agent VM Image Preparation in Process"
Remove-AzureRmVMExtension -Name "MSAVExtension" -ResourceGroupName $rg -VMName $VMName -Force -Confirm:$false
}
		"customscript" {
Write-Host "Updating server with custom script"
}
		"diag" {
Write-Host "Removing Azure Enhanced Diagnostics"
Remove-AzureRmVMAEMExtension -ResourceGroupName $rg -VMName $VMName
}
		"domjoin" {
Write-Host "Domain Join active"
}
		"linuxOsPatch" {
Write-Host "Adding Azure OS Patching Linux"
		}
		"linuxbackup" {
Write-Host "Removing Linux VMBackup"
Remove-AzureRmVMBackup -ResourceGroupName $rg -VMName $VMName -Tag "OSBackup"
		}
		"chefAgent" {
Write-Host "Adding Chef Agent"
}
		"opsinsightLinux" {
Write-Host "Adding Linux Insight Agent"
}
		"opsinsightWin" {
Write-Host "Adding Windows Insight Agent"
}
		"ESET" {
Write-Host "Setting File Security"
}
		"RegisterAzDSC" {
Write-Host "Registering with Azure Automation DSC"
}
		"WinPuppet" {
Write-Host "Deploying Puppet Extension"
}
		default{"An unsupported uninstall Extension command was used"
break
}
	}
} # Deploys Azure Extensions

Function InstallExt {
	param(
		[string]$AzExtConfig = $AzExtConfig,
		[string]$NSGName = $NSGName,
		[string]$Location = $Location,
		[string]$rg = $rg,
		[string]$StorageName = $StorageName,
		[string]$VMName = $VMName,
		[string]$containerName = $containerName,
		[string]$DomName = $DomName,
		[string]$customextname = $customextname

	)
switch ($AzExtConfig)
	{
		"access" {
ExtCompatWin
Write-Host "VM Access Agent VM Image Preparation in Process"
Set-AzureRmVMAccessExtension -ResourceGroupName $rg -VMName $VMName -Name "VMAccess" -typeHandlerVersion "2.0" -Location $Location -Verbose -username $locadmin -password $locpassword | Out-Null
Get-AzureRmVMAccessExtension -ResourceGroupName $rg -VMName $VMName -Name "VMAccess" -Status
$Description = "Added VM Access Extension"
Log-Command -Description $Description -LogFile $LogOutFile
}
		"msav" {
ExtCompatWin
Write-Host "MSAV Agent VM Image Preparation in Process"
Set-AzureRmVMExtension  -ResourceGroupName $rg -VMName $VMName -Name "MSAVExtension" -ExtensionType "IaaSAntimalware" -Publisher "Microsoft.Azure.Security" -typeHandlerVersion 1.4 -Location $Location | Out-Null
Get-AzureRmVMExtension -ResourceGroupName $rg -VMName $VMName -Name "MSAVExtension" -Status
$Description = "Added VM msav Extension"
Log-Command -Description $Description -LogFile $LogOutFile
}
		"customscript" {
Write-Host "Updating server with custom script"
if($CustomScriptUpload -eq 'True')
{
TestUpload
}
Set-AzureRmVMCustomScriptExtension -Name $customextname -ContainerName $containerName -ResourceGroupName $rg -VMName $VMName -StorageAccountName $StorageName -FileName $scriptname -Location $Location -TypeHandlerVersion "1.1" | Out-Null
Get-AzureRmVMCustomScriptExtension -ResourceGroupName $rg -VMName $VMName -Name $customextname -Status | Out-Null
$Description = "Added VM Custom Script Extension"
Log-Command -Description $Description -LogFile $LogOutFile
}
		"diag" {
Write-Host "Adding Azure Enhanced Diagnostics"
Set-AzureRmVMAEMExtension -ResourceGroupName $rg -VMName $VMName -WADStorageAccountName $StorageName -InformationAction SilentlyContinue -WarningAction SilentlyContinue | Out-Null
Get-AzureRmVMAEMExtension -ResourceGroupName $rg -VMName $VMName | Out-Null
$Description = "Added VM Enhanced Diag Extension"
Log-Command -Description $Description -LogFile $LogOutFile
}
		"domjoin" {
ExtCompatWin
$DomName = 'aip.local'
Write-Host "Domain Join active"
Set-AzureRmVMADDomainExtension -DomainName $DomName -ResourceGroupName $rg -VMName $VMName -Location $Location -Name 'DomJoin' -WarningAction SilentlyContinue -Restart | Out-Null
Get-AzureRmVMADDomainExtension -ResourceGroupName $rg  -VMName $VMName -Name 'DomJoin' | Out-Null
$Description = "Added VM Domain Join Extension"
Log-Command -Description $Description -LogFile $LogOutFile
}
		"linuxOsPatch" {
ExtCompatLin
Write-Host "Adding Azure OS Patching Linux"
Set-AzureRmVMExtension -VMName $VMName -ResourceGroupName $rg -Location $Location -Name "OSPatch" -ExtensionType "OSPatchingForLinux" -Publisher "Microsoft.OSTCExtensions" -typeHandlerVersion "2.0" -InformationAction SilentlyContinue -Verbose
Get-AzureRmVMExtension -ResourceGroupName $rg -VMName $VMName -Name "OSPatch"
$Description = "Added VM OS Patch Extension"
Log-Command -Description $Description -LogFile $LogOutFile
		}
		"linuxbackup" {
ExtCompatLin
Write-Host "Adding Linux VMBackup"
Set-AzureRmVMBackupExtension -VMName $VMName -ResourceGroupName $rg -Name "VMBackup" -Tag "OSBackup" -WarningAction SilentlyContinue | Out-Null
$Description = "Added VM Backup Extension"
Log-Command -Description $Description -LogFile $LogOutFile
		}
		"chefAgent" {
Write-Host "Adding Chef Agent"
$ProtectedSetting = ''
$Setting = ''
Set-AzureRmVMExtension -ResourceGroupName $rg -VMName $VMName -Name "ChefStrap" -ExtensionType "ChefClient" -Publisher "Chef.Bootstrap.WindowsAzure" -typeHandlerVersion "1210.12" -Location $Location -Verbose -ProtectedSettingString $ProtectedSetting -SettingString $Setting | Out-Null
Get-AzureRmVMExtension -ResourceGroupName $rg -VMName $VMName -Name "ChefStrap"
$Description = "Added VM Chef Extension"
Log-Command -Description $Description -LogFile $LogOutFile
}
		"opsinsightLinux" {
ExtCompatLin
Write-Host "Adding Linux Insight Agent"
Set-AzureRmVMExtension -VMName $VMName -ResourceGroupName $rg -Location $Location -Name "OperationalInsights" -ExtensionType "OmsAgentForLinux" -Publisher "Microsoft.EnterpriseCloud.Monitoring" -typeHandlerVersion "1.0" -InformationAction SilentlyContinue -Verbose | Out-Null
Get-AzureRmVMExtension -ResourceGroupName $rg -VMName $VMName -Name "OperationalInsights"
$Description = "Added OpsInsight Extension"
Log-Command -Description $Description -LogFile $LogOutFile
}
		"opsinsightWin" {
ExtCompatWin
Write-Host "Adding Windows Insight Agent"
Set-AzureRmVMExtension -VMName $VMName -ResourceGroupName $rg -Location $Location -Name "OperationalInsights" -ExtensionType "MicrosoftMonitoringAgent" -Publisher "Microsoft.EnterpriseCloud.Monitoring" -typeHandlerVersion "1.0" -InformationAction SilentlyContinue -Verbose | Out-Null
Get-AzureRmVMExtension -ResourceGroupName $rg -VMName $VMName -Name "OperationalInsights"
$Description = "Added OpsInsight Extension"
Log-Command -Description $Description -LogFile $LogOutFile
}
		"ESET" {
ExtCompatWin
Write-Host "Setting File Security"
Set-AzureRmVMExtension -VMName $VMName -ResourceGroupName $rg -Location $Location -Name "ESET" -ExtensionType "FileSecurity" -Publisher "ESET" -typeHandlerVersion "6.0" -InformationAction SilentlyContinue -Verbose | Out-Null
Get-AzureRmVMExtension -ResourceGroupName $rg -VMName $VMName -Name "ESET"
$Description = "Added ESET Extension"
Log-Command -Description $Description -LogFile $LogOutFile
}
		"RegisterAzDSC" {
Write-Host "Registering with Azure Automation DSC"
$ActionAfterReboot = 'ContinueConfiguration'
$configmode = 'ApplyAndAutocorrect'
$AutoAcctName = $Azautoacct
$NodeName = -join $VMNAME+".node"
$ConfigurationName = -join $VMNAME+".node"
Register-AzureRmAutomationDscNode -AutomationAccountName $AutoAcctName -AzureVMName $VMName -ActionAfterReboot $ActionAfterReboot -ConfigurationMode $configmode -RebootNodeIfNeeded $True -ResourceGroupName $rg -NodeConfigurationName $ConfigurationName -AzureVMLocation $Location -AzureVMResourceGroup $rg -Verbose | Out-Null
$Description = "Registered with Azure Automation DSC"
Log-Command -Description $Description -LogFile $LogOutFile
}
		"WinPuppet" {
ExtCompatWin
Write-Host "Deploying Puppet Extension"
Set-AzureRmVMExtension -VMName $VMName -ResourceGroupName $rg -Location $Location -Name "PuppetEnterpriseAgent" -ExtensionType "PuppetEnterpriseAgent" -Publisher "PuppetLabs" -typeHandlerVersion "3.2" -InformationAction SilentlyContinue -Verbose | Out-Null
Get-AzureRmVMExtension -ResourceGroupName $rg -VMName $VMName -Name "PuppetEnterpriseAgent"
$Description = "Added Puppet Agent Extension"
Log-Command -Description $Description -LogFile $LogOutFile
}
		default{"An unsupported Extension command was used"
break
}
	}
} # Deploys Azure Extensions

Function OrphanCleanup {
	param(
	[Parameter(Mandatory=$False,ValueFromPipelinebyPropertyName=$true)]
	[string]
	$InterfaceName1 = $VMName + "_nic1",
	[Parameter(Mandatory=$False,ValueFromPipelinebyPropertyName=$true)]
	[string]
	$InterfaceName2 = $VMName + "_nic2",
	[string]$Location = $Location,
	[string]$rg = $rg,
	[string]$VMName = $VMName
	)
$extvm = Get-AzureRmVm -Name $VMName -ResourceGroupName $rg -ErrorAction SilentlyContinue
$nic1 = Get-AzureRmNetworkInterface -Name $InterfaceName1 -ResourceGroupName $rg -ErrorAction SilentlyContinue
$nic2 = Get-AzureRmNetworkInterface -Name $InterfaceName2 -ResourceGroupName $rg -ErrorAction SilentlyContinue
$pubip =  Get-AzureRmPublicIpAddress -Name $InterfaceName1 -ResourceGroupName $rg -ErrorAction SilentlyContinue

if($extvm)
{ Write-Host "Host VM Found, cleanup cannot proceed" -ForegroundColor Cyan
 Start-sleep 5
Exit }
else {if($nic1)
{ Write-Host "Removing orphan $InterfaceName1" -ForegroundColor White
Remove-AzureRmNetworkInterface -Name $InterfaceName1 -ResourceGroupName $rg -Force -Confirm:$False
$LogOut = "Removed $InterfaceName1 - Private Adapter"
Log-Command -Description $LogOut -LogFile $LogOutFile
 }
	 if($pubip)
{
Remove-AzureRmPublicIpAddress -Name $InterfaceName1 -ResourceGroupName $rg -Force -Confirm:$False
$LogOut = "Removed $InterfaceName1 - Public Ip"
Log-Command -Description $LogOut -LogFile $LogOutFile
}
	 if($nic2)
{ Write-Host "Removing orphan $InterfaceName2" -ForegroundColor White
Remove-AzureRmNetworkInterface -Name $InterfaceName2 -ResourceGroupName $rg -Force -Confirm:$False
$LogOut = "Removed $InterfaceName2 - Private Adapter"
Log-Command -Description $LogOut -LogFile $LogOutFile
 }
 else {Write-Host "No orphans found." -ForegroundColor Green}
 exit
 }
} #

Function OrphanChk {
	param(
	[Parameter(Mandatory=$False,ValueFromPipelinebyPropertyName=$true)]
	[string]
	$InterfaceName1 = $VMName + "_nic1",
	[Parameter(Mandatory=$False,ValueFromPipelinebyPropertyName=$true)]
	[string]
	$InterfaceName2 = $VMName + "_nic2",
	[string]$Location = $Location,
	[string]$rg = $rg,
	[string]$VMName = $VMName
	)
$extvm = Get-AzureRmVm -Name $VMName -ResourceGroupName $rg -ErrorAction SilentlyContinue
$nic1 = Get-AzureRmNetworkInterface -Name $InterfaceName1 -ResourceGroupName $rg -ErrorAction SilentlyContinue
$nic2 = Get-AzureRmNetworkInterface -Name $InterfaceName2 -ResourceGroupName $rg -ErrorAction SilentlyContinue
$pubip =  Get-AzureRmPublicIpAddress -Name $InterfaceName1 -ResourceGroupName $rg -ErrorAction SilentlyContinue

if($extvm)
{ Write-Host "Host VM Found, please use a different VMName for Provisioning or manually delete the existing VM" -ForegroundColor Cyan
 Start-sleep 10
Exit }
else {if($nic1)
{ Write-Host "Removing orphan $InterfaceName1" -ForegroundColor White
Remove-AzureRmNetworkInterface -Name $InterfaceName1 -ResourceGroupName $rg -Force -Confirm:$False
$LogOut = "Removed $InterfaceName1 - Private Adapter"
Log-Command -Description $LogOut -LogFile $LogOutFile
 }
	 if($pubip)
{
Remove-AzureRmPublicIpAddress -Name $InterfaceName1 -ResourceGroupName $rg -Force -Confirm:$False
$LogOut = "Removed $InterfaceName1 - Public Ip"
Log-Command -Description $LogOut -LogFile $LogOutFile
}
	 if($nic2)
{ Write-Host "Removing orphan $InterfaceName2" -ForegroundColor White
Remove-AzureRmNetworkInterface -Name $InterfaceName2 -ResourceGroupName $rg -Force -Confirm:$False
$LogOut = "Removed $InterfaceName2 - Private Adapter"
Log-Command -Description $LogOut -LogFile $LogOutFile
 }
 else {Write-Host "No orphans found." -ForegroundColor Green}
 }
} #

Function Remove-azRg
{
Param(
		[Parameter(Mandatory=$False,ValueFromPipelinebyPropertyName=$true,Position=0)]
		[string]
		$rg = $rg
)
Write-Host "Removing RG "
Get-AzureRmResourceGroup -Name $rg | Remove-AzureRmResourceGroup -Verbose -Force -Confirm:$False
}

Function Remove-azVM
{
Param(
		[Parameter(Mandatory=$False,ValueFromPipelinebyPropertyName=$true,Position=1)]
		[string]
		$rg = $rg,
		[Parameter(Mandatory=$False,ValueFromPipelinebyPropertyName=$true,Position=0)]
		[string]
		$VMName = $VMName
)
Write-Host "Removing VM"
Remove-AzureRmVm -Name $VMName -ResourceGroupName $rg -ErrorAction Stop -Confirm:$False -Force | ft Status,StartTime,EndTime | Format-Table
$LogOut = "Removed $VMName from RG $rg"
Log-Command -Description $LogOut -LogFile $LogOutFile
}

Function Remove-azNSG
{
Param(
		[Parameter(Mandatory=$False,ValueFromPipelinebyPropertyName=$true,Position=1)]
		[string]
		$rg = $rg,
		[Parameter(Mandatory=$False,ValueFromPipelinebyPropertyName=$true,Position=0)]
		[string]
		$NSGName = $NSGName
)
Write-Host "Removing NSG"
Remove-AzureRmNetworkSecurityGroup -Name $NSGName -ResourceGroupName $rg -WarningAction SilentlyContinue -ErrorAction Stop -Force -Confirm:$False | Format-Table
$LogOut = "Removed $NSGName"
Log-Command -Description $LogOut -LogFile $LogOutFile
}

Function Remove-azVNET
{
Param(
		[Parameter(Mandatory=$False,ValueFromPipelinebyPropertyName=$true,Position=1)]
		[string]
		$rg = $rg,
		[Parameter(Mandatory=$False,ValueFromPipelinebyPropertyName=$true,Position=0)]
		[string]
		$VNETName = $VNETName
)
Write-Host "Removing VNET"
Remove-AzureRmVirtualNetwork -Name $VNETName -ResourceGroupName $rg -Confirm:$False -Force
 $LogOut = "Removed $VNETName"
Log-Command -Description $LogOut -LogFile $LogOutFile
}

Function Remove-AzStorage
{
Param(
		[Parameter(Mandatory=$False,ValueFromPipelinebyPropertyName=$true,Position=1)]
		[string]
		$rg = $rg,
		[Parameter(Mandatory=$False,ValueFromPipelinebyPropertyName=$true,Position=0)]
		[string]
		$Name = $storagename
)
Write-Host "Removing Storage"
Remove-AzureRMStorageAccount -Name $Name -ResourceGroupName $rg -WarningAction SilentlyContinue -Force -Confirm:$False
 $LogOut = "Removed $Name"
Log-Command -Description $LogOut -LogFile $LogOutFile
}

Function Remove-AzAvailabilitySet
{
Param(
		[Parameter(Mandatory=$False,ValueFromPipelinebyPropertyName=$true,Position=1)]
		[string]
		$rg = $rg,
		[Parameter(Mandatory=$False,ValueFromPipelinebyPropertyName=$true,Position=0)]
		[string]
		$AvailSetName = $AvailSetName
)
Write-Host "Removing Availability Set"
Remove-AzureRmAvailabilitySet -ResourceGroupName $rg -Confirm:$False -Force -Name $AvailSetName
 $LogOut = "Removed $AvailSetName"
Log-Command -Description $LogOut -LogFile $LogOutFile
}

Function RemoveComponent {
	param(
		[string]$RemoveObject = $RemoveObject
	)

switch ($RemoveObject)
	{
		"rg" {
Remove-azRg
break
}
		"vm" {
Remove-azVM
OrphanCleanup
}
		"nsg" {
Remove-azNSG
break
}
		"vnet" {
Remove-azVNET
break
}
		"storage" {
Remove-AzStorage
break
}
		"availabilityset" {
Remove-AzAvailabilitySet
break
}
		default{"An unsupported uninstall Extension command was used"
break
}
	}
} # Deploys Azure Extensions

# Fuctions
Function AzureVersion{
$name='Azure'
if(Get-Module -ListAvailable |
	Where-Object { $_.name -eq $name })
{
$ver = (Get-Module -ListAvailable | Where-Object{ $_.Name -eq $name }) |
	select version -ExpandProperty version
	Write-Host "current Azure PowerShell Version:" $ver
$currentver = $ver
	if($currentver-le '2.0.0'){
	Write-Host "expected version 2.0.1 found $ver" -ForegroundColor DarkRed
	exit
	}
}
else
{
	Write-Host “The Azure PowerShell module is not installed.”
	exit
}
}

##--------------------------- Begin Script Execution -------------------------------------------------------##
# Global
$date = Get-Date -UFormat "%Y-%m-%d-%H-%M"
$workfolder = Split-Path $script:MyInvocation.MyCommand.Path
$LogOutFile = $workfolder+'\'+$vmname+'-'+$date+'.log'
$ProfileFile = $workfolder+'\'+$profile+'.json'

AzureVersion # Verifies Azure client Powershell Version
if($help) {
Help-User
exit
}
validate-profile # Attempts to use json file for auth, falls back on Add-AzureRmAccount

try {
Get-AzureRmResourceGroup -Location $Location -ErrorAction Stop | Out-Null
}
catch {
	Write-Host -foregroundcolor Yellow `
	"User has not authenticated, use Add-AzureRmAccount or $($_.Exception.Message)"; `
	continue
}

 $resourceProviders = @("microsoft.compute","microsoft.network","microsoft.storage");
 if($resourceProviders.length) {
	Write-Host "Registering resource providers"
	foreach($resourceProvider in $resourceProviders) {
		RegisterRP($resourceProvider);
	}
 } # Get Resource Providers
if($getinfo){ Get-Azinfo }
Write-Output "Steps will be tracked on the log file : [ $LogOutFile ]"
if($RemoveObject){ RemoveComponent }

chknull # Verifies required fields have data
OrphanChk # Verifies no left overs
VerifyNet
StorageNameCheck # Verifies Storage Account Name does not exist

$resourcegroups = @($rg,$vnetrg);
if($resourcegroups.length) {
	foreach($resourcegroup in $resourcegroups) {
		ProvisionResGrp($resourcegroup);
	}
} # Create Resource Groups

# WriteConfig # Provides Pre-Deployment Description
WriteConfigVNet
if($AddVnet){CreateVnet} # Creates VNET

if($NSGEnabled){CreateNSG} # Creates NSG and Security Groups

CreateVM # Configure Image

if($NSGEnabled){NSGEnabled} #Adds NSG to NIC

if($AddExtension){InstallExt} #Installs Azure Extensions

if($AddVPN -eq 'True'){
CreateVPN
ConnectVPN
} #Creates VPN