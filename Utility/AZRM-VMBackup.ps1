<#
.SYNOPSIS
Written By John Lewis
email: jonos@live.com
Ver 1.0

v 1.0 updates - RTM

Deploys Azure Backup Vault and configures Azure VMs to leverage vault. Provides automated restore to new VM.

.PARAMETER Action

.PARAMETER VMName

.PARAMETER vmrg

.PARAMETER rg

.PARAMETER policyname

.PARAMETER containertype

.PARAMETER Location

.PARAMETER wrkloadtype

.PARAMETER csvimport

.PARAMETER csvfile

.EXAMPLE
.\AZRM-VMBackup.ps1 -csvimport -csvfile C:\temp\backupservers.csv
.EXAMPLE
.\AZRM-VMBackup.ps1 -action createpolicy -vaultname myvault -vaultrg myres -policyname mypolicy
.EXAMPLE
.\AZRM-VMBackup.ps1 -action createvault -vaultname myvault - myres
.EXAMPLE
.\AZRM-VMBackup.ps1 -action addvmcreatevault -backupvmname myvm -backupvmrg myres -vaultname myvault -vaultrg myres
.EXAMPLE
.\AZRM-VMBackup.ps1 -action restorevm -createvmname myvm -createvmrg myres -vaultrg backuprg -vaultname myvaultname
#>


[CmdletBinding(DefaultParameterSetName = 'default')]
Param(
[Parameter(Mandatory=$False,ValueFromPipelinebyPropertyName=$true)]
[ValidateSet("createpolicy","createvault","addvmcreatevault","addvmtovault","restorevm","executebackup","getstatus")]
[string]
$Action = 'createvault',
[Parameter(Mandatory=$False,ValueFromPipelinebyPropertyName=$true)]
[string]
$SubscriptionID = '',
[Parameter(Mandatory=$False,ValueFromPipelinebyPropertyName=$true)]
[string]
$TenantID = '',
[Parameter(Mandatory=$False,ValueFromPipelinebyPropertyName=$true)]
[string]
$vaultrg = "recover",
[Parameter(Mandatory=$False,ValueFromPipelinebyPropertyName=$true)]
[string]
$storeagerg = "resgrp",
[Parameter(Mandatory=$False,ValueFromPipelinebyPropertyName=$true)]
[string]
$location = "West US",
[Parameter(Mandatory=$False,ValueFromPipelinebyPropertyName=$true)]
[string]
$vaultname = "testvault",
[Parameter(Mandatory=$False,ValueFromPipelinebyPropertyName=$true)]
[string]
$backupvmname = 'w2k12001',
[Parameter(Mandatory=$False,ValueFromPipelinebyPropertyName=$true)]
[string]
$backupvmrg = 'resgrp',
[Parameter(Mandatory=$False,ValueFromPipelinebyPropertyName=$true)]
[string]
$createvmname = 'w2k12003',
[Parameter(Mandatory=$False,ValueFromPipelinebyPropertyName=$true)]
[string]
$createvmrg = 'resgrp',
[Parameter(Mandatory=$False,ValueFromPipelinebyPropertyName=$true)]
[string]
$policyname = 'policy',
[Parameter(Mandatory=$False,ValueFromPipelinebyPropertyName=$true)]
[string]
$containertype = 'AzureVM',
[Parameter(Mandatory=$False,ValueFromPipelinebyPropertyName=$true)]
[string]
$wrkloadtype = 'AzureVM',
[Parameter(Mandatory=$False,ValueFromPipelinebyPropertyName=$true)]
[string]
$provider = "Microsoft.RecoveryServices",
[Parameter(Mandatory=$False,ValueFromPipelinebyPropertyName=$true)]
[string]
$Profile = "profile",
[Parameter(Mandatory=$False,ValueFromPipelinebyPropertyName=$true)]
[string]
$csvfile = -join $workfolder + "\azrm-vmbackup.csv",
[Parameter(Mandatory=$False,ValueFromPipelinebyPropertyName=$true)]
[Alias("csv")]
[switch]
$csvimport,
[Parameter(Mandatory=$False)]
[string]
$GenerateName = -join ((65..90) + (97..122) | Get-Random -Count 6 | % {[char]$_}) + "rmp",
[Parameter(Mandatory=$False)]
[string]
$StorageName = $createvmname + 'str',
[Parameter(Mandatory=$False,ValueFromPipelinebyPropertyName=$true)]
[ValidateNotNullorEmpty()]
[Alias("int1")]
[string]
$InterfaceName1 = $createvmname + '_nic1',
[Parameter(Mandatory=$False,ValueFromPipelinebyPropertyName=$true)]
[Alias("int2")]
[string]
$InterfaceName2 = $createvmname + "_nic2",
[Parameter(Mandatory=$False,ValueFromPipelinebyPropertyName=$true,Position=4)]
[ValidateNotNullorEmpty()]
[Alias("vnet")]
[string]
$VNetName = 'vnet',
[Parameter(Mandatory=$False,ValueFromPipelinebyPropertyName=$true)]
[ValidateNotNullorEmpty()]
[string]
$vnetrg = "resgrp",
[Parameter(Mandatory=$False,ValueFromPipelinebyPropertyName=$true)]
[ValidateSet("Standard_LRS","Standard_GRS")]
[string]
$StorageType = 'Standard_GRS',
[Parameter(Mandatory=$False,ValueFromPipelinebyPropertyName=$true)]
[ValidateSet("InProgress","Completed")]
[string]
$status = 'InProgress'

	)
$workfolder = Split-Path $script:MyInvocation.MyCommand.Path
$ProfileFile = $workfolder+'\'+$profile+'.json'


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
  Add-AzureRmAccount
  Save-AzureRmContext -Path $ProfileFile -Force
  Write-Host "Saved Profile to $ProfileFile"
  exit
  }
}

Function csv-run {
param(
[string] $csvin = $csvfile
)
	$GetPath = test-path -Path $csvin
	if(!$csvin)
	{exit}
	else {
	Write-Host $GetPath "File Exists"
import-csv -Path $csvin -Delimiter ',' -ErrorAction SilentlyContinue -InformationAction SilentlyContinue | ForEach-Object{.\AZRM-VMBackup.ps1 -VMName $_.VMName -rg $_.rg -Action $_.Action -vmrg $_.vmrg -servaultname $_.servaultname }
}
}


Function Check-StorageName
{
	param(
		[Parameter(Mandatory=$False,ValueFromPipelinebyPropertyName=$true)]
		[string]$StorageName  = $StorageName
	)
	
	$checkname =  Get-AzureRmStorageAccountNameAvailability -Name $StorageName | Select-Object -ExpandProperty NameAvailable
if($checkname -ne 'False') {
	Write-Host "Storage Account Found..."
	Start-Sleep 5
	$script:StorageNameVerified = $GenerateName.ToLower()
	Restore-VMVHD
	}
	else
		{
		$script:StorageNameVerified = $StorageName.ToLower()
		Create-Storage
		}
		
}


#region Create Storage
Function Create-Storage {
		param(
		[string]$StorageName = $script:StorageNameVerified,
		[string]$StorageType = $StorageType,
		[string]$containerName = 'vhds',
		[string]$Location = $Location,
		[string]$storeagerg = $storeagerg
		)
		Write-Host "Starting Storage Creation..."
		$script:StorageAccount = New-AzureRmStorageAccount -ResourceGroupName $storeagerg -Name $StorageName.ToLower() -Type $StorageType -Location $Location -ErrorAction Stop -WarningAction SilentlyContinue
		Write-Host "Completed Storage Creation" -ForegroundColor White
								Restore-VMVHD
			}


function Reg-Provider {
param($provider = $provider)
Register-AzureRmResourceProvider -ProviderNamespace $provider
}


Function Configure-Backup {
	param(
		[Parameter(Mandatory=$False,ValueFromPipelinebyPropertyName=$true)]
		[string]
		$action = $action
	)
switch ($action)
	{
		"createvault" {
				Write-Host "Creating new Backup Vault $vaultname"
				Create-Vault

}
		"createpolicy" {
				Write-Host "Creating new Policy"
				Create-Policy

		}
		"addvmtovault" {
				Write-Host "Adding VM $backupvmname to $vaultname"
				Get-CurrentPolicies
				AddVM-Vault

		}
		"executebackup" {
				Write-Host "Executing backup of $backupvmname to $vaultname"
				Get-CurrentPolicies
				TriggerBackup-Vault

		}
		"addvmcreatevault" {
			Write-Host "Creating new Backup Vault $vaultname"
			Create-Vault
			Create-Policy
			Write-Host "Adding VM $backupvmname to $vaultname"
			Get-CurrentPolicies
			AddVM-Vault

		}
		"restorevm" {
				Write-Host "Restoring VM"
						Check-StorageName

						Create-VM 
		}
		"getstatus" {
				Write-Host "Obtaining current job information"
				Get-JobProgress
		}
		default{"An unsupported backup command was used"}
	}
	exit
}

Function Get-JobProgress {
	param(
		$status = $status

	)

Get-AzureRmRecoveryservicesBackupJob –Status $status


}


function Create-Vault {
New-AzureRmResourceGroup -Name $vaultrg -Location $Location –Confirm:$false -WarningAction SilentlyContinue -Force | Out-Null
New-AzureRmRecoveryServicesVault -Name $vaultname -ResourceGroupName $vaultrg -Location $location
$vault1 = Get-AzureRmRecoveryServicesVault –Name $vaultname
Set-AzureRmRecoveryServicesBackupProperties  -Vault $vault1 -BackupStorageRedundancy GeoRedundant
}

function Get-Context {
param($vaultname = $vaultname)
Get-AzureRmRecoveryServicesVault -Name $vaultname | Set-AzureRmRecoveryServicesVaultContext
}

function Get-CurrentPolicies {
param( 
$vaultname = $vaultname,
$wrkloadtype = $wrkloadtype
)
Get-AzureRmRecoveryServicesVault -Name $vaultname | Set-AzureRmRecoveryServicesVaultContext
$schPol = Get-AzureRmRecoveryServicesBackupSchedulePolicyObject -WorkloadType $wrkloadtype
$retPol = Get-AzureRmRecoveryServicesBackupRetentionPolicyObject -WorkloadType $wrkloadtype
}

function Create-Policy {
param( 
$vaultname = $vaultname,
$policyname = $policyname,
$wrkloadtype = $wrkloadtype
)
Get-AzureRmRecoveryServicesVault -Name $vaultname | Set-AzureRmRecoveryServicesVaultContext
New-AzureRmRecoveryServicesBackupProtectionPolicy -Name $policyname -WorkloadType $wrkloadtype -RetentionPolicy $retPol -SchedulePolicy $schPol -ErrorAction SilentlyContinue -WarningAction SilentlyContinue -InformationAction SilentlyContinue
$script:pol = Get-AzureRmRecoveryServicesBackupProtectionPolicy -Name $policyname

}

function Modify-Policy {
param( 
$vaultname = $vaultname,
$policyname = $policyname,
$wrkloadtype = $wrkloadtype
)

$retPol = Get-AzureRmRecoveryServicesBackupRetentionPolicyObject -WorkloadType "AzureVM"
$retPol.DailySchedule.DurationCountInDays = 365
$pol= Get-AzureRmRecoveryServicesBackupProtectionPolicy -Name $policyname
Set-AzureRmRecoveryServicesBackupProtectionPolicy -Policy $pol  -RetentionPolicy $RetPol

}

function TriggerBackup-Vault {
param( 
$vaultname = $vaultname,
$backupvmname = $backupvmname,
$containertype = "AzureVM"
)
Get-AzureRmRecoveryServicesVault -Name $vaultname | Set-AzureRmRecoveryServicesVaultContext
$namedContainer = Get-AzureRmRecoveryServicesBackupContainer -ContainerType $containertype -Status "Registered" -FriendlyName $backupvmname
$item = Get-AzureRmRecoveryServicesBackupItem -Container $namedContainer -WorkloadType "AzureVM"
$job = Backup-AzureRmRecoveryServicesBackupItem -Item $item
}

function AddVM-Vault {
param( 
$vaultname = $vaultname,
$backupvmname = $backupvmname,
$containertype = "AzureVM",
$vaultrg = $backupvmrg
)
Get-AzureRmRecoveryServicesVault -Name $vaultname | Set-AzureRmRecoveryServicesVaultContext
$script:pol = Get-AzureRmRecoveryServicesBackupProtectionPolicy -Name $policyname
Enable-AzureRmRecoveryServicesBackupProtection -Policy $script:pol -Name $backupvmname -ResourceGroupName $vaultrg
$namedContainer = Get-AzureRmRecoveryServicesBackupContainer -ContainerType $containertype -Status "Registered" -FriendlyName $backupvmname
$item = Get-AzureRmRecoveryServicesBackupItem -Container $namedContainer -WorkloadType "AzureVM"
$job = Backup-AzureRmRecoveryServicesBackupItem -Item $item
$job
}

Function Get-RestorePoint {

Get-AzureRmRecoveryServicesVault -Name $vaultname | Set-AzureRmRecoveryServicesVaultContext
$startDate = (Get-Date).AddDays(-7)
$endDate = Get-Date
$rp = Get-AzureRmRecoveryServicesBackupRecoveryPoint -Item $backupitem -StartDate $startdate.ToUniversalTime() -EndDate $enddate.ToUniversalTime()
$rp[0]


}

function Restore-VMVHD {
param(
$vaultname = $vaultname,
$storeagerg = $storeagerg,
$StorageName = $script:StorageNameVerified,
$backupvmname = $backupvmname

)
Get-AzureRmRecoveryServicesVault -Name $vaultname | Set-AzureRmRecoveryServicesVaultContext
$namedContainer = Get-AzureRmRecoveryServicesBackupContainer  -ContainerType "AzureVM" –Status "Registered" -FriendlyName $backupvmname -WarningAction SilentlyContinue -InformationAction SilentlyContinue -ErrorAction Stop
$backupitem = Get-AzureRmRecoveryServicesBackupItem –Container $namedContainer  –WorkloadType "AzureVM" -InformationAction SilentlyContinue -WarningAction SilentlyContinue -ErrorAction Stop
$startDate = (Get-Date).AddDays(-7)
$endDate = Get-Date
$rp = Get-AzureRmRecoveryServicesBackupRecoveryPoint -Item $backupitem -StartDate $startdate.ToUniversalTime() -EndDate $enddate.ToUniversalTime() -WarningAction SilentlyContinue -ErrorAction Stop -InformationAction SilentlyContinue
$rp[0]
Write-Host "Preparing Restore Job"
$restorejob = Restore-AzureRmRecoveryServicesBackupItem -RecoveryPoint $rp[0] -StorageAccountName $StorageName -StorageAccountResourceGroupName $storeagerg -WarningAction SilentlyContinue -InformationAction SilentlyContinue -ErrorAction Stop
Wait-AzureRmRecoveryServicesBackupJob -Job $restorejob -Timeout 43200 -WarningAction SilentlyContinue -InformationAction SilentlyContinue -ErrorAction Stop
Write-Host "Restore Job Running"
$script:restorejob = $restorejob
$restorejob = Get-AzureRmRecoveryServicesBackupJob -Job $script:restorejob -InformationAction SilentlyContinue -WarningAction SilentlyContinue -ErrorAction Stop
$JobDetails = Get-AzureRmRecoveryServicesBackupJobDetails -Job $restorejob -InformationAction SilentlyContinue -WarningAction SilentlyContinue -ErrorAction Stop
$properties = $JobDetails.properties
$properties
$storageAccountName = $properties["Target Storage Account Name"]
$containerName = $properties["Config Blob Container Name"]
$blobName = $properties["Config Blob Name"]

Write-Host $storageAccountName
Write-Host $blobName
Write-Host $containerName

Write-Host "Completed restore job"
Set-AzureRmCurrentStorageAccount -Name $storageaccountname -ResourceGroupName $storeagerg
$destination_path = "C:\temp\$blobName.json"

Get-AzureStorageBlobContent -Container $containerName -Blob $blobName -Destination $destination_path -ErrorAction Stop -WarningAction SilentlyContinue -InformationAction SilentlyContinue
$obj = ((Get-Content -Path $destination_path -Raw -Encoding Unicode)).TrimEnd([char]0x00) | ConvertFrom-Json
Write-Host "Exported json configuration file to $destination_path"
$vm = New-AzureRmVMConfig -VMSize $obj.'properties.hardwareProfile'.vmSize -VMName $createvmname -ErrorAction Stop -WarningAction SilentlyContinue -InformationAction SilentlyContinue
Set-AzureRmVMOSDisk -VM $vm -Name "osdisk" -VhdUri $obj.'properties.StorageProfile'.osDisk.vhd.Uri -CreateOption "Attach" -WarningAction SilentlyContinue -ErrorAction Stop -InformationAction SilentlyContinue
$vm.StorageProfile.OsDisk.OsType = $obj.'properties.StorageProfile'.OsDisk.OsType
foreach($dd in $obj.'properties.StorageProfile'.DataDisks)
 {
 $vm = Add-AzureRmVMDataDisk -VM $vm -Name "datadisk1" -VhdUri $dd.vhd.Uri -DiskSizeInGB 128 -Lun $dd.Lun -CreateOption "Attach"
 }
Write-Host "Completed data disk configuration"
$pip = New-AzureRmPublicIpAddress -Name $InterfaceName1 -ResourceGroupName $createvmrg -Location $Location -AllocationMethod "Dynamic" –Confirm:$false -WarningAction SilentlyContinue  -ErrorAction Stop
Write-Host "Completed public ip creation"
$script:VNet = Get-AzureRMVirtualNetwork -Name $VNetName -ResourceGroupName $vnetrg | Set-AzureRmVirtualNetwork
$script:Interface1 = New-AzureRmNetworkInterface -Name $InterfaceName1 -ResourceGroupName $createvmrg -Location $Location -SubnetId $VNet.Subnets[3].Id -PublicIpAddressId $pip.Id –Confirm:$false -WarningAction SilentlyContinue  -ErrorAction Stop -EnableIPForwarding
$script:VirtualMachine = Add-AzureRmVMNetworkInterface -VM $vm -Id $script:Interface1.Id -Primary -WarningAction SilentlyContinue  -ErrorAction Stop
Write-Host "Completed vm prep"

}
Function Create-VM 
{
	Write-Host "Creating VM"
	New-AzureRmVM -ResourceGroupName $createvmrg -Location $location -VM $script:VirtualMachine

}

Reg-Provider

if($csvimport) {
	try {
	csv-run
	}
	catch {
	Write-Host -foregroundcolor Yellow `
	"$($_.Exception.Message)"; `
	break
	}
}

Configure-Backup

