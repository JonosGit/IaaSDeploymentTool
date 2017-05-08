<#
.SYNOPSIS
Written By John Lewis
email: jonos@live.com
Ver 1.3

v 1.3 Updates - Updated Remove VM function to cleanup after a VM is removed. Added Managed Disks to cleanup process. 

.DESCRIPTION
This script removes existing VMs, RGs, Storage, Availability Sets, VNETs, NSGs and Azure Extensions

.PARAMETER Remove-Object
Sets the type of removal operation
.PARAMETER VMName
Sets the name of the VM to remove
.PARAMETER rg
The name of the resource group to remove.

.NOTES

.LINK

#>

[CmdletBinding(DefaultParameterSetName = 'default')]
Param(
[Parameter(Mandatory=$False,ValueFromPipelinebyPropertyName=$true,Position=0)]
[ValidateSet("vm","vnet","rg","nsg","disk","storage","availabilityset","extension","loadbalancer")]
[string]
$RemoveObject = '',
[Parameter(Mandatory=$False,ValueFromPipelinebyPropertyName=$true)]
[Alias("vm")]
[string]
$VMName = '',
[Parameter(Mandatory=$False,ValueFromPipelinebyPropertyName=$true,Position=1)]
[ValidateNotNullorEmpty()]
[string]
$rg = '',
[Parameter(Mandatory=$False,ValueFromPipelinebyPropertyName=$true)]
[string]
$LBName = '',
[Parameter(Mandatory=$False,ValueFromPipelinebyPropertyName=$true)]
[string]
$vnetrg = '',
[Parameter(Mandatory=$False,ValueFromPipelinebyPropertyName=$true)]
[Alias("vnet")]
[string]
$VNetName = '',
[Parameter(Mandatory=$False,ValueFromPipelinebyPropertyName=$true)]
[Alias("disk")]
[string]
$DiskName = $VMName + "_datadisk",
[Parameter(Mandatory=$False,ValueFromPipelinebyPropertyName=$true)]
[ValidateNotNullorEmpty()]
[string]
$Location = 'WestUs',
[Parameter(Mandatory=$False,ValueFromPipelinebyPropertyName=$true)]
[string]
$SubscriptionID = '',
[Parameter(Mandatory=$False,ValueFromPipelinebyPropertyName=$true)]
[string]
$TenantID = '',
[Parameter(Mandatory=$False,ValueFromPipelinebyPropertyName=$true)]
[string]
$Profile = "profile",
[Parameter(Mandatory=$False,ValueFromPipelinebyPropertyName=$true)]
[ValidateSet("diag","msav","bginfo","access","linuxbackup","chefagent","eset","customscript","opsinsightLinux","opsinsightWin","WinPuppet","domjoin","RegisterAzDSC","PushDSC")]
[Alias("ext")]
[string]
$AzExtConfig = 'diag',
[Parameter(Mandatory=$False,ValueFromPipelinebyPropertyName=$true)]
[string]
$StorageName = $VMName + 'str',
[Parameter(Mandatory=$False,ValueFromPipelinebyPropertyName=$true)]
[switch]
$clobber
)

$Error.Clear()
Set-StrictMode -Version Latest
Trap [System.SystemException] {("Exception" + $_ ) ; break}

#region Validate Profile
Function validate-profile {
$comparedate = (Get-Date).AddDays(-14)
$fileexist = Test-Path $ProfileFile -NewerThan $comparedate
  if($fileexist)
  {
  Select-AzureRmProfile -Path $ProfileFile | Out-Null
		Write-Host "Using $ProfileFile"
  }
  else
  {
  Write-Host "Please enter your credentials"
  Add-AzureRmAccount
  Save-AzureRmProfile -Path $ProfileFile -Force
  Write-Host "Saved Profile to $ProfileFile"
  exit
  }
}
#endregion

#region Create Log
Function Log-Command ([string]$Description, [string]$logFile, [string]$VMName){
$Output = $LogOut+'. '
Write-Host $Output -ForegroundColor white
((Get-Date -UFormat "[%d-%m-%Y %H:%M:%S] ") + $Output) | Out-File -FilePath $LogOutFile -Append -Force
}
#endregion

Function Check-Vnet {
$vnetexists = Get-AzureRmVirtualNetwork -Name $VNetName -ResourceGroupName $vnetrg -ErrorAction SilentlyContinue -WarningAction SilentlyContinue
if(!$vnetexists)
	{Create-Vnet}
	else
		{Write-Host "Proceeding with VNET $VnetName"}
}

#region Check Values of runtime params
function Check-NullValues {
if(!$rg) {
Write-Host "Please Enter Resource Group Name"
exit
}
	elseif(!$VMName) {
	Write-Host "Please Enter -vmName"
	exit
	}
				elseif(!$Location) {
				Write-Host "Please Enter -Location"
				exit
				}
}

function Check-RemoveAction {
if($ActionType -eq 'Remove' -and !$RemoveObject -and !$RemoveExtension)
	 {
		 Write-Host "Please enter object -RemoveObject or extension -RemoveExtension to remove"
		exit
		 }
 }

function Check-RemoveObject {
if($RemoveObject -eq 'rg' -and !$rg) {
	Write-Host "Please Enter -rg RG Name"
	exit
	}
	}

function Check-ExtensionUnInstall {
if($RemoveExtension -and !$rg) {
	Write-Host "Please Enter -rg RG Name"
	exit
	}
	elseif($RemoveExtension -and !$VMName) {
	Write-Host "Please Enter -vmname VM Name"
	exit
	}
}

#region Get Resource Providers
Function Register-RP {
	Param(
		[string]$ResourceProviderNamespace
	)

	# Write-Host "Registering resource provider '$ResourceProviderNamespace'";
	Register-AzureRmResourceProvider -ProviderNamespace $ResourceProviderNamespace –Confirm:$false -WarningAction SilentlyContinue | Out-Null;
}
#endregion

#region Uninstall Extension
Function UnInstall-Ext {
	param(
		[Parameter(Mandatory=$False,ValueFromPipelinebyPropertyName=$true)]
		[string]
		$Location = $Location,
		[Parameter(Mandatory=$False,ValueFromPipelinebyPropertyName=$true)]
		[string]
		$rg = $rg,
		[Parameter(Mandatory=$False,ValueFromPipelinebyPropertyName=$true)]
		[string]
		$VMName = $VMName,
		[Parameter(Mandatory=$False,ValueFromPipelinebyPropertyName=$true)]
		[string]
		$AzExtConfig = $AzExtConfig

	)
switch ($AzExtConfig)
	{
		"access" {
				Write-Host "VM Access Agent VM Image Removal in Process"
				Remove-AzureRmVMAccessExtension -ResourceGroupName $rg -VMName $VMName -Name "VMAccess" -Force -Confirm:$false
				$LogOut = "Removed VM Access Extension"
				Log-Command -Description $LogOut -LogFile $LogOutFile
						exit
}
		"msav" {
				Write-Host "MSAV Agent VM Image Removal in Process"
				Remove-AzureRmVMExtension -Name "MSAVExtension" -ResourceGroupName $rg -VMName $VMName -Confirm:$false -Force
				$LogOut = "Removed MSAV Extension"
				Log-Command -Description $LogOut -LogFile $LogOutFile
						exit
		}
		"customscript" {
				Write-Host "Removing custom script"
				Remove-AzureRmVMCustomScriptExtension -ResourceGroupName $rg -VMName $VMName -Name $customextname -Confirm:$false -Force
				$LogOut = "Removed Custom Script Extension"
				Log-Command -Description $LogOut -LogFile $LogOutFile
					exit
		}
		"diag" {
				Write-Host "Removing Azure Enhanced Diagnostics"
				Remove-AzureRmVMAEMExtension -ResourceGroupName $rg -VMName $VMName
				$LogOut = "Removed Custom Script Extension"
				Log-Command -Description $LogOut -LogFile $LogOutFile
						exit
		}
		"domjoin" {
				Write-Host "Removing Domain Join"
		}
		"linuxOsPatch" {
				Write-Host "Removing Azure OS Patching Linux"
				Remove-AzureRmVMExtension -ResourceGroupName $rg -VMName $VMName -Name "OSPatch"
				$LogOut = "Removed Linux OS Patch Extension"
				Log-Command -Description $LogOut -LogFile $LogOutFile
						exit
				}
		"linuxbackup" {
				Write-Host "Removing Linux VMBackup"
				Remove-AzureRmVMBackup -ResourceGroupName $rg -VMName $VMName -Tag 'OSBackup'
				$LogOut = "Removed Linux OS Backup Extension"
				Log-Command -Description $LogOut -LogFile $LogOutFile
						exit
				}
		"chefAgent" {
				Write-Host "Removing Chef Agent"
				Remove-AzureRmVMExtension -ResourceGroupName $rg -VMName $VMName -Name "ChefStrap" -Force -Confirm:$false
				$LogOut = "Removed Chef Extension"
				Log-Command -Description $LogOut -LogFile $LogOutFile
				exit
				}
		"opsinsightLinux" {
				Write-Host "Removing Linux Insight Agent"
			exit
				}
		"opsinsightWin" {
				Write-Host "Removing Windows Insight Agent"
			exit
				}
		"ESET" {
				Write-Host "Removing File Security"
				Remove-AzureRmVMExtension -ResourceGroupName $rg -VMName $VMName -Name "ESET" -Force -Confirm:$false
				$LogOut = "Removed File Security Extension"
				Log-Command -Description $LogOut -LogFile $LogOutFile
			exit
				}
		"RegisterAzDSC" {
				Write-Host "Removing Azure Automation DSC"
			exit
				}
		"WinPuppet" {
				Write-Host "Removing Puppet Extension"
			exit
				}
		"PushDSC" {
				Remove-DscExt
				$LogOut = "Removed DSC Extension"
				Log-Command -Description $LogOut -LogFile $LogOutFile
						exit
				}
		"Bginfo" {
				Write-Host "Removing BgInfo Extension"
				Remove-AzureVMBGInfoExtension -VM $VMName
				$LogOut = "Removed BGInfo Extension"
				Log-Command -Description $LogOut -LogFile $LogOutFile
			exit
				}
		default{"An unsupported uninstall Extension command was used"}
	}
	exit
}
#endregion

#region Remove Orphans
Function Remove-Orphans {
	param(
	[Parameter(Mandatory=$False,ValueFromPipelinebyPropertyName=$true)]
	[string]
	$InterfaceName1 = $VMName + "_nic1",
	[Parameter(Mandatory=$False,ValueFromPipelinebyPropertyName=$true)]
	[string]
	$InterfaceName2 = $VMName + "_nic2",
	[Parameter(Mandatory=$False,ValueFromPipelinebyPropertyName=$true)]
	[string]$Location = $Location,
	[Parameter(Mandatory=$False,ValueFromPipelinebyPropertyName=$true)]
	[string]$rg = $rg,
	[Parameter(Mandatory=$False,ValueFromPipelinebyPropertyName=$true)]
	[string]$VMName = $VMName
	)
	$OSDiskName = $VMName + "_OSDisk"
	$extvm = Get-AzureRmVm -Name $VMName -ResourceGroupName $rg -ErrorAction SilentlyContinue -WarningAction SilentlyContinue
	$nic1 = Get-AzureRmNetworkInterface -Name $InterfaceName1 -ResourceGroupName $rg -ErrorAction SilentlyContinue
	$nic2 = Get-AzureRmNetworkInterface -Name $InterfaceName2 -ResourceGroupName $rg -ErrorAction SilentlyContinue
	$pubip =  Get-AzureRmPublicIpAddress -Name $InterfaceName1 -ResourceGroupName $rg -ErrorAction SilentlyContinue
	$str = Get-AzureRmStorageAccount -Name $StorageName -ResourceGroupName $rg -WarningAction SilentlyContinue -ErrorAction SilentlyContinue

if($extvm)
{ Write-Host "Host VM Found, cleanup cannot proceed" -ForegroundColor Cyan
 Start-sleep 2
Exit }

	if($nic1)
{
		Write-Host "Removing orphan $InterfaceName1" -ForegroundColor White
		Remove-AzureRmNetworkInterface -Name $InterfaceName1 -ResourceGroupName $rg -Force -Confirm:$False
		$LogOut = "Removed $InterfaceName1 - Private Adapter"
		Log-Command -Description $LogOut -LogFile $LogOutFile
 }
	 if($pubip)
{
		Remove-AzureRmPublicIpAddress -Name $InterfaceName1 -ResourceGroupName $rg -Force -Confirm:$False
		$LogOut = "Removed $InterfaceName1 - Public Ip"
		Log-Command -Description $LogOut -LogFile $LogOutFile
}
	 if($nic2)
{
		Write-Host "Removing orphan $InterfaceName2" -ForegroundColor White
		Remove-AzureRmNetworkInterface -Name $InterfaceName2 -ResourceGroupName $rg -Force -Confirm:$False
		$LogOut = "Removed $InterfaceName2 - Private Adapter"
		Log-Command -Description $LogOut -LogFile $LogOutFile
 }
	if($str)
{
		Write-Host "Removing orphan $StorageName" -ForegroundColor White
		Remove-azStorage -Name $StorageName -rg $rg
		$LogOut = "Removed $StorageName - Storage"
		Log-Command -Description $LogOut -LogFile $LogOutFile
}

		$OSDiskName = $VMName + "_OSDisk"
		Write-Host "Removing orphan $OSDiskName" -ForegroundColor White
		Remove-AzureRmDisk -ResourceGroupName $rg -DiskName $OSDiskName -Force -Confirm:$False -InformationAction SilentlyContinue -WarningAction SilentlyContinue -ErrorAction SilentlyContinue
		$LogOut = "Removed $OSDiskName - Managed Storage"
		Log-Command -Description $LogOut -LogFile $LogOutFile

 Write-Host "No orphans found." -ForegroundColor Green
 exit
 }
#endregion

#region Remove DSC
Function Remove-DscExt
{
Param(
		[Parameter(Mandatory=$False,ValueFromPipelinebyPropertyName=$true,Position=0)]
		[string]
		$rg = $rg,
		[Parameter(Mandatory=$False,ValueFromPipelinebyPropertyName=$true,Position=0)]
		[string]
		$VMName = $VMName
)
Write-Host "Removing DSC Extension"
Remove-AzureRmVMDscExtension -ResourceGroupName $rg -VMName $VMName -Confirm:$False
}

Function Remove-azRg
{
Param(
		[Parameter(Mandatory=$False,ValueFromPipelinebyPropertyName=$true,Position=0)]
		[string]
		$rg = $rg
)
		Write-Host "Removing RG "
		Get-AzureRmResourceGroup -Name $rg | Remove-AzureRmResourceGroup -Verbose -Force -Confirm:$False
}
#endregion

#region RemoveVM
Function Remove-azVM-NoCleanup
{
Param(
		[Parameter(Mandatory=$False,ValueFromPipelinebyPropertyName=$true,Position=1)]
		[string]
		$rg = $rg,
		[Parameter(Mandatory=$False,ValueFromPipelinebyPropertyName=$true,Position=0)]
		[string]
		$VMName = $VMName
)
		Write-Host "Removing VM $VMName"
		Remove-AzureRmVm -Name $VMName -ResourceGroupName $rg -ErrorAction Stop -Confirm:$False -Force | ft Status,StartTime,EndTime | Format-Table
		$LogOut = "Removed $VMName from RG $rg"
		Log-Command -Description $LogOut -LogFile $LogOutFile
}
#endregion

function Remove-azVM  {
	[CmdletBinding(SupportsShouldProcess)]
	param
	(
		[Parameter(ValueFromPipelineByPropertyName)]
		[Alias('vm')]
		[string]$VMName = $VMName,
		[Parameter(ValueFromPipelineByPropertyName)]
		[string]$ResourceGroupName = $rg
	)
	process {
		try
		{
			$scriptBlock = {
				param ($VMName,
						$ResourceGroupName)
					$commonParams = @{
					'Name' = $VMName;
					'ResourceGroupName' = $ResourceGroupName
				}
				$vm = Get-AzureRmVm @commonParams

				$azResourceParams = @{
					'ResourceName' = $VMName
					'ResourceType' = 'Microsoft.Compute/virtualMachines'
					'ResourceGroupName' = $ResourceGroupName
				}
				$vmResource = Get-AzureRmResource @azResourceParams
				$vmId = $vmResource.Properties.VmId



				if ($vm.DiagnosticsProfile.bootDiagnostics)
				{
					Write-Host 'Removing boot diagnostics storage container...'
					$diagSa = [regex]::match($vm.DiagnosticsProfile.bootDiagnostics.storageUri, '^http[s]?://(.+?)\.').groups[1].value
					if ($vm.Name.Length -gt 9) {
						$i = 9
					} else {
						$i = $vm.Name.Length - 1
					}

					$diagContainerName = ('bootdiagnostics-{0}-{1}' -f $vm.Name.ToLower().Substring(0, $i), $vmId)
					$diagSaRg = (Get-AzureRmStorageAccount | where { $_.StorageAccountName -eq $diagSa }).ResourceGroupName
					$saParams = @{
						'ResourceGroupName' = $diagSaRg
						'Name' = $diagSa
					}
					
					Get-AzureRmStorageAccount @saParams | Get-AzureStorageContainer | where { $_.Name-eq $diagContainerName } | Remove-AzureStorageContainer -Force
				}


				Write-Host 'Removing the Azure VM...'
				$null = $vm | Remove-AzureRmVM -Force
				Write-Host 'Removing the Azure network interface...'
				foreach($nicUri in $vm.NetworkInterfaceIDs)
				{
					$nic = Get-AzureRmNetworkInterface -ResourceGroupName $vm.ResourceGroupName -Name $nicUri.Split('/')[-1]
					Remove-AzureRmNetworkInterface -Name $nic.Name -ResourceGroupName $vm.ResourceGroupName -Force
					foreach($ipConfig in $nic.IpConfigurations)
					{
						if($ipConfig.PublicIpAddress -ne $null)
							{
							Write-Host 'Removing the Public IP Address...'
							Remove-AzureRmPublicIpAddress -ResourceGroupName $vm.ResourceGroupName -Name $ipConfig.PublicIpAddress.Id.Split('/')[-1] -Force
								}
					}
				}


			   $strexists =  $vm.StorageProfile.OSDisk.Vhd
			   $diskexists = $vm.StorageProfile.OsDisk.ManagedDisk
			   if($strexists)
			   {
				Write-Host 'Removing OS disk...'
				$osDiskUri = $vm.StorageProfile.OSDisk.Vhd.Uri
				$osDiskContainerName = $osDiskUri.Split('/')[-2]


				$osDiskStorageAcct = Get-AzureRmStorageAccount | where { $_.StorageAccountName -eq $osDiskUri.Split('/')[2].Split('.')[0] }
				$osDiskStorageAcct | Remove-AzureStorageBlob -Container $osDiskContainerName -Blob $osDiskUri.Split('/')[-1] -ea Ignore


				Write-Host 'Removing the OS disk status blob...'
				$osDiskStorageAcct | Get-AzureStorageBlob -Container $osDiskContainerName -Blob "$($vm.Name)*.status" | Remove-AzureStorageBlob

				
				if ($vm.DataDiskNames.Count -gt 0)
				{
					Write-Host 'Removing unmanaged data disks...'
					foreach ($uri in $vm.StorageProfile.DataDisks.Vhd.Uri)
					{
						$dataDiskStorageAcct = Get-AzureRmStorageAccount -ResourceGroupName $rg -Name $uri.Split('/')[2].Split('.')[0]
						$dataDiskStorageAcct | Remove-AzureStorageBlob -Container $uri.Split('/')[-2] -Blob $uri.Split('/')[-1] -ea Ignore
					}
				}

				}
				if($diskexists)
				{
				Write-Host 'Removing the OS managed disk...'
				Remove-AzureRmDisk -ResourceGroupName $vm.ResourceGroupName -DiskName $vm.StorageProfile.OSDisk.Name -Force -Confirm: $false -ErrorAction Stop -WarningAction SilentlyContinue -InformationAction SilentlyContinue | Out-Null
					Remove-azDisk
				}


			}

				& $scriptBlock -VMName $VMName -ResourceGroupName $ResourceGroupName
		}
		catch
		{
			Write-Host -foregroundcolor Yellow `
			"Exception Encountered"; `
			$ErrorMessage = $_.Exception.Message
			$LogOut  = 'Error '+$ErrorMessage
			Log-Command -Description $LogOut -LogFile $LogOutFile
			break
		}
	}
}

#region Remove NSG
Function Remove-azNSG
{
Param(
		[Parameter(Mandatory=$False,ValueFromPipelinebyPropertyName=$true,Position=1)]
		[string]
		$rg = $rg,
		[Parameter(Mandatory=$False,ValueFromPipelinebyPropertyName=$true,Position=0)]
		[string]
		$NSGName = $NSGName
)
		Write-Host "Removing NSG"
		Remove-AzureRmNetworkSecurityGroup -Name $NSGName -ResourceGroupName $rg -WarningAction SilentlyContinue -ErrorAction Stop -Force -Confirm:$False | Format-Table
		$LogOut = "Removed $NSGName"
		Log-Command -Description $LogOut -LogFile $LogOutFile
}
#endregion

#region Remove Managed Disk
Function Remove-azDisk
{
Param(
		[Parameter(Mandatory=$False,ValueFromPipelinebyPropertyName=$true,Position=1)]
		[string]
		$rg = $rg,
		[Parameter(Mandatory=$False,ValueFromPipelinebyPropertyName=$true,Position=0)]
		[string]
		$DiskName = $DiskName
)
		Write-Host "Removing Managed Disk"
		Remove-AzureRmDisk -ResourceGroupName $rg -DiskName $DiskName -Force -Confirm: $false -ErrorAction Stop -WarningAction SilentlyContinue -InformationAction SilentlyContinue | Out-Null
		$LogOut = "Removed $DiskName"
		Log-Command -Description $LogOut -LogFile $LogOutFile
}
#endregion

#region Remove VNET
Function Remove-azVNET
{
Param(
		[Parameter(Mandatory=$False,ValueFromPipelinebyPropertyName=$true,Position=1)]
		[string]
		$rg = $rg,
		[Parameter(Mandatory=$False,ValueFromPipelinebyPropertyName=$true,Position=0)]
		[string]
		$VNETName = $VNETName
)
		Write-Host "Removing VNET"
		Remove-AzureRmVirtualNetwork -Name $VNETName -ResourceGroupName $rg -Confirm:$False -Force
		$LogOut = "Removed $VNETName"
		Log-Command -Description $LogOut -LogFile $LogOutFile
}
#endregion

#region Remove Storage
Function Remove-AzStorage
{
Param(
		[Parameter(Mandatory=$False,ValueFromPipelinebyPropertyName=$true,Position=1)]
		[string]
		$rg = $rg,
		[Parameter(Mandatory=$False,ValueFromPipelinebyPropertyName=$true,Position=0)]
		[string]
		$Name = $storagename
)
		Write-Host "Removing Storage"
		Remove-AzureRMStorageAccount -Name $Name -ResourceGroupName $rg -WarningAction SilentlyContinue -Force -Confirm:$False
		$LogOut = "Removed Azure Storage $Name"
		Log-Command -Description $LogOut -LogFile $LogOutFile
}
#endregion

#region Remove Availability Set
Function Remove-AzAvailabilitySet
{
Param(
		[Parameter(Mandatory=$False,ValueFromPipelinebyPropertyName=$true,Position=1)]
		[string]
		$rg = $rg,
		[Parameter(Mandatory=$False,ValueFromPipelinebyPropertyName=$true,Position=0)]
		[string]
		$AvailSetName = $AvailSetName
)
		Write-Host "Removing Availability Set"
		Remove-AzureRmAvailabilitySet -ResourceGroupName $rg -Confirm:$False -Force -Name $AvailSetName
		$LogOut = "Removed $AvailSetName"
		Log-Command -Description $LogOut -LogFile $LogOutFile
}
#endregion

#region Remove Load Balancer
Function Remove-AzLoadBalancer
{
Param(
		[Parameter(Mandatory=$False,ValueFromPipelinebyPropertyName=$true,Position=1)]
		[string]
		$rg = $rg,
		[Parameter(Mandatory=$False,ValueFromPipelinebyPropertyName=$true,Position=0)]
		[string]
		$LBName = $LBName
)
		Write-Host "Removing Load Balancer"
		Remove-AzureRmLoadBalancer -Name extlb -ResourceGroupName resx -Confirm:$False -Force
		$LogOut = "Removed Load Balancer"
		Log-Command -Description $LogOut -LogFile $LogOutFile
}
#endregion

#region Remove Component
Function Remove-Component {
	param(
		[string]$RemoveObject = $RemoveObject
	)

switch ($RemoveObject)
	{
		"rg" {
		Remove-azRg
		exit
}
		"vm" {
		Remove-azVM
			if($clobber)
				{Remove-Orphans}	
}
		"nsg" {
		Remove-azNSG
		exit
}
		"vnet" {
		Remove-azVNET
		exit
}
		"storage" {
		Remove-AzStorage
		exit
}
		"disk" {
		Remove-AzDisk
		exit
}
		"availabilityset" {
		Remove-AzAvailabilitySet
		exit
}
		"loadbalancer" {
		Remove-AzLoadBalancer
		exit
}
		"dsc" {
		Remove-Dsc
		exit
}
		"extension" {
		UnInstall-Ext -AzExtConfig $AzExtConfig
		exit
}
		default{"An unsupported uninstall Extension command was used"}
	}
	exit
}
#endregion

#region Azure Version
Function Verify-AzureVersion {
$name='Azure'
if(Get-Module -ListAvailable |
	Where-Object { $_.name -eq $name })
{
	$ver = (Get-Module -ListAvailable | Where-Object{ $_.Name -eq $name }) |
		select version -ExpandProperty version
		Write-Host "current Azure PowerShell Version:" $ver
	$currentver = $ver
		if($currentver-le '2.0.0'){
		Write-Host "expected version 3.0.0 found $ver" -ForegroundColor DarkRed
		exit
			}
}
		else
{
	Write-Host “The Azure PowerShell module is not installed.”
	exit
}
}
#endregion

#region Create Log Directory
Function Create-Dir {
$logdirexists = Test-Path -Path $logdir
if(!$logdirexists)
	{
	New-Item -Path $logdir -ItemType Directory -Force | Out-Null
		Write-Host "Created directory" $logdir
	}
}
#endregion

Function Register-ResourceProviders {
	 $resourceProviders = @("microsoft.compute","microsoft.network","microsoft.storage");
 if($resourceProviders.length) {
	Write-Host "Registering resource providers"
	foreach($resourceProvider in $resourceProviders) {
		Register-RP($resourceProvider);
	}
 }
	}

##--------------------------- Begin Script Execution -------------------------------------------------------##
# Global
$date = Get-Date -UFormat "%Y-%m-%d-%H-%M"
$workfolder = Split-Path $script:MyInvocation.MyCommand.Path
$logdir = $workfolder+'\'+'log'+'\'
$LogOutFile = $logdir+$vmname+'-'+$date+'.log'
$ProfileFile = $workfolder+'\'+$profile+'.json'
$logdir = $workfolder+'\'+'log'+'\'

Verify-AzureVersion # Verifies Azure client Powershell Version

validate-profile # Attempts to use json file for auth, falls back on Add-AzureRmAccount

try {
Get-AzureRmResourceGroup -Location $Location -ErrorAction Stop | Out-Null
}
catch {
	Write-Host -foregroundcolor Yellow `
	"User has not authenticated, use Add-AzureRmAccount or $($_.Exception.Message)"; `
	continue
}

Register-ResourceProviders

Create-Dir

					if($RemoveObject)
						{
						Check-RemoveObject
						Remove-Component
						}