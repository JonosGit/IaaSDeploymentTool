<#
.SYNOPSIS
Written By John Lewis
email: jonos@live.com
Ver 1.0
Deploys Virtual Machine Extensions to existing Azure RM VMs. Supports standard extensions as well as DSC and Custom Scripts.

v 1.0 updates 

.DESCRIPTION

.PARAMETER VMName

.PARAMETER rg

.PARAMETER locadmin

.PARAMETER locpassword

.PARAMETER Location

.PARAMETER GenerateName

.PARAMETER StorageName

.PARAMETER StorageType

.PARAMETER Azautoacct

.PARAMETER Profile

.PARAMETER AzExtConfig

.PARAMETER BatchAddExtension

.PARAMETER CustomScriptUpload

.PARAMETER dscname

.PARAMETER scriptname

.PARAMETER containername

.PARAMETER customextname

.PARAMETER scriptfolder

.PARAMETER localfolder

.PARAMETER csvimport

.PARAMETER csvfile

.PARAMETER help

.EXAMPLE
\.AZRM-ExtDeploy.ps1 -csvimport -csvfile C:\temp\iaasdeployment.csv
.EXAMPLE
\.AZRM-ExtDeploy.ps1 -ExtName diag -rg ResourceGroup -vmname myvm
-ExtName <Extension Type>
			access – Adds Azure Access Extension – Added by default during VM creation
			msav – Adds Azure Antivirus Extension
			custScript – Adds Custom Script for Execution (Requires Table Storage Configuration first)
			pushdsc - Deploys DSC Configuration to Azure VM
			diag – Adds Azure Diagnostics Extension
			linuxOsPatch - Deploy Latest updates for Linux platforms
			linuxbackup - Deploys Azure Linux backup Extension
			addDom – Adds Azure Domain Join Extension
			chef – Adds Azure Chef Extension (Requires Chef Certificate and Settings info first)
			opsinsightLinux - OMS Agent
			opsinsightWin - OMS Agent
			eset - File Security Ext
			WinPuppet - Puppet Agent Install for Windows
.LINK
https://github.com/JonosGit/IaaSDeploymentTool
https://github.com/JonosGit/IaaSDeploymentTool/blob/master/The%20IaaS%20Deployment%20Tool%20User%20Guide.pdf
#>

[CmdletBinding(DefaultParameterSetName = 'default')]
Param(

[Parameter(Mandatory=$False,ValueFromPipelinebyPropertyName=$true)]
[ValidateSet("diag","msav","access","linuxbackup","chefagent","eset","customscript","opsinsightLinux","opsinsightWin","WinPuppet","domjoin","RegisterAzDSC","PushDSC","bginfo")]
[Alias("AzExtConfig")]
[string]
$extname = 'diag',
[Parameter(Mandatory=$False,ValueFromPipelinebyPropertyName=$true,Position=1)]
[ValidateNotNullorEmpty()]
[Alias("vm")]
[string]
$VMName = '',
[ValidateNotNullorEmpty()]
[Parameter(Mandatory=$False,ValueFromPipelinebyPropertyName=$true,Position=0)]
[string]
$rg = '',
[Parameter(Mandatory=$False,ValueFromPipelinebyPropertyName=$true)]
[ValidateNotNullorEmpty()]
[ValidateSet("Standard_A3","Standard_A4","Standard_A2")]
[string]
$VMSize = 'Standard_A3',
[Parameter(Mandatory=$False,ValueFromPipelinebyPropertyName=$true)]
[ValidateNotNullorEmpty()]
[string]
$locadmin = 'localadmin',
[Parameter(Mandatory=$false,ValueFromPipelinebyPropertyName=$true)]
[ValidateNotNullorEmpty()]
[string]
$locpassword = 'P@ssW0rd!',
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
[Parameter(Mandatory=$False)]
[string]
$GenerateName = -join ((65..90) + (97..122) | Get-Random -Count 6 | % {[char]$_}) + "aip",
[Parameter(Mandatory=$False)]
[string]
$StorageName = $VMName + 'str',
[Parameter(Mandatory=$False,ValueFromPipelinebyPropertyName=$true)]
[ValidateSet("Standard_LRS","Standard_GRS")]
[string]
$StorageType = 'Standard_GRS',
[Parameter(Mandatory=$False,ValueFromPipelinebyPropertyName=$true)]
[string]
$Azautoacct = "DSC-Auto",
[Parameter(Mandatory=$False,ValueFromPipelinebyPropertyName=$true)]
[string]
$Profile = "profile",
[Parameter(Mandatory=$False,ValueFromPipelinebyPropertyName=$true)]
[Alias("addext")]
[switch]
$AddExtension,
[Parameter(Mandatory=$False,ValueFromPipelinebyPropertyName=$true)]
[string]
$BatchAddExtension = 'False',
[Parameter(Mandatory=$False,ValueFromPipelinebyPropertyName=$true)]
[ValidateSet("True","False")]
[Alias("upload")]
[string]
$CustomScriptUpload = 'True',
[Parameter(Mandatory=$False,ValueFromPipelinebyPropertyName=$true)]
[Alias("dscscriptname")]
[string]
$DSCConfig = 'WIN_MSUpdate',
[Parameter(Mandatory=$False,ValueFromPipelinebyPropertyName=$true)]
[Alias("customscriptname")]
[string]
$scriptname = 'WFirewall.ps1',
[Parameter(Mandatory=$False,ValueFromPipelinebyPropertyName=$true)]
[string]
$containername = 'scripts',
[Parameter(Mandatory=$False,ValueFromPipelinebyPropertyName=$true)]
[string]
$customextname = 'customscript',
[Parameter(Mandatory=$False,ValueFromPipelinebyPropertyName=$true)]
[string]
$scriptfolder = $workfolder,
[Parameter(Mandatory=$False,ValueFromPipelinebyPropertyName=$true)]
[string]
$localfolder = "$scriptfolder\scripts",
[Parameter(Mandatory=$False,ValueFromPipelinebyPropertyName=$true)]
[switch]
$csvimport,
[Parameter(Mandatory=$False,ValueFromPipelinebyPropertyName=$true)]
[string]
$csvfile = -join $workfolder + "\azrm-vmdeploy.csv"
)

$SecureLocPassword=Convertto-SecureString $locpassword –asplaintext -Force
$Credential1 = New-Object System.Management.Automation.PSCredential ($locadmin,$SecureLocPassword)
# $Error.Clear()
Set-StrictMode -Version Latest
# Trap [System.SystemException] {("Exception" + $_ ) ; break}

#region Validate Profile
Function validate-profile {
$comparedate = (Get-Date).AddDays(-14)
$fileexist = Test-Path $ProfileFile -NewerThan $comparedate
  if($fileexist)
  {
  Select-AzureRmProfile -Path $ProfileFile | Out-Null
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

Function WriteLog-Command([string]$Description, [ScriptBlock]$Command, [string]$LogFile, [string]$VMName ){
Try{
$Output = $Description+'  ... '
Write-Host $Output -ForegroundColor Blue
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

#region Use CSV
Function csv-run {
param(
[string] $csvin = $csvfile
)
	$GetPath = test-path -Path $csvin
	if(!$csvin)
	{exit}
	else {
	Write-Host $GetPath "File Exists"
import-csv -Path $csvin -Delimiter ',' -ErrorAction SilentlyContinue -InformationAction SilentlyContinue | ForEach-Object{.\AZRM-ExtDeploy.ps1 -VMName $_.VMName -rg $_.rg -ExtName $_.AzExtConfig -CustomScriptUpload $_.CustomScriptUpload -scriptname $_.scriptname -containername $_.containername -scriptfolder $_.scriptfolder -customextname $_.customextname }
}
}
#endregion

#region Check Values of runtime params
function Check-NullValues {
if(!$rg) {
Write-Host "Please Enter Resource Group Name"
exit
}
	elseif(!$VMName) {
	Write-Host "Please Enter vmName"
	exit
	}
				elseif(!$Location) {
				Write-Host "Please Enter Location"
				exit
				}
}

function Check-ExtensionUnInstall {
if($RemoveExtension -and !$rg) {
	Write-Host "Please Enter RG Name"
	exit
	}
	elseif($RemoveExtension -and !$VMName) {
	Write-Host "Please Enter VM Name"
	exit
	}
}

function Check-NSGName {
if($UpdateNSG -and !$NSGName) {
Write-Host "Please Enter NSG Name"
exit
 }
	elseif($UpdateNSG -and !$rg)
	{
		Write-Host "Please Enter Resouce Group"
		exit
	}
}

function Check-Extension {
if($AddExtension -and !$extname) {
Write-Host "Please Enter Extension Name"
 }
}
#endregion

#region Check Storage
Function Check-StorageName
{
	param(
		[string]$StorageName  = $StorageName
	)
$extvm = Get-AzureRmVm -Name $VMName -ResourceGroupName $rg -ErrorAction SilentlyContinue
	if($extvm) {exit}
		$checkname =  Get-AzureRmStorageAccountNameAvailability -Name $StorageName | Select-Object -ExpandProperty NameAvailable
if($checkname -ne 'True') {
	Write-Host "Storage Account Name in use, generating random name for storage..."
	Start-Sleep 5
	$script:StorageNameVerified = $GenerateName.ToLower()
	Write-Host "Storage Name Check Completed for:" $StorageNameVerified
		}
	else
		{
	$script:StorageNameVerified = $StorageName.ToLower()
	Write-Host "Storage Name Check Completed for:" $StorageNameVerified
	}
}
#endregion

#region Get Resource Providers
Function Register-RP {
	Param(
		[string]$ResourceProviderNamespace
	)

	# Write-Host "Registering resource provider '$ResourceProviderNamespace'";
	Register-AzureRmResourceProvider -ProviderNamespace $ResourceProviderNamespace –Confirm:$false -WarningAction SilentlyContinue | Out-Null;
}

#region Deploy VM
 function Provision-Vm {
	 param (
	[string]$rg = $rg,
	[string]$Location = $Location
	 )
	$ProvisionVMs = @($VirtualMachine);
try {
   foreach($provisionvm in $ProvisionVMs) {
		New-AzureRmVM -ResourceGroupName $rg -Location $Location -VM $VirtualMachine -DisableBginfoExtension –Confirm:$false -WarningAction SilentlyContinue -ErrorAction Stop | Out-Null
		$LogOut = "Completed Configuration of $VMName"
		Log-Command -Description $LogOut -LogFile $LogOutFile
						}
	}
catch {
	Write-Host -foregroundcolor Yellow `
	"Exception Encountered"; `
	$LogOut = "$($_.Exception.Message)"
	Log-Command -Description $LogOut -LogFile $LogOutFile
	break
}
	 }
#endregion

#region Provision Resource Group
Function Provision-RG
{
	Param(
		[string]$rg
	)
New-AzureRmResourceGroup -Name $rg -Location $Location –Confirm:$false -WarningAction SilentlyContinue -Force | Out-Null
}
#endregion

#region Create Storage
Function Create-Storage {
		param(
		[string]$StorageName = $script:StorageNameVerified,
		[string]$rg = $rg,
		[string]$StorageType = $StorageType,
		[string]$Location = $Location
		)
		Write-Host "Starting Storage Creation.."
		$script:StorageAccount = New-AzureRmStorageAccount -ResourceGroupName $rg -Name $StorageName.ToLower() -Type $StorageType -Location $Location -ErrorAction Stop -WarningAction SilentlyContinue
		Write-Host "Completed Storage Creation" -ForegroundColor White
		$LogOut = "Storage Configuration completed: $StorageName"
		Log-Command -Description $LogOut -LogFile $LogOutFile
		} # Creates Storage
#endregion

#region Configure DSC
Function Configure-DSC {
param(

 [Parameter(Mandatory=$False,ValueFromPipelinebyPropertyName=$true)]
 [ValidateSet("WIN_MSUpdate")]
 [string]
 $DSCConfig = 'WIN_MSUpdate',

[Parameter(Mandatory=$False,ValueFromPipelinebyPropertyName=$true)]
 [string]
 $ConfigurationName = "MuSecurityImportant",
 [Parameter(Mandatory=$False,ValueFromPipelinebyPropertyName=$true)]
 [string]
 $ArchiveBlobName = "WindowsUpdate.ps1.zip",

 [Parameter(Mandatory=$False,ValueFromPipelinebyPropertyName=$true)]
 [string]
 $ConfigurationPath = $dscdir + '\WindowsUpdate.ps1',

 [Parameter(Mandatory=$False,ValueFromPipelinebyPropertyName=$true)]
 [string]
 $storageAccountName = $script:StorageNameVerified,

 [Parameter(Mandatory=$False,ValueFromPipelinebyPropertyName=$true)]
 [string]
 $StorageType = "Standard_GRS"

)

	 switch -Wildcard ($DSCConfig)
	{
		"*WIN_MSUpdate*" {
		Publish-AzureRmVMDscConfiguration -ResourceGroupName $rg -ConfigurationPath $ConfigurationPath -StorageAccountName $storageAccountName -Force
		Set-AzureRmVMDscExtension -ResourceGroupName $rg -VMName $VMName -ArchiveBlobName $ArchiveBlobName -ArchiveStorageAccountName $storageAccountName -ConfigurationName $ConfigurationName -Version 2.19
		$LogOut = "Added VM DSC to Storage Account $storageAccountName from file $ConfigurationPath"
		Log-Command -Description $LogOut -LogFile $LogOutFile
}
		default{"An unsupported DSC command was used"}
	}
}
#endregion

#region Verify Upload Resources
Function Test-Upload {
param(
	$localFolder = $localFolder
	)

$folderexist = Test-Path -Path $localFolder
if(!$folderexist)
{
Write-Host "Folder Doesn't Exist"
exit }
else
{  }
}
#endregion

#region Upload Custom Script
Function Upload-CustomScript {
	param(
	$StorageName = $script:StorageNameVerified,
	$containerName = $containerName,
	$rg = $rg,
	$localFolder = $localFolder
	)
		$Keys = Get-AzureRmStorageAccountKey -ResourceGroupName $rg -Name $StorageName;
		$StorageContext = New-AzureStorageContext -StorageAccountName $StorageName -StorageAccountKey $Keys[0].Value;
		New-AzureStorageContainer -Context $StorageContext -Name $containerName -WarningAction SilentlyContinue -ErrorAction SilentlyContinue;
		$storageAccountKey = Get-AzureRmStorageAccountKey -ResourceGroupName $rg -Name $StorageName;
		$blobContext = New-AzureStorageContext -StorageAccountName $StorageName -StorageAccountKey $Keys[0].Value;
		$files = Get-ChildItem $localFolder
		foreach($file in $files)
		{
		  $fileName = "$localFolder\$file"
		  $blobName = "$file"
		  Set-AzureStorageBlobContent -File $filename -Container $containerName -Blob $blobName -Context $blobContext -Force -BlobType Append -WarningAction SilentlyContinue -ErrorAction SilentlyContinue -Confirm:$false | Out-Null
		  Get-AzureStorageBlob -Container $containerName -Context $blobContext -Blob $blobName -WarningAction SilentlyContinue | Out-Null
}
write-host "All files in $localFolder uploaded to $containerName!"
}
#endregion

#region Uninstall Extension
Function UnInstall-Ext {
	param(
		[string]$Location = $Location,
		[string]$rg = $rg,
		[string]$VMName = $VMName,
		[string]$customextname = $customextname,
		[string]$extname = $extname

	)
switch ($extname)
	{
		"access" {
Write-Host "VM Access Agent VM Image Removal in Process"
Remove-AzureRmVMAccessExtension -ResourceGroupName $rg -VMName $VMName -Name "VMAccess" -Force -Confirm:$false
exit
}
		"msav" {
Write-Host "MSAV Agent VM Image Removal in Process"
Remove-AzureRmVMExtension -Name "MSAVExtension" -ResourceGroupName $rg -VMName $VMName -Force -Confirm:$false
exit
		}
		"customscript" {
Write-Host "Removing custom script"
			exit
		}
		"diag" {
Write-Host "Removing Azure Enhanced Diagnostics"
Remove-AzureRmVMAEMExtension -ResourceGroupName $rg -VMName $VMName
			exit
		}
		"domjoin" {
Write-Host "Removing Domain Join"
		}
		"linuxOsPatch" {
Write-Host "Removing Azure OS Patching Linux"
			exit
				}
		"linuxbackup" {
Write-Host "Removing Linux VMBackup"
Remove-AzureRmVMBackup -ResourceGroupName $rg -VMName $VMName -Tag 'OSBackup'
			exit
				}
		"chefAgent" {
Write-Host "Removing Chef Agent"
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
Write-Host "Removing DSC Extension"
Remove-DscExt
			exit
				}
		"Bginfo" {
Write-Host "Removing BgInfo Extension"
Remove-AzureVMBGInfoExtension -VM $VMName
			exit
				}
		default{"An unsupported uninstall Extension command was used"}
	}
	exit
} # Deploys Azure Extensions
#endregion

Function Verify-StorageExists {
	param(
		$StorageName = $StorageName

	)
		$strexists = Get-AzureRmStorageAccount -ResourceGroupName $rg -Name $StorageName.ToLower() -WarningAction SilentlyContinue -ErrorAction SilentlyContinue
if(!$strexists)
{
	 $script:StorageNameVerified = $GenerateName.ToLower()
	Create-Storage
	break
}
	else {
	$script:StorageNameVerified = $StorageName.ToLower()
}
	}

#region Install Extension
Function Install-Ext {
	param(
		[string]$extname = $extname,
		[string]$Location = $Location,
		[string]$rg = $rg,
		[string]$StorageName = $script:StorageNameVerified,
		[string]$VMName = $VMName,
		[string]$containerNameScripts = 'scripts',
		[string]$DomName =  'aip.local',
		[string]$customextname = $customextname,
		[string]$localfolderscripts = $customscriptsdir
	)
switch ($extname)
	{
		"access" {
				Write-Host "VM Access Agent VM Image Preparation in Process"
				Set-AzureRmVMAccessExtension -ResourceGroupName $rg -VMName $VMName -Name "VMAccess" -typeHandlerVersion "2.0" -Location $Location -Verbose -username $locadmin -password $locpassword -ErrorAction Stop | Out-Null
				Get-AzureRmVMAccessExtension -ResourceGroupName $rg -VMName $VMName -Name "VMAccess" -Status
				$LogOut = "VM Access Agent Deployed to $VMName"
				Log-Command -Description $LogOut -LogFile $LogOutFile
						Write-Results

									break
}
		"msav" {
				Write-Host "MSAV Agent VM Image Preparation in Process"
				Set-AzureRmVMExtension  -ResourceGroupName $rg -VMName $VMName -Name "MSAVExtension" -ExtensionType "IaaSAntimalware" -Publisher "Microsoft.Azure.Security" -typeHandlerVersion 1.4 -Location $Location  -ErrorAction Stop | Out-Null
				Get-AzureRmVMExtension -ResourceGroupName $rg -VMName $VMName -Name "MSAVExtension" -Status
				$LogOut = "MSAV Agent Deployed to $VMName"
				Log-Command -Description $LogOut -LogFile $LogOutFile
						Write-Results

									  break
}
		"customscript" {
				Verify-StorageExists
				Write-Host "Updating: $VMName in the Resource Group: $rg with a custom script: $customextname in Storage Account: $StorageName"
				if($CustomScriptUpload -eq 'True')
				{
				Test-Upload -localFolder $localfolderscripts
				Upload-CustomScript -StorageName $StorageName -rg $rg -containerName $containerNameScripts -localFolder $localfolderscripts
				}
				Set-AzureRmVMCustomScriptExtension -Name $customextname -ContainerName $containerName -ResourceGroupName $rg -VMName $VMName -StorageAccountName $StorageName -FileName $scriptname -Location $Location -TypeHandlerVersion "1.1" -WarningAction SilentlyContinue  -ErrorAction Stop | Out-Null
				Get-AzureRmVMCustomScriptExtension -ResourceGroupName $rg -VMName $VMName -Name $customextname -Status | Out-Null
				$LogOut = "Custom Script Deployed to $VMName"
				Log-Command -Description $LogOut -LogFile $LogOutFile
						Write-Results

									  break
}
		"diag" {
				Verify-StorageExists
				Write-Host "Adding Azure Enhanced Diagnostics to $VMName in $rg using the $StorageName Storage Account"
				Set-AzureRmVMAEMExtension -ResourceGroupName $rg -VMName $VMName -WADStorageAccountName $StorageName -InformationAction SilentlyContinue  -ErrorAction Stop -WarningAction SilentlyContinue | Out-Null
				Get-AzureRmVMAEMExtension -ResourceGroupName $rg -VMName $VMName | Out-Null
				$LogOut = "Azure Enhanced Diagnostics Deployed to $VMName"
				Log-Command -Description $LogOut -LogFile $LogOutFile
						Write-Results

									  break
}
		"domjoin" {
				Write-Host "Domain Join active"
				Set-AzureRmVMADDomainExtension -DomainName $DomName -ResourceGroupName $rg -VMName $VMName -Location $Location -Name 'DomJoin'  -ErrorAction Stop -WarningAction SilentlyContinue -Restart | Out-Null
				Get-AzureRmVMADDomainExtension -ResourceGroupName $rg  -VMName $VMName -Name 'DomJoin' | Out-Null
				$LogOut = "Domain join Deployed to $VMName"
				Log-Command -Description $LogOut -LogFile $LogOutFile
						Write-Results

									  break
}
		"linuxOsPatch" {
				Write-Host "Adding Azure OS Patching Linux"
				Set-AzureRmVMExtension -VMName $VMName -ResourceGroupName $rg -Location $Location -Name "OSPatch" -ExtensionType "OSPatchingForLinux" -Publisher "Microsoft.OSTCExtensions" -typeHandlerVersion "2.0" -InformationAction SilentlyContinue -ErrorAction Stop  -Verbose
				Get-AzureRmVMExtension -ResourceGroupName $rg -VMName $VMName -Name "OSPatch"
				$LogOut = "OS Patching Deployed to $VMName"
				Log-Command -Description $LogOut -LogFile $LogOutFile
						Write-Results

										  break
		}
		"linuxbackup" {
				Write-Host "Adding Linux VMBackup to $VMName in the resource group $rg"
				Set-AzureRmVMBackupExtension -VMName $VMName -ResourceGroupName $rg -Name "VMBackup" -Tag "OSBackup" -WarningAction SilentlyContinue | Out-Null
				$LogOut = "Linux Backup Deployed to $VMName"
				Log-Command -Description $LogOut -LogFile $LogOutFile
						Write-Results

									  break
		}
		"chefAgent" {
				Write-Host "Adding Chef Agent"
				$ProtectedSetting = ''
				$Setting = ''
				Set-AzureRmVMExtension -ResourceGroupName $rg -VMName $VMName -Name "ChefStrap" -ExtensionType "ChefClient" -Publisher "Chef.Bootstrap.WindowsAzure" -typeHandlerVersion "1210.12" -Location $Location -Verbose -ProtectedSettingString $ProtectedSetting -SettingString $Setting -ErrorAction Stop  | Out-Null
				Get-AzureRmVMExtension -ResourceGroupName $rg -VMName $VMName -Name "ChefStrap"
				$LogOut = "Chef Agent Deployed to $VMName"
				Log-Command -Description $LogOut -LogFile $LogOutFile
						Write-Results

													  break
}
		"opsinsightLinux" {
				Write-Host "Adding Linux Insight Agent"
				Set-AzureRmVMExtension -VMName $VMName -ResourceGroupName $rg -Location $Location -Name "OperationalInsights" -ExtensionType "OmsAgentForLinux" -Publisher "Microsoft.EnterpriseCloud.Monitoring" -typeHandlerVersion "1.0" -InformationAction SilentlyContinue  -ErrorAction Stop -Verbose | Out-Null
				Get-AzureRmVMExtension -ResourceGroupName $rg -VMName $VMName -Name "OperationalInsights"
				$LogOut = "Ops Insight Deployed to $VMName"
				Log-Command -Description $LogOut -LogFile $LogOutFile
						Write-Results

													  break
}
		"opsinsightWin" {
				Write-Host "Adding Windows Insight Agent"
				Set-AzureRmVMExtension -VMName $VMName -ResourceGroupName $rg -Location $Location -Name "OperationalInsights" -ExtensionType "MicrosoftMonitoringAgent" -Publisher "Microsoft.EnterpriseCloud.Monitoring" -typeHandlerVersion "1.0" -InformationAction SilentlyContinue  -ErrorAction Stop  -Verbose | Out-Null
				Get-AzureRmVMExtension -ResourceGroupName $rg -VMName $VMName -Name "OperationalInsights"
				$LogOut = "Widows Insight Deployed to $VMName"
				Log-Command -Description $LogOut -LogFile $LogOutFile
						Write-Results

													  break
}
		"ESET" {
				Write-Host "Setting File Security"
				Set-AzureRmVMExtension -VMName $VMName -ResourceGroupName $rg -Location $Location -Name "ESET" -ExtensionType "FileSecurity" -Publisher "ESET" -typeHandlerVersion "6.0" -InformationAction SilentlyContinue -Verbose  -ErrorAction Stop | Out-Null
				Get-AzureRmVMExtension -ResourceGroupName $rg -VMName $VMName -Name "ESET"
				$LogOut = "ESET Deployed to $VMName"
				Log-Command -Description $LogOut -LogFile $LogOutFile
						Write-Results

										  break
}
		"PushDSC" {
				Verify-StorageExists
				Configure-DSC
				Write-Host "Pushing DSC to $VMName in the $rg Resource Group"
						Write-Results

										  break
}
		"RegisterAzDSC" {
				Write-Host "Registering with Azure Automation DSC"
				$ActionAfterReboot = 'ContinueConfiguration'
				$configmode = 'ApplyAndAutocorrect'
				$AutoAcctName = $Azautoacct
				$NodeName = -join $VMNAME+".node"
				$ConfigurationName = -join $VMNAME+".node"
				Register-AzureRmAutomationDscNode -AutomationAccountName $AutoAcctName -AzureVMName $VMName -ActionAfterReboot $ActionAfterReboot -ConfigurationMode $configmode -RebootNodeIfNeeded $True -ResourceGroupName $rg -NodeConfigurationName $ConfigurationName -AzureVMLocation $Location -AzureVMResourceGroup $rg -Verbose | Out-Null
										  break
}
		"WinPuppet" {
				Write-Host "Deploying Puppet Extension"
				Set-AzureRmVMExtension -VMName $VMName -ResourceGroupName $rg -Location $Location -Name "PuppetEnterpriseAgent" -ExtensionType "PuppetEnterpriseAgent" -Publisher "PuppetLabs" -typeHandlerVersion "3.2" -InformationAction SilentlyContinue -ErrorAction Stop -Verbose | Out-Null
				Get-AzureRmVMExtension -ResourceGroupName $rg -VMName $VMName -Name "PuppetEnterpriseAgent"
				$LogOut = "Puppet Enterprise Deployed to $VMName"
				Log-Command -Description $LogOut -LogFile $LogOutFile
						Write-Results

			break
}
		default{"An unsupported Extension command was used"}
	}
	exit
} # Deploys Azure Extensions
#endregion

Function Create-ResourceGroup {
				$resourcegroups = @($rg,$vnetrg);
				if($resourcegroups.length) {
					foreach($resourcegroup in $resourcegroups) {
						Provision-RG($resourcegroup);
					}
				}
}

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
		Write-Host "expected version 2.0.1 found $ver" -ForegroundColor DarkRed
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

Function Write-Results {
param(

)
Write-Host "                                                               "
Write-Host "------------------------------------------------------" -ForegroundColor Cyan
Write-Host "                                                               "
Write-Host "Completed Deployment of:"  -ForegroundColor Cyan

Write-Host "VM Name: $VMName " -ForegroundColor White
Write-Host "Resource Group Name: $rg"
Write-Host "Storage Account Name:  $StorageNameVerified"

if($AddExtension -or $BatchAddExtension -eq 'True'){
Write-Host "Extension deployed: $extname "
Write-Host "                                                               "
$time = " End Time " + (Get-Date -UFormat "%d-%m-%Y %H:%M:%S")
Write-Host Extension Install - $time ------ -ForegroundColor Cyan
Write-Host "                                                               "
}
}

Function Write-Config {
param(

)

Write-Host "                                                               "
$time = " Start Time " + (Get-Date -UFormat "%d-%m-%Y %H:%M:%S")
Write-Host Extension Install - $time ---- -ForegroundColor Cyan
Write-Host "                                                               "
Write-Host "VM Name: $VMName " -ForegroundColor White
Write-Host "Resource Group Name: $rg"
Write-Host "Geo Location: $Location"
Write-Host "Storage Account Name: $StorageName"
Write-Host "Storage Account Type: $StorageType"

if($AddExtension -or $BatchAddExtension -eq 'True') {
Write-Host "Extension selected for deployment: $extname "
}
}

Function Check-VM {
	param(
	[Parameter(Mandatory=$False,ValueFromPipelinebyPropertyName=$true)]
	[string]
	$InterfaceName1 = $VMName + "_nic1",
	[Parameter(Mandatory=$False,ValueFromPipelinebyPropertyName=$true)]
	[string]
	$InterfaceName2 = $VMName + "_nic2",
	[string]$Location = $Location,
	[string]$rg = $rg,
	[string]$VMName = $VMName
	)
	$extvm = Get-AzureRmVm -Name $VMName -ResourceGroupName $rg -ErrorAction SilentlyContinue

if(!$extvm)
{
	Write-Host "Host VM  Not Found, please use a different VMName for Provisioning Extensions" -ForegroundColor Cyan
	Start-sleep 10
	Exit
}
} #
#endregion

#region Create Log Directory
Function Create-Dir {
$logdirexists = Test-Path -Path $logdir
	$direxists = Test-Path -Path $customscriptsdir
		$dscdirexists = Test-Path -Path $dscdir
if(!$logdirexists)
	{
	New-Item -Path $logdir -ItemType Directory -Force | Out-Null
		Write-Host "Created directory" $logdir
	}
	elseif(!$direxists)
	{
	New-Item -Path $customscriptsdir -ItemType Directory -Force | Out-Null
	Write-Host "Created directory" $logdir
}
		elseif(!$dscdirexists)
{
		New-Item -Path $dscdir -ItemType Directory -Force | Out-Null
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
$customscriptsdir = $workfolder+'\'+'customscripts'+'\'
$dscdir = $workfolder+'\'+'dsc'+'\'
$LogOutFile = $logdir+$vmname+'-'+$date+'.log'
$ProfileFile = $workfolder+'\'+$profile+'.json'

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

if($csvimport) {
	try {
	csv-run
	}
	catch {
	Write-Host -foregroundcolor Yellow `
	"$($_.Exception.Message)"; `
	$LogOut = "$($_.Exception.Message)"
	Log-Command -Description $LogOut -LogFile $LogOutFile
	break
	}
}



		try {
			Write-Config
			Check-NullValues
				Check-VM
				Verify-StorageExists
					Install-Ext
		}
					catch {
				Write-Host -foregroundcolor Yellow `
				"$($_.Exception.Message)"; `
				$LogOut = "$($_.Exception.Message)"
				Log-Command -Description $LogOut -LogFile $LogOutFile
				break
					}