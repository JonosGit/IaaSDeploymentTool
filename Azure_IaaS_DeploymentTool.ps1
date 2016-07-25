<#
.NOTES
Azure_Iaas_DeploymentTool.ps1 - Azure Infrastructure Automation Tool
Written by John Lewis
Version 2.0
.SYNOPSIS
This script provides the following functionality for deploying IaaS environments in Azure. The script will deploy VNET in addition to numerour Market Place VMs or make use of an existing VNETs.
The script supports dual homed servers (PFSense/Checkpoint/FreeBSD)
The script allows select of subnet prior to VM Deployment
The script supports deploying Availability Sets as well as adding new servers to existing Availability Sets through the -AvailabilitySet "True" and -AvailSetName switches.
The script will generate a name for azure storage endpoint unless the -StorageName variable is updated or referenced at runtime.
The script will log all processes to the log file location $logFile = $workfolder+'\'+$vmname+'-'+$date+'.log'

Market Images supported: Redhat 6.7 and 7.2, PFSense 2.5, Windows 2008 R2, Windows 2012 R2, Ubuntu 14.04, CentOs 7.2, SUSE, SQL 2016 (on W2K12R2), R Server on Windows, Windows 2016 (Preview), Checkpoint Firewall, FreeBsd
.PARAMETERS

 Core VM Parameters
   -VMName = “NewVM”
   -ResourceGroupName = “RG”
   -NewVnet = “True”
   -VNetName = “VNET”
   -vNetResourceGroupName = “RGVNET”
   -NSGEnabled True
   -AvailabilitySet <True>

 To specify the destination subnet,
	-depsub1 <Subnet ID>
	-depsub2 <Subnet ID>

 To specify Private IP configurations
	-ConfigIps  <Configuration>
	Single – Deploys the single NIC default configuration of a Public IP and automatically generated private IP.
	Dual – Deploys the dual NIC default configuration of a Public IP and automatically generated private IP.
	DualPvtNoPub – Deploys the server dual homed without a Public IP using the private IPs specified by the user.
	SinglePvtNoPub – Deploys the server dual homed without a Public IP using the private IP specified by the user.
	SinglePvt - Deploys the server single NIC with a Public IP using the private IP specified by the user.
	DualPvt - Deploys the server dual NIC with a Public IP using the private IPs specified by the user.

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

.EXAMPLE
\.azdeploy.ps1 -VMName pf001 -VMMarketImage pfsense -ResourceGroupName ResGroup1 -vNetResourceGroupName ResGroup1 -VNetName $VNET -depsub1 0 -depsub2 1 -ConfigIPs DualPvtNoPub -PvtIPNic1 10.120.0.7 -PvtIPNic2 10.120.1.7
\.azdeploy.ps1 -VMName suse003 -VMMarketImage suse -ResourceGroupName ResGroup1 -vNetResourceGroupName ResGroup1 -VNetName $VNET -depsub1 5 -ConfigIPs Single -AvailabilitySet "True"
\.azdeploy.ps1 -VMName cent006 -VMMarketImage centos -ResourceGroupName ResGroup1 -vNetResourceGroupName ResGroup1 -VNetName $VNET -depsub1 4 -ConfigIPs SinglePvt -PvtIPNic1 10.120.4.120
\.azdeploy.ps1 -VMName win006 -VMMarketImage w2k12 -ResourceGroupName ResGroup1 -vNetResourceGroupName ResGroup1 -VNetName $VNET -depsub1 6 -ConfigIPs SinglePvtNoPub -PvtIPNic1 10.120.6.120 -AvailabilitySet "True"
\.azdeploy.ps1 -VMName red76 -VMMarketImage red67 -ResourceGroupName $ResGroup1 -vNetResourceGroupName $ResGroup2 -VNetName $VNET -depsub1 6 -ConfigIPs SinglePvtNoPub -PvtIPNic1 10.120.6.124
#>

[CmdletBinding()]
Param(
 [Parameter(Mandatory=$False,ValueFromPipelinebyPropertyName=$true)]
 [string]
$vmMarketImage = "Pfsense",

 [Parameter(Mandatory=$False,ValueFromPipelinebyPropertyName=$true)]
 [string]
$NewVnet = "True",

 [Parameter(Mandatory=$False,ValueFromPipelinebyPropertyName=$true)]
 [string]
$VMName = "pfsrv01",

 [Parameter(Mandatory=$False,ValueFromPipelinebyPropertyName=$true)]
 [string]
$ResourceGroupName = "ResGrp",

 [Parameter(Mandatory=$False,ValueFromPipelinebyPropertyName=$true)]
 [string]
$vNetResourceGroupName =$ResourceGroupName,

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
 [Int]
$DepSub1 = 0,
 [Parameter(Mandatory=$False,ValueFromPipelinebyPropertyName=$true)]
 [Int]
$DepSub2 = 1,
 [Parameter(Mandatory=$False,ValueFromPipelinebyPropertyName=$true)]
 [string]
$AvailabilitySet = "False",
 [Parameter(Mandatory=$False,ValueFromPipelinebyPropertyName=$true)]
 [string]
$AvailSetName = $GenerateName,
 [Parameter(Mandatory=$False,ValueFromPipelinebyPropertyName=$true)]
 [INT]
$PvtIPNic1 = "",
 [Parameter(Mandatory=$False,ValueFromPipelinebyPropertyName=$true)]
 [INT]
$PvtIPNic2 = "",
 [Parameter(Mandatory=$False,ValueFromPipelinebyPropertyName=$true)]
 [string]
$ConfigIPs = "Dual"
)
# Global
$ErrorActionPreference = "SilentlyContinue"
$date = Get-Date -UFormat "%Y-%m-%d-%H-%M"
$workfolder = Split-Path $script:MyInvocation.MyCommand.Path
$logFile = $workfolder+'\'+$vmname+'-'+$date+'.log'
$OutputFile = $workfolder+'\'+$vmname+'-'+$date+'.txt'
$SecureLocPassword=Convertto-SecureString $locpassword –asplaintext -Force
$Credential1 = New-Object System.Management.Automation.PSCredential ($locadmin,$SecureLocPassword)
Write-Output "Steps will be tracked on the log file : [ $logFile ]"
## To use a Profile Json file for auth
# Login-AzureRmAccount -TenantId $TenantId

Function WriteLog-Command([string]$Description, [ScriptBlock]$Command, [string]$LogFile, [string]$VMName ){
Try{
$Output = $Description+'  ... '
Write-Host $Output -ForegroundColor White
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
# End of Log Wrapping Function
Function NetStk_nic_pub_stpvt {
$global:PIp = New-AzureRmPublicIpAddress -Name $InterfaceName1 -ResourceGroupName $ResourceGroupName -Location $Location -AllocationMethod "Dynamic" –Confirm:$false -Force
$global:VNet = Get-AzureRMVirtualNetwork -Name $VNetName -ResourceGroupName $vNetResourceGroupName | Set-AzureRmVirtualNetwork
$global:Interface1 = New-AzureRmNetworkInterface -Name $InterfaceName1 -ResourceGroupName $ResourceGroupName -Location $Location -SubnetId $VNet.Subnets[$DepSub1].Id -PublicIpAddressId $PIp.Id -PrivateIpAddress $PvtIPNic1 –Confirm:$false -Force
}
Function NetStk_dualnic_pub_stpvt {
$global:PIp = New-AzureRmPublicIpAddress -Name $InterfaceName1 -ResourceGroupName $ResourceGroupName -Location $Location -AllocationMethod "Dynamic" –Confirm:$false -Force
$global:VNet = Get-AzureRMVirtualNetwork -Name $VNetName -ResourceGroupName $vNetResourceGroupName | Set-AzureRmVirtualNetwork
$global:Interface1 = New-AzureRmNetworkInterface -Name $InterfaceName1 -ResourceGroupName $ResourceGroupName -Location $Location -SubnetId $VNet.Subnets[$DepSub1].Id -PrivateIpAddress $PvtIPNic1 –Confirm:$false -Force
$global:Interface2 = New-AzureRmNetworkInterface -Name $InterfaceName2 -ResourceGroupName $ResourceGroupName -Location $Location -SubnetId $VNet.Subnets[$DepSub2].Id -PrivateIpAddress $PvtIPNic2 –Confirm:$false -Force
}
Function NetStk_dualnic_nopub_stpvt {
$global:VNet = Get-AzureRMVirtualNetwork -Name $VNetName -ResourceGroupName $vNetResourceGroupName | Set-AzureRmVirtualNetwork
$global:Interface1 = New-AzureRmNetworkInterface -Name $InterfaceName1 -ResourceGroupName $ResourceGroupName -Location $Location -SubnetId $VNet.Subnets[$DepSub1].Id -PrivateIpAddress $PvtIPNic1 –Confirm:$false -Force
$global:Interface2 = New-AzureRmNetworkInterface -Name $InterfaceName2 -ResourceGroupName $ResourceGroupName -Location $Location -SubnetId $VNet.Subnets[$DepSub2].Id -PrivateIpAddress $PvtIPNic2 –Confirm:$false -Force
}
Function NetStk_nic_nopub_stpvt {
$global:VNet = Get-AzureRMVirtualNetwork -Name $VNetName -ResourceGroupName $vNetResourceGroupName | Set-AzureRmVirtualNetwork
$global:Interface1 = New-AzureRmNetworkInterface -Name $InterfaceName1 -ResourceGroupName $ResourceGroupName -Location $Location -SubnetId $VNet.Subnets[$DepSub1].Id -PrivateIpAddress $PvtIPNic1 –Confirm:$false -Force
}
Function NetStk_nic_nopub_dynpvt {
$global:VNet = Get-AzureRMVirtualNetwork -Name $VNetName -ResourceGroupName $vNetResourceGroupName | Set-AzureRmVirtualNetwork
$global:Interface1 = New-AzureRmNetworkInterface -Name $InterfaceName1 -ResourceGroupName $ResourceGroupName -Location $Location -SubnetId $VNet.Subnets[$DepSub1].Id –Confirm:$false -Force
}
Function NetStk_dualnic_nopub_dynpvt {
$global:VNet = Get-AzureRMVirtualNetwork -Name $VNetName -ResourceGroupName $vNetResourceGroupName | Set-AzureRmVirtualNetwork
$global:Interface1 = New-AzureRmNetworkInterface -Name $InterfaceName1 -ResourceGroupName $ResourceGroupName -Location $Location -SubnetId $VNet.Subnets[$DepSub1].Id –Confirm:$false -Force
$global:Interface2 = New-AzureRmNetworkInterface -Name $InterfaceName2 -ResourceGroupName $ResourceGroupName -Location $Location -SubnetId $VNet.Subnets[$DepSub2].Id –Confirm:$false -Force
}
Function NetStk_nic_pub_dynpvt {
$global:PIp = New-AzureRmPublicIpAddress -Name $InterfaceName1 -ResourceGroupName $ResourceGroupName -Location $Location -AllocationMethod "Dynamic" –Confirm:$false -Force
$global:VNet = Get-AzureRMVirtualNetwork -Name $VNetName -ResourceGroupName $vNetResourceGroupName | Set-AzureRmVirtualNetwork
$global:Interface1 = New-AzureRmNetworkInterface -Name $InterfaceName1 -ResourceGroupName $ResourceGroupName -Location $Location -SubnetId $VNet.Subnets[$DepSub1].Id -PublicIpAddressId $PIp.Id –Confirm:$false -Force
}
Function NetStk_dualnic_pub_dynpvt {
$global:PIp = New-AzureRmPublicIpAddress -Name $InterfaceName1 -ResourceGroupName $ResourceGroupName -Location $Location -AllocationMethod "Dynamic" –Confirm:$false -Force
$global:VNet = Get-AzureRMVirtualNetwork -Name $VNetName -ResourceGroupName $vNetResourceGroupName | Set-AzureRmVirtualNetwork
$global:Interface1 = New-AzureRmNetworkInterface -Name $InterfaceName1 -ResourceGroupName $ResourceGroupName -Location $Location -SubnetId $VNet.Subnets[$DepSub1].Id -PublicIpAddressId $PIp.Id –Confirm:$false -Force
$global:Interface2 = New-AzureRmNetworkInterface -Name $InterfaceName2 -ResourceGroupName $ResourceGroupName -Location $Location -SubnetId $VNet.Subnets[$DepSub2].Id –Confirm:$false -Force
}

Function SelectNetConfig {
if($ConfigIPs -EQ "Dual"){NetStk_dualnic_pub_dynpvt}
	elseif($ConfigIPs -EQ "Single"){NetStk_nic_pub_dynpvt}
			elseif($ConfigIPs-EQ "DualPvt"){NetStk_dualnic_pub_stpvt}
				  elseif($ConfigIPs-EQ "SinglePvt"){NetStk_nic_pub_stpvt}
						 elseif($ConfigIPs-EQ "SinglePvtNoPub"){NetStk_nic_nopub_stpvt}
							   elseif($ConfigIPs-EQ "DualPvtNoPub"){NetStk_dualnic_nopub_stpvt}
	else {
	Write-Host "No Network Config Found" -ForegroundColor Red
	}
}

Function SelectNicCount {
if($ConfigIPs-EQ "Dual"){AddNICs}
	elseif($ConfigIPs-EQ "Single"){AddNIC}
			elseif($ConfigIPs-EQ "DualPvt"){AddNICs}
				  elseif($ConfigIPs-EQ "SinglePvt"){AddNIC}
						 elseif($ConfigIPs-EQ "SinglePvtNoPub"){AddNIC}
							   elseif($ConfigIPs-EQ "DualPvtNoPub"){AddNICs}
	else {
	Write-Host "No Network Config Found" -ForegroundColor Red
	}
}

Function SelectNicDescrtipt {
if($ConfigIPs-EQ "Dual"){Write-Host "         Dual Nic, Pvt IP & Public IP"}
	elseif($ConfigIPs-EQ "Single"){Write-Host "         Single Nic, Pvt IP & Public IP"}
			elseif($ConfigIPs-EQ "DualPvt"){Write-Host "         Dual Nic, Static Pvt IP & Public IP"}
				  elseif($ConfigIPs-EQ"SinglePvt"){Write-Host "         Single Nic, Static Pvt IP & Public IP"}
						 elseif($ConfigIPs-EQ "SinglePvtNoPub"){Write-Host "         Single Nic, Static Pvt IP & No Public IP"}
							   elseif($ConfigIPs-EQ "DualPvtNoPub"){Write-Host "         Single Nic, Static Pvt IP & No Public IP"}
	else {
	Write-Host "No Network Config Found" -ForegroundColor Red
	}
}

Function AvailSet {
 try {
 If ($AvailabilitySet -eq "True" )
 {
New-AzureRmAvailabilitySet -ResourceGroupName $ResourceGroupName -Name $AvailSetName -Location $Location | Out-Null
$AvailabilitySet = (Get-AzureRmAvailabilitySet -ResourceGroupName $ResourceGroupName -Name $AvailSetName).Id
$global:VirtualMachine = New-AzureRmVMConfig -VMName $VMName -VMSize $VMSize -AvailabilitySetID $AvailabilitySet
}
else
{
Write-Host "Skipping Availability Set creation"
$global:VirtualMachine = New-AzureRmVMConfig -VMName $VMName -VMSize $VMSize
}
	}

catch {
	Write-Host -foregroundcolor Red `
	"$($_.Exception.Message)"; `
	continue
}
 }

Function AddDiskImage {
$Description = "Finishing up vhd image creation"
Write-Progress -Activity
$global:osDiskCaching = "ReadWrite"
$global:OSDiskName = $VMName + "OSDisk"
$global:OSDiskUri = $StorageAccount.PrimaryEndpoints.Blob.ToString() + "vhds/" + $OSDiskName + ".vhd"
$global:VirtualMachine = Set-AzureRmVMOSDisk -VM $VirtualMachine -Name $OSDiskName -VhdUri $OSDiskUri -CreateOption "FromImage" -Caching $osDiskCaching
$Command = {New-AzureRmVM -ResourceGroupName $ResourceGroupName -Location $Location -VM $VirtualMachine –Confirm:$false -Verbose}
WriteLog-Command -Description $Description -Command $Command -LogFile $LogFile
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
$VirtualMachine = Set-AzureRmVMPlan -VM $VirtualMachine -Name $name -Publisher $Publisher -Product $Product
$VirtualMachine = Set-AzureRmVMOperatingSystem -VM $VirtualMachine -linux -ComputerName $VMName -Credential $Credential1
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
$VirtualMachine = Set-AzureRmVMPlan -VM $VirtualMachine -Name $name -Publisher $Publisher -Product $Product
$VirtualMachine = Set-AzureRmVMOperatingSystem -VM $VirtualMachine -linux -ComputerName $VMName -Credential $Credential1
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
$VirtualMachine = Set-AzureRmVMPlan -VM $VirtualMachine -Name $name -Publisher $Publisher -Product $Product
$VirtualMachine = Set-AzureRmVMOperatingSystem -VM $VirtualMachine -linux -ComputerName $VMName -Credential $Credential1
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
$VirtualMachine = Set-AzureRmVMOperatingSystem -VM $VirtualMachine -Windows -ComputerName $VMName -Credential $Credential1 -ProvisionVMAgent -EnableAutoUpdate -WinRMHttp -Verbose
$global:VirtualMachine = Set-AzureRmVMSourceImage -VM $VirtualMachine -PublisherName $Publisher -Offer $offer -Skus $Skus -Version $version
}

Function AddNICs {
Write-Host "Adding 2 Network Interface(s) $InterfaceName1 $InterfaceName2" -ForegroundColor White
$VirtualMachine = Add-AzureRmVMNetworkInterface -VM $VirtualMachine -Id $Interface1.Id -Primary
$global:VirtualMachine = Add-AzureRmVMNetworkInterface -VM $VirtualMachine -Id $Interface2.Id
}

Function AddNIC {
Write-Host "Adding Network Interface $InterfaceName1" -ForegroundColor White
$global:VirtualMachine = Add-AzureRmVMNetworkInterface -VM $VirtualMachine -Id $Interface1.Id -Primary
}
Function Validate-AvailExistence ($AvaiabilitySetName, $ResourceGroupName)
{
$AvExist = $false
$Description = "Validating the Availability Set Existence"
$IsExist = {Get-AzureRmVM | where { $_.ResourceGroupName -eq $ResourceGroupName -and $_.Name -eq $AvaiabilitySetName}}
if ($IsExist) {$AvExist = $true}
return $AvExist
}

Function Validate-VmExistence ($VMName, $ResourceGroupName)
{
$VmExist = $false
$Description = "Validating the Vm Existence"
$IsExist = {Get-AzureRmVM | where { $_.ResourceGroupName -eq $ResourceGroupName -and $_.Name -eq $VMName}}
if ($IsExist) {$VmExist = $true}
return $VmExist
}
Function Validate-Nic1Existence ($InterfaceName, $ResourceGroupName)
{
$NicExist = $false
$Description = "Validating the Nic Existence"
$IsExist = {Get-AzureRmNetworkInterface | where { $_.ResourceGroupName -eq $ResourceGroupName -and $_.Name -eq $InterfaceName1}}
if ($IsExist) {$NicExist = $true}
return $NicExist
}
Function Validate-Nic2Existence ($InterfaceName, $ResourceGroupName)
{
$NicExist = $false
$Description = "Validating the Nic Existence"
$IsExist = {Get-AzureRmNetworkInterface | where { $_.ResourceGroupName -eq $ResourceGroupName -and $_.Name -eq $InterfaceName2}}
if ($IsExist) {$NicExist = $true}
return $NicExist
}
Function Validate-PubIpExistence ($InterfaceName, $ResourceGroupName)
{
$IpExist = $false
$Description = "Validating the Nic Existence"
$IsExist = {Get-AzureRmPublicIpAddress | where { $_.ResourceGroupName -eq $ResourceGroupName -and $_.Name -eq $InterfaceName1}}
if ($IsExist) {$IpExist = $true}
return $IpExist
}
Function Validate-vnetExistence ($VNetName, $vNetResourceGroupName  )
{
$vnetExist = $false
$Description = "Validating the Nic Existence"
$IsExist = { Get-AzureRmVirtualNetwork| where { $_.ResourceGroupName -eq $vNetResourceGroupName   -and $_.Name -eq $VNetName}}
if ($IsExist) {$vnetExist = $true}
return $vnetExist
}

Function ProvisionNet {
Write-Host "Network Preparation in Process" -ForegroundColor Blue
$subnet1 = New-AzureRmVirtualNetworkSubnetConfig -AddressPrefix 10.120.0.0/24 -Name perimeter
$subnet2 = New-AzureRmVirtualNetworkSubnetConfig -AddressPrefix 10.120.1.0/24 -Name web
$subnet3 = New-AzureRmVirtualNetworkSubnetConfig -AddressPrefix 10.120.2.0/24 -Name intake
$subnet4 = New-AzureRmVirtualNetworkSubnetConfig -AddressPrefix 10.120.3.0/24 -Name data
$subnet5 = New-AzureRmVirtualNetworkSubnetConfig -AddressPrefix 10.120.4.0/24 -Name monitoring
$subnet6 = New-AzureRmVirtualNetworkSubnetConfig -AddressPrefix 10.120.5.0/24 -Name analytics
$subnet7 = New-AzureRmVirtualNetworkSubnetConfig -AddressPrefix 10.120.6.0/24 -Name backup
$subnet8 = New-AzureRmVirtualNetworkSubnetConfig -AddressPrefix 10.120.7.0/24 -Name management
$Description = "Network Creation in Process"
$Command = {New-AzureRmVirtualNetwork -Location $Location -Name $VNetName -ResourceGroupName $vNetResourceGroupName -AddressPrefix '10.120.0.0/21' -Subnet $subnet1,$subnet2,$subnet3,$subnet4,$subnet5,$subnet6,$subnet7,$subnet8 –Confirm:$false -Force | Out-Null}
Get-AzureRmVirtualNetwork -Name $VNetName -ResourceGroupName $vNetResourceGroupName | Get-AzureRmVirtualNetworkSubnetConfig | Out-Null
WriteLog-Command -Description $Description -Command $Command -LogFile $LogFile
}
# End of Provision VNET Function
Function CreateNSG {
Write-Host "Network Security Group Preparation in Process" -ForegroundColor Blue
$httprule = New-AzureRmNetworkSecurityRuleConfig -Name "FrontEnd_HTTP" -Description "HTTP Exception for Web frontends" -Protocol Tcp -SourcePortRange "80" -DestinationPortRange "80" -SourceAddressPrefix "*" -DestinationAddressPrefix "10.120.0.0/21" -Access Allow -Direction Inbound -Priority 200
$httpsrule = New-AzureRmNetworkSecurityRuleConfig -Name "FrontEnd_HTTPS" -Description "HTTPS Exception for Web frontends" -Protocol Tcp -SourcePortRange "443" -DestinationPortRange "443" -SourceAddressPrefix "*" -DestinationAddressPrefix "10.120.0.0/21" -Access Allow -Direction Inbound -Priority 201
$sshrule = New-AzureRmNetworkSecurityRuleConfig -Name "FrontEnd_SSH" -Description "SSH Exception for Web frontends" -Protocol Tcp -SourcePortRange "22" -DestinationPortRange "22" -SourceAddressPrefix "*" -DestinationAddressPrefix "10.120.0.0/21" -Access Allow -Direction Inbound ` -Priority 203
$Description = "NSG Creation in Process"
$Command = {$nsg = New-AzureRmNetworkSecurityGroup -ResourceGroupName $vNetResourceGroupName -Location $Location -Name $NSGName -SecurityRules $httprule,$httpsrule, $sshrule –Confirm:$false -Force | Out-Null }
Get-AzureRmNetworkSecurityGroup -Name $NSGName -ResourceGroupName $vNetResourceGroupName | Out-Null
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

Function WriteConfig {
Write-Host "Using configuration:"
Write-Host "         VM Name: $VMName "
Write-Host "         Resource Group: $ResourceGroupName"
Write-Host "         Server Type: $vmMarketImage"
Write-Host "         VNET Resource Group Name: $vNetResourceGroupName"
Write-Host "         Storage Name:  $StorageName"
SelectNicDescrtipt
If ($ConfigIPs -eq "SinglePvtNoPub")
{ Write-Host "         Public Ip Will not be created"
Write-Host "        "Nic1: "$PvtIPNic1"
SubnetMatch $DepSub1
}
If ($ConfigIPs -eq "DualPvtNoPub")
{ Write-Host "         Public Ip Will not be created"
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
If ($ConfigIPs -eq "SinglePvt")
{ Write-Host "         Public Ip Will be created"
SubnetMatch $DepSub1
Write-Host "        "Nic1: "$PvtIPNic1"
}
If ($ConfigIPs -eq "DualPvt")
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
Write-Host "         Availability Set to 'False'"
}
}

Function EndState {
 Get-AzureRmVirtualNetwork -ResourceGroupName $vNetResourceGroupName | Select Name, ResourceGroupName, Subnets
 Get-AzureRmPublicIpAddress -ResourceGroupName $ResourceGroupName | ft "Name","IpAddress"
 Get-AzureRmNetworkInterface -ResourceGroupName $ResourceGroupName | ft Name,Location,ResourceGroupName

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

Function RegisterRP {
	Param(
		[string]$ResourceProviderNamespace
	)

	Write-Host "Registering resource provider '$ResourceProviderNamespace'";
	Register-AzureRmResourceProvider -ProviderNamespace $ResourceProviderNamespace –Confirm:$false -Force;
}
# End of Resgister Resource Providers Function
Function ProvisionRGs {
	Param(
		[string]$ResourceGroupName
	)
	$resourceGroup = Get-AzureRmResourceGroup -Name $ResourceGroupName -ErrorAction SilentlyContinue | Out-Null
if(!$resourceGroup)
{
	Write-Host "Resource group '$ResourceGroupName' does not exist. Creating...";
	if(!$Location) {
		$Location = Read-Host "resourceGroupLocation";
	}
	$Description = "Creating resource group $resourceGroupName in location $Location";
$Command = {New-AzureRmResourceGroup -Name $resourceGroupName -Location $Location –Confirm:$false -Force | Out-Null}
WriteLog-Command -Description $Description -Command $Command -LogFile $LogFile
}
else{
	Write-Host "Using existing resource group $ResourceGroupName"
	Get-AzureRmResourceGroup -Name $ResourceGroupName -ErrorAction SilentlyContinue | Out-Null
}
}

Function CreateStorage {
$Description = "Starting Storage Creation"
$Command = {$Global:StorageAccount = New-AzureRmStorageAccount -ResourceGroupName $ResourceGroupName -Name $StorageName.ToLower() -Type $StorageType -Location $Location -ErrorAction Stop}
Get-AzureRmStorageAccount -Name $StorageName.ToLower() -ResourceGroupName $ResourceGroupName | ft "StorageAccountName" -Wrap | Out-Null
WriteLog-Command -Description $Description -Command $Command -LogFile $LogFile
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
{ Write-Host "PublicIp already Exists, removing orphan" -ForegroundColor Yellow
				  Remove-AzureRmPublicIpAddress -Name $InterfaceName1 -ResourceGroupName $ResourceGroupName -Force -Confirm:$False
}
	 if($nic2)
{ Write-Host "Nic2 already Exists, removing orphan" -ForegroundColor Yellow
				  Remove-AzureRmNetworkInterface -Name $InterfaceName2 -ResourceGroupName $ResourceGroupName -Force -Confirm:$False
 }
 }
Write-Host "No Orphans Found" -ForegroundColor Green
}

Add-AzureRmAccount -TenantId $TenantId
## To use a Profile Json file for auth
##Select-AzureRmProfile -Path “”

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

# Create Resource Groups
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
 #Sets network connection info

switch -Wildcard ($vmMarketImage)
	{
		"*pf*" {
SelectNetConfig  #Sets network connection info
MakeImagePlanInfo_Pfsense
SelectNicCount
AddDiskImage
}
		"*free*" {
SelectNetConfig  #Sets network connection info
MakeImageNoPlanInfo_FreeBsd
SelectNicCount
AddDiskImage
}
		"*red72*" {
SelectNetConfig  #Sets network connection info
MakeImageNoPlanInfo_RedHat72
SelectNicCount
AddDiskImage
}
		"*red67*" {
SelectNetConfig  #Sets network connection info
MakeImageNoPlanInfo_RedHat67
SelectNicCount
AddDiskImage
}
		"*w2k12*" {
SelectNetConfig  #Sets network connection info
MakeImageNoPlanInfo_w2k12
SelectNicCount
AddDiskImage
}
		"*sql*" {
SelectNetConfig  #Sets network connection info
MakeImageNoPlanInfo_sql2k16
SelectNicCount
AddDiskImage
}
		"*check*" {
SelectNetConfig  #Sets network connection info
MakeImagePlanInfo_Checkpoint
SelectNicCount
AddDiskImage
}
		"*cent*" {
SelectNetConfig  #Sets network connection info
MakeImageNoPlanInfo_CentOs
SelectNicCount
AddDiskImage
}
		"*Suse*" {
SelectNetConfig  #Sets network connection info
MakeImageNoPlanInfo_Suse
SelectNicCount
AddDiskImage
}
		"*w2k8*" {
SelectNetConfig  #Sets network connection info
MakeImageNoPlanInfo_w2k8
SelectNicCount
AddDiskImage
}
		"*w2k16*" {
SelectNetConfig  #Sets network connection info
MakeImageNoPlanInfo_w2k16
SelectNicCount
AddDiskImage
}
		default{"An unsupported image was referenced"}
	}

#End State Report

If ($Global:AvailabilitySet -eq "True"){
Write-Host "Completed - [VM]:$VMName [RG]:$ResourceGroupName [IMAGE]:$vmMarketImage [VNET]: $VNetName [VNETRG]: $vNetResourceGroupName [AVAILSET]: $AvailSetName"
Start-sleep 5
Get-AzureRmResource | where { $_.ResourceGroupName -eq$ResourceGroupName } | ft  "Name", "ResourceType" Format-Table
}
else
{
Write-Host "Completed - [VM]:$VMName [RG]:$ResourceGroupName [IMAGE]:$vmMarketImage [VNET]: $VNetName [VNETRG]: $vNetResourceGroupName"
Get-AzureRmResource | where { $_.ResourceGroupName -eq$ResourceGroupName } | ft  "Name", "ResourceType" | Format-Table
}

EndState