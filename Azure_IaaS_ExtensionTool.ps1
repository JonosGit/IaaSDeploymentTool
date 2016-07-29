<#
.SYNOPSIS
Written By John Lewis v.2
This script will provision existing extensions in Azure. The script also supports underlying operations for Custom Scripts such as creating blob storage and uploading dependent installation files for custom script execution.

.PARAMETERS
-VMName
-ResourceGroupName
-AzExtConfig
	ExtChef
	ExtVMAcces
	ExtCustScript
	ExtAddDom
	ExtMSAV
	ExtDiag
	LinBootStChef
	WinBootStChef
-CreateStorage
.EXAMPLES
.\azextension.ps1 -VMName MyVm -ResourceGroupName MyRg -AzExtConfig ExtCustScript -CreateStorage
.\azextension.ps1 -VMName MyVm -ResourceGroupName MyRg -AzExtConfig ExtDiag
.\azextension.ps1 -VMName MyVm -ResourceGroupName MyRg -AzExtConfig ExtChef
#>

Param(

 [Parameter(Mandatory=$False,ValueFromPipeline=$True,Position=0)]
 [string]
 $VMName = "win001",
 [Parameter(Mandatory=$False,ValueFromPipeline=$True)]
 [Bool]
 $CreateStorage = $False,
 [Parameter(Mandatory=$False,ValueFromPipeline=$True,Position=1)]
 [string]
 $ResourceGroupName = "Rgp",
[Parameter(Mandatory=$False,ValueFromPipelinebyPropertyName=$true)]
 [string]
 $AzExtConfig = 'Win',

 [Parameter(Mandatory=$False,ValueFromPipelinebyPropertyName=$true)]
 [string]
 $Location = "WestUs",

 [Parameter(Mandatory=$False,ValueFromPipelinebyPropertyName=$true)]
 [string]
 $SubscriptionID = '',

 [Parameter(Mandatory=$False,ValueFromPipelinebyPropertyName=$true)]
 [string]
 $TenantID = '',

 [Parameter(Mandatory=$False)]
 [string]
 $GenerateName = -join ((65..90) + (97..122) | Get-Random -Count 6 | % {[char]$_}) + "aip",

 [Parameter(Mandatory=$False,ValueFromPipelinebyPropertyName=$true)]
 [string]
 $storageAccountName = $GenerateName.ToLower() + "str",

 [Parameter(Mandatory=$False,ValueFromPipelinebyPropertyName=$true)]
 [string]
 $StorageType = "Standard_GRS",

 [Parameter(Mandatory=$False,ValueFromPipelinebyPropertyName=$true)]
 [string]
 $SkipDependencyDetection = "True",
 [Parameter(Mandatory=$False,ValueFromPipelinebyPropertyName=$true)]
 [string]
 $thisfolder = "C:\Templates\",

 [Parameter(Mandatory=$False,ValueFromPipelinebyPropertyName=$true)]
 [string]
 $localfolder = "$thisfolder\templates",
 [Parameter(Mandatory=$False,ValueFromPipelinebyPropertyName=$true)]
 [string]
 $destfolder = "templates",
[Parameter(Mandatory=$False,ValueFromPipelinebyPropertyName=$true)]
 [string]
 $localfolder2 = "$thisfolder\iaasinstall",
 [Parameter(Mandatory=$False,ValueFromPipelinebyPropertyName=$true)]
 [string]
 $destfolder2 = "iaasinstall",
 [Parameter(Mandatory=$False,ValueFromPipelinebyPropertyName=$true)]
 [string]
$containerName1 = "templates",
 [Parameter(Mandatory=$False,ValueFromPipelinebyPropertyName=$true)]
 [string]
$containerName2 = "iaasinstall",
  [Parameter(Mandatory=$False,ValueFromPipelinebyPropertyName=$true)]
 [string]
 $locadmin = 'localadmin',
 [Parameter(Mandatory=$False)]
 [string]
 $locpassword = ""

)
## Global
Select-AzureRmProfile -Path “c:\Templates\pf1.json”
$SecureLocPassword=Convertto-SecureString $locpassword –asplaintext -force
$Credential1 = New-Object System.Management.Automation.PSCredential ($locadmin,$SecureLocPassword)
$vm = New-Object System.Management.Automation.PSObject ($VMName)

# Add-AzureRmAccount -TenantId $TenantID
# Resource Group


if($CreateStorage)
{
### Create an Azure Resource Manager (ARM) Resource Group
$ResourceGroup = @{
Name = $ResourceGroupName;
Location = 'West Us';
Force = $true;
}
New-AzureRmResourceGroup @ResourceGroup;

$StorageAccount = @{
	ResourceGroupName = $ResourceGroupName;
	Name = $storageAccountName;
	SkuName = 'Standard_LRS';
	Location = 'West US';
	}

New-AzureRmStorageAccount @StorageAccount;

### Obtain the Storage Account authentication keys using Azure Resource Manager (ARM)
$Keys = Get-AzureRmStorageAccountKey -ResourceGroupName $ResourceGroupName -Name $storageAccountName;

### Use the Azure.Storage module to create a Storage Authentication Context
$StorageContext = New-AzureStorageContext -StorageAccountName $storageAccountName.ToLower() -StorageAccountKey $Keys[0].Value;

### Create a Blob Container in the Storage Account
New-AzureStorageContainer -Context $StorageContext -Name templates;
New-AzureStorageContainer -Context $StorageContext -Name iaas_install
;

### Upload a file to the Microsoft Azure Storage Blob Container

$storageAccountKey = Get-AzureRmStorageAccountKey -ResourceGroupName $ResourceGroupName -Name $storageAccountName;
$blobContext = New-AzureStorageContext -StorageAccountName $storageAccountName -StorageAccountKey $Keys[0].Value;
Function UploadFiles {

$files = Get-ChildItem $localFolder 
foreach($file in $files)
{
  $fileName = "$localFolder1\$file"
  $blobName = "$destfolder1/$file"
	$containerName = $containerName1
  write-host "copying $fileName to $blobName"
  Set-AzureStorageBlobContent -File $filename -Container $containerName -Blob $blobName -Context $blobContext -Force
  $fileName = "$localFolder2\$file"
  $blobName = "$destfolder2/$file"
		$containerName = $containerName2
  write-host "copying $fileName to $blobName"
  Set-AzureStorageBlobContent -File $filename -Container $containerName -Blob $blobName -Context $blobContext -Force

} 
write-host "All files in $localFolder uploaded to $containerName!"
}

}
	 switch -Wildcard ($AzExtConfig)
	{
		"*ExtVMAccess*" {
Write-Host "VM Access Agent VM Image Preparation in Process"
Set-AzureRmVMAccessExtension -ResourceGroupName $ResourceGroupName -VMName $VMName -Name "VMAccess" -ExtensionType "VMAccessAgent" -Publisher "Microsoft.Compute" -typeHandlerVersion "2.0" -Location $Location -Verbose
Get-AzureRmVMExtension -ResourceGroupName $ResourceGroupName -VMName $VMName -Name "VMAccess"
}
		"*ExtMSAV*" {
Write-Host "MSAV Agent VM Image Preparation in Process"
Set-AzureRmVMExtension  -ResourceGroupName $ResourceGroupName -VMName $VMName -Name "MSAVExtension" -ExtensionType "IaaSAntimalware" -Publisher "Microsoft.Azure.Security" -typeHandlerVersion 1.4 -Location $Location
Set-AzureRmVMAccessExtension -ResourceGroupName $ResourceGroupName -VMName $VMName -Name "MSAVExtension" -Location Westus
Get-AzureRmVMExtension -ResourceGroupName $ResourceGroupName -VMName $VMName -Name "MSAVExtension" -Status
}
		"*ExtCustScript" {
Write-Host "Updating server with custom script"
Set-AzureRmVMCustomScriptExtension -Name "CustScript" -ResourceGroupName $ResourceGroupName -Run "CustScript.ps1" -VMName $VMName -FileUri $StorageName -Location $Location -TypeHandlerVersion "1.1"
Get-AzureRmVMCustomScriptExtension -ResourceGroupName $ResourceGroupName -Name "CustScript"
}
		"*ExtDiag*" {
Write-Host "Adding Azure Enhanced Diagnostics"
Set-AzureRmVMAEMExtension -ResourceGroupName $ResourceGroupName -VMName $VMName -WADStorageAccountName $StorageName
Get-AzureRmVMAEMExtension -ResourceGroupName $ResourceGroupName -VMName $VMName
}
		"*ExtAddDom*" {
Write-Host "Adding Azure Enhanced Diagnostics"
Set-AzureRmVMADDomainExtension -DomainName $DomName -ResourceGroupName $ResourceGroupName -VMName $VMName -Location $Location -JoinOption -OUPath -Restart -Name
Get-AzureRmVMADDomainExtension -ResourceGroupName $ResourceGroupName -VMName $VMName -Status -Name
		}
		"*ExtChef*" {
Write-Host "Adding Chef Agent"
Set-AzureRmVMExtension -ResourceGroupName $ResourceGroupName -VMName $VMName -Name "ChefStrap" -ExtensionType "ChefClient" -Publisher "Chef.Bootstrap.WindowsAzure" -typeHandlerVersion "1210.12" -Location $Location -Verbose -ProtectedSettingString -SettingString
Get-AzureRmVMExtension -ResourceGroupName $ResourceGroupName -VMName $VMName -Name "ChefStrap"
		}
		"*WinBootStChef*" {
Write-Host "Bootstrapping Chef Agent"
knife bootstrap windows winrm $BootIp --winrm-user $localadmin --winrm-password $locpassword --node-name $VMName --Install-as-service
		}
		"*LinBootStChef*" {
Write-Host "Bootstrapping Chef Agent"
knife bootstrap $BootIp --node-name $VMName --ssh-user localadmin --ssh-password $locpassword --sudo --use-sudo-password --verbose --yes
		}

		default{"An unsupported Extensions command was used"}
	}
