<# 
.SYNOPSIS 
This script provides the following functionality for deploying IaaS environments in Azure. The script will deploy VNET in addition to numerour Market Place VMs or make use of an existing VNET.
Market Images supported: Redhat 6.7, PFSense 2.5, Windows 2008 R2, Windows 2012 R2, Ubuntu 14.04, CentOs 7.2, SUSE, SQL 2016 (on W2K12R2), R Server on Windows and Chef Server v12

.PARAMETERS
VMName is a required parameter at runtime. All other parameters are optional.
By default the script expects an existing VNET and will deploy a dual homed PFSense Server to an existing Resource Group in Azure. Use -NewVNet to overide
To deploy a VM to an existing VNET set the $NewVnet parameter to false. ** Update the $VNETResourceGroupName variable before running the script.
To deploy a new VNET with multiple subnets set the $NewVnet flag to true. ** The New VNET Will be deployed to $vNetResourceGroupName.
To deploy a specific market image enter one of the following names for $vmmMarketImage: Redhat PFSecure W2k12r2 w2k8r2 centos ubuntu chef SUSE SQL RSERVER

The Public IP Address of the VM will be shown when the script completes and can be used access the server.


.EXAMPLES
Deployment runtime positional parameters examples:

.\Azure_IaaS_Deploy.ps1 myserver RedHat myresgroup myvnet -NewVNET True
.\Azure_IaaS_Deploy.ps1 myserver2 RedHat myresgroup myvnet
.\Azure_IaaS_Deploy.ps1 myserver3 Suse myresgroup myvnet
.\Azure_IaaS_Deploy.ps1 myserver4 w2k12 myresgroup myvnet
.\Azure_IaaS_Deploy.ps1 myserver5 rserver myresgroup myvnet
.\Azure_IaaS_Deploy.ps1 myserver5 sql myresgroup myvnet

Deployment runtime named parameters examples:

Deploy SQL Server to existing VNET in existing resource group  - .\Azure_IaaS_DeployTool.ps1 -VName sqlserver1 -VMMarketImage SQL
Deploy PFSense Server to a existing VNET in existing resource group - .\Azure_IaaS_DeployTool.ps1 -VName pfserver1 -VMMarketImage Pfsense
Deploy PFSense Server to a new VNET in new resource group - .\Azure_IaaS_DeployTool.ps1 -VName pfserver1 -VMMarketImage Pfsense -NewVNET True -VNETName NewVNET -ResourceGroupName INFRA_RG
Deploy Windows 2012 R2 Server to a new VNET in new resource group - .\Azure_IaaS_DeployTool.ps1 -VName winserver1 -VMMarketImage w2k12r2
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
 $locpassword = 'PassW0rd!@1'

)

## Global
$Location = "WestUs"
$SubscriptionID=''
$TenantID=''
$StorageName = $VMName + "str"
$StorageType = "Standard_GRS"
$InterfaceName1 = $VMName + "nic1"
$InterfaceName2 = $VMName + "nic2"
$SecureLocPassword=Convertto-SecureString $locpassword –asplaintext -force
$Credential1 = New-Object System.Management.Automation.PSCredential ($locadmin,$SecureLocPassword)


# Login-AzureRmAccount
Set-AzureRmContext -tenantid $TenantID -subscriptionid $SubscriptionID

# Resource Group
New-AzureRmResourceGroup -Name $ResourceGroupName -Location $Location -force
New-AzureRmResourceGroup -Name $vNetResourceGroupName -Location $Location -force

If($NewVnet -eq "True")
{
## Create Virtual Network
Write-Host "Network Deployment in Progress"
New-AzureRmVirtualNetwork -Location WestUS -Name $VNetName -ResourceGroupName $vNetResourceGroupName -AddressPrefix '10.51.0.0/21' -Force;

$NewVirtualNetwork = @{
    ResourceGroupName = $vNetResourceGroupName;
    Name = $VNetName;
    Location = 'West US';
    AddressPrefix = '10.51.0.0/21';
    Subnet = $SubnetList;
    }
New-AzureRmVirtualNetwork @NewVirtualNetwork -force;
$SubnetList = @();
$SubnetList += New-AzureRmVirtualNetworkSubnetConfig -Name enablement -AddressPrefix 10.51.0.0/24;
$SubnetList += New-AzureRmVirtualNetworkSubnetConfig -Name public -AddressPrefix 10.51.1.0/24;
$SubnetList += New-AzureRmVirtualNetworkSubnetConfig -Name ingest -AddressPrefix 10.51.2.0/24;
$SubnetList += New-AzureRmVirtualNetworkSubnetConfig -Name data -AddressPrefix 10.51.3.0/24;
$SubnetList += New-AzureRmVirtualNetworkSubnetConfig -Name monitor -AddressPrefix 10.51.4.0/24;
$SubnetList += New-AzureRmVirtualNetworkSubnetConfig -Name analytics -AddressPrefix 10.51.5.0/24;
$SubnetList += New-AzureRmVirtualNetworkSubnetConfig -Name backup -AddressPrefix 10.51.6.0/24;
$SubnetList += New-AzureRmVirtualNetworkSubnetConfig -Name management -AddressPrefix 10.51.7.0/24;
}

# Storage
$StorageAccount = New-AzureRmStorageAccount -ResourceGroupName $ResourceGroupName -Name $StorageName -Type $StorageType -Location $Location


## Add Non Image Specific objects

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
New-AzureRmVM -ResourceGroupName $ResourceGroupName -Location $Location -VM $VirtualMachine -Verbose 
Write-Host "Deployment Completed"
Get-AzureRmPublicIpAddress -Name $InterfaceName1 -ResourceGroupName $ResourceGroupName | ft "IpAddress"
