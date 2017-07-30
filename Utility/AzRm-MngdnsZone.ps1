<#
.SYNOPSIS
Written By John Lewis
email: jonos@live.com
Ver 1.1

This script provides an automated deployment capability for Azure Zones. Specifically the script helps in creating new Zones and zone records, as well as removal related operations.

v 1.1 updates - added alignzonevm function which allows for automatic alignment of A records to existing hosts in Azure
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
 .EXAMPLE
 .\AZRM-MngdnsZone.ps1 -Action alignzonevm -ZoneName myzone.net -rg zone-dns -vmname myvm -vmrg my-vmrg
  .EXAMPLE
 .\AZRM-MngdnsZone.ps1 -Action addzonerec -ZoneName myzone.net -rg zone-dns -recname myrec -recip 127.20.0.4 -rectype a -recttl 3600

#>

[CmdletBinding(DefaultParameterSetName = 'default')]
Param(
[Parameter(Mandatory=$False,ValueFromPipelinebyPropertyName=$true)]
[ValidateNotNullorEmpty()]
[ValidateSet("createzone","addzonerec","removezonerec","removezone","getinfo","alignzonevm")]
[string]
$Action = 'addzonerec',
[Parameter(Mandatory=$False,ValueFromPipelinebyPropertyName=$true)]
[string]
$ZoneName = "beta.net",
[Parameter(Mandatory=$False,ValueFromPipelinebyPropertyName=$true)]
[string]
$RecName = '',
[Parameter(Mandatory=$False,ValueFromPipelinebyPropertyName=$true)]
[string]
$VMName = '',
[Parameter(Mandatory=$False,ValueFromPipelinebyPropertyName=$true)]
[string]
$rg = 'dns',
[Parameter(Mandatory=$False,ValueFromPipelinebyPropertyName=$true)]
[string]
$vmrg = 'vmrg',
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
$SubscriptionID = '',
[Parameter(Mandatory=$False,ValueFromPipelinebyPropertyName=$true)]
[string]
$TenantID = ''
	)
$workfolder = Split-Path $script:MyInvocation.MyCommand.Path
$ProfileFile = $workfolder+'\'+$profile+'.json'
$restorejson = $workfolder+'\'+ 'config.json'
$workfolder = Split-Path $script:MyInvocation.MyCommand.Path
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
Write-Host ZONE CONFIGURATION - $time -ForegroundColor Cyan
Write-Host "                                                               "

Write-Host "Action Selected: $Action"

}

Function Action-Summary {

if($Action -eq 'alignzonevm')
	{
	Write-Host "VMName: $VMName "
		Write-Host "VM Resource Group $vmrg"
			Write-Host "DNS Resource Group $rg"
				Write-Host "Zone Name $ZoneName "
					Write-Host "Record Type $RecType "
						Write-Host "Record TTL $RecTtl "
	}
	elseif($Action -eq 'createzone')
	{
				Write-Host "DNS Resource Group $rg"
				Write-Host "Zone Name $ZoneName"

	}
		elseif($Action -eq 'addzonerec')
			{
				Write-Host "DNS Resource Group $rg"
				Write-Host "Zone Name $ZoneName"
				Write-Host "Record Type $RecType "
				Write-Host "Record TTL $RecTtl "
				Write-Host "Record Name $RecName "
			}
			elseif($Action -eq 'removezonerec')
			{
				Write-Host "DNS Resource Group $rg"
				Write-Host "Zone Name $ZoneName"
				Write-Host "Record Name $RecName "
			}
			elseif($Action -eq 'removezone')
			{
				Write-Host "DNS Resource Group $rg"
				Write-Host "Zone Name $ZoneName"
			}

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
			Write-Host "Removed Record $RecName in $ZoneName"
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

$vma = get-azurermvm -ResourceGroupName $vmrg -Name $VMName
$idnic = $vma.NetworkProfile.NetworkInterfaces.Id.Split('/')[-1]
$ipcfg = Get-AzureRmNetworkInterface -Name $idnic -ResourceGroupName $ResourceGroupName
$pvtip = $ipcfg.IpConfigurations | Select-Object -ExpandProperty PrivateIpAddress
$Script:pvtip = $pvtip
Write-Host "Located Private IP Address: $Script:pvtip"
}

Function New-AzureDNSZone {
param(
[string] $ZoneName = $ZoneName,
[string] $rg = $rg
)
try {
	 New-AzureRmDnsZone -Name $ZoneName -ResourceGroupName $rg -ErrorAction Stop -WarningAction SilentlyContinue -InformationAction SilentlyContinue
			Write-Host "Created $ZoneName in $rg"

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
	Write-Host "Creating record in ZoneName: $ZoneName RecName: $RecName RecIP: $RecIp"

	New-AzureRmDnsRecordSet -Name $RecName -RecordType $RecType -ResourceGroupName $rg -Ttl $RecTtl -DnsRecords (New-AzureRmDnsRecordConfig -IPv4Address $RecIp) -ZoneName $ZoneName -Overwrite | Out-Null
		Write-Host "Created Record $RecName in $ZoneName with a ttl of $RecTtl and type $RecType"
}
catch {
	Write-Host -foregroundcolor Yellow `
	"$($_.Exception.Message)"; `
	$LogOut = "$($_.Exception.Message)"
	Log-Command -Description $LogOut -LogFile $LogOutFile
	break
}
}


Function Write-Completion {

Write-Host "                                                               "
$time = " End Time " + (Get-Date -UFormat "%d-%m-%Y %H:%M:%S")
Write-Host ZONE CONFIGURATION - $time -ForegroundColor Cyan
Write-Host "                                                               "
Write-Host "Completed operation: $Action " -ForegroundColor White
Write-Host "                                                               "
}

Function Check-VMExists {
	param(
	[Parameter(Mandatory=$False,ValueFromPipelinebyPropertyName=$true)]
	[string]
	$Location = $Location,
	[Parameter(Mandatory=$False,ValueFromPipelinebyPropertyName=$true)]
	[string]
	$vmrg = $vmrg,
	[Parameter(Mandatory=$False,ValueFromPipelinebyPropertyName=$true)]
	[string]
	$VMName = $VMName
	)
	$extvm = Get-AzureRmVm -Name $VMName -ResourceGroupName $vmrg -ErrorAction SilentlyContinue -WarningAction SilentlyContinue
if(!$extvm)
{
	Write-Host "$VMName does not exist, please verify the VM exists" -ForegroundColor Yellow
	Break
}

 else {Write-Host "Host VM Located" -ForegroundColor Green}
 
} #

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
						Write-Completion
}
		"addzonerec" {
			New-AzureDNSZoneRecord
						Write-Completion
		}
		"removezone" {
			Remove-AzureDNSZone
						Write-Completion
		}
		"removezonerec" {
			Remove-AzureDNSZoneRecord
						Write-Completion
		}
		"getinfo" {
			Get-ZoneInfo
		}
		"alignzonevm" {
			Check-VMExists
			Get-AzureVMIp
			New-AzureDNSZoneRecord -ZoneName $ZoneName -rg $rg -RecName $VMName -RecIp $Script:pvtip -RecTtl $RecTtl -RecType $RecType
			Write-Completion
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
Action-Summary
Configure-DNS