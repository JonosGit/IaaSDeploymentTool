<#
.SYNOPSIS
Written By John Lewis v.6
This script takes two parameters, a Resource Group Name and an Azure regional location. 
The script will retrive all network components in a Resource Group including VNET, Network Interfaces
 Public IP and Private IP info.
.PARAMETERS
-ResourceGroupName
-Location
.EXAMPLE
\azNetinfo.ps2 -ResourceGroupName "MyResGrp"
\azNetinfo.ps2 -ResourceGroupName "MyResGrp" -Location "WestUs"
#>

Param(
[Parameter(Mandatory=$False,ValueFromPipelinebyPropertyName=$true)]
 [string]
 $ResourceGroupName = 'RGA',
 [Parameter(Mandatory=$False,ValueFromPipelinebyPropertyName=$true,Position=0)]
 [string]
 $Location = "WestUs"
)
Function RegisterRP {
	Param(
		[string]$ResourceProviderNamespace
	)

	Write-Host "Registering resource provider '$ResourceProviderNamespace'";
	Register-AzureRmResourceProvider -ProviderNamespace $ResourceProviderNamespace –Confirm:$false -Force -WarningAction SilentlyContinue;
}

Add-AzureRmAccount

 $resourceProviders = @("microsoft.compute","microsoft.network","microsoft.storage");
 if($resourceProviders.length) {
	Write-Host "Registering resource providers"
	foreach($resourceProvider in $resourceProviders) {
		RegisterRP($resourceProvider);
	}
 }

 try {
Get-AzureRmResourceGroup -Name $ResourceGroupName -Location $Location -ErrorAction Stop | OUt-Null
}
catch {
	Write-Host -foregroundcolor Yellow `
	" $($_.Exception.Message)"; `
	continue
}
 
 Get-AzureRmVirtualNetwork -ResourceGroupName $ResourceGroupName | ft Name, ResourceGroupName
 
 Write-Host "Subnets located in RG" $ResourceGroupName -NoNewline
 Get-AzureRmVirtualNetwork -ResourceGroupName $ResourceGroupName | Get-AzureRmVirtualNetworkSubnetConfig | ft Name,AddressPrefix
 
 Write-Host "Public Ips located in RG" $ResourceGroupName -NoNewline
 Get-AzureRmPublicIpAddress -ResourceGroupName $ResourceGroupName | ft "Name","IpAddress"
 
 Write-Host "NICs located in RG" $ResourceGroupName -NoNewline
 Get-AzureRmNetworkInterface -ResourceGroupName $ResourceGroupName | ft Name,Location,ResourceGroupName
 
 Write-Host "VMs located in RG" $ResourceGroupName -NoNewline
 Get-AzureRmVM -ResourceGroupName $ResourceGroupName | ft "Name"


Write-Host "Private Network Interfaces located in " $ResourceGroupName
$vms = get-azurermvm -ResourceGroupName $ResourceGroupName
$nics = get-azurermnetworkinterface -ResourceGroupName $ResourceGroupName | where VirtualMachine -NE $null #skip Nics with no VM
foreach($nic in $nics)
{
	$vm = $vms | where-object -Property Id -EQ $nic.VirtualMachine.id
	$prv =  $nic.IpConfigurations | select-object -ExpandProperty PrivateIpAddress
	$alloc =  $nic.IpConfigurations | select-object -ExpandProperty PrivateIpAllocationMethod
	Write-Output "$($vm.Name): $prv - $alloc" | Format-Table
}

