<#
.SYNOPSIS
Written By John Lewis
ver 2.3
This script provides the following functionality for deploying IaaS environments in Azure. The script will deploy VNET in addition to numerour Market Place VMs or make use of an existing VNETs.
The script supports dual homed servers (PFSense/Checkpoint/FreeBSD)
The script allows select of subnet prior to VM Deployment
The script supports deploying Availability Sets as well as adding new servers to existing Availability Sets through the -AvailabilitySet "True" and -AvailSetName switches.
The script will generate a name for azure storage endpoint unless the -StorageName variable is updated or referenced at runtime.
The script will log all processes to the log file location $logFile = $workfolder+'\'+$vmname+'-'+$date+'.log'

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
.NOTES

	-ConfigIps  <Configuration>
	PvtSingleStat & PvtDualStat – Deploys the server with a Public IP and the private IP(s) specified by the user.
	NoPubSingle & NoPubDual - Deploys the server without Public IP using automatically generated private IP(s).
	Single & Dual – Deploys the default configuration of a Public IP and automatically generated private IP(s).
	StatPvtNoPubDual & StatPvtNoPubSingle – Deploys the server without a Public IP using the private IP(s) specified by the user.

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
.EXAMPLE
\.azdeploy.ps1 -VMName pf001 -VMMarketImage pfsense -ResourceGroupName ResGroup1 -vNetResourceGroupName ResGroup1 -VNetName VNET -depsub1 0 -depsub2 1 -ConfigIPs DualPvtNoPub -PvtIPNic1 10.120.0.7 -PvtIPNic2 10.120.1.7
\.azdeploy.ps1 -VMName suse003 -VMMarketImage suse -ResourceGroupName ResGroup1 -vNetResourceGroupName ResGroup1 -VNetName VNET -depsub1 5 -ConfigIPs Single -AvailabilitySet "True"
\.azdeploy.ps1 -VMName cent006 -VMMarketImage centos -ResourceGroupName ResGroup1 -vNetResourceGroupName ResGroup1 -VNetName VNET -depsub1 4 -ConfigIPs SinglePvt -PvtIPNic1 10.120.4.120
\.azdeploy.ps1 -VMName win006 -VMMarketImage w2k12 -ResourceGroupName ResGroup1 -vNetResourceGroupName ResGroup1 -VNetName VNET -depsub1 6 -ConfigIPs SinglePvtNoPub -PvtIPNic1 10.120.6.120 -AvailabilitySet "True"
\.azdeploy.ps1 -VMName red76 -VMMarketImage red67 -ResourceGroupName $ResGroup1 -vNetResourceGroupName $ResGroup2 -VNetName VNET -depsub1 6 -ConfigIPs SinglePvtNoPub -PvtIPNic1 10.120.6.124
#>

[CmdletBinding()]
Param(
[Parameter(Mandatory=$False,ValueFromPipelinebyPropertyName=$true,Position=1)]
[string]
$vmMarketImage = "PFSense",

[Parameter(Mandatory=$False,ValueFromPipelinebyPropertyName=$true)]
[string]
$NewVnet = "True",

[Parameter(Mandatory=$False,ValueFromPipelinebyPropertyName=$true,Position=0)]
[string]
$VMName = "pf001",

[Parameter(Mandatory=$False,ValueFromPipelinebyPropertyName=$true,Position=2)]
[string]
$ResourceGroupName = 'ResGrp',

[Parameter(Mandatory=$False,ValueFromPipelinebyPropertyName=$true)]
[string]
$vNetResourceGroupName = $ResourceGroupName,

[Parameter(Mandatory=$False,ValueFromPipelinebyPropertyName=$true)]
[string]
$VNetName = "Vnet",

[Parameter(Mandatory=$False,ValueFromPipelinebyPropertyName=$true)]
[ValidateSet("Single","Dual","NoPubDual","PvtDualStat","StatPvtNoPubSingle","PvtSingleStat","StatPvtNoPubDual","NoPubSingle")]
[string]
$ConfigIPs = "Dual",

[Parameter(Mandatory=$False,ValueFromPipelinebyPropertyName=$true)]
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
$NSGEnabled = "True",

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
$PvtIPNic1 = '10.120.3.145',

[Parameter(Mandatory=$False,ValueFromPipelinebyPropertyName=$true)]
$PvtIPNic2 = '10.120.1.145'

)
# Global
$ErrorActionPreference = "SilentlyContinue"
$date = Get-Date -UFormat "%Y-%m-%d-%H-%M"
$workfolder = Split-Path $script:MyInvocation.MyCommand.Path
$SecureLocPassword=Convertto-SecureString $locpassword –asplaintext -Force
$Credential1 = New-Object System.Management.Automation.PSCredential ($locadmin,$SecureLocPassword)
## To use a Profile Json file for auth
# Login-AzureRmAccount -TenantId $TenantId

Function ConfigNet {
switch ($ConfigIPs)
	{
		"PvtDualStat" {
Write-Host "Dual IP Configuration - Static"
$global:PIp = New-AzureRmPublicIpAddress -Name $InterfaceName1 -ResourceGroupName $ResourceGroupName -Location $Location -AllocationMethod "Dynamic" –Confirm:$false -Force -WarningAction SilentlyContinue
$global:VNet = Get-AzureRMVirtualNetwork -Name $VNetName -ResourceGroupName $vNetResourceGroupName | Set-AzureRmVirtualNetwork
$global:Interface1 = New-AzureRmNetworkInterface -Name $InterfaceName1 -ResourceGroupName $ResourceGroupName -Location $Location -SubnetId $VNet.Subnets[$DepSub1].Id -PublicIpAddressId $PIp.Id -PrivateIpAddress $PvtIPNic1 –Confirm:$false -Force -WarningAction SilentlyContinue
$global:Interface2 = New-AzureRmNetworkInterface -Name $InterfaceName2 -ResourceGroupName $ResourceGroupName -Location $Location -SubnetId $VNet.Subnets[$DepSub2].Id -PrivateIpAddress $PvtIPNic2 –Confirm:$false -Force -WarningAction SilentlyContinue
}
		"PvtSingleStat" {
Write-Host "Single IP Configuration - Static"
$global:PIp = New-AzureRmPublicIpAddress -Name $InterfaceName1 -ResourceGroupName $ResourceGroupName -Location $Location -AllocationMethod "Dynamic" –Confirm:$false -Force -WarningAction SilentlyContinue
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
$global:PIp = New-AzureRmPublicIpAddress -Name $InterfaceName1 -ResourceGroupName $ResourceGroupName -Location $Location -AllocationMethod "Dynamic" –Confirm:$false -Force -WarningAction SilentlyContinue
$global:VNet = Get-AzureRMVirtualNetwork -Name $VNetName -ResourceGroupName $vNetResourceGroupName | Set-AzureRmVirtualNetwork
$global:Interface1 = New-AzureRmNetworkInterface -Name $InterfaceName1 -ResourceGroupName $ResourceGroupName -Location $Location -SubnetId $VNet.Subnets[$DepSub1].Id -PublicIpAddressId $PIp.Id –Confirm:$false -Force -WarningAction SilentlyContinue
}
		"Dual" {
Write-Host "Default Dual IP Configuration"
$global:PIp = New-AzureRmPublicIpAddress -Name $InterfaceName1 -ResourceGroupName $ResourceGroupName -Location $Location -AllocationMethod "Dynamic" –Confirm:$false -Force -WarningAction SilentlyContinue
$global:VNet = Get-AzureRMVirtualNetwork -Name $VNetName -ResourceGroupName $vNetResourceGroupName | Set-AzureRmVirtualNetwork
$global:Interface1 = New-AzureRmNetworkInterface -Name $InterfaceName1 -ResourceGroupName $ResourceGroupName -Location $Location -SubnetId $VNet.Subnets[$DepSub1].Id -PublicIpAddressId $PIp.Id –Confirm:$false -Force -WarningAction SilentlyContinue
$global:Interface2 = New-AzureRmNetworkInterface -Name $InterfaceName2 -ResourceGroupName $ResourceGroupName -Location $Location -SubnetId $VNet.Subnets[$DepSub2].Id –Confirm:$false -Force -WarningAction SilentlyContinue
}
		"NoPubSingle" {
Write-Host "Single IP - No Public"
$VNet = Get-AzureRMVirtualNetwork -Name $VNetName -ResourceGroupName $vNetResourceGroupName | Set-AzureRmVirtualNetwork
$Interface1 = New-AzureRmNetworkInterface -Name $InterfaceName1 -ResourceGroupName $ResourceGroupName -Location $Location -SubnetId $VNet.Subnets[$DepSub1].Id –Confirm:$false -Force -WarningAction SilentlyContinue
}
		"NoPubDual" {
Write-Host "Dual IP - No Public"
$VNet = Get-AzureRMVirtualNetwork -Name $VNetName -ResourceGroupName $vNetResourceGroupName | Set-AzureRmVirtualNetwork
$Interface1 = New-AzureRmNetworkInterface -Name $InterfaceName1 -ResourceGroupName $ResourceGroupName -Location $Location -SubnetId $VNet.Subnets[$DepSub1].Id –Confirm:$false -Force -WarningAction SilentlyContinue
$Interface2 = New-AzureRmNetworkInterface -Name $InterfaceName2 -ResourceGroupName $ResourceGroupName -Location $Location -SubnetId $VNet.Subnets[$DepSub2].Id –Confirm:$false -Force -WarningAction SilentlyContinue
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

Function SelectNicDescrtipt {
if($ConfigIPs-EQ "Dual"){Write-Host "         Dual Nic, Pvt IP & Public IP" }
	elseif($ConfigIPs-EQ "Single"){Write-Host "         Single Nic, Pvt IP & Public IP" }
			elseif($ConfigIPs-EQ "PvtDualStat"){Write-Host "         Dual Nic, Static Pvt IP & Public IP" }
				  elseif($ConfigIPs-EQ"PvtSingleStat"){Write-Host "         Single Nic, Static Pvt IP & Public IP" }
						 elseif($ConfigIPs-EQ "SinglePvtNoPub"){Write-Host "         Single Nic, Static Pvt IP & No Public IP" }
							   elseif($ConfigIPs-EQ "StatPvtNoPubDual"){Write-Host "         Dual Nic, Static Pvt IPs & No Public IP"}
										elseif($ConfigIPs-EQ "StatPvtNoPubSingle"){Write-Host "         Single Nic, Static Pvt IP & No Public IP"}
											   elseif($ConfigIPs-EQ "NoPubSingle"){Write-Host "         Single Nic, Pvt IP & No Public IP"}
													elseif($ConfigIPs-EQ "NoPubDual"){Write-Host "         Dual Nic, Pvt IPs & No Public IP"}
	else {
	Write-Host "No Network Config Found - Warning" -ForegroundColor Red
	}
}
Function RegisterRP {
	Param(
		[string]$ResourceProviderNamespace
	)

	Write-Host "Registering resource provider '$ResourceProviderNamespace'";
	Register-AzureRmResourceProvider -ProviderNamespace $ResourceProviderNamespace –Confirm:$false -Force -WarningAction SilentlyContinue | Out-Null;
}

Function AvailSet {
 try {
 If ($AvailabilitySet -eq "True" )
 {
 Write-Host "Availability Set creation in process" -ForegroundColor Blue
New-AzureRmAvailabilitySet -ResourceGroupName $ResourceGroupName -Name $AvailSetName -Location $Location -WarningAction SilentlyContinue| Out-Null
$AvailabilitySet = (Get-AzureRmAvailabilitySet -ResourceGroupName $ResourceGroupName -Name $AvailSetName).Id
$global:VirtualMachine = New-AzureRmVMConfig -VMName $VMName -VMSize $VMSize -AvailabilitySetID $AvailabilitySet -WarningAction SilentlyContinue
Write-Host "Availability Set has been created" -ForegroundColor White
}
else
{
Write-Host "Skipping Availability Set creation" -ForegroundColor Blue
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
Write-Host "Completing image creation" -ForegroundColor Blue
Write-Progress -Activity
$global:osDiskCaching = "ReadWrite"
$global:OSDiskName = $VMName + "OSDisk"
$global:OSDiskUri = $StorageAccount.PrimaryEndpoints.Blob.ToString() + "vhds/" + $OSDiskName + ".vhd"
$global:VirtualMachine = Set-AzureRmVMOSDisk -VM $VirtualMachine -Name $OSDiskName -VhdUri $OSDiskUri -CreateOption "FromImage" -Caching $osDiskCaching -WarningAction SilentlyContinue
New-AzureRmVM -ResourceGroupName $ResourceGroupName -Location $Location -VM $VirtualMachine –Confirm:$false -Verbose -WarningAction SilentlyContinue
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
Write-Host "Network Preparation in Process"
$subnet1 = New-AzureRmVirtualNetworkSubnetConfig -AddressPrefix 10.120.0.0/24 -Name perimeter
$subnet2 = New-AzureRmVirtualNetworkSubnetConfig -AddressPrefix 10.120.1.0/24 -Name web
$subnet3 = New-AzureRmVirtualNetworkSubnetConfig -AddressPrefix 10.120.2.0/24 -Name intake
$subnet4 = New-AzureRmVirtualNetworkSubnetConfig -AddressPrefix 10.120.3.0/24 -Name data
$subnet5 = New-AzureRmVirtualNetworkSubnetConfig -AddressPrefix 10.120.4.0/24 -Name monitoring
$subnet6 = New-AzureRmVirtualNetworkSubnetConfig -AddressPrefix 10.120.5.0/24 -Name analytics
$subnet7 = New-AzureRmVirtualNetworkSubnetConfig -AddressPrefix 10.120.6.0/24 -Name backup
$subnet8 = New-AzureRmVirtualNetworkSubnetConfig -AddressPrefix 10.120.7.0/24 -Name management
New-AzureRmVirtualNetwork -Location $Location -Name $VNetName -ResourceGroupName $vNetResourceGroupName -AddressPrefix '10.120.0.0/21' -Subnet $subnet1,$subnet2,$subnet3,$subnet4,$subnet5,$subnet6,$subnet7,$subnet8 –Confirm:$false -Force -WarningAction SilentlyContinue | Out-Null
Get-AzureRmVirtualNetwork -Name $VNetName -ResourceGroupName $vNetResourceGroupName | Get-AzureRmVirtualNetworkSubnetConfig -WarningAction SilentlyContinue | Out-Null
Write-Host "Network Preparation completed" -ForegroundColor Blue
}

# End of Provision VNET Function
Function CreateNSG {
Write-Host "Network Security Group Preparation in Process"
$httprule = New-AzureRmNetworkSecurityRuleConfig -Name "FrontEnd_HTTP" -Description "HTTP Exception for Web frontends" -Protocol Tcp -SourcePortRange "80" -DestinationPortRange "80" -SourceAddressPrefix "*" -DestinationAddressPrefix "10.120.0.0/21" -Access Allow -Direction Inbound -Priority 200
$httpsrule = New-AzureRmNetworkSecurityRuleConfig -Name "FrontEnd_HTTPS" -Description "HTTPS Exception for Web frontends" -Protocol Tcp -SourcePortRange "443" -DestinationPortRange "443" -SourceAddressPrefix "*" -DestinationAddressPrefix "10.120.0.0/21" -Access Allow -Direction Inbound -Priority 201
$sshrule = New-AzureRmNetworkSecurityRuleConfig -Name "FrontEnd_SSH" -Description "SSH Exception for Web frontends" -Protocol Tcp -SourcePortRange "22" -DestinationPortRange "22" -SourceAddressPrefix "*" -DestinationAddressPrefix "10.120.0.0/21" -Access Allow -Direction Inbound ` -Priority 203
$nsg = New-AzureRmNetworkSecurityGroup -ResourceGroupName $vNetResourceGroupName -Location $Location -Name $NSGName -SecurityRules $httprule,$httpsrule, $sshrule –Confirm:$false -Force -WarningAction SilentlyContinue | Out-Null
Get-AzureRmNetworkSecurityGroup -Name $NSGName -ResourceGroupName $vNetResourceGroupName -WarningAction SilentlyContinue | Out-Null
Write-Host "Network Security Group creation completed" -ForegroundColor Blue
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

Function WriteConfig {
Write-Host "Using configuration:"
Write-Host "         VM Name: $VMName "
Write-Host "         Resource Group Name: $ResourceGroupName"
Write-Host "         Server Type: $vmMarketImage"
Write-Host "         VNET Resource Group Name: $vNetResourceGroupName"
Write-Host "         Storage Account Name:  $StorageName"
SelectNicDescrtipt
If ($ConfigIPs -eq "StatPvtNoPubSingle")
{ Write-Host "         Public Ip Will not be created" -ForegroundColor Blue
Write-Host "        "Nic1: "$PvtIPNic1"
SubnetMatch $DepSub1
}
If ($ConfigIPs -eq "StatPvtNoPubDual")
{ Write-Host "         Public Ip Will not be created" -ForegroundColor Blue
Write-Host "        "Nic1: "$PvtIPNic1"
Write-Host "        "Nic2: "$PvtIPNic2"
SubnetMatch $DepSub1
SubnetMatch $DepSub2
}
If ($ConfigIPs -eq "Single")
{ Write-Host "         Public Ip Will be created"
SubnetMatch $DepSub1
}

If ($ConfigIPs -eq "Dual")
{ Write-Host "         Public Ip Will be created"
SubnetMatch $DepSub1
SubnetMatch $DepSub2
}
If ($ConfigIPs -eq "PvtSingleStat")
{ Write-Host "         Public Ip Will be created"
SubnetMatch $DepSub1
Write-Host "        "Nic1: "$PvtIPNic1"
}
If ($ConfigIPs -eq "PvtDualStat")
{ Write-Host "         Public Ip Will be created"
SubnetMatch $DepSub1
SubnetMatch $DepSub2
Write-Host "        "Nic1: "$PvtIPNic1"
Write-Host "        "Nic2: "$PvtIPNic2"
}
if($AvailabilitySet -eq "True") {
Write-Host "         Availability Set to 'True'"
Write-Host "         Availability Set Name:  '$AvailSetName'"
}
else
{
Write-Host "         Availability Set to 'False'" -ForegroundColor White
}
}

Function WriteResults {
Write-Host "Completed Deployment of:"
Write-Host "VM Name: $VMName "
Write-Host "Resource Group Name: $ResourceGroupName"
Write-Host "Server Type: $vmMarketImage"
Write-Host "VNET Resource Group Name: $vNetResourceGroupName"
Write-Host "Storage Account Name:  $StorageName"
SelectNicDescrtipt
if($AvailabilitySet -eq "True") {
Write-Host "Availability Set created"
Write-Host "Availability Set Name:  '$AvailSetName'"
}
else
{
# Write-Host "         Availability Set to 'False'" -ForegroundColor Blue
}
}

Function EndState {
 Get-AzureRmVirtualNetwork -ResourceGroupName $vNetResourceGroupName | Select Name, ResourceGroupName, Subnets
 Get-AzureRmPublicIpAddress -ResourceGroupName $ResourceGroupName | ft "Name","IpAddress"
 Get-AzureRmNetworkInterface -ResourceGroupName $ResourceGroupName | ft Name,Location,ResourceGroupName

WriteResults

Write-Host "Resource Group Network Interfaces"
$vms = get-azurermvm -ResourceGroupName $ResourceGroupName
$nics = get-azurermnetworkinterface -ResourceGroupName $ResourceGroupName | where VirtualMachine -NE $null #skip Nics with no VM
foreach($nic in $nics)
{
	$vm = $vms | where-object -Property Id -EQ $nic.VirtualMachine.id
	$prv =  $nic.IpConfigurations | select-object -ExpandProperty PrivateIpAddress
	$alloc =  $nic.IpConfigurations | select-object -ExpandProperty PrivateIpAllocationMethod
	Write-Output "$($vm.Name) : $prv , $alloc" | Format-Table
}
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

Function CreateStorage {
Write-Host "Starting Storage Creation"
$Global:StorageAccount = New-AzureRmStorageAccount -ResourceGroupName $ResourceGroupName -Name $StorageName.ToLower() -Type $StorageType -Location $Location -ErrorAction Stop -WarningAction SilentlyContinue
#Get-AzureRmStorageAccount -Name $StorageName.ToLower() -ResourceGroupName $ResourceGroupName -WarningAction SilentlyContinue | ft "StorageAccountName" -OutVariable $stracct
Write-Host "Completed Storage Creation" -ForegroundColor Blue
}
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
 else {Write-Host "No Orphans Found" -ForegroundColor Green}
 }
# Write-Host "No Orphans Found" -ForegroundColor Green
}

Add-AzureRmAccount

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
 }

$resourcegroups = @($ResourceGroupName,$vNetResourceGroupName);
# $resourcegroups = @($ResourceGroupName);
if($resourcegroups.length) {
	foreach($resourcegroup in $resourcegroups) {
		ProvisionRGs($resourcegroup);
	}
	}

AzureVersion # Display Azure Version
CheckOrphns # Check if Orphans exist.
WriteConfig # Displays Configuration
ProvisionNet # Creates VNET
CreateNSG # Creates Network Security Group
CreateStorage # Creates Storage for VM
NicCounts # Gets Nic Creation Info
AvailSet # Handles Availability Set Creation

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

		default{"An unsupported image was referenced"}
	}

EndState