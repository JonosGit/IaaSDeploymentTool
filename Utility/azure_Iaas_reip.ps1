<#
.SYNOPSIS
This Script updates the private IP address of an existing Network Interface on an existing VM in Azure.
.DESCRIPTION

.PARAMETER ResourceGroupName

.PARAMETER PvtIPNic

.PARAMETER InterfaceName

.EXAMPLE
.\Iaas-ReIP.ps1 -ResourceGroupName MyRes -InterfaceName MyNic -PvtIPNic 10.10.0.100
.LINK
https://github.com/JonosGit/IaaSDeploymentTool
#>

Param(
[Parameter(Mandatory=$True,ValueFromPipelinebyPropertyName=$true,Position=2)]
$ResourceGroupName = "res",

[Parameter(Mandatory=$True,ValueFromPipelinebyPropertyName=$true,Position=0)]
$PvtIPNic = "10.120.4.74",

[Parameter(Mandatory=$True,ValueFromPipelinebyPropertyName=$true,Position=1)]
$InterfaceName = "red88y_nic1"
)
function verifyIpnic {
if($PvtIPNic)
{
if($PvtIPNic -match "^(?:[0-9]{1,3}\.){3}[0-9]{1,3}$")
{Write-Host "IP Address Format is correct"}
else
{Write-Host "Incorrect Format, please use 192.12.1.1"
$PvtIPNic = Read-Host "Please Enter the IP Address in the correct format"
}
}
else
{
$PvtIPNic = Read-Host Read-Host "Please Enter the IP Address"
}
}

Function VerifyProfile {
$ProfileFile = "c:\Temp\jl.json"
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

VerifyProfile
verifyIpnic

$nic = Get-AzureRmNetworkInterface -Name $InterfaceName -ResourceGroupName $ResourceGroupName -ErrorAction SilentlyContinue
if($nic) 
{
$nic = Get-AzureRmNetworkInterface -Name $InterfaceName -ResourceGroupName $ResourceGroupName
$nic.IpConfigurations[0].PrivateIpAllocationMethod = "Static"
$nic.IpConfigurations[0].PrivateIpAddress = $PvtIPNic
Set-AzureRmNetworkInterface -NetworkInterface $nic -ErrorAction Stop

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
}
else
{
Write-Host "NIC does not exist, verify Interface Name and retry" -ForegroundColor Red
}
