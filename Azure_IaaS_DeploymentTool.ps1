
<# 
.SYNOPSIS 
This script provides the following functionality for deploying IaaS environments in Azure. The script will deploy VNET in addition to numerour Market Place VMs or make use of an existing VNET.
Market Images supported: Redhat 6.7 and 7.2, PFSense 2.5, Windows 2008 R2, Windows 2012 R2, Ubuntu 14.04, CentOs 7.2, SUSE, SQL 2016 (on W2K12R2), R Server on Windows, Windows 2016 (Preview), Checkpoint Firewall,
.PARAMETERS
VMName is a required parameter at runtime. All other parameters are optional at runtime.
To deploy a VM to an existing VNET set the -NewVnet parameter to false. ** Update the -VNETResourceGroupName variable before running the script.
To deploy a new VNET with multiple subnets set the -NewVnet flag to true. ** The New VNET Will be deployed to -vNetResourceGroupName.
To deploy a Network Security Group to the VNET use the -NSGEnabled (True) and -NSGName (name of the NSG group) to create an NSG for the provisioned VNET.
To deploy a specific market image, enter one of the following names for -vmmMarketImage: Red67 Red72 Check PFSecure W2k12r2 w2k8r2 centos ubuntu chef SUSE SQL2K16 RSERVER
.SYNTAX
Required Parameters defined at Runtime
Azure_IaaS_Deploy.ps1 -vmname
Required Parameters defined in script
Azure_IaaS_Deploy.ps1 -vmname -VMMarketImage -ResourceGroupName -VNETName -VNETResourceGroupName -Location -SubscriberID -StorageType -StorageName -TenantID -InterfaceName1 -IntrerfaceName2 -NSGEnabled -VMSize -locadmin -locpassword 
Optional Parameters
Azure_IaaS_Deploy.ps1 -vmname -VMMarketImage -ResourceGroupName -VNETName -VNETResourceGroupName -NewVNet -NSGEnabled -NSGName
Azure_IaaS_Deploy.ps1 -vmname -VMMarketImage -ResourceGroupName -VNETName -VNETResourceGroupName -ExtMSAV
Azure_IaaS_Deploy.ps1 -vmname -VMMarketImage -ResourceGroupName -VNETName -VNETResourceGroupName -ExtVMAccess
.EXAMPLES
Deployment runtime positional parameters examples:

.\Azure_IaaS_Deploy.ps1 myserver RedHat myresgroup myvnet -NewVNET True
.\Azure_IaaS_Deploy.ps1 myserver2 RedHat myresgroup myvnet
.\Azure_IaaS_Deploy.ps1 myserver3 Suse myresgroup myvnet
.\Azure_IaaS_Deploy.ps1 myserver4 w2k12 myresgroup myvnet
.\Azure_IaaS_Deploy.ps1 myserver5 rserver myresgroup myvnet
.\Azure_IaaS_Deploy.ps1 myserver5 sql myresgroup myvnet

Runtime named parameters examples:
Deploy SQL Server 2016 to existing VNET in existing resource group  
.\Azure_IaaS_DeployTool.ps1 -VMName sqlserver1 -VMMarketImage SQL
--------------------------------------------------------------------------------------------------------
Deploy PFSense Server to existing VNET in existing resource group 
.\Azure_IaaS_DeployTool.ps1 -VMName pfserver1 -VMMarketImage Pfsense
--------------------------------------------------------------------------------------------------------
Deploy PFSense Server to a new VNET in new resource group 
.\Azure_IaaS_DeployTool.ps1 -VMName pfserver1 -VMMarketImage Pfsense -NewVNET True -VNETName NewVNET -ResourceGroupName INFRA_RG
--------------------------------------------------------------------------------------------------------
Deploy Windows 2012 R2 Server to a new VNET in new resource group
.\Azure_IaaS_DeployTool.ps1 -VMName winserver1 -VMMarketImage w2k12r2
#> 
[CmdletBinding()]
Param( 
 [Parameter(Mandatory=$False,ValueFromPipeline=$True,Position=1)]
 [string]
 $vmMarketImage = "Red72",

 [Parameter(Mandatory=$False,ValueFromPipeline=$True,Position=5)]
 [string]
 $NewVnet = "True",

 [Parameter(Mandatory=$False,ValueFromPipeline=$True,Position=0)]
 [string]
 $VMName = 'mynewvm1',

 [Parameter(Mandatory=$False,ValueFromPipeline=$True)]
 [string]
 $VM = ($VMName | Out-String),
 
 [Parameter(Mandatory=$False,ValueFromPipelinebyPropertyName=$true)]
 [string]
 $GenerateName = -join ((65..90) + (97..122) | Get-Random -Count 3 | % {[char]$_}) + "aip",

 [Parameter(Mandatory=$False,ValueFromPipelinebyPropertyName=$true)]
 [string]
 $StorageName = $VMName + "aip",
 
 [Parameter(Mandatory=$False,ValueFromPipelinebyPropertyName=$true)]
 [string]
 $InterfaceName1 = $VMName + "nic1",
 
 [Parameter(Mandatory=$False,ValueFromPipelinebyPropertyName=$true)]
 [string]
 $InterfaceName2 = $VMName + "nic2",

 [Parameter(Mandatory=$False,ValueFromPipeline=$True,Position=2)]
 [string]
 $ResourceGroupName = "RESGRP",

 [Parameter(Mandatory=$False,ValueFromPipeline=$True,Position=4)]
 [string]
 $vNetResourceGroupName = $ResourceGroupName,

 [Parameter(Mandatory=$False,ValueFromPipeline=$True,Position=3)]
 [string]
 $VNetName = "VNET",

 [Parameter(Mandatory=$False,ValueFromPipelinebyPropertyName=$true)]
 [string]
 $VMSize = "Standard_A3",

 [Parameter(Mandatory=$False,ValueFromPipelinebyPropertyName=$true)]
 [string]
 $locadmin = 'localadmin',

 [Parameter(Mandatory=$False)]
 [string]
 $locpassword = 'PassW0rd!@1',

 [Parameter(Mandatory=$False,ValueFromPipeline=$True,Position=6)]
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

 [Parameter(Mandatory=$False,ValueFromPipelinebyPropertyName=$true)]
 [string]
 $StorageType = "Standard_GRS",

 [Parameter(Mandatory=$False,ValueFromPipelinebyPropertyName=$true)]
 [string]
 $NSGName = "AIPNSG",

 [Parameter(Mandatory=$False,ValueFromPipelinebyPropertyName=$true)]
 [string]
 $ExtMSAV = "False",
 
 [Parameter(Mandatory=$False,ValueFromPipelinebyPropertyName=$true)]
 [string]
 $ExtVMAccess = "False"
)

# Login-AzureRmAccount
# Set-AzureRmContext -subscriptionid $SubscriptionID -TenantId $TenantID
Add-AzureRmAccount -TenantId $TenantID

Function Create-ResourceGroups {
	param()
	BEGIN {
{
}
}
	PROCESS {
Write-Host "Create/Update Resource Groups"
New-AzureRmResourceGroup -Name $ResourceGroupName -Location $Location -force | ft ResourceGroupName
New-AzureRmResourceGroup -Name $vNetResourceGroupName -Location $Location -force | ft ResourceGroupName
    }
    END {}
}
Function Create-Network {
	param()
	BEGIN {
{
}
}
	PROCESS {
		Write-Host "Network Preparation in Process"
$subnet1 = New-AzureRmVirtualNetworkSubnetConfig -AddressPrefix 10.51.0.0/24 -Name enablement
$subnet2 = New-AzureRmVirtualNetworkSubnetConfig -AddressPrefix 10.51.1.0/24 -Name Public
$subnet3 = New-AzureRmVirtualNetworkSubnetConfig -AddressPrefix 10.51.2.0/24 -Name ingest
$subnet4 = New-AzureRmVirtualNetworkSubnetConfig -AddressPrefix 10.51.3.0/24 -Name data
$subnet5 = New-AzureRmVirtualNetworkSubnetConfig -AddressPrefix 10.51.4.0/24 -Name monitoring
$subnet6 = New-AzureRmVirtualNetworkSubnetConfig -AddressPrefix 10.51.5.0/24 -Name analytics
$subnet7 = New-AzureRmVirtualNetworkSubnetConfig -AddressPrefix 10.51.6.0/24 -Name backup
$subnet8 = New-AzureRmVirtualNetworkSubnetConfig -AddressPrefix 10.51.7.0/24 -Name management
New-AzureRmVirtualNetwork -Location WestUS -Name $VNetName -ResourceGroupName $vNetResourceGroupName -AddressPrefix '10.51.0.0/21' -Subnet $subnet1,$subnet2,$subnet3,$subnet4, $subnet5, $subnet6, $subnet7 -Force;
Write-Host "Completed deployment of new VNET"
    }
    END {}
}
Function Create-NSG {
	param()
	BEGIN {
Write-Host "Network Security Group Preparation in Process"
{
}
}
	PROCESS {
$httprule = New-AzureRmNetworkSecurityRuleConfig -Name "FrontEnd_HTTP" -Description "HTTP Exception for Web frontends" -Protocol Tcp -SourcePortRange "80" -DestinationPortRange "80" -SourceAddressPrefix "*" -DestinationAddressPrefix "10.51.0.0/21" -Access Allow -Direction Inbound -Priority 200 -Verbose
$httpsrule = New-AzureRmNetworkSecurityRuleConfig -Name "FrontEnd_HTTPS" -Description "HTTPS Exception for Web frontends" -Protocol Tcp -SourcePortRange "443" -DestinationPortRange "443" -SourceAddressPrefix "*" -DestinationAddressPrefix "10.51.0.0/21" -Access Allow -Direction Inbound -Priority 201 -Verbose
$sshrule = New-AzureRmNetworkSecurityRuleConfig -Name "FrontEnd_SSH" -Description "SSH Exception for Web frontends" -Protocol Tcp -SourcePortRange "22" -DestinationPortRange "22" -SourceAddressPrefix "*" -DestinationAddressPrefix "10.51.0.0/21" -Access Allow -Direction Inbound ` -Priority 203 -Verbose
$nsg = New-AzureRmNetworkSecurityGroup -ResourceGroupName $vNetResourceGroupName -Location "West US" -Name $NSGName -SecurityRules $httprule,$httpsrule, $sshrule -force -Verbose
    }
    END {
    Write-Host "Network Security Group Preparation complete"
    Get-AzureRmNetworkSecurityGroup -Name $NSGName -ResourceGroupName $vNetResourceGroupName | ft "Name"
    }
}
Function Create-Image {
	param(
 [Parameter(Mandatory=$False,ValueFromPipeline=$True)]
 [string[]]
 $VMNames = $VMName
)
	BEGIN {
$SecureLocPassword=Convertto-SecureString $locpassword –asplaintext -force
$Credential1 = New-Object System.Management.Automation.PSCredential ($locadmin,$SecureLocPassword)

$StorageAccount = New-AzureRmStorageAccount -ResourceGroupName $ResourceGroupName -Name $StorageName.ToLower() -Type $StorageType -Location $Location

switch -Wildcard ($vmMarketImage)
    {
        "*pf*" {
Write-Host "PfSense VM Image Preparation in Process"
$PIp = New-AzureRmPublicIpAddress -Name $InterfaceName1 -ResourceGroupName $ResourceGroupName -Location $Location -AllocationMethod "Dynamic"
$VNet = Get-AzureRMVirtualNetwork -Name $VNetName -ResourceGroupName $vNetResourceGroupName | Set-AzureRmVirtualNetwork
$Interface1 = New-AzureRmNetworkInterface -Name $InterfaceName1 -ResourceGroupName $ResourceGroupName -Location $Location -SubnetId $VNet.Subnets[1].Id -PublicIpAddressId $PIp.Id
$Interface2 = New-AzureRmNetworkInterface -Name $InterfaceName2 -ResourceGroupName $ResourceGroupName -Location $Location -SubnetId $VNet.Subnets[2].Id
$VirtualMachine = New-AzureRmVMConfig -VMName $VMName -VMSize $VMSize
$VirtualMachine = Set-AzureRmVMPlan -VM $VirtualMachine -Name pfsense-router-fw-vpn-225 -Publisher netgate -Product netgate-pfsense-appliance
$VirtualMachine = Set-AzureRmVMOperatingSystem -VM $VirtualMachine -linux -ComputerName $VMName -Credential $Credential1
$VirtualMachine = Set-AzureRmVMSourceImage -VM $VirtualMachine -PublisherName netgate -Offer netgate-pfsense-appliance -Skus pfsense-router-fw-vpn-225 -Version "latest"
$VirtualMachine = Add-AzureRmVMNetworkInterface -VM $VirtualMachine -Id $Interface1.Id -Primary
$VirtualMachine = Add-AzureRmVMNetworkInterface -VM $VirtualMachine -Id $Interface2.Id
$OSDiskName = $VMName + "OSDisk"
$OSDiskUri = $StorageAccount.PrimaryEndpoints.Blob.ToString() + "vhds/" + $OSDiskName + ".vhd"
$VirtualMachine = Set-AzureRmVMOSDisk -VM $VirtualMachine -Name $OSDiskName -VhdUri $OSDiskUri -CreateOption "FromImage" -Caching $osDiskCaching
}
        "*red72*" {
Write-Host "Red Hat 7.2 VM Image Preparation in Process"
$PIp = New-AzureRmPublicIpAddress -Name $InterfaceName1 -ResourceGroupName $ResourceGroupName -Location $Location -AllocationMethod "Dynamic"
$VNet = Get-AzureRMVirtualNetwork -Name $VNetName -ResourceGroupName $vNetResourceGroupName | Set-AzureRmVirtualNetwork
$Interface1 = New-AzureRmNetworkInterface -Name $InterfaceName1 -ResourceGroupName $ResourceGroupName -Location $Location -SubnetId $VNet.Subnets[3].Id -PublicIpAddressId $PIp.Id
$VirtualMachine = New-AzureRmVMConfig -VMName $VMName -VMSize $VMSize
$VirtualMachine = Set-AzureRmVMOperatingSystem -VM $VirtualMachine -linux -ComputerName $VMName -Credential $Credential1
$VirtualMachine = Set-AzureRmVMSourceImage -VM $VirtualMachine -PublisherName "Redhat" -Offer "rhel" -Skus "7.2" -Version "latest"
$VirtualMachine = Add-AzureRmVMNetworkInterface -VM $VirtualMachine -Id $Interface1.Id -Primary
$OSDiskName = $VMName + "OSDisk"
$OSDiskUri = $StorageAccount.PrimaryEndpoints.Blob.ToString() + "vhds/" + $OSDiskName + ".vhd"
$VirtualMachine = Set-AzureRmVMOSDisk -VM $VirtualMachine -Name $OSDiskName -VhdUri $OSDiskUri -CreateOption "FromImage" -Caching $osDiskCaching
}
        "*red67*" {
Write-Host "Red Hat 6.7 VM Image Preparation in Process"
$PIp = New-AzureRmPublicIpAddress -Name $InterfaceName1 -ResourceGroupName $ResourceGroupName -Location $Location -AllocationMethod "Dynamic"
$VNet = Get-AzureRMVirtualNetwork -Name $VNetName -ResourceGroupName $vNetResourceGroupName | Set-AzureRmVirtualNetwork
$Interface1 = New-AzureRmNetworkInterface -Name $InterfaceName1 -ResourceGroupName $ResourceGroupName -Location $Location -SubnetId $VNet.Subnets[3].Id -PublicIpAddressId $PIp.Id
$VirtualMachine = New-AzureRmVMConfig -VMName $VMName -VMSize $VMSize
$VirtualMachine = Set-AzureRmVMOperatingSystem -VM $VirtualMachine -linux -ComputerName $VMName -Credential $Credential1
$VirtualMachine = Set-AzureRmVMSourceImage -VM $VirtualMachine -PublisherName "Redhat" -Offer "rhel" -Skus "6.7" -Version "latest"
$VirtualMachine = Add-AzureRmVMNetworkInterface -VM $VirtualMachine -Id $Interface1.Id -Primary
$OSDiskName = $VMName + "OSDisk"
$OSDiskUri = $StorageAccount.PrimaryEndpoints.Blob.ToString() + "vhds/" + $OSDiskName + ".vhd"
$VirtualMachine = Set-AzureRmVMOSDisk -VM $VirtualMachine -Name $OSDiskName -VhdUri $OSDiskUri -CreateOption "FromImage" -Caching $osDiskCaching
}
        "*MySql*" {
Write-Host "MySql VM Image Preparation in Process"
$PIp = New-AzureRmPublicIpAddress -Name $InterfaceName1 -ResourceGroupName $ResourceGroupName -Location $Location -AllocationMethod "Dynamic"
$VNet = Get-AzureRMVirtualNetwork -Name $VNetName -ResourceGroupName $vNetResourceGroupName | Set-AzureRmVirtualNetwork
$Interface1 = New-AzureRmNetworkInterface -Name $InterfaceName1 -ResourceGroupName $ResourceGroupName -Location $Location -SubnetId $VNet.Subnets[3].Id -PublicIpAddressId $PIp.Id
$VirtualMachine = New-AzureRmVMConfig -VMName $VMName -VMSize $VMSize
$VirtualMachine = Set-AzureRmVMOperatingSystem -VM $VirtualMachine -linux -ComputerName $VMName -Credential $Credential1
$VirtualMachine = Set-AzureRmVMSourceImage -VM $VirtualMachine -PublisherName "Bitnami" -Offer "mysql" -Skus "5-6" -Version "latest"
$VirtualMachine = Add-AzureRmVMNetworkInterface -VM $VirtualMachine -Id $Interface1.Id -Primary
$OSDiskName = $VMName + "OSDisk"
$OSDiskUri = $StorageAccount.PrimaryEndpoints.Blob.ToString() + "vhds/" + $OSDiskName + ".vhd"
$VirtualMachine = Set-AzureRmVMOSDisk -VM $VirtualMachine -Name $OSDiskName -VhdUri $OSDiskUri -CreateOption "FromImage" -Caching $osDiskCaching
}
        "*w2k12*" {
Write-Host "Windows VM Image Preparation in Process"
$PIp = New-AzureRmPublicIpAddress -Name $InterfaceName1 -ResourceGroupName $ResourceGroupName -Location $Location -AllocationMethod "Dynamic"
$VNet = Get-AzureRMVirtualNetwork -Name $VNetName -ResourceGroupName $vNetResourceGroupName | Set-AzureRmVirtualNetwork
$Interface1 = New-AzureRmNetworkInterface -Name $InterfaceName1 -ResourceGroupName $ResourceGroupName -Location $Location -SubnetId $VNet.Subnets[3].Id -PublicIpAddressId $PIp.Id
$VirtualMachine = New-AzureRmVMConfig -VMName $VMName -VMSize $VMSize
$VirtualMachine = Set-AzureRmVMOperatingSystem -VM $VirtualMachine -Windows -ComputerName $VMName -Credential $Credential1 -ProvisionVMAgent -EnableAutoUpdate
$VirtualMachine = Set-AzureRmVMSourceImage -VM $VirtualMachine -PublisherName "MicrosoftWindowsServer" -Offer "WindowsServer" -Skus "2012-R2-Datacenter" -Version "latest"
$VirtualMachine = Add-AzureRmVMNetworkInterface -VM $VirtualMachine -Id $Interface1.Id -Primary
$OSDiskName = $VMName + "OSDisk"
$OSDiskUri = $StorageAccount.PrimaryEndpoints.Blob.ToString() + "vhds/" + $OSDiskName + ".vhd"
$VirtualMachine = Set-AzureRmVMOSDisk -VM $VirtualMachine -Name $OSDiskName -VhdUri $OSDiskUri -CreateOption "FromImage" -Caching $osDiskCaching
}
        "*sql2k16*" {
Write-Host "SQL VM Image Preparation in Process"
$PIp = New-AzureRmPublicIpAddress -Name $InterfaceName1 -ResourceGroupName $ResourceGroupName -Location $Location -AllocationMethod "Dynamic"
$VNet = Get-AzureRMVirtualNetwork -Name $VNetName -ResourceGroupName $vNetResourceGroupName | Set-AzureRmVirtualNetwork
$Interface1 = New-AzureRmNetworkInterface -Name $InterfaceName1 -ResourceGroupName $ResourceGroupName -Location $Location -SubnetId $VNet.Subnets[4].Id -PublicIpAddressId $PIp.Id
$VirtualMachine = New-AzureRmVMConfig -VMName $VMName -VMSize $VMSize
$VirtualMachine = Set-AzureRmVMOperatingSystem -VM $VirtualMachine -Windows -ComputerName $VMName -Credential $Credential1 -ProvisionVMAgent -EnableAutoUpdate
$VirtualMachine = Set-AzureRmVMSourceImage -VM $VirtualMachine -PublisherName "MicrosoftSQLServer" -Offer "SQL2016-WS2012R2" -Skus "Enterprise" -Version "latest"
$VirtualMachine = Add-AzureRmVMNetworkInterface -VM $VirtualMachine -Id $Interface1.Id -Primary
$OSDiskName = $VMName + "OSDisk"
$OSDiskUri = $StorageAccount.PrimaryEndpoints.Blob.ToString() + "vhds/" + $OSDiskName + ".vhd"
$VirtualMachine = Set-AzureRmVMOSDisk -VM $VirtualMachine -Name $OSDiskName -VhdUri $OSDiskUri -CreateOption "FromImage" -Caching $osDiskCaching
}
        "*rserver*" {
Write-Host "R Server VM Image Preparation in Process"
$PIp = New-AzureRmPublicIpAddress -Name $InterfaceName1 -ResourceGroupName $ResourceGroupName -Location $Location -AllocationMethod "Dynamic"
$VNet = Get-AzureRMVirtualNetwork -Name $VNetName -ResourceGroupName $vNetResourceGroupName | Set-AzureRmVirtualNetwork
$Interface1 = New-AzureRmNetworkInterface -Name $InterfaceName1 -ResourceGroupName $ResourceGroupName -Location $Location -SubnetId $VNet.Subnets[6].Id -PublicIpAddressId $PIp.Id
$VirtualMachine = New-AzureRmVMConfig -VMName $VMName -VMSize $VMSize
$VirtualMachine = Set-AzureRmVMPlan -VM $VirtualMachine -Name msr80-win2012r2 -Publisher microsoft-r-products -Product microsoft-r-server
$VirtualMachine = Set-AzureRmVMOperatingSystem -VM $VirtualMachine -Windows -ComputerName $VMName -Credential $Credential1 -ProvisionVMAgent -EnableAutoUpdate
$VirtualMachine = Set-AzureRmVMSourceImage -VM $VirtualMachine -PublisherName microsoft-r-products -Offer microsoft-r-server -Skus msr80-win2012r2 -Version "latest"
$VirtualMachine = Add-AzureRmVMNetworkInterface -VM $VirtualMachine -Id $Interface1.Id -Primary
$OSDiskName = $VMName + "OSDisk"
$OSDiskUri = $StorageAccount.PrimaryEndpoints.Blob.ToString() + "vhds/" + $OSDiskName + ".vhd"
$VirtualMachine = Set-AzureRmVMOSDisk -VM $VirtualMachine -Name $OSDiskName -VhdUri $OSDiskUri -CreateOption "FromImage" -Caching $osDiskCaching
}
        "*w2k8*" {
Write-Host "Windows 2008 R2 VM Image Preparation in Process"
$PIp = New-AzureRmPublicIpAddress -Name $InterfaceName1 -ResourceGroupName $ResourceGroupName -Location $Location -AllocationMethod "Dynamic"
$VNet = Get-AzureRMVirtualNetwork -Name $VNetName -ResourceGroupName $vNetResourceGroupName | Set-AzureRmVirtualNetwork
$Interface1 = New-AzureRmNetworkInterface -Name $InterfaceName1 -ResourceGroupName $ResourceGroupName -Location $Location -SubnetId $VNet.Subnets[3].Id -PublicIpAddressId $PIp.Id
$VirtualMachine = New-AzureRmVMConfig -VMName $VMName -VMSize $VMSize
$VirtualMachine = Set-AzureRmVMOperatingSystem -VM $VirtualMachine -Windows -ComputerName $VMName -Credential $Credential1 -ProvisionVMAgent -EnableAutoUpdate
$VirtualMachine = Set-AzureRmVMSourceImage -VM $VirtualMachine -PublisherName "MicrosoftWindowsServer" -Offer "WindowsServer" -Skus "2008-R2-SP1" -Version "latest"
$VirtualMachine = Add-AzureRmVMNetworkInterface -VM $VirtualMachine -Id $Interface1.Id -Primary
$OSDiskName = $VMName + "OSDisk"
$OSDiskUri = $StorageAccount.PrimaryEndpoints.Blob.ToString() + "vhds/" + $OSDiskName + ".vhd"
$VirtualMachine = Set-AzureRmVMOSDisk -VM $VirtualMachine -Name $OSDiskName -VhdUri $OSDiskUri -CreateOption "FromImage" -Caching $osDiskCaching
}
        "*w2k16*" {
Write-Host "Windows Server Preview VM Image Preparation in Process"
$PIp = New-AzureRmPublicIpAddress -Name $InterfaceName1 -ResourceGroupName $ResourceGroupName -Location $Location -AllocationMethod "Dynamic"
$VNet = Get-AzureRMVirtualNetwork -Name $VNetName -ResourceGroupName $vNetResourceGroupName | Set-AzureRmVirtualNetwork
$Interface1 = New-AzureRmNetworkInterface -Name $InterfaceName1 -ResourceGroupName $ResourceGroupName -Location $Location -SubnetId $VNet.Subnets[3].Id -PublicIpAddressId $PIp.Id
$VirtualMachine = New-AzureRmVMConfig -VMName $VMName -VMSize $VMSize
$VirtualMachine = Set-AzureRmVMOperatingSystem -VM $VirtualMachine -Windows -ComputerName $VMName -Credential $Credential1 -ProvisionVMAgent -EnableAutoUpdate
$VirtualMachine = Set-AzureRmVMSourceImage -VM $VirtualMachine -PublisherName "MicrosoftWindowsServer" -Offer "WindowsServer" -Skus "Windows-Server-Technical-Preview" -Version "latest"
$VirtualMachine = Add-AzureRmVMNetworkInterface -VM $VirtualMachine -Id $Interface1.Id -Primary
$OSDiskName = $VMName + "OSDisk"
$OSDiskUri = $StorageAccount.PrimaryEndpoints.Blob.ToString() + "vhds/" + $OSDiskName + ".vhd"
$VirtualMachine = Set-AzureRmVMOSDisk -VM $VirtualMachine -Name $OSDiskName -VhdUri $OSDiskUri -CreateOption "FromImage" -Caching $osDiskCaching
}
        "*chef*" {
Write-Host "Chef VM Image Preparation in Process"
$PIp = New-AzureRmPublicIpAddress -Name $InterfaceName1 -ResourceGroupName $ResourceGroupName -Location $Location -AllocationMethod "Dynamic"
$VNet = Get-AzureRMVirtualNetwork -Name $VNetName -ResourceGroupName $vNetResourceGroupName | Set-AzureRmVirtualNetwork
$Interface1 = New-AzureRmNetworkInterface -Name $InterfaceName1 -ResourceGroupName $ResourceGroupName -Location $Location -SubnetId $VNet.Subnets[5].Id -PublicIpAddressId $PIp.Id
$VirtualMachine = New-AzureRmVMConfig -VMName $VMName -VMSize $VMSize
$VirtualMachine = Set-AzureRmVMPlan -VM $VirtualMachine -Name azure_marketplace_100 -Publisher chef-software -Product chef-server
$VirtualMachine = Set-AzureRmVMSourceImage -VM $VirtualMachine -PublisherName chef-software -Offer chef-server -Skus azure_marketplace_100 -Version "latest"
$VirtualMachine = Set-AzureRmVMOperatingSystem -VM $VirtualMachine -linux -ComputerName $VMName -Credential $Credential1
$VirtualMachine = Add-AzureRmVMNetworkInterface -VM $VirtualMachine -Id $Interface1.Id -Primary
$OSDiskName = $VMName + "OSDisk"
$OSDiskUri = $StorageAccount.PrimaryEndpoints.Blob.ToString() + "vhds/" + $OSDiskName + ".vhd"
$VirtualMachine = Set-AzureRmVMOSDisk -VM $VirtualMachine -Name $OSDiskName -VhdUri $OSDiskUri -CreateOption "FromImage" -Caching $osDiskCaching
}
        "*cent*" {
Write-Host "Centos VM Image Preparation in Process"
$PIp = New-AzureRmPublicIpAddress -Name $InterfaceName1 -ResourceGroupName $ResourceGroupName -Location $Location -AllocationMethod "Dynamic"
$VNet = Get-AzureRMVirtualNetwork -Name $VNetName -ResourceGroupName $vNetResourceGroupName | Set-AzureRmVirtualNetwork
$Interface1 = New-AzureRmNetworkInterface -Name $InterfaceName1 -ResourceGroupName $ResourceGroupName -Location $Location -SubnetId $VNet.Subnets[6].Id -PublicIpAddressId $PIp.Id
$VirtualMachine = New-AzureRmVMConfig -VMName $VMName -VMSize $VMSize
$VirtualMachine = Set-AzureRmVMSourceImage -VM $VirtualMachine -PublisherName OpenLogic -Offer Centos -Skus "7.2" -Version "latest"
$VirtualMachine = Set-AzureRmVMOperatingSystem -VM $VirtualMachine -linux -ComputerName $VMName -Credential $Credential1
$VirtualMachine = Add-AzureRmVMNetworkInterface -VM $VirtualMachine -Id $Interface1.Id -Primary
$OSDiskName = $VMName + "OSDisk"
$OSDiskUri = $StorageAccount.PrimaryEndpoints.Blob.ToString() + "vhds/" + $OSDiskName + ".vhd"
$VirtualMachine = Set-AzureRmVMOSDisk -VM $VirtualMachine -Name $OSDiskName -VhdUri $OSDiskUri -CreateOption "FromImage" -Caching $osDiskCaching
}
        "*ub*" {
Write-Host "Ubuntu VM Image Preparation in Process"
$PIp = New-AzureRmPublicIpAddress -Name $InterfaceName1 -ResourceGroupName $ResourceGroupName -Location $Location -AllocationMethod "Dynamic"
$VNet = Get-AzureRMVirtualNetwork -Name $VNetName -ResourceGroupName $vNetResourceGroupName | Set-AzureRmVirtualNetwork
$Interface1 = New-AzureRmNetworkInterface -Name $InterfaceName1 -ResourceGroupName $ResourceGroupName -Location $Location -SubnetId $VNet.Subnets[6].Id -PublicIpAddressId $PIp.Id
$VirtualMachine = New-AzureRmVMConfig -VMName $VMName -VMSize $VMSize
$VirtualMachine = Set-AzureRmVMSourceImage -VM $VirtualMachine -PublisherName Canonical -Offer UbuntuServer -Skus "14.04.4-LTS" -Version "latest"
$VirtualMachine = Set-AzureRmVMOperatingSystem -VM $VirtualMachine -linux -ComputerName $VMName -Credential $Credential1
$VirtualMachine = Add-AzureRmVMNetworkInterface -VM $VirtualMachine -Id $Interface1.Id -Primary
$OSDiskName = $VMName + "OSDisk"
$OSDiskUri = $StorageAccount.PrimaryEndpoints.Blob.ToString() + "vhds/" + $OSDiskName + ".vhd"
$VirtualMachine = Set-AzureRmVMOSDisk -VM $VirtualMachine -Name $OSDiskName -VhdUri $OSDiskUri -CreateOption "FromImage" -Caching $osDiskCaching
}
        "*SU*" {
Write-Host "Open SUSE VM Image Preparation in Process"
$PIp = New-AzureRmPublicIpAddress -Name $InterfaceName1 -ResourceGroupName $ResourceGroupName -Location $Location -AllocationMethod "Dynamic"
$VNet = Get-AzureRMVirtualNetwork -Name $VNetName -ResourceGroupName $vNetResourceGroupName | Set-AzureRmVirtualNetwork
$Interface1 = New-AzureRmNetworkInterface -Name $InterfaceName1 -ResourceGroupName $ResourceGroupName -Location $Location -SubnetId $VNet.Subnets[6].Id -PublicIpAddressId $PIp.Id
$VirtualMachine = New-AzureRmVMConfig -VMName $VMName -VMSize $VMSize
$VirtualMachine = Set-AzureRmVMSourceImage -VM $VirtualMachine -PublisherName SUSE -Offer openSUSE -Skus "13.2" -Version "latest"
$VirtualMachine = Set-AzureRmVMOperatingSystem -VM $VirtualMachine -linux -ComputerName $VMName -Credential $Credential1
$VirtualMachine = Add-AzureRmVMNetworkInterface -VM $VirtualMachine -Id $Interface1.Id -Primary
$OSDiskName = $VMName + "OSDisk"
$OSDiskUri = $StorageAccount.PrimaryEndpoints.Blob.ToString() + "vhds/" + $OSDiskName + ".vhd"
$VirtualMachine = Set-AzureRmVMOSDisk -VM $VirtualMachine -Name $OSDiskName -VhdUri $OSDiskUri -CreateOption "FromImage" -Caching $osDiskCaching
}
        "*check*" {
Write-Host "CheckPoint VM Image Preparation in Process"
$PIp = New-AzureRmPublicIpAddress -Name $InterfaceName1 -ResourceGroupName $ResourceGroupName -Location $Location -AllocationMethod "Dynamic"
$VNet = Get-AzureRMVirtualNetwork -Name $VNetName -ResourceGroupName $vNetResourceGroupName | Set-AzureRmVirtualNetwork
$Interface1 = New-AzureRmNetworkInterface -Name $InterfaceName1 -ResourceGroupName $ResourceGroupName -Location $Location -SubnetId $VNet.Subnets[1].Id -PublicIpAddressId $PIp.Id
$Interface2 = New-AzureRmNetworkInterface -Name $InterfaceName2 -ResourceGroupName $ResourceGroupName -Location $Location -SubnetId $VNet.Subnets[2].Id
$VirtualMachine = New-AzureRmVMConfig -VMName $VMName -VMSize $VMSize
$VirtualMachine = Set-AzureRmVMPlan -VM $VirtualMachine -Name sg-ngtp -Publisher checkpoint -Product check-point-r77-10
$VirtualMachine = Set-AzureRmVMSourceImage -VM $VirtualMachine -PublisherName checkpoint -Offer check-point-r77-10 -Skus sg-ngtp -Version "latest"
$VirtualMachine = Set-AzureRmVMOperatingSystem -VM $VirtualMachine -linux -ComputerName $VMName -Credential $Credential1
$VirtualMachine = Add-AzureRmVMNetworkInterface -VM $VirtualMachine -Id $Interface1.Id -Primary
$VirtualMachine = Add-AzureRmVMNetworkInterface -VM $VirtualMachine -Id $Interface2.Id
$OSDiskName = $VMName + "OSDisk"
$OSDiskUri = $StorageAccount.PrimaryEndpoints.Blob.ToString() + "vhds/" + $OSDiskName + ".vhd"
$VirtualMachine = Set-AzureRmVMOSDisk -VM $VirtualMachine -Name $OSDiskName -VhdUri $OSDiskUri -CreateOption "FromImage" -Caching $osDiskCaching
}
        default{"An unsupported image was referenced"}
    }

}

	PROCESS {
		Foreach ($VM in $VMName) {

Write-Host "Starting VM Creation"
New-AzureRmVM -ResourceGroupName $ResourceGroupName -Location $Location -VM $VirtualMachine -Verbose

		}
    }
    END {
    Write-Host "Completing VM Deployment"
    }
}
Function Ext-VMAccess {
	param()
	BEGIN {
}
	PROCESS {
Write-Host "Adding VM Access Extensions"
Write-Host "VM access extensions installing"
Set-AzureRmVMExtension -ResourceGroupName $ResourceGroupName -VMName $VMName -Name "VMAccess" -ExtensionType "VMAccessAgent" -Publisher "Microsoft.Compute" -typeHandlerVersion "2.0" -Location Westus -Verbose
Set-AzureRmVMAccessExtension -ResourceGroupName $ResourceGroupName -VMName $VMName -Name "VMAccess" -Location Westus -Verbose
Get-AzureRmVMExtension -ResourceGroupName $ResourceGroupName -VMName $VMName -Name "VMAccess"
Write-Host "VM access Preparation complete"
    }
    END {}
}
Function Ext-MSAV {
	param()
	BEGIN {
}
	PROCESS {
Write-Host "Adding MSAV Extensions"
Write-Host "MSAV Agent Preparation in Process"
Set-AzureRmVMExtension  -ResourceGroupName $ResourceGroupName -VMName $VMName -Name "MSAVExtension" -ExtensionType "IaaSAntimalware" -Publisher "Microsoft.Azure.Security" -typeHandlerVersion 1.4 -Location $Location
Set-AzureRmVMAccessExtension -ResourceGroupName $ResourceGroupName -VMName $VMName -Name "MSAVExtension" -Location Westus
Get-AzureRmVMExtension -ResourceGroupName $ResourceGroupName -VMName $VMName -Name "MSAVExtension" -Status
Write-Host "MSAV Agent Preparation complete"
    }
    END {}
}

If($ResourceGroupName -ne $null) {Create-ResourceGroups}
If($NewVnet -eq "True"){Create-Network}
If($NSGEnabled -eq "True"){Create-NSG}
If($VMName -ne $null) {Create-Image}
If($ExtMSAV -eq "True"){Ext-VMSAv}
If($ExtVMAccess -eq "True"){Ext-VMAccess}

Get-AzureRmVirtualNetwork -Name $VNetName -ResourceGroupName $vNetResourceGroupName | ft "Name"
Get-AzureRmVirtualNetwork -Name $VNetName -ResourceGroupName $vNetResourceGroupName | Get-AzureRmVirtualNetworkSubnetConfig | ft "addressprefix"

Get-AzureRmPublicIpAddress -Name $InterfaceName1 -ResourceGroupName $ResourceGroupName | ft "IpAddress"
Write-Host "Remote Access available via IP Address above"
