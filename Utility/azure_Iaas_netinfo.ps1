<#
.SYNOPSIS
Written By John Lewis

This script takes two parameters, a Resource Group Name and an Azure regional location.
The script will retrive all network components in a Resource Group including VNET, Network Interfaces
 Public IP and Private IP info.
.PARAMETERS
-ResourceGroupName
-Location
.EXAMPLE
\azNetinfo.ps1 -ResourceGroupName "MyResGrp"
\azNetinfo.ps1 -ResourceGroupName "MyResGrp" -Location "WestUs"
#>

Param(
[Parameter(Mandatory=$False,ValueFromPipelinebyPropertyName=$true,Position=0)]
 [string]
 $ResourceGroupName = 'resx',
 [Parameter(Mandatory=$False,ValueFromPipelinebyPropertyName=$true)]
 [string]
 $Location = "WestUs"
)


Function VerifyProfile {
$ProfileFile = "C:\Users\admin\OneDrive\Scripts\Powershell\Roaming\Azure\outlook.json"
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

Function AzureVersion {
$name='Azure'
if(Get-Module -ListAvailable |
	Where-Object { $_.name -eq $name })
{
$ver = (Get-Module -ListAvailable | Where-Object{ $_.Name -eq $name }) |
	select version -ExpandProperty version
	Write-Host "current Azure PowerShell Version:" $ver
$currentver = $ver
	if($currentver-le '2.0.0'){
	Write-Host "expected version 2.0.0 found $ver" -ForegroundColor DarkRed
	exit
	}
}
else
{
	Write-Host “The Azure PowerShell module is not installed.”
	exit
}
}

AzureVersion
VerifyProfile


 try {
Get-AzureRmResourceGroup -Name $ResourceGroupName -Location $Location -ErrorAction Stop | OUt-Null
}
catch {
	Write-Host -foregroundcolor Yellow `
	" $($_.Exception.Message)"; `
	continue
}

Write-Host "VNETs in RG" $ResourceGroupName -NoNewline
Get-AzureRmVirtualNetwork -ResourceGroupName $ResourceGroupName -WarningAction SilentlyContinue | ft Name, ResourceGroupName -Wrap -AutoSize

Write-Host "Subnets located in RG" $ResourceGroupName
Get-AzureRmVirtualNetwork -ResourceGroupName $ResourceGroupName | Get-AzureRmVirtualNetworkSubnetConfig | ft Name,AddressPrefix

Write-Host "Network Security Groups located in RG" $ResourceGroupName 
Get-AzureRmNetworkSecurityGroup -ResourceGroupName $ResourceGroupName -WarningAction SilentlyContinue | ft "Name"

Write-Host "NICs located in RG" $ResourceGroupName
Get-AzureRmNetworkInterface -ResourceGroupName $ResourceGroupName | ft Name,Location,ResourceGroupName

Write-Host "VMs located in RG" $ResourceGroupName
Get-AzureRmVM -ResourceGroupName $ResourceGroupName | ft "Name"

Write-Host "Public Ips located in RG" $ResourceGroupName
Get-AzureRmPublicIpAddress -ResourceGroupName $ResourceGroupName | ft "Name","IpAddress"

Write-Host "Public DNS Records located in RG" $ResourceGroupName 
Get-AzureRmPublicIpAddress -ResourceGroupName $ResourceGroupName | select-object -ExpandProperty DNSSettings | FT FQDN -Wrap


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

Get-AzureRmNetworkSecurityGroup -Name nsg -ResourceGroupName xres -ExpandResource NetworkInterfaces | Get-AzureRmNetworkSecurityRuleConfig | Ft Name,Description,Direction,SourcePortRange,DestinationPortRange,DestinationPortRange,SourceAddressPrefix,Access
Get-AzureRmNetworkSecurityGroup -Name nsg -ResourceGroupName xres -ExpandResource NetworkInterfaces | Get-AzureRmNetworkSecurityRuleConfig -DefaultRules | Ft Name,Description,Direction,SourcePortRange,DestinationPortRange,DestinationAddressPrefix,SourceAddressPrefix,Access

