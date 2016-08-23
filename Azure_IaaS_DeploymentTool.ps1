<#
.SYNOPSIS
Written By John N Lewis
email: jonos@live.com
Ver 4.2
This script provides the following functionality for deploying IaaS environments in Azure. The script will deploy VNET in addition to numerour Market Place VMs or make use of an existing VNETs.
The script supports dual homed servers (PFSense/Checkpoint/FreeBSD)
The script allows select of subnet prior to VM Deployment
The script supports deploying Availability Sets as well as adding new servers to existing Availability Sets through the -AvailabilitySet "True" and -AvailSetName switches.
The script will generate a name for azure storage endpoint unless the -StorageName variable is updated or referenced at runtime.

.DESCRIPTION
Deploys 26 Market Images on a new or existing VNET. Supports post deployment configuration through Azure Extensions.
Market Images supported: Redhat 6.7 and 7.2, PFSense 2.5, Windows 2008 R2, Windows 2012 R2, Ubuntu 14.04, CentOs 7.2, SUSE, SQL 2016 (on W2K12R2), R Server on Windows, Windows 2016 (Preview), Checkpoint Firewall, FreeBsd, Oracle Linux, Puppet, Splunk, Oracle Web-Logic, Oracle DB, Bitnami Lamp, Bitnami PostGresSql, Bitnami nodejs, Bitnami Elastics, Bitnami MySql
.PARAMETER vmMarketImage

.PARAMETER NewVnet

.PARAMETER VMName

.PARAMETER ResourceGroupName

.PARAMETER vNetResourceGroupName

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

.PARAMETER DepSub1

.PARAMETER DepSub2

.PARAMETER AvailabilitySet

.PARAMETER AvailSetName

.PARAMETER PvtIPNic1

.PARAMETER PvtIPNic2

.PARAMETER AzExtConfig

.PARAMETER DNLabel

.PARAMETER AddFQDN

.EXAMPLE
\.azdeploy.ps1 -VMName pf001 -VMMarketImage pfsense -ResourceGroupName ResGroup1 -vNetResourceGroupName ResGroup1 -VNetName VNET -depsub1 0 -depsub2 1 -ConfigIPs DualPvtNoPub -PvtIPNic1 10.120.0.7 -PvtIPNic2 10.120.1.7
.EXAMPLE
\.azdeploy.ps1 -VMName red76 -VMMarketImage red67 -ResourceGroupName ResGroup1 -vNetResourceGroupName ResGroup2 -VNetName VNET -depsub1 6 -ConfigIPs SinglePvtNoPub -PvtIPNic1 10.120.6.124 -AzExtConfig linuxbackup
.EXAMPLE
\.azdeploy.ps1 -VMName win006 -VMMarketImage w2k12 -ResourceGroupName ResGroup1 -vNetResourceGroupName ResGroup1 -VNetName VNET -depsub1 6 -ConfigIPs SinglePvtNoPub -PvtIPNic1 10.120.6.120 -AvailabilitySet "True"
.EXAMPLE
\.azdeploy.ps1 -VMName win007 -VMMarketImage w2k12 -ResourceGroupName ResGroup1 -vNetResourceGroupName ResGroup1 -VNetName VNET -depsub1 6 -ConfigIPs Single -AddFQDN $True -DNLabel myw2ksrv
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
			Ubuntu 14.04 – ubun
			SQL Server 2016 (on Windows 2012 host) – sql
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
			Bitnami PostGres - postgres
			Oracle Web Logic - weblogic
			Oracle Linux - oracle-linux
			Oracle Standard Edition DB - stddb-oracle
			Oracle Enterprise Edition DB - entdb-oracle
			Puppet Enterprise - puppet
			Splunk Enterprise - splunk
			SharePoint 2013 - share2013
			SharePoint 2016 - share2016
-AzExtConfig <Extension Type>
			access – Adds Azure Access Extension – Added by default during VM creation
			msav – Adds Azure Antivirus Extension
			custScript – Adds Custom Script for Execution (Requires Table Storage Configuration first)
			diag – Adds Azure Diagnostics Extension
			linuxOsPatch - Deploy Latest updates for Linux platforms
			linuxbackup - Deploys Azure Linux bacup Extension
			addDom – Adds Azure Domain Join Extension
			chef – Adds Azure Chef Extension (Requires Chef Certificate and Settings info first)
			winChef – Calls Knife command to install Chef Agent on Server
			linChef – Calls Knife command to install Chef Agent on Server
.LINK
https://github.com/JonosGit/IaaSDeploymentTool
#>

[CmdletBinding()]
Param(
[Parameter(Mandatory=$False,ValueFromPipelinebyPropertyName=$true,Position=1)]
[string]
$vmMarketImage = "pfsense",
[ValidateSet("w2k12","red67","red72","suse","free","ubuntu","centos","w2k16","sql","chef","check","pfsense","lamp","jenkins","nodejs","elastics","postgres","splunk","oracle-linux","puppet","web-logic","stddb-oracle","entdb-oracle")]

[Parameter(Mandatory=$False,ValueFromPipelinebyPropertyName=$true)]
[string]
$NewVnet = "True",

[Parameter(Mandatory=$False,ValueFromPipelinebyPropertyName=$true,Position=0)]
[string]
$VMName = "pfs001",

[Parameter(Mandatory=$False,ValueFromPipelinebyPropertyName=$true,Position=2)]
[string]
$ResourceGroupName = 'ResGrp',

[Parameter(Mandatory=$False,ValueFromPipelinebyPropertyName=$true)]
[string]
$vNetResourceGroupName = $ResourceGroupName,

[Parameter(Mandatory=$False,ValueFromPipelinebyPropertyName=$true)]
[string]
$VNetName = "vnet",

[Parameter(Mandatory=$False,ValueFromPipelinebyPropertyName=$true)]
[ValidateSet("Single","Dual","NoPubDual","PvtDualStat","StatPvtNoPubSingle","PvtSingleStat","StatPvtNoPubDual","NoPubSingle")]
[string]
$ConfigIPs = "Dual",

[Parameter(Mandatory=$False,ValueFromPipelinebyPropertyName=$true)]
[ValidateSet("Standard_A3","Standard_A4","Standard_A2")]
[string]
$VMSize = "Standard_A3",

[Parameter(Mandatory=$False,ValueFromPipelinebyPropertyName=$true)]
[string]
$locadmin = 'localadmin',

[Parameter(Mandatory=$False)]
[string]
$locpassword = 'P@ssW0rd!',

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
$InterfaceName1 =$VMName + "_nic1",

[Parameter(Mandatory=$False)]
[string]
$InterfaceName2 =$VMName + "_nic2",

[Parameter(Mandatory=$False,ValueFromPipelinebyPropertyName=$true)]
[string]
$NSGName = "NSG",

[Parameter(Mandatory=$False,ValueFromPipelinebyPropertyName=$true)]
[ValidateRange(0,7)]
[Int]
$DepSub1 = 0,

[Parameter(Mandatory=$False,ValueFromPipelinebyPropertyName=$true)]
[ValidateRange(0,7)]
[Int]
$DepSub2 = 1,

[Parameter(Mandatory=$False,ValueFromPipelinebyPropertyName=$true)]
[string]
$AvailabilitySet = "False",

[Parameter(Mandatory=$False,ValueFromPipelinebyPropertyName=$true)]
[string]
$AvailSetName = $GenerateName,

[Parameter(Mandatory=$False,ValueFromPipelinebyPropertyName=$true)]
[string]
$DNLabel = 'mytesr1',

[Parameter(Mandatory=$False,ValueFromPipelinebyPropertyName=$true)]
[bool]
$AddFQDN = $False,

[Parameter(Mandatory=$False,ValueFromPipelinebyPropertyName=$true)]
$PvtIPNic1 = '10.120.3.145',

[Parameter(Mandatory=$False,ValueFromPipelinebyPropertyName=$true)]
$PvtIPNic2 = '10.120.1.145',

[Parameter(Mandatory=$False,ValueFromPipelinebyPropertyName=$true)]
[string]
$AzExtConfig = ''

)
# Global
# $ErrorActionPreference = "SilentlyContinue"
$date = Get-Date -UFormat "%Y-%m-%d-%H-%M"
$workfolder = Split-Path $script:MyInvocation.MyCommand.Path
$SecureLocPassword=Convertto-SecureString $locpassword –asplaintext -Force
$Credential1 = New-Object System.Management.Automation.PSCredential ($locadmin,$SecureLocPassword)

#Begin Functions
Function VerifyProfile {
$ProfileFile = "c:\Temp\outlook.json"
$fileexist = Test-Path $ProfileFile
  if($fileexist)
  {Write-Host "Profile Found"
  Select-AzureRmProfile -Path $ProfileFile
  }
  else
  {
  Write-Host "Please enter your credentials"
  Add-AzureRmAccount
  }
}

Function PubIPconfig {
if($AddFQDN)
{
$global:PIp = New-AzureRmPublicIpAddress -Name $InterfaceName1 -ResourceGroupName $ResourceGroupName -Location $Location -AllocationMethod "Dynamic" -DomainNameLabel $DNLabel –Confirm:$false -Force -WarningAction SilentlyContinue
}
else
{
$global:PIp = New-AzureRmPublicIpAddress -Name $InterfaceName1 -ResourceGroupName $ResourceGroupName -Location $Location -AllocationMethod "Dynamic" –Confirm:$false -Force -WarningAction SilentlyContinue
}
}

Function PubDNSconfig {
if($AddFQDN)
{
Write-Host $DNLabel + $Location + ".cloudapp.azure.com"
}
else
{
}
}

Function ConfigNet {
switch ($ConfigIPs)
	{
		"PvtDualStat" {
Write-Host "Dual IP Configuration - Static"
PubIPconfig
$global:VNet = Get-AzureRMVirtualNetwork -Name $VNetName -ResourceGroupName $vNetResourceGroupName | Set-AzureRmVirtualNetwork
$global:Interface1 = New-AzureRmNetworkInterface -Name $InterfaceName1 -ResourceGroupName $ResourceGroupName -Location $Location -SubnetId $VNet.Subnets[$DepSub1].Id -PublicIpAddressId $PIp.Id -PrivateIpAddress $PvtIPNic1 –Confirm:$false -Force -WarningAction SilentlyContinue
$global:Interface2 = New-AzureRmNetworkInterface -Name $InterfaceName2 -ResourceGroupName $ResourceGroupName -Location $Location -SubnetId $VNet.Subnets[$DepSub2].Id -PrivateIpAddress $PvtIPNic2 –Confirm:$false -Force -WarningAction SilentlyContinue
}
		"PvtSingleStat" {
Write-Host "Single IP Configuration - Static"
PubIPconfig
$global:VNet = Get-AzureRMVirtualNetwork -Name $VNetName -ResourceGroupName $vNetResourceGroupName | Set-AzureRmVirtualNetwork
$global:Interface1 = New-AzureRmNetworkInterface -Name $InterfaceName1 -ResourceGroupName $ResourceGroupName -Location $Location -SubnetId $VNet.Subnets[$DepSub1].Id -PublicIpAddressId $PIp.Id -PrivateIpAddress $PvtIPNic1 –Confirm:$false -Force -WarningAction SilentlyContinue
}
		"StatPvtNoPubDual" {
Write-Host "Dual IP Configuration- Static - No Public"
$global:VNet = Get-AzureRMVirtualNetwork -Name $VNetName -ResourceGroupName $vNetResourceGroupName | Set-AzureRmVirtualNetwork
$global:Interface1 = New-AzureRmNetworkInterface -Name $InterfaceName1 -ResourceGroupName $ResourceGroupName -Location $Location -SubnetId $VNet.Subnets[$DepSub1].Id -PrivateIpAddress $PvtIPNic1 –Confirm:$false -Force -WarningAction SilentlyContinue
$global:Interface2 = New-AzureRmNetworkInterface -Name $InterfaceName2 -ResourceGroupName $ResourceGroupName -Location $Location -SubnetId $VNet.Subnets[$DepSub2].Id -PrivateIpAddress $PvtIPNic2 –Confirm:$false -Force -WarningAction SilentlyContinue
}
		"StatPvtNoPubSingle" {
Write-Host "Single IP Configuration - Static - No Public"
$global:VNet = Get-AzureRMVirtualNetwork -Name $VNetName -ResourceGroupName $vNetResourceGroupName | Set-AzureRmVirtualNetwork
$global:Interface1 = New-AzureRmNetworkInterface -Name $InterfaceName1 -ResourceGroupName $ResourceGroupName -Location $Location -SubnetId $VNet.Subnets[$DepSub1].Id -PrivateIpAddress $PvtIPNic1 –Confirm:$false -Force -WarningAction SilentlyContinue
}
		"Single" {
Write-Host "Default Single IP Configuration"
PubIPconfig
$global:VNet = Get-AzureRMVirtualNetwork -Name $VNetName -ResourceGroupName $vNetResourceGroupName | Set-AzureRmVirtualNetwork
$global:Interface1 = New-AzureRmNetworkInterface -Name $InterfaceName1 -ResourceGroupName $ResourceGroupName -Location $Location -SubnetId $VNet.Subnets[$DepSub1].Id -PublicIpAddressId $PIp.Id –Confirm:$false -Force -WarningAction SilentlyContinue
}
		"Dual" {
Write-Host "Default Dual IP Configuration"
PubIPconfig
$global:VNet = Get-AzureRMVirtualNetwork -Name $VNetName -ResourceGroupName $vNetResourceGroupName | Set-AzureRmVirtualNetwork
$global:Interface1 = New-AzureRmNetworkInterface -Name $InterfaceName1 -ResourceGroupName $ResourceGroupName -Location $Location -SubnetId $VNet.Subnets[$DepSub1].Id -PublicIpAddressId $PIp.Id –Confirm:$false -Force -WarningAction SilentlyContinue
$global:Interface2 = New-AzureRmNetworkInterface -Name $InterfaceName2 -ResourceGroupName $ResourceGroupName -Location $Location -SubnetId $VNet.Subnets[$DepSub2].Id –Confirm:$false -Force -WarningAction SilentlyContinue
}
		"NoPubSingle" {
Write-Host "Single IP - No Public"
$global:VNet = Get-AzureRMVirtualNetwork -Name $VNetName -ResourceGroupName $vNetResourceGroupName | Set-AzureRmVirtualNetwork
$global:Interface1 = New-AzureRmNetworkInterface -Name $InterfaceName1 -ResourceGroupName $ResourceGroupName -Location $Location -SubnetId $VNet.Subnets[$DepSub1].Id –Confirm:$false -Force -WarningAction SilentlyContinue
}
		"NoPubDual" {
Write-Host "Dual IP - No Public"
$global:VNet = Get-AzureRMVirtualNetwork -Name $VNetName -ResourceGroupName $vNetResourceGroupName | Set-AzureRmVirtualNetwork
$global:Interface1 = New-AzureRmNetworkInterface -Name $InterfaceName1 -ResourceGroupName $ResourceGroupName -Location $Location -SubnetId $VNet.Subnets[$DepSub1].Id –Confirm:$false -Force -WarningAction SilentlyContinue
$global:Interface2 = New-AzureRmNetworkInterface -Name $InterfaceName2 -ResourceGroupName $ResourceGroupName -Location $Location -SubnetId $VNet.Subnets[$DepSub2].Id –Confirm:$false -Force -WarningAction SilentlyContinue
}
		default{"Nothing matched entry criteria"}
}
}

Function AddNICs {
Write-Host "Adding 2 Network Interface(s) $InterfaceName1 $InterfaceName2" -ForegroundColor White
$global:VirtualMachine = Add-AzureRmVMNetworkInterface -VM $VirtualMachine -Id $global:Interface1.Id -Primary -WarningAction SilentlyContinue
$global:VirtualMachine = Add-AzureRmVMNetworkInterface -VM $VirtualMachine -Id $global:Interface2.Id -WarningAction SilentlyContinue
}

Function AddNIC {
Write-Host "Adding Network Interface $InterfaceName1" -ForegroundColor White
$global:VirtualMachine = Add-AzureRmVMNetworkInterface -VM $VirtualMachine -Id $global:Interface1.Id -Primary -WarningAction SilentlyContinue
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
if($NSGEnabled -eq "True"){
$nic1 = Get-AzureRmNetworkInterface -Name $InterfaceName1 -ResourceGroupName $ResourceGroupName -ErrorAction SilentlyContinue
$nic2 = Get-AzureRmNetworkInterface -Name $InterfaceName2 -ResourceGroupName $ResourceGroupName -ErrorAction SilentlyContinue
if($nic1)
{
$nsg = Get-AzureRmNetworkSecurityGroup -ResourceGroupName $ResourceGroupName -Name $NSGName
$nic = Get-AzureRmNetworkInterface -ResourceGroupName $ResourceGroupName -Name $InterfaceName1
$nic.NetworkSecurityGroup = $nsg
Set-AzureRmNetworkInterface -NetworkInterface $nic | Out-Null
}
if($nic2)
{
$nsg = Get-AzureRmNetworkSecurityGroup -ResourceGroupName $ResourceGroupName -Name $NSGName
$nic = Get-AzureRmNetworkInterface -ResourceGroupName $ResourceGroupName -Name $InterfaceName2
$nic.NetworkSecurityGroup = $nsg
Set-AzureRmNetworkInterface -NetworkInterface $nic | Out-Null
}
}
}
Function SelectNicDescrtipt {
if($ConfigIPs-EQ "Dual"){Write-Host "Dual Pvt IP & Public IP will be created" }
	elseif($ConfigIPs-EQ "Single"){Write-Host "Single Pvt IP & Public IP will be created" }
			elseif($ConfigIPs-EQ "PvtDualStat"){Write-Host "Dual Static Pvt IP & Public IP will be created" }
				  elseif($ConfigIPs-EQ"PvtSingleStat"){Write-Host "Single Static Pvt IP & Public IP will be created" }
						 elseif($ConfigIPs-EQ "SinglePvtNoPub"){Write-Host "Single Static Pvt IP & No Public IP" }
							   elseif($ConfigIPs-EQ "StatPvtNoPubDual"){Write-Host "Dual Static Pvt IP & No Public IP"}
										elseif($ConfigIPs-EQ "StatPvtNoPubSingle"){Write-Host "Single Static Pvt IP & No Public IP"}
											   elseif($ConfigIPs-EQ "NoPubSingle"){Write-Host "Single Pvt IP & No Public IP"}
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
	Register-AzureRmResourceProvider -ProviderNamespace $ResourceProviderNamespace –Confirm:$false -Force -WarningAction SilentlyContinue | Out-Null;
}

Function AvailSet {
 try {
 If ($AvailabilitySet -eq "True" )
 {
 Write-Host "Availability Set creation in process.." -ForegroundColor White
New-AzureRmAvailabilitySet -ResourceGroupName $ResourceGroupName -Name $AvailSetName -Location $Location -WarningAction SilentlyContinue | Out-Null
$AvailabilitySet = (Get-AzureRmAvailabilitySet -ResourceGroupName $ResourceGroupName -Name $AvailSetName).Id
$global:VirtualMachine = New-AzureRmVMConfig -VMName $VMName -VMSize $VMSize -AvailabilitySetID $AvailabilitySet -WarningAction SilentlyContinue
Write-Host "Availability Set has been created" -ForegroundColor White
}
else
{
Write-Host "Skipping Availability Set creation" -ForegroundColor White
$global:VirtualMachine = New-AzureRmVMConfig -VMName $VMName -VMSize $VMSize -WarningAction SilentlyContinue
}
	}

catch {
	Write-Host -foregroundcolor Red `
	"$($_.Exception.Message)"; `
	continue
}
 }

Function AddDiskImage {
Write-Host "Completing image creation..." -ForegroundColor White
$global:osDiskCaching = "ReadWrite"
$global:OSDiskName = $VMName + "OSDisk"
$global:OSDiskUri = $StorageAccount.PrimaryEndpoints.Blob.ToString() + "vhds/" + $OSDiskName + ".vhd"
$global:VirtualMachine = Set-AzureRmVMOSDisk -VM $VirtualMachine -Name $OSDiskName -VhdUri $OSDiskUri -CreateOption "FromImage" -Caching $osDiskCaching -WarningAction SilentlyContinue
}

function Provvms {
	$ProvisionVMs = @($VirtualMachine);
try {
   foreach($provisionvm in $ProvisionVMs) {
New-AzureRmVM -ResourceGroupName $ResourceGroupName -Location $Location -VM $VirtualMachine –Confirm:$false -WarningAction SilentlyContinue | Out-Null
Write-Host "Completed creation of new VM" -ForegroundColor White
						}
	}

catch {
	Write-Host -foregroundcolor Red `
	"$($_.Exception.Message)"; `
	continue
}
}
Function MakeImagePlanInfo_Bitnami_Lamp {
param(
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
}
Function MakeImagePlanInfo_Bitnami_elastic {
param(
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
Function MakeImagePlanInfo_Bitnami_mongodb {
param(
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
}
Function MakeImagePlanInfo_Bitnami_nginxstack {
param(
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
}
Function MakeImagePlanInfo_Bitnami_nodejs {
param(
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
}
Function MakeImagePlanInfo_Bitnami_postgresql {
param(
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
}
Function MakeImagePlanInfo_Oracle_linux {
param(
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
}
Function MakeImagePlanInfo_Oracle_weblogic {
param(
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
}
Function MakeImagePlanInfo_Oracle_EntDB {
param(
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
}
Function MakeImagePlanInfo_Oracle_StdDB {
param(
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
}
Function MakeImagePlanInfo_puppet_puppetent {
param(
[string]$Publisher = 'Puppet',
[string]$offer = 'puppet-enterprise',
[string]$Skus = '2016-1',
[string]$version = 'latest',
[string]$Product = '2016-1',
[string]$name = 'puppet-enterprise'
)
Write-Host "Image Creation in Process - Plan Info - Puppet Enterprise" -ForegroundColor White
Write-Host 'Publisher:'$Publisher 'Offer:'$offer 'Sku:'$Skus 'Version:'$version
$global:VirtualMachine= Set-AzureRmVMPlan -VM $VirtualMachine -Name $name -Publisher $Publisher -Product $Product
$global:VirtualMachine = Set-AzureRmVMOperatingSystem -VM $VirtualMachine -linux -ComputerName $VMName -Credential $Credential1
$global:VirtualMachine = Set-AzureRmVMSourceImage -VM $VirtualMachine -PublisherName $Publisher -Offer $offer -Skus $Skus -Version $version
}
Function MakeImagePlanInfo_splunk {
param(
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
}

Function MakeImagePlanInfo_Pfsense {
param(
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
}

Function MakeImagePlanInfo_Checkpoint {
param(
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
}

Function MakeImagePlanInfo_Chef {
param(
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
}

Function MakeImageNoPlanInfo_RedHat67 {
param(
[string]$Publisher = "Redhat",
[string]$offer = "rhel",
[string]$Skus = "6.7",
[string]$version = "latest"
)
Write-Host "Image Creation in Process - No Plan Info - RedHat 6.7" -ForegroundColor White
Write-Host 'Publisher:'$Publisher 'Offer:'$offer 'Sku:'$Skus 'Version:'$version
$global:VirtualMachine = Set-AzureRmVMOperatingSystem -VM $VirtualMachine -linux -ComputerName $VMName -Credential $Credential1
$global:VirtualMachine = Set-AzureRmVMSourceImage -VM $VirtualMachine -PublisherName $Publisher -Offer $offer -Skus $Skus -Version $version
}

Function MakeImageNoPlanInfo_RedHat72 {
param(
[string]$Publisher = "Redhat",
[string]$offer = "rhel",
[string]$Skus = "7.2",
[string]$version = "latest"
)
Write-Host "Image Creation in Process - No Plan Info - Redhat 7.2" -ForegroundColor White
Write-Host 'Publisher:'$Publisher 'Offer:'$offer 'Sku:'$Skus 'Version:'$version
$global:VirtualMachine = Set-AzureRmVMOperatingSystem -VM $VirtualMachine -linux -ComputerName $VMName -Credential $Credential1
$global:VirtualMachine = Set-AzureRmVMSourceImage -VM $VirtualMachine -PublisherName $Publisher -Offer $offer -Skus $Skus -Version $version
}

Function MakeImageNoPlanInfo_FreeBsd {
param(
[string]$Publisher = "MicrosoftOSTC",
[string]$offer = "FreeBSD",
[string]$Skus = "10.3",
[string]$version = "latest"
)
Write-Host "Image Creation in Process - No Plan Info - FreeBsd" -ForegroundColor White
Write-Host 'Publisher:'$Publisher 'Offer:'$offer 'Sku:'$Skus 'Version:'$version
$global:VirtualMachine = Set-AzureRmVMOperatingSystem -VM $VirtualMachine -linux -ComputerName $VMName -Credential $Credential1
$global:VirtualMachine = Set-AzureRmVMSourceImage -VM $VirtualMachine -PublisherName $Publisher -Offer $offer -Skus $Skus -Version $version
}

Function MakeImageNoPlanInfo_CentOs {
param(
[string]$Publisher = "OpenLogic",
[string]$offer = "Centos",
[string]$Skus = "7.2",
[string]$version = "latest"

)
Write-Host "Image Creation in Process - No Plan Info - CentOs" -ForegroundColor White
Write-Host 'Publisher:'$Publisher 'Offer:'$offer 'Sku:'$Skus 'Version:'$version
$global:VirtualMachine = Set-AzureRmVMOperatingSystem -VM $VirtualMachine -linux -ComputerName $VMName -Credential $Credential1
$global:VirtualMachine = Set-AzureRmVMSourceImage -VM $VirtualMachine -PublisherName $Publisher -Offer $offer -Skus $Skus -Version $version
}

Function MakeImageNoPlanInfo_Suse {
param(
[string]$Publisher = "Suse",
[string]$offer = "openSUSE",
[string]$Skus = "13.2",
[string]$version = "latest"

)
Write-Host "Image Creation in Process - No Plan Info - SUSE" -ForegroundColor White
Write-Host 'Publisher:'$Publisher 'Offer:'$offer 'Sku:'$Skus 'Version:'$version
$global:VirtualMachine = Set-AzureRmVMOperatingSystem -VM $VirtualMachine -linux -ComputerName $VMName -Credential $Credential1
$global:VirtualMachine = Set-AzureRmVMSourceImage -VM $VirtualMachine -PublisherName $Publisher -Offer $offer -Skus $Skus -Version $version
}

Function MakeImageNoPlanInfo_Chef {
param(
[string]$Publisher = 'chef-software',
[string]$offer = 'chef-server',
[string]$Skus = 'azure_marketplace_100',
[string]$version = 'latest',
[string]$Product = 'chef-server',
[string]$name = 'azure_marketplace_100'
)
Write-Host "Image Creation in Process - Plan Info - Chef" -ForegroundColor White
Write-Host 'Publisher:'$Publisher 'Offer:'$offer 'Sku:'$Skus 'Version:'$version
$global:VirtualMachine= Set-AzureRmVMPlan -VM $VirtualMachine -Name $name -Publisher $Publisher -Product $Product
$global:VirtualMachine = Set-AzureRmVMOperatingSystem -VM $VirtualMachine -linux -ComputerName $VMName -Credential $Credential1
$global:VirtualMachine = Set-AzureRmVMSourceImage -VM $VirtualMachine -PublisherName $Publisher -Offer $offer -Skus $Skus -Version $version
}

Function MakeImageNoPlanInfo_w2k12 {
param(
[string]$Publisher = "MicrosoftWindowsServer",
[string]$offer = "WindowsServer",
[string]$Skus = "2012-R2-Datacenter",
[string]$version = "latest"
)
Write-Host "Image Creation in Process - No Plan Info - W2k12 server" -ForegroundColor White
Write-Host 'Publisher:'$Publisher 'Offer:'$offer 'Sku:'$Skus 'Version:'$version
$global:VirtualMachine = Set-AzureRmVMOperatingSystem -VM $VirtualMachine -Windows -ComputerName $VMName -Credential $Credential1 -ProvisionVMAgent -EnableAutoUpdate -WinRMHttp -Verbose
$global:VirtualMachine = Set-AzureRmVMSourceImage -VM $VirtualMachine -PublisherName $Publisher -Offer $offer -Skus $Skus -Version $version
}

Function MakeImageNoPlanInfo_w2k8 {
param(
[string]$Publisher = "MicrosoftWindowsServer",
[string]$offer = "WindowsServer",
[string]$Skus = "2008-R2-SP1",
[string]$version = "latest"
)
Write-Host "Image Creation in Process - No Plan Info - W2k8 server" -ForegroundColor White
Write-Host 'Publisher:'$Publisher 'Offer:'$offer 'Sku:'$Skus 'Version:'$version
$global:VirtualMachine = Set-AzureRmVMOperatingSystem -VM $VirtualMachine -Windows -ComputerName $VMName -Credential $Credential1 -ProvisionVMAgent -EnableAutoUpdate -WinRMHttp -Verbose
$global:VirtualMachine = Set-AzureRmVMSourceImage -VM $VirtualMachine -PublisherName $Publisher -Offer $offer -Skus $Skus -Version $version
}

Function MakeImageNoPlanInfo_SharePoint2k13 {
param(
[string]$Publisher = "MicrosoftSharePoint",
[string]$offer = "MicrosoftSharePointServer",
[string]$Skus = "2013",
[string]$version = "latest"
)
Write-Host "Image Creation in Process - No Plan Info - SharePoint 2013 server" -ForegroundColor White
Write-Host 'Publisher:'$Publisher 'Offer:'$offer 'Sku:'$Skus 'Version:'$version
$global:VirtualMachine = Set-AzureRmVMOperatingSystem -VM $VirtualMachine -Windows -ComputerName $VMName -Credential $Credential1 -ProvisionVMAgent -EnableAutoUpdate -WinRMHttp -Verbose
$global:VirtualMachine = Set-AzureRmVMSourceImage -VM $VirtualMachine -PublisherName $Publisher -Offer $offer -Skus $Skus -Version $version
}

Function MakeImageNoPlanInfo_SharePoint2k16 {
param(
[string]$Publisher = "MicrosoftSharePoint",
[string]$offer = "MicrosoftSharePointServer",
[string]$Skus = "2016",
[string]$version = "latest"
)
Write-Host "Image Creation in Process - No Plan Info - SharePoint 2016 server" -ForegroundColor White
Write-Host 'Publisher:'$Publisher 'Offer:'$offer 'Sku:'$Skus 'Version:'$version
$global:VirtualMachine = Set-AzureRmVMOperatingSystem -VM $VirtualMachine -Windows -ComputerName $VMName -Credential $Credential1 -ProvisionVMAgent -EnableAutoUpdate -WinRMHttp -Verbose
$global:VirtualMachine = Set-AzureRmVMSourceImage -VM $VirtualMachine -PublisherName $Publisher -Offer $offer -Skus $Skus -Version $version
}

Function MakeImageNoPlanInfo_w2k16 {
param(
[string]$Publisher = "MicrosoftWindowsServer",
[string]$offer = "WindowsServer",
[string]$Skus = "Windows-Server-Technical-Preview",
[string]$version = "latest"
)
Write-Host "Image Creation in Process - No Plan Info - W2k16 server" -ForegroundColor White
Write-Host 'Publisher:'$Publisher 'Offer:'$offer 'Sku:'$Skus 'Version:'$version
$global:VirtualMachine = Set-AzureRmVMOperatingSystem -VM $VirtualMachine -Windows -ComputerName $VMName -Credential $Credential1 -ProvisionVMAgent -EnableAutoUpdate -WinRMHttp -Verbose
$global:VirtualMachine = Set-AzureRmVMSourceImage -VM $VirtualMachine -PublisherName $Publisher -Offer $offer -Skus $Skus -Version $version
}

Function MakeImageNoPlanInfo_sql2k16 {
param(
[string]$Publisher = "MicrosoftSQLServer",
[string]$offer = "SQL2016-WS2012R2",
[string]$Skus = "Enterprise",
[string]$version = "latest"
)
Write-Host "Image Creation in Process - No Plan Info - SQL 2016" -ForegroundColor White
Write-Host $Publisher $offer $Skus $version
$global:VirtualMachine = Set-AzureRmVMOperatingSystem -VM $VirtualMachine -Windows -ComputerName $VMName -Credential $Credential1 -ProvisionVMAgent -EnableAutoUpdate -WinRMHttp -Verbose
$global:VirtualMachine = Set-AzureRmVMSourceImage -VM $VirtualMachine -PublisherName $Publisher -Offer $offer -Skus $Skus -Version $version
}

Function ProvisionNet {
Write-Host "Network Preparation in Process.."
$subnet1 = New-AzureRmVirtualNetworkSubnetConfig -AddressPrefix 10.120.0.0/24 -Name perimeter
$subnet2 = New-AzureRmVirtualNetworkSubnetConfig -AddressPrefix 10.120.1.0/24 -Name web
$subnet3 = New-AzureRmVirtualNetworkSubnetConfig -AddressPrefix 10.120.2.0/24 -Name intake
$subnet4 = New-AzureRmVirtualNetworkSubnetConfig -AddressPrefix 10.120.3.0/24 -Name data
$subnet5 = New-AzureRmVirtualNetworkSubnetConfig -AddressPrefix 10.120.4.0/24 -Name monitoring
$subnet6 = New-AzureRmVirtualNetworkSubnetConfig -AddressPrefix 10.120.5.0/24 -Name analytics
$subnet7 = New-AzureRmVirtualNetworkSubnetConfig -AddressPrefix 10.120.6.0/24 -Name backup
$subnet8 = New-AzureRmVirtualNetworkSubnetConfig -AddressPrefix 10.120.7.0/24 -Name management
$subnet9 = New-AzureRmVirtualNetworkSubnetConfig -AddressPrefix 10.120.8.0/24 -Name gatewaysubnet
New-AzureRmVirtualNetwork -Location $Location -Name $VNetName -ResourceGroupName $vNetResourceGroupName -AddressPrefix '10.120.0.0/21' -Subnet $subnet1,$subnet2,$subnet3,$subnet4,$subnet5,$subnet6,$subnet7,$subnet8 –Confirm:$false -Force -WarningAction SilentlyContinue | Out-Null
Get-AzureRmVirtualNetwork -Name $VNetName -ResourceGroupName $vNetResourceGroupName | Get-AzureRmVirtualNetworkSubnetConfig -WarningAction SilentlyContinue | Out-Null
Write-Host "Network Preparation completed" -ForegroundColor White
}
# End of Provision VNET Function

Function CreateNSG {
Write-Host "Network Security Group Preparation in Process.."
$httprule = New-AzureRmNetworkSecurityRuleConfig -Name "FrontEnd_HTTP" -Description "HTTP Exception for Web frontends" -Protocol Tcp -SourcePortRange "80" -DestinationPortRange "80" -SourceAddressPrefix "*" -DestinationAddressPrefix "10.120.0.0/21" -Access Allow -Direction Inbound -Priority 200
$httpsrule = New-AzureRmNetworkSecurityRuleConfig -Name "FrontEnd_HTTPS" -Description "HTTPS Exception for Web frontends" -Protocol Tcp -SourcePortRange "443" -DestinationPortRange "443" -SourceAddressPrefix "*" -DestinationAddressPrefix "10.120.0.0/21" -Access Allow -Direction Inbound -Priority 201
$sshrule = New-AzureRmNetworkSecurityRuleConfig -Name "FrontEnd_SSH" -Description "SSH Exception for Web frontends" -Protocol Tcp -SourcePortRange "22" -DestinationPortRange "22" -SourceAddressPrefix "*" -DestinationAddressPrefix "10.120.0.0/21" -Access Allow -Direction Inbound ` -Priority 203
$nsg = New-AzureRmNetworkSecurityGroup -ResourceGroupName $vNetResourceGroupName -Location $Location -Name $NSGName -SecurityRules $httprule,$httpsrule, $sshrule –Confirm:$false -Force -WarningAction SilentlyContinue | Out-Null
Get-AzureRmNetworkSecurityGroup -Name $NSGName -ResourceGroupName $vNetResourceGroupName -WarningAction SilentlyContinue | Out-Null
Write-Host "Network Security Group creation completed" -ForegroundColor White
}
# End of Provision Network Security Groups Function

Function SubnetMatch {
	Param(
		[INT]$Subnet
	)
switch ($Subnet)
{
0 {Write-Host "Deploying to Subnet 10.120.0.0/24"}
1 {Write-Host "Deploying to Subnet 10.120.1.0/24"}
2 {Write-Host "Deploying to Subnet 10.120.2.0/24"}
3 {Write-Host "Deploying to Subnet 10.120.3.0/24"}
4 {Write-Host "Deploying to Subnet 10.120.4.0/24"}
5 {Write-Host "Deploying to Subnet 10.120.5.0/24"}
6 {Write-Host "Deploying to Subnet 10.120.6.0/24"}
7 {Write-Host "Deploying to Subnet 10.120.7.0/24"}
8 {Write-Host "Deploying to Subnet 10.120.8.0/24"}
default {No Subnet Found}
}
}

Function WriteConfig {
Write-Host "                                                               "
$time = " Start Time " + (Get-Date -UFormat "%d-%m-%Y %H:%M:%S")
Write-Host -------------- $time --------------- -ForegroundColor Cyan
Write-Host "Using configuration:"

Write-Host "VM Name: $VMName " -ForegroundColor White
Write-Host "Resource Group Name: $ResourceGroupName"
Write-Host "Server Type: $vmMarketImage"
Write-Host "VNET Name: $vNetName"
Write-Host "VNET Resource Group Name: $vNetResourceGroupName"
Write-Host "Storage Account Name:  $StorageName"
SelectNicDescrtipt
If ($ConfigIPs -eq "StatPvtNoPubSingle")
{ Write-Host "Public Ip Will not be created" -ForegroundColor White
Write-Host "Nic1: $PvtIPNic1"
SubnetMatch $DepSub1
}
If ($ConfigIPs -eq "StatPvtNoPubDual")
{ Write-Host "Public Ip Will not be created" -ForegroundColor White
Write-Host "Nic1: $PvtIPNic1"
Write-Host "Nic2: $PvtIPNic2"
SubnetMatch $DepSub1
SubnetMatch $DepSub2
}
If ($ConfigIPs -eq "Single")
{ Write-Host "Public Ip Will be created"
SubnetMatch $DepSub1
}

If ($ConfigIPs -eq "Dual")
{ Write-Host "Public Ip Will be created"
SubnetMatch $DepSub1
SubnetMatch $DepSub2
}
If ($ConfigIPs -eq "PvtSingleStat")
{ Write-Host "Public Ip Will be created"
SubnetMatch $DepSub1
Write-Host "Nic1: $PvtIPNic1"
}
If ($ConfigIPs -eq "PvtDualStat")
{ Write-Host "Public Ip Will be created"
SubnetMatch $DepSub1
SubnetMatch $DepSub2
Write-Host "Nic1: $PvtIPNic1"
Write-Host "Nic2: $PvtIPNic2"
}
if($AzExtConfig) {
Write-Host "Extension selected for deployment: $AzExtConfig "
}
if($AvailabilitySet -eq "True") {
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

Function WriteResults {
Write-Host "                                                               "
Write-Host "--------------------------------------------------------------" -ForegroundColor Cyan
Write-Host "                                                               "
Write-Host "Completed Deployment of:"  -ForegroundColor Cyan
Write-Host "VM Name: $VMName " -ForegroundColor White
Write-Host "Resource Group Name: $ResourceGroupName"
Write-Host "Server Type: $vmMarketImage"
Write-Host "VNET Resource Group Name: $vNetResourceGroupName" -ForegroundColor White
Write-Host "VNET Name: $VNetName" -ForegroundColor White
Write-Host "Storage Account Name:  $StorageName"
SelectNicDescrtipt

if($AvailabilitySet -eq "True") {
Write-Host "Availability Set created"
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
}

Function EndState {
Write-Host "                                                               "
Write-Host "Private Network Interfaces for $ResourceGroupName"
$vms = get-azurermvm -ResourceGroupName $ResourceGroupName
$nics = get-azurermnetworkinterface -ResourceGroupName $ResourceGroupName | where VirtualMachine -NE $null #skip Nics with no VM
foreach($nic in $nics)
{
	$vm = $vms | where-object -Property Id -EQ $nic.VirtualMachine.id
	$prv =  $nic.IpConfigurations | select-object -ExpandProperty PrivateIpAddress
	$alloc =  $nic.IpConfigurations | select-object -ExpandProperty PrivateIpAllocationMethod
	Write-Output "$($vm.Name) : $prv , $alloc" | Format-Table
}
Write-Host "Public Network Interfaces for $ResourceGroupName"
$pubip =  Get-AzureRmPublicIpAddress -Name $InterfaceName1 -ResourceGroupName $ResourceGroupName -ErrorAction SilentlyContinue
if ($pubip)
{
Get-AzureRmPublicIpAddress -ResourceGroupName $ResourceGroupName | ft "Name","IpAddress"
Get-AzureRmPublicIpAddress -ExpandResource IPConfiguration -Name $InterfaceName1 -ResourceGroupName $ResourceGroupName | select-object -ExpandProperty DNSSettings | select-object -ExpandProperty FQDN
}
Write-Host "                                                               "
}

Function ProvisionRGs {
	Param(
		[string]$ResourceGroupName
	)
	$resourceGroup = Get-AzureRmResourceGroup -Name $ResourceGroupName -ErrorAction SilentlyContinue -WarningAction SilentlyContinue | Out-Null
if(!$resourceGroup)
{
#	Write-Host "Resource group '$ResourceGroupName' does not exist. Creating...";
	if(!$Location) {
		$Location = Read-Host "resourceGroupLocation";
	}
New-AzureRmResourceGroup -Name $resourceGroupName -Location $Location –Confirm:$false -force -WarningAction SilentlyContinue | Out-Null
}
else{
	Write-Host "Using existing resource group $ResourceGroupName";
	Get-AzureRmResourceGroup -Name $ResourceGroupName -ErrorAction SilentlyContinue -WarningAction SilentlyContinue | Out-Null }
}

Function ProvisionResGrp
{
	Param(
		[string]$ResourceGroupName
	)
New-AzureRmResourceGroup -Name $resourceGroupName -Location $Location –Confirm:$false -force -WarningAction SilentlyContinue | Out-Null
}

Function OutFile {
$Output | Tee-Object –FilePath "c:\test\AllSystemFiles.txt" –Append
}

Function CreateStorage {
Write-Host "Starting Storage Creation.."
$Global:StorageAccount = New-AzureRmStorageAccount -ResourceGroupName $ResourceGroupName -Name $StorageName.ToLower() -Type $StorageType -Location $Location -ErrorAction Stop -WarningAction SilentlyContinue
Write-Host "Completed Storage Creation" -ForegroundColor White
} # Creates Storage

Function ImageConfig {
switch -Wildcard ($vmMarketImage)
	{
		"*pf*" {
ConfigNet  #Sets network connection info
MakeImagePlanInfo_Pfsense # Begins Image Creation
ConfigSet # Adds Network Interfaces
AddDiskImage # Completes Image Creation
}
		"*free*" {
ConfigNet  #Sets network connection info
MakeImageNoPlanInfo_FreeBsd  # Begins Image Creation
ConfigSet # Adds Network Interfaces
AddDiskImage # Completes Image Creation
}
		"*red72*" {
ConfigNet  #Sets network connection info
MakeImageNoPlanInfo_RedHat72  # Begins Image Creation
ConfigSet # Adds Network Interfaces
AddDiskImage # Completes Image Creation
}
		"*red67*" {
ConfigNet  #Sets network connection info
MakeImageNoPlanInfo_RedHat67  # Begins Image Creation
ConfigSet # Adds Network Interfaces
AddDiskImage # Completes Image Creation
}
		"*w2k12*" {
ConfigNet  #Sets network connection info
MakeImageNoPlanInfo_w2k12  # Begins Image Creation
ConfigSet # Adds Network Interfaces
AddDiskImage # Completes Image Creation
}
		"*sql*" {
ConfigNet  #Sets network connection info
MakeImageNoPlanInfo_sql2k16  # Begins Image Creation
 ConfigSet # Adds Network Interfaces
AddDiskImage # Completes Image Creation
}
		"*check*" {
ConfigNet  #Sets network connection info
MakeImagePlanInfo_Checkpoint  # Begins Image Creation
ConfigSet # Adds Network Interfaces
AddDiskImage # Completes Image Creation
}
		"*cent*" {
ConfigNet  #Sets network connection info
MakeImageNoPlanInfo_CentOs  # Begins Image Creation
ConfigSet # Adds Network Interfaces
AddDiskImage # Completes Image Creation
}
		"*Suse*" {
ConfigNet  #Sets network connection info
MakeImageNoPlanInfo_Suse  # Begins Image Creation
ConfigSet # Adds Network Interfaces
AddDiskImage # Completes Image Creation
}
		"*w2k8*" {
ConfigNet  #Sets network connection info
MakeImageNoPlanInfo_w2k8  # Begins Image Creation
ConfigSet # Adds Network Interfaces
AddDiskImage # Completes Image Creation
}
		"*w2k16*" {
ConfigNet  #Sets network connection info
MakeImageNoPlanInfo_w2k16  # Begins Image Creation
ConfigSet # Adds Network Interfaces
AddDiskImage # Completes Image Creation
}
		"*chef*" {
ConfigNet  #Sets network connection info
MakeImagePlanInfo_Chef  # Begins Image Creation
ConfigSet # Adds Network Interfaces
AddDiskImage # Completes Image Creation
}
		"*lamp*" {
ConfigNet  #Sets network connection info
MakeImagePlanInfo_Bitnami_Lamp # Begins Image Creation
ConfigSet # Adds Network Interfaces
AddDiskImage # Completes Image Creation
}
		"*mongodb*" {
ConfigNet  #Sets network connection info
MakeImagePlanInfo_Bitnami_mongodb # Begins Image Creation
ConfigSet # Adds Network Interfaces
AddDiskImage # Completes Image Creation
}
		"*mysql*" {
ConfigNet  #Sets network connection info
MakeImagePlanInfo_Bitnami_mysql # Begins Image Creation
ConfigSet # Adds Network Interfaces
AddDiskImage # Completes Image Creation
}
		"*elastics*" {
ConfigNet  #Sets network connection info
MakeImagePlanInfo_Bitnami_elastic # Begins Image Creation
ConfigSet # Adds Network Interfaces
AddDiskImage # Completes Image Creation
}
		"*nodejs*" {
ConfigNet  #Sets network connection info
MakeImagePlanInfo_Bitnami_nodejs # Begins Image Creation
ConfigSet # Adds Network Interfaces
AddDiskImage # Completes Image Creation
}
		"*nginxstack*" {
ConfigNet  #Sets network connection info
MakeImagePlanInfo_Bitnami_nginxstack # Begins Image Creation
ConfigSet # Adds Network Interfaces
AddDiskImage # Completes Image Creation
}
		"*postgresql*" {
ConfigNet  #Sets network connection info
MakeImagePlanInfo_Bitnami_postgresql # Begins Image Creation
ConfigSet # Adds Network Interfaces
AddDiskImage # Completes Image Creation
}
		"*oracle-linux*" {
ConfigNet  #Sets network connection info
MakeImagePlanInfo_Oracle_linux # Begins Image Creation
ConfigSet # Adds Network Interfaces
AddDiskImage # Completes Image Creation
}
		"*web-logic*" {
ConfigNet  #Sets network connection info
MakeImagePlanInfo_Oracle_weblogic # Begins Image Creation
ConfigSet # Adds Network Interfaces
AddDiskImage # Completes Image Creation
}
		"*entdb-oracle*" {
ConfigNet  #Sets network connection info
MakeImagePlanInfo_Oracle_EntDB  # Begins Image Creation
ConfigSet # Adds Network Interfaces
AddDiskImage # Completes Image Creation
}
		"*stddb-oracle*" {
ConfigNet  #Sets network connection info
MakeImagePlanInfo_Oracle_StdDB # Begins Image Creation
ConfigSet # Adds Network Interfaces
AddDiskImage # Completes Image Creation
}
		"*puppet*" {
ConfigNet  #Sets network connection info
MakeImagePlanInfo_puppet_puppetent # Begins Image Creation
ConfigSet # Adds Network Interfaces
AddDiskImage # Completes Image Creation
}
		"*splunk*" {
ConfigNet  #Sets network connection info
MakeImagePlanInfo_splunk # Begins Image Creation
ConfigSet # Adds Network Interfaces
AddDiskImage # Completes Image Creation
}
		"*share2013*" {
ConfigNet  #Sets network connection info
MakeImageNoPlanInfo_SharePoint2k13 # Begins Image Creation
ConfigSet # Adds Network Interfaces
AddDiskImage # Completes Image Creation
}
		"*share2016*" {
ConfigNet  #Sets network connection info
MakeImageNoPlanInfo_SharePoint2k16 # Begins Image Creation
ConfigSet # Adds Network Interfaces
AddDiskImage # Completes Image Creation
}
		"*jenkins*" {
ConfigNet  #Sets network connection info
MakeImagePlanInfo_Bitnami_jenkins # Begins Image Creation
ConfigSet # Adds Network Interfaces
AddDiskImage # Completes Image Creation
}
		default{"An unsupported image was referenced"}
	}
}

Function InstallExt {
switch ($AzExtConfig)
	{
		"access" {
Write-Host "VM Access Agent VM Image Preparation in Process"
Set-AzureRmVMAccessExtension -ResourceGroupName $ResourceGroupName -VMName $VMName -Name "VMAccess" -ExtensionType "VMAccessAgent" -Publisher "Microsoft.Compute" -typeHandlerVersion "2.0" -Location $Location -Verbose
Get-AzureRmVMExtension -ResourceGroupName $ResourceGroupName -VMName $VMName -Name "VMAccess"
}
		"msav" {
Write-Host "MSAV Agent VM Image Preparation in Process"
Set-AzureRmVMExtension  -ResourceGroupName $ResourceGroupName -VMName $VMName -Name "MSAVExtension" -ExtensionType "IaaSAntimalware" -Publisher "Microsoft.Azure.Security" -typeHandlerVersion 1.4 -Location $Location
Get-AzureRmVMExtension -ResourceGroupName $ResourceGroupName -VMName $VMName -Name "MSAVExtension" -Status
}
		"custScript" {
Write-Host "Updating server with custom script"
Set-AzureRmVMCustomScriptExtension -Name "CustScript" -ResourceGroupName $ResourceGroupName -Run "CustScript.ps1" -VMName $VMName -FileUri $StorageName -Location $Location -TypeHandlerVersion "1.1"
Get-AzureRmVMCustomScriptExtension -ResourceGroupName $ResourceGroupName -Name "CustScript"
}
		"diag" {
Write-Host "Adding Azure Enhanced Diagnostics"
Set-AzureRmVMAEMExtension -ResourceGroupName $ResourceGroupName -VMName $VMName -WADStorageAccountName $StorageName -InformationAction SilentlyContinue -WarningAction SilentlyContinue | Out-Null
Get-AzureRmVMAEMExtension -ResourceGroupName $ResourceGroupName -VMName $VMName | Out-Null
}
		"domjoin" {
Write-Host "Domain Join active"
Set-AzureRmVMADDomainExtension -DomainName $DomName -ResourceGroupName $ResourceGroupName -VMName $VMName -Location $Location -Name DomJoin -WarningAction SilentlyContinue
Get-AzureRmVMADDomainExtension -ResourceGroupName $ResourceGroupName -VMName $VMName
		}
		"linuxOsPatch" {
Write-Host "Adding Azure OS Patching Linux"
Set-AzureRmVMExtension -VMName $VMName -ResourceGroupName $ResourceGroupName -Location $Location -Name "OSPatch" -ExtensionType "OSPatchingForLinux" -Publisher "Microsoft.OSTCExtensions" -typeHandlerVersion "2.0" -InformationAction SilentlyContinue -ForceRerun -Verbose
Get-AzureRmVMExtension -ResourceGroupName $ResourceGroupName -VMName $VMName -Name "OSPatch"
		}
		"linuxbackup" {
Write-Host "Adding Linux VMBackup"
Set-AzureRmVMBackupExtension -VMName $VMName -ResourceGroupName $ResourceGroupName -Location $Location -Name "VMBackup" -Tag "OSBackup" -WarningAction SilentlyContinue
Get-AzureRmVMBackupExtension -ResourceGroupName $ResourceGroupName -VMName $VMName -Name "VMBackup"
		}
		"chefAgent" {
Write-Host "Adding Chef Agent"
Set-AzureRmVMExtension -ResourceGroupName $ResourceGroupName -VMName $VMName -Name "ChefStrap" -ExtensionType "ChefClient" -Publisher "Chef.Bootstrap.WindowsAzure" -typeHandlerVersion "1210.12" -Location $Location -Verbose -ProtectedSettingString -SettingString
Get-AzureRmVMExtension -ResourceGroupName $ResourceGroupName -VMName $VMName -Name "ChefStrap"
		}
		"WinBootStChef" {
Write-Host "Bootstrapping Chef Agent"
knife bootstrap windows winrm $BootIp --winrm-user $localadmin --winrm-password $locpassword --node-name $VMName --Install-as-service
		}
		"linBootStChef" {
Write-Host "Bootstrapping Chef Agent"
knife bootstrap $BootIp --node-name $VMName --ssh-user localadmin --ssh-password $locpassword --sudo --use-sudo-password --verbose --yes
		}
		default{"An unsupported Extension command was used"
break
}
	}
} # Deploys Azure Extensions

Function CheckOrphns {
$extvm = Get-AzureRmVm -Name $VMName -ResourceGroupName $ResourceGroupName -ErrorAction SilentlyContinue
$nic1 = Get-AzureRmNetworkInterface -Name $InterfaceName1 -ResourceGroupName $ResourceGroupName -ErrorAction SilentlyContinue
$nic2 = Get-AzureRmNetworkInterface -Name $InterfaceName2 -ResourceGroupName $ResourceGroupName -ErrorAction SilentlyContinue
$pubip =  Get-AzureRmPublicIpAddress -Name $InterfaceName1 -ResourceGroupName $ResourceGroupName -ErrorAction SilentlyContinue

if($extvm)
{ Write-Host "Host VM Found, please use a different VMName for Provisioning or manually delete the existing VM" -ForegroundColor Red
 Start-sleep 10
 exit   }
else {if($nic1)
{ Write-Host "Nic1 already Exists, removing orphan" -ForegroundColor DarkYellow
Remove-AzureRmNetworkInterface -Name $InterfaceName1 -ResourceGroupName $ResourceGroupName -Force -Confirm:$False
 }
	 if($pubip)
{ Write-Host "PublicIp already Exists, removing orphan" -ForegroundColor DarkYellow
				  Remove-AzureRmPublicIpAddress -Name $InterfaceName1 -ResourceGroupName $ResourceGroupName -Force -Confirm:$False
}
	 if($nic2)
{ Write-Host "Nic2 already Exists, removing orphan" -ForegroundColor DarkYellow
				  Remove-AzureRmNetworkInterface -Name $InterfaceName2 -ResourceGroupName $ResourceGroupName -Force -Confirm:$False
 }
 else {Write-Host "No Orphans Found, proceeding with deployment.." -ForegroundColor Green}
 }
# Write-Host "No Orphans Found" -ForegroundColor Green
} # Verifies no left over components will prohibit deployment of the new VM, cleans up any if the exist.
Function AzureVersion{
$name='Azure'
if(Get-Module -ListAvailable |
	Where-Object { $_.name -eq $name })
{
	(Get-Module -ListAvailable | Where-Object{ $_.Name -eq $name }) |
	Select Version, Name, Author, PowerShellVersion  | Format-List;
}
else
{
	“The Azure PowerShell module is not installed.”
}
}

# End of Fuctions

##--------------------------- Begin Script Execution -------------------------------------------------------##

VerifyProfile

try {
	[Microsoft.Azure.Common.Authentication.AzureSession]::ClientFactory.AddUserAgent("VSAzureTools-$UI$($host.name)".replace(" ","_"), "2.9")
} catch { }

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

$resourcegroups = @($ResourceGroupName,$vNetResourceGroupName);
# $resourcegroups = @($ResourceGroupName);
if($resourcegroups.length) {
	foreach($resourcegroup in $resourcegroups) {
		ProvisionResGrp($resourcegroup);
	}
	} # Create Resource Groups

AzureVersion # Display Azure Version
CheckOrphns # Check if Orphans exist.
WriteConfig
if($NewVNET -eq "True"){ProvisionNet} # Creates VNET
if($NSGEnabled -eq "True"){CreateNSG}
CreateStorage # Creates Storage for VM
AvailSet # Handles Availability Set Creation
ImageConfig # Configure Image
Provvms #Provisions Final Step of VM Creation
if($NSGEnabled -eq "True"){NSGEnabled} #Adds NSG to NIC
if($AzExtConfig) {InstallExt} #Installs Azure Extensions
EndState