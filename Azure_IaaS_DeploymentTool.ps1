<#
  .SYNOPSIS
This script provides the following functionality for deploying IaaS environments in Azure. The script will deploy VNET in addition to numerour Market Place VMs or make use of an existing VNETs.
The script supports dual homed servers (PFSense/Checkpoint/FreeBSD)
The script allows select of subnet prior to VM Deployment
The script supports deploying Availability Sets as well as adding new servers to existing Availability Sets through the -AvailabilitySet "True" and -AvailSetName switches.
The script will generate a name for azure storage endpoint unless the -StorageName variable is updated or referenced at runtime.
The script will log all processes to the log file location $logFile = $workfolder+'\'+$vmname+'-'+$date+'.log'

 .DESCRIPTION
	Deploys 12 Market Images on a new or existing VNET.
	Market Images supported: Redhat 6.7 and 7.2, PFSense 2.5, Windows 2008 R2, Windows 2012 R2, Ubuntu 14.04, CentOs 7.2, SUSE, SQL 2016 (on W2K12R2), R Server on Windows, Windows 2016 (Preview), Checkpoint Firewall, FreeBsd
  .PARAMETERS

  .PARAMETER VMName
	Defines VMName for new VM
  .PARAMETER ResourceGroupName
	Specifies Resource Group to use for deployment
  .PARAMETER NewVnet
	Determines whether to create a new VNET
  .PARAMETER VNetName
	Name of new or existing VNET to use for the deployment
  .PARAMETER vNetResourceGroupName
	Name of Resource Group the VNET should be deployed in.
  .PARAMETER NSGEnabled
	Determmines whether a new NSG is deployed.
  .PARAMETER AvailabilitySet
	Specifies whether an Availability Set should be used for the deployment.
  .PARAMETER AvailabilitySetName
	Availability set name.
  .PARAMETER depsub1
   Deployment Subnet for all Nic1 instances. 0-7 Are the acceptable values.
  .PARAMETER depsub2
	Deployment Subnet for all Nic2 instances. 0-7 Are the acceptable values.
  .PARAMETER ConfigIps
	Determines Network Interface configuration settings for VM
  .PARAMETER VMMarketImage
	Determines Market Image to use for the deployment
  .PARAMETER AzExtConfig
	Determines Post Deployment Extensions
.NOTES

	-ConfigIps  <Configuration>
	UsePublicPvtIP – Deploys the server with a Public IP and the private IP specified by the user.
	DynPvtNoPublic - Deploys the server without Public IP using automatically generated private IP.
	Managed – Deploys the default configuration of a Public IP and automatically generated private IP.
	NoPublicStatPvtIP – Deploys the server without a Public IP using the private IP specified by the user.

	To specify Store Image
	-VMMarketImage <Image ShortName>
	Redhat 6.7 – Red67
	Redhat7.2 – Red72
	Windows 2012 R2 – w2k12
	PFSense 2.5 – pfsense
	Free BSD – free
	Suse – suse
	CentOs 7.2 – cent
	Ubuntu 14.04 – ubun
	SQL Server 2016 (on Windows 2012 host) – sql
	MySql – mysql
	CheckPoint – check
	Windows 2008 R2 – w2k8
	Windows 2016 – w2k16
	Chef v12 - chef

	-AzExtConfig <Extension Type>
	ExtVMAccess – Adds Azure Access Extension – Added by default during VM creation
	ExtMSAV – Adds Azure Antivirus Extension
	ExtCustScript – Adds Custom Script for Execution (Requires Table Storage Configuration first)
	ExtAzureDiag – Adds Azure Diagnostics Extension
	ExtAzureAddDom – Adds Azure Domain Join Extension
	ExtAzureChef – Adds Azure Chef Extension (Requires Chef Certificate and Settings info first)
	WinChef – Calls Knife command to install Chef Agent on Server
	LinChef – Calls Knife command to install Chef Agent on Server

.EXAMPLE
\.azdeploy.ps1 -VMName pfb1234 -VMMarketImage pfsense -ResourceGroupName AIPRES -vNetResourceGroupName AIPRES -VNetName VNET -NewVnet True -NSGEnabled True -ConfigIPs UsePublicPvtIP -PvtIPNic1 10.120.0.6 -PvtIPNic2 10.120.1.6
\.azdeploy.ps1 -VMName winiis6 -VMMarketImage w2k16 -ResourceGroupName AIPRES -vNetResourceGroupName AIPRES -VNetName VNET -depsub1 6 -ConfigIPs Managed
\.azdeploy.ps1 -VMName open002 -VMMarketImage freebsd -ResourceGroupName AIPRES -vNetResourceGroupName AIPRES -VNetName VNET -depsub1 4 -ConfigIPs Managed -AvailabilitySet "True" -AvailSetName "AIP1"
\.azdeploy.ps1 -VMName su0001 -VMMarketImage suse -ResourceGroupName AIPRES -vNetResourceGroupName AIPRES -VNetName VNET -depsub1 5 -ConfigIPs UsePublicPvtIP -PvtIPNic1 10.120.5.130
#>
##Setting Global Paramaters##
[CmdletBinding()]
Param(
 [Parameter(Mandatory=$False,ValueFromPipelinebyPropertyName=$true)]
 [string]
 $vmMarketImage = "PfSense",

 [Parameter(Mandatory=$False,ValueFromPipelinebyPropertyName=$true)]
 [string]
 $NewVnet = "True",

 [Parameter(Mandatory=$False,ValueFromPipelinebyPropertyName=$true)]
 [string]
 $VMName = "Pfs001",

 [Parameter(Mandatory=$False,ValueFromPipelinebyPropertyName=$true)]
 [string]
 $ResourceGroupName = "RSG",

 [Parameter(Mandatory=$False,ValueFromPipelinebyPropertyName=$true)]
 [string]
 $vNetResourceGroupName = $ResourceGroupName,

 [Parameter(Mandatory=$False,ValueFromPipelinebyPropertyName=$true)]
 [string]
 $VNetName = "vnet",

 [Parameter(Mandatory=$False,ValueFromPipelinebyPropertyName=$true)]
 [string]
 $VMSize = "Standard_A3",

 [Parameter(Mandatory=$False,ValueFromPipelinebyPropertyName=$true)]
 [string]
 $locadmin = 'localadmin',

  [Parameter(Mandatory=$False)]
 [string]
 $locpassword = 'P@55W0rd',

 [Parameter(Mandatory=$False,ValueFromPipelinebyPropertyName=$true)]
 [string]
 $NSGEnabled = "False",

 [Parameter(Mandatory=$False,ValueFromPipelinebyPropertyName=$true)]
 [string]
 $Location = "WestUs",

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
 $StorageName = $GenerateName + "str",

 [Parameter(Mandatory=$False,ValueFromPipelinebyPropertyName=$true)]
 [string]
 $StorageType = "Standard_GRS",

 [Parameter(Mandatory=$False)]
 [string]
 $InterfaceName1 = $VMName + "_nic1",
 [Parameter(Mandatory=$False)]
 [string]
 $InterfaceName2 = $VMName + "_nic2",
 [Parameter(Mandatory=$False,ValueFromPipelinebyPropertyName=$true)]
 [string]
 $NSGName = "NSG",
 [Parameter(Mandatory=$False,ValueFromPipelinebyPropertyName=$true)]
 [Int]
 $DepSub1 = 0,
 [Parameter(Mandatory=$False,ValueFromPipelinebyPropertyName=$true)]
 [Int]
 $DepSub2 = 1,
 [Parameter(Mandatory=$False,ValueFromPipelinebyPropertyName=$true)]
 [string]
 $NoPublicIP = "False",
 [Parameter(Mandatory=$False,ValueFromPipelinebyPropertyName=$true)]
 [string]
 $AvailabilitySet = "False",
 [Parameter(Mandatory=$False,ValueFromPipelinebyPropertyName=$true)]
 [string]
 $AvailSetName = "AVSET",
 [Parameter(Mandatory=$False,ValueFromPipelinebyPropertyName=$true)]
 [string]
 $KnifeClient = "Windows",
 [Parameter(Mandatory=$False,ValueFromPipelinebyPropertyName=$true)]
 [string]
 $ChefClient = "False",
 [Parameter(Mandatory = $false)]
 [PSObject]
 $provisionvm,
 [Parameter(Mandatory = $false)]
 [PSObject[]]
 $ProvisionVMs,
 [Parameter(Mandatory=$False,ValueFromPipelinebyPropertyName=$true)]

 $PvtIPNic1 = '',
 [Parameter(Mandatory=$False,ValueFromPipelinebyPropertyName=$true)]

 $PvtIPNic2 = '',
 [Parameter(Mandatory=$False,ValueFromPipelinebyPropertyName=$true)]
 [string]
 $ConfigIPs = "Managed",
  [Parameter(Mandatory=$False,ValueFromPipelinebyPropertyName=$true)]
 [string]
 $DNSLabel = "dnslabel",

 [Parameter(Mandatory=$False,ValueFromPipelinebyPropertyName=$true)]
 [string]
 $AzExtConfig = '',

 [Parameter(Mandatory=$False,ValueFromPipelinebyPropertyName=$true)]
 [string]
 $DomName = 'aipdom.local'
)
# Global
$ErrorActionPreference = "SilentlyContinue"
$WarningActionPreference = "SilentlyContinue"
$date = Get-Date -UFormat "%Y-%m-%d-%H-%M"
$workfolder = Split-Path $script:MyInvocation.MyCommand.Path
$logFile = $workfolder+'\'+$vmname+'-'+$date+'.log'
$OutputFile = $workfolder+'\'+$vmname+'-'+$date+'.txt'
$SecureLocPassword=Convertto-SecureString $locpassword –asplaintext -Force
$Credential1 = New-Object System.Management.Automation.PSCredential ($locadmin,$SecureLocPassword)
Write-Output "Steps will be tracked on the log file : [ $logFile ]"
## To use a Profile Json file for auth
# Login-AzureRmAccount -TenantId $TenantId

# Fuctions

Function CheckOrphns {
$extvm = Get-AzureRmVm -Name $VMName -ResourceGroupName $ResourceGroupName -ErrorAction SilentlyContinue
$nic1 = Get-AzureRmNetworkInterface -Name $InterfaceName1 -ResourceGroupName $ResourceGroupName -ErrorAction SilentlyContinue
$nic2 = Get-AzureRmNetworkInterface -Name $InterfaceName2 -ResourceGroupName $ResourceGroupName -ErrorAction SilentlyContinue
$pubip =  Get-AzureRmPublicIpAddress -Name $InterfaceName1 -ResourceGroupName $ResourceGroupName -ErrorAction SilentlyContinue

if($extvm)
{ Write-Host "Host VM Found, please use a different VMName for Provisioning or manually delete the existing VM" -ForegroundColor DarkRed
 Start-sleep 10
 exit   }
else {if($nic1)
{ Write-Host "Nic1 already Exists, removing orphan" -ForegroundColor DarkYellow
Remove-AzureRmNetworkInterface -Name $InterfaceName1 -ResourceGroupName $ResourceGroupName -Force  –Confirm:$false -Force -WarningAction SilentlyContinue
 }
	 if($pubip)
{ Write-Host "PublicIp already Exists, removing orphan" -ForegroundColor Yellow
				  Remove-AzureRmPublicIpAddress -Name $InterfaceName1 -ResourceGroupName $ResourceGroupName –Confirm:$false -Force -WarningAction SilentlyContinue
}
	 if($nic2)
{ Write-Host "Nic2 already Exists, removing orphan" -ForegroundColor Yellow
				  Remove-AzureRmNetworkInterface -Name $InterfaceName2 -ResourceGroupName $ResourceGroupName –Confirm:$false -Force -WarningAction SilentlyContinue
 }
 }
Write-Host "No orphan objects found, proceeding with deployment" -ForegroundColor Green
}

Function AzureVersion{
$name='Azure'
if(Get-Module -ListAvailable |
	Where-Object { $_.name -eq $name })
{
	(Get-Module -ListAvailable | Where-Object{ $_.Name -eq $name }) |
	Select Version, Name, PowerShellVersion  | Format-List;
	Start-sleep 5
}
else
{
	“The Azure PowerShell module is not installed.”
}
}

Function WriteLog-Command([string]$Description, [ScriptBlock]$Command, [string]$LogFile, [string]$VMName ){
Try{
$Output = $Description+'  ... '
Write-Host $Output -ForegroundColor Blue
((Get-Date -UFormat "[%d-%m-%Y %H:%M:%S] ") + $Output) | Out-File -FilePath $LogFile -Append –Confirm:$false -Force -WarningAction SilentlyContinue
$Result = Invoke-Command -ScriptBlock $Command
}
Catch {
$ErrorMessage = $_.Exception.Message
$Output = 'Error '+$ErrorMessage
((Get-Date -UFormat "[%d-%m-%Y %H:%M:%S] ") + $Output) | Out-File -FilePath $LogFile -Append –Confirm:$false -Force -WarningAction SilentlyContinue
$Result = ""
}
Finally
{
if ($ErrorMessage -eq $null) {$Output = "[Completed]  $Description  ... "} else {$Output = "[Failed]  $Description  ... "}
((Get-Date -UFormat "[%d-%m-%Y %H:%M:%S] ") + $Output) | Out-File -FilePath $LogFile -Append –Confirm:$false -Force -WarningAction SilentlyContinue
}
Return $Result
}
# End of Log Wrapping Function
Function Output-Command ([string]$Desc, [string]$OutputFile, [string]$VMName){
$Output = $Desc+'  ... '
Write-Host $Output -ForegroundColor White
$OutResult = ((Get-Date -UFormat "[%d-%m-%Y %H:%M:%S] ") + $Output) | Out-File -FilePath $OutputFile -Append –Confirm:$false -Force -WarningAction SilentlyContinue
Return $OutResult
}
# End of Data Wrapping Function
Function RegisterRP {
	Param(
		[string]$ResourceProviderNamespace
	)

	Write-Host "Registering resource provider '$ResourceProviderNamespace'";
	Register-AzureRmResourceProvider -ProviderNamespace $ResourceProviderNamespace –Confirm:$false -Force -WarningAction SilentlyContinue| Out-Null ;
}
# End of Resgister Resource Providers Function
Function ProvisionRGs {
	Param(
		[string]$ResourceGroupName
	)
	$resourceGroup = Get-AzureRmResourceGroup -Name $ResourceGroupName -ErrorAction SilentlyContinue -WarningAction SilentlyContinue | Out-Null
if(!$resourceGroup)
{
	Write-Host "Resource group '$ResourceGroupName' does not exist. Creating...";
	if(!$Location) {
		$Location = Read-Host "resourceGroupLocation";
	}
	$Description = "Creating resource group $resourceGroupName in location $Location";
	$Command = { New-AzureRmResourceGroup -Name $resourceGroupName -Location $Location –Confirm:$false -Force -WarningAction SilentlyContinue | Out-Null }
	WriteLog-Command -Description $Description -Command $Command -LogFile $LogFile
}
else{
	$Description = "Using existing resource group $ResourceGroupName";
	$Command = { Get-AzureRmResourceGroup -Name $ResourceGroupName -ErrorAction SilentlyContinue -WarningAction SilentlyContinue | Out-Null }
	WriteLog-Command -Description $Description -Command $Command -LogFile $LogFile
}
}
# End of Provision Resource Groups Function
Function ProvisionNet {
## Create Virtual Network
$Description = {"Network Preparation in Process"}
$subnet1 = New-AzureRmVirtualNetworkSubnetConfig -AddressPrefix 10.120.0.0/24 -Name perimeter
$subnet2 = New-AzureRmVirtualNetworkSubnetConfig -AddressPrefix 10.120.1.0/24 -Name web
$subnet3 = New-AzureRmVirtualNetworkSubnetConfig -AddressPrefix 10.120.2.0/24 -Name intake
$subnet4 = New-AzureRmVirtualNetworkSubnetConfig -AddressPrefix 10.120.3.0/24 -Name data
$subnet5 = New-AzureRmVirtualNetworkSubnetConfig -AddressPrefix 10.120.4.0/24 -Name monitoring
$subnet6 = New-AzureRmVirtualNetworkSubnetConfig -AddressPrefix 10.120.5.0/24 -Name analytics
$subnet7 = New-AzureRmVirtualNetworkSubnetConfig -AddressPrefix 10.120.6.0/24 -Name backup
$subnet8 = New-AzureRmVirtualNetworkSubnetConfig -AddressPrefix 10.120.7.0/24 -Name management
New-AzureRmVirtualNetwork -Location $Location -Name $VNetName -ResourceGroupName $vNetResourceGroupName -AddressPrefix '10.120.0.0/21' -Subnet $subnet1,$subnet2,$subnet3,$subnet4,$subnet5,$subnet6,$subnet7,$subnet8 –Confirm:$false -Force -WarningAction SilentlyContinue  | Out-Null
$Command = { Get-AzureRmVirtualNetwork -Name $VNetName -ResourceGroupName $vNetResourceGroupName | Get-AzureRmVirtualNetworkSubnetConfig -WarningAction SilentlyContinue | Out-Null }
$Description = "Completed deployment of new VNET $VNetName"
WriteLog-Command -Description $Description -Command $Command -LogFile $LogFile
}
# End of Provision VNET Function
Function CreateNSG {
$httprule = New-AzureRmNetworkSecurityRuleConfig -Name "FrontEnd_HTTP" -Description "HTTP Exception for Web frontends" -Protocol Tcp -SourcePortRange "80" -DestinationPortRange "80" -SourceAddressPrefix "*" -DestinationAddressPrefix "10.120.0.0/21" -Access Allow -Direction Inbound -Priority 200
$httpsrule = New-AzureRmNetworkSecurityRuleConfig -Name "FrontEnd_HTTPS" -Description "HTTPS Exception for Web frontends" -Protocol Tcp -SourcePortRange "443" -DestinationPortRange "443" -SourceAddressPrefix "*" -DestinationAddressPrefix "10.120.0.0/21" -Access Allow -Direction Inbound -Priority 201
$sshrule = New-AzureRmNetworkSecurityRuleConfig -Name "FrontEnd_SSH" -Description "SSH Exception for Web frontends" -Protocol Tcp -SourcePortRange "22" -DestinationPortRange "22" -SourceAddressPrefix "*" -DestinationAddressPrefix "10.120.0.0/21" -Access Allow -Direction Inbound ` -Priority 203
$nsg = New-AzureRmNetworkSecurityGroup -ResourceGroupName $vNetResourceGroupName -Location $Location -Name $NSGName -SecurityRules $httprule,$httpsrule, $sshrule –Confirm:$false -Force -WarningAction SilentlyContinue  | Out-Null
$Description = "Completed deployment of NSG Configuration $NSGName"
$Command = { Get-AzureRmNetworkSecurityGroup -Name $NSGName -ResourceGroupName $vNetResourceGroupName -WarningAction SilentlyContinue | Out-Null }
WriteLog-Command -Description $Description -Command $Command -LogFile $LogFile
}
# End of Provision Network Security Groups Function
Function SubnetMatch {
	Param(
		[INT]$Subnet
	)
switch ($Subnet)
{
0 {Write-Host "         Deploying to Subnet 10.120.0.0/24"}
1 {Write-Host "         Deploying to Subnet 10.120.1.0/24"}
2 {Write-Host "         Deploying to Subnet 10.120.2.0/24"}
3 {Write-Host "         Deploying to Subnet 10.120.3.0/24"}
4 {Write-Host "         Deploying to Subnet 10.120.4.0/24"}
5 {Write-Host "         Deploying to Subnet 10.120.5.0/24"}
6 {Write-Host "         Deploying to Subnet 10.120.6.0/24"}
7 {Write-Host "         Deploying to Subnet 10.120.7.0/24"}
default {No Subnet Found}
}
}
# End of SubnetMatch Function
Function SignInProfile {
try {
$GetPath = test-path -Path $ProfPath
Write-Host $GetPath
if($GetPath -eq "False")
{ Add-AzureRmAccount -TenantId $TenantID }
}
catch {
	Write-Host -foregroundcolor Yellow `
	"$($_.Exception.Message)"; `
	continue
}
	finally {
	Select-AzureRmProfile -Path $ProfPath
	}
}

Function WriteConfig
{
Write-Host "Using configuration:"
Write-Host "         VM Name: '$VMName' "
Write-Host "         Resource Group: '$ResourceGroupName'"
Write-Host "         Server Type: '$vmMarketImage'"
Write-Host "         VNET Name: '$VNetName'"
Write-Host "         VNET Resource Group Name: '$vNetResourceGroupName'"

if($PvtIPNic1) {
Write-Host "         Nic1 Name: '$InterfaceName1'"
Write-Host "         Nic1 Private IP: '$PvtIPNic1'"
}
Write-Host "         Nic1 Name: '$InterfaceName1'"
SubnetMatch $DepSub1
if($PvtIPNic2) {
Write-Host "         Nic2 Name: '$InterfaceName2'"
Write-Host "         Nic2 Private IP: '$PvtIPNic2'"
SubnetMatch $DepSub2
}

If ($ConfigIPs -eq "NoPublicStatPvtIP" -OR $ConfigIPs -eq "DynPvtNoPublic")
{ Write-Host "         Public Ip Will not be created"}

if($AvailabilitySet -eq "True") {
Write-Host "         Availability Set to 'True'"
Write-Host "         Availability Set Name:  '$AvailSetName'"
}
else
{
Write-Host "         Availability Set to 'False'"
}
}

## To use a Profile Json file for auth

Add-AzureRmAccount -TenantId $TenantID

# GetAzureVersion
AzureVersion

try {
Get-AzureRmResourceGroup -Location $Location -ErrorAction Stop -WarningAction SilentlyContinue | Out-Null
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
 }

CheckOrphns
# Create Resource Groups
$resourcegroups = @($ResourceGroupName,$vNetResourceGroupName);
# $resourcegroups = @($ResourceGroupName);
if($resourcegroups.length) {
	foreach($resourcegroup in $resourcegroups) {
		ProvisionRGs($resourcegroup);
	}
	}

WriteConfig

# Create Network
If($NewVnet -eq "True")
{
ProvisionNet
}
else
 {$Description = "Create new VNET not selected...Using Existing $VNetName"
 $Command = {Get-AzureRmVirtualNetwork -Name $VNetName -ResourceGroupName $vNetResourceGroupName | Get-AzureRmVirtualNetworkSubnetConfig -WarningAction SilentlyContinue
 Get-AzureRmVirtualNetwork -Name $VNetName -ResourceGroupName $vNetResourceGroupName | Select Name, ResourceGroupName, Subnets -WarningAction SilentlyContinue
 }
 WriteLog-Command -Description $Description -Command $Command -LogFile $LogFile
 }

 Start-sleep 5

 # Create NSG
If($NSGEnabled -eq "True")
{
CreateNSG}
 else
{$Description = "Create new NSG not selected...Using existing $NSGName"
$Command = { Get-AzureRmNetworkSecurityGroup -Name $NSGName -ResourceGroupName $vNetResourceGroupName -WarningAction SilentlyContinue | Out-Null }
WriteLog-Command -Description $Description -Command $Command -LogFile $LogFile
}

#CreateStorage
try {
Write-Host "Starting Storage Creation"
$StorageAccount = New-AzureRmStorageAccount -ResourceGroupName $ResourceGroupName -Name $StorageName.ToLower() -Type $StorageType -Location $Location -ErrorAction Stop -WarningAction SilentlyContinue
$strnew = Get-AzureRmStorageAccount -Name $StorageName.ToLower() -ResourceGroupName $ResourceGroupName -WarningAction SilentlyContinue | ft "StorageAccountName" -Wrap -HideTableHeaders
$Description = {'Storage Creation'}
}
catch {
	Write-Host -foregroundcolor Yellow `
	"$($_.Exception.Message)"; `
	WriteLog-Command $Command -Description $_ -LogFile $LogFile
	continue
Finally {
}
}

#Match and prepare image
switch -Wildcard ($vmMarketImage)
	{
		"*pf*" {
$Command = {"PfSense VM Image Preparation in Process"}
$Description = "Starting Azure VM Creation"
	WriteLog-Command -Description $Description -Command $Command  -LogFile $LogFile
switch -Wildcard ($ConfigIPs)
	{
		"*UsePublicPvtIP*" {
Write-Host "Public/Static Pvt IP"
$PIp = New-AzureRmPublicIpAddress -Name $InterfaceName1 -ResourceGroupName $ResourceGroupName -Location $Location -AllocationMethod "Dynamic" –Confirm:$false -Force -WarningAction SilentlyContinue
$VNet = Get-AzureRMVirtualNetwork -Name $VNetName -ResourceGroupName $vNetResourceGroupName | Set-AzureRmVirtualNetwork
$Interface1 = New-AzureRmNetworkInterface -Name $InterfaceName1 -ResourceGroupName $ResourceGroupName -Location $Location -SubnetId $VNet.Subnets[$DepSub1].Id -PublicIpAddressId $PIp.Id -PrivateIpAddress $PvtIPNic1 –Confirm:$false -Force -WarningAction SilentlyContinue
$Interface2 = New-AzureRmNetworkInterface -Name $InterfaceName2 -ResourceGroupName $ResourceGroupName -Location $Location -SubnetId $VNet.Subnets[$DepSub2].Id -PrivateIpAddress $PvtIPNic2 –Confirm:$false -Force -WarningAction SilentlyContinue
}
		"*NoPublicStatPvtIP*" {
Write-Host "No Public IP/Static Pvt Ip"
$VNet = Get-AzureRMVirtualNetwork -Name $VNetName -ResourceGroupName $vNetResourceGroupName | Set-AzureRmVirtualNetwork
SubnetMatch $DepSub1
$Interface1 = New-AzureRmNetworkInterface -Name $InterfaceName1 -ResourceGroupName $ResourceGroupName -Location $Location -SubnetId $VNet.Subnets[$DepSub1].Id -PrivateIpAddress $PvtIPNic1 –Confirm:$false -Force -WarningAction SilentlyContinue
SubnetMatch $DepSub2
$Interface2 = New-AzureRmNetworkInterface -Name $InterfaceName2 -ResourceGroupName $ResourceGroupName -Location $Location -SubnetId $VNet.Subnets[$DepSub2].Id -PrivateIpAddress $PvtIPNic2 –Confirm:$false -Force -WarningAction SilentlyContinue
}
		"*DynPvtNoPublic*" {
Write-Host "No Public IP/Dynamic PvtIp"
$VNet = Get-AzureRMVirtualNetwork -Name $VNetName -ResourceGroupName $vNetResourceGroupName | Set-AzureRmVirtualNetwork
$Interface1 = New-AzureRmNetworkInterface -Name $InterfaceName1 -ResourceGroupName $ResourceGroupName -Location $Location -SubnetId $VNet.Subnets[$DepSub1].Id –Confirm:$false -Force -WarningAction SilentlyContinue
$Interface2 = New-AzureRmNetworkInterface -Name $InterfaceName2 -ResourceGroupName $ResourceGroupName -Location $Location -SubnetId $VNet.Subnets[$DepSub2].Id –Confirm:$false -Force -WarningAction SilentlyContinue
}
		"*Managed*" {
Write-Host "Default IP Configuration"
$PIp = New-AzureRmPublicIpAddress -Name $InterfaceName1 -ResourceGroupName $ResourceGroupName -Location $Location -AllocationMethod "Dynamic" –Confirm:$false -Force -WarningAction SilentlyContinue
$VNet = Get-AzureRMVirtualNetwork -Name $VNetName -ResourceGroupName $vNetResourceGroupName | Set-AzureRmVirtualNetwork
$Interface1 = New-AzureRmNetworkInterface -Name $InterfaceName1 -ResourceGroupName $ResourceGroupName -Location $Location -SubnetId $VNet.Subnets[$DepSub1].Id -PublicIpAddressId $PIp.Id –Confirm:$false -Force -WarningAction SilentlyContinue
$Interface2 = New-AzureRmNetworkInterface -Name $InterfaceName2 -ResourceGroupName $ResourceGroupName -Location $Location -SubnetId $VNet.Subnets[$DepSub2].Id –Confirm:$false -Force -WarningAction SilentlyContinue
}
		default{"An unsupported network configuration was referenced"}
}
If ($AvailabilitySet -eq "True")
 {
New-AzureRmAvailabilitySet -ResourceGroupName $ResourceGroupName -Name $AvailSetName -Location $Location -WarningAction SilentlyContinue | Out-Null
Write-Host "Created Availability Set"
$AvailabilitySet =(Get-AzureRmAvailabilitySet -ResourceGroupName $ResourceGroupName -Name $AvailSetName).Id
$VirtualMachine = New-AzureRmVMConfig -VMName $VMName -VMSize $VMSize -AvailabilitySetID $AvailabilitySet -WarningAction SilentlyContinue
}
else
{
$VirtualMachine = New-AzureRmVMConfig -VMName $VMName -VMSize $VMSize -WarningAction SilentlyContinue
}
$VirtualMachine = Set-AzureRmVMPlan -VM $VirtualMachine -Name pfsense-router-fw-vpn-225 -Publisher netgate -Product netgate-pfsense-appliance
$VirtualMachine = Set-AzureRmVMOperatingSystem -VM $VirtualMachine -linux -ComputerName $VMName -Credential $Credential1 -WarningAction SilentlyContinue
$VirtualMachine = Set-AzureRmVMSourceImage -VM $VirtualMachine -PublisherName netgate -Offer netgate-pfsense-appliance -Skus pfsense-router-fw-vpn-225 -Version "latest"
$VirtualMachine = Add-AzureRmVMNetworkInterface -VM $VirtualMachine -Id $Interface1.Id -Primary -WarningAction SilentlyContinue
$VirtualMachine = Add-AzureRmVMNetworkInterface -VM $VirtualMachine -Id $Interface2.Id -WarningAction SilentlyContinue
$osDiskCaching = "ReadWrite"
$OSDiskName = $VMName + "OSDisk"
$OSDiskUri = $StorageAccount.PrimaryEndpoints.Blob.ToString() + "vhds/" + $OSDiskName + ".vhd"
$VirtualMachine = Set-AzureRmVMOSDisk -VM $VirtualMachine -Name $OSDiskName -VhdUri $OSDiskUri -CreateOption "FromImage" -Caching $osDiskCaching
}
				"*free*" {
$Command = {"OpenBSD VM Image Preparation in Process"}
$Description = "Starting Azure VM Creation"
	WriteLog-Command -Description $Description -Command $Command  -LogFile $LogFile
switch -Wildcard ($ConfigIPs)
	{
		"*UsePublicPvtIP*" {
Write-Host "Public/Static Pvt IP"
$PIp = New-AzureRmPublicIpAddress -Name $InterfaceName1 -ResourceGroupName $ResourceGroupName -Location $Location -AllocationMethod "Dynamic" –Confirm:$false -Force -WarningAction SilentlyContinue
$VNet = Get-AzureRMVirtualNetwork -Name $VNetName -ResourceGroupName $vNetResourceGroupName | Set-AzureRmVirtualNetwork
$Interface1 = New-AzureRmNetworkInterface -Name $InterfaceName1 -ResourceGroupName $ResourceGroupName -Location $Location -SubnetId $VNet.Subnets[$DepSub1].Id -PublicIpAddressId $PIp.Id -PrivateIpAddress $PvtIPNic1 –Confirm:$false -Force -WarningAction SilentlyContinue
$Interface2 = New-AzureRmNetworkInterface -Name $InterfaceName2 -ResourceGroupName $ResourceGroupName -Location $Location -SubnetId $VNet.Subnets[$DepSub2].Id -PrivateIpAddress $PvtIPNic2 –Confirm:$false -Force -WarningAction SilentlyContinue
}
		"*NoPublicStatPvtIP*" {
Write-Host "No Public IP/Static Pvt Ip"
$VNet = Get-AzureRMVirtualNetwork -Name $VNetName -ResourceGroupName $vNetResourceGroupName | Set-AzureRmVirtualNetwork
SubnetMatch $DepSub1
$Interface1 = New-AzureRmNetworkInterface -Name $InterfaceName1 -ResourceGroupName $ResourceGroupName -Location $Location -SubnetId $VNet.Subnets[$DepSub1].Id -PrivateIpAddress $PvtIPNic1 –Confirm:$false -Force -WarningAction SilentlyContinue
SubnetMatch $DepSub2
$Interface2 = New-AzureRmNetworkInterface -Name $InterfaceName2 -ResourceGroupName $ResourceGroupName -Location $Location -SubnetId $VNet.Subnets[$DepSub2].Id -PrivateIpAddress $PvtIPNic2 –Confirm:$false -Force -WarningAction SilentlyContinue
}
		"*DynPvtNoPublic*" {
Write-Host "No Public IP/Dynamic PvtIp"
$VNet = Get-AzureRMVirtualNetwork -Name $VNetName -ResourceGroupName $vNetResourceGroupName | Set-AzureRmVirtualNetwork
$Interface1 = New-AzureRmNetworkInterface -Name $InterfaceName1 -ResourceGroupName $ResourceGroupName -Location $Location -SubnetId $VNet.Subnets[$DepSub1].Id –Confirm:$false -Force -WarningAction SilentlyContinue
$Interface2 = New-AzureRmNetworkInterface -Name $InterfaceName2 -ResourceGroupName $ResourceGroupName -Location $Location -SubnetId $VNet.Subnets[$DepSub2].Id –Confirm:$false -Force -WarningAction SilentlyContinue
}
		"*Managed*" {
Write-Host "Default IP Configuration"
$PIp = New-AzureRmPublicIpAddress -Name $InterfaceName1 -ResourceGroupName $ResourceGroupName -Location $Location -AllocationMethod "Dynamic" –Confirm:$false -Force -WarningAction SilentlyContinue
$VNet = Get-AzureRMVirtualNetwork -Name $VNetName -ResourceGroupName $vNetResourceGroupName | Set-AzureRmVirtualNetwork
$Interface1 = New-AzureRmNetworkInterface -Name $InterfaceName1 -ResourceGroupName $ResourceGroupName -Location $Location -SubnetId $VNet.Subnets[$DepSub1].Id -PublicIpAddressId $PIp.Id –Confirm:$false -Force -WarningAction SilentlyContinue
$Interface2 = New-AzureRmNetworkInterface -Name $InterfaceName2 -ResourceGroupName $ResourceGroupName -Location $Location -SubnetId $VNet.Subnets[$DepSub2].Id –Confirm:$false -Force -WarningAction SilentlyContinue
}
		default{"An unsupported image was referenced"}
}
If ($AvailabilitySet -eq "True")
 {
New-AzureRmAvailabilitySet -ResourceGroupName $ResourceGroupName -Name $AvailSetName -Location $Location -WarningAction SilentlyContinue | Out-Null
Write-Host "Created Availability Set"
$AvailabilitySet =(Get-AzureRmAvailabilitySet -ResourceGroupName $ResourceGroupName -Name $AvailSetName).Id
$VirtualMachine = New-AzureRmVMConfig -VMName $VMName -VMSize $VMSize -AvailabilitySetID $AvailabilitySet -WarningAction SilentlyContinue
}
else
{
$VirtualMachine = New-AzureRmVMConfig -VMName $VMName -VMSize $VMSize -WarningAction SilentlyContinue
}
$VirtualMachine = Set-AzureRmVMOperatingSystem -VM $VirtualMachine -linux -ComputerName $VMName -Credential $Credential1 -WarningAction SilentlyContinue
$VirtualMachine = Set-AzureRmVMSourceImage -VM $VirtualMachine -PublisherName MicrosoftOSTC -Offer FreeBSD -Skus 10.3 -Version "latest"
$VirtualMachine = Add-AzureRmVMNetworkInterface -VM $VirtualMachine -Id $Interface1.Id -Primary -WarningAction SilentlyContinue
$VirtualMachine = Add-AzureRmVMNetworkInterface -VM $VirtualMachine -Id $Interface2.Id -WarningAction SilentlyContinue
$osDiskCaching = "ReadWrite"
$OSDiskName = $VMName + "OSDisk"
$OSDiskUri = $StorageAccount.PrimaryEndpoints.Blob.ToString() + "vhds/" + $OSDiskName + ".vhd"
$VirtualMachine = Set-AzureRmVMOSDisk -VM $VirtualMachine -Name $OSDiskName -VhdUri $OSDiskUri -CreateOption "FromImage" -Caching $osDiskCaching
}

		"*red72*" {
$Command = {"Redhat VM Image Preparation in Process"}
$Description = "Starting Azure VM Creation"
	WriteLog-Command -Description $Description -Command $Command  -LogFile $LogFile
switch -Wildcard ($ConfigIPs)
	{
		"*UsePublicPvtIP*" {
Write-Host "Public/Static Pvt IP"
$PIp = New-AzureRmPublicIpAddress -Name $InterfaceName1 -ResourceGroupName $ResourceGroupName -Location $Location -AllocationMethod "Dynamic" –Confirm:$false -Force -WarningAction SilentlyContinue
$VNet = Get-AzureRMVirtualNetwork -Name $VNetName -ResourceGroupName $vNetResourceGroupName | Set-AzureRmVirtualNetwork
$Interface1 = New-AzureRmNetworkInterface -Name $InterfaceName1 -ResourceGroupName $ResourceGroupName -Location $Location -SubnetId $VNet.Subnets[$DepSub1].Id -PublicIpAddressId $PIp.Id -PrivateIpAddress $PvtIPNic1 –Confirm:$false -Force -WarningAction SilentlyContinue
}
		"*NoPublicStatPvtIP*" {
Write-Host "No Public IP/Static Pvt Ip"
$VNet = Get-AzureRMVirtualNetwork -Name $VNetName -ResourceGroupName $vNetResourceGroupName | Set-AzureRmVirtualNetwork
$Interface1 = New-AzureRmNetworkInterface -Name $InterfaceName1 -ResourceGroupName $ResourceGroupName -Location $Location -SubnetId $VNet.Subnets[$DepSub1].Id -PrivateIpAddress $PvtIPNic1 –Confirm:$false -Force -WarningAction SilentlyContinue
}
		"*DynPvtNoPublic*" {
Write-Host "No Public IP/Dynamic PvtIp"
$VNet = Get-AzureRMVirtualNetwork -Name $VNetName -ResourceGroupName $vNetResourceGroupName | Set-AzureRmVirtualNetwork
$Interface1 = New-AzureRmNetworkInterface -Name $InterfaceName1 -ResourceGroupName $ResourceGroupName -Location $Location -SubnetId $VNet.Subnets[$DepSub1].Id –Confirm:$false -Force -WarningAction SilentlyContinue
}
		"*Managed*" {
Write-Host "Default IP Configuration"
$PIp = New-AzureRmPublicIpAddress -Name $InterfaceName1 -ResourceGroupName $ResourceGroupName -Location $Location -AllocationMethod "Dynamic" –Confirm:$false -Force -WarningAction SilentlyContinue
$VNet = Get-AzureRMVirtualNetwork -Name $VNetName -ResourceGroupName $vNetResourceGroupName | Set-AzureRmVirtualNetwork
$Interface1 = New-AzureRmNetworkInterface -Name $InterfaceName1 -ResourceGroupName $ResourceGroupName -Location $Location -SubnetId $VNet.Subnets[$DepSub1].Id -PublicIpAddressId $PIp.Id –Confirm:$false -Force -WarningAction SilentlyContinue
}
		default{"An unsupported image was referenced"}
}
If ($AvailabilitySet -eq "True")
 {
New-AzureRmAvailabilitySet -ResourceGroupName $ResourceGroupName -Name $AvailSetName -Location $Location -WarningAction SilentlyContinue | Out-Null
Write-Host "Created Availability Set"
$AvailabilitySet =(Get-AzureRmAvailabilitySet -ResourceGroupName $ResourceGroupName -Name $AvailSetName).Id
$VirtualMachine = New-AzureRmVMConfig -VMName $VMName -VMSize $VMSize -AvailabilitySetID $AvailabilitySet -WarningAction SilentlyContinue
}
else
{
$VirtualMachine = New-AzureRmVMConfig -VMName $VMName -VMSize $VMSize -WarningAction SilentlyContinue
}
$VirtualMachine = Set-AzureRmVMOperatingSystem -VM $VirtualMachine -linux -ComputerName $VMName -Credential $Credential1 -WarningAction SilentlyContinue
$VirtualMachine = Set-AzureRmVMSourceImage -VM $VirtualMachine -PublisherName "Redhat" -Offer "rhel" -Skus "7.2" -Version "latest"
$VirtualMachine = Add-AzureRmVMNetworkInterface -VM $VirtualMachine -Id $Interface1.Id -Primary -WarningAction SilentlyContinue
$osDiskCaching = "ReadWrite"
$OSDiskName = $VMName + "OSDisk"
$OSDiskUri = $StorageAccount.PrimaryEndpoints.Blob.ToString() + "vhds/" + $OSDiskName + ".vhd"
$VirtualMachine = Set-AzureRmVMOSDisk -VM $VirtualMachine -Name $OSDiskName -VhdUri $OSDiskUri -CreateOption "FromImage" -Caching $osDiskCaching
}
		"*red67*" {
$Command = {"Redhat VM Image Preparation in Process"}
$Description = "Starting Azure VM Creation"
	WriteLog-Command -Description $Description -Command $Command  -LogFile $LogFile
If ($NoPublicIP -eq "False")
{
Write-Host "Finishing Public IP creation..."
$PIp = New-AzureRmPublicIpAddress -Name $InterfaceName1 -ResourceGroupName $ResourceGroupName -Location $Location -AllocationMethod "Dynamic" –Confirm:$false -Force -WarningAction SilentlyContinue
$VNet = Get-AzureRMVirtualNetwork -Name $VNetName -ResourceGroupName $vNetResourceGroupName | Set-AzureRmVirtualNetwork
$Interface1 = New-AzureRmNetworkInterface -Name $InterfaceName1 -ResourceGroupName $ResourceGroupName -Location $Location -SubnetId $VNet.Subnets[$DepSub1].Id -PublicIpAddressId $PIp.Id  –Confirm:$false -Force -WarningAction SilentlyContinue
} else
{
Write-Host "Skipping Public IP creation..."
$VNet = Get-AzureRMVirtualNetwork -Name $VNetName -ResourceGroupName $vNetResourceGroupName | Set-AzureRmVirtualNetwork
$Interface1 = New-AzureRmNetworkInterface -Name $InterfaceName1 -ResourceGroupName $ResourceGroupName -Location $Location -SubnetId $VNet.Subnets[$DepSub1].Id –Confirm:$false -Force -WarningAction SilentlyContinue
}
If ($AvailabilitySet -eq "True")
 {
New-AzureRmAvailabilitySet -ResourceGroupName $ResourceGroupName -Name $AvailSetName -Location $Location -WarningAction SilentlyContinue | Out-Null
Write-Host
$AvailabilitySet =(Get-AzureRmAvailabilitySet -ResourceGroupName $ResourceGroupName -Name $AvailSetName).Id
$VirtualMachine = New-AzureRmVMConfig -VMName $VMName -VMSize $VMSize -AvailabilitySetID $AvailabilitySet -WarningAction SilentlyContinue
}
else
{
$VirtualMachine = New-AzureRmVMConfig -VMName $VMName -VMSize $VMSize -WarningAction SilentlyContinue
}
$VirtualMachine = Set-AzureRmVMOperatingSystem -VM $VirtualMachine -linux -ComputerName $VMName -Credential $Credential1 -WarningAction SilentlyContinue
$VirtualMachine = Set-AzureRmVMSourceImage -VM $VirtualMachine -PublisherName "Redhat" -Offer "rhel" -Skus "6.7" -Version "latest"
$VirtualMachine = Add-AzureRmVMNetworkInterface -VM $VirtualMachine -Id $Interface1.Id -Primary -WarningAction SilentlyContinue
$osDiskCaching = "ReadWrite"
$OSDiskName = $VMName + "OSDisk"
$OSDiskUri = $StorageAccount.PrimaryEndpoints.Blob.ToString() + "vhds/" + $OSDiskName + ".vhd"
$VirtualMachine = Set-AzureRmVMOSDisk -VM $VirtualMachine -Name $OSDiskName -VhdUri $OSDiskUri -CreateOption "FromImage" -Caching $osDiskCaching
}
		"*MySql*" {
$Command = {"MySql VM Image Preparation in Process"}
$Description = "Starting Azure VM Creation"
	WriteLog-Command -Description $Description -Command $Command  -LogFile $LogFile
switch -Wildcard ($ConfigIPs)
	{
		"*UsePublicPvtIP*" {
Write-Host "Public/Static Pvt IP"
$PIp = New-AzureRmPublicIpAddress -Name $InterfaceName1 -ResourceGroupName $ResourceGroupName -Location $Location -AllocationMethod "Dynamic" –Confirm:$false -Force -WarningAction SilentlyContinue
$VNet = Get-AzureRMVirtualNetwork -Name $VNetName -ResourceGroupName $vNetResourceGroupName | Set-AzureRmVirtualNetwork
$Interface1 = New-AzureRmNetworkInterface -Name $InterfaceName1 -ResourceGroupName $ResourceGroupName -Location $Location -SubnetId $VNet.Subnets[$DepSub1].Id -PublicIpAddressId $PIp.Id -PrivateIpAddress $PvtIPNic1 –Confirm:$false -Force -WarningAction SilentlyContinue
}
		"*NoPublicStatPvtIP*" {
Write-Host "No Public IP/Static Pvt Ip"
$VNet = Get-AzureRMVirtualNetwork -Name $VNetName -ResourceGroupName $vNetResourceGroupName | Set-AzureRmVirtualNetwork
$Interface1 = New-AzureRmNetworkInterface -Name $InterfaceName1 -ResourceGroupName $ResourceGroupName -Location $Location -SubnetId $VNet.Subnets[$DepSub1].Id -PrivateIpAddress $PvtIPNic1 –Confirm:$false -Force -WarningAction SilentlyContinue
}
		"*DynPvtNoPublic*" {
Write-Host "No Public IP/Dynamic PvtIp"
$VNet = Get-AzureRMVirtualNetwork -Name $VNetName -ResourceGroupName $vNetResourceGroupName | Set-AzureRmVirtualNetwork
$Interface1 = New-AzureRmNetworkInterface -Name $InterfaceName1 -ResourceGroupName $ResourceGroupName -Location $Location -SubnetId $VNet.Subnets[$DepSub1].Id –Confirm:$false -Force -WarningAction SilentlyContinue
}
		"*Managed*" {
Write-Host "Default IP Configuration"
$PIp = New-AzureRmPublicIpAddress -Name $InterfaceName1 -ResourceGroupName $ResourceGroupName -Location $Location -AllocationMethod "Dynamic" –Confirm:$false -Force -WarningAction SilentlyContinue
$VNet = Get-AzureRMVirtualNetwork -Name $VNetName -ResourceGroupName $vNetResourceGroupName | Set-AzureRmVirtualNetwork
$Interface1 = New-AzureRmNetworkInterface -Name $InterfaceName1 -ResourceGroupName $ResourceGroupName -Location $Location -SubnetId $VNet.Subnets[$DepSub1].Id  -PublicIpAddressId $PIp.Id –Confirm:$false -Force -WarningAction SilentlyContinue
}
		default{"An unsupported image was referenced"}
}
If ($AvailabilitySet -eq "True")
 {
New-AzureRmAvailabilitySet -ResourceGroupName $ResourceGroupName -Name $AvailSetName -Location -WarningAction SilentlyContinue | Out-Null
Write-Host "Created Availability Set"
$AvailabilitySet =(Get-AzureRmAvailabilitySet -ResourceGroupName $ResourceGroupName -Name $AvailSetName).Id
$VirtualMachine = New-AzureRmVMConfig -VMName $VMName -VMSize $VMSize -AvailabilitySetID $AvailabilitySet -WarningAction SilentlyContinue
}
else
{
$VirtualMachine = New-AzureRmVMConfig -VMName $VMName -VMSize $VMSize -WarningAction SilentlyContinue
}
$VirtualMachine = Set-AzureRmVMOperatingSystem -VM $VirtualMachine -linux -ComputerName $VMName -Credential $Credential1 -WarningAction SilentlyContinue
$VirtualMachine = Set-AzureRmVMSourceImage -VM $VirtualMachine -PublisherName "Bitnami" -Offer "mysql" -Skus "5-6" -Version "latest"
$VirtualMachine = Add-AzureRmVMNetworkInterface -VM $VirtualMachine -Id $Interface1.Id -Primary -WarningAction SilentlyContinue
$osDiskCaching = "ReadWrite"
$OSDiskName = $VMName + "OSDisk"
$OSDiskUri = $StorageAccount.PrimaryEndpoints.Blob.ToString() + "vhds/" + $OSDiskName + ".vhd"
$VirtualMachine = Set-AzureRmVMOSDisk -VM $VirtualMachine -Name $OSDiskName -VhdUri $OSDiskUri -CreateOption "FromImage" -Caching $osDiskCaching
}
		"*w2k12*" {
$Command = {"Windows VM Image Preparation in Process"}
$Description = "Starting Azure VM Creation"
	WriteLog-Command -Description $Description -Command $Command  -LogFile $LogFile
switch -Wildcard ($ConfigIPs)
	{
		"*UsePublicPvtIP*" {
Write-Host "Public/Static Pvt IP"
$PIp = New-AzureRmPublicIpAddress -Name $InterfaceName1 -ResourceGroupName $ResourceGroupName -Location $Location -AllocationMethod "Dynamic" –Confirm:$false -Force -WarningAction SilentlyContinue
$VNet = Get-AzureRMVirtualNetwork -Name $VNetName -ResourceGroupName $vNetResourceGroupName | Set-AzureRmVirtualNetwork
SubnetMatch $DepSub1
$Interface1 = New-AzureRmNetworkInterface -Name $InterfaceName1 -ResourceGroupName $ResourceGroupName -Location $Location -SubnetId $VNet.Subnets[$DepSub1].Id -PublicIpAddressId $PIp.Id -PrivateIpAddress $PvtIPNic1 –Confirm:$false -Force -WarningAction SilentlyContinue
}
		"*NoPublicStatPvtIP*" {
Write-Host "No Public IP/Static Pvt Ip"
$VNet = Get-AzureRMVirtualNetwork -Name $VNetName -ResourceGroupName $vNetResourceGroupName | Set-AzureRmVirtualNetwork
SubnetMatch $DepSub1
$Interface1 = New-AzureRmNetworkInterface -Name $InterfaceName1 -ResourceGroupName $ResourceGroupName -Location $Location -SubnetId $VNet.Subnets[$DepSub1].Id -PrivateIpAddress $PvtIPNic1 –Confirm:$false -Force -WarningAction SilentlyContinue
}
		"*DynPvtNoPublic*" {
Write-Host "No Public IP/Dynamic PvtIp"
$VNet = Get-AzureRMVirtualNetwork -Name $VNetName -ResourceGroupName $vNetResourceGroupName | Set-AzureRmVirtualNetwork
SubnetMatch $DepSub1
$Interface1 = New-AzureRmNetworkInterface -Name $InterfaceName1 -ResourceGroupName $ResourceGroupName -Location $Location -SubnetId $VNet.Subnets[$DepSub1].Id –Confirm:$false -Force -WarningAction SilentlyContinue
}
		"*Managed*" {
Write-Host "Default IP Configuration"
$PIp = New-AzureRmPublicIpAddress -Name $InterfaceName1 -ResourceGroupName $ResourceGroupName -Location $Location -AllocationMethod "Dynamic" –Confirm:$false -Force -WarningAction SilentlyContinue
$VNet = Get-AzureRMVirtualNetwork -Name $VNetName -ResourceGroupName $vNetResourceGroupName -WarningAction SilentlyContinue  | Set-AzureRmVirtualNetwork
SubnetMatch $DepSub1
$Interface1 = New-AzureRmNetworkInterface -Name $InterfaceName1 -ResourceGroupName $ResourceGroupName -Location $Location -SubnetId $VNet.Subnets[$DepSub1].Id  -PublicIpAddressId $PIp.Id –Confirm:$false -Force -WarningAction SilentlyContinue
}
		default{"An unsupported image was referenced"}
}
If ($AvailabilitySet -eq "True")
 {
New-AzureRmAvailabilitySet -ResourceGroupName $ResourceGroupName -Name $AvailSetName -Location $Location -WarningAction SilentlyContinue | Out-Null
Write-Host "Created Availability Set"
$AvailabilitySet =(Get-AzureRmAvailabilitySet -ResourceGroupName $ResourceGroupName -Name $AvailSetName).Id
$VirtualMachine = New-AzureRmVMConfig -VMName $VMName -VMSize $VMSize -AvailabilitySetID $AvailabilitySet -WarningAction SilentlyContinue
}
else
{
$VirtualMachine = New-AzureRmVMConfig -VMName $VMName -VMSize $VMSize -WarningAction SilentlyContinue
}
$VirtualMachine = Set-AzureRmVMOperatingSystem -VM $VirtualMachine -Windows -ComputerName $VMName -Credential $Credential1 -ProvisionVMAgent -EnableAutoUpdate -WinRMHttp -Verbose -WarningAction SilentlyContinue
$VirtualMachine = Set-AzureRmVMSourceImage -VM $VirtualMachine -PublisherName "MicrosoftWindowsServer" -Offer "WindowsServer" -Skus "2012-R2-Datacenter" -Version "latest" -WarningAction SilentlyContinue
$VirtualMachine = Add-AzureRmVMNetworkInterface -VM $VirtualMachine -Id $Interface1.Id -Primary -WarningAction SilentlyContinue
$osDiskCaching = "ReadWrite"
$OSDiskName = $VMName + "OSDisk"
$OSDiskUri = $StorageAccount.PrimaryEndpoints.Blob.ToString() + "vhds/" + $OSDiskName + ".vhd"
$VirtualMachine = Set-AzureRmVMOSDisk -VM $VirtualMachine -Name $OSDiskName -VhdUri $OSDiskUri -CreateOption "FromImage" -Caching $osDiskCaching -WarningAction SilentlyContinue
}
		"*sql*" {
$Command = {"SQL VM Image Preparation in Process"}
$Description = "Starting Azure VM Creation"
	WriteLog-Command -Description $Description -Command $Command  -LogFile $LogFile
switch -Wildcard ($ConfigIPs)
	{
		"*UsePublicPvtIP*" {
Write-Host "Public/Static Pvt IP"
$PIp = New-AzureRmPublicIpAddress -Name $InterfaceName1 -ResourceGroupName $ResourceGroupName -Location $Location -AllocationMethod "Dynamic" –Confirm:$false -Force -WarningAction SilentlyContinue
$VNet = Get-AzureRMVirtualNetwork -Name $VNetName -ResourceGroupName $vNetResourceGroupName | Set-AzureRmVirtualNetwork
$Interface1 = New-AzureRmNetworkInterface -Name $InterfaceName1 -ResourceGroupName $ResourceGroupName -Location $Location -SubnetId $VNet.Subnets[$DepSub1].Id -PublicIpAddressId $PIp.Id -PrivateIpAddress $PvtIPNic1 –Confirm:$false -Force -WarningAction SilentlyContinue
}
		"*NoPublicStatPvtIP*" {
Write-Host "No Public IP/Static Pvt Ip"
$VNet = Get-AzureRMVirtualNetwork -Name $VNetName -ResourceGroupName $vNetResourceGroupName | Set-AzureRmVirtualNetwork
$Interface1 = New-AzureRmNetworkInterface -Name $InterfaceName1 -ResourceGroupName $ResourceGroupName -Location $Location -SubnetId $VNet.Subnets[$DepSub1].Id -PrivateIpAddress $PvtIPNic1 –Confirm:$false -Force -WarningAction SilentlyContinue
}
		"*DynPvtNoPublic*" {
Write-Host "No Public IP/Dynamic PvtIp"
$VNet = Get-AzureRMVirtualNetwork -Name $VNetName -ResourceGroupName $vNetResourceGroupName | Set-AzureRmVirtualNetwork
$Interface1 = New-AzureRmNetworkInterface -Name $InterfaceName1 -ResourceGroupName $ResourceGroupName -Location $Location -SubnetId $VNet.Subnets[$DepSub1].Id –Confirm:$false -Force -WarningAction SilentlyContinue
}
		"*Managed*" {
Write-Host "Default IP Configuration"
$PIp = New-AzureRmPublicIpAddress -Name $InterfaceName1 -ResourceGroupName $ResourceGroupName -Location $Location -AllocationMethod "Dynamic" –Confirm:$false -Force -WarningAction SilentlyContinue
$VNet = Get-AzureRMVirtualNetwork -Name $VNetName -ResourceGroupName $vNetResourceGroupName | Set-AzureRmVirtualNetwork
$Interface1 = New-AzureRmNetworkInterface -Name $InterfaceName1 -ResourceGroupName $ResourceGroupName -Location $Location -SubnetId $VNet.Subnets[$DepSub1].Id  -PublicIpAddressId $PIp.Id –Confirm:$false -Force -WarningAction SilentlyContinue
}
		default{"An unsupported image was referenced"}
}
If ($AvailabilitySet -eq "True")
 {
New-AzureRmAvailabilitySet -ResourceGroupName $ResourceGroupName -Name $AvailSetName -Location $Location -WarningAction SilentlyContinue | Out-Null
Write-Host "Created Availability Set"
$AvailabilitySet =(Get-AzureRmAvailabilitySet -ResourceGroupName $ResourceGroupName -Name $AvailSetName).Id
$VirtualMachine = New-AzureRmVMConfig -VMName $VMName -VMSize $VMSize -AvailabilitySetID $AvailabilitySet -WarningAction SilentlyContinue
}
else
{
$VirtualMachine = New-AzureRmVMConfig -VMName $VMName -VMSize $VMSize -WarningAction SilentlyContinue
}
$VirtualMachine = Set-AzureRmVMOperatingSystem -VM $VirtualMachine -Windows -ComputerName $VMName -Credential $Credential1 -ProvisionVMAgent -EnableAutoUpdate -WinRMHttp -Verbose
$VirtualMachine = Set-AzureRmVMSourceImage -VM $VirtualMachine -PublisherName "MicrosoftSQLServer" -Offer "SQL2016-WS2012R2" -Skus "Enterprise" -Version "latest"
$VirtualMachine = Add-AzureRmVMNetworkInterface -VM $VirtualMachine -Id $Interface1.Id -Primary -WarningAction SilentlyContinue
$osDiskCaching = "ReadWrite"
$OSDiskName = $VMName + "OSDisk"
$OSDiskUri = $StorageAccount.PrimaryEndpoints.Blob.ToString() + "vhds/" + $OSDiskName + ".vhd"
$VirtualMachine = Set-AzureRmVMOSDisk -VM $VirtualMachine -Name $OSDiskName -VhdUri $OSDiskUri -CreateOption "FromImage" -Caching $osDiskCaching
}
		"*rserver*" {
$Command = {"R Server VM Image Preparation in Process"}
$Description = "Starting Azure VM Creation"
	WriteLog-Command -Description $Description -Command $Command  -LogFile $LogFile
switch -Wildcard ($ConfigIPs)
	{
		"*UsePublicPvtIP*" {
Write-Host "Public/Static Pvt IP"
$PIp = New-AzureRmPublicIpAddress -Name $InterfaceName1 -ResourceGroupName $ResourceGroupName -Location $Location -AllocationMethod "Dynamic" –Confirm:$false -Force -WarningAction SilentlyContinue
$VNet = Get-AzureRMVirtualNetwork -Name $VNetName -ResourceGroupName $vNetResourceGroupName | Set-AzureRmVirtualNetwork
$Interface1 = New-AzureRmNetworkInterface -Name $InterfaceName1 -ResourceGroupName $ResourceGroupName -Location $Location -SubnetId $VNet.Subnets[$DepSub1].Id -PublicIpAddressId $PIp.Id -PrivateIpAddress $PvtIPNic1 –Confirm:$false -Force -WarningAction SilentlyContinue
}
		"*NoPublicStatPvtIP*" {
Write-Host "No Public IP/Static Pvt Ip"
$VNet = Get-AzureRMVirtualNetwork -Name $VNetName -ResourceGroupName $vNetResourceGroupName | Set-AzureRmVirtualNetwork
$Interface1 = New-AzureRmNetworkInterface -Name $InterfaceName1 -ResourceGroupName $ResourceGroupName -Location $Location -SubnetId $VNet.Subnets[$DepSub1].Id -PrivateIpAddress $PvtIPNic1 –Confirm:$false -Force -WarningAction SilentlyContinue
}
		"*DynPvtNoPublic*" {
Write-Host "No Public IP/Dynamic PvtIp"
$VNet = Get-AzureRMVirtualNetwork -Name $VNetName -ResourceGroupName $vNetResourceGroupName | Set-AzureRmVirtualNetwork
$Interface1 = New-AzureRmNetworkInterface -Name $InterfaceName1 -ResourceGroupName $ResourceGroupName -Location $Location -SubnetId $VNet.Subnets[$DepSub1].Id –Confirm:$false -Force -WarningAction SilentlyContinue
}
		"*Managed*" {
Write-Host "Default IP Configuration"
$PIp = New-AzureRmPublicIpAddress -Name $InterfaceName1 -ResourceGroupName $ResourceGroupName -Location $Location -AllocationMethod "Dynamic" –Confirm:$false -Force -WarningAction SilentlyContinue
$VNet = Get-AzureRMVirtualNetwork -Name $VNetName -ResourceGroupName $vNetResourceGroupName | Set-AzureRmVirtualNetwork
$Interface1 = New-AzureRmNetworkInterface -Name $InterfaceName1 -ResourceGroupName $ResourceGroupName -Location $Location -SubnetId $VNet.Subnets[$DepSub1].Id  -PublicIpAddressId $PIp.Id –Confirm:$false -Force -WarningAction SilentlyContinue
}
		default{"An unsupported image was referenced"}
}
If ($AvailabilitySet -eq "True")
 {
New-AzureRmAvailabilitySet -ResourceGroupName $ResourceGroupName -Name $AvailSetName -Location $Location -WarningAction SilentlyContinue | Out-Null
Write-Host "Created Availability Set"
$AvailabilitySet =(Get-AzureRmAvailabilitySet -ResourceGroupName $ResourceGroupName -Name $AvailSetName).Id
$VirtualMachine = New-AzureRmVMConfig -VMName $VMName -VMSize $VMSize -AvailabilitySetID $AvailabilitySet -WarningAction SilentlyContinue
}
else
{
$VirtualMachine = New-AzureRmVMConfig -VMName $VMName -VMSize $VMSize -WarningAction SilentlyContinue
}
$VirtualMachine = Set-AzureRmVMPlan -VM $VirtualMachine -Name msr80-win2012r2 -Publisher microsoft-r-products -Product microsoft-r-server
$VirtualMachine = Set-AzureRmVMOperatingSystem -VM $VirtualMachine -Windows -ComputerName $VMName -Credential $Credential1 -ProvisionVMAgent -EnableAutoUpdate -WarningAction SilentlyContinue
$VirtualMachine = Set-AzureRmVMSourceImage -VM $VirtualMachine -PublisherName microsoft-r-products -Offer microsoft-r-server -Skus msr80-win2012r2 -Version "latest"
$VirtualMachine = Add-AzureRmVMNetworkInterface -VM $VirtualMachine -Id $Interface1.Id -Primary -WarningAction SilentlyContinue
$osDiskCaching = "ReadWrite"
$OSDiskName = $VMName + "OSDisk"
$OSDiskUri = $StorageAccount.PrimaryEndpoints.Blob.ToString() + "vhds/" + $OSDiskName + ".vhd"
$VirtualMachine = Set-AzureRmVMOSDisk -VM $VirtualMachine -Name $OSDiskName -VhdUri $OSDiskUri -CreateOption "FromImage" -Caching $osDiskCaching
}
		"*w2k8*" {
$Command = {"Windows 2k8 VM Image Preparation in Process"}
$Description = "Starting Azure VM Creation"
	WriteLog-Command -Description $Description -Command $Command  -LogFile $LogFile
switch -Wildcard ($ConfigIPs)
	{
		"*UsePublicPvtIP*" {
Write-Host "Public/Static Pvt IP"
$PIp = New-AzureRmPublicIpAddress -Name $InterfaceName1 -ResourceGroupName $ResourceGroupName -Location $Location -AllocationMethod "Dynamic" –Confirm:$false -Force -WarningAction SilentlyContinue
$VNet = Get-AzureRMVirtualNetwork -Name $VNetName -ResourceGroupName $vNetResourceGroupName | Set-AzureRmVirtualNetwork
SubnetMatch $DepSub1
$Interface1 = New-AzureRmNetworkInterface -Name $InterfaceName1 -ResourceGroupName $ResourceGroupName -Location $Location -SubnetId $VNet.Subnets[$DepSub1].Id -PublicIpAddressId $PIp.Id -PrivateIpAddress $PvtIPNic1 –Confirm:$false -Force -WarningAction SilentlyContinue
}
		"*NoPublicStatPvtIP*" {
Write-Host "No Public IP/Static Pvt Ip"
$VNet = Get-AzureRMVirtualNetwork -Name $VNetName -ResourceGroupName $vNetResourceGroupName | Set-AzureRmVirtualNetwork
SubnetMatch $DepSub1
$Interface1 = New-AzureRmNetworkInterface -Name $InterfaceName1 -ResourceGroupName $ResourceGroupName -Location $Location -SubnetId $VNet.Subnets[$DepSub1].Id -PrivateIpAddress $PvtIPNic1 –Confirm:$false -Force -WarningAction SilentlyContinue
}
		"*DynPvtNoPublic*" {
Write-Host "No Public IP/Dynamic PvtIp"
$VNet = Get-AzureRMVirtualNetwork -Name $VNetName -ResourceGroupName $vNetResourceGroupName | Set-AzureRmVirtualNetwork
SubnetMatch $DepSub1
$Interface1 = New-AzureRmNetworkInterface -Name $InterfaceName1 -ResourceGroupName $ResourceGroupName -Location $Location -SubnetId $VNet.Subnets[$DepSub1].Id –Confirm:$false -Force -WarningAction SilentlyContinue
}
		"*Managed*" {
Write-Host "Default IP Configuration"
$PIp = New-AzureRmPublicIpAddress -Name $InterfaceName1 -ResourceGroupName $ResourceGroupName -Location $Location -AllocationMethod "Dynamic" –Confirm:$false -Force -WarningAction SilentlyContinue
$VNet = Get-AzureRMVirtualNetwork -Name $VNetName -ResourceGroupName $vNetResourceGroupName | Set-AzureRmVirtualNetwork
SubnetMatch $DepSub1
$Interface1 = New-AzureRmNetworkInterface -Name $InterfaceName1 -ResourceGroupName $ResourceGroupName -Location $Location -SubnetId $VNet.Subnets[$DepSub1].Id  -PublicIpAddressId $PIp.Id –Confirm:$false -Force -WarningAction SilentlyContinue
}
		default{"An unsupported image was referenced"}
}
If ($AvailabilitySet -eq "True")
 {
New-AzureRmAvailabilitySet -ResourceGroupName $ResourceGroupName -Name $AvailSetName -Location $Location -WarningAction SilentlyContinue | Out-Null
Write-Host "Created Availability Set"
$AvailabilitySet =(Get-AzureRmAvailabilitySet -ResourceGroupName $ResourceGroupName -Name $AvailSetName).Id
$VirtualMachine = New-AzureRmVMConfig -VMName $VMName -VMSize $VMSize -AvailabilitySetID $AvailabilitySet -WarningAction SilentlyContinue
}
else
{
$VirtualMachine = New-AzureRmVMConfig -VMName $VMName -VMSize $VMSize -WarningAction SilentlyContinue
}
$VirtualMachine = Set-AzureRmVMOperatingSystem -VM $VirtualMachine -Windows -ComputerName $VMName -Credential $Credential1 -ProvisionVMAgent -EnableAutoUpdate -WinRMHttp -Verbose -WarningAction SilentlyContinue
$VirtualMachine = Set-AzureRmVMSourceImage -VM $VirtualMachine -PublisherName "MicrosoftWindowsServer" -Offer "WindowsServer" -Skus "2008-R2-SP1" -Version "latest"
$VirtualMachine = Add-AzureRmVMNetworkInterface -VM $VirtualMachine -Id $Interface1.Id -Primary -WarningAction SilentlyContinue
$osDiskCaching = "ReadWrite"
$OSDiskName = $VMName + "OSDisk"
$OSDiskUri = $StorageAccount.PrimaryEndpoints.Blob.ToString() + "vhds/" + $OSDiskName + ".vhd"
$VirtualMachine = Set-AzureRmVMOSDisk -VM $VirtualMachine -Name $OSDiskName -VhdUri $OSDiskUri -CreateOption "FromImage" -Caching $osDiskCaching
}
		"*w2k16*" {
$Command = {"Windows 2k16 VM Image Preparation in Process"}
$Description = "Starting Azure VM Creation"
	WriteLog-Command -Description $Description -Command $Command  -LogFile $LogFile
switch -Wildcard ($ConfigIPs)
	{
		"*UsePublicPvtIP*" {
Write-Host "Public/Static Pvt IP"
$PIp = New-AzureRmPublicIpAddress -Name $InterfaceName1 -ResourceGroupName $ResourceGroupName -Location $Location -AllocationMethod "Dynamic" –Confirm:$false -Force -WarningAction SilentlyContinue
$VNet = Get-AzureRMVirtualNetwork -Name $VNetName -ResourceGroupName $vNetResourceGroupName | Set-AzureRmVirtualNetwork
SubnetMatch $DepSub1
$Interface1 = New-AzureRmNetworkInterface -Name $InterfaceName1 -ResourceGroupName $ResourceGroupName -Location $Location -SubnetId $VNet.Subnets[$DepSub1].Id -PublicIpAddressId $PIp.Id -PrivateIpAddress $PvtIPNic1 –Confirm:$false -Force -WarningAction SilentlyContinue
}
		"*NoPublicStatPvtIP*" {
Write-Host "No Public IP/Static Pvt Ip"
$VNet = Get-AzureRMVirtualNetwork -Name $VNetName -ResourceGroupName $vNetResourceGroupName | Set-AzureRmVirtualNetwork
SubnetMatch $DepSub1
$Interface1 = New-AzureRmNetworkInterface -Name $InterfaceName1 -ResourceGroupName $ResourceGroupName -Location $Location -SubnetId $VNet.Subnets[$DepSub1].Id -PrivateIpAddress $PvtIPNic1 –Confirm:$false -Force -WarningAction SilentlyContinue
}
		"*DynPvtNoPublic*" {
Write-Host "No Public IP/Dynamic PvtIp"
$VNet = Get-AzureRMVirtualNetwork -Name $VNetName -ResourceGroupName $vNetResourceGroupName | Set-AzureRmVirtualNetwork
SubnetMatch $DepSub1
$Interface1 = New-AzureRmNetworkInterface -Name $InterfaceName1 -ResourceGroupName $ResourceGroupName -Location $Location -SubnetId $VNet.Subnets[$DepSub1].Id –Confirm:$false -Force -WarningAction SilentlyContinue
}
		"*Managed*" {
Write-Host "Default IP Configuration"
$PIp = New-AzureRmPublicIpAddress -Name $InterfaceName1 -ResourceGroupName $ResourceGroupName -Location $Location -AllocationMethod "Dynamic" –Confirm:$false -Force -WarningAction SilentlyContinue
$VNet = Get-AzureRMVirtualNetwork -Name $VNetName -ResourceGroupName $vNetResourceGroupName | Set-AzureRmVirtualNetwork
SubnetMatch $DepSub1
$Interface1 = New-AzureRmNetworkInterface -Name $InterfaceName1 -ResourceGroupName $ResourceGroupName -Location $Location -SubnetId $VNet.Subnets[$DepSub1].Id  -PublicIpAddressId $PIp.Id –Confirm:$false -Force -WarningAction SilentlyContinue
}
		default{"An unsupported image was referenced"}
}
If ($AvailabilitySet -eq "True")
 {
New-AzureRmAvailabilitySet -ResourceGroupName $ResourceGroupName -Name $AvailSetName -Location $Location -WarningAction SilentlyContinue | Out-Null
Write-Host "Created Availability Set"
$AvailabilitySet =(Get-AzureRmAvailabilitySet -ResourceGroupName $ResourceGroupName -Name $AvailSetName).Id
$VirtualMachine = New-AzureRmVMConfig -VMName $VMName -VMSize $VMSize -AvailabilitySetID $AvailabilitySet
}
else
{
$VirtualMachine = New-AzureRmVMConfig -VMName $VMName -VMSize $VMSize -WarningAction SilentlyContinue
}
$VirtualMachine = Set-AzureRmVMOperatingSystem -VM $VirtualMachine -Windows -ComputerName $VMName -Credential $Credential1 -ProvisionVMAgent -EnableAutoUpdate -WinRMHttp -Verbose -WarningAction SilentlyContinue
$VirtualMachine = Set-AzureRmVMSourceImage -VM $VirtualMachine -PublisherName "MicrosoftWindowsServer" -Offer "WindowsServer" -Skus "Windows-Server-Technical-Preview" -Version "latest"
$VirtualMachine = Add-AzureRmVMNetworkInterface -VM $VirtualMachine -Id $Interface1.Id -Primary -WarningAction SilentlyContinue
$osDiskCaching = "ReadWrite"
$OSDiskName = $VMName + "OSDisk"
$OSDiskUri = $StorageAccount.PrimaryEndpoints.Blob.ToString() + "vhds/" + $OSDiskName + ".vhd"
$VirtualMachine = Set-AzureRmVMOSDisk -VM $VirtualMachine -Name $OSDiskName -VhdUri $OSDiskUri -CreateOption "FromImage" -Caching $osDiskCaching
}
		"*chef*" {
$Command = {"Chef VM Image Preparation in Process"}
$Description = "Starting Azure VM Creation"
	WriteLog-Command -Description $Description -Command $Command  -LogFile $LogFile
switch -Wildcard ($ConfigIPs)
	{
		"*UsePublicPvtIP*" {
Write-Host "Public/Static Pvt IP"
$PIp = New-AzureRmPublicIpAddress -Name $InterfaceName1 -ResourceGroupName $ResourceGroupName -Location $Location -AllocationMethod "Dynamic" –Confirm:$false -Force -WarningAction SilentlyContinue
$VNet = Get-AzureRMVirtualNetwork -Name $VNetName -ResourceGroupName $vNetResourceGroupName | Set-AzureRmVirtualNetwork
$Interface1 = New-AzureRmNetworkInterface -Name $InterfaceName1 -ResourceGroupName $ResourceGroupName -Location $Location -SubnetId $VNet.Subnets[$DepSub1].Id -PublicIpAddressId $PIp.Id -PrivateIpAddress $PvtIPNic1 –Confirm:$false -Force -WarningAction SilentlyContinue
}
		"*NoPublicStatPvtIP*" {
Write-Host "No Public IP/Static Pvt Ip"
$VNet = Get-AzureRMVirtualNetwork -Name $VNetName -ResourceGroupName $vNetResourceGroupName | Set-AzureRmVirtualNetwork
$Interface1 = New-AzureRmNetworkInterface -Name $InterfaceName1 -ResourceGroupName $ResourceGroupName -Location $Location -SubnetId $VNet.Subnets[$DepSub1].Id -PrivateIpAddress $PvtIPNic1 –Confirm:$false -Force -WarningAction SilentlyContinue
}
		"*DynPvtNoPublic*" {
Write-Host "No Public IP/Dynamic PvtIp"
$VNet = Get-AzureRMVirtualNetwork -Name $VNetName -ResourceGroupName $vNetResourceGroupName | Set-AzureRmVirtualNetwork
$Interface1 = New-AzureRmNetworkInterface -Name $InterfaceName1 -ResourceGroupName $ResourceGroupName -Location $Location -SubnetId $VNet.Subnets[$DepSub1].Id –Confirm:$false -Force -WarningAction SilentlyContinue
}
		"*Managed*" {
Write-Host "Default IP Configuration"
$PIp = New-AzureRmPublicIpAddress -Name $InterfaceName1 -ResourceGroupName $ResourceGroupName -Location $Location -AllocationMethod "Dynamic" -DomainNameLabel $DNSLabel –Confirm:$false -Force -WarningAction SilentlyContinue
$VNet = Get-AzureRMVirtualNetwork -Name $VNetName -ResourceGroupName $vNetResourceGroupName | Set-AzureRmVirtualNetwork
$Interface1 = New-AzureRmNetworkInterface -Name $InterfaceName1 -ResourceGroupName $ResourceGroupName -Location $Location -SubnetId $VNet.Subnets[$DepSub1].Id  -PublicIpAddressId $PIp.Id –Confirm:$false -Force -WarningAction SilentlyContinue
Write-Host "DNS Name $DNSLabel.westus.cloudapp.azure.com"
}
		default{"An unsupported image was referenced"}
}
If ($AvailabilitySet -eq "True")
 {
New-AzureRmAvailabilitySet -ResourceGroupName $ResourceGroupName -Name $AvailSetName -Location $Location -WarningAction SilentlyContinue | Out-Null
Write-Host "Created Availability Set"
$AvailabilitySet =(Get-AzureRmAvailabilitySet -ResourceGroupName $ResourceGroupName -Name $AvailSetName).Id
$VirtualMachine = New-AzureRmVMConfig -VMName $VMName -VMSize $VMSize -AvailabilitySetID $AvailabilitySet -WarningAction SilentlyContinue
}
else
{
$VirtualMachine = New-AzureRmVMConfig -VMName $VMName -VMSize $VMSize -WarningAction SilentlyContinue
}
$VirtualMachine = Set-AzureRmVMPlan -VM $VirtualMachine -Name azure_marketplace_100 -Publisher chef-software -Product chef-server
$VirtualMachine = Set-AzureRmVMSourceImage -VM $VirtualMachine -PublisherName chef-software -Offer chef-server -Skus azure_marketplace_100 -Version "latest"
$VirtualMachine = Set-AzureRmVMOperatingSystem -VM $VirtualMachine -linux -ComputerName $VMName -Credential $Credential1
$VirtualMachine = Add-AzureRmVMNetworkInterface -VM $VirtualMachine -Id $Interface1.Id -Primary -WarningAction SilentlyContinue
$osDiskCaching = "ReadWrite"
$OSDiskName = $VMName + "OSDisk"
$OSDiskUri = $StorageAccount.PrimaryEndpoints.Blob.ToString() + "vhds/" + $OSDiskName + ".vhd"
$VirtualMachine = Set-AzureRmVMOSDisk -VM $VirtualMachine -Name $OSDiskName -VhdUri $OSDiskUri -CreateOption "FromImage" -Caching $osDiskCaching
}
		"*cent*" {
$Command = {"CentOS VM Image Preparation in Process"}
$Description = "Starting Azure VM Creation"
	WriteLog-Command -Description $Description -Command $Command  -LogFile $LogFile
switch -Wildcard ($ConfigIPs)
	{
		"*UsePublicPvtIP*" {
Write-Host "Public/Static Pvt IP"
$PIp = New-AzureRmPublicIpAddress -Name $InterfaceName1 -ResourceGroupName $ResourceGroupName -Location $Location -AllocationMethod "Dynamic" –Confirm:$false -Force -WarningAction SilentlyContinue
$VNet = Get-AzureRMVirtualNetwork -Name $VNetName -ResourceGroupName $vNetResourceGroupName | Set-AzureRmVirtualNetwork
SubnetMatch $DepSub1
$Interface1 = New-AzureRmNetworkInterface -Name $InterfaceName1 -ResourceGroupName $ResourceGroupName -Location $Location -SubnetId $VNet.Subnets[$DepSub1].Id -PublicIpAddressId $PIp.Id -PrivateIpAddress $PvtIPNic1 –Confirm:$false -Force -WarningAction SilentlyContinue
}
		"*NoPublicStatPvtIP*" {
Write-Host "No Public IP/Static Pvt Ip"
$VNet = Get-AzureRMVirtualNetwork -Name $VNetName -ResourceGroupName $vNetResourceGroupName | Set-AzureRmVirtualNetwork
SubnetMatch $DepSub1
$Interface1 = New-AzureRmNetworkInterface -Name $InterfaceName1 -ResourceGroupName $ResourceGroupName -Location $Location -SubnetId $VNet.Subnets[$DepSub1].Id -PrivateIpAddress $PvtIPNic1 –Confirm:$false -Force -WarningAction SilentlyContinue
}
		"*DynPvtNoPublic*" {
Write-Host "No Public IP/Dynamic PvtIp"
$VNet = Get-AzureRMVirtualNetwork -Name $VNetName -ResourceGroupName $vNetResourceGroupName | Set-AzureRmVirtualNetwork
SubnetMatch $DepSub1
$Interface1 = New-AzureRmNetworkInterface -Name $InterfaceName1 -ResourceGroupName $ResourceGroupName -Location $Location -SubnetId $VNet.Subnets[$DepSub1].Id –Confirm:$false -Force -WarningAction SilentlyContinue
}
		"*Managed*" {
Write-Host "Default IP Configuration"
$PIp = New-AzureRmPublicIpAddress -Name $InterfaceName1 -ResourceGroupName $ResourceGroupName -Location $Location -AllocationMethod "Dynamic" –Confirm:$false -Force -WarningAction SilentlyContinue
$VNet = Get-AzureRMVirtualNetwork -Name $VNetName -ResourceGroupName $vNetResourceGroupName | Set-AzureRmVirtualNetwork
SubnetMatch $DepSub1
$Interface1 = New-AzureRmNetworkInterface -Name $InterfaceName1 -ResourceGroupName $ResourceGroupName -Location $Location -SubnetId $VNet.Subnets[$DepSub1].Id  -PublicIpAddressId $PIp.Id –Confirm:$false -Force -WarningAction SilentlyContinue
}
		default{"An unsupported image was referenced"}
}
If ($AvailabilitySet -eq "True")
 {
New-AzureRmAvailabilitySet -ResourceGroupName $ResourceGroupName -Name $AvailSetName -Location $Location -WarningAction SilentlyContinue | Out-Null
Write-Host "Created Availability Set"
$AvailabilitySet =(Get-AzureRmAvailabilitySet -ResourceGroupName $ResourceGroupName -Name $AvailSetName).Id
$VirtualMachine = New-AzureRmVMConfig -VMName $VMName -VMSize $VMSize -AvailabilitySetID $AvailabilitySet -WarningAction SilentlyContinue
}
else
{
$VirtualMachine = New-AzureRmVMConfig -VMName $VMName -VMSize $VMSize -WarningAction SilentlyContinue
}
$VirtualMachine = Set-AzureRmVMSourceImage -VM $VirtualMachine -PublisherName OpenLogic -Offer Centos -Skus "7.2" -Version "latest"
$VirtualMachine = Set-AzureRmVMOperatingSystem -VM $VirtualMachine -linux -ComputerName $VMName -Credential $Credential1
$VirtualMachine = Add-AzureRmVMNetworkInterface -VM $VirtualMachine -Id $Interface1.Id -Primary -WarningAction SilentlyContinue
$osDiskCaching = "ReadWrite"
$OSDiskName = $VMName + "OSDisk"
$OSDiskUri = $StorageAccount.PrimaryEndpoints.Blob.ToString() + "vhds/" + $OSDiskName + ".vhd"
$VirtualMachine = Set-AzureRmVMOSDisk -VM $VirtualMachine -Name $OSDiskName -VhdUri $OSDiskUri -CreateOption "FromImage" -Caching $osDiskCaching
}
		"*ub*" {
$Command = {"Ubuntu VM Image Preparation in Process"}
$Description = "Starting Azure VM Creation"
	WriteLog-Command -Description $Description -Command $Command  -LogFile $LogFile
switch -Wildcard ($ConfigIPs)
	{
		"*UsePublicPvtIP*" {
Write-Host "Public/Static Pvt IP"
$PIp = New-AzureRmPublicIpAddress -Name $InterfaceName1 -ResourceGroupName $ResourceGroupName -Location $Location -AllocationMethod "Dynamic" –Confirm:$false -Force -WarningAction SilentlyContinue
$VNet = Get-AzureRMVirtualNetwork -Name $VNetName -ResourceGroupName $vNetResourceGroupName | Set-AzureRmVirtualNetwork
SubnetMatch $DepSub1
$Interface1 = New-AzureRmNetworkInterface -Name $InterfaceName1 -ResourceGroupName $ResourceGroupName -Location $Location -SubnetId $VNet.Subnets[$DepSub1].Id -PublicIpAddressId $PIp.Id -PrivateIpAddress $PvtIPNic –Confirm:$false -Force -WarningAction SilentlyContinue
}
		"*NoPublicStatPvtIP*" {
Write-Host "No Public IP/Static Pvt Ip"
$VNet = Get-AzureRMVirtualNetwork -Name $VNetName -ResourceGroupName $vNetResourceGroupName | Set-AzureRmVirtualNetwork
SubnetMatch $DepSub1
$Interface1 = New-AzureRmNetworkInterface -Name $InterfaceName1 -ResourceGroupName $ResourceGroupName -Location $Location -SubnetId $VNet.Subnets[$DepSub1].Id -PrivateIpAddress $PvtIPNic –Confirm:$false -Force -WarningAction SilentlyContinue
}
		"*DynPvtNoPublic*" {
Write-Host "No Public IP/Dynamic PvtIp"
$VNet = Get-AzureRMVirtualNetwork -Name $VNetName -ResourceGroupName $vNetResourceGroupName | Set-AzureRmVirtualNetwork
SubnetMatch $DepSub1
$Interface1 = New-AzureRmNetworkInterface -Name $InterfaceName1 -ResourceGroupName $ResourceGroupName -Location $Location -SubnetId $VNet.Subnets[$DepSub1].Id –Confirm:$false -Force -WarningAction SilentlyContinue
}
		"*Managed*" {
Write-Host "Default IP Configuration"
$PIp = New-AzureRmPublicIpAddress -Name $InterfaceName1 -ResourceGroupName $ResourceGroupName -Location $Location -AllocationMethod "Dynamic" –Confirm:$false -Force -WarningAction SilentlyContinue
$VNet = Get-AzureRMVirtualNetwork -Name $VNetName -ResourceGroupName $vNetResourceGroupName | Set-AzureRmVirtualNetwork
SubnetMatch $DepSub1
$Interface1 = New-AzureRmNetworkInterface -Name $InterfaceName1 -ResourceGroupName $ResourceGroupName -Location $Location -SubnetId $VNet.Subnets[$DepSub1].Id -PublicIpAddressId $PIp.Id –Confirm:$false -Force -WarningAction SilentlyContinue
}
		default{"An unsupported image was referenced"}
}
If ($AvailabilitySet -eq "True")
 {
New-AzureRmAvailabilitySet -ResourceGroupName $ResourceGroupName -Name $AvailSetName -Location $Location -WarningAction SilentlyContinue | Out-Null
Write-Host "Created Availability Set"
$AvailabilitySet = (Get-AzureRmAvailabilitySet -ResourceGroupName $ResourceGroupName -Name $AvailSetName).Id
$VirtualMachine = New-AzureRmVMConfig -VMName $VMName -VMSize $VMSize -AvailabilitySetID $AvailabilitySet -WarningAction SilentlyContinue
}
else
{
$VirtualMachine = New-AzureRmVMConfig -VMName $VMName -VMSize $VMSize -WarningAction SilentlyContinue
}
$VirtualMachine = Set-AzureRmVMSourceImage -VM $VirtualMachine -PublisherName Canonical -Offer UbuntuServer -Skus "14.04.4-LTS" -Version "latest"
$VirtualMachine = Set-AzureRmVMOperatingSystem -VM $VirtualMachine -linux -ComputerName $VMName -Credential $Credential1 -WarningAction SilentlyContinue
$VirtualMachine = Add-AzureRmVMNetworkInterface -VM $VirtualMachine -Id $Interface1.Id -Primary -WarningAction SilentlyContinue
$osDiskCaching = "ReadWrite"
$OSDiskName = $VMName + "OSDisk"
$OSDiskUri = $StorageAccount.PrimaryEndpoints.Blob.ToString() + "vhds/" + $OSDiskName + ".vhd"
$VirtualMachine = Set-AzureRmVMOSDisk -VM $VirtualMachine -Name $OSDiskName -VhdUri $OSDiskUri -CreateOption "FromImage" -Caching $osDiskCaching
}
		"*SU*" {
$Command = {"SuSe VM Image Preparation in Process"}
$Description = "Starting Azure VM Creation"
	WriteLog-Command -Description $Description -Command $Command  -LogFile $LogFile
switch -Wildcard ($ConfigIPs)
	{
		"*UsePublicPvtIP*" {
Write-Host "Public/Static Pvt IP"
$PIp = New-AzureRmPublicIpAddress -Name $InterfaceName1 -ResourceGroupName $ResourceGroupName -Location $Location -AllocationMethod "Dynamic" –Confirm:$false -Force -WarningAction SilentlyContinue
$VNet = Get-AzureRMVirtualNetwork -Name $VNetName -ResourceGroupName $vNetResourceGroupName | Set-AzureRmVirtualNetwork
SubnetMatch $DepSub1
$Interface1 = New-AzureRmNetworkInterface -Name $InterfaceName1 -ResourceGroupName $ResourceGroupName -Location $Location -SubnetId $VNet.Subnets[$DepSub1].Id -PublicIpAddressId $PIp.Id -PrivateIpAddress $PvtIPNic1 –Confirm:$false -Force -WarningAction SilentlyContinue
}
		"*NoPublicStatPvtIP*" {
Write-Host "No Public IP/Static Pvt Ip"
$VNet = Get-AzureRMVirtualNetwork -Name $VNetName -ResourceGroupName $vNetResourceGroupName | Set-AzureRmVirtualNetwork
SubnetMatch $DepSub1
$Interface1 = New-AzureRmNetworkInterface -Name $InterfaceName1 -ResourceGroupName $ResourceGroupName -Location $Location -SubnetId $VNet.Subnets[$DepSub1].Id -PrivateIpAddress $PvtIPNic1 –Confirm:$false -Force -WarningAction SilentlyContinue
}
		"*DynPvtNoPublic*" {
Write-Host "No Public IP/Dynamic PvtIp"
$VNet = Get-AzureRMVirtualNetwork -Name $VNetName -ResourceGroupName $vNetResourceGroupName | Set-AzureRmVirtualNetwork
SubnetMatch $DepSub1
$Interface1 = New-AzureRmNetworkInterface -Name $InterfaceName1 -ResourceGroupName $ResourceGroupName -Location $Location -SubnetId $VNet.Subnets[$DepSub1].Id –Confirm:$false -Force -WarningAction SilentlyContinue
}
		"*Managed*" {
Write-Host "Default IP Configuration"
$PIp = New-AzureRmPublicIpAddress -Name $InterfaceName1 -ResourceGroupName $ResourceGroupName -Location $Location -AllocationMethod "Dynamic" –Confirm:$false -Force -WarningAction SilentlyContinue
$VNet = Get-AzureRMVirtualNetwork -Name $VNetName -ResourceGroupName $vNetResourceGroupName | Set-AzureRmVirtualNetwork
SubnetMatch $DepSub1
$Interface1 = New-AzureRmNetworkInterface -Name $InterfaceName1 -ResourceGroupName $ResourceGroupName -Location $Location -SubnetId $VNet.Subnets[$DepSub1].Id  -PublicIpAddressId $PIp.Id –Confirm:$false -Force -WarningAction SilentlyContinue
}
		default{"An unsupported image was referenced"}
}
If ($AvailabilitySet -eq "True")
 {
New-AzureRmAvailabilitySet -ResourceGroupName $ResourceGroupName -Name $AvailSetName -Location $Location -WarningAction SilentlyContinue | Out-Null
Write-Host "Created Availability Set"
$AvailabilitySet =(Get-AzureRmAvailabilitySet -ResourceGroupName $ResourceGroupName -Name $AvailSetName).Id
$VirtualMachine = New-AzureRmVMConfig -VMName $VMName -VMSize $VMSize -AvailabilitySetID $AvailabilitySet -WarningAction SilentlyContinue
}
else
{
$VirtualMachine = New-AzureRmVMConfig -VMName $VMName -VMSize $VMSize -WarningAction SilentlyContinue
}
$VirtualMachine = Set-AzureRmVMSourceImage -VM $VirtualMachine -PublisherName SUSE -Offer openSUSE -Skus "13.2" -Version "latest"
$VirtualMachine = Set-AzureRmVMOperatingSystem -VM $VirtualMachine -linux -ComputerName $VMName -Credential $Credential1 -WarningAction SilentlyContinue
$VirtualMachine = Add-AzureRmVMNetworkInterface -VM $VirtualMachine -Id $Interface1.Id -Primary -WarningAction SilentlyContinue
$osDiskCaching = "ReadWrite"
$OSDiskName = $VMName + "OSDisk"
$OSDiskUri = $StorageAccount.PrimaryEndpoints.Blob.ToString() + "vhds/" + $OSDiskName + ".vhd"
$VirtualMachine = Set-AzureRmVMOSDisk -VM $VirtualMachine -Name $OSDiskName -VhdUri $OSDiskUri -CreateOption "FromImage" -Caching $osDiskCaching
}
		"*check*" {
$Command = {"Checkpoint VM Image Preparation in Process"}
$Description = "Starting Azure VM Creation"
	WriteLog-Command -Description $Description -Command $Command  -LogFile $LogFile
switch -Wildcard ($ConfigIPs)
	{
		"*UsePublicPvtIP*" {
Write-Host "Public/Static Pvt IP"
$PIp = New-AzureRmPublicIpAddress -Name $InterfaceName1 -ResourceGroupName $ResourceGroupName -Location $Location -AllocationMethod "Dynamic" –Confirm:$false -Force -WarningAction SilentlyContinue
$VNet = Get-AzureRMVirtualNetwork -Name $VNetName -ResourceGroupName $vNetResourceGroupName | Set-AzureRmVirtualNetwork
$Interface1 = New-AzureRmNetworkInterface -Name $InterfaceName1 -ResourceGroupName $ResourceGroupName -Location $Location -SubnetId $VNet.Subnets[$DepSub1].Id -PublicIpAddressId $PIp.Id -PrivateIpAddress $PvtIPNic1 –Confirm:$false -Force -WarningAction SilentlyContinue
SubnetMatch $DepSub1
$Interface2 = New-AzureRmNetworkInterface -Name $InterfaceName2 -ResourceGroupName $ResourceGroupName -Location $Location -SubnetId $VNet.Subnets[$DepSub2].Id -PrivateIpAddress $PvtIPNic2 –Confirm:$false -Force -WarningAction SilentlyContinue
}
		"*NoPublicStatPvtIP*" {
Write-Host "No Public IP/Static Pvt Ip"
$VNet = Get-AzureRMVirtualNetwork -Name $VNetName -ResourceGroupName $vNetResourceGroupName | Set-AzureRmVirtualNetwork
SubnetMatch $DepSub1
$Interface1 = New-AzureRmNetworkInterface -Name $InterfaceName1 -ResourceGroupName $ResourceGroupName -Location $Location -SubnetId $VNet.Subnets[$DepSub1].Id -PrivateIpAddress $PvtIPNic1 –Confirm:$false -Force -WarningAction SilentlyContinue
SubnetMatch $DepSub2
$Interface2 = New-AzureRmNetworkInterface -Name $InterfaceName2 -ResourceGroupName $ResourceGroupName -Location $Location -SubnetId $VNet.Subnets[$DepSub2].Id -PrivateIpAddress $PvtIPNic2 –Confirm:$false -Force -WarningAction SilentlyContinue
}
		"*DynPvtNoPublic*" {
Write-Host "No Public IP/Dynamic PvtIp"
$VNet = Get-AzureRMVirtualNetwork -Name $VNetName -ResourceGroupName $vNetResourceGroupName | Set-AzureRmVirtualNetwork
$Interface1 = New-AzureRmNetworkInterface -Name $InterfaceName1 -ResourceGroupName $ResourceGroupName -Location $Location -SubnetId $VNet.Subnets[$DepSub1].Id –Confirm:$false -Force -WarningAction SilentlyContinue
$Interface2 = New-AzureRmNetworkInterface -Name $InterfaceName2 -ResourceGroupName $ResourceGroupName -Location $Location -SubnetId $VNet.Subnets[$DepSub2].Id –Confirm:$false -Force -WarningAction SilentlyContinue
}
		"*Managed*" {
Write-Host "Default IP Configuration"
$PIp = New-AzureRmPublicIpAddress -Name $InterfaceName1 -ResourceGroupName $ResourceGroupName -Location $Location -AllocationMethod "Dynamic" –Confirm:$false -Force -WarningAction SilentlyContinue
$VNet = Get-AzureRMVirtualNetwork -Name $VNetName -ResourceGroupName $vNetResourceGroupName | Set-AzureRmVirtualNetwork
$Interface1 = New-AzureRmNetworkInterface -Name $InterfaceName1 -ResourceGroupName $ResourceGroupName -Location $Location -SubnetId $VNet.Subnets[$DepSub1].Id -PublicIpAddressId $PIp.Id –Confirm:$false -Force -WarningAction SilentlyContinue
$Interface2 = New-AzureRmNetworkInterface -Name $InterfaceName2 -ResourceGroupName $ResourceGroupName -Location $Location -SubnetId $VNet.Subnets[$DepSub2].Id –Confirm:$false -Force -WarningAction SilentlyContinue
}
		default{"An unsupported image was referenced"}
}
If ($AvailabilitySet -eq "True")
 {
New-AzureRmAvailabilitySet -ResourceGroupName $ResourceGroupName -Name $AvailSetName -Location $Location -WarningAction SilentlyContinue | Out-Null
Write-Host "Created Availability Set"
$AvailabilitySet =(Get-AzureRmAvailabilitySet -ResourceGroupName $ResourceGroupName -Name $AvailSetName).Id
$VirtualMachine = New-AzureRmVMConfig -VMName $VMName -VMSize $VMSize -AvailabilitySetID $AvailabilitySet -WarningAction SilentlyContinue
}
else
{
$VirtualMachine = New-AzureRmVMConfig -VMName $VMName -VMSize $VMSize -WarningAction SilentlyContinue
}
$VirtualMachine = Set-AzureRmVMPlan -VM $VirtualMachine -Name sg-ngtp -Publisher checkpoint -Product check-point-r77-10
$VirtualMachine = Set-AzureRmVMSourceImage -VM $VirtualMachine -PublisherName checkpoint -Offer check-point-r77-10 -Skus sg-ngtp -Version "latest"
$VirtualMachine = Set-AzureRmVMOperatingSystem -VM $VirtualMachine -linux -ComputerName $VMName -Credential $Credential1 -WarningAction SilentlyContinue
$VirtualMachine = Add-AzureRmVMNetworkInterface -VM $VirtualMachine -Id $Interface1.Id -Primary -WarningAction SilentlyContinue
$VirtualMachine = Add-AzureRmVMNetworkInterface -VM $VirtualMachine -Id $Interface2.Id -WarningAction SilentlyContinue
$osDiskCaching = "ReadWrite"
$OSDiskName = $VMName + "OSDisk"
$OSDiskUri = $StorageAccount.PrimaryEndpoints.Blob.ToString() + "vhds/" + $OSDiskName + ".vhd"
$VirtualMachine = Set-AzureRmVMOSDisk -VM $VirtualMachine -Name $OSDiskName -VhdUri $OSDiskUri -CreateOption "FromImage" -Caching $osDiskCaching
}
		default{"An unsupported image was referenced"}
	}
	$ProvisionVMs = @($VirtualMachine);
try {
   foreach($provisionvm in $ProvisionVMs) {
New-AzureRmVM -ResourceGroupName $ResourceGroupName -Location $Location -VM $VirtualMachine –Confirm:$false -Verbose -WarningAction SilentlyContinue
						}
	}

catch {
	Write-Host -foregroundcolor Red `
	"$($_.Exception.Message)"; `
	continue
}

If ($ConfigIPs -eq "NoPublicStatPvtIP" -OR $ConfigIPs -eq "DynPvtNoPublic"){
Write-Host "No Public IP created"
Get-AzureRmNetworkInterface -Name $InterfaceName1 -ResourceGroupName $ResourceGroupName | ft Name,Location,ResourceGroupName
}
else
{
Get-AzureRmPublicIpAddress -Name $InterfaceName1 -ResourceGroupName $ResourceGroupName | ft "IpAddress" -Wrap -HideTableHeaders
	Get-AzureRmNetworkInterface -Name $InterfaceName1 -ResourceGroupName $ResourceGroupName | ft Name,Location,ResourceGroupName
}

	 switch -Wildcard ($AzExtConfig)
{
		"*VMAccess*" {
Write-Host "VM Access Agent VM Image Preparation in Process"
Set-AzureRmVMAccessExtension -ResourceGroupName $ResourceGroupName -VMName $VMName -Name "VMAccess" -ExtensionType "VMAccessAgent" -Publisher "Microsoft.Compute" -typeHandlerVersion "2.0" -Location $Location -Verbose
Get-AzureRmVMExtension -ResourceGroupName $ResourceGroupName -VMName $VMName -Name "VMAccess"
}
		"*MSAV*" {
Write-Host "MSAV Agent VM Image Preparation in Process"
Set-AzureRmVMExtension  -ResourceGroupName $ResourceGroupName -VMName $VMName -Name "MSAVExtension" -ExtensionType "IaaSAntimalware" -Publisher "Microsoft.Azure.Security" -typeHandlerVersion 1.4 -Location $Location
Set-AzureRmVMAccessExtension -ResourceGroupName $ResourceGroupName -VMName $VMName -Name "MSAVExtension" -Location $Location
Get-AzureRmVMExtension -ResourceGroupName $ResourceGroupName -VMName $VMName -Name "MSAVExtension" -Status
}
		"*CustScript" {
Write-Host "Updating server with custom script"
Set-AzureRmVMCustomScriptExtension -Name "CustScript" -ResourceGroupName $ResourceGroupName -Run "CustScript.ps1" -VMName $VMName -FileUri $StorageName -Location $Location -TypeHandlerVersion "1.1"
Get-AzureRmVMCustomScriptExtension -ResourceGroupName $ResourceGroupName -Name "CustScript"
}
		"*AzureDiag*" {
Write-Host "Adding Azure Enhanced Diagnostics"
Set-AzureRmVMAEMExtension -ResourceGroupName $ResourceGroupName -VMName $VMName -WADStorageAccountName $StorageName
Get-AzureRmVMAEMExtension -ResourceGroupName $ResourceGroupName -VMName $VMName
}
		"*AddDom*" {
Write-Host "Adding to Domain $Domname"
Set-AzureRmVMADDomainExtension -DomainName $DomName -ResourceGroupName $ResourceGroupName -VMName $VMName -Location $Location -Restart
Get-AzureRmVMADDomainExtension -ResourceGroupName $ResourceGroupName -VMName $VMName -Status -Name
		}
		"*ExtChef*" {
Write-Host "Adding Chef Agent"
Set-AzureRmVMExtension -ResourceGroupName $ResourceGroupName -VMName $VMName -Name "ChefStrap" -ExtensionType "ChefClient" -Publisher "Chef.Bootstrap.WindowsAzure" -typeHandlerVersion "1210.12" -Location $Location -Verbose -ProtectedSettingString -SettingString
Get-AzureRmVMExtension -ResourceGroupName $ResourceGroupName -VMName $VMName -Name "ChefStrap"
		}
		"*ChefWin*" {
Write-Host "Bootstrapping Chef Agent"
knife bootstrap windows winrm $BootIp --winrm-user $localadmin --winrm-password $locpassword --node-name $VMName --Install-as-service
		}
		"*ChefLin*" {
Write-Host "Bootstrapping Chef Agent"
knife bootstrap $BootIp --node-name $VMName --ssh-user localadmin --ssh-password $locpassword --sudo --use-sudo-password --verbose --yes
		}

		default{"An unsupported Extensions command was used"}
	}

If ($AvailabilitySet -ne "True"){
Write-Host "Completed - [VM]:$VMName [RG]:$ResourceGroupName [IMAGE]:$vmMarketImage [VNET]: $VNetName [VNETRG]: $vNetResourceGroupName [AVAILSET]: $AvailSetName"
Start-sleep 5
Get-AzureRmResource | where { $_.ResourceGroupName -eq $ResourceGroupName } | Format-Table
}
else
{
Write-Host "Completed - [VM]:$VMName [RG]:$ResourceGroupName [IMAGE]:$vmMarketImage [VNET]: $VNetName [VNETRG]: $vNetResourceGroupName"
Start-sleep 5
Write-Output "Completed - [VM]:$VMName [RG]:$ResourceGroupName [IMAGE]:$vmMarketImage [VNET]: $VNetName [VNETRG]: $vNetResourceGroupName"
Get-AzureRmResource | where { $_.ResourceGroupName -eq $ResourceGroupName } | ft  "Name", "ResourceType" | Format-Table
}

 Get-AzureRmVirtualNetwork -Name $VNetName -ResourceGroupName $vNetResourceGroupName | Select Name, ResourceGroupName, Subnets
 Get-AzureRmPublicIpAddress -Name $InterfaceName1 -ResourceGroupName $ResourceGroupName | ft "Name","IpAddress"
 Get-AzureRmNetworkInterface -Name $InterfaceName1 -ResourceGroupName $ResourceGroupName | ft Name,Location,ResourceGroupName