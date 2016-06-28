<# 
.SYNOPSIS 
This script provides the following functionality for deploying IaaS environments in Azure. The script will deploy VNET in addition to numerour Market Place VMs or make use of an existing VNET.
Market Images supported: Redhat 6.7, PFSense 2.5, Windows 2008 R2, Windows 2012 R2, Ubuntu 14.04, CentOs 7.2, SUSE, SQL 2016 (on W2K12R2), R Server on Windows and Chef Server v12
.PARAMETERS
VMName is a required parameter at runtime. All other parameters are optional at runtime.
To deploy a VM to an existing VNET set the -NewVnet parameter to false. ** Update the -VNETResourceGroupName variable before running the script.
To deploy a new VNET with multiple subnets set the -NewVnet flag to true. ** The New VNET Will be deployed to -vNetResourceGroupName.
To deploy a Network Security Group to the VNET use the -NSGEnabled (True) and -NSGName (name of the NSG group) to create an NSG for the provisioned VNET.
To deploy a specific market image, enter one of the following names for -vmmMarketImage: Redhat PFSecure W2k12r2 w2k8r2 centos ubuntu chef SUSE SQL RSERVER
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
.\Azure_IaaS_DeployTool.ps1 -VName sqlserver1 -VMMarketImage SQL
--------------------------------------------------------------------------------------------------------
Deploy PFSense Server to existing VNET in existing resource group 
.\Azure_IaaS_DeployTool.ps1 -VName pfserver1 -VMMarketImage Pfsense
--------------------------------------------------------------------------------------------------------
Deploy PFSense Server to a new VNET in new resource group 
.\Azure_IaaS_DeployTool.ps1 -VName pfserver1 -VMMarketImage Pfsense -NewVNET True -VNETName NewVNET -ResourceGroupName INFRA_RG
--------------------------------------------------------------------------------------------------------
Deploy Windows 2012 R2 Server to a new VNET in new resource group
.\Azure_IaaS_DeployTool.ps1 -VName winserver1 -VMMarketImage w2k12r2
#> 

Param( 
 [Parameter(Mandatory=$False,ValueFromPipeline=$True,Position=1)]
 [string]
 $vmMarketImage = "PFSense",

 [Parameter(Mandatory=$False,ValueFromPipeline=$True,Position=5)]
 [string]
 $NewVnet = "False",

 [Parameter(Mandatory=$True,ValueFromPipeline=$True,Position=0)]
 [string]
 $VMName = "server0001",

 [Parameter(Mandatory=$False,ValueFromPipeline=$True,Position=2)]
 [string]
 $ResourceGroupName = "RESGRP",

 [Parameter(Mandatory=$False,ValueFromPipeline=$True,Position=4)]
 [string]
 $vNetResourceGroupName = $ResourceGroupName,

 [Parameter(Mandatory=$False,ValueFromPipeline=$True,Position=3)]
 [string]
 $VNetName = "VNET",

 [Parameter(Mandatory=$False,ValueFromPipeline=$True)]
 [string]
 $VMSize = "Standard_A3",

 [Parameter(Mandatory=$False,ValueFromPipeline=$True)]
 [string]
 $locadmin = 'localadmin',

 [Parameter(Mandatory=$False)]
 [string]
 $locpassword = 'PassW0rd!@1',

 [Parameter(Mandatory=$False,ValueFromPipeline=$True,Position=6)]
 [string]
 $NSGEnabled = "False",

 [Parameter(Mandatory=$False,ValueFromPipeline=$True)]
 [string]
 $Location = "WestUs",

 [Parameter(Mandatory=$False,ValueFromPipeline=$True)]
 [string]
 $SubscriptionID = '',

 [Parameter(Mandatory=$False,ValueFromPipeline=$True)]
 [string]
 $TenantID = '',

 [Parameter(Mandatory=$False,ValueFromPipeline=$True)]
 [string]
 $StorageName = $VMName + "str",

 [Parameter(Mandatory=$False,ValueFromPipeline=$True)]
 [string]
 $StorageType = "Standard_GRS",

 [Parameter(Mandatory=$False,ValueFromPipeline=$True)]
 [string]
 $InterfaceName1 = $VMName + "nic1",

 [Parameter(Mandatory=$False,ValueFromPipeline=$True)]
 [string]
 $InterfaceName2 = $VMName + "nic2",

 [Parameter(Mandatory=$False,ValueFromPipeline=$True)]
 [string]
 $NSGName = "NSG",

 [Parameter(Mandatory=$False,ValueFromPipeline=$True)]
 [string]
 $ExtMSAV = "False",
 
 [Parameter(Mandatory=$False,ValueFromPipeline=$True)]
 [string]
 $ExtVMAccess = "False"

)
## Global
$SecureLocPassword=Convertto-SecureString $locpassword –asplaintext -force
$Credential1 = New-Object System.Management.Automation.PSCredential ($locadmin,$SecureLocPassword)

Login-AzureRmAccount
Set-AzureRmContext -tenantid $TenantID -subscriptionid $SubscriptionID

# Resource Group
New-AzureRmResourceGroup -Name $ResourceGroupName -Location $Location -force
New-AzureRmResourceGroup -Name $vNetResourceGroupName -Location $Location -force

If($NewVnet -eq "True")
{
## Create Virtual Network
Write-Host "Network Deployment in Progress"
$subnet1 = New-AzureRmVirtualNetworkSubnetConfig -AddressPrefix 10.51.0.0/24 -Name enablement
$subnet2 = New-AzureRmVirtualNetworkSubnetConfig -AddressPrefix 10.51.1.0/24 -Name Public
$subnet3 = New-AzureRmVirtualNetworkSubnetConfig -AddressPrefix 10.51.2.0/24 -Name ingest
$subnet4 = New-AzureRmVirtualNetworkSubnetConfig -AddressPrefix 10.51.3.0/24 -Name data
$subnet5 = New-AzureRmVirtualNetworkSubnetConfig -AddressPrefix 10.51.4.0/24 -Name monitoring
$subnet6 = New-AzureRmVirtualNetworkSubnetConfig -AddressPrefix 10.51.5.0/24 -Name analytics
$subnet7 = New-AzureRmVirtualNetworkSubnetConfig -AddressPrefix 10.51.6.0/24 -Name backup
$subnet8 = New-AzureRmVirtualNetworkSubnetConfig -AddressPrefix 10.51.7.0/24 -Name management
New-AzureRmVirtualNetwork -Location WestUS -Name $VNetName -ResourceGroupName $vNetResourceGroupName -AddressPrefix '10.51.0.0/21' -Subnet $subnet1,$subnet2,$subnet3,$subnet4, $subnet5, $subnet6, $subnet7 -Force;

Get-AzureRmVirtualNetwork -Name $VNetName -ResourceGroupName $vNetResourceGroupName | Get-AzureRmVirtualNetworkSubnetConfig | ft "addressprefix"

Write-Host "Completed deployment of new VNET"
}
If($NSGEnabled -eq "True")
{
Write-Host "Network Security Group Deployment in Progress"
$httprule = New-AzureRmNetworkSecurityRuleConfig -Name "FrontEnd_HTTP" -Description "HTTP Exception for Web frontends" -Protocol Tcp -SourcePortRange "80" -DestinationPortRange "80" -SourceAddressPrefix "*" -DestinationAddressPrefix "10.51.0.0/21" -Access Allow -Direction Inbound -Priority 200
$httpsrule = New-AzureRmNetworkSecurityRuleConfig -Name "FrontEnd_HTTPS" -Description "HTTPS Exception for Web frontends" -Protocol Tcp -SourcePortRange "443" -DestinationPortRange "443" -SourceAddressPrefix "*" -DestinationAddressPrefix "10.51.0.0/21" -Access Allow -Direction Inbound -Priority 201
$sshrule = New-AzureRmNetworkSecurityRuleConfig -Name "FrontEnd_SSH" -Description "SSH Exception for Web frontends" -Protocol Tcp -SourcePortRange "22" -DestinationPortRange "22" -SourceAddressPrefix "*" -DestinationAddressPrefix "10.51.0.0/21" -Access Allow -Direction Inbound ` -Priority 203
$nsg = New-AzureRmNetworkSecurityGroup -ResourceGroupName $vNetResourceGroupName -Location "West US" -Name $NSGName -SecurityRules $httprule,$httpsrule, $sshrule
Get-AzureRmNetworkSecurityGroup -Name $NSGName -ResourceGroupName $vNetResourceGroupName
}



## Add Non Image Specific objects
$StorageAccount = New-AzureRmStorageAccount -ResourceGroupName $ResourceGroupName -Name $StorageName -Type $StorageType -Location $Location

## New-AzureRmAvailabilitySet -Name $AvailSet -ResourceGroupName $ResourceGroupName -Location $Location -PlatformFaultDomainCount 3

switch -Wildcard ($vmMarketImage)
    {
        "*pf*" {
Write-Host "PfSense Deployment in Progress"
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
        "*red*" {
Write-Host "Red Hat Deployment in Progress"
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
        "*w2k12*" {
Write-Host "Windows Deployment in Progress"
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
        "*sql*" {
Write-Host "SQL Deployment in Progress"
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
Write-Host "R Server Deployment in Progress"
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
Write-Host "Windows 2008 R2 Deployment in Progress"
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
        "*chef*" {
Write-Host "Chef Deployment in Progress"
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
Write-Host "Centos Deployment in Progress"
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
Write-Host "Ubuntu Deployment in Progress"
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
Write-Host "Open SUSE Deployment in Progress"
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
        default{"An unsupported image was referenced"}
    }

## Create the VM in Azure
Write-Host "Starting Azure VM Creation"
New-AzureRmVM -ResourceGroupName $ResourceGroupName -Location $Location -VM $VirtualMachine -Verbose 
Write-Host "Deployment Completed"

If($ExtVMAccess -eq "True")
{
Write-Host "VM Access Agent Deployment in Progress"
Set-AzureRmVMExtension -ResourceGroupName $ResourceGroupName -VMName $VMName -Name "VMAccess" -ExtensionType "VMAccessAgent" -Publisher "Microsoft.Compute" -typeHandlerVersion "2.0" -Location Westus -Verbose
Set-AzureRmVMAccessExtension -ResourceGroupName $ResourceGroupName -VMName $VMName -Name "VMAccess" -Location Westus -Verbose
Get-AzureRmVMExtension -ResourceGroupName $ResourceGroupName -VMName $VMName -Name "VMAccess"
}
If($ExtMSAV -eq "True")
{
Write-Host "MSAV Agent Deployment in Progress"
Set-AzureRmVMExtension  -ResourceGroupName $ResourceGroupName -VMName $VMName -Name "MSAVExtension" -ExtensionType "IaaSAntimalware" -Publisher "Microsoft.Azure.Security" -typeHandlerVersion 1.4 -Location $Location
Set-AzureRmVMAccessExtension -ResourceGroupName $ResourceGroupName -VMName $VMName -Name "MSAVExtension" -Location Westus
Get-AzureRmVMExtension -ResourceGroupName $ResourceGroupName -VMName $VMName -Name "MSAVExtension" -Status
}

Get-AzureRmPublicIpAddress -Name $InterfaceName1 -ResourceGroupName $ResourceGroupName | ft "IpAddress"
Write-Host "Remote Access availble via IP Address above"
