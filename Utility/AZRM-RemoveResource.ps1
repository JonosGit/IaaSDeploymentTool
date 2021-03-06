<#
.SYNOPSIS
Written By John Lewis
email: jonos@live.com
Ver 1.5

v 1.5 Updates for Extension Removal -extname
v 1.4 Updates - Fixes issue with removal of NICs due to Azure PS updates.
v 1.3 Updates - Updated Remove VM function to cleanup after a VM is removed. Added Managed Disks to cleanup process. 

.DESCRIPTION
This script removes existing VMs, RGs, Storage, Availability Sets, VNETs, NSGs and Azure Extensions

.PARAMETER Remove-Object

.PARAMETER VMName
Sets the name of the VM to remove
.PARAMETER rg
The name of the resource group to remove.

.EXAMPLE
\.AZRM-RemoveResource.ps1 -csvimport -csvfile C:\temp\iaasdeployment.csv
.EXAMPLE
\.AZRM-RemoveResource.ps1 -removeobject vm -VMName myvm -rg myres
.EXAMPLE
\.AZRM-RemoveResource.ps1 -removeobject rg -rg myres
.EXAMPLE
\.AZRM-RemoveResource.ps1 -removeobject vm -VMName myvm -rg myres -extname opsinsightLinux
.EXAMPLE
\.AZRM-RemoveResource.ps1 -removeobject nsg -nsgname mynsg -rg nsgrg


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
[ValidateSet("azshare","diag","msav","linaccess","winaccess","linuxbackup","linuxospatch","linchefagent","winchefagent","eset","customscript","linuxcustomscript","opsinsightLinux","opsinsightWin","WinPuppet","domjoin","RegisterAzDSC","linuxpushdsc","winpushdsc","bginfo","RegisterLinuxDSC")]
[Alias("ext")]
[string]
$extname = 'diag',
[Parameter(Mandatory=$False,ValueFromPipelinebyPropertyName=$true)]
[string]
$StorageName = $VMName + 'str',
[Parameter(Mandatory=$False,ValueFromPipelinebyPropertyName=$true)]
[switch]
$clobber,
[Parameter(Mandatory=$False,ValueFromPipelinebyPropertyName=$true)]
[switch]
$csvimport,
[Parameter(Mandatory=$False,ValueFromPipelinebyPropertyName=$true)]
[string]
$csvfile = -join $workfolder + "\azrm-remove.csv"
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
  $az = Import-AzureRmContext -Path $ProfileFile
	  $subid = $az.Context.Subscription.Id

	Set-AzureRmContext -SubscriptionId $subid | Out-Null
		Write-Host "Using $ProfileFile"
  }
  else
  {
  Write-Host "Please enter your credentials"
	  if($SubscriptionID)
 { Add-AzureRmAccount -SubscriptionId $SubscriptionID
  Save-AzureRmContext -Path $ProfileFile -Force
  Write-Host "Saved Profile to $ProfileFile" }
	  else
 { Add-AzureRmAccount
  Save-AzureRmContext -Path $ProfileFile -Force
  Write-Host "Saved Profile to $ProfileFile" }
  exit
  }
}

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


Function Remove-ExtensionRM 
{
	param(
		$rg = $rg,
		$VMName = $VMName,
		$RemoveExtName = $RemoveExtName


	)

					Remove-AzureRmVMAccessExtension -ResourceGroupName $rg -VMName $VMName -Name $RemoveExtName -Force -Confirm:$false

}

Function Check-VM {
	param(
	[string]$Location = $Location,
	[string]$rg = $rg,
	[string]$VMName = $VMName
	)
	$extvm = Get-AzureRmVm -Name $VMName -ResourceGroupName $rg -InformationAction SilentlyContinue -WarningAction SilentlyContinue -ErrorAction SilentlyContinue 

if(!$extvm)
{
	Write-Host "Host VM $VMName Not Found, unable to proceed" -ForegroundColor Red
	Start-sleep 3
	Exit
}
} #



Function csv-run {
param(
[string] $csvin = $csvfile
)
try {
	$GetPath = test-path -Path $csvin
	if(!$GetPath)
	{ exit }
	else {
	Write-Host $csvin "File Exists"
		import-csv -Path $csvin -Delimiter ',' | ForEach-Object{.\AZRM-RemoveResource.ps1 -RemoveObject $_.RemoveObject -VMName $_.VMName -rg $_.rg }
	}
}
catch {
	Write-Host -foregroundcolor Yellow `
	"$($_.Exception.Message)"; `
	$LogOut = "$($_.Exception.Message)"
	Log-Command -Description $LogOut -LogFile $LogOutFile
	break
}
}

#region Get Resource Providers
Function Register-RP {
	Param(
		[string]$ResourceProviderNamespace
	)

	# Write-Host "Registering resource provider '$ResourceProviderNamespace'";
	Register-AzureRmResourceProvider -ProviderNamespace $ResourceProviderNamespace �Confirm:$false -WarningAction SilentlyContinue | Out-Null;
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
		$extname = $extname

	)
switch ($extname)
	{
		"access" {
				Write-Host "VM Access Agent VM Image Removal in Process"
				Remove-ExtensionRM -ResourceGroupName $rg -VMName $VMName -RemoveExtName "VMAccess"
				$LogOut = "Removed VM Access Extension"
				Log-Command -Description $LogOut -LogFile $LogOutFile
						exit
}
		"msav" {
				Write-Host "MSAV Agent VM Image Removal in Process"
				Remove-ExtensionRM -ResourceGroupName $rg -VMName $VMName -RemoveExtName "MSAVExtension"
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
		"linuxcustomscript" {
				Write-Host "Removing custom script"
				Remove-ExtensionRM -ResourceGroupName $rg -VMName $VMName -RemoveExtName "CustomscriptLinux"
				$LogOut = "Removed Custom Script  Linux Extension"
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
				Remove-ExtensionRM -ResourceGroupName $rg -VMName $VMName -RemoveExtName "OSPatch"
				$LogOut = "Removed Linux OS Patch Extension"
				Log-Command -Description $LogOut -LogFile $LogOutFile
						exit
				}
		"linuxbackup" {
				Write-Host "Removing Linux VMBackup"
				Remove-ExtensionRM -ResourceGroupName $rg -VMName $VMName -RemoveExtName "VMBackupForLinuxExtension"
				$LogOut = "Removed Linux OS Backup Extension"
				Log-Command -Description $LogOut -LogFile $LogOutFile
						exit
				}
		"chefAgent" {
				Write-Host "Removing Chef Agent"
				Remove-AzureRmVMExtension -ResourceGroupName $rg -VMName $VMName -RemoveExtName "ChefStrap" -Force -Confirm:$false
				$LogOut = "Removed Chef Extension"
				Log-Command -Description $LogOut -LogFile $LogOutFile
				exit
				}
		"linuxCustomScript" {
				Write-Host "Removing Custom Script"
				Remove-AzureRmVMExtension -ResourceGroupName $rg -VMName $VMName -RemoveExtName "CustomscriptLinux" -Force -Confirm:$false -ErrorAction Stop -WarningAction SilentlyContinue -InformationAction SilentlyContinue
				$LogOut = "Removed Custom Script Extension"
				Log-Command -Description $LogOut -LogFile $LogOutFile
				exit
				}
		"opsinsightLinux" {
				Write-Host "Removing Linux Insight Agent"
				Remove-ExtensionRM -ResourceGroupName $rg -VMName $VMName -RemoveExtName "OperationalInsights"
				$LogOut = "Removed OMS Extension"
				Log-Command -Description $LogOut -LogFile $LogOutFile
			
			exit
				}
		"opsinsightWin" {
				Write-Host "Removing Windows Insight Agent"
				Remove-ExtensionRM -ResourceGroupName $rg -VMName $VMName -RemoveExtName "OperationalInsights"
				$LogOut = "Removed OMS Extension"
				Log-Command -Description $LogOut -LogFile $LogOutFile
			exit
				}
		"ESET" {
				Write-Host "Removing File Security"
				Remove-ExtensionRM -ResourceGroupName $rg -VMName $VMName -RemoveExtName "ESET"
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
				$vm = Get-AzureRmVm @commonParams -WarningAction SilentlyContinue -ErrorAction Stop -InformationAction SilentlyContinue

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
				$vm =  Get-AzureRmVM -ResourceGroupName $rg -Name $VMName
				$extcnt = $vm.Extensions.Count
				if($extcnt -ge 1)
				{}

				Write-Host 'Removing the Azure VM...'
				$null = $vm | Remove-AzureRmVM -Force
				$vmnic = 
				Write-Host 'Removing the Azure network interface...'
				foreach($nicUri in $vm.NetworkProfile.NetworkInterfaces.Id)
				{
					$nic = Get-AzureRmNetworkInterface -ResourceGroupName $vm.ResourceGroupName -Name $nicUri.Split('/')[-1]
					Remove-AzureRmNetworkInterface -Name $nic.Name -ResourceGroupName $vm.ResourceGroupName -Force -InformationAction SilentlyContinue -WarningAction SilentlyContinue -ErrorAction SilentlyContinue
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
		[string]$RemoveObject = $RemoveObject,
		[string]$rg = $rg
	)

switch ($RemoveObject)
	{
		"rg" {
		Remove-azRg
		exit
}
		"vm" {
		Check-VM
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
		Check-VM
		Remove-Dsc
		exit
}
		"extension" {
		Check-VM
		UnInstall-Ext -extname $extname
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
		if($currentver-le '4.0.0'){
		Write-Host "expected version 4.0.1 found $ver" -ForegroundColor DarkRed
		exit
			}
}
		else
{
	Write-Host �The Azure PowerShell module is not installed.�
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

Function Login-AddAzureRmProfile
{
Add-AzureRmAccount -WarningAction SilentlyContinue

}

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
$LogOutFile = $logdir+$RemoveObject+'-'+$date+'.log'
$ProfileFile = $workfolder+'\'+$profile+'.json'
$logdir = $workfolder+'\'+'log'+'\'

Verify-AzureVersion # Verifies Azure client Powershell Version

validate-profile # Attempts to use json file for auth, falls back on Add-AzureRmAccount

try {
Get-AzureRmResourceGroup -Location $Location -ErrorAction Stop -WarningAction SilentlyContinue -InformationAction SilentlyContinue| Out-Null
}
catch {
	Write-Host -foregroundcolor Yellow `
	"User has not authenticated, use Add-AzureRmAccount or $($_.Exception.Message)"; `
	Login-AddAzureRmProfile
}

Register-ResourceProviders

Create-Dir
if($csvimport) { csv-run }
					if($RemoveObject)
						{
						Check-RemoveObject
						Remove-Component
						}