<#
.SYNOPSIS
Written By John Lewis
email: jonos@live.com
Ver 7.0
This script provides the following functionality for deploying IaaS environments in Azure. The script will deploy VNET in addition to numerous Market Place VMs or make use of an existing VNETs.
The script supports dual homed servers (PFSense/Checkpoint/FreeBSD/F5/Barracuda)
The script supports deploying Availability Sets as well as adding new servers to existing Availability Sets through the -AvailabilitySet and -AvailSetName switches.
The script supports deploying Azure Extensions through the -AddExtensions switch.
The script will create three directories if they do not exist in the runtime directory, Log, Scripts, DSC.

v7.0 updates - Updates for Azure PowerShell 3.0
v6.9 updates - Exception Handling generates to log file
v6.8 updates - Added Core parameters for -Action-Type Update, Create and Remove
v6.7 updates - Created -updateextension swith for OOB deployments of extensions to existing Azure VMs
v6.6 updates - Added CSV Import command and csv file name parameter, script now supports csv execution.
v6.5 updates - Custom Scripts directory and logs directory will now be created in the scripts execution directory.
v6.4 updates - Added Cloudera, cloud-connector, datastax to image offerings
v6.3 updates - DSC Push Configuration added to Extensions
v6.2 updates - Added 12 new images including Biztalk, Visual Studio, TFS, Incredibuild, HortonWorks, Dev15, ASR (Azure Site Recovery) Images
v6.11 updates - Modified Profile to save to script execution directory, added -help switch.
v6.0 updates - Added Remove Functions to script, added subnet correction validation for static IPs and Storage
v5.9 updates - Moved -add parameters to [switch]

.DESCRIPTION
Deploys 45 different Market Images on a new or existing VNET. Supports post deployment configuration through Azure Extensions.
Market Images supported: Redhat 6.7 and 7.2, PFSense 2.5, Windows 2008 R2, Windows 2012 R2, Ubuntu 14.04, CentOs 7.2, SUSE, SQL 2016 (on W2K12R2), R Server on Windows, Windows 2016 (Preview), Checkpoint Firewall, FreeBsd, Puppet, Splunk, Bitnami Lamp, Bitnami PostGresSql, Bitnami nodejs, Bitnami Elastics, Bitnami MySql, SharePoint 2013/2016, Barracuda NG, Barracuda SPAM, F5 BigIP, F5 App Firewall, Bitnami JRuby, Bitnami Neos, Bitnami TomCat, Bitnami redis, Bitnami hadoop, Incredibuild, VS 2015, Dev15 Preview, Tableau, MS NAV, TFS, Ads Data Science Server, Biztalk 2013/2016, HortonWorks, Cloudera, DataStax

.PARAMETER vmMarketImage

.PARAMETER VMName

.PARAMETER rg

.PARAMETER vnetrg

.PARAMETER AddVnet

.PARAMETER BatchAddVnet

.PARAMETER VNetName

.PARAMETER ConfigIPs

.PARAMETER CreateNSG

.PARAMETER BatchAddNSG

.PARAMETER RemoveObject

.PARAMETER VMSize

.PARAMETER locadmin

.PARAMETER locpassword

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

.PARAMETER BatchAddAvSet

.PARAMETER AvailSetName

.PARAMETER DNLabel

.PARAMETER AddFQDN

.PARAMETER BatchAddFQDN

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

.PARAMETER Profile

.PARAMETER AzExtConfig

.PARAMETER AddExtension

.PARAMETER UpdateExtension

.PARAMETER BatchAddExtension

.PARAMETER RemoveExtension

.PARAMETER CustomScriptUpload

.PARAMETER dscname

.PARAMETER scriptname

.PARAMETER containername

.PARAMETER customextname

.PARAMETER scriptfolder

.PARAMETER localfolder

.PARAMETER infoset

.PARAMETER getinfo

.PARAMETER csvimport

.PARAMETER csvfile

.PARAMETER help

.EXAMPLE
\.AZRM-VMDeploy.ps1 -csvimport -csvfile C:\temp\iaasdeployment.csv
.EXAMPLE
\.AZRM-VMDeploy.ps1 -ActionType Create -vm pf001 -image pfsense -rg ResGroup1 -vnetrg ResGroup2 -addvnet -vnet VNET -sub1 3 -sub2 4 -ConfigIPs DualPvtNoPub -Nic1 10.120.2.7 -Nic2 10.120.3.7
.EXAMPLE
\.AZRM-VMDeploy.ps1 -ActionType Create -vm red76 -image red67 -rg ResGroup1 -vnetrg ResGroup2 -vnet VNET -sub1 7 -ConfigIPs SinglePvtNoPub -Nic1 10.120.6.124 -Ext linuxbackup
.EXAMPLE
\.AZRM-VMDeploy.ps1 -ActionType Create -vm win006 -image w2k12 -rg ResGroup1 -vnetrg ResGroup2 -vnet VNET -sub1 2 -ConfigIPs Single -AvSet -CreateNSG -NSGName NSG
.EXAMPLE
\.AZRM-VMDeploy.ps1 -ActionType Create -vm win008 -image w2k16 -rg ResGroup1 -vnetrg ResGroup2 -vnet VNET -sub1 5 -ConfigIPs PvtSingleStat -Nic1 10.120.4.169 -AddFQDN -fqdn mydns1
.EXAMPLE
\.AZRM-VMDeploy.ps1 -ActionType Create -vm ubu001 -image ubuntu -RG ResGroup1 -vnetrg ResGroup2 -VNet VNET -sub1 6 -ConfigIPs PvtSingleStat -Nic1 10.120.5.169 -AddFQDN fqdn mydns2
.EXAMPLE
\.AZRM-VMDeploy.ps1 -ActionType remove -vm ubu001 -RG ResGroup1 -RemoveObject VM
.EXAMPLE
\.AZRM-VMDeploy.ps1 -ActionType remove -RG ResGroup1 -RemoveObject rg
.NOTES
-ConfigIps  <Configuration>
			PvtSingleStat & PvtDualStat – Deploys the server with a Public IP and the private IP(s) specified by the user.
			NoPubSingle & NoPubDual - Deploys the server without Public IP using automatically generated private IP(s).
			Single & Dual – Deploys the default configuration of a Public IP and automatically generated private IP(s).
			StatPvtNoPubDual & StatPvtNoPubSingle – Deploys the server without a Public IP using the private IP(s) specified by the user.
-VMMarketImage <Image ShortName>

			Windows 2012 R2 – w2k12
			Windows 2008 R2 – w2k8
			Windows 2016 – w2k16
			SharePoint 2016 - Share2016
			SharePoint 2013 - share2013
			Biztalk 2013 Ent - biztalk2013
			Biztalk 2016 preview - biztalk2016
			TFS 2013 - tfs
			Visual Studio 2015 Ent on W2k12 r2 - vs2015
			Dev15 - Preview - dev15
			SQL Server 2016 (on Windows 2012 host) – sql2016
			PFSense 2.5 – pfsense
			Free BSD – free
			Suse – suse
			CentOs 7.2 – centos
			Ubuntu 14.04 – ubuntu
			Redhat 6.7 – Red67
			Redhat 7.2 – Red72
			CheckPoint AppFirewall – check
			Chef Server v12 - 100 Client - chef
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
			F5 BIG IP - f5bigip
			F5 Application Firewall - f5appfire
			Barracuda NG Firewall (hourly) - barrahourngfw
			Barracuda NG Firewall (BYOL) - barrabyolngfw
			Barracuda spam Firewall (hourly) - barrahourspam
			Barracuda spam Firewall (byol) - barrabyolspam
			Server R - serverr
			Hortonworks DataPlatform - horton-dp
			Incredibuild - Incredibuild
			Microsoft Ads - Data Science Standard Server - ads-datascience
			Microsoft Ads - Data Science Linux Server - ads-linuxdatascience
			Cloudera - cloudera
			DataStax - datastax
			Cloud-connector - cloud-conn
			Tableau Desktop - tableau
			metavistech O365 Suite - O365-suite

-AzExtConfig <Extension Type>
			access – Adds Azure Access Extension – Added by default during VM creation
			msav – Adds Azure Antivirus Extension
			custScript – Adds Custom Script for Execution (Requires Table Storage Configuration first)
			pushdsc - Deploys DSC Configuration to Azure VM
			diag – Adds Azure Diagnostics Extension
			linuxOsPatch - Deploy Latest updates for Linux platforms
			linuxbackup - Deploys Azure Linux backup Extension
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

[CmdletBinding(DefaultParameterSetName = 'default')]
Param(
[Parameter(Mandatory=$False,ValueFromPipelinebyPropertyName=$true)]
[ValidateSet("remove","create","update")]
[Alias("action")]
[string]
$ActionType = 'create',
[Parameter(Mandatory=$False,ValueFromPipelinebyPropertyName=$true,Position=2)]
[ValidateNotNullorEmpty()]
[ValidateSet("w2k12","w2k8","w2k16","sql2016","biztalk2013","tfs","biztalk2016","vs2015","dev15","incredibuild","msnav2016","red67","red72","suse","free","ubuntu","centos","chef","check","pfsense","lamp","jenkins","nodejs","elastics","postgressql","splunk","horton-dp","serverr","horton-hdp","f5bigip","f5appfire","barrahourngfw","barrabyolngfw","barrahourspam","barrabyolspam","mysql","share2013","share2016","mongodb","nginxstack","hadoop","neos","tomcat","redis","gitlab","jruby","tableau","cloudera","datastax","O365-suite","ads-linuxdatascience","ads-datascience","cloud-conn")]
[Alias("image")]
[string]
$vmMarketImage = 'w2k12',
[Parameter(Mandatory=$False,ValueFromPipelinebyPropertyName=$true,Position=1)]
[ValidateNotNullorEmpty()]
[Alias("vm")]
[string]
$VMName = '',
[ValidateNotNullorEmpty()]
[Parameter(Mandatory=$False,ValueFromPipelinebyPropertyName=$true,Position=0)]
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
[string]
$BatchAddVnet = 'False',
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
$CreateNSG,
[Parameter(Mandatory=$False,ValueFromPipelinebyPropertyName=$true)]
[string]
$BatchAddNSG = 'False',
[Parameter(Mandatory=$False,ValueFromPipelinebyPropertyName=$true)]
[ValidateSet("vm","vnet","rg","nsg","storage","availabilityset")]
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
$Subnet1 = 5,
[Parameter(Mandatory=$False,ValueFromPipelinebyPropertyName=$true)]
[ValidateRange(1,8)]
[ValidateNotNullorEmpty()]
[Alias("sub2")]
[int]
$Subnet2 = 6,
[Parameter(Mandatory=$False,ValueFromPipelinebyPropertyName=$true)]
[ValidateSet("True","False")]
[Alias("avset")]
[switch]
$AddAvailabilitySet,
[Parameter(Mandatory=$False,ValueFromPipelinebyPropertyName=$true)]
[string]
$BatchAddAvSet = 'False',
[Parameter(Mandatory=$False)]
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
[string]
$BatchAddFQDN,
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
[ValidateSet("diag","msav","access","linuxbackup","chefagent","eset","customscript","opsinsightLinux","opsinsightWin","WinPuppet","domjoin","RegisterAzDSC","PushDSC")]
[Alias("ext")]
[string]
$AzExtConfig = 'diag',
[Parameter(Mandatory=$False,ValueFromPipelinebyPropertyName=$true)]
[Alias("addext")]
[switch]
$AddExtension,
[Parameter(Mandatory=$False,ValueFromPipelinebyPropertyName=$true)]
[Alias("oobaddext")]
[switch]
$UpdateExtension,
[Parameter(Mandatory=$False,ValueFromPipelinebyPropertyName=$true)]
[string]
$BatchAddExtension = 'False',
[Parameter(Mandatory=$False,ValueFromPipelinebyPropertyName=$true)]
[string]
$BatchUpdateNSG = 'False',
[Parameter(Mandatory=$False,ValueFromPipelinebyPropertyName=$true)]
[Alias("removeext")]
[switch]
$RemoveExtension,
[Parameter(Mandatory=$False,ValueFromPipelinebyPropertyName=$true)]
[ValidateSet("True","False")]
[Alias("upload")]
[string]
$CustomScriptUpload = 'True',
[Parameter(Mandatory=$False,ValueFromPipelinebyPropertyName=$true)]
[Alias("addvmnsg")]
[switch]
$AddNSG,
[Parameter(Mandatory=$False,ValueFromPipelinebyPropertyName=$true)]
[Alias("dscscriptname")]
[string]
$DSCConfig = 'WIN_MSUpdate',
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
$scriptfolder = $workfolder,
[Parameter(Mandatory=$False,ValueFromPipelinebyPropertyName=$true)]
[string]
$localfolder = "$scriptfolder\scripts",
[Parameter(Mandatory=$False,ValueFromPipelinebyPropertyName=$true)]
[ValidateSet("network","vm","summary","storage")]
[string]
$infoset = 'network',
[Parameter(Mandatory=$False,ValueFromPipelinebyPropertyName=$true)]
[switch]
$getinfo,
[Parameter(Mandatory=$False,ValueFromPipelinebyPropertyName=$true)]
[switch]
$csvimport,
[Parameter(Mandatory=$False,ValueFromPipelinebyPropertyName=$true)]
[string]
$csvfile = -join $workfolder + "\azrm-vmdeploy.csv",
[Parameter(Mandatory=$False,ValueFromPipelinebyPropertyName=$true)]
[Alias("h")]
[Alias("?")]
[switch]
$help
)

$SecureLocPassword=Convertto-SecureString $locpassword –asplaintext -Force
$Credential1 = New-Object System.Management.Automation.PSCredential ($locadmin,$SecureLocPassword)
$Error.Clear()
Set-StrictMode -Version Latest
Trap [System.SystemException] {("Exception" + $_ ) ; break}

#region Validate Profile
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
#endregion

Function WriteLog-Command([string]$Description, [ScriptBlock]$Command, [string]$LogFile, [string]$VMName ){
Try{
$Output = $Description+'  ... '
Write-Host $Output -ForegroundColor Blue
((Get-Date -UFormat "[%d-%m-%Y %H:%M:%S] ") + $Output) | Out-File -FilePath $LogFile -Append –Confirm:$false -Force
$Result = Invoke-Command -ScriptBlock $Command
}
Catch {
$ErrorMessage = $_.Exception.Message
$Output = 'Error '+$ErrorMessage
((Get-Date -UFormat "[%d-%m-%Y %H:%M:%S] ") + $Output) | Out-File -FilePath $LogFile -Append –Confirm:$false -Force
$Result = ""
}
Finally
{
if ($ErrorMessage -eq $null) {$Output = "[Completed]  $Description  ... "} else {$Output = "[Failed]  $Description  ... "}
((Get-Date -UFormat "[%d-%m-%Y %H:%M:%S] ") + $Output) | Out-File -FilePath $LogFile -Append –Confirm:$false -Force
}
Return $Result
}

#region User Help
Function Help-User {
Write-Host "Don't know where to start? Here are some examples:"
Write-Host "                                                       "
Write-Host "Deploy PFSense"
Write-Host "azurerm_deploy.ps1 -vm pf001 -image pfsense -rg ResGroup1 -vnetrg ResGroup2 -vnet VNET -ConfigIPs DualPvtNoPub -Nic1 10.120.2.7 -Nic2 10.120.3.7"
Write-Host "Deploy RedHat"
Write-Host "azurerm_deploy.ps1 -vm red76 -image red67 -rg ResGroup1 -vnetrg ResGroup2 -vnet VNET -ConfigIPs SinglePvtNoPub -Nic1 10.120.6.124 -Ext linuxbackup"
Write-Host "Deploy Windows 2012"
Write-Host "azurerm_deploy.ps1 -vm win006 -image w2k12 -rg ResGroup1 -vnetrg ResGroup2 -vnet VNET -ConfigIPs Single -AvSet -CreateNSG -NSGName NSG"
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
Write-Host "             -CreateNSG - adds new NSG/Configures VM to use existing NSG"
Write-Host "             -addavailabilityset - adds new Availability Set"
Write-Host "             -addfqdn - adds FQDN to Public IP address of VM"
Write-Host "             -addextension - adds VM extension"
Write-Host "                                                       "
}
#endregion

#region Create Log
Function Log-Command ([string]$Description, [string]$logFile, [string]$VMName){
$Output = $LogOut+'. '
Write-Host $Output -ForegroundColor white
((Get-Date -UFormat "[%d-%m-%Y %H:%M:%S] ") + $Output) | Out-File -FilePath $LogOutFile -Append -Force
}
#endregion

#region Use CSV
Function csv-run {
param(
[string] $csvin = $csvfile
)
try {
	$GetPath = test-path -Path $csvin
	if(!$csvin)
	{exit}
	else {
	Write-Host $GetPath "File Exists"
		import-csv -Path $csvin -Delimiter ',' | ForEach-Object{.\AZRM-VMDeploy.ps1 -ActionType $_.ActionType -VMName $_.VMName -vmMarketImage $_.Image -rg $_.rg -vNetrg $_.vnetrg -VNetName $_.VNetName -ConfigIPs $_.ConfigIPs -subnet1 $_.Subnet1 -subnet2 $_.Subnet2 -PvtIPNic1 $_.PvtIPNic1 -PvtIPNic2 $_.PvtIPNic2 -DNLabel $_.DNLabel  -BatchAddVnet $_.BatchAddVnet -BatchAddNSG $_.BatchAddNSG -BatchUpdateNSG $_.BatchUpdateNSG -NSGName $_.NSGName -AzExtConfig $_.AzExtConfig -BatchAddExtension $_.BatchAddExtension -BatchAddAvSet $_.BatchAddAvSet -BatchAddFqdn $_.BatchAddFqdn -CustomScriptUpload $_.CustomScriptUpload -scriptname $_.scriptname -containername $_.containername -scriptfolder $_.scriptfolder -customextname $_.customextname }
	}
}
catch {
	Write-Host -foregroundcolor Yellow `
	"$($_.Exception.Message)"; `
	$LogOut = "$($_.Exception.Message)"
	Log-Command -Description $LogOut -LogFile $LogOutFile
	break
}
}
#endregion

#region Verify Private IP
Function Verify-PvtIp {
		if($PvtIPNic1)
			{
			[int]$subnet = $Subnet1
			$ip = $PvtIPNic1
			$array = $ip.Split(".")
			[int]$subnetint = $array[2]
			[int]$subnetcalc = ($subnetint + 1)
				if($subnetcalc -ne $subnet){
					$script:Subnet1 = $subnetcalc
					Write-Host "Updating Subnet1 to correct subnet"
					Write-Host "Subnet1: $script:Subnet1"
				}
			else
			{
			Write-Host "correct subnet"
			$script:Subnet1 = $Subnet1
			}
	}
}

Function Verify-PvtIp2 {
if($PvtIPNic2)
			{
			[int]$subnet = $Subnet2
			$ip = $PvtIPNic2
			$array = $ip.Split(".")
			[int]$subnetint = $array[2]
			[int]$subnetcalc = ($subnetint + 1)
				if($subnetcalc -ne $subnet){
					$script:Subnet2 = $subnetcalc
					Write-Host "Updating Subnet2 to correct subnet"
					Write-Host "Subnet1: $script:Subnet2"
			}
			else
			{
			Write-Host "correct subnet"
			$script:Subnet2 = $Subnet2
			}
	}
}

Function Verify-NIC {
	If ($ConfigIPs -eq "StatPvtNoPubSingle")
	{
		Write-Host "Subnet IP Validation" -ForegroundColor White
		Verify-PvtIp
	}
	If ($ConfigIPs -eq "StatPvtNoPubDual")
	{
		Write-Host "Subnet IP Validation" -ForegroundColor White
		Verify-PvtIp
		Verify-PvtIp2
	}
	If ($ConfigIPs -eq "Single")
	{
		Write-Host "Skipping Subnet IP Validation"
		if($Subnet1 -le 2)
		{$subnet1 = 2}
		$script:Subnet1 = $Subnet1
	}

	If ($ConfigIPs -eq "Dual")
	{
		Write-Host "Skipping Subnet IP Validation"
		if($Subnet1 -le 2){$subnet1 = 2}
		if($Subnet2 -le 2){$subnet2 = 2}
		$script:Subnet1 = $Subnet1
		$script:Subnet2 = $Subnet2
	}
	If ($ConfigIPs -eq "PvtSingleStat")
	{
		Write-Host "Subnet IP Validation"
		Verify-PvtIp
	}
	If ($ConfigIPs -eq "PvtDualStat")
	{
		Write-Host "Subnet IP Validation"
		Verify-PvtIp
		Verify-PvtIp2
	}
}
#endregion

Function Check-Vnet {
$vnetexists = Get-AzureRmVirtualNetwork -Name $VNetName -ResourceGroupName $vnetrg -ErrorAction SilentlyContinue -WarningAction SilentlyContinue
if(!$vnetexists)
	{Create-Vnet}
	else
		{Write-Host "Proceeding with VNET $VnetName"}
}

#region Check Values of runtime params
function Check-NullValues {
if(!$rg) {
Write-Host "Please Enter Resource Group Name"
exit
}
	elseif(!$VMName) {
	Write-Host "Please Enter vmName"
	exit
	}
				elseif(!$Location) {
				Write-Host "Please Enter Location"
				exit
				}
}

function Check-ExtensionUnInstall {
if($RemoveExtension -and !$rg) {
	Write-Host "Please Enter RG Name"
	exit
	}
	elseif($RemoveExtension -and !$VMName) {
	Write-Host "Please Enter VM Name"
	exit
	}
}

function Check-AvailabilitySet {
if($AddAvailabilitySet -and !$AvailSetName) {
Write-Host "Please Enter AvailabilitySet Name"
exit
 }
}
function Check-FQDN {
if($AddFQDN -and !$DNLabel) {
Write-Host "Please Enter Public FQDN"
exit
 }
}

function Check-NSGName {
if($CreateNSG -and !$NSGName) {
Write-Host "Please Enter NSG Name"
exit
 }
}

function Check-getinfo {
if($ActionType -eq 'info' -and !$rg) {
Write-Host "Please Enter Resource Group Name"
exit
 }
}

function Check-Extension {
if($AddExtension -and !$AzExtConfig) {
Write-Host "Please Enter Extension Name"
 }
}
#endregion

#region Show DNS
Function Configure-PubIpDNS {
	param(
	[string]$vnetrg = $vnetrg,
	[string]$Location = $Location,
	[string]$rg = $rg,
	[string]$InterfaceName1 = $InterfaceName1,
	[string]$DNLabel = $DNLabel
	)

	Try
	{
if($AddFQDN -or $BatchAddFQDN -eq 'True')
{
	$script:PIp = New-AzureRmPublicIpAddress -Name $InterfaceName1 -ResourceGroupName $rg -Location $Location -AllocationMethod "Dynamic" -DomainNameLabel $DNLabel.ToLower() –Confirm:$false -WarningAction SilentlyContinue  -ErrorAction Stop
	$LogOut = "Completed Public DNS record creation $DNLabel.$Location.cloudapp.azure.com"
	Log-Command -Description $LogOut -LogFile $LogOutFile
	}
	else
	{
	$script:PIp = New-AzureRmPublicIpAddress -Name $InterfaceName1 -ResourceGroupName $rg -Location $Location -AllocationMethod "Dynamic" –Confirm:$false -WarningAction SilentlyContinue  -ErrorAction Stop
	}
	}
	Catch
	{
	Write-Host -foregroundcolor Yellow `
	"Exception Encountered"; `
	$ErrorMessage = $_.Exception.Message
	$LogOut  = 'Error '+$ErrorMessage
	Log-Command -Description $LogOut -LogFile $LogOutFile
	break
	}
}
#endregion

#region Configure Public DNS
Function Configure-PubDNS {
if($AddFQDN -or $BatchAddFQDN -eq 'True')
{
Write-Host "Creating FQDN: " $DNLabel.$Location.cloudapp.azure.com
}
else
{
Write-Host "No DNS Name Specified"
}
}
#endregion

#region Check Storage
Function Check-StorageName
{
	param(
		[string]$StorageName  = $StorageName
	)
$extvm = Get-AzureRmVm -Name $VMName -ResourceGroupName $rg -ErrorAction SilentlyContinue
	if($extvm) {exit}
		$checkname =  Get-AzureRmStorageAccountNameAvailability -Name $StorageName | Select-Object -ExpandProperty NameAvailable
if($checkname -ne 'True') {
	Write-Host "Storage Account Name in use, generating random name for storage..."
	Start-Sleep 5
	$script:StorageNameVerified = $GenerateName.ToLower()
	Write-Host "Storage Name Check Completed for:" $StorageNameVerified
		}
	else
		{
	$script:StorageNameVerified = $StorageName.ToLower()
	Write-Host "Storage Name Check Completed for:" $StorageNameVerified
	}
}
#endregion

#region Configure NICs
Function Configure-Nics {
	param(
	[string]$vnetrg = $vnetrg,
	[string]$Location = $Location,
	[string]$rg = $rg,
	[string]$InterfaceName1 = $InterfaceName1,
	[string]$InterfaceName2 = $InterfaceName2,
	[int]$Subnet1 = $script:Subnet1,
	[int]$Subnet2 = $script:Subnet2,
	[ipaddress]$PvtIPNic1 = $PvtIPNic1,
	[ipaddress]$PvtIPNic2 = $PvtIPNic2,
	[string]$ConfigIps = $ConfigIps
	)

	Try
	{
switch ($ConfigIPs)
	{
		"PvtDualStat" {
			Write-Host "Dual IP Configuration - Static"
			Configure-PubIpDNS
			$script:VNet = Get-AzureRMVirtualNetwork -Name $VNetName -ResourceGroupName $vnetrg | Set-AzureRmVirtualNetwork
			$script:Interface1 = New-AzureRmNetworkInterface -Name $InterfaceName1 -ResourceGroupName $rg -Location $Location -SubnetId $VNet.Subnets[$Subnet1].Id -PublicIpAddressId $PIp.Id -PrivateIpAddress $PvtIPNic1 –Confirm:$false -WarningAction SilentlyContinue  -ErrorAction Stop
			$script:Interface2 = New-AzureRmNetworkInterface -Name $InterfaceName2 -ResourceGroupName $rg -Location $Location -SubnetId $VNet.Subnets[$Subnet2].Id -PrivateIpAddress $PvtIPNic2 –Confirm:$false -WarningAction SilentlyContinue  -ErrorAction Stop
}
		"PvtSingleStat" {
			Write-Host "Single IP Configuration - Static"
			Configure-PubIpDNS
			$script:VNet = Get-AzureRMVirtualNetwork -Name $VNetName -ResourceGroupName $vnetrg | Set-AzureRmVirtualNetwork
			$script:Interface1 = New-AzureRmNetworkInterface -Name $InterfaceName1 -ResourceGroupName $rg -Location $Location -SubnetId $VNet.Subnets[$Subnet1].Id -PublicIpAddressId $PIp.Id -PrivateIpAddress $PvtIPNic1 –Confirm:$false -WarningAction SilentlyContinue  -ErrorAction Stop
}
		"StatPvtNoPubDual" {
			Write-Host "Dual IP Configuration- Static - No Public"
			$script:VNet = Get-AzureRMVirtualNetwork -Name $VNetName -ResourceGroupName $vnetrg | Set-AzureRmVirtualNetwork
			$script:Interface1 = New-AzureRmNetworkInterface -Name $InterfaceName1 -ResourceGroupName $rg -Location $Location -SubnetId $VNet.Subnets[$Subnet1].Id -PrivateIpAddress $PvtIPNic1 –Confirm:$false -WarningAction SilentlyContinue  -ErrorAction Stop
			$script:Interface2 = New-AzureRmNetworkInterface -Name $InterfaceName2 -ResourceGroupName $rg -Location $Location -SubnetId $VNet.Subnets[$Subnet2].Id -PrivateIpAddress $PvtIPNic2 –Confirm:$false -WarningAction SilentlyContinue  -ErrorAction Stop
}
		"StatPvtNoPubSingle" {
			Write-Host "Single IP Configuration - Static - No Public"
			$script:VNet = Get-AzureRMVirtualNetwork -Name $VNetName -ResourceGroupName $vnetrg | Set-AzureRmVirtualNetwork
			$script:Interface1 = New-AzureRmNetworkInterface -Name $InterfaceName1 -ResourceGroupName $rg -Location $Location -SubnetId $VNet.Subnets[$Subnet1].Id -PrivateIpAddress $PvtIPNic1 –Confirm:$false -WarningAction SilentlyContinue  -ErrorAction Stop
}
		"Single" {
			Write-Host "Default Single IP Configuration"
			Configure-PubIpDNS
			$script:VNet = Get-AzureRMVirtualNetwork -Name $VNetName -ResourceGroupName $vnetrg | Set-AzureRmVirtualNetwork
			$script:Interface1 = New-AzureRmNetworkInterface -Name $InterfaceName1 -ResourceGroupName $rg -Location $Location -SubnetId $VNet.Subnets[$Subnet1].Id -PublicIpAddressId $PIp.Id –Confirm:$false -WarningAction SilentlyContinue  -ErrorAction Stop
}
		"Dual" {
			Write-Host "Default Dual IP Configuration"
			Configure-PubIpDNS
			$script:VNet = Get-AzureRMVirtualNetwork -Name $VNetName -ResourceGroupName $vnetrg | Set-AzureRmVirtualNetwork
			$script:Interface1 = New-AzureRmNetworkInterface -Name $InterfaceName1 -ResourceGroupName $rg -Location $Location -SubnetId $VNet.Subnets[$Subnet1].Id -PublicIpAddressId $PIp.Id –Confirm:$false -WarningAction SilentlyContinue  -ErrorAction Stop
			$script:Interface2 = New-AzureRmNetworkInterface -Name $InterfaceName2 -ResourceGroupName $rg -Location $Location -SubnetId $VNet.Subnets[$Subnet2].Id –Confirm:$false -WarningAction SilentlyContinue  -ErrorAction Stop
}
		"NoPubSingle" {
			Write-Host "Single IP - No Public"
			$script:VNet = Get-AzureRMVirtualNetwork -Name $VNetName -ResourceGroupName $vnetrg | Set-AzureRmVirtualNetwork
			$script:Interface1 = New-AzureRmNetworkInterface -Name $InterfaceName1 -ResourceGroupName $rg -Location $Location -SubnetId $VNet.Subnets[$Subnet1].Id –Confirm:$false -WarningAction SilentlyContinue  -ErrorAction Stop
}
		"NoPubDual" {
			Write-Host "Dual IP - No Public"
			$script:VNet = Get-AzureRMVirtualNetwork -Name $VNetName -ResourceGroupName $vnetrg | Set-AzureRmVirtualNetwork
			$script:Interface1 = New-AzureRmNetworkInterface -Name $InterfaceName1 -ResourceGroupName $rg -Location $Location -SubnetId $VNet.Subnets[$Subnet1].Id –Confirm:$false -WarningAction SilentlyContinue  -ErrorAction Stop
			$script:Interface2 = New-AzureRmNetworkInterface -Name $InterfaceName2 -ResourceGroupName $rg -Location $Location -SubnetId $VNet.Subnets[$Subnet2].Id –Confirm:$false -WarningAction SilentlyContinue  -ErrorAction Stop
}
		default{"Nothing matched entry criteria"}
}
	}
	Catch
		{
		Write-Host -foregroundcolor Yellow `
		"Exception Encountered"; `
		$ErrorMessage = $_.Exception.Message
		$LogOut  = 'Error '+$ErrorMessage
		Log-Command -Description $LogOut -LogFile $LogOutFile
		break
		}
}
#endregion

#region Add Dual Nics
Function Add-NICs {
	Write-Host "Adding 2 Network Interface(s) $InterfaceName1 $InterfaceName2" -ForegroundColor White
	$script:VirtualMachine = Add-AzureRmVMNetworkInterface -VM $VirtualMachine -Id $script:Interface1.Id -Primary -WarningAction SilentlyContinue -ErrorAction Stop
	$script:VirtualMachine = Add-AzureRmVMNetworkInterface -VM $VirtualMachine -Id $script:Interface2.Id -WarningAction SilentlyContinue
	$LogOut = "Completed adding NICs"
	Log-Command -Description $LogOut -LogFile $LogOutFile
}
#endregion

#region Add Single Nic
Function Add-NIC {
	Write-Host "Adding Network Interface $InterfaceName1" -ForegroundColor White
	$script:VirtualMachine = Add-AzureRmVMNetworkInterface -VM $VirtualMachine -Id $script:Interface1.Id -Primary -WarningAction SilentlyContinue  -ErrorAction Stop
	$LogOut = "Completed adding NIC"
	Log-Command -Description $LogOut -LogFile $LogOutFile
}
#endregion

#region Configure Single/Dual Homed
Function Set-NicConfiguration {
switch  ($ConfigIPs)
	{
		"PvtDualStat" {
Add-NICs
}
		"PvtSingleStat" {
Add-NIC
}
		"StatPvtNoPubDual" {
Add-NICs
}
		"StatPvtNoPubSingle" {
Add-NIC
}
		"Single" {
Add-NIC
}
		"Dual" {
Add-NICs
}
		"NoPubSingle" {
Add-NIC
}
		"NoPubDual" {
Add-NICs
}
		default{"An unsupported network configuration was referenced"
		break
					}
}
}
#endregion

#region Enable NSG
Function Configure-CreateNSG
{
	param(
		$NSGName = $NSGName,
		$rg = $rg,
		$vnetrg = $vnetrg,
		$VMName = $VMName
	)

	Try
	{
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
	Catch
	{
	Write-Host -foregroundcolor Yellow `
	"Exception Encountered"; `
	$ErrorMessage = $_.Exception.Message
	$LogOut  = 'Error '+$ErrorMessage
	Log-Command -Description $LogOut -LogFile $LogOutFile
	break
	}
}
#endregion

#region Create VPN
Function Create-VPN {
	Try
	{
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
	Catch
	{
	Write-Host -foregroundcolor Yellow `
	"Exception Encountered"; `
	$ErrorMessage = $_.Exception.Message
	$LogOut  = 'Error '+$ErrorMessage
			Log-Command -Description $LogOut -LogFile $LogOutFile
		break
	}
}
#endregion

#region Connect VPN
Function Connect-VPN {
[PSObject]$gateway1 = Get-AzureRmVirtualNetworkGateway -Name vnetvpn1 -ResourceGroupName $vnetrg -WarningAction SilentlyContinue
[PSObject]$local = Get-AzureRmLocalNetworkGateway -Name LocalSite -ResourceGroupName $vnetrg -WarningAction SilentlyContinue
New-AzureRmVirtualNetworkGatewayConnection -ConnectionType IPSEC  -Name sitetosite -ResourceGroupName $vnetrg -Location $Location -VirtualNetworkGateway1 $gateway1 -LocalNetworkGateway2 $local -SharedKey '4321avfe' -Verbose -Force -RoutingWeight 10 -WarningAction SilentlyContinue  -ErrorAction Stop | Out-Null
}
#endregion

#region Nic Description
Function Select-NicDescrtipt {
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
#endregion

#region Get Resource Providers
Function Register-RP {
	Param(
		[string]$ResourceProviderNamespace
	)

	# Write-Host "Registering resource provider '$ResourceProviderNamespace'";
	Register-AzureRmResourceProvider -ProviderNamespace $ResourceProviderNamespace –Confirm:$false -WarningAction SilentlyContinue | Out-Null;
}
#endregion

#region Create Availability Set
Function Create-AvailabilitySet {
	param(
		[string]$rg = $rg,
		[string]$Location = $Location,
		[string]$AvailSetName = $AvailSetName
)
 try {
 If ($AddAvailabilitySet -or $BatchAddAvset -eq 'True')
 {
	Write-Host "Availability Set configuration in process.." -ForegroundColor White
	New-AzureRmAvailabilitySet -ResourceGroupName $rg -Name $AvailSetName -Location $Location -WarningAction SilentlyContinue  -ErrorAction Stop | Out-Null
	$AddAvailabilitySet = (Get-AzureRmAvailabilitySet -ResourceGroupName $rg -Name $AvailSetName).Id
	$script:VirtualMachine = New-AzureRmVMConfig -VMName $VMName -VMSize $VMSize -AvailabilitySetID $AddAvailabilitySet -WarningAction SilentlyContinue
	Write-Host "Availability Set has been configured" -ForegroundColor White
	$LogOut = "Completed Availability Set configuration $AvailSetName"
	Log-Command -Description $LogOut -LogFile $LogOutFile
}
else
{
	Write-Host "Skipping Availability Set configuration" -ForegroundColor White
	$script:VirtualMachine = New-AzureRmVMConfig -VMName $VMName -VMSize $VMSize -WarningAction SilentlyContinue -ErrorAction Stop
	$LogOut = "Skipped Availability Set Configuration"
	Log-Command -Description $LogOut -LogFile $LogOutFile
}
	}

catch {
	Write-Host -foregroundcolor Yellow `
	"Exception Encountered"; `
	$ErrorMessage = $_.Exception.Message
	$LogOut  = 'Error '+$ErrorMessage
	Log-Command -Description $LogOut -LogFile $LogOutFile
	break
}
 }
 #endregion

#region Deploy VM
 function Provision-Vm {
	 param (
	[string]$rg = $rg,
	[string]$Location = $Location
	 )
	$ProvisionVMs = @($VirtualMachine);
try {
   foreach($provisionvm in $ProvisionVMs) {
		New-AzureRmVM -ResourceGroupName $rg -Location $Location -VM $VirtualMachine -DisableBginfoExtension –Confirm:$false -WarningAction SilentlyContinue -ErrorAction Stop | Out-Null
		$LogOut = "Completed Creation of $VMName from $vmMarketImage"
		Log-Command -Description $LogOut -LogFile $LogOutFile
						}
	}
catch {
	Write-Host -foregroundcolor Yellow `
	"Exception Encountered"; `
	$ErrorMessage = $_.Exception.Message
	$LogOut  = 'Error '+$ErrorMessage
	Log-Command -Description $LogOut -LogFile $LogOutFile
	break
}
	 }
#endregion

#region Configure Image
Function Configure-Image {
	Try
	{
		Write-Host "Completing image creation..." -ForegroundColor White
		$script:osDiskCaching = "ReadWrite"
		$script:OSDiskName = $VMName + "OSDisk"
		$script:OSDiskUri = $StorageAccount.PrimaryEndpoints.Blob.ToString() + "vhds/" + $OSDiskName + ".vhd"
		$script:VirtualMachine = Set-AzureRmVMOSDisk -VM $VirtualMachine -Name $OSDiskName -VhdUri $OSDiskUri -CreateOption "FromImage" -Caching $osDiskCaching -WarningAction SilentlyContinue
	}
	Catch
	{
	Write-Host -foregroundcolor Yellow `
	"Exception Encountered"; `
	$ErrorMessage = $_.Exception.Message
	$LogOut  = 'Error '+$ErrorMessage
	Log-Command -Description $LogOut -LogFile $LogOutFile
	break
	}
}
#endregion

#region Image Lib
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
	$script:VirtualMachine= Set-AzureRmVMPlan -VM $VirtualMachine -Name $name -Publisher $Publisher -Product $Product
	$script:VirtualMachine = Set-AzureRmVMOperatingSystem -VM $VirtualMachine -linux -ComputerName $VMName -Credential $Credential1
	$script:VirtualMachine = Set-AzureRmVMSourceImage -VM $VirtualMachine -PublisherName $Publisher -Offer $offer -Skus $Skus -Version $version
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
	$script:VirtualMachine= Set-AzureRmVMPlan -VM $VirtualMachine -Name $name -Publisher $Publisher -Product $Product
	$script:VirtualMachine = Set-AzureRmVMOperatingSystem -VM $VirtualMachine -linux -ComputerName $VMName -Credential $Credential1
	$script:VirtualMachine = Set-AzureRmVMSourceImage -VM $VirtualMachine -PublisherName $Publisher -Offer $offer -Skus $Skus -Version $version
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
	$script:VirtualMachine= Set-AzureRmVMPlan -VM $VirtualMachine -Name $name -Publisher $Publisher -Product $Product
	$script:VirtualMachine = Set-AzureRmVMOperatingSystem -VM $VirtualMachine -linux -ComputerName $VMName -Credential $Credential1
	$script:VirtualMachine = Set-AzureRmVMSourceImage -VM $VirtualMachine -PublisherName $Publisher -Offer $offer -Skus $Skus -Version $version
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
	$script:VirtualMachine= Set-AzureRmVMPlan -VM $VirtualMachine -Name $name -Publisher $Publisher -Product $Product
	$script:VirtualMachine = Set-AzureRmVMOperatingSystem -VM $VirtualMachine -Windows -ComputerName $VMName -Credential $Credential1
	$script:VirtualMachine = Set-AzureRmVMSourceImage -VM $VirtualMachine -PublisherName $Publisher -Offer $offer -Skus $Skus -Version $version
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
	$script:VirtualMachine= Set-AzureRmVMPlan -VM $VirtualMachine -Name $name -Publisher $Publisher -Product $Product
	$script:VirtualMachine = Set-AzureRmVMOperatingSystem -VM $VirtualMachine -linux -ComputerName $VMName -Credential $Credential1
	$script:VirtualMachine = Set-AzureRmVMSourceImage -VM $VirtualMachine -PublisherName $Publisher -Offer $offer -Skus $Skus -Version $version
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
	$script:VirtualMachine= Set-AzureRmVMPlan -VM $VirtualMachine -Name $name -Publisher $Publisher -Product $Product
	$script:VirtualMachine = Set-AzureRmVMOperatingSystem -VM $VirtualMachine -linux -ComputerName $VMName -Credential $Credential1
	$script:VirtualMachine = Set-AzureRmVMSourceImage -VM $VirtualMachine -PublisherName $Publisher -Offer $offer -Skus $Skus -Version $version
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
	$script:VirtualMachine= Set-AzureRmVMPlan -VM $VirtualMachine -Name $name -Publisher $Publisher -Product $Product
	$script:VirtualMachine = Set-AzureRmVMOperatingSystem -VM $VirtualMachine -linux -ComputerName $VMName -Credential $Credential1
	$script:VirtualMachine = Set-AzureRmVMSourceImage -VM $VirtualMachine -PublisherName $Publisher -Offer $offer -Skus $Skus -Version $version
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
	$script:VirtualMachine= Set-AzureRmVMPlan -VM $VirtualMachine -Name $name -Publisher $Publisher -Product $Product
	$script:VirtualMachine = Set-AzureRmVMOperatingSystem -VM $VirtualMachine -linux -ComputerName $VMName -Credential $Credential1
	$script:VirtualMachine = Set-AzureRmVMSourceImage -VM $VirtualMachine -PublisherName $Publisher -Offer $offer -Skus $Skus -Version $version
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
	$script:VirtualMachine= Set-AzureRmVMPlan -VM $VirtualMachine -Name $name -Publisher $Publisher -Product $Product
	$script:VirtualMachine = Set-AzureRmVMOperatingSystem -VM $VirtualMachine -linux -ComputerName $VMName -Credential $Credential1
	$script:VirtualMachine = Set-AzureRmVMSourceImage -VM $VirtualMachine -PublisherName $Publisher -Offer $offer -Skus $Skus -Version $version
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
	$script:VirtualMachine= Set-AzureRmVMPlan -VM $VirtualMachine -Name $name -Publisher $Publisher -Product $Product
	$script:VirtualMachine = Set-AzureRmVMOperatingSystem -VM $VirtualMachine -linux -ComputerName $VMName -Credential $Credential1
	$script:VirtualMachine = Set-AzureRmVMSourceImage -VM $VirtualMachine -PublisherName $Publisher -Offer $offer -Skus $Skus -Version $version
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
	$script:VirtualMachine= Set-AzureRmVMPlan -VM $VirtualMachine -Name $name -Publisher $Publisher -Product $Product
	$script:VirtualMachine = Set-AzureRmVMOperatingSystem -VM $VirtualMachine -linux -ComputerName $VMName -Credential $Credential1
	$script:VirtualMachine = Set-AzureRmVMSourceImage -VM $VirtualMachine -PublisherName $Publisher -Offer $offer -Skus $Skus -Version $version
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
	$script:VirtualMachine= Set-AzureRmVMPlan -VM $VirtualMachine -Name $name -Publisher $Publisher -Product $Product
	$script:VirtualMachine = Set-AzureRmVMOperatingSystem -VM $VirtualMachine -linux -ComputerName $VMName -Credential $Credential1
	$script:VirtualMachine = Set-AzureRmVMSourceImage -VM $VirtualMachine -PublisherName $Publisher -Offer $offer -Skus $Skus -Version $version
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
	$script:VirtualMachine= Set-AzureRmVMPlan -VM $VirtualMachine -Name $name -Publisher $Publisher -Product $Product
	$script:VirtualMachine = Set-AzureRmVMOperatingSystem -VM $VirtualMachine -linux -ComputerName $VMName -Credential $Credential1
	$script:VirtualMachine = Set-AzureRmVMSourceImage -VM $VirtualMachine -PublisherName $Publisher -Offer $offer -Skus $Skus -Version $version
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
	$script:VirtualMachine= Set-AzureRmVMPlan -VM $VirtualMachine -Name $name -Publisher $Publisher -Product $Product
	$script:VirtualMachine = Set-AzureRmVMOperatingSystem -VM $VirtualMachine -linux -ComputerName $VMName -Credential $Credential1
	$script:VirtualMachine = Set-AzureRmVMSourceImage -VM $VirtualMachine -PublisherName $Publisher -Offer $offer -Skus $Skus -Version $version
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
	$script:VirtualMachine= Set-AzureRmVMPlan -VM $VirtualMachine -Name $name -Publisher $Publisher -Product $Product
	$script:VirtualMachine = Set-AzureRmVMOperatingSystem -VM $VirtualMachine -linux -ComputerName $VMName -Credential $Credential1
	$script:VirtualMachine = Set-AzureRmVMSourceImage -VM $VirtualMachine -PublisherName $Publisher -Offer $offer -Skus $Skus -Version $version
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
$script:VirtualMachine= Set-AzureRmVMPlan -VM $VirtualMachine -Name $name -Publisher $Publisher -Product $Product
$script:VirtualMachine = Set-AzureRmVMOperatingSystem -VM $VirtualMachine -linux -ComputerName $VMName -Credential $Credential1
$script:VirtualMachine = Set-AzureRmVMSourceImage -VM $VirtualMachine -PublisherName $Publisher -Offer $offer -Skus $Skus -Version $version
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
	Try
	{
		Write-Host "Image Creation in Process - Plan Info - Barracuda Firewall " -ForegroundColor White
		Write-Host 'Publisher:'$Publisher 'Offer:'$offer 'Sku:'$Skus 'Version:'$version
		$script:VirtualMachine= Set-AzureRmVMPlan -VM $VirtualMachine -Name $name -Publisher $Publisher -Product $Product
		$script:VirtualMachine = Set-AzureRmVMOperatingSystem -VM $VirtualMachine -linux -ComputerName $VMName -Credential $Credential1
		$script:VirtualMachine = Set-AzureRmVMSourceImage -VM $VirtualMachine -PublisherName $Publisher -Offer $offer -Skus $Skus -Version $version
		$LogOut = "Completed image prep 'Publisher:'$Publisher 'Offer:'$offer 'Sku:'$Skus 'Version:'$version"
		Log-Command -Description $LogOut -LogFile $LogOutFile
	}
	Catch
	{
	Write-Host -foregroundcolor Yellow `
	"$($_.Exception.Message)"; `
	$LogOut = "$($_.Exception.Message)"
	Log-Command -Description $LogOut -LogFile $LogOutFile
	break
	}
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
$script:VirtualMachine= Set-AzureRmVMPlan -VM $VirtualMachine -Name $name -Publisher $Publisher -Product $Product
$script:VirtualMachine = Set-AzureRmVMOperatingSystem -VM $VirtualMachine -linux -ComputerName $VMName -Credential $Credential1
$script:VirtualMachine = Set-AzureRmVMSourceImage -VM $VirtualMachine -PublisherName $Publisher -Offer $offer -Skus $Skus -Version $version
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
$script:VirtualMachine= Set-AzureRmVMPlan -VM $VirtualMachine -Name $name -Publisher $Publisher -Product $Product
$script:VirtualMachine = Set-AzureRmVMOperatingSystem -VM $VirtualMachine -linux -ComputerName $VMName -Credential $Credential1
$script:VirtualMachine = Set-AzureRmVMSourceImage -VM $VirtualMachine -PublisherName $Publisher -Offer $offer -Skus $Skus -Version $version
$LogOut = "Completed image prep 'Publisher:'$Publisher 'Offer:'$offer 'Sku:'$Skus 'Version:'$version"
Log-Command -Description $LogOut -LogFile $LogOutFile
}

Function MakeImagePlanInfo_cloudera {
param(
	[string]$VMName = $VMName,
	[string]$Publisher = 'cloudera',
	[string]$offer = 'cloudera-centos-os',
	[string]$Skus = '7_2',
	[string]$version = 'latest',
	[string]$Product = 'cloudera-centos-os',
	[string]$name = '7_2'
)
	Try
	{
		Write-Host "Image Creation in Process - Plan Info - cloudera" -ForegroundColor White
		Write-Host 'Publisher:'$Publisher 'Offer:'$offer 'Sku:'$Skus 'Version:'$version
		$script:VirtualMachine= Set-AzureRmVMPlan -VM $VirtualMachine -Name $name -Publisher $Publisher -Product $Product
		$script:VirtualMachine = Set-AzureRmVMOperatingSystem -VM $VirtualMachine -linux -ComputerName $VMName -Credential $Credential1
		$script:VirtualMachine = Set-AzureRmVMSourceImage -VM $VirtualMachine -PublisherName $Publisher -Offer $offer -Skus $Skus -Version $version
		$LogOut = "Completed image prep 'Publisher:'$Publisher 'Offer:'$offer 'Sku:'$Skus 'Version:'$version"
		Log-Command -Description $LogOut -LogFile $LogOutFile
	}
	Catch
	{
	Write-Host -foregroundcolor Yellow `
	"$($_.Exception.Message)"; `
	$LogOut = "$($_.Exception.Message)"
	Log-Command -Description $LogOut -LogFile $LogOutFile
	break
	}
}

Function MakeImagePlanInfo_datastax {
param(
	[string]$VMName = $VMName,
	[string]$Publisher = 'datastax',
	[string]$offer = 'datastax-enterprise',
	[string]$Skus = 'datastaxenterprise',
	[string]$version = 'latest',
	[string]$Product = 'datastax-enterprise',
	[string]$name = 'datastaxenterprise'
)
Write-Host "Image Creation in Process - Plan Info - datastax" -ForegroundColor White
Write-Host 'Publisher:'$Publisher 'Offer:'$offer 'Sku:'$Skus 'Version:'$version
$script:VirtualMachine= Set-AzureRmVMPlan -VM $VirtualMachine -Name $name -Publisher $Publisher -Product $Product
$script:VirtualMachine = Set-AzureRmVMOperatingSystem -VM $VirtualMachine -linux -ComputerName $VMName -Credential $Credential1
$script:VirtualMachine = Set-AzureRmVMSourceImage -VM $VirtualMachine -PublisherName $Publisher -Offer $offer -Skus $Skus -Version $version
$LogOut = "Completed image prep 'Publisher:'$Publisher 'Offer:'$offer 'Sku:'$Skus 'Version:'$version"
Log-Command -Description $LogOut -LogFile $LogOutFile
}

Function MakeImagePlanInfo_cloudconnector {
param(
	[string]$VMName = $VMName,
	[string]$Publisher = 'elfiqnetworks',
	[string]$offer = 'cloud-connector',
	[string]$Skus = 'cloud-connector-azure',
	[string]$version = 'latest',
	[string]$Product = 'cloud-connector',
	[string]$name = 'cloud-connector-azure'
)
Write-Host "Image Creation in Process - Plan Info - cloud connector" -ForegroundColor White
Write-Host 'Publisher:'$Publisher 'Offer:'$offer 'Sku:'$Skus 'Version:'$version
$script:VirtualMachine= Set-AzureRmVMPlan -VM $VirtualMachine -Name $name -Publisher $Publisher -Product $Product
$script:VirtualMachine = Set-AzureRmVMOperatingSystem -VM $VirtualMachine -linux -ComputerName $VMName -Credential $Credential1
$script:VirtualMachine = Set-AzureRmVMSourceImage -VM $VirtualMachine -PublisherName $Publisher -Offer $offer -Skus $Skus -Version $version
$LogOut = "Completed image prep 'Publisher:'$Publisher 'Offer:'$offer 'Sku:'$Skus 'Version:'$version"
Log-Command -Description $LogOut -LogFile $LogOutFile
}

Function MakeImagePlanInfo_chefbyol {
param(
	[string]$VMName = $VMName,
	[string]$Publisher = 'chef-software',
	[string]$offer = 'chef-server',
	[string]$Skus = 'chefbyol',
	[string]$version = 'latest',
	[string]$Product = 'chef-server',
	[string]$name = 'chefbyol'
)
Write-Host "Image Creation in Process - Plan Info - Chef BYOL" -ForegroundColor White
Write-Host 'Publisher:'$Publisher 'Offer:'$offer 'Sku:'$Skus 'Version:'$version
$script:VirtualMachine= Set-AzureRmVMPlan -VM $VirtualMachine -Name $name -Publisher $Publisher -Product $Product
$script:VirtualMachine = Set-AzureRmVMOperatingSystem -VM $VirtualMachine -linux -ComputerName $VMName -Credential $Credential1
$script:VirtualMachine = Set-AzureRmVMSourceImage -VM $VirtualMachine -PublisherName $Publisher -Offer $offer -Skus $Skus -Version $version
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
$script:VirtualMachine= Set-AzureRmVMPlan -VM $VirtualMachine -Name $name -Publisher $Publisher -Product $Product
$script:VirtualMachine = Set-AzureRmVMOperatingSystem -VM $VirtualMachine -linux -ComputerName $VMName -Credential $Credential1
$script:VirtualMachine = Set-AzureRmVMSourceImage -VM $VirtualMachine -PublisherName $Publisher -Offer $offer -Skus $Skus -Version $version
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
$script:VirtualMachine= Set-AzureRmVMPlan -VM $VirtualMachine -Name $name -Publisher $Publisher -Product $Product
$script:VirtualMachine = Set-AzureRmVMOperatingSystem -VM $VirtualMachine -linux -ComputerName $VMName -Credential $Credential1
$script:VirtualMachine = Set-AzureRmVMSourceImage -VM $VirtualMachine -PublisherName $Publisher -Offer $offer -Skus $Skus -Version $version
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
	Try
	{
		Write-Host "Image Creation in Process - Plan Info - F5 WebApp Firewall- BYOL" -ForegroundColor White
		Write-Host 'Publisher:'$Publisher 'Offer:'$offer 'Sku:'$Skus 'Version:'$version
		$script:VirtualMachine= Set-AzureRmVMPlan -VM $VirtualMachine -Name $name -Publisher $Publisher -Product $Product
		$script:VirtualMachine = Set-AzureRmVMOperatingSystem -VM $VirtualMachine -linux -ComputerName $VMName -Credential $Credential1
		$script:VirtualMachine = Set-AzureRmVMSourceImage -VM $VirtualMachine -PublisherName $Publisher -Offer $offer -Skus $Skus -Version $version
		$LogOut = "Completed image prep 'Publisher:'$Publisher 'Offer:'$offer 'Sku:'$Skus 'Version:'$version"
		Log-Command -Description $LogOut -LogFile $LogOutFile
	}
	Catch
	{
	Write-Host -foregroundcolor Yellow `
	"Exception Encountered"; `
	$ErrorMessage = $_.Exception.Message
	$LogOut  = 'Error '+$ErrorMessage
	Log-Command -Description $LogOut -LogFile $LogOutFile
	break
	}
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
$script:VirtualMachine= Set-AzureRmVMPlan -VM $VirtualMachine -Name $name -Publisher $Publisher -Product $Product
$script:VirtualMachine = Set-AzureRmVMOperatingSystem -VM $VirtualMachine -linux -ComputerName $VMName -Credential $Credential1
$script:VirtualMachine = Set-AzureRmVMSourceImage -VM $VirtualMachine -PublisherName $Publisher -Offer $offer -Skus $Skus -Version $version
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
$script:VirtualMachine = Set-AzureRmVMPlan -VM $VirtualMachine -Name $name -Publisher $Publisher -Product $Product
$script:VirtualMachine = Set-AzureRmVMOperatingSystem -VM $VirtualMachine -linux -ComputerName $VMName -Credential $Credential1
$script:VirtualMachine = Set-AzureRmVMSourceImage -VM $VirtualMachine -PublisherName $Publisher -Offer $offer -Skus $Skus -Version $version
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
$script:VirtualMachine = Set-AzureRmVMOperatingSystem -VM $VirtualMachine -linux -ComputerName $VMName -Credential $Credential1
$script:VirtualMachine = Set-AzureRmVMSourceImage -VM $VirtualMachine -PublisherName $Publisher -Offer $offer -Skus $Skus -Version $version
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
$script:VirtualMachine = Set-AzureRmVMOperatingSystem -VM $VirtualMachine -linux -ComputerName $VMName -Credential $Credential1
$script:VirtualMachine = Set-AzureRmVMSourceImage -VM $VirtualMachine -PublisherName $Publisher -Offer $offer -Skus $Skus -Version $version
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
$script:VirtualMachine = Set-AzureRmVMOperatingSystem -VM $VirtualMachine -linux -ComputerName $VMName -Credential $Credential1
$script:VirtualMachine = Set-AzureRmVMSourceImage -VM $VirtualMachine -PublisherName $Publisher -Offer $offer -Skus $Skus -Version $version
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
$script:VirtualMachine = Set-AzureRmVMOperatingSystem -VM $VirtualMachine -linux -ComputerName $VMName -Credential $Credential1
$script:VirtualMachine = Set-AzureRmVMSourceImage -VM $VirtualMachine -PublisherName $Publisher -Offer $offer -Skus $Skus -Version $version
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
$script:VirtualMachine = Set-AzureRmVMOperatingSystem -VM $VirtualMachine -linux -ComputerName $VMName -Credential $Credential1
$script:VirtualMachine = Set-AzureRmVMSourceImage -VM $VirtualMachine -PublisherName $Publisher -Offer $offer -Skus $Skus -Version $version
$LogOut = "Completed image prep 'Publisher:'$Publisher 'Offer:'$offer 'Sku:'$Skus 'Version:'$version"
Log-Command -Description $LogOut -LogFile $LogOutFile
}

Function MakeImagePlanInfo_tableau {
param(
	[string]$VMName = $VMName,
	[string]$Publisher = 'tableau',
	[string]$offer = 'tableau-server',
	[string]$Skus = 'bring-your-own-license',
	[string]$version = 'latest',
	[string]$Product = 'tableau-server',
	[string]$name = 'bring-your-own-license'
)
Write-Host "Image Creation in Process - Plan Info - Tableau" -ForegroundColor White
Write-Host 'Publisher:'$Publisher 'Offer:'$offer 'Sku:'$Skus 'Version:'$version
$script:VirtualMachine= Set-AzureRmVMPlan -VM $VirtualMachine -Name $name -Publisher $Publisher -Product $Product
$script:VirtualMachine = Set-AzureRmVMOperatingSystem -VM $VirtualMachine -windows -ComputerName $VMName -Credential $Credential1
$script:VirtualMachine = Set-AzureRmVMSourceImage -VM $VirtualMachine -PublisherName $Publisher -Offer $offer -Skus $Skus -Version $version
$LogOut = "Completed image prep 'Publisher:'$Publisher 'Offer:'$offer 'Sku:'$Skus 'Version:'$version"
Log-Command -Description $LogOut -LogFile $LogOutFile
}

Function MakeImagePlanInfo_RevAnalytics_win {
param(
	[string]$VMName = $VMName,
	[string]$Publisher = 'revolution-analytics',
	[string]$offer = 'revolution-r-enterprise',
	[string]$Skus = 'rre74-win2012r2',
	[string]$version = 'latest',
	[string]$Product = 'revolution-r-enterprise',
	[string]$name = 'rre74-win2012r2'
)
Write-Host "Image Creation in Process - Plan Info - Revo Analytics" -ForegroundColor White
Write-Host 'Publisher:'$Publisher 'Offer:'$offer 'Sku:'$Skus 'Version:'$version
$script:VirtualMachine= Set-AzureRmVMPlan -VM $VirtualMachine -Name $name -Publisher $Publisher -Product $Product
$script:VirtualMachine = Set-AzureRmVMOperatingSystem -VM $VirtualMachine -windows -ComputerName $VMName -Credential $Credential1
$script:VirtualMachine = Set-AzureRmVMSourceImage -VM $VirtualMachine -PublisherName $Publisher -Offer $offer -Skus $Skus -Version $version
$LogOut = "Completed image prep 'Publisher:'$Publisher 'Offer:'$offer 'Sku:'$Skus 'Version:'$version"
Log-Command -Description $LogOut -LogFile $LogOutFile
}

Function MakeImagePlanInfo_RevAnalytics_cent {
param(
	[string]$VMName = $VMName,
	[string]$Publisher = 'revolution-analytics',
	[string]$offer = 'revolution-r-enterprise',
	[string]$Skus = 'rre74-centos65',
	[string]$version = 'latest',
	[string]$Product = 'revolution-r-enterprise',
	[string]$name = 'rre74-centos65'
)
Write-Host "Image Creation in Process - Plan Info - Revo Analytics" -ForegroundColor White
Write-Host 'Publisher:'$Publisher 'Offer:'$offer 'Sku:'$Skus 'Version:'$version
$script:VirtualMachine= Set-AzureRmVMPlan -VM $VirtualMachine -Name $name -Publisher $Publisher -Product $Product
$script:VirtualMachine = Set-AzureRmVMOperatingSystem -VM $VirtualMachine -windows -ComputerName $VMName -Credential $Credential1
$script:VirtualMachine = Set-AzureRmVMSourceImage -VM $VirtualMachine -PublisherName $Publisher -Offer $offer -Skus $Skus -Version $version
$LogOut = "Completed image prep 'Publisher:'$Publisher 'Offer:'$offer 'Sku:'$Skus 'Version:'$version"
Log-Command -Description $LogOut -LogFile $LogOutFile
}

Function MakeImagenoPlanInfo_ads_datascience {
param(
	[string]$VMName = $VMName,
	[string]$Publisher = 'microsoft-ads',
	[string]$offer = 'linux-data-science-vm',
	[string]$Skus = 'linuxdsvm',
	[string]$version = 'latest',
	[string]$Product = 'linux-data-science-vm',
	[string]$name = 'linuxdsvm'
)
Write-Host "Image Creation in Process - No Plan Info - Ads Data Science" -ForegroundColor White
Write-Host 'Publisher:'$Publisher 'Offer:'$offer 'Sku:'$Skus 'Version:'$version
$script:VirtualMachine= Set-AzureRmVMPlan -VM $VirtualMachine -Name $name -Publisher $Publisher -Product $Product
$script:VirtualMachine = Set-AzureRmVMOperatingSystem -VM $VirtualMachine -linux -ComputerName $VMName -Credential $Credential1
$script:VirtualMachine = Set-AzureRmVMSourceImage -VM $VirtualMachine -PublisherName $Publisher -Offer $offer -Skus $Skus -Version $version
$LogOut = "Completed image prep 'Publisher:'$Publisher 'Offer:'$offer 'Sku:'$Skus 'Version:'$version"
Log-Command -Description $LogOut -LogFile $LogOutFile
}

Function MakeImagenoPlanInfo_ads_stddatascience {
param(
	[string]$VMName = $VMName,
	[string]$Publisher = 'microsoft-ads',
	[string]$offer = 'standard-data-science-vm',
	[string]$Skus = 'standard-data-science-vm',
	[string]$version = 'latest',
	[string]$Product = 'standard-data-science-vm',
	[string]$name = 'standard-data-science-vm'
)
Write-Host "Image Creation in Process - No Plan Info - Ads Data Science Standard" -ForegroundColor White
Write-Host 'Publisher:'$Publisher 'Offer:'$offer 'Sku:'$Skus 'Version:'$version
$script:VirtualMachine= Set-AzureRmVMPlan -VM $VirtualMachine -Name $name -Publisher $Publisher -Product $Product
$script:VirtualMachine = Set-AzureRmVMOperatingSystem -VM $VirtualMachine -linux -ComputerName $VMName -Credential $Credential1
$script:VirtualMachine = Set-AzureRmVMSourceImage -VM $VirtualMachine -PublisherName $Publisher -Offer $offer -Skus $Skus -Version $version
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
$script:VirtualMachine = Set-AzureRmVMOperatingSystem -VM $VirtualMachine -linux -ComputerName $VMName -Credential $Credential1
$script:VirtualMachine = Set-AzureRmVMSourceImage -VM $VirtualMachine -PublisherName $Publisher -Offer $offer -Skus $Skus -Version $version
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
$script:VirtualMachine = Set-AzureRmVMPlan -VM $VirtualMachine -Name $name -Publisher $Publisher -Product $Product
$script:VirtualMachine = Set-AzureRmVMOperatingSystem -VM $VirtualMachine -linux -ComputerName $VMName -Credential $Credential1
$script:VirtualMachine = Set-AzureRmVMSourceImage -VM $VirtualMachine -PublisherName $Publisher -Offer $offer -Skus $Skus -Version $version
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
$script:VirtualMachine = Set-AzureRmVMOperatingSystem -VM $VirtualMachine -Windows -ComputerName $VMName -Credential $Credential1 -ProvisionVMAgent -EnableAutoUpdate -WinRMHttp -Verbose
$script:VirtualMachine = Set-AzureRmVMSourceImage -VM $VirtualMachine -PublisherName $Publisher -Offer $offer -Skus $Skus -Version $version
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
$script:VirtualMachine = Set-AzureRmVMOperatingSystem -VM $VirtualMachine -Windows -ComputerName $VMName -Credential $Credential1 -ProvisionVMAgent -EnableAutoUpdate -WinRMHttp -Verbose
$script:VirtualMachine = Set-AzureRmVMSourceImage -VM $VirtualMachine -PublisherName $Publisher -Offer $offer -Skus $Skus -Version $version
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
$script:VirtualMachine = Set-AzureRmVMOperatingSystem -VM $VirtualMachine -Windows -ComputerName $VMName -Credential $Credential1 -ProvisionVMAgent -EnableAutoUpdate -WinRMHttp -Verbose
$script:VirtualMachine = Set-AzureRmVMSourceImage -VM $VirtualMachine -PublisherName $Publisher -Offer $offer -Skus $Skus -Version $version
$LogOut = "Completed image prep 'Publisher:'$Publisher 'Offer:'$offer 'Sku:'$Skus 'Version:'$version"
Log-Command -Description $LogOut -LogFile $LogOutFile
}

Function MakeImageNoPlanInfo_MSNAV2016 {
param(
	[string]$VMName = $VMName,
	[string]$Publisher = "MicrosoftDynamicsNAV",
	[string]$offer = "DynamicsNAV",
	[string]$Skus = "2016",
	[string]$version = "latest"
)
Write-Host "Image Creation in Process - No Plan Info - MS Nav 2016" -ForegroundColor White
Write-Host 'Publisher:'$Publisher 'Offer:'$offer 'Sku:'$Skus 'Version:'$version
$script:VirtualMachine = Set-AzureRmVMOperatingSystem -VM $VirtualMachine -Windows -ComputerName $VMName -Credential $Credential1 -ProvisionVMAgent -EnableAutoUpdate -WinRMHttp -Verbose
$script:VirtualMachine = Set-AzureRmVMSourceImage -VM $VirtualMachine -PublisherName $Publisher -Offer $offer -Skus $Skus -Version $version
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
$script:VirtualMachine = Set-AzureRmVMOperatingSystem -VM $VirtualMachine -Windows -ComputerName $VMName -Credential $Credential1 -ProvisionVMAgent -EnableAutoUpdate -WinRMHttp -Verbose
$script:VirtualMachine = Set-AzureRmVMSourceImage -VM $VirtualMachine -PublisherName $Publisher -Offer $offer -Skus $Skus -Version $version
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
$script:VirtualMachine = Set-AzureRmVMOperatingSystem -VM $VirtualMachine -Windows -ComputerName $VMName -Credential $Credential1 -ProvisionVMAgent -EnableAutoUpdate -WinRMHttp -Verbose
$script:VirtualMachine = Set-AzureRmVMSourceImage -VM $VirtualMachine -PublisherName $Publisher -Offer $offer -Skus $Skus -Version $version
$LogOut = "Completed image prep 'Publisher:'$Publisher 'Offer:'$offer 'Sku:'$Skus 'Version:'$version"
Log-Command -Description $LogOut -LogFile $LogOutFile
}
Function MakeImageNoPlanInfo_TeamFoundationServer {
param(
	[string]$VMName = $VMName,
	[string]$Publisher = 'MicrosoftVisualStudio',
	[string]$offer = 'TeamFoundationServer',
	[string]$Skus = 'Team-Foundation-Server-2013-Update4-WS2012R2',
	[string]$version = 'latest',
	[string]$Product = 'Team-Foundation-Server-2013-Update4-WS2012R2',
	[string]$name = 'TeamFoundationServer'
)
Write-Host "Image Creation in Process - No Plan Info - TeamFoundationServer" -ForegroundColor White
Write-Host 'Publisher:'$Publisher 'Offer:'$offer 'Sku:'$Skus 'Version:'$version
$script:VirtualMachine = Set-AzureRmVMOperatingSystem -VM $VirtualMachine -Windows -ComputerName $VMName -Credential $Credential1 -ProvisionVMAgent -EnableAutoUpdate -WinRMHttp -Verbose
$script:VirtualMachine = Set-AzureRmVMSourceImage -VM $VirtualMachine -PublisherName $Publisher -Offer $offer -Skus $Skus -Version $version
$LogOut = "Completed image prep 'Publisher:'$Publisher 'Offer:'$offer 'Sku:'$Skus 'Version:'$version"
Log-Command -Description $LogOut -LogFile $LogOutFile
}
Function MakeImageNoPlanInfo_Biztalk-Enterprise {
param(
	[string]$VMName = $VMName,
	[string]$Publisher = 'MicrosoftBizTalkServer',
	[string]$offer = 'BizTalk-Server',
	[string]$Skus = '2013-R2-Enterprise',
	[string]$version = 'latest'
)
Write-Host "Image Creation in Process - No Plan Info - MicrosoftBizTalkServer" -ForegroundColor White
Write-Host 'Publisher:'$Publisher 'Offer:'$offer 'Sku:'$Skus 'Version:'$version
$script:VirtualMachine = Set-AzureRmVMOperatingSystem -VM $VirtualMachine -Windows -ComputerName $VMName -Credential $Credential1 -ProvisionVMAgent -EnableAutoUpdate -WinRMHttp -Verbose
$script:VirtualMachine = Set-AzureRmVMSourceImage -VM $VirtualMachine -PublisherName $Publisher -Offer $offer -Skus $Skus -Version $version
$LogOut = "Completed image prep 'Publisher:'$Publisher 'Offer:'$offer 'Sku:'$Skus 'Version:'$version"
Log-Command -Description $LogOut -LogFile $LogOutFile
}
Function MakeImageNoPlanInfo_Biztalk2016-PreRelease {
param(
	[string]$VMName = $VMName,
	[string]$Publisher = 'MicrosoftBizTalkServer',
	[string]$offer = 'BizTalk-Server',
	[string]$Skus = '2016-PreRelease',
	[string]$version = 'latest'
)
Write-Host "Image Creation in Process - No Plan Info - MicrosoftBizTalkServer2016" -ForegroundColor White
Write-Host 'Publisher:'$Publisher 'Offer:'$offer 'Sku:'$Skus 'Version:'$version
$script:VirtualMachine = Set-AzureRmVMOperatingSystem -VM $VirtualMachine -Windows -ComputerName $VMName -Credential $Credential1 -ProvisionVMAgent -EnableAutoUpdate -WinRMHttp -Verbose
$script:VirtualMachine = Set-AzureRmVMSourceImage -VM $VirtualMachine -PublisherName $Publisher -Offer $offer -Skus $Skus -Version $version
$LogOut = "Completed image prep 'Publisher:'$Publisher 'Offer:'$offer 'Sku:'$Skus 'Version:'$version"
Log-Command -Description $LogOut -LogFile $LogOutFile
}

Function MakeImagePlanInfo_metavistech {
param(
	[string]$VMName = $VMName,
	[string]$Publisher = 'metavistech',
	[string]$offer = 'metavis-office365-suite',
	[string]$Skus = 'mv-office365-ste-azure-1',
	[string]$version = 'latest',
	[string]$Product = 'metavis-office365-suite',
	[string]$name = 'mv-office365-ste-azure-1'
)
Write-Host "Image Creation in Process - Plan Info - metavistech" -ForegroundColor White
Write-Host 'Publisher:'$Publisher 'Offer:'$offer 'Sku:'$Skus 'Version:'$version
$script:VirtualMachine= Set-AzureRmVMPlan -VM $VirtualMachine -Name $name -Publisher $Publisher -Product $Product
$script:VirtualMachine = Set-AzureRmVMOperatingSystem -VM $VirtualMachine -linux -ComputerName $VMName -Credential $Credential1
$script:VirtualMachine = Set-AzureRmVMSourceImage -VM $VirtualMachine -PublisherName $Publisher -Offer $offer -Skus $Skus -Version $version
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
$script:VirtualMachine = Set-AzureRmVMOperatingSystem -VM $VirtualMachine -Windows -ComputerName $VMName -Credential $Credential1 -ProvisionVMAgent -EnableAutoUpdate -WinRMHttp -Verbose
$script:VirtualMachine = Set-AzureRmVMSourceImage -VM $VirtualMachine -PublisherName $Publisher -Offer $offer -Skus $Skus -Version $version
$LogOut = "Completed image prep 'Publisher:'$Publisher 'Offer:'$offer 'Sku:'$Skus 'Version:'$version"
Log-Command -Description $LogOut -LogFile $LogOutFile
}

Function MakeImagePlanInfo_incredibuild {
param(
	[string]$VMName = $VMName,
	[string]$Publisher = 'incredibuild',
	[string]$offer = 'incredibuild',
	[string]$Skus = 'incredibuild',
	[string]$version = 'latest',
	[string]$Product = 'incredibuild',
	[string]$name = 'incredibuild'
)
Write-Host "Image Creation in Process - Plan Info - incredibuild" -ForegroundColor White
Write-Host 'Publisher:'$Publisher 'Offer:'$offer 'Sku:'$Skus 'Version:'$version
$script:VirtualMachine= Set-AzureRmVMPlan -VM $VirtualMachine -Name $name -Publisher $Publisher -Product $Product
$script:VirtualMachine = Set-AzureRmVMOperatingSystem -VM $VirtualMachine -linux -ComputerName $VMName -Credential $Credential1
$script:VirtualMachine = Set-AzureRmVMSourceImage -VM $VirtualMachine -PublisherName $Publisher -Offer $offer -Skus $Skus -Version $version
$LogOut = "Completed image prep 'Publisher:'$Publisher 'Offer:'$offer 'Sku:'$Skus 'Version:'$version"
Log-Command -Description $LogOut -LogFile $LogOutFile
}

Function MakeImagePlanInfo_hortonwowk_dp {
param(
	[string]$VMName = $VMName,
	[string]$Publisher = 'hortonworks',
	[string]$offer = 'hortonworks-data-platform-240',
	[string]$Skus = 'hdp-240-ambari-221',
	[string]$version = 'latest',
	[string]$Product = 'hortonworks-data-platform-240',
	[string]$name = 'hdp-240-ambari-221'
)
Write-Host "Image Creation in Process - Plan Info - HortonWorks" -ForegroundColor White
Write-Host 'Publisher:'$Publisher 'Offer:'$offer 'Sku:'$Skus 'Version:'$version
$script:VirtualMachine= Set-AzureRmVMPlan -VM $VirtualMachine -Name $name -Publisher $Publisher -Product $Product
$script:VirtualMachine = Set-AzureRmVMOperatingSystem -VM $VirtualMachine -linux -ComputerName $VMName -Credential $Credential1
$script:VirtualMachine = Set-AzureRmVMSourceImage -VM $VirtualMachine -PublisherName $Publisher -Offer $offer -Skus $Skus -Version $version
$LogOut = "Completed image prep 'Publisher:'$Publisher 'Offer:'$offer 'Sku:'$Skus 'Version:'$version"
Log-Command -Description $LogOut -LogFile $LogOutFile
}
Function MakeImagePlanInfo_hortonwowk_hdp {
param(
	[string]$VMName = $VMName,
	[string]$Publisher = 'hortonworks',
	[string]$offer = 'hdpimage',
	[string]$Skus = 'hdpimage',
	[string]$version = 'latest',
	[string]$Product = 'hdpimage',
	[string]$name = 'hdpimage'
)
Write-Host "Image Creation in Process - Plan Info - HortonWorks" -ForegroundColor White
Write-Host 'Publisher:'$Publisher 'Offer:'$offer 'Sku:'$Skus 'Version:'$version
$script:VirtualMachine= Set-AzureRmVMPlan -VM $VirtualMachine -Name $name -Publisher $Publisher -Product $Product
$script:VirtualMachine = Set-AzureRmVMOperatingSystem -VM $VirtualMachine -linux -ComputerName $VMName -Credential $Credential1
$script:VirtualMachine = Set-AzureRmVMSourceImage -VM $VirtualMachine -PublisherName $Publisher -Offer $offer -Skus $Skus -Version $version
$LogOut = "Completed image prep 'Publisher:'$Publisher 'Offer:'$offer 'Sku:'$Skus 'Version:'$version"
Log-Command -Description $LogOut -LogFile $LogOutFile
}

Function MakeImagenoPlanInfo_w2012r2vs2015 {
param(
	[string]$VMName = $VMName,
	[string]$Publisher = 'MicrosoftVisualStudio',
	[string]$offer = 'VisualStudio',
	[string]$Skus = 'VS-2015-Ent-AzureSDK-2.9-WS2012R2',
	[string]$version = 'latest'
)
Write-Host "Image Creation in Process - No Plan Info - MicrosoftVisualStudio" -ForegroundColor White
Write-Host 'Publisher:'$Publisher 'Offer:'$offer 'Sku:'$Skus 'Version:'$version
$script:VirtualMachine = Set-AzureRmVMOperatingSystem -VM $VirtualMachine -Windows -ComputerName $VMName -Credential $Credential1 -ProvisionVMAgent -EnableAutoUpdate -WinRMHttp -Verbose
$script:VirtualMachine = Set-AzureRmVMSourceImage -VM $VirtualMachine -PublisherName $Publisher -Offer $offer -Skus $Skus -Version $version
$LogOut = "Completed image prep 'Publisher:'$Publisher 'Offer:'$offer 'Sku:'$Skus 'Version:'$version"
Log-Command -Description $LogOut -LogFile $LogOutFile
}

Function MakeImagenoPlanInfo_w2012r2dev15 {
param(
	[string]$VMName = $VMName,
	[string]$Publisher = 'MicrosoftVisualStudio',
	[string]$offer = 'VisualStudio',
	[string]$Skus = 'VS-Dev15-Preview3-Ent-AzureSDK-291-WS2012R2',
	[string]$version = 'latest'
)
Write-Host "Image Creation in Process - No Plan Info - Dev15 Preview" -ForegroundColor White
Write-Host 'Publisher:'$Publisher 'Offer:'$offer 'Sku:'$Skus 'Version:'$version
$script:VirtualMachine = Set-AzureRmVMOperatingSystem -VM $VirtualMachine -Windows -ComputerName $VMName -Credential $Credential1 -ProvisionVMAgent -EnableAutoUpdate -WinRMHttp -Verbose
$script:VirtualMachine = Set-AzureRmVMSourceImage -VM $VirtualMachine -PublisherName $Publisher -Offer $offer -Skus $Skus -Version $version
$LogOut = "Completed image prep 'Publisher:'$Publisher 'Offer:'$offer 'Sku:'$Skus 'Version:'$version"
Log-Command -Description $LogOut -LogFile $LogOutFile
}
#endregion

#region Create VNET
Function Create-Vnet {
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
Write-ConfigVNet
	Write-Host "Network Preparation in Process.."
	$subnet1 = New-AzureRmVirtualNetworkSubnetConfig -AddressPrefix $SubnetAddPrefix1 -Name $SubnetNameAddPrefix1
	$subnet2 = New-AzureRmVirtualNetworkSubnetConfig -AddressPrefix $SubnetAddPrefix2 -Name $SubnetNameAddPrefix2
	$subnet3 = New-AzureRmVirtualNetworkSubnetConfig -AddressPrefix $SubnetAddPrefix3 -Name $SubnetNameAddPrefix3
	$subnet4 = New-AzureRmVirtualNetworkSubnetConfig -AddressPrefix $SubnetAddPrefix4 -Name $SubnetNameAddPrefix4
	$subnet5 = New-AzureRmVirtualNetworkSubnetConfig -AddressPrefix $SubnetAddPrefix5 -Name $SubnetNameAddPrefix5
	$subnet6 = New-AzureRmVirtualNetworkSubnetConfig -AddressPrefix $SubnetAddPrefix6 -Name $SubnetNameAddPrefix6
	$subnet7 = New-AzureRmVirtualNetworkSubnetConfig -AddressPrefix $SubnetAddPrefix7 -Name $SubnetNameAddPrefix7
	$subnet8 = New-AzureRmVirtualNetworkSubnetConfig -AddressPrefix $SubnetAddPrefix8 -Name $SubnetNameAddPrefix8
	Try
	{
	New-AzureRmVirtualNetwork -Location $Location -Name $VNetName -ResourceGroupName $vnetrg -AddressPrefix $AddRange -Subnet $subnet1,$subnet2,$subnet3,$subnet4,$subnet5,$subnet6,$subnet7,$subnet8 –Confirm:$false -WarningAction SilentlyContinue -Force | Out-Null
	Get-AzureRmVirtualNetwork -Name $VNetName -ResourceGroupName $vnetrg | Get-AzureRmVirtualNetworkSubnetConfig -WarningAction SilentlyContinue | Out-Null
	Write-Host "Network Preparation completed" -ForegroundColor White
	$LogOut = "Completed Network Configuration of $VNetName"
	Log-Command -Description $LogOut -LogFile $LogOutFile
	}
	Catch
	{
	Write-Host -foregroundcolor Yellow `
	"$($_.Exception.Message)"; `
	$LogOut = "$($_.Exception.Message)"
	Log-Command -Description $LogOut -LogFile $LogOutFile
	break
	}
}
#endregion

#region Create NSG
Function Create-NSG {
param(
[string]$NSGName = $NSGName,
[string]$Location = $Location,
[string]$vnetrg = $vnetrg
)
	Try
	{
			Write-Host "Network Security Group Preparation in Process.."
		$httprule = New-AzureRmNetworkSecurityRuleConfig -Name "FrontEnd_HTTP" -Description "HTTP Exception for Web frontends" -Protocol Tcp -SourcePortRange "80" -DestinationPortRange "80" -SourceAddressPrefix "*" -DestinationAddressPrefix "10.120.0.0/21" -Access Allow -Direction Inbound -Priority 200
		$httpsrule = New-AzureRmNetworkSecurityRuleConfig -Name "FrontEnd_HTTPS" -Description "HTTPS Exception for Web frontends" -Protocol Tcp -SourcePortRange "443" -DestinationPortRange "443" -SourceAddressPrefix "*" -DestinationAddressPrefix "10.120.0.0/21" -Access Allow -Direction Inbound -Priority 201
		$sshrule = New-AzureRmNetworkSecurityRuleConfig -Name "FrontEnd_SSH" -Description "SSH Exception for Web frontends" -Protocol Tcp -SourcePortRange "22" -DestinationPortRange "22" -SourceAddressPrefix "*" -DestinationAddressPrefix "10.120.0.0/21" -Access Allow -Direction Inbound ` -Priority 203
		$rdprule = New-AzureRmNetworkSecurityRuleConfig -Name "FrontEnd_RDP" -Description "RDP Exception for frontends" -Protocol Tcp -SourcePortRange "3389" -DestinationPortRange "3389" -SourceAddressPrefix "*" -DestinationAddressPrefix "10.120.0.0/21" -Access Allow -Direction Inbound ` -Priority 204
		$nsg = New-AzureRmNetworkSecurityGroup -ResourceGroupName $vnetrg -Location $Location -Name $NSGName -SecurityRules $httprule,$httpsrule,$sshrule,$rdprule –Confirm:$false -WarningAction SilentlyContinue -Force | Out-Null
		Get-AzureRmNetworkSecurityGroup -Name $NSGName -ResourceGroupName $vnetrg -WarningAction SilentlyContinue | Out-Null
		Write-Host "Network Security Group configuration completed" -ForegroundColor White
		$secrules = Get-AzureRmNetworkSecurityGroup -Name $NSGName -ResourceGroupName $vnetrg -ExpandResource NetworkInterfaces | Get-AzureRmNetworkSecurityRuleConfig | Ft Name,Description,Direction,SourcePortRange,DestinationPortRange,DestinationPortRange,SourceAddressPrefix,Access
		$defsecrules = Get-AzureRmNetworkSecurityGroup -Name $NSGName -ResourceGroupName $vnetrg -ExpandResource NetworkInterfaces | Get-AzureRmNetworkSecurityRuleConfig -DefaultRules | Ft Name,Description,Direction,SourcePortRange,DestinationPortRange,DestinationAddressPrefix,SourceAddressPrefix,Access
		$LogOut = "Security Rules added for $NSGName"
		Log-Command -Description $LogOut -LogFile $LogOutFile
		$LogOut = "Completed NSG Configuration of $NSGName"
		Log-Command -Description $LogOut -LogFile $LogOutFile
	}
	Catch
	{
	Write-Host -foregroundcolor Yellow `
	"Exception Encountered"; `
	$ErrorMessage = $_.Exception.Message
	$LogOut  = 'Error '+$ErrorMessage
	Log-Command -Description $LogOut -LogFile $LogOutFile
	break
	}
}
#endregion

#region Match Subnet
Function Subnet-Match {
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
#endregion

#region Show VM Configuration
Function Write-ConfigVM {
param(
$Subnet1 = $script:Subnet1,
$Subnet2 = $script:Subnet2
)

Write-Host "                                                               "
$time = " Start Time " + (Get-Date -UFormat "%d-%m-%Y %H:%M:%S")
Write-Host VM CONFIGURATION - $time ----------- -ForegroundColor Cyan
Write-Host "                                                               "
Write-Host "Action Type:" $ActionType
Write-Host "VM Name: $VMName " -ForegroundColor White
Write-Host "Resource Group Name: $rg"
Write-Host "Server Type: $vmMarketImage"
Write-Host "Geo Location: $Location"
Write-Host "VNET Name: $vNetName"
Write-Host "Storage Account Name: $StorageName"
Write-Host "Storage Account Type: $StorageType"
Select-NicDescrtipt
If ($ConfigIPs -eq "StatPvtNoPubSingle")
{ Write-Host "Public Ip Will not be created" -ForegroundColor White
Write-Host "Nic1: $PvtIPNic1"
Subnet-Match $Subnet1
}
If ($ConfigIPs -eq "StatPvtNoPubDual")
{ Write-Host "Public Ip Will not be created" -ForegroundColor White
Write-Host "Nic1: $PvtIPNic1"
Write-Host "Nic2: $PvtIPNic2"
Subnet-Match $Subnet1
Subnet-Match $Subnet2
}
If ($ConfigIPs -eq "Single")
{ Write-Host "Public Ip Will be created"
Subnet-Match $Subnet1
}
If ($ConfigIPs -eq "Dual")
{ Write-Host "Public Ip Will be created"
Subnet-Match $Subnet1
Subnet-Match $Subnet2
}
If ($ConfigIPs -eq "PvtSingleStat")
{ Write-Host "Public Ip Will be created"
Subnet-Match $Subnet1
Write-Host "Nic1: $PvtIPNic1"
}
If ($ConfigIPs -eq "PvtDualStat")
{ Write-Host "Public Ip Will be created"
Subnet-Match $Subnet1
Subnet-Match $Subnet2
Write-Host "Nic1: $PvtIPNic1"
Write-Host "Nic2: $PvtIPNic2"
}
if($AddExtension -or $BatchAddExtension -eq 'True') {
Write-Host "Extension selected for deployment: $AzExtConfig "
}
if($AddAvailabilitySet -or $BatchAddAvset -eq 'True') {
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
#endregion

#region Show Network Config
Function Write-ConfigVnet {
Write-Host "                                                               "
$time = " Start Time " + (Get-Date -UFormat "%d-%m-%Y %H:%M:%S")
Write-Host VNET CONFIGURATION - $time --------- -ForegroundColor Cyan
Write-Host "                                                               "
Write-Host "Action Type:" $ActionType
Write-Host "Geo Location: $Location"
Write-Host "VNET Name: $vNetName"
Write-Host "VNET Resource Group Name: $vnetrg"
Write-Host "Address Range:  $AddRange"
if($CreateNSG -or $BatchAddNSG -eq 'True')
{
Write-Host "NSG Name: $NSGName"
}
Write-Host "                                                               "
}
#endregion

#region Show Final Report
Function Write-Results {
param(
$Subnet1 = $script:Subnet1,
$Subnet2 = $script:Subnet2
)
Write-Host "                                                               "
Write-Host "--------------------------------------------------------------" -ForegroundColor Cyan
Write-Host "                                                               "
Write-Host "Completed Deployment of:"  -ForegroundColor Cyan
Write-Host "Action Type:" $ActionType
Write-Host "VM Name: $VMName " -ForegroundColor White
Write-Host "Resource Group Name: $rg"
Write-Host "Server Type: $vmMarketImage"
Write-Host "VNET Resource Group Name: $vnetrg" -ForegroundColor White
Write-Host "VNET Name: $VNetName" -ForegroundColor White
Write-Host "Storage Account Name:  $StorageNameVerified"

if($AddExtension -or $BatchAddExtension -eq 'True'){
Write-Host "Extension deployed: $AzExtConfig "
}
if($AddAvailabilitySet -or $BatchAddAvset -eq 'True') {
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
Write-FinalState
}
#endregion

#region Show Completed State
Function Write-FinalState {
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
Results-Rollup
Write-Host "                                                               "
}
#endregion

#region Show Results
Function Results-Rollup {
Write-Host "                                                               "
Write-Host "Storage Accounts for $rg" -NoNewLine
Get-AzurermStorageAccount -ResourceGroupName $rg -WarningAction SilentlyContinue | ft StorageAccountName,Location,ResourceGroupname -Wrap

if($AddAvailabilitySet -or $BatchAddAvset -eq 'True'){
Write-Host "Availability Sets for $rg"
Get-AzurermAvailabilitySet -ResourceGroupName $rg -WarningAction SilentlyContinue | ft Name,ResourceGroupName -Wrap
}
}
#endregion

#region Provision Resource Group
Function Provision-RG
{
	Param(
		[string]$rg
	)
New-AzureRmResourceGroup -Name $rg -Location $Location –Confirm:$false -WarningAction SilentlyContinue -Force | Out-Null
}
#endregion

#region Get information
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
}

#region Create Storage
Function Create-Storage {
		param(
		[string]$StorageName = $script:StorageNameVerified,
		[string]$rg = $rg,
		[string]$StorageType = $StorageType,
		[string]$Location = $Location
		)
		Write-Host "Starting Storage Creation.."
		$script:StorageAccount = New-AzureRmStorageAccount -ResourceGroupName $rg -Name $StorageName.ToLower() -Type $StorageType -Location $Location -ErrorAction Stop -WarningAction SilentlyContinue
		Write-Host "Completed Storage Creation" -ForegroundColor White
		$LogOut = "Storage Configuration completed: $StorageName"
		Log-Command -Description $LogOut -LogFile $LogOutFile
		} # Creates Storage
#endregion

#region Create VM
Function Create-VM {
	param(
	[string]$VMName = $VMName,
	[ValidateSet("w2k12","w2k8","w2k16","sql2016","biztalk2013","tfs","biztalk2016","vs2015","dev15","incredibuild","msnav2016","red67","red72","suse","free","ubuntu","centos","chef","check","pfsense","lamp","jenkins","nodejs","elastics","postgressql","splunk","horton-dp","serverr","horton-hdp","f5bigip","f5appfire","barrahourngfw","barrabyolngfw","barrahourspam","barrabyolspam","mysql","share2013","share2016","mongodb","nginxstack","hadoop","neos","tomcat","redis","gitlab","jruby","tableau","cloudera","datastax","O365-suite","ads-linuxdatascience","ads-datascience","cloud-conn")]
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
	$CreateNSG = $CreateNSG,
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
			Write-ConfigVM
			Create-Storage
			Create-AvailabilitySet
			Configure-Nics  #Sets network connection info
			MakeImagePlanInfo_Pfsense # Begins Image Creation
			Set-NicConfiguration # Adds Network Interfaces
			Configure-Image # Completes Image Creation
			Provision-Vm
}
		"*free*" {
			Write-ConfigVM
			Create-Storage
			Create-AvailabilitySet
			Configure-Nics  #Sets network connection info
			MakeImageNoPlanInfo_FreeBsd  # Begins Image Creation
			Set-NicConfiguration # Adds Network Interfaces
			Configure-Image # Completes Image Creation
			Provision-Vm
}
		"*red72*" {
			Write-ConfigVM
			Create-Storage
			Create-AvailabilitySet
			Configure-Nics  #Sets network connection info
			MakeImageNoPlanInfo_RedHat72  # Begins Image Creation
			Set-NicConfiguration # Adds Network Interfaces
			Configure-Image # Completes Image Creation
			Provision-Vm
}
		"*red67*" {
			Write-ConfigVM
			Create-Storage
			Create-AvailabilitySet
			Configure-Nics  #Sets network connection info
			MakeImageNoPlanInfo_RedHat67  # Begins Image Creation
			Set-NicConfiguration # Adds Network Interfaces
			Configure-Image # Completes Image Creation
			Provision-Vm
}
		"*w2k12*" {
			Write-ConfigVM
			Create-Storage
			Create-AvailabilitySet
			Configure-Nics  #Sets network connection info
			MakeImageNoPlanInfo_w2k12  # Begins Image Creation
			Set-NicConfiguration # Adds Network Interfaces
			Configure-Image # Completes Image Creation
			Provision-Vm
}
		"*MSNav2016*" {
			Write-ConfigVM
			Create-Storage
			Create-AvailabilitySet
			Configure-Nics  #Sets network connection info
			MakeImageNoPlanInfo_MSNAV2016  # Begins Image Creation
			Set-NicConfiguration # Adds Network Interfaces
			Configure-Image # Completes Image Creation
			Provision-Vm
}
		"*sql2016*" {
			Write-ConfigVM
			Create-Storage
			Create-AvailabilitySet
			Configure-Nics  #Sets network connection info
			MakeImageNoPlanInfo_sql2k16  # Begins Image Creation
			Set-NicConfiguration # Adds Network Interfaces
			Configure-Image # Completes Image Creation
			Provision-Vm
}
		"*check*" {
			Write-ConfigVM
			Create-Storage
			Create-AvailabilitySet
			Configure-Nics  #Sets network connection info
			MakeImagePlanInfo_Checkpoint  # Begins Image Creation
			Set-NicConfiguration # Adds Network Interfaces
			Configure-Image # Completes Image Creation
			Provision-Vm
}
		"*cloudera*" {
			Write-ConfigVM
			Create-Storage
			Create-AvailabilitySet
			Configure-Nics  #Sets network connection info
			MakeImagePlanInfo_cloudera # Begins Image Creation
			Set-NicConfiguration # Adds Network Interfaces
			Configure-Image # Completes Image Creation
			Provision-Vm
}
		"*datastax*" {
			Write-ConfigVM
			Create-Storage
			Create-AvailabilitySet
			Configure-Nics  #Sets network connection info
			MakeImagePlanInfo_datastax # Begins Image Creation
			Set-NicConfiguration # Adds Network Interfaces
			Configure-Image # Completes Image Creation
			Provision-Vm
}
		"*cent*" {
			Write-ConfigVM
			Create-Storage
			Create-AvailabilitySet
			Configure-Nics  #Sets network connection info
			MakeImageNoPlanInfo_CentOs  # Begins Image Creation
			Set-NicConfiguration # Adds Network Interfaces
			Configure-Image # Completes Image Creation
			Provision-Vm
}
		"*Suse*" {
			Write-ConfigVM
			Create-Storage
			Create-AvailabilitySet
			Configure-Nics  #Sets network connection info
			MakeImageNoPlanInfo_Suse  # Begins Image Creation
			Set-NicConfiguration # Adds Network Interfaces
			Configure-Image # Completes Image Creation
			Provision-Vm
}
		"*w2k8*" {
			Write-ConfigVM
			Create-Storage
			Create-AvailabilitySet
			Configure-Nics  #Sets network connection info
			MakeImageNoPlanInfo_w2k8  # Begins Image Creation
			Set-NicConfiguration # Adds Network Interfaces
			Configure-Image # Completes Image Creation
			Provision-Vm
}
		"*w2k16*" {
			Write-ConfigVM
			Create-Storage
			Create-AvailabilitySet
			Configure-Nics  #Sets network connection info
			MakeImageNoPlanInfo_w2k16  # Begins Image Creation
			Set-NicConfiguration # Adds Network Interfaces
			Configure-Image # Completes Image Creation
			Provision-Vm
}
		"*chef*" {
			Write-ConfigVM
			Create-Storage
			Create-AvailabilitySet
			Configure-Nics  #Sets network connection info
			MakeImagePlanInfo_Chef  # Begins Image Creation
			Set-NicConfiguration # Adds Network Interfaces
			Configure-Image # Completes Image Creation
			Provision-Vm
}
		"*ads-datascience*" {
			Write-ConfigVM
			Create-Storage
			Create-AvailabilitySet
			Configure-Nics  #Sets network connection info
			MakeImagenoPlanInfo_ads_stddatascience # Begins Image Creation
			Set-NicConfiguration # Adds Network Interfaces
			Configure-Image # Completes Image Creation
			Provision-Vm
}
		"*ads-linuxdatascience*" {
			Write-ConfigVM
			Create-Storage
			Create-AvailabilitySet
			Configure-Nics  #Sets network connection info
			MakeImagenoPlanInfo_ads_datascience # Begins Image Creation
			Set-NicConfiguration # Adds Network Interfaces
			Configure-Image # Completes Image Creation
			Provision-Vm
}
		"*tableau*" {
			Write-ConfigVM
			Create-Storage
			Create-AvailabilitySet
			Configure-Nics  #Sets network connection info
			MakeImagePlanInfo_tableau # Begins Image Creation
			Set-NicConfiguration # Adds Network Interfaces
			Configure-Image # Completes Image Creation
			Provision-Vm
}
		"*RevoAn-Lin*" {
			Write-ConfigVM
			Create-Storage
			Create-AvailabilitySet
			Configure-Nics  #Sets network connection info
			MakeImagePlanInfo_RevAnalytics_cent # Begins Image Creation
			Set-NicConfiguration # Adds Network Interfaces
			Configure-Image # Completes Image Creation
			Provision-Vm
}
		"*RevoAn-Win*" {
			Write-ConfigVM
			Create-Storage
			Create-AvailabilitySet
			Configure-Nics  #Sets network connection info
			MakeImagePlanInfo_RevAnalytics_win # Begins Image Creation
			Set-NicConfiguration # Adds Network Interfaces
			Configure-Image # Completes Image Creation
			Provision-Vm
}
		"*lamp*" {
			Write-ConfigVM
			Create-Storage
			Create-AvailabilitySet
			Configure-Nics  #Sets network connection info
			MakeImagePlanInfo_Bitnami_Lamp # Begins Image Creation
			Set-NicConfiguration # Adds Network Interfaces
			Configure-Image # Completes Image Creation
			Provision-Vm
}
		"*mongodb*" {
			Write-ConfigVM
			Create-Storage
			Create-AvailabilitySet
			Configure-Nics  #Sets network connection info
			MakeImagePlanInfo_Bitnami_mongodb # Begins Image Creation
			Set-NicConfiguration # Adds Network Interfaces
			Configure-Image # Completes Image Creation
			Provision-Vm
}
		"*mysql*" {
			Write-ConfigVM
			Create-Storage
			Create-AvailabilitySet
			Configure-Nics  #Sets network connection info
			MakeImagePlanInfo_Bitnami_mysql # Begins Image Creation
			Set-NicConfiguration # Adds Network Interfaces
			Configure-Image # Completes Image Creation
			Provision-Vm
}
		"*elastics*" {
			Write-ConfigVM
			Create-Storage
			Create-AvailabilitySet
			Configure-Nics  #Sets network connection info
			MakeImagePlanInfo_Bitnami_elastic # Begins Image Creation
			Set-NicConfiguration # Adds Network Interfaces
			Configure-Image # Completes Image Creation
			Provision-Vm
}
		"*nodejs*" {
			Write-ConfigVM
			Create-Storage
			Create-AvailabilitySet
			Configure-Nics  #Sets network connection info
			MakeImagePlanInfo_Bitnami_nodejs # Begins Image Creation
			Set-NicConfiguration # Adds Network Interfaces
			Configure-Image # Completes Image Creation
			Provision-Vm
}
		"*nginxstack*" {
			Write-ConfigVM
			Create-Storage
			Create-AvailabilitySet
			Configure-Nics  #Sets network connection info
			MakeImagePlanInfo_Bitnami_nginxstack # Begins Image Creation
			Set-NicConfiguration # Adds Network Interfaces
			Configure-Image # Completes Image Creation
			Provision-Vm
}
		"*postgressql*" {
			Write-ConfigVM
			Create-Storage
			Create-AvailabilitySet
			Configure-Nics  #Sets network connection info
			MakeImagePlanInfo_Bitnami_postgresql # Begins Image Creation
			Set-NicConfiguration # Adds Network Interfaces
			Configure-Image # Completes Image Creation
			Provision-Vm
}
		"*incredibuild*" {
			Write-ConfigVM
			Create-Storage
			Create-AvailabilitySet
			Configure-Nics  #Sets network connection info
			MakeImagePlanInfo_incredibuild # Begins Image Creation
			Set-NicConfiguration # Adds Network Interfaces
			Configure-Image # Completes Image Creation
			Provision-Vm
}
		"*horton-dp*" {
			Write-ConfigVM
			Create-Storage
			Create-AvailabilitySet
			Configure-Nics  #Sets network connection info
			MakeImagePlanInfo_hortonwowk_dp  # Begins Image Creation
			Set-NicConfiguration # Adds Network Interfaces
			Configure-Image # Completes Image Creation
			Provision-Vm
}
		"*horton-hdp*" {
			Write-ConfigVM
			Create-Storage
			Create-AvailabilitySet
			Configure-Nics  #Sets network connection info
			MakeImagePlanInfo_hortonwowk_hdp # Begins Image Creation
			Set-NicConfiguration # Adds Network Interfaces
			Configure-Image # Completes Image Creation
			Provision-Vm
}
		"*puppet*" {
			Write-ConfigVM
			Create-Storage
			Create-AvailabilitySet
			Configure-Nics  #Sets network connection info
			MakeImagePlanInfo_puppet_puppetent # Begins Image Creation
			Set-NicConfiguration # Adds Network Interfaces
			Configure-Image # Completes Image Creation
			Provision-Vm
}

		"*share2013*" {
			Write-ConfigVM
			Create-Storage
			Create-AvailabilitySet
			Configure-Nics  #Sets network connection info
			MakeImageNoPlanInfo_SharePoint2k13 # Begins Image Creation
			Set-NicConfiguration # Adds Network Interfaces
			Configure-Image # Completes Image Creation
			Provision-Vm
}
		"*tfs*" {
			Write-ConfigVM
			Create-Storage
			Create-AvailabilitySet
			Configure-Nics  #Sets network connection info
			MakeImageNoPlanInfo_TeamFoundationServer # Begins Image Creation
			Set-NicConfiguration # Adds Network Interfaces
			Configure-Image # Completes Image Creation
			Provision-Vm
}
		"*VS2015*" {
			Write-ConfigVM
			Create-Storage
			Create-AvailabilitySet
			Configure-Nics  #Sets network connection info
			MakeImagenoPlanInfo_w2012r2vs2015 # Begins Image Creation
			Set-NicConfiguration # Adds Network Interfaces
			Configure-Image # Completes Image Creation
			Provision-Vm
}
		"*DEV15*" {
			Write-ConfigVM
			Create-Storage
			Create-AvailabilitySet
			Configure-Nics  #Sets network connection info
			MakeImagenoPlanInfo_w2012r2dev15 # Begins Image Creation
			Set-NicConfiguration # Adds Network Interfaces
			Configure-Image # Completes Image Creation
			Provision-Vm
}
		"*biztalk2013*" {
			Write-ConfigVM
			Create-Storage
			Create-AvailabilitySet
			Configure-Nics  #Sets network connection info
			MakeImageNoPlanInfo_Biztalk-Enterprise # Begins Image Creation
			Set-NicConfiguration # Adds Network Interfaces
			Configure-Image # Completes Image Creation
			Provision-Vm
}
		"*biztalk2016*" {
			Write-ConfigVM
			Create-Storage
			Create-AvailabilitySet
			Configure-Nics  #Sets network connection info
			MakeImageNoPlanInfo_Biztalk2016-PreRelease # Begins Image Creation
			Set-NicConfiguration # Adds Network Interfaces
			Configure-Image # Completes Image Creation
			Provision-Vm
}
		"*share2016*" {
			Write-ConfigVM
			Create-Storage
			Create-AvailabilitySet
			Configure-Nics  #Sets network connection info
			MakeImageNoPlanInfo_SharePoint2k16 # Begins Image Creation
			Set-NicConfiguration # Adds Network Interfaces
			Configure-Image # Completes Image Creation
			Provision-Vm
}
		"*serverr*" {
			Write-ConfigVM
			Create-Storage
			Create-AvailabilitySet
			Configure-Nics  #Sets network connection info
			MakeImagePlanInfo_Microsoft_Serverr # Begins Image Creation
			Set-NicConfiguration # Adds Network Interfaces
			Configure-Image # Completes Image Creation
			Provision-Vm
}
		"*ubuntu*" {
			Write-ConfigVM
			Create-Storage
			Create-AvailabilitySet
			Configure-Nics  #Sets network connection info
			MakeImageNoPlanInfo_Ubuntu # Begins Image Creation
			Set-NicConfiguration # Adds Network Interfaces
			Configure-Image # Completes Image Creation
			Provision-Vm
}
		"*f5bigip*" {
			Write-ConfigVM
			Create-Storage
			Create-AvailabilitySet
			Configure-Nics  #Sets network connection info
			MakeImagePlanInfo_f5_bigip_good_byol # Begins Image Creation
			Set-NicConfiguration # Adds Network Interfaces
			Configure-Image # Completes Image Creation
			Provision-Vm
}
		"*f5appfire*" {
			Write-ConfigVM
			Create-Storage
			Create-AvailabilitySet
			Configure-Nics  #Sets network connection info
			MakeImagePlanInfo_f5_webappfire_byol # Begins Image Creation
			Set-NicConfiguration # Adds Network Interfaces
			Configure-Image # Completes Image Creation
			Provision-Vm
}
		"*barrahourngfw*" {
			Write-ConfigVM
			Create-Storage
			Create-AvailabilitySet
			Configure-Nics  #Sets network connection info
			MakeImagePlanInfo_Barracuda_ng_firewall_hourly # Begins Image Creation
			Set-NicConfiguration # Adds Network Interfaces
			Configure-Image # Completes Image Creation
			Provision-Vm
}
		"*barrabyolngfw*" {
			Write-ConfigVM
			Create-Storage
			Create-AvailabilitySet
			Configure-Nics  #Sets network connection info
			MakeImagePlanInfo_Barracuda_ng_firewall_byol # Begins Image Creation
			Set-NicConfiguration # Adds Network Interfaces
			Configure-Image # Completes Image Creation
			Provision-Vm
}
		"*barrahourspam*" {
			Write-ConfigVM
			Create-Storage
			Create-AvailabilitySet
			Configure-Nics  #Sets network connection info
			MakeImagePlanInfo_Barracuda_spam_firewall_hourly # Begins Image Creation
			Set-NicConfiguration # Adds Network Interfaces
			Configure-Image # Completes Image Creation
			Provision-Vm
}
		"*barrabyolspam*" {
			Write-ConfigVM
			Create-Storage
			Create-AvailabilitySet
			Configure-Nics  #Sets network connection info
			MakeImagePlanInfo_Barracuda_spam_firewall_byol # Begins Image Creation
			Set-NicConfiguration # Adds Network Interfaces
			Configure-Image # Completes Image Creation
			Provision-Vm
}
		"*O365-Suite*" {
			Write-ConfigVM
			Create-Storage
			Create-AvailabilitySet
			Configure-Nics  #Sets network connection info
			MakeImagePlanInfo_metavistech # Begins Image Creation
			Set-NicConfiguration # Adds Network Interfaces
			Configure-Image # Completes Image Creation
			Provision-Vm
}
		"*hadoop*" {
			Write-ConfigVM
			Create-Storage
			Create-AvailabilitySet
			Configure-Nics  #Sets network connection info
			MakeImagePlanInfo_Bitnami_hadoop # Begins Image Creation
			Set-NicConfiguration # Adds Network Interfaces
			Configure-Image # Completes Image Creation
			Provision-Vm
}
		"*tomcat*" {
			Write-ConfigVM
			Create-Storage
			Create-AvailabilitySet
			Configure-Nics  #Sets network connection info
			MakeImagePlanInfo_Bitnami_tomcat # Begins Image Creation
			Set-NicConfiguration # Adds Network Interfaces
			Configure-Image # Completes Image Creation
			Provision-Vm
}
		"*redis*" {
			Write-ConfigVM
			Create-Storage
			Create-AvailabilitySet
			Configure-Nics  #Sets network connection info
			MakeImagePlanInfo_Bitnami_redis # Begins Image Creation
			Set-NicConfiguration # Adds Network Interfaces
			Configure-Image # Completes Image Creation
			Provision-Vm
}
		"*neos*" {
			Write-ConfigVM
			Create-Storage
			Create-AvailabilitySet
			Configure-Nics  #Sets network connection info
			MakeImagePlanInfo_Bitnami_neos # Begins Image Creation
			Set-NicConfiguration # Adds Network Interfaces
			Configure-Image # Completes Image Creation
			Provision-Vm
}
		"*jruby*" {
			Write-ConfigVM
			Create-Storage
			Create-AvailabilitySet
			Configure-Nics  #Sets network connection info
			MakeImagePlanInfo_Bitnami_jrubystack # Begins Image Creation
			Set-NicConfiguration # Adds Network Interfaces
			Configure-Image # Completes Image Creation
			Provision-Vm
}
		"*jenkins*" {
			Write-ConfigVM
			Create-Storage
			Create-AvailabilitySet
			Configure-Nics  #Sets network connection info
			MakeImagePlanInfo_Bitnami_jenkins # Begins Image Creation
			Set-NicConfiguration # Adds Network Interfaces
			Configure-Image # Completes Image Creation
			Provision-Vm
}
		default{"An unsupported image was referenced"}
	}
}
#endregion

#region Verify Windows OS
Function Verify-ExtWin {
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
#endregion

#region Verify Linux OS
Function Verify-ExtLinux {
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
#endregion

#region Configure DSC
Function Configure-DSC {
param(

 [Parameter(Mandatory=$False,ValueFromPipelinebyPropertyName=$true)]
 [ValidateSet("WIN_MSUpdate","WIN_IIS","SharePoint2013_CU")]
 [string]
 $DSCConfig = 'SharePoint2013_CU',

[Parameter(Mandatory=$False,ValueFromPipelinebyPropertyName=$true)]
 [string]
 $ConfigurationName = "SharePoint2013_CU",
 [Parameter(Mandatory=$False,ValueFromPipelinebyPropertyName=$true)]
 [string]
 $ArchiveBlobName = "SharePoint2013_CU.ps1.zip",

 [Parameter(Mandatory=$False,ValueFromPipelinebyPropertyName=$true)]
 [string]
 $ConfigurationPath = $dscdir + '\SharePoint2013_CU.ps1',

 [Parameter(Mandatory=$False,ValueFromPipelinebyPropertyName=$true)]
 [string]
 $storageAccountName = $script:StorageNameVerified,

 [Parameter(Mandatory=$False,ValueFromPipelinebyPropertyName=$true)]
 [string]
 $StorageType = "Standard_GRS"

)

	 switch -Wildcard ($DSCConfig)
	{
		"*WIN_IIS*" {
		Publish-AzureRmVMDscConfiguration -ResourceGroupName $rg -ConfigurationPath $IISConfigurationPath -StorageAccountName $storageAccountName -Force
		Set-AzureRmVMDscExtension -ResourceGroupName $rg -VMName $VMName -ArchiveBlobName $IISArchiveBlobName -ArchiveStorageAccountName $storageAccountName -ConfigurationName $IISConfigurationName -Version 2.19
}
		"*WIN_MSUpdate*" {
		Publish-AzureRmVMDscConfiguration -ResourceGroupName $rg -ConfigurationPath $ConfigurationPath -StorageAccountName $storageAccountName -Force
		Set-AzureRmVMDscExtension -ResourceGroupName $rg -VMName $VMName -ArchiveBlobName $ArchiveBlobName -ArchiveStorageAccountName $storageAccountName -ConfigurationName $ConfigurationName -Version 2.19
		$LogOut = "Added VM DSC to Storage Account $storageAccountName from file $ConfigurationPath"
		Log-Command -Description $LogOut -LogFile $LogOutFile
}
		"*SharePoint2013_CU*" {
		Publish-AzureRmVMDscConfiguration -ResourceGroupName $rg -ConfigurationPath $ConfigurationPath -StorageAccountName $storageAccountName -Force
		Set-AzureRmVMDscExtension -ResourceGroupName $rg -VMName $VMName -ArchiveBlobName $ArchiveBlobName -ArchiveStorageAccountName $storageAccountName -ConfigurationName $ConfigurationName -Version 2.19
		$LogOut = "Added VM DSC to Storage Account $storageAccountName from file $ConfigurationPath"
		Log-Command -Description $LogOut -LogFile $LogOutFile
}
		default{"An unsupported DSC command was used"}
	}
}
#endregion

#region Verify Upload Resources
Function Test-Upload {
param(
	$localFolder = $localFolder
	)

$folderexist = Test-Path -Path $localFolder
if(!$folderexist)
{
Write-Host "Folder Doesn't Exist"
exit }
else
{  }
}
#endregion

#region Upload Custom Script
Function Upload-CustomScript {
	param(
	$StorageName = $script:StorageNameVerified,
	$containerName = $containerName,
	$rg = $rg,
	$localFolder = $localFolder
	)
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
		  Set-AzureStorageBlobContent -File $filename -Container $containerName -Blob $blobName -Context $blobContext -Force -BlobType Append -WarningAction SilentlyContinue | Out-Null
		  Get-AzureStorageBlob -Container $containerName -Context $blobContext -Blob $blobName -WarningAction SilentlyContinue | Out-Null
		}
		write-host "All files in $localFolder uploaded to $containerName!"
}
#endregion

#region Uninstall Extension
Function UnInstall-Ext {
	param(
		[string]$Location = $Location,
		[string]$rg = $rg,
		[string]$VMName = $VMName,
		[string]$customextname = $customextname,
		[string]$AzExtConfig = $AzExtConfig

	)
switch ($AzExtConfig)
	{
		"access" {
				Write-Host "VM Access Agent VM Image Removal in Process"
				Remove-AzureRmVMAccessExtension -ResourceGroupName $rg -VMName $VMName -Name "VMAccess" -Force -Confirm:$false
exit
}
		"msav" {
				Write-Host "MSAV Agent VM Image Removal in Process"
				Remove-AzureRmVMExtension -Name "MSAVExtension" -ResourceGroupName $rg -VMName $VMName -Force -Confirm:$false
exit
		}
		"customscript" {
				Write-Host "Removing custom script"
			exit
		}
		"diag" {
				Write-Host "Removing Azure Enhanced Diagnostics"
				Remove-AzureRmVMAEMExtension -ResourceGroupName $rg -VMName $VMName
			exit
		}
		"domjoin" {
				Write-Host "Removing Domain Join"
		}
		"linuxOsPatch" {
				Write-Host "Removing Azure OS Patching Linux"
			exit
				}
		"linuxbackup" {
				Write-Host "Removing Linux VMBackup"
				Remove-AzureRmVMBackup -ResourceGroupName $rg -VMName $VMName -Tag 'OSBackup'
			exit
				}
		"chefAgent" {
				Write-Host "Removing Chef Agent"
			exit
				}
		"opsinsightLinux" {
				Write-Host "Removing Linux Insight Agent"
			exit
				}
		"opsinsightWin" {
				Write-Host "Removing Windows Insight Agent"
			exit
				}
		"ESET" {
				Write-Host "Removing File Security"
			exit
				}
		"RegisterAzDSC" {
				Write-Host "Removing Azure Automation DSC"
			exit
				}
		"WinPuppet" {
				Write-Host "Removing Puppet Extension"
			exit
				}
		"PushDSC" {
				Write-Host "Removing DSC Extension"
				Remove-DscExt
			exit
				}
		"Bginfo" {
				Write-Host "Removing BgInfo Extension"
				Remove-AzureVMBGInfoExtension -VM $VMName
			exit
				}
		default{"An unsupported uninstall Extension command was used"}
	}
	exit
} # Deploys Azure Extensions
#endregion

Function Verify-StorageExists {
	param(
		$StorageName = $StorageName

	)
		$strexists = Get-AzureRmStorageAccount -ResourceGroupName $rg -Name $StorageName.ToLower() -WarningAction SilentlyContinue -ErrorAction SilentlyContinue
if(!$strexists)
{
	 $script:StorageNameVerified = $GenerateName.ToLower()
	Create-Storage
	break
}
	else {
	$script:StorageNameVerified = $StorageName.ToLower()
}
	}

#region Install Extension
Function Install-Ext {
	param(
		[string]$AzExtConfig = $AzExtConfig,
		[string]$NSGName = $NSGName,
		[string]$Location = $Location,
		[string]$rg = $rg,
		[string]$StorageName = $script:StorageNameVerified,
		[string]$VMName = $VMName,
		[string]$containerNameScripts = 'scripts',
		[string]$DomName =  'aip.local',
		[string]$customextname = $customextname,
		[string]$localfolderscripts = $customscriptsdir
	)
switch ($AzExtConfig)
	{
		"access" {
				Verify-ExtWin
				Write-Host "VM Access Agent VM Image Preparation in Process"
				Set-AzureRmVMAccessExtension -ResourceGroupName $rg -VMName $VMName -Name "VMAccess" -typeHandlerVersion "2.0" -Location $Location -Verbose -username $locadmin -password $locpassword | Out-Null
				Get-AzureRmVMAccessExtension -ResourceGroupName $rg -VMName $VMName -Name "VMAccess" -Status
				$LogOut = "Added VM Access Extension"
				Log-Command -Description $LogOut -LogFile $LogOutFile
				Write-Results
}
		"msav" {
				Verify-ExtWin
				Write-Host "MSAV Agent VM Image Preparation in Process"
				Set-AzureRmVMExtension  -ResourceGroupName $rg -VMName $VMName -Name "MSAVExtension" -ExtensionType "IaaSAntimalware" -Publisher "Microsoft.Azure.Security" -typeHandlerVersion 1.4 -Location $Location | Out-Null
				Get-AzureRmVMExtension -ResourceGroupName $rg -VMName $VMName -Name "MSAVExtension" -Status
				 $LogOut = "Added VM msav Extension"
				Log-Command -Description $LogOut -LogFile $LogOutFile
				Write-Results
}
		"customscript" {
				Verify-StorageExists
				Write-Host "Updating: $VMName in the Resource Group: $rg with a custom script: $customextname in Storage Account: $StorageName"
				if($CustomScriptUpload -eq 'True')
				{
				Test-Upload -localFolder $localfolderscripts
				Upload-CustomScript -StorageName $StorageName -rg $rg -containerName $containerNameScripts -localFolder $localfolderscripts
				}
				Set-AzureRmVMCustomScriptExtension -Name $customextname -ContainerName $containerName -ResourceGroupName $rg -VMName $VMName -StorageAccountName $StorageName -FileName $scriptname -Location $Location -TypeHandlerVersion "1.1" -WarningAction SilentlyContinue | Out-Null
				Get-AzureRmVMCustomScriptExtension -ResourceGroupName $rg -VMName $VMName -Name $customextname -Status | Out-Null
				 $LogOut = "Added VM Custom Script Extension for $scriptname"
				Log-Command -Description $LogOut -LogFile $LogOutFile
				Write-Results
}
		"diag" {
				Verify-StorageExists
				Write-Host "Adding Azure Enhanced Diagnostics to $VMName in $rg using the $StorageName Storage Account"
				Set-AzureRmVMAEMExtension -ResourceGroupName $rg -VMName $VMName -WADStorageAccountName $StorageName -InformationAction SilentlyContinue -WarningAction SilentlyContinue | Out-Null
				Get-AzureRmVMAEMExtension -ResourceGroupName $rg -VMName $VMName | Out-Null
				 $LogOut = "Added VM Enhanced Diag Extension to Storage Profile $StorageName"
				Log-Command -Description $LogOut -LogFile $LogOutFile
				Write-Results
}
		"domjoin" {
				Verify-ExtWin
				Write-Host "Domain Join active"
				Set-AzureRmVMADDomainExtension -DomainName $DomName -ResourceGroupName $rg -VMName $VMName -Location $Location -Name 'DomJoin' -WarningAction SilentlyContinue -Restart | Out-Null
				Get-AzureRmVMADDomainExtension -ResourceGroupName $rg  -VMName $VMName -Name 'DomJoin' | Out-Null
				 $LogOut = "Added VM Domain Join Extension for domain: $DomName "
				Log-Command -Description $LogOut -LogFile $LogOutFile
}
		"linuxOsPatch" {
				Write-Host "Adding Azure OS Patching Linux"
				Set-AzureRmVMExtension -VMName $VMName -ResourceGroupName $rg -Location $Location -Name "OSPatch" -ExtensionType "OSPatchingForLinux" -Publisher "Microsoft.OSTCExtensions" -typeHandlerVersion "2.0" -InformationAction SilentlyContinue -Verbose
				Get-AzureRmVMExtension -ResourceGroupName $rg -VMName $VMName -Name "OSPatch"
				 $LogOut = "Added VM OS Patch Extension"
				Log-Command -Description $LogOut -LogFile $LogOutFile
				Write-Results
		}
		"linuxbackup" {
				Write-Host "Adding Linux VMBackup to $VMName in the resource group $rg"
				Set-AzureRmVMBackupExtension -VMName $VMName -ResourceGroupName $rg -Name "VMBackup" -Tag "OSBackup" -WarningAction SilentlyContinue | Out-Null
				 $LogOut = "Added VM Backup Extension"
				Log-Command -Description $LogOut -LogFile $LogOutFile
				Write-Results
		}
		"chefAgent" {
				Write-Host "Adding Chef Agent"
				$ProtectedSetting = ''
				$Setting = ''
				Set-AzureRmVMExtension -ResourceGroupName $rg -VMName $VMName -Name "ChefStrap" -ExtensionType "ChefClient" -Publisher "Chef.Bootstrap.WindowsAzure" -typeHandlerVersion "1210.12" -Location $Location -Verbose -ProtectedSettingString $ProtectedSetting -SettingString $Setting | Out-Null
				Get-AzureRmVMExtension -ResourceGroupName $rg -VMName $VMName -Name "ChefStrap"
				 $LogOut = "Added VM Chef Extension"
				Log-Command -Description $LogOut -LogFile $LogOutFile
				Write-Results
}
		"opsinsightLinux" {
				Verify-ExtLinux
				Write-Host "Adding Linux Insight Agent"
				Set-AzureRmVMExtension -VMName $VMName -ResourceGroupName $rg -Location $Location -Name "OperationalInsights" -ExtensionType "OmsAgentForLinux" -Publisher "Microsoft.EnterpriseCloud.Monitoring" -typeHandlerVersion "1.0" -InformationAction SilentlyContinue -Verbose | Out-Null
				Get-AzureRmVMExtension -ResourceGroupName $rg -VMName $VMName -Name "OperationalInsights"
				 $LogOut = "Added OpsInsight Extension"
				Log-Command -Description $LogOut -LogFile $LogOutFile
				Write-Results
}
		"opsinsightWin" {
				Verify-ExtWin
				Write-Host "Adding Windows Insight Agent"
				Set-AzureRmVMExtension -VMName $VMName -ResourceGroupName $rg -Location $Location -Name "OperationalInsights" -ExtensionType "MicrosoftMonitoringAgent" -Publisher "Microsoft.EnterpriseCloud.Monitoring" -typeHandlerVersion "1.0" -InformationAction SilentlyContinue -Verbose | Out-Null
				Get-AzureRmVMExtension -ResourceGroupName $rg -VMName $VMName -Name "OperationalInsights"
				 $LogOut = "Added OpsInsight Extension"
				Log-Command -Description $LogOut -LogFile $LogOutFile
				Write-Results
}
		"ESET" {
				Verify-ExtWin
				Write-Host "Setting File Security"
				Set-AzureRmVMExtension -VMName $VMName -ResourceGroupName $rg -Location $Location -Name "ESET" -ExtensionType "FileSecurity" -Publisher "ESET" -typeHandlerVersion "6.0" -InformationAction SilentlyContinue -Verbose | Out-Null
				Get-AzureRmVMExtension -ResourceGroupName $rg -VMName $VMName -Name "ESET"
				 $LogOut = "Added ESET Extension"
				Log-Command -Description $LogOut -LogFile $LogOutFile
				Write-Results
}
		"PushDSC" {
				Verify-StorageExists
				Configure-DSC
				Write-Host "Pushing DSC to $VMName in the $rg Resource Group"
				$LogOut = "Added DSC Configuration"
				Log-Command -Description $LogOut -LogFile $LogOutFile
				Write-Results
}
		"RegisterAzDSC" {
				Write-Host "Registering with Azure Automation DSC"
				$ActionAfterReboot = 'ContinueConfiguration'
				$configmode = 'ApplyAndAutocorrect'
				$AutoAcctName = $Azautoacct
				$NodeName = -join $VMNAME+".node"
				$ConfigurationName = -join $VMNAME+".node"
				Register-AzureRmAutomationDscNode -AutomationAccountName $AutoAcctName -AzureVMName $VMName -ActionAfterReboot $ActionAfterReboot -ConfigurationMode $configmode -RebootNodeIfNeeded $True -ResourceGroupName $rg -NodeConfigurationName $ConfigurationName -AzureVMLocation $Location -AzureVMResourceGroup $rg -Verbose | Out-Null
				 $LogOut = "Registered with Azure Automation DSC"
				Log-Command -Description $LogOut -LogFile $LogOutFile
				Write-Results
}
		"WinPuppet" {
				Verify-ExtWin
				Write-Host "Deploying Puppet Extension"
				Set-AzureRmVMExtension -VMName $VMName -ResourceGroupName $rg -Location $Location -Name "PuppetEnterpriseAgent" -ExtensionType "PuppetEnterpriseAgent" -Publisher "PuppetLabs" -typeHandlerVersion "3.2" -InformationAction SilentlyContinue -Verbose | Out-Null
				Get-AzureRmVMExtension -ResourceGroupName $rg -VMName $VMName -Name "PuppetEnterpriseAgent"
				 $LogOut = "Added Puppet Agent Extension"
				Log-Command -Description $LogOut -LogFile $LogOutFile
				Write-Results
}
		default{"An unsupported Extension command was used"}
	}
	exit
} # Deploys Azure Extensions
#endregion

#region Remove Orphans
Function Remove-Orphans {
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
 Start-sleep 2
Exit }
else {if($nic1)
{
		Write-Host "Removing orphan $InterfaceName1" -ForegroundColor White
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
{
		Write-Host "Removing orphan $InterfaceName2" -ForegroundColor White
		Remove-AzureRmNetworkInterface -Name $InterfaceName2 -ResourceGroupName $rg -Force -Confirm:$False
		$LogOut = "Removed $InterfaceName2 - Private Adapter"
		Log-Command -Description $LogOut -LogFile $LogOutFile
 }
 else {Write-Host "No orphans found." -ForegroundColor Green}
 exit
 }
}
#endregion

#region Precheck Orphans
Function Check-Orphans {
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
{
	Write-Host "Host VM Found, please use a different VMName for Provisioning or manually delete the existing VM" -ForegroundColor Cyan
	Start-sleep 10
	Exit
}
else {if($nic1)
{
	Write-Host "Removing orphan $InterfaceName1" -ForegroundColor White
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
{
	Write-Host "Removing orphan $InterfaceName2" -ForegroundColor White
	Remove-AzureRmNetworkInterface -Name $InterfaceName2 -ResourceGroupName $rg -Force -Confirm:$False
	$LogOut = "Removed $InterfaceName2 - Private Adapter"
	Log-Command -Description $LogOut -LogFile $LogOutFile
 }
 else {Write-Host "No orphans found." -ForegroundColor Green}
 }
} #
#endregion

#region Remove DSC
Function Remove-DscExt
{
Param(
		[Parameter(Mandatory=$False,ValueFromPipelinebyPropertyName=$true,Position=0)]
		[string]
		$rg = $rg,
		[Parameter(Mandatory=$False,ValueFromPipelinebyPropertyName=$true,Position=0)]
		[string]
		$VMName = $VMName
)
Write-Host "Removing DSC Extension"
Remove-AzureRmVMDscExtension -ResourceGroupName $rg -VMName $VMName -Confirm:$False
}

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
#endregion

#region RemoveVM
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
#endregion

#region Remove NSG
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
#endregion

#region Remove VNET
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
#endregion

#region Remove Storage
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
#endregion

#region Create Availability Set
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
#endregion

Function Create-ResourceGroup {
				$resourcegroups = @($rg,$vnetrg);
				if($resourcegroups.length) {
					foreach($resourcegroup in $resourcegroups) {
						Provision-RG($resourcegroup);
					}
				}
}
#region Remove Component
Function Remove-Component {
	param(
		[string]$RemoveObject = $RemoveObject
	)

switch ($RemoveObject)
	{
		"rg" {
		Remove-azRg
		exit
}
		"vm" {
		Remove-azVM
		Remove-Orphans
}
		"nsg" {
		Remove-azNSG
		exit
}
		"vnet" {
		Remove-azVNET
		exit
}
		"storage" {
		Remove-AzStorage
		exit
}
		"availabilityset" {
		Remove-AzAvailabilitySet
		exit
}
		"dsc" {
		Remove-Dsc
		exit
}
		default{"An unsupported uninstall Extension command was used"}
	}
	exit
}
#endregion

Function Action-Type {
	param(
		$ActionType = $ActionType
	)

	Try
	{
	switch ($ActionType)
		{
			"create" {
					Check-NSGName # Verifies required fields have data
					Check-AvailabilitySet # Verifies required fields have data
					Check-FQDN # Verifies required fields have data
					Check-NullValues # Verifies required fields have data
					Check-Orphans # Verifies no left overs
					Verify-NIC # Verifies required fields have data
					Check-StorageName # Verifies Storage Account Name does not exist

					Write-Output "Steps will be tracked in the log file : [ $LogOutFile ]"
					Create-ResourceGroup
					if($AddVnet -or $BatchAddVnet -eq 'True')
					{
						Create-Vnet
					} # Creates VNET

					if($CreateNSG -or $BatchAddNSG -eq 'True')
					{
						Create-NSG
					} # Creates NSG and Security Groups
					Check-Vnet
					Create-VM # Configure Image
					if($AddNSG -or $BatchUpdateNSG -eq 'True')
					{
						Configure-CreateNSG
					} #Adds NSG to NIC

					if($AddExtension -or $BatchAddExtension -eq 'True')
					{ Install-Ext }
					else
					{ Write-Results }

					if($AddVPN -eq 'True'){
					Create-VPN
					Connect-VPN
					} #Creates VPN
	}
			"update" {
				if($UpdateExtension -or $BatchAddExtension -eq 'True')
	{
					Verify-StorageExists
					Install-Ext
					exit
	}
				if($AddNSG -or $BatchUpdateNSG -eq 'True')
					{
					Check-NSGName
					Configure-CreateNSG
					}
	}
			"remove" {
					if($RemoveObject)
					{
						Remove-Component
					}

					if($RemoveExtension)
					 {
						 Check-ExtensionUnInstall
						 UnInstall-Ext
					 }
	}
			default{"An unsupported uninstall Extension command was used"}
		}
	}
	Catch
	{
	Write-Host -foregroundcolor Yellow `
	"Exception Encountered"; `
	$ErrorMessage = $_.Exception.Message
	$LogOut  = 'Error '+$ErrorMessage
	Log-Command -Description $LogOut -LogFile $LogOutFile
	break
	}

	exit
}

#region Azure Version
Function Verify-AzureVersion {
$name='Azure'
if(Get-Module -ListAvailable |
	Where-Object { $_.name -eq $name })
{
	$ver = (Get-Module -ListAvailable | Where-Object{ $_.Name -eq $name }) |
		select version -ExpandProperty version
		Write-Host "current Azure PowerShell Version:" $ver
	$currentver = $ver
		if($currentver-le '2.0.0'){
		Write-Host "expected version 3.0.0 found $ver" -ForegroundColor DarkRed
		exit
			}
}
		else
{
	Write-Host “The Azure PowerShell module is not installed.”
	exit
}
}
#endregion

#region Create Log Directory
Function Create-Dir {
$logdirexists = Test-Path -Path $logdir
	$direxists = Test-Path -Path $customscriptsdir
		$dscdirexists = Test-Path -Path $dscdir
if(!$logdirexists)
	{
	New-Item -Path $logdir -ItemType Directory -Force | Out-Null
		Write-Host "Created directory" $logdir
	}
	elseif(!$direxists)
	{
	New-Item -Path $customscriptsdir -ItemType Directory -Force | Out-Null
	Write-Host "Created directory" $logdir
}
		elseif(!$dscdirexists)
{
		New-Item -Path $dscdir -ItemType Directory -Force | Out-Null
		Write-Host "Created directory" $logdir
}
}
#endregion

Function Register-ResourceProviders {
	 $resourceProviders = @("microsoft.compute","microsoft.network","microsoft.storage");
 if($resourceProviders.length) {
	Write-Host "Registering resource providers"
	foreach($resourceProvider in $resourceProviders) {
		Register-RP($resourceProvider);
	}
 }
	}

##--------------------------- Begin Script Execution -------------------------------------------------------##
# Global
$date = Get-Date -UFormat "%Y-%m-%d-%H-%M"
$workfolder = Split-Path $script:MyInvocation.MyCommand.Path
$logdir = $workfolder+'\'+'log'+'\'
$customscriptsdir = $workfolder+'\'+'customscripts'+'\'
$dscdir = $workfolder+'\'+'dsc'+'\'
$LogOutFile = $logdir+$vmname+'-'+$date+'.log'
$ProfileFile = $workfolder+'\'+$profile+'.json'

Verify-AzureVersion # Verifies Azure client Powershell Version

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

Register-ResourceProviders

Create-Dir

if($csvimport) { csv-run }

Action-Type