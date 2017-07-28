<#
.SYNOPSIS
Written By John Lewis
email: jonos@live.com
Ver 1.0

This script provides an automated deployment capability for Azure Zones. Specifically the script helps in creating new Zones and zone records, as well as removal related operations.
v 1.0 updates - RTM

.PARAMETER Action

.PARAMETER zonename

.PARAMETER recname

.PARAMETER recip

.PARAMETER rectype

.PARAMETER recttl

.EXAMPLE
 .\AZRM-MngdnsZone.ps1 -Action getinfo -ZoneName myzone.net -rg zone-dns
.EXAMPLE
 .\AZRM-MngdnsZone.ps1 -Action createzone -ZoneName myzone.net -rg zone-dns

#>

[CmdletBinding(DefaultParameterSetName = 'default')]
Param(
[Parameter(Mandatory=$False,ValueFromPipelinebyPropertyName=$true)]
[ValidateNotNullorEmpty()]
[ValidateSet("createzone","addzonerec","removezonerec","remzone","getinfo")]
[string]
$Action = 'addzonerec',
[Parameter(Mandatory=$False,ValueFromPipelinebyPropertyName=$true)]
[string]
$ZoneName = "",
[Parameter(Mandatory=$False,ValueFromPipelinebyPropertyName=$true)]
[string]
$RecName = '',
[Parameter(Mandatory=$False,ValueFromPipelinebyPropertyName=$true)]
[string]
$rg = '',
[Parameter(Mandatory=$False,ValueFromPipelinebyPropertyName=$true)]
[string]
$RecIp = '',
[Parameter(Mandatory=$False,ValueFromPipelinebyPropertyName=$true)]
[string]
$RecTtl = '3600',
[Parameter(Mandatory=$False,ValueFromPipelinebyPropertyName=$true)]
[ValidateNotNullorEmpty()]
[ValidateSet("a","cname","aaaa","mx")]
[string]
$RecType = 'a',
[Parameter(Mandatory=$False,ValueFromPipelinebyPropertyName=$true)]
[ValidateNotNullorEmpty()]
[string]
$location = "West US",
[Parameter(Mandatory=$False,ValueFromPipelinebyPropertyName=$true)]
[string]
$Profile = "profile",
[Parameter(Mandatory=$False,ValueFromPipelinebyPropertyName=$true)]
[string]
$csvfile = -join $workfolder + "\azrm-dnsrec.csv",
[Parameter(Mandatory=$False,ValueFromPipelinebyPropertyName=$true)]
[Alias("csv")]
[switch]
$csvimport,
[Parameter(Mandatory=$False,ValueFromPipelinebyPropertyName=$true)]
[string]
$VMName = '',
[Parameter(Mandatory=$False,ValueFromPipelinebyPropertyName=$true)]
[string]
$vmrg = '',
[Parameter(Mandatory=$False,ValueFromPipelinebyPropertyName=$true)]
[string]
$SubscriptionID = '',
[Parameter(Mandatory=$False,ValueFromPipelinebyPropertyName=$true)]
[string]
$TenantID = ''
	)

$workfolder = Split-Path $script:MyInvocation.MyCommand.Path
$ProfileFile = $workfolder+'\'+$profile+'.json'
$restorejson = $workfolder+'\'+ 'config.json'
$logdir = $workfolder+'\'+'log'+'\'
$LogOutFile = $logdir+$Action+'-'+$date+'.log'

$date = Get-Date -UFormat "%Y-%m-%d-%H-%M"

$Error.Clear()
Set-StrictMode -Version Latest
Trap [System.SystemException] {("Exception" + $_ ) ; break}

Function Write-Config {
param(

)

Write-Host "                                                               "
$time = " Start Time " + (Get-Date -UFormat "%d-%m-%Y %H:%M:%S")
Write-Host DNS CONFIGURATION - $time -ForegroundColor Cyan
Write-Host "                                                               "

Write-Host "Action Selected: $Action"
}

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

function Check-NullValues {
if(!$rg) {
Write-Host "Please Enter Resource Group Name"
exit
}
				elseif(!$Location) {
				Write-Host "Please Enter -Location"
				exit
				}
}

Function Get-ZoneInfo {
	Get-AzureRmDnsRecordSet -ResourceGroupName $rg -ZoneName $ZoneName | ft Name,ZoneName,Tty,RecordType,Records | Format-Table
}

Function csv-run {
param(
[string] $csvin = $csvfile
)
try {
	$GetPath = test-path -Path $csvin
	if(!$GetPath)
	{ exit }
	else {
	Write-Host $csvin "dns csv File Exists"
		import-csv -Path $csvin -Delimiter ',' | ForEach-Object{.\AZRM-Mngdns.ps1 -Action $_.Action -ZoneName $_.ZoneName -RecName $_.RecName -RecIp $_.RecIp -Recttl $_.Recttl -rg $_.rg -Rectype $_.RecType }
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

Function Remove-AzureDNSZone {
param(
[string] $ZoneName = $ZoneName,
[string] $rg = $rg
)
try {
	 Remove-AzureRmDnsZone -Name $ZoneName -ResourceGroupName $rg -ErrorAction Stop -WarningAction SilentlyContinue -InformationAction SilentlyContinue
}
catch {
	Write-Host -foregroundcolor Yellow `
	"$($_.Exception.Message)"; `
	$LogOut = "$($_.Exception.Message)"
	Log-Command -Description $LogOut -LogFile $LogOutFile
	break
}
}

Function Remove-AzureDNSZoneRecord {
param(
[string] $ZoneName = $ZoneName,
[string] $rg = $rg,
[string] $RecName = $RecName,
[string] $RecType = $RecType
)
try {
	 Remove-AzureRmDnsRecordSet -Name $RecName -ResourceGroupName $rg -RecordType $RecType -ZoneName $ZoneName -Force -ErrorAction Stop -WarningAction SilentlyContinue -InformationAction SilentlyContinue
}
catch {
	Write-Host -foregroundcolor Yellow `
	"$($_.Exception.Message)"; `
	$LogOut = "$($_.Exception.Message)"
	Log-Command -Description $LogOut -LogFile $LogOutFile
	break
}
}

Function Get-AzureVMIp {
	param(
[string] $vmrg = $vmrg,
[string] $VMName = $VMName
)

$vms = get-azurermvm -ResourceGroupName $vmrg -Name $VMName -WarningAction SilentlyContinue -InformationAction SilentlyContinue

$nics = get-azurermnetworkinterface -ResourceGroupName $vmrg -WarningAction SilentlyContinue | where VirtualMachine -EQ $VMName

	$vm = $vms | where-object -Property Id -EQ $nic.VirtualMachine.id
	$prv =  $nic.IpConfigurations | select-object -ExpandProperty PrivateIpAddress
	$Script:prvip =  $nic.IpConfigurations | select-object -ExpandProperty PrivateIpAddress
	$alloc =  $nic.IpConfigurations | select-object -ExpandProperty PrivateIpAllocationMethod
	Write-Host "Located Private IP $Script:prvip for VM $VMName"
}

Function New-AzureDNSZone {
param(
[string] $ZoneName = $ZoneName,
[string] $rg = $rg
)
try {
	 New-AzureRmDnsZone -Name $ZoneName -ResourceGroupName $rg -ErrorAction Stop -WarningAction SilentlyContinue -InformationAction SilentlyContinue
}
catch {
	Write-Host -foregroundcolor Yellow `
	"$($_.Exception.Message)"; `
	$LogOut = "$($_.Exception.Message)"
	Log-Command -Description $LogOut -LogFile $LogOutFile
	break
}
}

Function New-AzureDNSZoneRecord {
param(
[string] $ZoneName = $ZoneName,
[string] $rg = $rg,
[string] $RecName,
[string] $RecIp,
[string] $RecTtl = $RecTtl,
[string] $RecType = $RecType
)
try {
	Write-Host "ZoneName = $ZoneName"
		Write-Host "RecName = $RecName"
		Write-Host "IP = $RecIp"
			Write-Host "RG = $rg"

	New-AzureRmDnsRecordSet -Name $RecName -RecordType $RecType -ResourceGroupName $rg -Ttl $RecTtl -DnsRecords (New-AzureRmDnsRecordConfig -IPv4Address $RecIp) -ZoneName $ZoneName -Overwrite | Out-Null
		Write-Host "Created Record $RecName"
}
catch {
	Write-Host -foregroundcolor Yellow `
	"$($_.Exception.Message)"; `
	$LogOut = "$($_.Exception.Message)"
	Log-Command -Description $LogOut -LogFile $LogOutFile
	break
}
}

Function Configure-DNS {
	param(
		[Parameter(Mandatory=$False,ValueFromPipelinebyPropertyName=$true)]
		[string]
		$action = $action
	)
switch ($action)
	{
		"createzone" {
			New-RG
			New-AzureDNSZone
}
		"addzonerec" {
			New-AzureDNSZoneRecord
		}
		"removezone" {
			Remove-AzureDNSZone
		}
		"removezonerec" {
			Remove-AzureDNSZoneRecord
		}
		"getinfo" {
			Get-ZoneInfo
		}
		"alignzonevm" {
			Get-AzureVMIp
			New-AzureDNSZoneRecord -ZoneName $ZoneName -rg $rg -RecName $RecName -RecIp $Script:prvip -RecTtl $RecTtl -RecType $RecType
		}

		default{"An unsupported command was used"}
	}
	exit
}

Function New-RG {
param(
[string] $rg = $rg
)
try {
	 New-AzureRmResourceGroup -Name $rg -Location $Location –Confirm:$false -WarningAction SilentlyContinue -Force | Out-Null
}
catch {
	Write-Host -foregroundcolor Yellow `
	"$($_.Exception.Message)"; `
	$LogOut = "$($_.Exception.Message)"
	Log-Command -Description $LogOut -LogFile $LogOutFile
	break
}
}

Function Log-Command
([string]$Description, [string]$logFile, [string]$Action)
{
$Output = $LogOut+'. '
Write-Host $Output -ForegroundColor white
((Get-Date -UFormat "[%d-%m-%Y %H:%M:%S] ") + $Output) | Out-File -FilePath $LogOutFile -Append -Force
}

validate-profile

try {
Get-AzureRmResourceGroup -Location $Location -ErrorAction Stop | Out-Null
}
catch {
	Write-Host -foregroundcolor Yellow `
	"User has not authenticated, use Add-AzureRmAccount or $($_.Exception.Message)"; `
	Login-AddAzureRmProfile
}

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



Write-Config
Configure-DNS