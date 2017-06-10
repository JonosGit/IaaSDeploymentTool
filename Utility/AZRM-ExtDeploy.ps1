<#
.SYNOPSIS
Written By John Lewis
email: jonos@live.com
Ver 1.7
Extensions deployment

v 1.7 added -subscriptionid context option for context file creation
v 1.6 consolidated pushdsc params, added preview switch
v 1.5 update OMS and linux security patch management, added linux DSC
v 1.4 updated chef agent deployment
v 1.3 updated linux access scripts, added function to determine OS before ext deployment
v 1.2 updated linux OS patching and linux Custom Scripts
v 1.1 updates - added storage sharing function
v 1.0 updates - Moved -add parameters to [switch]

Deploys Azure Extensions to Existing VMs

.PARAMETER ExtName

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

.PARAMETER BatchAddExtension

.PARAMETER CustomScriptUpload

.PARAMETER LinDSCConfig

.PARAMETER scriptname

.PARAMETER containername

.PARAMETER customextname

.PARAMETER scriptfolder

.PARAMETER localfolder

.PARAMETER csvimport

.PARAMETER csvfile

.PARAMETER WinDSCConfig

.EXAMPLE
\.AZRM-ExtDeploy.ps1 -csvimport -csvfile C:\temp\iaasdeployment.csv
.EXAMPLE
\.AZRM-ExtDeploy.ps1 -extname linaccess -VMName myvm -rg myres
.EXAMPLE
\.AZRM-ExtDeploy.ps1 -extname linuxospatch -VMName myvm -rg myres
.EXAMPLE
\.AZRM-ExtDeploy.ps1 -extname linuxcustscript -scriptname update.sh -VMName myvm -rg myres

-extname <Extension Type>
			winaccess – Adds Azure Access Extension – Added by default during VM creation
			msav – Adds Azure Antivirus Extension
			customscript – Adds Custom Script for Execution (Requires Table Storage Configuration first)
			linuxcustscript – Adds Custom Script for Execution (Requires Table Storage Configuration first)
			linpushdsc - Deploys DSC Configuration to Linux Azure VM
			winpushdsc - Deploys DSC Configuration to Windows Azure VM
			diag – Adds Azure Diagnostics Extension
			linuxospatch - Deploy Latest updates for Linux platforms
			linaccess - Adds Azure Access Extension to Linux VM
			linuxbackup - Deploys Azure Linux backup Extension
			domjoin – Adds Azure Domain Join Extension
			linchefagent – Adds Azure Chef Extension (Requires Chef Certificate and knife.rb info first)
			winchefagent – Adds Azure Chef Extension (Requires Chef Certificate and knife.rb info first)
			opsinsightLinux - OMS Agent
			opsinsightWin - OMS Agent
			eset - File Security Ext
			WinPuppet - Puppet Agent Install for Windows
			Azure Storage Share -azshare
.LINK

#>

[CmdletBinding(DefaultParameterSetName = 'default')]
Param(

[Parameter(Mandatory=$False,ValueFromPipelinebyPropertyName=$true,Position=2)]
[ValidateSet("azshare","diag","msav","linaccess","winaccess","linuxbackup","linuxospatch","linchefagent","winchefagent","eset","customscript","linuxcustomscript","opsinsightLinux","opsinsightWin","WinPuppet","domjoin","RegisterAzDSC","linuxpushdsc","winpushdsc","bginfo","RegisterLinuxDSC")]
[Alias("ext")]
[string]
$extname = 'diag',
[Parameter(Mandatory=$False,ValueFromPipelinebyPropertyName=$true,Position=0)]
[ValidateNotNullorEmpty()]
[Alias("vm")]
[string]
$VMName = '',
[ValidateNotNullorEmpty()]
[Parameter(Mandatory=$False,ValueFromPipelinebyPropertyName=$true,Position=1)]
[string]
$rg = 'dcs',
[Parameter(Mandatory=$False,ValueFromPipelinebyPropertyName=$true)]
[string]
$storerg = $rg,
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
$Location = 'westus',
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
[ValidateNotNullorEmpty()]
[Alias("int1")]
[string]
$InterfaceName1 = $VMName + '_nic1',
[Parameter(Mandatory=$False,ValueFromPipelinebyPropertyName=$true)]
[Alias("int2")]
[string]
$InterfaceName2 = $VMName + "_nic2",
[string]
$Azautoacct = "automationacct",
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
[Alias("dscfilename")]
[string]
$WinDSCConfig = 'WindowsUpdate',
[Parameter(Mandatory=$False,ValueFromPipelinebyPropertyName=$true,Position=3)]
[Alias("customscriptname")]
[string]
$scriptname = 'installbase.sh',
[Parameter(Mandatory=$False,ValueFromPipelinebyPropertyName=$true)]
[string]
$containername = 'scripts',
[Parameter(Mandatory=$False,ValueFromPipelinebyPropertyName=$true)]
[string]
$dsccontainername = 'dscforlinux',
[Parameter(Mandatory=$False,ValueFromPipelinebyPropertyName=$true)]
[string]
$LinDSCConfig= 'localhost.mof',
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
[string]
$localdscfolder = "$scriptfolder\dsc",
[Parameter(Mandatory=$False,ValueFromPipelinebyPropertyName=$true)]
[string]
$sharename = 'software',
[Parameter(Mandatory=$False,ValueFromPipelinebyPropertyName=$true)]
[string]
$sharedirectory = 'apps',
[Parameter(Mandatory=$False,ValueFromPipelinebyPropertyName=$true)]
[string]
$localsoftwarefolder = "$scriptfolder\software",
[Parameter(Mandatory=$False,ValueFromPipelinebyPropertyName=$true)]
[switch]
$csvimport,
[Parameter(Mandatory=$False,ValueFromPipelinebyPropertyName=$true)]
[string]
$csvfile = -join $workfolder + "\azrm-vmextdeploy.csv",
[Parameter(Mandatory=$False,ValueFromPipelinebyPropertyName=$true)]
[string]
$BatchAddSSH = 'False',
[Parameter(Mandatory=$False,ValueFromPipelinebyPropertyName=$true)]
[string]
$DiskOSType = '',
[Parameter(Mandatory=$False,ValueFromPipelinebyPropertyName=$true)]
[string]
$useexiststorage = 'True',
[Parameter(Mandatory=$False,ValueFromPipelinebyPropertyName=$true)]
[string]
$chefvalidationpem = "\.chef\admin.pem",
[Parameter(Mandatory=$False,ValueFromPipelinebyPropertyName=$true)]
[string]
$chefclientrb =  "\.chef\knife.rb",
[Parameter(Mandatory=$False,ValueFromPipelinebyPropertyName=$true)]
[ValidateSet("oneoff","scheduled","disabled")]
[string]
$linuxpatchtype = '',
[Parameter(Mandatory=$False,ValueFromPipelinebyPropertyName=$true)]
[string]
$omswrkspaceid = '',
[Parameter(Mandatory=$False,ValueFromPipelinebyPropertyName=$true)]
[string]
$omswrkspacekey = '',
[Parameter(Mandatory=$False,ValueFromPipelinebyPropertyName=$true)]
[string]
$omsurl = "",
[Parameter(Mandatory=$False,ValueFromPipelinebyPropertyName=$true)]
[string]
$primary = "",
[Parameter(Mandatory=$False,ValueFromPipelinebyPropertyName=$true)]
[switch]
$preview
)

$sshPublicKey = Get-Content '.\Pspub.txt'
$SecureLocPassword=Convertto-SecureString $locpassword –asplaintext -Force
$Credential1 = New-Object System.Management.Automation.PSCredential ($locadmin,$SecureLocPassword)
$Error.Clear()
Set-StrictMode -Version Latest
Trap [System.SystemException] {("Exception" + $_ ) ; break}

#region Validate Profile
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
import-csv -Path $csvin -Delimiter ',' -ErrorAction SilentlyContinue -InformationAction SilentlyContinue | ForEach-Object{.\AZRM-ExtDeploy.ps1 -VMName $_.VMName -rg $_.rg -ExtName $_.ExtName -BatchAddExtension $_.BatchAddExtension -CustomScriptUpload $_.CustomScriptUpload -scriptname $_.scriptname -containername $_.containername -scriptfolder $_.scriptfolder -customextname $_.customextname -BatchAddSSH $_.BatchAddSsh -linuxpatchtype $_.linuxpatchtype }
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

function Check-linuxos-NullValues {
if($extname -eq 'linuxospatch' -and !$linuxpatchtype) {
Write-Host "Please select -linuxpatchtype before running this command" -ForegroundColor Red
exit
}
	elseif($extname -eq 'linuxospatch' -and $linuxpatchtype -eq 'oneoff') {
	Write-Host "Deploying Linux OS Patch - OneOff"
	}
				elseif($extname -eq 'linuxospatch' -and $linuxpatchtype -eq 'scheduled')  {
	Write-Host "Deploying Linux OS Patch - Scheduled"
				}
					elseif($extname -eq 'linuxospatch' -and $linuxpatchtype -eq 'disabled') {
	Write-Host "Deploying Linux OS Patch - Disable"
					}
}

function Check-ExtensionUnInstall {
if($RemoveExtension -and !$rg) {
	Write-Host "Please Enter RG Name"  -ForegroundColor Red
	exit
	}
	elseif($RemoveExtension -and !$VMName) {
	Write-Host "Please Enter VM Name"  -ForegroundColor Red
	exit
	}
}

function Check-Extension {
if($AddExtension -and !$extname) {
Write-Host "Please Enter Extension Name" -ForegroundColor Red
 }
}

function Validate-WinDscName {
	param(
		[string]$instring = $WinDSCConfig
	)

if($instring -like "*.*") {
Write-Host "Please remove file extension from configuration name, example WindowsUpdate" -ForegroundColor Yellow
	break
 }
}

function Validate-LinDscName {
	param(
		[string]$instring = $LinDSCConfig
	)

if($instring -notlike "*.*") {
Write-Host "Please add file extension to Linux DSC Config name, example localhost.mof" -ForegroundColor Yellow
	break
 }
}



#endregion

#region Check Storage
Function Check-StorageName
{
	param(
		[Parameter(Mandatory=$False,ValueFromPipelinebyPropertyName=$true)]
		[string]$StorageName  = $StorageName
	)
$extvm = Get-AzureRmVm -Name $VMName -ResourceGroupName $storerg -ErrorAction SilentlyContinue -WarningAction SilentlyContinue
	if(!$extvm) {exit}
	if($useexiststorage -eq 'True')
	{		$script:StorageNameVerified = $StorageName.ToLower()
		Write-Host "Storage Name:" $StorageNameVerified}
	else
	{
	$checkname =  Get-AzureRmStorageAccountNameAvailability -Name $StorageName | Select-Object -ExpandProperty NameAvailable
if($checkname -ne 'True') {
	Write-Host "Storage Account Name in use, generating random name for storage..."
	Start-Sleep 5
	$script:StorageNameVerified = $GenerateName.ToLower()
	Write-Host "Storage Name Check Completed for:" $StorageNameVerified }
	else
		{
		$script:StorageNameVerified = $StorageName.ToLower()
		Write-Host "Storage Name Check Completed for:" $StorageNameVerified
		}
		}
}
#endregion

#endregion

#region Get Resource Providers
Function Register-RP {
	Param(
		[string]$ResourceProviderNamespace
	)

	# Write-Host "Registering resource provider '$ResourceProviderNamespace'";
	Register-AzureRmResourceProvider -ProviderNamespace $ResourceProviderNamespace –Confirm:$false -WarningAction SilentlyContinue | Out-Null;
}

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

Function Configure-DSC {
param(

 [Parameter(Mandatory=$False,ValueFromPipelinebyPropertyName=$true)]
 [string]
 $DSCConfig = $WinDSCConfig,

[Parameter(Mandatory=$False,ValueFromPipelinebyPropertyName=$true)]
 [string]
 $ConfigurationName = $WinDSCConfig,
 [Parameter(Mandatory=$False,ValueFromPipelinebyPropertyName=$true)]
 [string]
 $ArchiveBlobName = "$DSCConfig.ps1.zip",

 [Parameter(Mandatory=$False,ValueFromPipelinebyPropertyName=$true)]
 [string]
 $ConfigurationPath = $dscdir + '\' + $DSCConfig + '.ps1',

 [Parameter(Mandatory=$False,ValueFromPipelinebyPropertyName=$true)]
 [string]
 $storageAccountName = $script:StorageNameVerified,

 [Parameter(Mandatory=$False,ValueFromPipelinebyPropertyName=$true)]
 [string]
 $StorageType = "Standard_GRS"

)
	Publish-AzureRmVMDscConfiguration -ResourceGroupName $rg -ConfigurationPath $ConfigurationPath -StorageAccountName $storageAccountName -Force
	Set-AzureRmVMDscExtension -ResourceGroupName $rg -VMName $VMName -ArchiveBlobName $ArchiveBlobName -ArchiveStorageAccountName $storageAccountName -ConfigurationName $ConfigurationName -Version 2.19
	$LogOut = "Added VM DSC to Storage Account $storageAccountName from file $ConfigurationPath"
	Log-Command -Description $LogOut -LogFile $LogOutFile
}

Function Configure-DSCPreview {
param(

 [Parameter(Mandatory=$False,ValueFromPipelinebyPropertyName=$true)]
 [string]
 $DSCConfig = $WinDSCConfig,

[Parameter(Mandatory=$False,ValueFromPipelinebyPropertyName=$true)]
 [string]
 $ConfigurationName = $DSCConfig,
 [Parameter(Mandatory=$False,ValueFromPipelinebyPropertyName=$true)]
 [string]
 $ArchiveBlobName = "$DSCConfig.ps1.zip",

 [Parameter(Mandatory=$False,ValueFromPipelinebyPropertyName=$true)]
 [string]
 $ConfigurationPath = $dscdir + '\' + $DSCConfig+ '.ps1',

 [Parameter(Mandatory=$False,ValueFromPipelinebyPropertyName=$true)]
 [string]
 $storageAccountName = $script:StorageNameVerified,

 [Parameter(Mandatory=$False,ValueFromPipelinebyPropertyName=$true)]
 [string]
 $StorageType = "Standard_GRS"

)
	Publish-AzureRmVMDscConfiguration -ResourceGroupName $rg -ConfigurationPath $ConfigurationPath -StorageAccountName $storageAccountName -Force
	Set-AzureRmVMDscExtension -ResourceGroupName $rg -VMName $VMName -ArchiveBlobName $ArchiveBlobName -ArchiveStorageAccountName $storageAccountName -ConfigurationName $ConfigurationName -Version 2.19 -WhatIf
	$LogOut = "Added VM DSC to Storage Account $storageAccountName from file $ConfigurationPath"
	Log-Command -Description $LogOut -LogFile $LogOutFile
}



function Check-OS {
	param(
	$DiskOSType = ''

	)

$vm =  Get-AzureRmVM -ResourceGroupName $rg -Name $VMName -InformationAction SilentlyContinue -WarningAction SilentlyContinue -ErrorAction Stop
$ostype = $vm.StorageProfile.OsDisk.OsType
if($ostype -eq 'Windows')
	{
	$Script:DiskOSType = 'Windows'
	}
	elseif($ostype -eq 'Linux')
		{
		$Script:DiskOSType = 'Linux'
		}
		}

function Check-OSImage {
$vm =  Get-AzureRmVM -ResourceGroupName $rg -Name $VMName -InformationAction SilentlyContinue -WarningAction SilentlyContinue -ErrorAction SilentlyContinue

if(!$vm)
	{
	Write-Host "VM does not exist!"
		break
	}
	else
	{
		$Script:strpublisher = $vm.StorageProfile.ImageReference.Publisher
		$Script:stroffer = $vm.StorageProfile.ImageReference.Offer
		$Script:strsku = $vm.StorageProfile.ImageReference.Sku
	}
		}

function linuxos-Patching{
	param(
		$patchtype = $linuxpatchtype
	)

if($patchtype -eq 'oneoff')
	{
$PublicSetting = ConvertTo-Json -InputObject @{
	"disabled" = $false;
	"stop" = $false;
	"rebootAfterPatch" = "Required";
	"category" = "ImportantAndRecommended";
	"installDuration" = "00:30";
	"oneoff" = $true;
	"distUpgradeAll" = $false;
}
Write-Host "Adding Azure OS Patching Linux - One Off"
Set-AzureRmVMExtension -VMName $VMName -ResourceGroupName $rg -Location $Location -Name "OSPatch" -ExtensionType "OSPatchingForLinux" -Publisher "Microsoft.OSTCExtensions" -typeHandlerVersion "2.0" -InformationAction SilentlyContinue -ErrorAction Stop -SettingString $PublicSetting -WarningAction SilentlyContinue | Out-Null
	}
	elseif($patchtype -eq 'scheduled')
	{
$PublicSetting = ConvertTo-Json -InputObject @{
	"disabled" = $false;
	"stop" = $false;
	"rebootAfterPatch" = "Required";
	"category" = "ImportantAndRecommended";
	"installDuration" = "00:90";
	"distUpgradeAll" = $true;
	"oneoff" = $false;
	"intervalOfWeeks" = "1";
	"dayOfWeek" = "Sunday|Saturday";
	"startTime" = "03:00";
}
Write-Host "Adding Azure OS Patching Linux - scheduled"
Set-AzureRmVMExtension -VMName $VMName -ResourceGroupName $rg -Location $Location -Name "OSPatch" -ExtensionType "OSPatchingForLinux" -Publisher "Microsoft.OSTCExtensions" -typeHandlerVersion "2.0" -InformationAction SilentlyContinue -ErrorAction Stop -SettingString $PublicSetting -WarningAction SilentlyContinue | Out-Null
	}
	elseif($patchtype -eq 'disabled')
	{
$PublicSetting = ConvertTo-Json -InputObject @{
	"disabled" = $false;
	"stop" = $true;
}
	Write-Host "Disabling Azure OS Patching Linux"
Set-AzureRmVMExtension -VMName $VMName -ResourceGroupName $rg -Location $Location -Name "OSPatch" -ExtensionType "OSPatchingForLinux" -Publisher "Microsoft.OSTCExtensions" -typeHandlerVersion "2.0" -InformationAction SilentlyContinue -ErrorAction Stop -SettingString $PublicSetting -WarningAction SilentlyContinue | Out-Null
	}

$LogOut = "Added VM OS Patching Extension"
Log-Command -Description $LogOut -LogFile $LogOutFile
}

function linuxos-PatchingPreview {
	param(
		$patchtype = $linuxpatchtype
	)

if($patchtype -eq 'oneoff')
	{
$PublicSetting = ConvertTo-Json -InputObject @{
	"disabled" = $false;
	"stop" = $false;
	"rebootAfterPatch" = "Required";
	"category" = "ImportantAndRecommended";
	"installDuration" = "00:30";
	"oneoff" = $true;
	"distUpgradeAll" = $false;
}
Write-Host "Adding Azure OS Patching Linux - One Off"
Set-AzureRmVMExtension -VMName $VMName -ResourceGroupName $rg -Location $Location -Name "OSPatch" -ExtensionType "OSPatchingForLinux" -Publisher "Microsoft.OSTCExtensions" -typeHandlerVersion "2.0" -InformationAction SilentlyContinue -ErrorAction Stop -SettingString $PublicSetting -WarningAction SilentlyContinue -WhatIf
	}
	elseif($patchtype -eq 'scheduled')
	{
$PublicSetting = ConvertTo-Json -InputObject @{
	"disabled" = $false;
	"stop" = $false;
	"rebootAfterPatch" = "Required";
	"category" = "ImportantAndRecommended";
	"installDuration" = "00:90";
	"distUpgradeAll" = $true;
	"oneoff" = $false;
	"intervalOfWeeks" = "1";
	"dayOfWeek" = "Sunday|Saturday";
	"startTime" = "03:00";
}
Write-Host "Adding Azure OS Patching Linux - scheduled"
Set-AzureRmVMExtension -VMName $VMName -ResourceGroupName $rg -Location $Location -Name "OSPatch" -ExtensionType "OSPatchingForLinux" -Publisher "Microsoft.OSTCExtensions" -typeHandlerVersion "2.0" -InformationAction SilentlyContinue -ErrorAction Stop -SettingString $PublicSetting -WarningAction SilentlyContinue -WhatIf
	}
	elseif($patchtype -eq 'disabled')
	{
$PublicSetting = ConvertTo-Json -InputObject @{
	"disabled" = $false;
	"stop" = $true;
}
	Write-Host "Disabling Azure OS Patching Linux"
Set-AzureRmVMExtension -VMName $VMName -ResourceGroupName $rg -Location $Location -Name "OSPatch" -ExtensionType "OSPatchingForLinux" -Publisher "Microsoft.OSTCExtensions" -typeHandlerVersion "2.0" -InformationAction SilentlyContinue -ErrorAction Stop -SettingString $PublicSetting -WarningAction SilentlyContinue -WhatIf
	}

Write-Host "Added VM OS Patching Extension - Preview"
}

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

Function Deploy-CustomScript {
	param(
	$StorageName = $script:StorageNameVerified,
	$containerName = $containerName,
	$rg = $rg,
	$localFolder = $localFolder,
	$localfile = -join $localFolder + "\" + $scriptname
	)

		$Keys = Get-AzureRmStorageAccountKey -ResourceGroupName $rg -Name $StorageName;
		$StorageContext = New-AzureStorageContext -StorageAccountName $StorageName -StorageAccountKey $Keys[0].Value;
		New-AzureStorageContainer -Context $StorageContext -Name $containerName -WarningAction SilentlyContinue -ErrorAction SilentlyContinue;
		$storageAccountKey = Get-AzureRmStorageAccountKey -ResourceGroupName $rg -Name $StorageName;
		$blobContext = New-AzureStorageContext -StorageAccountName $StorageName -StorageAccountKey $Keys[0].Value;
		$files = Get-Item -Path $localfile
		foreach($file in $files)
		{
		  $fileName = "$localFolder\$file"
		  $blobName = "$file"

			Set-AzureStorageBlobContent -File $filename -Container $containerName -Blob $blobName -Context $blobContext -Force -BlobType Append -WarningAction SilentlyContinue -ErrorAction SilentlyContinue -Confirm:$false | Out-Null
		  Get-AzureStorageBlob -Container $containerName -Context $blobContext -Blob $blobName -WarningAction SilentlyContinue | Out-Null
}
		  $scripturl = "https://$StorageName.blob.core.windows.net/$containerNameScripts/$scriptname"
		  $LogOut = "Custom Script deployed $scripturl"
				Log-Command -Description $LogOut -LogFile $LogOutFile
}

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
		  $scripturl = "https://$StorageName.blob.core.windows.net/$containerNameScripts/$scriptname"
		  $LogOut = "Custom Script uploaded $scripturl"
				Log-Command -Description $LogOut -LogFile $LogOutFile
}
#endregion

Function Upload-CustomScriptPreview {
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

			Set-AzureStorageBlobContent -File $filename -Container $containerName -Blob $blobName -Context $blobContext -Force -BlobType Append -WarningAction SilentlyContinue -ErrorAction SilentlyContinue -Confirm:$false -WhatIf | Out-Null
		  Get-AzureStorageBlob -Container $containerName -Context $blobContext -Blob $blobName -WarningAction SilentlyContinue | Out-Null
}
		  $scripturl = "https://$StorageName.blob.core.windows.net/$containerNameScripts/$scriptname"
		  Write-Host "Custom Script uploaded $scripturl -preview"
				Log-Command -Description $LogOut -LogFile $LogOutFile
}


Function Configure-DSCMof {
	param(
	$StorageName = $script:StorageNameVerified,
	$containername = $dsccontainername,
	$rg = $rg,
	$localFolder = $dscdir,
	$filename = $LinDSCConfig
	)
		$Keys = Get-AzureRmStorageAccountKey -ResourceGroupName $rg -Name $StorageName;
		$StorageContext = New-AzureStorageContext -StorageAccountName $StorageName -StorageAccountKey $Keys[0].Value;
		New-AzureStorageContainer -Context $StorageContext -Name $containername -WarningAction SilentlyContinue -ErrorAction SilentlyContinue -Permission Blob -ServerTimeoutPerRequest 60 -InformationAction SilentlyContinue | Out-Null;
		$storageAccountKey = Get-AzureRmStorageAccountKey -ResourceGroupName $rg -Name $StorageName;
		$blobContext = New-AzureStorageContext -StorageAccountName $StorageName -StorageAccountKey $Keys[0].Value;
		$files = Get-ChildItem $localFolder
		foreach($file in $files)
		{
		  $fileName = "$localfolder\$file"
		  $blobName = "$file"

			Set-AzureStorageBlobContent -File $fileName -Container $containername -Blob $blobName -Context $blobContext -Force -BlobType Append -WarningAction SilentlyContinue -ErrorAction SilentlyContinue -Confirm:$false | Out-Null
}

				$mofurl = -join "https://" + $StorageName + ".blob.core.windows.net/" + $dsccontainername + "/" + $DSCConfig
				$Keys = Get-AzureRmStorageAccountKey -ResourceGroupName $rg -Name $StorageName
				$Key1 = $Keys[0].Value
				$PublicSetting = "{`"FileUri`":`"$mofurl`" ,`"Mode`": `"Push`"}"
				$PrivateSetting = "{`"storageAccountName`":`"$StorageName`",`"storageAccountKey`":`"$Key1`"}"

				Write-Host "$mofurl"

				Set-AzureRmVMExtension -VMName $VMName -ResourceGroupName $rg -Location $Location -Name "DSCForLinux" -ExtensionType "DSCForLinux" -Publisher "Microsoft.OSTCExtensions" -typeHandlerVersion "2.3" -InformationAction SilentlyContinue -SettingString $PublicSetting -ProtectedSettingString $PrivateSetting | Out-Null
}

Function Configure-DSCMofPreview {
	param(
	$StorageName = $script:StorageNameVerified,
	$containername = $dsccontainername,
	$rg = $rg,
	$localFolder = $dscdir,
	$filename = $LinDSCConfig
	)
		$Keys = Get-AzureRmStorageAccountKey -ResourceGroupName $rg -Name $StorageName;
		$StorageContext = New-AzureStorageContext -StorageAccountName $StorageName -StorageAccountKey $Keys[0].Value;
		New-AzureStorageContainer -Context $StorageContext -Name $containername -WarningAction SilentlyContinue -ErrorAction SilentlyContinue -Permission Blob -ServerTimeoutPerRequest 60 -InformationAction SilentlyContinue;
		$storageAccountKey = Get-AzureRmStorageAccountKey -ResourceGroupName $rg -Name $StorageName;
		$blobContext = New-AzureStorageContext -StorageAccountName $StorageName -StorageAccountKey $Keys[0].Value;
		$files = Get-ChildItem $localFolder
		foreach($file in $files)
		{
		  $fileName = "$localfolder\$file"
		  $blobName = "$file"

			Set-AzureStorageBlobContent -File $fileName -Container $containername -Blob $blobName -Context $blobContext -Force -BlobType Append -WarningAction SilentlyContinue -ErrorAction SilentlyContinue -Confirm:$false | Out-Null
}

				$mofurl = -join "https://" + $StorageName + ".blob.core.windows.net/" + $dsccontainername + "/" + $DSCConfig
				$Keys = Get-AzureRmStorageAccountKey -ResourceGroupName $rg -Name $StorageName
				$Key1 = $Keys[0].Value
				$PublicSetting = "{`"FileUri`":`"$mofurl`" ,`"Mode`": `"Push`"}"
				$PrivateSetting = "{`"storageAccountName`":`"$StorageName`",`"storageAccountKey`":`"$Key1`"}"

				Write-Host "$mofurl"

				Set-AzureRmVMExtension -VMName $VMName -ResourceGroupName $rg -Location $Location -Name "DSCForLinux" -ExtensionType "DSCForLinux" -Publisher "Microsoft.OSTCExtensions" -typeHandlerVersion "2.3" -InformationAction SilentlyContinue -SettingString $PublicSetting -ProtectedSettingString $PrivateSetting -WhatIf | Out-Null
}


Function Get-OMSInfo {
	param(
		$omsrg = 'automation-rmp',
		$omsname = 'rmpautoact'
	)

	$key = Get-AzureRmOperationalInsightsWorkspaceSharedKeys -Name $omsname -ResourceGroupName $omsrg
	$primary = $key.PrimarySharedKey
	$oms =  Get-AzureRmOperationalInsightsWorkspace -ResourceGroupName $omsrg -Name $omsname
	$omsurl = $oms.PortalUrl
	Write-Host $primary


}


Function Register-DSCLinux {
	param(
	$primary = $primary,
	$omsurl = $omsurl
	)

	$PrivateSetting = ConvertTo-Json -InputObject @{
	"RegistrationUrl" = $omsurl;
	"RegistrationKey" = $primary;
	}


	$publicConfig = '{
	  "ExtensionAction" : "Register",
	  "NodeConfigurationName": "$VMName",
	  "RefreshFrequencyMins": "30",
	  "ConfigurationMode": "ApplyAndMonitor",
	  "ConfigurationModeFrequencyMins": "30"
	}'
Set-AzureRmVMExtension -VMName $VMName -ResourceGroupName $rg -Location $Location -Name "DSCForLinux" -ExtensionType "DSCForLinux" -Publisher "Microsoft.OSTCExtensions" -typeHandlerVersion "2.3" -InformationAction SilentlyContinue -SettingString $publicConfig -ProtectedSettingString $PrivateSetting | Out-Null
}

Function Register-DSCLinuxPreview {
	param(
	$primary = $primary,
	$omsurl = $omsurl
	)

	$PrivateSetting = ConvertTo-Json -InputObject @{
	"RegistrationUrl" = $omsurl;
	"RegistrationKey" = $primary;
	}


	$publicConfig = '{
	  "ExtensionAction" : "Register",
	  "NodeConfigurationName": "$VMName",
	  "RefreshFrequencyMins": "30",
	  "ConfigurationMode": "ApplyAndMonitor",
	  "ConfigurationModeFrequencyMins": "30"
	}'
Set-AzureRmVMExtension -VMName $VMName -ResourceGroupName $rg -Location $Location -Name "DSCForLinux" -ExtensionType "DSCForLinux" -Publisher "Microsoft.OSTCExtensions" -typeHandlerVersion "2.3" -InformationAction SilentlyContinue -SettingString $publicConfig -ProtectedSettingString $PrivateSetting -WhatIf | Out-Null
}


#region Verify Linux OS
Function Verify-ExtLinux {
Check-OS
Check-OSImage
$stroffer = $Script:stroffer
$DiskOSType = $Script:DiskOSType
if($DiskOSType -eq 'Linux' -and $stroffer -ne 'FreeBSD') {Write-Host "Host OS: Linux"}
	else
	{ Write-Host "No Compatble OS Found, please verify the extension is compatible with $VMName"
		break
	}
}
#endregion

Function Verify-ExtWindows {
Check-OS
$DiskOSType = $Script:DiskOSType
if($DiskOSType -eq 'Windows') {Write-Host "Host OS: Windows"}
	else
	{ 	$LogOut = "No compatible extension found for $VMName"
				Log-Command -Description $LogOut -LogFile $LogOutFile

						break
	}
}




#endregion

Function Verify-ExtCompat {
if($DiskOSType -eq 'Windows') {Write-Host "Host OS: Windows"}
	else
	{ Write-Host "No Compatble OS Found, please verify the extension is compatible with $VMName"
		break
	}
}

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
		$customextname = $customextname,
		[Parameter(Mandatory=$False,ValueFromPipelinebyPropertyName=$true)]
		[string]
		$extname = $extname

	)
switch ($extname)
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
		"winpushdsc" {
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

Function Verify-StorageExists {
	param(
		[Parameter(Mandatory=$False,ValueFromPipelinebyPropertyName=$true)]
		[string]
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

function Verify-ScriptExists {
	param(
	$remscriptpath = -join $customscriptsdir + "\" + $scriptname

	)

	$remscript = Test-Path -Path $remscriptpath

if(!$remscript)
	{
		Write-Host "File does not Exist" $remscriptpath
		break
	}
	else
	{	 $script:remenable = 'True'}
}

Function Check-VMExtension {
	param(
	$rg = $rg,
	$VMName = $VMName
	)
$vm =  Get-AzureRmVM -ResourceGroupName $rg -Name $VMName -InformationAction SilentlyContinue -WarningAction SilentlyContinue -ErrorAction Stop
if(!$vm)
	{Write-Host "Host VM not found $VMName"
		break
	}
		$extcnt = $vm.Extensions.Count
		if($extcnt -ge 1)
		{
		$exttype = $vm.Extensions | Select-Object -ExpandProperty VirtualMachineExtensionType
		$extname = $vm.Extensions | Select-Object -ExpandProperty Name
		Write-Host "[$extcnt] extensions found on $VMName"
			Write-Output "Installed Extensions: $exttype"
			}
}

Function Test-ChefFiles {
param(
	$validationpem = $chefvalidationpem,
	$clientrb = $chefclientrb
	)

$pemfileexist = Test-Path -Path $validationpem
	$clientfileexists = Test-Path -Path $clientrb

if(!$pemfileexist)
{
Write-Host "$validationpem Doesn't Exist"
exit }
elseif(!$clientfileexists)
	{
	Write-Host "$validationpem Doesn't Exist"
	exit
	}
	else
	{}
{
}
}

Function Install-ExtPreview {
	param(
		[string]$extname = $extname,
		[string]$Location = $Location,
		[string]$rg = $rg,
		[string]$StorageName = $script:StorageNameVerified,
		[string]$VMName = $VMName,
		[string]$containerNameScripts = 'scripts',
		[string]$DomName =  'aip.local',
		[string]$customextname = $customextname,
		[string]$localfolderscripts = $customscriptsdir,
		[string]$scriptname = $scriptname,
		[string]$validationpem = $chefvalidationpem,
		[string]$clientrb = $chefclientrb
	)
switch ($extname)
	{
		"winaccess" {
				Verify-ExtWindows
				Write-Host "Windows VM Access Agent VM Image Preparation in Process"
				Set-AzureRmVMAccessExtension -ResourceGroupName $rg -VMName $VMName -Name "VMAccess" -typeHandlerVersion "2.0" -Location $Location -Verbose -username $locadmin -password $locpassword -ErrorAction Stop -WhatIf | Out-Null

						Write-Results

									break
}
		"linaccess" {
				Verify-ExtLinux
				Write-Host "Linux VM Access Agent VM Image Preparation in Process"
				$PublicSetting = "{}"

				$PrivateSetting = "{`"username`":`"$locadmin`",`"password`":`"$locpassword`",`"ssh_key`":`"$sshPublicKey`",`"reset_ssh`":`"True`"}"

				Set-AzureRmVMExtension -VMName $VMName -ResourceGroupName $rg -Location $Location -Name "VMAccessForLinux" -ExtensionType "VMAccessForLinux" -Publisher "Microsoft.OSTCExtensions" -typeHandlerVersion "1.4" -InformationAction SilentlyContinue -Verbose -ProtectedSettingString $PrivateSetting -WhatIf | Out-Null
						Write-Results

									break
}

		"msav" {
				Verify-ExtWindows
				Write-Host "MSAV Agent VM Image Preparation in Process"
				Set-AzureRmVMExtension  -ResourceGroupName $rg -VMName $VMName -Name "MSAVExtension" -ExtensionType "IaaSAntimalware" -Publisher "Microsoft.Azure.Security" -typeHandlerVersion 1.4 -Location $Location  -ErrorAction Stop -WhatIf | Out-Null
						Write-Results

									  break
}
		"customscript" {
				Verify-ExtWindows
				Verify-ScriptExists

				Write-Host "Updating: $VMName in the Resource Group: $rg with a custom script: $customextname in Storage Account: $StorageName"
				if($CustomScriptUpload -eq 'True')
				{
				Test-Upload -localFolder $localfolderscripts
				Upload-CustomScriptPreview -StorageName $StorageName -rg $rg -containerName $containerNameScripts -localFolder $localfolderscripts
				}
				$scriptend = "https://$StorageName.blob.core.windows.net/$containerNameScripts/$scriptname"
				if(!$scriptend)
					{
					Upload-CustomScript -StorageName $StorageName -containerName $containerNameScripts -rg $rg -localFolder $localfolderscripts
					}
				Set-AzureRmVMCustomScriptExtension -Name $customextname -ContainerName $containerName -ResourceGroupName $rg -VMName $VMName -StorageAccountName $StorageName -FileName $scriptname -Location $Location -TypeHandlerVersion "1.8" -WarningAction SilentlyContinue  -ErrorAction Stop -WhatIf | Out-Null
				Get-AzureRmVMCustomScriptExtension -ResourceGroupName $rg -VMName $VMName -Name $customextname -Status | Out-Null
						Write-Results

									  break
}
		"linuxcustomscript" {
				Verify-ExtLinux
				Verify-ScriptExists
				$Keys = Get-AzureRmStorageAccountKey -ResourceGroupName $rg -Name $StorageName
				$Key1 = $Keys[0].Value
				$fileuri = -join "[" + "https://" + $StorageName + ".blob.core.windows.net/" + $containerNameScripts + "/" + $scriptname + "]"

				$PrivateSetting = ConvertTo-Json -InputObject @{
				"storageAccountName" = $StorageName;
				"storageAccountKey" = $Key1;
}
				$PublicSetting = "{`"fileUris`":[`"https://$StorageName.blob.core.windows.net/$containerNameScripts/$scriptname`"] ,`"commandToExecute`": `"sh $scriptname`"}"

				Write-Host "Updating $VMName with $scriptname in Storage Account $StorageName" -ForegroundColor Blue
				if($CustomScriptUpload -eq 'True')
				{
				Test-Upload -localFolder $localfolderscripts
				Upload-CustomScript -StorageName $StorageName -rg $rg -containerName $containerNameScripts -localFolder $localfolderscripts -InformationAction SilentlyContinue -WarningAction SilentlyContinue -ErrorAction Stop | Out-Null
				}
				Set-AzureRmVMExtension -VMName $VMName -ResourceGroupName $rg -Location $Location -Name "CustomscriptLinux" -ExtensionType "CustomScript" -Publisher "Microsoft.Azure.Extensions" -typeHandlerVersion "2.0" -InformationAction SilentlyContinue -SettingString $PublicSetting -ProtectedSettingString $PrivateSetting -WhatIf | Out-Null
				 $LogOut = "Added VM Custom Script Extension for $scriptname"
				Log-Command -Description $LogOut -LogFile $LogOutFile
				Write-Results
			}
		"diag" {
				Write-Host "Adding Azure Enhanced Diagnostics to $VMName in $rg using the $StorageName Storage Account"
				Set-AzureRmVMAEMExtension -ResourceGroupName $rg -VMName $VMName -WADStorageAccountName $StorageName -InformationAction SilentlyContinue  -ErrorAction Stop -WarningAction SilentlyContinue | Out-Null
				Get-AzureRmVMAEMExtension -ResourceGroupName $rg -VMName $VMName | Out-Null
						Write-Results

									  break
}
		"domjoin" {
				Verify-ExtWindows
				Write-Host "Domain Join active"
				Set-AzureRmVMADDomainExtension -DomainName $DomName -ResourceGroupName $rg -VMName $VMName -Location $Location -Name 'DomJoin'  -ErrorAction Stop -WarningAction SilentlyContinue -Restart -WhatIf | Out-Null
				Get-AzureRmVMADDomainExtension -ResourceGroupName $rg  -VMName $VMName -Name 'DomJoin' | Out-Null
				$LogOut = "Domain join Deployed to $VMName"
				Log-Command -Description $LogOut -LogFile $LogOutFile
						Write-Results

									  break
}
		"linuxospatch" {
				Verify-ExtLinux
				Check-linuxos-NullValues
				linuxos-PatchingPreview
						Write-Results

										  break
		}
		"linuxbackup" {
				$PublicSetting = ConvertTo-Json -InputObject @{
				"commandStartTimeUTCTicks" = "635809046306353843";
				"commandToExecute" = "snapshot";
				}
				Write-Host "Adding Linux VMBackup to $VMName in the resource group $rg"
				Set-AzureRmVMExtension -VMName $VMName -ResourceGroupName $rg -Location $Location -Name "VMBackupForLinuxExtension" -ExtensionType "VMBackupForLinuxExtension" -Publisher "Microsoft.OSTCExtensions" -typeHandlerVersion "0.1" -InformationAction SilentlyContinue -SettingString $PublicSetting -WhatIf
				Write-Results

									  break
		}
		"linchefagent" {
				Verify-ExtLinux
				Test-ChefFiles
				Write-Host "Adding Linux Chef Agent"
				$validationpem = $validationpem
				$clientrb = $clientrb
				Set-AzureRmVMChefExtension -ResourceGroupName $rg -VMName $VMName -TypeHandlerVersion "1210.12" -ValidationPem $validationpem -ClientRb $clientrb -Linux -WhatIf

						Write-Results

													  break
}
		"winchefagent" {
				Verify-ExtWindows
				Test-ChefFiles
				Write-Host "Adding Windows Chef Agent"
				$validationpem = $validationpem
				$clientrb = $clientrb
				Set-AzureRmVMChefExtension -ResourceGroupName $rg -VMName $VMName -TypeHandlerVersion "1210.12" -ValidationPem $validationpem -ClientRb $clientrb -Windows -WhatIf
						Write-Results

													  break
}

		"opsinsightLinux" {
				Verify-ExtLinux
				Write-Host "Adding Linux Insight Agent"
				$PublicSetting = "{`"workspaceId`":`"$omswrkspaceid`",`"stopOnMultipleConnections`":`"$false`"}"
				$PrivateSetting = "{`"workspaceKey`":`"$omswrkspacekey`"}"

				Set-AzureRmVMExtension -VMName $VMName -ResourceGroupName $rg -Location $Location -Name "OperationalInsights" -ExtensionType "OmsAgentForLinux" -Publisher "Microsoft.EnterpriseCloud.Monitoring" -typeHandlerVersion "1.0" -InformationAction SilentlyContinue  -ErrorAction Stop -SettingString $PublicSetting -ProtectedSettingString $PrivateSetting -WhatIf | Out-Null
				Get-AzureRmVMExtension -ResourceGroupName $rg -VMName $VMName -Name "OperationalInsights" | Out-Null
						Write-Results
				Break
}
		"opsinsightWin" {
				Verify-ExtWindows

					$PublicSetting = ConvertTo-Json -InputObject @{
					"workspaceId" = $omswrkspaceid;
					"stopOnMultipleConnections" = $false;
				}
					$PrivateSetting = ConvertTo-Json -InputObject @{
					"workspaceKey" = $omswrkspacekey;
				}

				Write-Host "Adding Windows Insight Agent"
				Set-AzureRmVMExtension -VMName $VMName -ResourceGroupName $rg -Location $Location -Name "OperationalInsights" -ExtensionType "MicrosoftMonitoringAgent" -Publisher "Microsoft.EnterpriseCloud.Monitoring" -typeHandlerVersion "1.0" -InformationAction SilentlyContinue  -ErrorAction Stop  -Verbose  -SettingString $PublicSetting -ProtectedSettingString $PrivateSetting -WhatIf | Out-Null
						Write-Results

													  break
}
		"ESET" {
				Verify-ExtWindows
				Write-Host "Setting File Security"
				Set-AzureRmVMExtension -VMName $VMName -ResourceGroupName $rg -Location $Location -Name "ESET" -ExtensionType "FileSecurity" -Publisher "ESET" -typeHandlerVersion "6.0" -InformationAction SilentlyContinue -Verbose  -ErrorAction Stop -WhatIf | Out-Null
						Write-Results

										  break
}
		"winpushdsc" {
				Verify-ExtWindows
				Validate-WinDscName
				Configure-DSCPreview
				Write-Host "Pushing DSC to $VMName in the $rg Resource Group"
						Write-Results

										  break
}
		"linuxpushdsc" {
				Verify-ExtLinux
				Validate-LinDscName
				Configure-DSCMofPreview
				Write-Host "Pushing DSC to $VMName in the $rg Resource Group"
				Write-Results

										  break
}

		"azshare" {
				Upload-sharefiles
				Write-Host "Uploading Files to $StorageName"
						Write-Results

										  break
}
		"RegisterAzDSC" {
				Verify-ExtWindows
				Write-Host "Registering with Azure Automation DSC"
										  break
}
		"RegisterLinuxDSC" {
			Verify-ExtLinux
			Register-DSCLinuxPreview
						Write-Results

			break
}
		"WinPuppet" {
				Verify-ExtWindows
				Write-Host "Deploying Puppet Extension"
				Set-AzureRmVMExtension -VMName $VMName -ResourceGroupName $rg -Location $Location -Name "PuppetEnterpriseAgent" -ExtensionType "PuppetEnterpriseAgent" -Publisher "PuppetLabs" -typeHandlerVersion "3.2" -InformationAction SilentlyContinue -ErrorAction Stop -WhatIf
						Write-Results

			break
}
		default{"An unsupported Extension command was used"}
	}
	exit
} # Deploys Azure Extensions

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
		[string]$localfolderscripts = $customscriptsdir,
		[string]$scriptname = $scriptname,
		[string]$validationpem = $chefvalidationpem,
		[string]$clientrb = $chefclientrb
	)
switch ($extname)
	{
		"winaccess" {
				Verify-ExtWindows
				Write-Host "Windows VM Access Agent VM Image Preparation in Process"
				Set-AzureRmVMAccessExtension -ResourceGroupName $rg -VMName $VMName -Name "VMAccess" -typeHandlerVersion "2.0" -Location $Location -Verbose -username $locadmin -password $locpassword -ErrorAction Stop | Out-Null
				$LogOut = "VM Access Agent Deployed to $VMName"
				Log-Command -Description $LogOut -LogFile $LogOutFile
						Write-Results

									break
}
		"linaccess" {
				Verify-ExtLinux
				Write-Host "Linux VM Access Agent VM Image Preparation in Process"
				$PublicSetting = "{}"

				$PrivateSetting = "{`"username`":`"$locadmin`",`"password`":`"$locpassword`",`"ssh_key`":`"$sshPublicKey`",`"reset_ssh`":`"True`"}"

				Set-AzureRmVMExtension -VMName $VMName -ResourceGroupName $rg -Location $Location -Name "VMAccessForLinux" -ExtensionType "VMAccessForLinux" -Publisher "Microsoft.OSTCExtensions" -typeHandlerVersion "1.4" -InformationAction SilentlyContinue -Verbose -ProtectedSettingString $PrivateSetting | Out-Null
				$LogOut = "VM Access Agent Deployed to $VMName"
				Log-Command -Description $LogOut -LogFile $LogOutFile
						Write-Results

									break
}

		"msav" {
				Verify-ExtWindows
				Write-Host "MSAV Agent VM Image Preparation in Process"
				Set-AzureRmVMExtension  -ResourceGroupName $rg -VMName $VMName -Name "MSAVExtension" -ExtensionType "IaaSAntimalware" -Publisher "Microsoft.Azure.Security" -typeHandlerVersion 1.4 -Location $Location  -ErrorAction Stop | Out-Null
				$LogOut = "MSAV Agent Deployed to $VMName"
				Log-Command -Description $LogOut -LogFile $LogOutFile
						Write-Results

									  break
}
		"customscript" {
				Verify-ExtWindows
				Verify-ScriptExists

				Write-Host "Updating: $VMName in the Resource Group: $rg with a custom script: $customextname in Storage Account: $StorageName"
				if($CustomScriptUpload -eq 'True')
				{
				Test-Upload -localFolder $localfolderscripts
				Upload-CustomScript -StorageName $StorageName -rg $rg -containerName $containerNameScripts -localFolder $localfolderscripts
				}
				$scriptend = "https://$StorageName.blob.core.windows.net/$containerNameScripts/$scriptname"
				if(!$scriptend)
					{
					Upload-CustomScript -StorageName $StorageName -containerName $containerNameScripts -rg $rg -localFolder $localfolderscripts
					}
				Set-AzureRmVMCustomScriptExtension -Name $customextname -ContainerName $containerName -ResourceGroupName $rg -VMName $VMName -StorageAccountName $StorageName -FileName $scriptname -Location $Location -TypeHandlerVersion "1.8" -WarningAction SilentlyContinue  -ErrorAction Stop | Out-Null
				Get-AzureRmVMCustomScriptExtension -ResourceGroupName $rg -VMName $VMName -Name $customextname -Status | Out-Null
				$LogOut = "Custom $scriptname Deployed to $VMName"
				Log-Command -Description $LogOut -LogFile $LogOutFile
						Write-Results

									  break
}
		"linuxcustomscript" {
				Verify-ExtLinux
				Verify-ScriptExists
				$Keys = Get-AzureRmStorageAccountKey -ResourceGroupName $rg -Name $StorageName
				$Key1 = $Keys[0].Value
				$fileuri = -join "[" + "https://" + $StorageName + ".blob.core.windows.net/" + $containerNameScripts + "/" + $scriptname + "]"

				$PrivateSetting = ConvertTo-Json -InputObject @{
				"storageAccountName" = $StorageName;
				"storageAccountKey" = $Key1;
}
				$PublicSetting = "{`"fileUris`":[`"https://$StorageName.blob.core.windows.net/$containerNameScripts/$scriptname`"] ,`"commandToExecute`": `"sh $scriptname`"}"

				Write-Host "Updating $VMName with $scriptname in Storage Account $StorageName" -ForegroundColor Blue
				if($CustomScriptUpload -eq 'True')
				{
				Test-Upload -localFolder $localfolderscripts
				Upload-CustomScript -StorageName $StorageName -rg $rg -containerName $containerNameScripts -localFolder $localfolderscripts -InformationAction SilentlyContinue -WarningAction SilentlyContinue -ErrorAction Stop | Out-Null
				}
				Set-AzureRmVMExtension -VMName $VMName -ResourceGroupName $rg -Location $Location -Name "CustomscriptLinux" -ExtensionType "CustomScript" -Publisher "Microsoft.Azure.Extensions" -typeHandlerVersion "2.0" -InformationAction SilentlyContinue -SettingString $PublicSetting -ProtectedSettingString $PrivateSetting | Out-Null
				 $LogOut = "Added VM Custom Script Extension for $scriptname"
				Log-Command -Description $LogOut -LogFile $LogOutFile
				Write-Results
			}
		"diag" {
				Write-Host "Adding Azure Enhanced Diagnostics to $VMName in $rg using the $StorageName Storage Account"
				Set-AzureRmVMAEMExtension -ResourceGroupName $rg -VMName $VMName -WADStorageAccountName $StorageName -InformationAction SilentlyContinue  -ErrorAction Stop -WarningAction SilentlyContinue | Out-Null
				Get-AzureRmVMAEMExtension -ResourceGroupName $rg -VMName $VMName | Out-Null
				$LogOut = "Azure Enhanced Diagnostics Deployed to $VMName"
				Log-Command -Description $LogOut -LogFile $LogOutFile
						Write-Results

									  break
}
		"domjoin" {
				Verify-ExtWindows
				Write-Host "Domain Join active"
				Set-AzureRmVMADDomainExtension -DomainName $DomName -ResourceGroupName $rg -VMName $VMName -Location $Location -Name 'DomJoin'  -ErrorAction Stop -WarningAction SilentlyContinue -Restart | Out-Null
				Get-AzureRmVMADDomainExtension -ResourceGroupName $rg  -VMName $VMName -Name 'DomJoin' | Out-Null
				$LogOut = "Domain join Deployed to $VMName"
				Log-Command -Description $LogOut -LogFile $LogOutFile
						Write-Results

									  break
}
		"linuxospatch" {
				Verify-ExtLinux
				Check-linuxos-NullValues
				linuxos-Patching
						Write-Results

										  break
		}
		"linuxbackup" {
				Verify-ExtLinux
				$PublicSetting = ConvertTo-Json -InputObject @{
				"commandStartTimeUTCTicks" = "635809046306353843";
				"commandToExecute" = "snapshot";
				}
				Write-Host "Adding Linux VMBackup to $VMName in the resource group $rg"
				Set-AzureRmVMExtension -VMName $VMName -ResourceGroupName $rg -Location $Location -Name "VMBackupForLinuxExtension" -ExtensionType "VMBackupForLinuxExtension" -Publisher "Microsoft.OSTCExtensions" -typeHandlerVersion "0.1" -InformationAction SilentlyContinue -SettingString $PublicSetting
				 $LogOut = "Added VM Backup Extension"
				Log-Command -Description $LogOut -LogFile $LogOutFile
				Write-Results

									  break
		}
		"linchefagent" {
				Verify-ExtLinux
				Test-ChefFiles
				Write-Host "Adding Linux Chef Agent"
				$validationpem = $validationpem
				$clientrb = $clientrb
				Set-AzureRmVMChefExtension -ResourceGroupName $rg -VMName $VMName -TypeHandlerVersion "1210.12" -ValidationPem $validationpem -ClientRb $clientrb -Linux
				$LogOut = "Chef Agent Deployed to $VMName"
				Log-Command -Description $LogOut -LogFile $LogOutFile
						Write-Results

													  break
}
		"winchefagent" {
				Verify-ExtWindows
				Test-ChefFiles
				Write-Host "Adding Windows Chef Agent"
				$validationpem = $validationpem
				$clientrb = $clientrb
				Set-AzureRmVMChefExtension -ResourceGroupName $rg -VMName $VMName -TypeHandlerVersion "1210.12" -ValidationPem $validationpem -ClientRb $clientrb -Windows -WhatIf
				$LogOut = "Chef Agent Deployed to $VMName"
				Log-Command -Description $LogOut -LogFile $LogOutFile
						Write-Results

													  break
}

		"opsinsightLinux" {
				Get-OMSInfo
				Verify-ExtLinux
				Write-Host "Adding Linux Insight Agent"
				$PublicSetting = "{`"workspaceId`":`"$omswrkspaceid`",`"stopOnMultipleConnections`":`"$false`"}"
				$PrivateSetting = "{`"workspaceKey`":`"$omswrkspacekey`"}"

				Set-AzureRmVMExtension -VMName $VMName -ResourceGroupName $rg -Location $Location -Name "OperationalInsights" -ExtensionType "OmsAgentForLinux" -Publisher "Microsoft.EnterpriseCloud.Monitoring" -typeHandlerVersion "1.0" -InformationAction SilentlyContinue  -ErrorAction Stop -SettingString $PublicSetting -ProtectedSettingString $PrivateSetting | Out-Null
				Get-AzureRmVMExtension -ResourceGroupName $rg -VMName $VMName -Name "OperationalInsights" | Out-Null
				$LogOut = "Ops Insight Deployed to $VMName"
				Log-Command -Description $LogOut -LogFile $LogOutFile
						Write-Results
				Break
}
		"opsinsightWin" {
				Verify-ExtWindows
				Get-OMSInfo
					$PublicSetting = ConvertTo-Json -InputObject @{
					"workspaceId" = $omswrkspaceid;
					"stopOnMultipleConnections" = $false;
				}
					$PrivateSetting = ConvertTo-Json -InputObject @{
					"workspaceKey" = $omswrkspacekey;
				}

				Write-Host "Adding Windows Insight Agent"
				Set-AzureRmVMExtension -VMName $VMName -ResourceGroupName $rg -Location $Location -Name "OperationalInsights" -ExtensionType "MicrosoftMonitoringAgent" -Publisher "Microsoft.EnterpriseCloud.Monitoring" -typeHandlerVersion "1.0" -InformationAction SilentlyContinue  -ErrorAction Stop  -Verbose  -SettingString $PublicSetting -ProtectedSettingString $PrivateSetting | Out-Null
				Get-AzureRmVMExtension -ResourceGroupName $rg -VMName $VMName -Name "OperationalInsights" | Out-Null
				$LogOut = "Widows Insight Deployed to $VMName"
				Log-Command -Description $LogOut -LogFile $LogOutFile
						Write-Results

													  break
}
		"ESET" {
				Verify-ExtWindows
				Write-Host "Setting File Security"
				Set-AzureRmVMExtension -VMName $VMName -ResourceGroupName $rg -Location $Location -Name "ESET" -ExtensionType "FileSecurity" -Publisher "ESET" -typeHandlerVersion "6.0" -InformationAction SilentlyContinue -Verbose  -ErrorAction Stop | Out-Null
				$LogOut = "ESET Deployed to $VMName"
				Log-Command -Description $LogOut -LogFile $LogOutFile
						Write-Results

										  break
}
		"winpushdsc" {
				Verify-ExtWindows
				Validate-WinDscName
				Configure-DSC
				Write-Host "Pushing DSC to $VMName in the $rg Resource Group"
						Write-Results

										  break
}
		"linuxpushdsc" {
				Verify-ExtLinux
				Validate-LinDscName
				Configure-DSCMof
				Write-Host "Pushing DSC to $VMName in the $rg Resource Group"
				Write-Results

										  break
}

		"azshare" {
				Upload-sharefiles
				Write-Host "Uploading Files to $StorageName"
						Write-Results

										  break
}
		"RegisterAzDSC" {
				Verify-ExtWindows

				Write-Host "Registering with Azure Automation DSC"
				$ActionAfterReboot = 'ContinueConfiguration'
				$configmode = 'ApplyAndAutocorrect'
				$AutoAcctName = $Azautoacct
				$NodeName = $VMName
				$autorg = 'AUTOMATION-RMP'
				$ConfigurationName = "config.$VMName"
				Register-AzureRmAutomationDscNode -AutomationAccountName $AutoAcctName -AzureVMName $VMName -ActionAfterReboot $ActionAfterReboot -ConfigurationMode $configmode -RebootNodeIfNeeded $True -ResourceGroupName $autorg -NodeConfigurationName $ConfigurationName -AzureVMLocation $Location -AzureVMResourceGroup $rg -Verbose | Out-Null
										  break
}
		"RegisterLinuxDSC" {
			Verify-ExtLinux
			Register-DSCLinux
				$LogOut = "Registration complete for $VMName"
				Log-Command -Description $LogOut -LogFile $LogOutFile
						Write-Results

			break
}
		"WinPuppet" {
				Verify-ExtWindows
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
		if($currentver-le '4.0.0'){
		Write-Host "expected version 4.0.1 found $ver" -ForegroundColor DarkRed
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
$time = " End Time " + (Get-Date -UFormat "%d-%m-%Y %H:%M:%S")
Write-Host VM CONFIGURATION - $time -ForegroundColor Cyan
Write-Host "                                                               "
Write-Host "VM Name: $VMName " -ForegroundColor White
Write-Host "Resource Group Name: $rg"
Write-Host "Storage Account Name:  $StorageNameVerified"
Write-Host "Extension deployed: $extname "
}

Function Write-Config {
param(

)

Write-Host "                                                               "
$time = " Start Time " + (Get-Date -UFormat "%d-%m-%Y %H:%M:%S")
Write-Host VM CONFIGURATION - $time -ForegroundColor Cyan
Write-Host "                                                               "
Write-Host "VM Name: $VMName " -ForegroundColor White
Write-Host "Resource Group Name: $rg"
Write-Host "Geo Location: $Location"
Write-Host "Storage Account Name: $StorageName"
Write-Host "Storage Account Type: $StorageType"
Write-Host "Extension selected for deployment: $extname "
Check-OSImage
Check-VMExtension
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
	$extvm = Get-AzureRmVm -Name $VMName -ResourceGroupName $rg -InformationAction SilentlyContinue -WarningAction SilentlyContinue

if(!$extvm)
{
	Write-Host "Host VM Not Found, please use a different VMName for Provisioning Extensions" -ForegroundColor Cyan
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

#region Upload Custom Software
Function Upload-sharefiles {
	param(
	[Parameter(Mandatory=$False,ValueFromPipelinebyPropertyName=$true)]
	[string]
	$StorageName = $StorageName,
	[Parameter(Mandatory=$False,ValueFromPipelinebyPropertyName=$true)]
	[string]
	$ShareName = $ShareName,
	[Parameter(Mandatory=$False,ValueFromPipelinebyPropertyName=$true)]
	[string]
	$rg = $rg,
	[Parameter(Mandatory=$False,ValueFromPipelinebyPropertyName=$true)]
	[string]
	$localsoftwareFolder = $localSoftwareFolder,
	[Parameter(Mandatory=$False,ValueFromPipelinebyPropertyName=$true)]
	[string]
	$Directory = $sharedirectory
	)
			$softwareexists = Test-Path -Path $localSoftwareFolder
	if(!$softwareexists)
	{
	Write-Host "Local Software Directory does not exist $localSoftwareFolder"
		exit
	}
			$Keys = Get-AzureRmStorageAccountKey -ResourceGroupName $rg -Name $StorageName
			$StorageContext = New-AzureStorageContext -StorageAccountName $StorageName -StorageAccountKey $Keys[0].Value
			$s = New-AzureStorageShare -Name $ShareName -Context $StorageContext
			New-AzureStorageDirectory -Share $s -Path $Directory
		$files = Get-ChildItem $localsoftwareFolder
		foreach($file in $files)
		{
		  $fileName = "$localsoftwareFolder\$file"
		  $blobName = "$file"
		  write-host "copying $fileName to $blobName"
			Set-AzureStorageFileContent -Share $s -Source $filename -Path $Directory
		}
		write-host "All files in $localSoftwareFolder uploaded to $Directory!"
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


Function Login-AddAzureRmProfile
{
Add-AzureRmAccount -WarningAction SilentlyContinue

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
Get-AzureRmResourceGroup -Location $Location -ErrorAction Stop -WarningAction SilentlyContinue -InformationAction SilentlyContinue| Out-Null
}
catch {
	Write-Host -foregroundcolor Yellow `
	"User has not authenticated, use Add-AzureRmAccount or $($_.Exception.Message)"; `
	Login-AddAzureRmProfile
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

Check-NullValues


		try {
				if($preview)
				{
				Write-Config
				Check-VM
				Check-StorageName
				Install-ExtPreview
				break
				}
				Write-Config
				Check-VM
				Check-StorageName
					Install-Ext
		}
					catch {
				Write-Host -foregroundcolor Yellow `
				"$($_.Exception.Message)"; `
				$LogOut = "$($_.Exception.Message)"
				Log-Command -Description $LogOut -LogFile $LogOutFile
				break
					}