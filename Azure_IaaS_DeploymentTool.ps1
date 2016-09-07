<#
.SYNOPSIS
Written By John N Lewis
email: jonos@live.com
Ver 5.1
This script provides the following functionality for deploying IaaS environments in Azure. The script will deploy VNET in addition to numerour Market Place VMs or make use of an existing VNETs.
The script supports dual homed servers (PFSense/Checkpoint/FreeBSD/F5/Barracuda)
The script allows select of subnet prior to VM Deployment
The script supports deploying Availability Sets as well as adding new servers to existing Availability Sets through the -AvailabilitySet "True" and -AvailSetName switches.
The script will generate a name for azure storage endpoint unless the -StorageName variable is updated or referenced at runtime.

v5.1 updates - Added VPN Creation Function
v5.0 updates - Added Alias' to command parameters
v4.9 updates - additional validation functions, note changes to AddVNET and NSGEnabled field types (was string now bool)
v4.8 updates - Added F5/Barracuda as well as Bitnami images
v4.7 updates - Added Step Logging
v4.6 Updates - Added Support for F5, Barracuda, SAP and Solar Winds
v4.5 Updates - Fixes for Azure PowerShell 2.1

.DESCRIPTION
Deploys 30 different Market Images on a new or existing VNET. Supports post deployment configuration through Azure Extensions.
Market Images supported: Redhat 6.7 and 7.2, PFSense 2.5, Windows 2008 R2, Windows 2012 R2, Ubuntu 14.04, CentOs 7.2, SUSE, SQL 2016 (on W2K12R2), R Server on Windows, Windows 2016 (Preview), Checkpoint Firewall, FreeBsd, Oracle Linux, Puppet, Splunk, Oracle Web-Logic, Oracle DB, Bitnami Lamp, Bitnami PostGresSql, Bitnami nodejs, Bitnami Elastics, Bitnami MySql, SharePoint 2013/2016, Barracuda NG, Barracuda SPAM, F5 BigIP, F5 App Firewall, SAP, Solar Winds, Bitnami JRuby, Bitnami Neos, Bitnami TomCat, Bitnami redis, Bitnami hadoop
.PARAMETER vmMarketImage

.PARAMETER AddVnet

.PARAMETER VMName

.PARAMETER ResourceGroupName

.PARAMETER vNetResourceGroupName

.PARAMETER VNetName

.PARAMETER ConfigIPs

.PARAMETER VMSize

.PARAMETER locadmin

.PARAMETER locpassword

.PARAMETER NSGEnabled

.PARAMETER Location

.PARAMETER SubscriptionID

.PARAMETER TenantID

.PARAMETER GenerateName

.PARAMETER StorageName

.PARAMETER StorageType

.PARAMETER InterfaceName1

.PARAMETER InterfaceName2

.PARAMETER NSGName

.PARAMETER Subnet1

.PARAMETER Subnet2

.PARAMETER AddAvailabilitySet

.PARAMETER AvailSetName

.PARAMETER PvtIPNic1

.PARAMETER PvtIPNic2

.PARAMETER LocalNetPip

.PARAMETER AddVPN

.PARAMETER LocalAddPrefix

.PARAMETER AzExtConfig
.EXAMPLE
\.azdeploy.ps1 -vm pf001 -image pfsense -rg ResGroup1 -vnetrg ResGroup2 -addvnet $True -vnet VNET -sub1 3 -sub2 4 -ConfigIPs DualPvtNoPub -Nic1 10.120.2.7 -Nic2 10.120.3.7
.EXAMPLE
\.azdeploy.ps1 -vm red76 -image red67 -rg ResGroup1 -vnetrg ResGroup2 -vnet VNET -sub1 7 -ConfigIPs SinglePvtNoPub -Nic1 10.120.6.124 -Ext linuxbackup
.EXAMPLE
\.azdeploy.ps1 -vm win006 -image w2k12 -rg ResGroup1 -vnetrg ResGroup2 -vnet VNE T-sub1 2 -ConfigIPs Single -AvSet $True -NSGEnabled $True -NSGName NSG
.EXAMPLE
\.azdeploy.ps1 -vm win008 -image w2k16 -rg ResGroup1 -vnetrg ResGroup2 -vnet VNET -sub1 5 -ConfigIPs PvtSingleStat -Nic1 10.120.4.169 -AddFQDN $True -fqdn mydns1
.EXAMPLE
\.azdeploy.ps1 -vm ubu001 -image ubuntu -RG ResGroup1 -vnetrg ResGroup2 -VNet VNET -sub1 6 -ConfigIPs PvtSingleStat -Nic1 10.120.5.169 -AddFQDN $True -fqdn mydns2
.NOTES
-ConfigIps  <Configuration>
			PvtSingleStat & PvtDualStat – Deploys the server with a Public IP and the private IP(s) specified by the user.
			NoPubSingle & NoPubDual - Deploys the server without Public IP using automatically generated private IP(s).
			Single & Dual – Deploys the default configuration of a Public IP and automatically generated private IP(s).
			StatPvtNoPubDual & StatPvtNoPubSingle – Deploys the server without a Public IP using the private IP(s) specified by the user.
-VMMarketImage <Image ShortName>
			Redhat 6.7 – Red67
			Redhat7.2 – Red72
			Windows 2012 R2 – w2k12
			PFSense 2.5 – pfsense
			Free BSD – free
			Suse – suse
			CentOs 7.2 – cent
			Ubuntu 14.04 – ubuntu
			SQL Server 2016 (on Windows 2012 host) – sql2016
			MySql – mysql
			CheckPoint – check
			Windows 2008 R2 – w2k8
			Windows 2016 – w2k16
			Chef v12 - chef
			Bitnami LampStack - lamp
			Bitnami MySql - mysql
			Bitnami NodeJs - node
			Bitnami Elastics Search - elastics
			Bitnami Jenkins - jenkins
			Bitnami PostGresSql - postgressql
			Bitnami Git Lab - gitlab
			Bitnami Redis - redis
			Bitnami Hadoop - hadoop
			Bitnami Tom-Cat - tomcat
			Bitnami jRubyStack - jruby
			Bitnami neos - neos
			Oracle Web Logic - weblogic
			Oracle Linux - oracle-linux
			Oracle Standard Edition DB - stddb-oracle
			Oracle Enterprise Edition DB - entdb-oracle
			Puppet Enterprise - puppet
			Splunk Enterprise - splunk
			SAP - sap
			Solar Winds - solarwinds
			F5 BIG IP - f5bigip
			F5 Application Firewall - f5appfire
			Barracuda NG Firewall (hourly) - barrahourngfw
			Barracuda NG Firewall (BYOL) - barrabyolngfw
			Barracuda spam Firewall (hourly) - barrahourspam
			Barracuda spam Firewall (byol) - barrabyolspam
			SharePoint 2016 - Share2016
			SharePoint 2013 - share2013
			Server R - serverr

-AzExtConfig <Extension Type>
			access – Adds Azure Access Extension – Added by default during VM creation
			msav – Adds Azure Antivirus Extension
			custScript – Adds Custom Script for Execution (Requires Table Storage Configuration first)
			diag – Adds Azure Diagnostics Extension
			linuxOsPatch - Deploy Latest updates for Linux platforms
			linuxbackup - Deploys Azure Linux bacup Extension
			addDom – Adds Azure Domain Join Extension
			chef – Adds Azure Chef Extension (Requires Chef Certificate and Settings info first)
.LINK
https://github.com/JonosGit/IaaSDeploymentTool
#>

[CmdletBinding()]
Param(
[Parameter(Mandatory=$False,ValueFromPipelinebyPropertyName=$true,Position=1)]
[ValidateSet("w2k12","w2k8","red67","red72","suse","free","ubuntu","centos","w2k16","sql2016","chef","check","pfsense","lamp","jenkins","nodejs","elastics","postgressql","splunk","oracle-linux","puppet","web-logic","stddb-oracle","entdb-oracle","serverr","sap","solarwinds","f5bigip","f5appfire","barrahourngfw","barrabyolngfw","barrahourspam","barrabyolspam","mysql","share2013","share2016","mongodb","nginxstack","hadoop","neos","tomcat","redis","gitlab","jruby")]
[Alias("image")]
[string]
$vmMarketImage = "",

[Parameter(Mandatory=$False,ValueFromPipelinebyPropertyName=$true)]
[bool]
$AddVnet = $True,

[Parameter(Mandatory=$False,ValueFromPipelinebyPropertyName=$true,Position=0)]
[Alias("vm")]
[string]
$VMName = "",

[Parameter(Mandatory=$False,ValueFromPipelinebyPropertyName=$true,Position=2)]
[Alias("rg")]
[string]
$ResourceGroupName = '',

[Parameter(Mandatory=$False,ValueFromPipelinebyPropertyName=$true)]
[Alias("vnetrg")]
[string]
$vNetResourceGroupName = '',

[Parameter(Mandatory=$False,ValueFromPipelinebyPropertyName=$true)]
[Alias("vnet")]
[string]
$VNetName = "vnet",

[Parameter(Mandatory=$False,ValueFromPipelinebyPropertyName=$true)]
[ValidateSet("Single","Dual","NoPubDual","PvtDualStat","StatPvtNoPubSingle","PvtSingleStat","StatPvtNoPubDual","NoPubSingle")]
[string]
$ConfigIPs = "Dual",

[Parameter(Mandatory=$False,ValueFromPipelinebyPropertyName=$true)]
[ValidateSet("Standard_A3","Standard_A4","Standard_A2")]
[string]
$VMSize = "Standard_A3",

[Parameter(Mandatory=$False,ValueFromPipelinebyPropertyName=$true)]
[string]
$locadmin = 'localadmin',

[Parameter(Mandatory=$False)]
[string]
$locpassword = 'P@ssW0rd!',

[Parameter(Mandatory=$False,ValueFromPipelinebyPropertyName=$true)]
[Alias("nsg")]
[bool]
$NSGEnabled = $False,

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

[Parameter(Mandatory=$False)]
[string]
$StorageName = $VMName + "str",

[Parameter(Mandatory=$False,ValueFromPipelinebyPropertyName=$true)]
[string]
$StorageType = "Standard_GRS",

[Parameter(Mandatory=$False)]
[Alias("int1")]
[string]
$InterfaceName1 = $VMName + "_nic1",

[Parameter(Mandatory=$False)]
[Alias("int2")]
[string]
$InterfaceName2 = $VMName + "_nic2",

[Parameter(Mandatory=$False,ValueFromPipelinebyPropertyName=$true)]
[string]
$NSGName = "NSG",

[Parameter(Mandatory=$False,ValueFromPipelinebyPropertyName=$true)]
[ValidateRange(0,8)]
[Alias("sub1")]
[Int]
$Subnet1 = 2,

[Parameter(Mandatory=$False,ValueFromPipelinebyPropertyName=$true)]
[ValidateRange(0,8)]
[Alias("sub2")]
[Int]
$Subnet2 = 3,

[Parameter(Mandatory=$False,ValueFromPipelinebyPropertyName=$true)]
[Alias("avset")]
[bool]
$AddAvailabilitySet = $False,

[Parameter(Mandatory=$False,ValueFromPipelinebyPropertyName=$true)]
[string]
$AvailSetName = $GenerateName,

[Parameter(Mandatory=$False,ValueFromPipelinebyPropertyName=$true)]
[Alias("fqdn")]
[string]
$DNLabel = 'mytesr1',

[Parameter(Mandatory=$False,ValueFromPipelinebyPropertyName=$true)]
[bool]
$AddFQDN = $False,

[Parameter(Mandatory=$False,ValueFromPipelinebyPropertyName=$true)]
[Alias("nic1")]
$PvtIPNic1 = '',

[Parameter(Mandatory=$False,ValueFromPipelinebyPropertyName=$true)]
[Alias("nic2")]
$PvtIPNic2 = '',

[Parameter(Mandatory=$False,ValueFromPipelinebyPropertyName=$true)]
[bool]
$AddVPN = $False,

[Parameter(Mandatory=$False,ValueFromPipelinebyPropertyName=$true)]
[ipaddress]
$LocalNetPip = "207.21.2.1",

[Parameter(Mandatory=$False,ValueFromPipelinebyPropertyName=$true)]
[string]
$LocalAddPrefix = "10.10.0.0/24",

[Parameter(Mandatory=$False,ValueFromPipelinebyPropertyName=$true)]
[Alias("ext")]
[string]
$AzExtConfig = ''

)

# Global
# $ErrorActionPreference = "SilentlyContinue"
$date = Get-Date -UFormat "%Y-%m-%d-%H-%M"
$workfolder = Split-Path $script:MyInvocation.MyCommand.Path
$SecureLocPassword=Convertto-SecureString $locpassword –asplaintext -Force
$Credential1 = New-Object System.Management.Automation.PSCredential ($locadmin,$SecureLocPassword)
$LogOutFile = $workfolder+'\'+$vmname+'-'+$date+'.log'

Function Log-Command ([string]$Description, [string]$logFile, [string]$VMName){
$Output = $LogOut+'. '
Write-Host $Output -ForegroundColor white
((Get-Date -UFormat "[%d-%m-%Y %H:%M:%S] ") + $Output) | Out-File -FilePath $LogOutFile -Append -Force
}

Function WriteLog-Command([string]$Description, [ScriptBlock]$Command, [string]$LogFile, [string]$VMName){
Try{
$Output = $Description+'  ... '
Write-Host $Output -ForegroundColor Yellow
((Get-Date -UFormat "[%d-%m-%Y %H:%M:%S] ") + $Output) | Out-File -FilePath $LogFile -Append -Force
$Result = Invoke-Command -ScriptBlock $Command
}
Catch {
$ErrorMessage = $_.Exception.Message
$Output = 'Error '+$ErrorMessage
((Get-Date -UFormat "[%d-%m-%Y %H:%M:%S] ") + $Output) | Out-File -FilePath $LogFile -Append -Force
$Result = ""
continue
}
Finally
{
if ($ErrorMessage -eq $null) {$Output = "[Completed]  $Description  ... "} else {$Output = "[Failed]  $Description  ... "}
((Get-Date -UFormat "[%d-%m-%Y %H:%M:%S] ") + $Output) | Out-File -FilePath $LogFile -Append -Force
}
Return $Result
}

Function VerifyProfile {
$ProfileFile = ""
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

Function VerifyPvtIps {
if($PvtIPNic1)
{
$subnet = $Subnet1
$ip = $PvtIPNic1
$array = $ip.Split(".")
[int]$subnetint = $array[2]
$subnetcalc = ($subnetint + '1')
Write-Host "Subnet Match $subnet $subnetcalc"
if($subnetcalc -ne $subnet){
Write-Host "Verify the IP Address for Subnet1 is in the correct subnet"
break
}
}
if($PvtIPNic2){
$subnet = $Subnet2
$ip = $PvtIPNic2
$array = $ip.Split(".")
[int]$subnetint = $array[2]
$subnetcalc = ($subnetint + '1')
Write-Host "Subnet Match $subnet $subnetcalc"
if($subnetcalc -ne $subnet){
Write-Host "Verify the IP Address for Subnet2 is in the correct subnet"
break
}
}
}

Function VerifyNicValue1 {
if($PvtIPNic1.Length -le 7) {Write-Host "Invalid IP"
exit
}
}

Function VerifyNicValue2 {
if($PvtIPNic1.Length -le 7) {Write-Host "Invalid IP"
exit
}
}

Function VerifyNet {
If ($ConfigIPs -eq "StatPvtNoPubSingle")
{ Write-Host "Subnet IP Validation" -ForegroundColor White
VerifyNicValue1
VerifyPvtIps
}
If ($ConfigIPs -eq "StatPvtNoPubDual")
{ Write-Host "Subnet IP Validation" -ForegroundColor White
VerifyNicValue1
VerifyNicValue2
VerifyPvtIps
}
If ($ConfigIPs -eq "Single")
{ Write-Host "Skipping Subnet IP Validation"
}

If ($ConfigIPs -eq "Dual")
{ Write-Host "Skipping Subnet IP Validation"
}
If ($ConfigIPs -eq "PvtSingleStat")
{ Write-Host "Subnet IP Validation"
VerifyNicValue1
VerifyPvtIps
}
If ($ConfigIPs -eq "PvtDualStat")
{ Write-Host "Subnet IP Validation"
VerifyNicValue1
VerifyNicValue2
VerifyPvtIps
}
}

function chknull {
if(!$vmMarketImage) {
Write-Host "Please Enter vmMarketImage"
exit }
	elseif(!$VMName) {
	Write-Host "Please Enter vmName"
	exit}
		elseif(!$VNetName) {
		Write-Host "Please Enter vNet Name"
		exit}
			elseif(!$ResourceGroupName) {
			Write-Host "Please Enter Resource Group Name"
			exit}
				elseif(!$Location) {
				Write-Host "Please Enter Location"
				exit}
					elseif(!$ConfigIPs) {
					Write-Host "Please Enter IP Configuration"
					exit}
						elseif(!$VNETResourceGroupName) {
						Write-Host "Please Enter VNET Resource Group Name"
						exit
											}
}

Function PubIPconfig {
if($AddFQDN)
{
$global:PIp = New-AzureRmPublicIpAddress -Name $InterfaceName1 -ResourceGroupName $ResourceGroupName -Location $Location -AllocationMethod "Dynamic" -DomainNameLabel $DNLabel –Confirm:$false -WarningAction SilentlyContinue
$LogOut = "Completed Public DNS record creation $DNLabel.$Location.cloudapp.azure.com"
Log-Command -Description $LogOut -LogFile $LogOutFile
}
else
{
$global:PIp = New-AzureRmPublicIpAddress -Name $InterfaceName1 -ResourceGroupName $ResourceGroupName -Location $Location -AllocationMethod "Dynamic" –Confirm:$false -WarningAction SilentlyContinue
}
}

Function PubDNSconfig {
if($AddFQDN)
{
Write-Host "Creating FQDN: " $DNLabel.$Location.cloudapp.azure.com
}
else
{
Write-Host "No DNS Name Specified"
}
}

Function ConfigNet {
switch ($ConfigIPs)
	{
		"PvtDualStat" {
Write-Host "Dual IP Configuration - Static"
PubIPconfig
$global:VNet = Get-AzureRMVirtualNetwork -Name $VNetName -ResourceGroupName $vNetResourceGroupName | Set-AzureRmVirtualNetwork
$global:Interface1 = New-AzureRmNetworkInterface -Name $InterfaceName1 -ResourceGroupName $ResourceGroupName -Location $Location -SubnetId $VNet.Subnets[$Subnet1].Id -PublicIpAddressId $PIp.Id -PrivateIpAddress $PvtIPNic1 –Confirm:$false -WarningAction SilentlyContinue
$global:Interface2 = New-AzureRmNetworkInterface -Name $InterfaceName2 -ResourceGroupName $ResourceGroupName -Location $Location -SubnetId $VNet.Subnets[$Subnet2].Id -PrivateIpAddress $PvtIPNic2 –Confirm:$false -WarningAction SilentlyContinue
}
		"PvtSingleStat" {
Write-Host "Single IP Configuration - Static"
PubIPconfig
$global:VNet = Get-AzureRMVirtualNetwork -Name $VNetName -ResourceGroupName $vNetResourceGroupName | Set-AzureRmVirtualNetwork
$global:Interface1 = New-AzureRmNetworkInterface -Name $InterfaceName1 -ResourceGroupName $ResourceGroupName -Location $Location -SubnetId $VNet.Subnets[$Subnet1].Id -PublicIpAddressId $PIp.Id -PrivateIpAddress $PvtIPNic1 –Confirm:$false -WarningAction SilentlyContinue
}
		"StatPvtNoPubDual" {
Write-Host "Dual IP Configuration- Static - No Public"
$global:VNet = Get-AzureRMVirtualNetwork -Name $VNetName -ResourceGroupName $vNetResourceGroupName | Set-AzureRmVirtualNetwork
$global:Interface1 = New-AzureRmNetworkInterface -Name $InterfaceName1 -ResourceGroupName $ResourceGroupName -Location $Location -SubnetId $VNet.Subnets[$Subnet1].Id -PrivateIpAddress $PvtIPNic1 –Confirm:$false -WarningAction SilentlyContinue
$global:Interface2 = New-AzureRmNetworkInterface -Name $InterfaceName2 -ResourceGroupName $ResourceGroupName -Location $Location -SubnetId $VNet.Subnets[$Subnet2].Id -PrivateIpAddress $PvtIPNic2 –Confirm:$false -WarningAction SilentlyContinue
}
		"StatPvtNoPubSingle" {
Write-Host "Single IP Configuration - Static - No Public"
$global:VNet = Get-AzureRMVirtualNetwork -Name $VNetName -ResourceGroupName $vNetResourceGroupName | Set-AzureRmVirtualNetwork
$global:Interface1 = New-AzureRmNetworkInterface -Name $InterfaceName1 -ResourceGroupName $ResourceGroupName -Location $Location -SubnetId $VNet.Subnets[$Subnet1].Id -PrivateIpAddress $PvtIPNic1 –Confirm:$false -WarningAction SilentlyContinue
}
		"Single" {
Write-Host "Default Single IP Configuration"
PubIPconfig
$global:VNet = Get-AzureRMVirtualNetwork -Name $VNetName -ResourceGroupName $vNetResourceGroupName | Set-AzureRmVirtualNetwork
$global:Interface1 = New-AzureRmNetworkInterface -Name $InterfaceName1 -ResourceGroupName $ResourceGroupName -Location $Location -SubnetId $VNet.Subnets[$Subnet1].Id -PublicIpAddressId $PIp.Id –Confirm:$false -WarningAction SilentlyContinue
}
		"Dual" {
Write-Host "Default Dual IP Configuration"
PubIPconfig
$global:VNet = Get-AzureRMVirtualNetwork -Name $VNetName -ResourceGroupName $vNetResourceGroupName | Set-AzureRmVirtualNetwork
$global:Interface1 = New-AzureRmNetworkInterface -Name $InterfaceName1 -ResourceGroupName $ResourceGroupName -Location $Location -SubnetId $VNet.Subnets[$Subnet1].Id -PublicIpAddressId $PIp.Id –Confirm:$false -WarningAction SilentlyContinue
$global:Interface2 = New-AzureRmNetworkInterface -Name $InterfaceName2 -ResourceGroupName $ResourceGroupName -Location $Location -SubnetId $VNet.Subnets[$Subnet2].Id –Confirm:$false -WarningAction SilentlyContinue
}
		"NoPubSingle" {
Write-Host "Single IP - No Public"
$global:VNet = Get-AzureRMVirtualNetwork -Name $VNetName -ResourceGroupName $vNetResourceGroupName | Set-AzureRmVirtualNetwork
$global:Interface1 = New-AzureRmNetworkInterface -Name $InterfaceName1 -ResourceGroupName $ResourceGroupName -Location $Location -SubnetId $VNet.Subnets[$Subnet1].Id –Confirm:$false -WarningAction SilentlyContinue
}
		"NoPubDual" {
Write-Host "Dual IP - No Public"
$global:VNet = Get-AzureRMVirtualNetwork -Name $VNetName -ResourceGroupName $vNetResourceGroupName | Set-AzureRmVirtualNetwork
$global:Interface1 = New-AzureRmNetworkInterface -Name $InterfaceName1 -ResourceGroupName $ResourceGroupName -Location $Location -SubnetId $VNet.Subnets[$Subnet1].Id –Confirm:$false -WarningAction SilentlyContinue
$global:Interface2 = New-AzureRmNetworkInterface -Name $InterfaceName2 -ResourceGroupName $ResourceGroupName -Location $Location -SubnetId $VNet.Subnets[$Subnet2].Id –Confirm:$false -WarningAction SilentlyContinue
}
		default{"Nothing matched entry criteria"}
}
}

Function AddNICs {
Write-Host "Adding 2 Network Interface(s) $InterfaceName1 $InterfaceName2" -ForegroundColor White
$global:VirtualMachine = Add-AzureRmVMNetworkInterface -VM $VirtualMachine -Id $global:Interface1.Id -Primary -WarningAction SilentlyContinue
$global:VirtualMachine = Add-AzureRmVMNetworkInterface -VM $VirtualMachine -Id $global:Interface2.Id -WarningAction SilentlyContinue
$LogOut = "Completed adding NICs"
Log-Command -Description $LogOut -LogFile $LogOutFile
}

Function AddNIC {
Write-Host "Adding Network Interface $InterfaceName1" -ForegroundColor White
$global:VirtualMachine = Add-AzureRmVMNetworkInterface -VM $VirtualMachine -Id $global:Interface1.Id -Primary -WarningAction SilentlyContinue
$LogOut = "Completed adding NIC"
Log-Command -Description $LogOut -LogFile $LogOutFile
}

Function ConfigSet {
switch  ($ConfigIPs)
	{
		"PvtDualStat" {
AddNICs
}
		"PvtSingleStat" {
AddNIC
}
		"StatPvtNoPubDual" {
AddNICs
}
		"StatPvtNoPubSingle" {
AddNIC
}
		"Single" {
AddNIC
}
		"Dual" {
AddNICs
}
		"NoPubSingle" {
AddNIC
}
		"NoPubDual" {
AddNICs
}
		default{"An unsupported network configuration was referenced"
		break
					}
}
}
Function NSGEnabled
{
if($NSGEnabled){
$nic1 = Get-AzureRmNetworkInterface -Name $InterfaceName1 -ResourceGroupName $ResourceGroupName -ErrorAction SilentlyContinue
$nic2 = Get-AzureRmNetworkInterface -Name $InterfaceName2 -ResourceGroupName $ResourceGroupName -ErrorAction SilentlyContinue
if($nic1)
{
$nsg = Get-AzureRmNetworkSecurityGroup -ResourceGroupName $vNetResourceGroupName -Name $NSGName
$nic = Get-AzureRmNetworkInterface -ResourceGroupName $ResourceGroupName -Name $InterfaceName1
$nic.NetworkSecurityGroup = $nsg
Set-AzureRmNetworkInterface -NetworkInterface $nic | Out-Null
$LogOut = "Completed Image NSG Post Configuration. Added $InterfaceName1 to $NSGName"
Log-Command -Description $LogOut -LogFile $LogOutFile
}
if($nic2)
{
$nsg = Get-AzureRmNetworkSecurityGroup -ResourceGroupName $vNetResourceGroupName -Name $NSGName
$nic = Get-AzureRmNetworkInterface -ResourceGroupName $ResourceGroupName -Name $InterfaceName2
$nic.NetworkSecurityGroup = $nsg
Set-AzureRmNetworkInterface -NetworkInterface $nic | Out-Null
$secrules = Get-AzureRmNetworkSecurityGroup -Name $NSGName -ResourceGroupName $vNetResourceGroupName | Get-AzureRmNetworkSecurityRuleConfig | Ft Name,Description,Direction,SourcePortRange,DestinationPortRange,DestinationPortRange,SourceAddressPrefix,Access | Format-Table | Out-Null
$defsecrules = Get-AzureRmNetworkSecurityGroup -Name $NSGName -ResourceGroupName $vNetResourceGroupName | Get-AzureRmNetworkSecurityRuleConfig -DefaultRules | Format-Table | Out-Null
$LogOut = "Completed Image NSG Post Configuration. Added $InterfaceName2 to $NSGName"
Log-Command -Description $LogOut -LogFile $LogOutFile
}
}
}
Function CreateVPN {
Write-Host "VPN Creation can take up to 45 minutes!"
New-AzureRmLocalNetworkGateway -Name LocalSite -ResourceGroupName $vNetResourceGroupName -Location $Location -GatewayIpAddress $LocalNetPip -AddressPrefix $LocalAddPrefix -ErrorAction Stop -WarningAction SilentlyContinue | Out-Null
Write-Host "Completed Local Network GW Creation"
$vpnpip= New-AzureRmPublicIpAddress -Name vpnpip -ResourceGroupName $vNetResourceGroupName -Location $Location -AllocationMethod Dynamic -ErrorAction Stop -WarningAction SilentlyContinue
$vnet = Get-AzureRmVirtualNetwork -Name $VNetName -ResourceGroupName $vNetResourceGroupName -ErrorAction Stop -WarningAction SilentlyContinue
$subnet = Get-AzureRmVirtualNetworkSubnetConfig -Name 'GatewaySubnet' -VirtualNetwork $vnet -WarningAction SilentlyContinue
$vpnipconfig = New-AzureRmVirtualNetworkGatewayIpConfig -Name vpnipconfig1 -SubnetId $subnet.Id -PublicIpAddressId $vpnpip.Id -WarningAction SilentlyContinue
New-AzureRmVirtualNetworkGateway -Name vnetvpn1 -ResourceGroupName $vNetResourceGroupName -Location $Location -IpConfigurations $vpnipconfig -GatewayType Vpn -VpnType RouteBased -GatewaySku Standard -ErrorAction Stop -WarningAction SilentlyContinue | Out-Null
Write-Host "Completed VNET Network GW Creation"
Get-AzureRmPublicIpAddress -Name vpnpip -ResourceGroupName $ResourceGroupName -WarningAction SilentlyContinue
Write-Host "Configure Local Device with Azure VNET vpn Public IP"
}
Function ConnectVPN {
[PSObject]$gateway1 = Get-AzureRmVirtualNetworkGateway -Name vnetvpn1 -ResourceGroupName $vNetResourceGroupName -WarningAction SilentlyContinue
[PSObject]$local = Get-AzureRmLocalNetworkGateway -Name LocalSite -ResourceGroupName $vNetResourceGroupName -WarningAction SilentlyContinue
New-AzureRmVirtualNetworkGatewayConnection -ConnectionType IPSEC  -Name sitetosite -ResourceGroupName $vNetResourceGroupName -Location $Location -VirtualNetworkGateway1 $gateway1 -LocalNetworkGateway2 $local -SharedKey '4321avfe' -Verbose -Force -RoutingWeight 10 -WarningAction SilentlyContinue| Out-Null
}
Function SelectNicDescrtipt {
if($ConfigIPs-EQ "Dual"){Write-Host "Dual Pvt IP & Public IP will be created" }
	elseif($ConfigIPs-EQ "Single"){Write-Host "Single Pvt IP & Public IP will be created" }
		elseif($ConfigIPs-EQ "PvtDualStat"){Write-Host "Dual Static Pvt IP & Public IP will be created" }
			elseif($ConfigIPs-EQ"PvtSingleStat"){Write-Host "Single Static Pvt IP & Public IP will be created" }
				elseif($ConfigIPs-EQ "SinglePvtNoPub"){Write-Host "Single Static Pvt IP & No Public IP" }
					elseif($ConfigIPs-EQ "StatPvtNoPubDual"){Write-Host "Dual Static Pvt IP & No Public IP"}
						elseif($ConfigIPs-EQ "StatPvtNoPubSingle"){Write-Host "Single Static Pvt IP & No Public IP"}
							elseif($ConfigIPs-EQ "NoPubDual"){Write-Host "Dual Pvt IP & No Public IP"}
	else {
	Write-Host "No Network Config Found - Warning" -ForegroundColor Red
	}
}

Function RegisterRP {
	Param(
		[string]$ResourceProviderNamespace
	)

	# Write-Host "Registering resource provider '$ResourceProviderNamespace'";
	Register-AzureRmResourceProvider -ProviderNamespace $ResourceProviderNamespace –Confirm:$false -WarningAction SilentlyContinue | Out-Null;
}

Function AvailSet {
 try {
 If ($AddAvailabilitySet)
 {
 Write-Host "Availability Set configuration in process.." -ForegroundColor White
New-AzureRmAvailabilitySet -ResourceGroupName $ResourceGroupName -Name $AvailSetName -Location $Location -WarningAction SilentlyContinue | Out-Null
$AddAvailabilitySet = (Get-AzureRmAvailabilitySet -ResourceGroupName $ResourceGroupName -Name $AvailSetName).Id
$global:VirtualMachine = New-AzureRmVMConfig -VMName $VMName -VMSize $VMSize -AvailabilitySetID $AddAvailabilitySet -WarningAction SilentlyContinue
Write-Host "Availability Set has been configured" -ForegroundColor White
$LogOut = "Completed Availability Set configuration $AvailSetName"
Log-Command -Description $LogOut -LogFile $LogOutFile
}
else
{
Write-Host "Skipping Availability Set configuration" -ForegroundColor White
$global:VirtualMachine = New-AzureRmVMConfig -VMName $VMName -VMSize $VMSize -WarningAction SilentlyContinue
$LogOut = "Skipped Availability Set Configuration"
Log-Command -Description $LogOut -LogFile $LogOutFile
}
	}

catch {
	Write-Host -foregroundcolor Red `
	"$($_.Exception.Message)"; `
	break
}
 }

 function Provvms {
	$ProvisionVMs = @($VirtualMachine);
try {
   foreach($provisionvm in $ProvisionVMs) {
		New-AzureRmVM -ResourceGroupName $ResourceGroupName -Location $Location -VM $VirtualMachine –Confirm:$false -WarningAction SilentlyContinue | Out-Null
		Log-Command -Description $LogOut -LogFile $LogOutFile
		Write-Host "Completed creation of new VM" -ForegroundColor White
						}
	}
catch {
	Write-Host -foregroundcolor Red `
	"$($_.Exception.Message)"; `
	break
}
	 }

Function AddDiskImage {
Write-Host "Completing image creation..." -ForegroundColor White
$global:osDiskCaching = "ReadWrite"
$global:OSDiskName = $VMName + "OSDisk"
$global:OSDiskUri = $StorageAccount.PrimaryEndpoints.Blob.ToString() + "vhds/" + $OSDiskName + ".vhd"
$global:VirtualMachine = Set-AzureRmVMOSDisk -VM $VirtualMachine -Name $OSDiskName -VhdUri $OSDiskUri -CreateOption "FromImage" -Caching $osDiskCaching -WarningAction SilentlyContinue
}

Function MakeImagePlanInfo_Bitnami_Lamp {
param(
[string]$Publisher = 'bitnami',
[string]$offer = 'lampstack',
[string]$Skus = '5-6',
[string]$version = 'latest',
[string]$Product = 'lampstack',
[string]$name = '5-6'
)
Write-Host "Image Creation in Process - Plan Info - LampStack" -ForegroundColor White
Write-Host 'Publisher:'$Publisher 'Offer:'$offer 'Sku:'$Skus 'Version:'$version
$global:VirtualMachine= Set-AzureRmVMPlan -VM $VirtualMachine -Name $name -Publisher $Publisher -Product $Product
$global:VirtualMachine = Set-AzureRmVMOperatingSystem -VM $VirtualMachine -linux -ComputerName $VMName -Credential $Credential1
$global:VirtualMachine = Set-AzureRmVMSourceImage -VM $VirtualMachine -PublisherName $Publisher -Offer $offer -Skus $Skus -Version $version
}
Function MakeImagePlanInfo_Bitnami_elastic {
param(
[string]$Publisher = 'bitnami',
[string]$offer = 'elastic-search',
[string]$Skus = '2-2',
[string]$version = 'latest',
[string]$Product = 'elastic-search',
[string]$name = '2-2'
)
Write-Host "Image Creation in Process - Plan Info - Elastic Search" -ForegroundColor White
Write-Host 'Publisher:'$Publisher 'Offer:'$offer 'Sku:'$Skus 'Version:'$version
$global:VirtualMachine= Set-AzureRmVMPlan -VM $VirtualMachine -Name $name -Publisher $Publisher -Product $Product
$global:VirtualMachine = Set-AzureRmVMOperatingSystem -VM $VirtualMachine -linux -ComputerName $VMName -Credential $Credential1
$global:VirtualMachine = Set-AzureRmVMSourceImage -VM $VirtualMachine -PublisherName $Publisher -Offer $offer -Skus $Skus -Version $version
}
Function MakeImagePlanInfo_Bitnami_jenkins {
param(
[string]$Publisher = 'bitnami',
[string]$offer = 'jenkins',
[string]$Skus = '1-650',
[string]$version = 'latest',
[string]$Product = 'jenkins',
[string]$name = '1-650'
)
Write-Host "Image Creation in Process - Plan Info - Jenkins" -ForegroundColor White
Write-Host 'Publisher:'$Publisher 'Offer:'$offer 'Sku:'$Skus 'Version:'$version
$global:VirtualMachine= Set-AzureRmVMPlan -VM $VirtualMachine -Name $name -Publisher $Publisher -Product $Product
$global:VirtualMachine = Set-AzureRmVMOperatingSystem -VM $VirtualMachine -linux -ComputerName $VMName -Credential $Credential1
$global:VirtualMachine = Set-AzureRmVMSourceImage -VM $VirtualMachine -PublisherName $Publisher -Offer $offer -Skus $Skus -Version $version
}

Function MakeImagePlanInfo_Microsoft_ServerR {
param(
[string]$Publisher = 'microsoft-r-products',
[string]$offer = 'microsoft-r-server',
[string]$Skus = 'msr80-win2012r2',
[string]$version = 'latest',
[string]$Product = 'microsoft-r-server',
[string]$name = 'msr80-win2012r2'
)
Write-Host "Image Creation in Process - Plan Info - Microsoft R Server" -ForegroundColor White
Write-Host 'Publisher:'$Publisher 'Offer:'$offer 'Sku:'$Skus 'Version:'$version
$global:VirtualMachine= Set-AzureRmVMPlan -VM $VirtualMachine -Name $name -Publisher $Publisher -Product $Product
$global:VirtualMachine = Set-AzureRmVMOperatingSystem -VM $VirtualMachine -Windows -ComputerName $VMName -Credential $Credential1
$global:VirtualMachine = Set-AzureRmVMSourceImage -VM $VirtualMachine -PublisherName $Publisher -Offer $offer -Skus $Skus -Version $version
}
Function MakeImagePlanInfo_Bitnami_tomcat {
param(
[string]$Publisher = 'bitnami',
[string]$offer = 'tom-cat',
[string]$Skus = '7-0',
[string]$version = 'latest',
[string]$Product = 'tom-cat',
[string]$name = '7-0'
)
Write-Host "Image Creation in Process - Plan Info - Tom-Cat" -ForegroundColor White
Write-Host 'Publisher:'$Publisher 'Offer:'$offer 'Sku:'$Skus 'Version:'$version
$global:VirtualMachine= Set-AzureRmVMPlan -VM $VirtualMachine -Name $name -Publisher $Publisher -Product $Product
$global:VirtualMachine = Set-AzureRmVMOperatingSystem -VM $VirtualMachine -linux -ComputerName $VMName -Credential $Credential1
$global:VirtualMachine = Set-AzureRmVMSourceImage -VM $VirtualMachine -PublisherName $Publisher -Offer $offer -Skus $Skus -Version $version
}

Function MakeImagePlanInfo_Bitnami_redis {
param(
[string]$Publisher = 'bitnami',
[string]$offer = 'redis',
[string]$Skus = '3-2',
[string]$version = 'latest',
[string]$Product = 'redis',
[string]$name = '3-2'
)
Write-Host "Image Creation in Process - Plan Info - Redis"
Write-Host 'Publisher:'$Publisher 'Offer:'$offer 'Sku:'$Skus 'Version:'$version
$global:VirtualMachine= Set-AzureRmVMPlan -VM $VirtualMachine -Name $name -Publisher $Publisher -Product $Product
$global:VirtualMachine = Set-AzureRmVMOperatingSystem -VM $VirtualMachine -linux -ComputerName $VMName -Credential $Credential1
$global:VirtualMachine = Set-AzureRmVMSourceImage -VM $VirtualMachine -PublisherName $Publisher -Offer $offer -Skus $Skus -Version $version
}
Function MakeImagePlanInfo_Bitnami_neos {
param(
[string]$Publisher = 'bitnami',
[string]$offer = 'neos',
[string]$Skus = '2-0',
[string]$version = 'latest',
[string]$Product = 'neos',
[string]$name = '2-0'
)
Write-Host "Image Creation in Process - Plan Info - neos"
Write-Host 'Publisher:'$Publisher 'Offer:'$offer 'Sku:'$Skus 'Version:'$version
$global:VirtualMachine= Set-AzureRmVMPlan -VM $VirtualMachine -Name $name -Publisher $Publisher -Product $Product
$global:VirtualMachine = Set-AzureRmVMOperatingSystem -VM $VirtualMachine -linux -ComputerName $VMName -Credential $Credential1
$global:VirtualMachine = Set-AzureRmVMSourceImage -VM $VirtualMachine -PublisherName $Publisher -Offer $offer -Skus $Skus -Version $version
}
Function MakeImagePlanInfo_Bitnami_hadoop {
param(
[string]$Publisher = 'bitnami',
[string]$offer = 'hadoop',
[string]$Skus = '2-7',
[string]$version = 'latest',
[string]$Product = 'hadoop',
[string]$name = '2-7'
)
Write-Host "Image Creation in Process - Plan Info - hadoop"
Write-Host 'Publisher:'$Publisher 'Offer:'$offer 'Sku:'$Skus 'Version:'$version
$global:VirtualMachine= Set-AzureRmVMPlan -VM $VirtualMachine -Name $name -Publisher $Publisher -Product $Product
$global:VirtualMachine = Set-AzureRmVMOperatingSystem -VM $VirtualMachine -linux -ComputerName $VMName -Credential $Credential1
$global:VirtualMachine = Set-AzureRmVMSourceImage -VM $VirtualMachine -PublisherName $Publisher -Offer $offer -Skus $Skus -Version $version
}
Function MakeImagePlanInfo_Bitnami_gitlab {
param(
[string]$Publisher = 'bitnami',
[string]$offer = 'gitlab',
[string]$Skus = '8-5',
[string]$version = 'latest',
[string]$Product = 'gitlab',
[string]$name = '8-5'
)
Write-Host "Image Creation in Process - Plan Info - gitlab"
Write-Host 'Publisher:'$Publisher 'Offer:'$offer 'Sku:'$Skus 'Version:'$version
$global:VirtualMachine= Set-AzureRmVMPlan -VM $VirtualMachine -Name $name -Publisher $Publisher -Product $Product
$global:VirtualMachine = Set-AzureRmVMOperatingSystem -VM $VirtualMachine -linux -ComputerName $VMName -Credential $Credential1
$global:VirtualMachine = Set-AzureRmVMSourceImage -VM $VirtualMachine -PublisherName $Publisher -Offer $offer -Skus $Skus -Version $version
}
Function MakeImagePlanInfo_Bitnami_jrubystack {
param(
[string]$Publisher = 'bitnami',
[string]$offer = 'jrubystack',
[string]$Skus = '9-0',
[string]$version = 'latest',
[string]$Product = 'jrubystack',
[string]$name = '9-0'
)
Write-Host "Image Creation in Process - Plan Info - jrubystack"
Write-Host 'Publisher:'$Publisher 'Offer:'$offer 'Sku:'$Skus 'Version:'$version
$global:VirtualMachine= Set-AzureRmVMPlan -VM $VirtualMachine -Name $name -Publisher $Publisher -Product $Product
$global:VirtualMachine = Set-AzureRmVMOperatingSystem -VM $VirtualMachine -linux -ComputerName $VMName -Credential $Credential1
$global:VirtualMachine = Set-AzureRmVMSourceImage -VM $VirtualMachine -PublisherName $Publisher -Offer $offer -Skus $Skus -Version $version
}

Function MakeImagePlanInfo_Bitnami_mongodb {
param(
[string]$Publisher = 'bitnami',
[string]$offer = 'mongodb',
[string]$Skus = '3-2',
[string]$version = 'latest',
[string]$Product = 'mongodb',
[string]$name = '3-2'
)
Write-Host "Image Creation in Process - Plan Info - MongoDb" -ForegroundColor White
Write-Host 'Publisher:'$Publisher 'Offer:'$offer 'Sku:'$Skus 'Version:'$version
$global:VirtualMachine= Set-AzureRmVMPlan -VM $VirtualMachine -Name $name -Publisher $Publisher -Product $Product
$global:VirtualMachine = Set-AzureRmVMOperatingSystem -VM $VirtualMachine -linux -ComputerName $VMName -Credential $Credential1
$global:VirtualMachine = Set-AzureRmVMSourceImage -VM $VirtualMachine -PublisherName $Publisher -Offer $offer -Skus $Skus -Version $version
}
Function MakeImagePlanInfo_Bitnami_mysql {
param(
[string]$Publisher = 'bitnami',
[string]$offer = 'mysql',
[string]$Skus = '5-6',
[string]$version = 'latest',
[string]$Product = 'mysql',
[string]$name = '5-6'
)
Write-Host "Image Creation in Process - Plan Info - MySql" -ForegroundColor White
Write-Host 'Publisher:'$Publisher 'Offer:'$offer 'Sku:'$Skus 'Version:'$version
$global:VirtualMachine= Set-AzureRmVMPlan -VM $VirtualMachine -Name $name -Publisher $Publisher -Product $Product
$global:VirtualMachine = Set-AzureRmVMOperatingSystem -VM $VirtualMachine -linux -ComputerName $VMName -Credential $Credential1
$global:VirtualMachine = Set-AzureRmVMSourceImage -VM $VirtualMachine -PublisherName $Publisher -Offer $offer -Skus $Skus -Version $version
}
Function MakeImagePlanInfo_Bitnami_nginxstack {
param(
[string]$Publisher = 'bitnami',
[string]$offer = 'nginxstack',
[string]$Skus = '1-9',
[string]$version = 'latest',
[string]$Product = 'nginxstack',
[string]$name = '1-9'
)
Write-Host "Image Creation in Process - Plan Info - Nginxstack" -ForegroundColor White
Write-Host 'Publisher:'$Publisher 'Offer:'$offer 'Sku:'$Skus 'Version:'$version
$global:VirtualMachine= Set-AzureRmVMPlan -VM $VirtualMachine -Name $name -Publisher $Publisher -Product $Product
$global:VirtualMachine = Set-AzureRmVMOperatingSystem -VM $VirtualMachine -linux -ComputerName $VMName -Credential $Credential1
$global:VirtualMachine = Set-AzureRmVMSourceImage -VM $VirtualMachine -PublisherName $Publisher -Offer $offer -Skus $Skus -Version $version
}
Function MakeImagePlanInfo_Bitnami_nodejs {
param(
[string]$Publisher = 'bitnami',
[string]$offer = 'nodejs',
[string]$Skus = '4-3',
[string]$version = 'latest',
[string]$Product = 'nodejs',
[string]$name = '4-3'
)
Write-Host "Image Creation in Process - Plan Info - Nodejs" -ForegroundColor White
Write-Host 'Publisher:'$Publisher 'Offer:'$offer 'Sku:'$Skus 'Version:'$version
$global:VirtualMachine= Set-AzureRmVMPlan -VM $VirtualMachine -Name $name -Publisher $Publisher -Product $Product
$global:VirtualMachine = Set-AzureRmVMOperatingSystem -VM $VirtualMachine -linux -ComputerName $VMName -Credential $Credential1
$global:VirtualMachine = Set-AzureRmVMSourceImage -VM $VirtualMachine -PublisherName $Publisher -Offer $offer -Skus $Skus -Version $version
}
Function MakeImagePlanInfo_Bitnami_postgresql {
param(
[string]$Publisher = 'bitnami',
[string]$offer = 'postgresql',
[string]$Skus = '9-5',
[string]$version = 'latest',
[string]$Product = 'postgresql',
[string]$name = '9-5'
)
Write-Host "Image Creation in Process - Plan Info - postgresql" -ForegroundColor White
Write-Host 'Publisher:'$Publisher 'Offer:'$offer 'Sku:'$Skus 'Version:'$version
$global:VirtualMachine= Set-AzureRmVMPlan -VM $VirtualMachine -Name $name -Publisher $Publisher -Product $Product
$global:VirtualMachine = Set-AzureRmVMOperatingSystem -VM $VirtualMachine -linux -ComputerName $VMName -Credential $Credential1
$global:VirtualMachine = Set-AzureRmVMSourceImage -VM $VirtualMachine -PublisherName $Publisher -Offer $offer -Skus $Skus -Version $version
}
Function MakeImagePlanInfo_Oracle_linux {
param(
[string]$Publisher = 'Oracle',
[string]$offer = 'Oracle-Linux',
[string]$Skus = '7.2',
[string]$version = 'latest',
[string]$Product = 'Oracle-Linux',
[string]$name = '7.2'
)
Write-Host "Image Creation in Process - Plan Info - Oracle Linux" -ForegroundColor White
Write-Host 'Publisher:'$Publisher 'Offer:'$offer 'Sku:'$Skus 'Version:'$version
$global:VirtualMachine= Set-AzureRmVMPlan -VM $VirtualMachine -Name $name -Publisher $Publisher -Product $Product
$global:VirtualMachine = Set-AzureRmVMOperatingSystem -VM $VirtualMachine -linux -ComputerName $VMName -Credential $Credential1
$global:VirtualMachine = Set-AzureRmVMSourceImage -VM $VirtualMachine -PublisherName $Publisher -Offer $offer -Skus $Skus -Version $version
}
Function MakeImagePlanInfo_Oracle_weblogic {
param(
[string]$Publisher = 'Oracle',
[string]$offer = 'Oracle-WebLogic-server',
[string]$Skus = 'Oracle-WebLogic-Server',
[string]$version = 'latest',
[string]$Product = 'Oracle-WebLogic-Server',
[string]$name = 'Oracle-WebLogic-Server'
)
Write-Host "Image Creation in Process - Plan Info - Oracle WebLogic" -ForegroundColor White
Write-Host 'Publisher:'$Publisher 'Offer:'$offer 'Sku:'$Skus 'Version:'$version
$global:VirtualMachine= Set-AzureRmVMPlan -VM $VirtualMachine -Name $name -Publisher $Publisher -Product $Product
$global:VirtualMachine = Set-AzureRmVMOperatingSystem -VM $VirtualMachine -linux -ComputerName $VMName -Credential $Credential1
$global:VirtualMachine = Set-AzureRmVMSourceImage -VM $VirtualMachine -PublisherName $Publisher -Offer $offer -Skus $Skus -Version $version
}
Function MakeImagePlanInfo_Oracle_EntDB {
param(
[string]$Publisher = 'Oracle',
[string]$offer = 'Oracle-database-Ee',
[string]$Skus = '12.1.0.2',
[string]$version = 'latest',
[string]$Product = '12.1.0.2',
[string]$name = 'Oracle-database-Ee'
)
Write-Host "Image Creation in Process - Plan Info - Oracle Enterprise Edition" -ForegroundColor White
Write-Host 'Publisher:'$Publisher 'Offer:'$offer 'Sku:'$Skus 'Version:'$version
$global:VirtualMachine= Set-AzureRmVMPlan -VM $VirtualMachine -Name $name -Publisher $Publisher -Product $Product
$global:VirtualMachine = Set-AzureRmVMOperatingSystem -VM $VirtualMachine -linux -ComputerName $VMName -Credential $Credential1
$global:VirtualMachine = Set-AzureRmVMSourceImage -VM $VirtualMachine -PublisherName $Publisher -Offer $offer -Skus $Skus -Version $version
}
Function MakeImagePlanInfo_Oracle_StdDB {
param(
[string]$Publisher = 'Oracle',
[string]$offer = 'Oracle-database-Se',
[string]$Skus = '12.1.0.2',
[string]$version = 'latest',
[string]$Product = '12.1.0.2',
[string]$name = 'Oracle-database-Se'
)
Write-Host "Image Creation in Process - Plan Info - Oracle Standard Edition" -ForegroundColor White
Write-Host 'Publisher:'$Publisher 'Offer:'$offer 'Sku:'$Skus 'Version:'$version
$global:VirtualMachine= Set-AzureRmVMPlan -VM $VirtualMachine -Name $name -Publisher $Publisher -Product $Product
$global:VirtualMachine = Set-AzureRmVMOperatingSystem -VM $VirtualMachine -linux -ComputerName $VMName -Credential $Credential1
$global:VirtualMachine = Set-AzureRmVMSourceImage -VM $VirtualMachine -PublisherName $Publisher -Offer $offer -Skus $Skus -Version $version
}
Function MakeImagePlanInfo_SAP_ase {
param(
[string]$Publisher = 'sap',
[string]$offer = 'ase',
[string]$Skus = 'ase_hourly',
[string]$version = 'latest',
[string]$Product = 'ase_hourly',
[string]$name = 'ase'
)
Write-Host "Image Creation in Process - Plan Info - SAP - ASE" -ForegroundColor White
Write-Host 'Publisher:'$Publisher 'Offer:'$offer 'Sku:'$Skus 'Version:'$version
$global:VirtualMachine= Set-AzureRmVMPlan -VM $VirtualMachine -Name $name -Publisher $Publisher -Product $Product
$global:VirtualMachine = Set-AzureRmVMOperatingSystem -VM $VirtualMachine -linux -ComputerName $VMName -Credential $Credential1
$global:VirtualMachine = Set-AzureRmVMSourceImage -VM $VirtualMachine -PublisherName $Publisher -Offer $offer -Skus $Skus -Version $version
}

Function MakeImagePlanInfo_puppet_puppetent {
param(
[string]$Publisher = 'puppetLabs',
[string]$offer = 'PuppetEnterprise',
[string]$Skus = '3.7',
[string]$version = 'latest',
[string]$Product = '3.7',
[string]$name = 'PuppetEnterprise'
)
Write-Host "Image Creation in Process - Plan Info - Puppet Enterprise" -ForegroundColor White
Write-Host 'Publisher:'$Publisher 'Offer:'$offer 'Sku:'$Skus 'Version:'$version
$global:VirtualMachine= Set-AzureRmVMPlan -VM $VirtualMachine -Name $name -Publisher $Publisher -Product $Product
$global:VirtualMachine = Set-AzureRmVMOperatingSystem -VM $VirtualMachine -linux -ComputerName $VMName -Credential $Credential1
$global:VirtualMachine = Set-AzureRmVMSourceImage -VM $VirtualMachine -PublisherName $Publisher -Offer $offer -Skus $Skus -Version $version
}
Function MakeImagePlanInfo_splunk {
param(
[string]$Publisher = 'Splunk',
[string]$offer = 'splunk-enterprise-base-image',
[string]$Skus = 'splunk-on-ubuntu-14-04-lts',
[string]$version = 'latest',
[string]$Product = 'splunk-on-ubuntu-14-04-lts',
[string]$name = 'splunk-enterprise-base-image'
)
Write-Host "Image Creation in Process - Plan Info - Puppet Enterprise" -ForegroundColor White
Write-Host 'Publisher:'$Publisher 'Offer:'$offer 'Sku:'$Skus 'Version:'$version
$global:VirtualMachine= Set-AzureRmVMPlan -VM $VirtualMachine -Name $name -Publisher $Publisher -Product $Product
$global:VirtualMachine = Set-AzureRmVMOperatingSystem -VM $VirtualMachine -linux -ComputerName $VMName -Credential $Credential1
$global:VirtualMachine = Set-AzureRmVMSourceImage -VM $VirtualMachine -PublisherName $Publisher -Offer $offer -Skus $Skus -Version $version
}
Function MakeImagePlanInfo_SolarWinds {
param(
[string]$Publisher = 'solarwinds',
[string]$offer = 'solarwinds-database-performance-analyzer',
[string]$Skus = 'dpa-byol',
[string]$version = 'latest',
[string]$Product = 'solarwinds-database-performance-analyzer',
[string]$name = 'dpa-byol'
)
Write-Host "Image Creation in Process - Plan Info - SolarWinds" -ForegroundColor White
Write-Host 'Publisher:'$Publisher 'Offer:'$offer 'Sku:'$Skus 'Version:'$version
$global:VirtualMachine= Set-AzureRmVMPlan -VM $VirtualMachine -Name $name -Publisher $Publisher -Product $Product
$global:VirtualMachine = Set-AzureRmVMOperatingSystem -VM $VirtualMachine -linux -ComputerName $VMName -Credential $Credential1
$global:VirtualMachine = Set-AzureRmVMSourceImage -VM $VirtualMachine -PublisherName $Publisher -Offer $offer -Skus $Skus -Version $version
}

Function MakeImagePlanInfo_Barracuda_ng_firewall_hourly {
param(
[string]$Publisher = 'Barracudanetworks',
[string]$offer = 'barracuda-ng-firewall',
[string]$Skus = 'hourly',
[string]$version = 'latest',
[string]$Product = 'barracuda-ng-firewall',
[string]$name = 'hourly'
)
Write-Host "Image Creation in Process - Plan Info - Barracuda Firewall " -ForegroundColor White
Write-Host 'Publisher:'$Publisher 'Offer:'$offer 'Sku:'$Skus 'Version:'$version
$global:VirtualMachine= Set-AzureRmVMPlan -VM $VirtualMachine -Name $name -Publisher $Publisher -Product $Product
$global:VirtualMachine = Set-AzureRmVMOperatingSystem -VM $VirtualMachine -linux -ComputerName $VMName -Credential $Credential1
$global:VirtualMachine = Set-AzureRmVMSourceImage -VM $VirtualMachine -PublisherName $Publisher -Offer $offer -Skus $Skus -Version $version
}

Function MakeImagePlanInfo_Barracuda_ng_firewall_byol {
param(
[string]$Publisher = 'Barracudanetworks',
[string]$offer = 'barracuda-ng-firewall',
[string]$Skus = 'byol',
[string]$version = 'latest',
[string]$Product = 'barracuda-ng-firewall',
[string]$name = 'byol'
)
Write-Host "Image Creation in Process - Plan Info - Barracuda NG Firewall " -ForegroundColor White
Write-Host 'Publisher:'$Publisher 'Offer:'$offer 'Sku:'$Skus 'Version:'$version
$global:VirtualMachine= Set-AzureRmVMPlan -VM $VirtualMachine -Name $name -Publisher $Publisher -Product $Product
$global:VirtualMachine = Set-AzureRmVMOperatingSystem -VM $VirtualMachine -linux -ComputerName $VMName -Credential $Credential1
$global:VirtualMachine = Set-AzureRmVMSourceImage -VM $VirtualMachine -PublisherName $Publisher -Offer $offer -Skus $Skus -Version $version
}

Function MakeImagePlanInfo_Barracuda_spam_firewall_byol {
param(
[string]$Publisher = 'Barracudanetworks',
[string]$offer = 'barracuda-spam-firewall',
[string]$Skus = 'byol',
[string]$version = 'latest',
[string]$Product = 'barracuda-spam-firewall',
[string]$name = 'byol'
)
Write-Host "Image Creation in Process - Plan Info - Barracuda SPAM Firewall " -ForegroundColor White
Write-Host 'Publisher:'$Publisher 'Offer:'$offer 'Sku:'$Skus 'Version:'$version
$global:VirtualMachine= Set-AzureRmVMPlan -VM $VirtualMachine -Name $name -Publisher $Publisher -Product $Product
$global:VirtualMachine = Set-AzureRmVMOperatingSystem -VM $VirtualMachine -linux -ComputerName $VMName -Credential $Credential1
$global:VirtualMachine = Set-AzureRmVMSourceImage -VM $VirtualMachine -PublisherName $Publisher -Offer $offer -Skus $Skus -Version $version
}

Function MakeImagePlanInfo_Barracuda_spam_firewall_hours {
param(
[string]$Publisher = 'Barracudanetworks',
[string]$offer = 'barracuda-spam-firewall',
[string]$Skus = 'hourly',
[string]$version = 'latest',
[string]$Product = 'barracuda-spam-firewall',
[string]$name = 'hourly'
)
Write-Host "Image Creation in Process - Plan Info - Barracuda SPAM Firewall " -ForegroundColor White
Write-Host 'Publisher:'$Publisher 'Offer:'$offer 'Sku:'$Skus 'Version:'$version
$global:VirtualMachine= Set-AzureRmVMPlan -VM $VirtualMachine -Name $name -Publisher $Publisher -Product $Product
$global:VirtualMachine = Set-AzureRmVMOperatingSystem -VM $VirtualMachine -linux -ComputerName $VMName -Credential $Credential1
$global:VirtualMachine = Set-AzureRmVMSourceImage -VM $VirtualMachine -PublisherName $Publisher -Offer $offer -Skus $Skus -Version $version
}

Function MakeImagePlanInfo_f5_bigip_good_byol {
param(
[string]$Publisher = 'F5-networks',
[string]$offer = 'f5-big-ip',
[string]$Skus = 'f5-bigip-virtual-edition-good-byol',
[string]$version = 'latest',
[string]$Product = 'f5-big-ip',
[string]$name = 'f5-bigip-virtual-edition-good-byol'
)
Write-Host "Image Creation in Process - Plan Info - F5 BIG IP - BYOL" -ForegroundColor White
Write-Host 'Publisher:'$Publisher 'Offer:'$offer 'Sku:'$Skus 'Version:'$version
$global:VirtualMachine= Set-AzureRmVMPlan -VM $VirtualMachine -Name $name -Publisher $Publisher -Product $Product
$global:VirtualMachine = Set-AzureRmVMOperatingSystem -VM $VirtualMachine -linux -ComputerName $VMName -Credential $Credential1
$global:VirtualMachine = Set-AzureRmVMSourceImage -VM $VirtualMachine -PublisherName $Publisher -Offer $offer -Skus $Skus -Version $version
}

Function MakeImagePlanInfo_f5_webappfire_byol {
param(
[string]$Publisher = 'F5-networks',
[string]$offer = 'f5-web-application-firewall',
[string]$Skus = 'f5-waf-solution-byol',
[string]$version = 'latest',
[string]$Product = 'f5-web-application-firewall',
[string]$name = 'f5-waf-solution-byol'
)
Write-Host "Image Creation in Process - Plan Info - F5 WebApp Firewall- BYOL" -ForegroundColor White
Write-Host 'Publisher:'$Publisher 'Offer:'$offer 'Sku:'$Skus 'Version:'$version
$global:VirtualMachine= Set-AzureRmVMPlan -VM $VirtualMachine -Name $name -Publisher $Publisher -Product $Product
$global:VirtualMachine = Set-AzureRmVMOperatingSystem -VM $VirtualMachine -linux -ComputerName $VMName -Credential $Credential1
$global:VirtualMachine = Set-AzureRmVMSourceImage -VM $VirtualMachine -PublisherName $Publisher -Offer $offer -Skus $Skus -Version $version
}

Function MakeImagePlanInfo_Pfsense {
param(
[string]$Publisher = 'netgate',
[string]$offer = 'netgate-pfsense-appliance',
[string]$Skus = 'pfsense-router-fw-vpn-225',
[string]$version = 'latest',
[string]$Product = 'netgate-pfsense-appliance',
[string]$name = 'pfsense-router-fw-vpn-225'
)
Write-Host "Image Creation in Process - Plan Info - Pfsense" -ForegroundColor White
Write-Host 'Publisher:'$Publisher 'Offer:'$offer 'Sku:'$Skus 'Version:'$version
$global:VirtualMachine= Set-AzureRmVMPlan -VM $VirtualMachine -Name $name -Publisher $Publisher -Product $Product
$global:VirtualMachine = Set-AzureRmVMOperatingSystem -VM $VirtualMachine -linux -ComputerName $VMName -Credential $Credential1
$global:VirtualMachine = Set-AzureRmVMSourceImage -VM $VirtualMachine -PublisherName $Publisher -Offer $offer -Skus $Skus -Version $version
}

Function MakeImagePlanInfo_Checkpoint {
param(
[string]$Publisher = 'checkpoint',
[string]$offer = 'check-point-r77-10',
[string]$Skus = 'sg-ngtp',
[string]$version = 'latest',
[string]$Product = 'check-point-r77-10',
[string]$name = 'sg-ngtp'
)
Write-Host "Image Creation in Process - Plan Info - Checkpoint" -ForegroundColor White
Write-Host 'Publisher:'$Publisher 'Offer:'$offer 'Sku:'$Skus 'Version:'$version
$global:VirtualMachine = Set-AzureRmVMPlan -VM $VirtualMachine -Name $name -Publisher $Publisher -Product $Product
$global:VirtualMachine = Set-AzureRmVMOperatingSystem -VM $VirtualMachine -linux -ComputerName $VMName -Credential $Credential1
$global:VirtualMachine = Set-AzureRmVMSourceImage -VM $VirtualMachine -PublisherName $Publisher -Offer $offer -Skus $Skus -Version $version
}

Function MakeImageNoPlanInfo_RedHat67 {
param(
[string]$Publisher = "Redhat",
[string]$offer = "rhel",
[string]$Skus = "6.7",
[string]$version = "latest"
)
Write-Host "Image Creation in Process - No Plan Info - RedHat 6.7" -ForegroundColor White
Write-Host 'Publisher:'$Publisher 'Offer:'$offer 'Sku:'$Skus 'Version:'$version
$global:VirtualMachine = Set-AzureRmVMOperatingSystem -VM $VirtualMachine -linux -ComputerName $VMName -Credential $Credential1
$global:VirtualMachine = Set-AzureRmVMSourceImage -VM $VirtualMachine -PublisherName $Publisher -Offer $offer -Skus $Skus -Version $version
}

Function MakeImageNoPlanInfo_RedHat72 {
param(
[string]$Publisher = "Redhat",
[string]$offer = "rhel",
[string]$Skus = "7.2",
[string]$version = "latest"
)
Write-Host "Image Creation in Process - No Plan Info - Redhat 7.2" -ForegroundColor White
Write-Host 'Publisher:'$Publisher 'Offer:'$offer 'Sku:'$Skus 'Version:'$version
$global:VirtualMachine = Set-AzureRmVMOperatingSystem -VM $VirtualMachine -linux -ComputerName $VMName -Credential $Credential1
$global:VirtualMachine = Set-AzureRmVMSourceImage -VM $VirtualMachine -PublisherName $Publisher -Offer $offer -Skus $Skus -Version $version
}

Function MakeImageNoPlanInfo_FreeBsd {
param(
[string]$Publisher = "MicrosoftOSTC",
[string]$offer = "FreeBSD",
[string]$Skus = "10.3",
[string]$version = "latest"
)
Write-Host "Image Creation in Process - No Plan Info - FreeBsd" -ForegroundColor White
Write-Host 'Publisher:'$Publisher 'Offer:'$offer 'Sku:'$Skus 'Version:'$version
$global:VirtualMachine = Set-AzureRmVMOperatingSystem -VM $VirtualMachine -linux -ComputerName $VMName -Credential $Credential1
$global:VirtualMachine = Set-AzureRmVMSourceImage -VM $VirtualMachine -PublisherName $Publisher -Offer $offer -Skus $Skus -Version $version
}

Function MakeImageNoPlanInfo_CentOs {
param(
[string]$Publisher = "OpenLogic",
[string]$offer = "Centos",
[string]$Skus = "7.2",
[string]$version = "latest"

)
Write-Host "Image Creation in Process - No Plan Info - CentOs" -ForegroundColor White
Write-Host 'Publisher:'$Publisher 'Offer:'$offer 'Sku:'$Skus 'Version:'$version
$global:VirtualMachine = Set-AzureRmVMOperatingSystem -VM $VirtualMachine -linux -ComputerName $VMName -Credential $Credential1
$global:VirtualMachine = Set-AzureRmVMSourceImage -VM $VirtualMachine -PublisherName $Publisher -Offer $offer -Skus $Skus -Version $version
}

Function MakeImageNoPlanInfo_Suse {
param(
[string]$Publisher = "Suse",
[string]$offer = "openSUSE",
[string]$Skus = "13.2",
[string]$version = "latest"

)
Write-Host "Image Creation in Process - No Plan Info - SUSE" -ForegroundColor White
Write-Host 'Publisher:'$Publisher 'Offer:'$offer 'Sku:'$Skus 'Version:'$version
$global:VirtualMachine = Set-AzureRmVMOperatingSystem -VM $VirtualMachine -linux -ComputerName $VMName -Credential $Credential1
$global:VirtualMachine = Set-AzureRmVMSourceImage -VM $VirtualMachine -PublisherName $Publisher -Offer $offer -Skus $Skus -Version $version
}

Function MakeImageNoPlanInfo_Ubuntu {
param(
[string]$Publisher = "Canonical",
[string]$offer = "UbuntuServer",
[string]$Skus = "14.04.4-LTS",
[string]$version = "latest"

)
Write-Host "Image Creation in Process - No Plan Info - Ubuntu" -ForegroundColor White
Write-Host 'Publisher:'$Publisher 'Offer:'$offer 'Sku:'$Skus 'Version:'$version
$global:VirtualMachine = Set-AzureRmVMOperatingSystem -VM $VirtualMachine -linux -ComputerName $VMName -Credential $Credential1
$global:VirtualMachine = Set-AzureRmVMSourceImage -VM $VirtualMachine -PublisherName $Publisher -Offer $offer -Skus $Skus -Version $version
}

Function MakeImagePlanInfo_Chef {
param(
[string]$Publisher = 'chef-software',
[string]$offer = 'chef-server',
[string]$Skus = 'azure_marketplace_100',
[string]$version = 'latest',
[string]$Product = 'chef-server',
[string]$name = 'azure_marketplace_100'
)
Write-Host "Image Creation in Process - Plan Info - Chef" -ForegroundColor White
Write-Host 'Publisher:'$Publisher 'Offer:'$offer 'Sku:'$Skus 'Version:'$version
$global:VirtualMachine = Set-AzureRmVMPlan -VM $VirtualMachine -Name $name -Publisher $Publisher -Product $Product
$global:VirtualMachine = Set-AzureRmVMOperatingSystem -VM $VirtualMachine -linux -ComputerName $VMName -Credential $Credential1
$global:VirtualMachine = Set-AzureRmVMSourceImage -VM $VirtualMachine -PublisherName $Publisher -Offer $offer -Skus $Skus -Version $version
}

Function MakeImageNoPlanInfo_w2k12 {
param(
[string]$Publisher = "MicrosoftWindowsServer",
[string]$offer = "WindowsServer",
[string]$Skus = "2012-R2-Datacenter",
[string]$version = "latest"
)
Write-Host "Image Creation in Process - No Plan Info - W2k12 server" -ForegroundColor White
Write-Host 'Publisher:'$Publisher 'Offer:'$offer 'Sku:'$Skus 'Version:'$version
$global:VirtualMachine = Set-AzureRmVMOperatingSystem -VM $VirtualMachine -Windows -ComputerName $VMName -Credential $Credential1 -ProvisionVMAgent -EnableAutoUpdate -WinRMHttp -Verbose
$global:VirtualMachine = Set-AzureRmVMSourceImage -VM $VirtualMachine -PublisherName $Publisher -Offer $offer -Skus $Skus -Version $version
}

Function MakeImageNoPlanInfo_w2k8 {
param(
[string]$Publisher = "MicrosoftWindowsServer",
[string]$offer = "WindowsServer",
[string]$Skus = "2008-R2-SP1",
[string]$version = "latest"
)
Write-Host "Image Creation in Process - No Plan Info - W2k8 server" -ForegroundColor White
Write-Host 'Publisher:'$Publisher 'Offer:'$offer 'Sku:'$Skus 'Version:'$version
$global:VirtualMachine = Set-AzureRmVMOperatingSystem -VM $VirtualMachine -Windows -ComputerName $VMName -Credential $Credential1 -ProvisionVMAgent -EnableAutoUpdate -WinRMHttp -Verbose
$global:VirtualMachine = Set-AzureRmVMSourceImage -VM $VirtualMachine -PublisherName $Publisher -Offer $offer -Skus $Skus -Version $version
}

Function MakeImageNoPlanInfo_SharePoint2k13 {
param(
[string]$Publisher = "MicrosoftSharePoint",
[string]$offer = "MicrosoftSharePointServer",
[string]$Skus = "2013",
[string]$version = "latest"
)
Write-Host "Image Creation in Process - No Plan Info - SharePoint 2013 server" -ForegroundColor White
Write-Host 'Publisher:'$Publisher 'Offer:'$offer 'Sku:'$Skus 'Version:'$version
$global:VirtualMachine = Set-AzureRmVMOperatingSystem -VM $VirtualMachine -Windows -ComputerName $VMName -Credential $Credential1 -ProvisionVMAgent -EnableAutoUpdate -WinRMHttp -Verbose
$global:VirtualMachine = Set-AzureRmVMSourceImage -VM $VirtualMachine -PublisherName $Publisher -Offer $offer -Skus $Skus -Version $version
}

Function MakeImageNoPlanInfo_SharePoint2k16 {
param(
[string]$Publisher = "MicrosoftSharePoint",
[string]$offer = "MicrosoftSharePointServer",
[string]$Skus = "2016",
[string]$version = "latest"
)
Write-Host "Image Creation in Process - No Plan Info - SharePoint 2016 server" -ForegroundColor White
Write-Host 'Publisher:'$Publisher 'Offer:'$offer 'Sku:'$Skus 'Version:'$version
$global:VirtualMachine = Set-AzureRmVMOperatingSystem -VM $VirtualMachine -Windows -ComputerName $VMName -Credential $Credential1 -ProvisionVMAgent -EnableAutoUpdate -WinRMHttp -Verbose
$global:VirtualMachine = Set-AzureRmVMSourceImage -VM $VirtualMachine -PublisherName $Publisher -Offer $offer -Skus $Skus -Version $version
}

Function MakeImageNoPlanInfo_w2k16 {
param(
[string]$Publisher = "MicrosoftWindowsServer",
[string]$offer = "WindowsServer",
[string]$Skus = "Windows-Server-Technical-Preview",
[string]$version = "latest"
)
Write-Host "Image Creation in Process - No Plan Info - W2k16 server" -ForegroundColor White
Write-Host 'Publisher:'$Publisher 'Offer:'$offer 'Sku:'$Skus 'Version:'$version
$global:VirtualMachine = Set-AzureRmVMOperatingSystem -VM $VirtualMachine -Windows -ComputerName $VMName -Credential $Credential1 -ProvisionVMAgent -EnableAutoUpdate -WinRMHttp -Verbose
$global:VirtualMachine = Set-AzureRmVMSourceImage -VM $VirtualMachine -PublisherName $Publisher -Offer $offer -Skus $Skus -Version $version
}

Function MakeImageNoPlanInfo_sql2k16 {
param(
[string]$Publisher = "MicrosoftSQLServer",
[string]$offer = "SQL2016-WS2012R2",
[string]$Skus = "Enterprise",
[string]$version = "latest"
)
Write-Host "Image Creation in Process - No Plan Info - SQL 2016" -ForegroundColor White
Write-Host $Publisher $offer $Skus $version
$global:VirtualMachine = Set-AzureRmVMOperatingSystem -VM $VirtualMachine -Windows -ComputerName $VMName -Credential $Credential1 -ProvisionVMAgent -EnableAutoUpdate -WinRMHttp -Verbose
$global:VirtualMachine = Set-AzureRmVMSourceImage -VM $VirtualMachine -PublisherName $Publisher -Offer $offer -Skus $Skus -Version $version
}

Function ProvisionNet {
Write-Host "Network Preparation in Process.."
$subnet1 = New-AzureRmVirtualNetworkSubnetConfig -AddressPrefix 10.120.0.0/25 -Name gatewaysubnet
$subnet2 = New-AzureRmVirtualNetworkSubnetConfig -AddressPrefix 10.120.0.128/25 -Name perimeter
$subnet3 = New-AzureRmVirtualNetworkSubnetConfig -AddressPrefix 10.120.1.0/24 -Name web
$subnet4 = New-AzureRmVirtualNetworkSubnetConfig -AddressPrefix 10.120.2.0/24 -Name intake
$subnet5 = New-AzureRmVirtualNetworkSubnetConfig -AddressPrefix 10.120.3.0/24 -Name data
$subnet6 = New-AzureRmVirtualNetworkSubnetConfig -AddressPrefix 10.120.4.0/24 -Name monitoring
$subnet7 = New-AzureRmVirtualNetworkSubnetConfig -AddressPrefix 10.120.5.0/24 -Name analytics
$subnet8 = New-AzureRmVirtualNetworkSubnetConfig -AddressPrefix 10.120.6.0/24 -Name backup
$subnet9 = New-AzureRmVirtualNetworkSubnetConfig -AddressPrefix 10.120.7.0/24 -Name management
New-AzureRmVirtualNetwork -Location $Location -Name $VNetName -ResourceGroupName $vNetResourceGroupName -AddressPrefix '10.120.0.0/21' -Subnet $subnet1,$subnet2,$subnet3,$subnet4,$subnet5,$subnet6,$subnet7,$subnet8,$subnet9 –Confirm:$false -WarningAction SilentlyContinue -Force | Out-Null
Get-AzureRmVirtualNetwork -Name $VNetName -ResourceGroupName $vNetResourceGroupName | Get-AzureRmVirtualNetworkSubnetConfig -WarningAction SilentlyContinue | Out-Null
Write-Host "Network Preparation completed" -ForegroundColor White
$LogOut = "Completed Network Configuration of $VNetName"
Log-Command -Description $LogOut -LogFile $LogOutFile
}

# End of Provision VNET Function
Function CreateNSG {
Write-Host "Network Security Group Preparation in Process.."
$httprule = New-AzureRmNetworkSecurityRuleConfig -Name "FrontEnd_HTTP" -Description "HTTP Exception for Web frontends" -Protocol Tcp -SourcePortRange "80" -DestinationPortRange "80" -SourceAddressPrefix "*" -DestinationAddressPrefix "10.120.0.0/21" -Access Allow -Direction Inbound -Priority 200
$httpsrule = New-AzureRmNetworkSecurityRuleConfig -Name "FrontEnd_HTTPS" -Description "HTTPS Exception for Web frontends" -Protocol Tcp -SourcePortRange "443" -DestinationPortRange "443" -SourceAddressPrefix "*" -DestinationAddressPrefix "10.120.0.0/21" -Access Allow -Direction Inbound -Priority 201
$sshrule = New-AzureRmNetworkSecurityRuleConfig -Name "FrontEnd_SSH" -Description "SSH Exception for Web frontends" -Protocol Tcp -SourcePortRange "22" -DestinationPortRange "22" -SourceAddressPrefix "*" -DestinationAddressPrefix "10.120.0.0/21" -Access Allow -Direction Inbound ` -Priority 203
$nsg = New-AzureRmNetworkSecurityGroup -ResourceGroupName $vNetResourceGroupName -Location $Location -Name $NSGName -SecurityRules $httprule,$httpsrule, $sshrule –Confirm:$false -WarningAction SilentlyContinue -Force | Out-Null
Get-AzureRmNetworkSecurityGroup -Name $NSGName -ResourceGroupName $vNetResourceGroupName -WarningAction SilentlyContinue | Out-Null
Write-Host "Network Security Group configuration completed" -ForegroundColor White
$LogOut = "Security Rules added for $NSGName"
$secrules =Get-AzureRmNetworkSecurityGroup -Name $NSGName -ResourceGroupName $vNetResourceGroupName -ExpandResource NetworkInterfaces | Get-AzureRmNetworkSecurityRuleConfig | Ft Name,Description,Direction,SourcePortRange,DestinationPortRange,DestinationPortRange,SourceAddressPrefix,Access
$defsecrules = Get-AzureRmNetworkSecurityGroup -Name $NSGName -ResourceGroupName $vNetResourceGroupName -ExpandResource NetworkInterfaces | Get-AzureRmNetworkSecurityRuleConfig -DefaultRules | Ft Name,Description,Direction,SourcePortRange,DestinationPortRange,DestinationAddressPrefix,SourceAddressPrefix,Access
Log-Command -Description $LogOut -LogFile $LogOutFile
$LogOut = "Completed NSG Configuration of $NSGName"
Log-Command -Description $LogOut -LogFile $LogOutFile
}
# End of Provision Network Security Groups Function

Function SubnetMatch {
	Param(
		[INT]$Subnet
	)
switch ($Subnet)
{
0 {Write-Host "Deploying to Subnet 10.120.0.0/25"}
1 {Write-Host "Deploying to Subnet 10.120.1.128/25"}
2 {Write-Host "Deploying to Subnet 10.120.1.0/24"}
3 {Write-Host "Deploying to Subnet 10.120.2.0/24"}
4 {Write-Host "Deploying to Subnet 10.120.3.0/24"}
5 {Write-Host "Deploying to Subnet 10.120.4.0/24"}
6 {Write-Host "Deploying to Subnet 10.120.5.0/24"}
7 {Write-Host "Deploying to Subnet 10.120.6.0/24"}
8 {Write-Host "Deploying to Subnet 10.120.7.0/24"}
9 {Write-Host "Deploying to Subnet 10.120.8.0/24"}
default {No Subnet Found}
}
}

Function WriteConfig {
Write-Host "                                                               "
$time = " Start Time " + (Get-Date -UFormat "%d-%m-%Y %H:%M:%S")
Write-Host -------------- $time --------------- -ForegroundColor Cyan
Write-Host "Using configuration:"

Write-Host "VM Name: $VMName " -ForegroundColor White
Write-Host "Resource Group Name: $ResourceGroupName"
Write-Host "Server Type: $vmMarketImage"
Write-Host "VNET Name: $vNetName"
Write-Host "VNET Resource Group Name: $vNetResourceGroupName"
Write-Host "Storage Account Name:  $StorageName"
SelectNicDescrtipt
If ($ConfigIPs -eq "StatPvtNoPubSingle")
{ Write-Host "Public Ip Will not be created" -ForegroundColor White
Write-Host "Nic1: $PvtIPNic1"
SubnetMatch $Subnet1
}
If ($ConfigIPs -eq "StatPvtNoPubDual")
{ Write-Host "Public Ip Will not be created" -ForegroundColor White
Write-Host "Nic1: $PvtIPNic1"
Write-Host "Nic2: $PvtIPNic2"
SubnetMatch $Subnet1
SubnetMatch $Subnet2
}
If ($ConfigIPs -eq "Single")
{ Write-Host "Public Ip Will be created"
SubnetMatch $Subnet1
}

If ($ConfigIPs -eq "Dual")
{ Write-Host "Public Ip Will be created"
SubnetMatch $Subnet1
SubnetMatch $Subnet2
}
If ($ConfigIPs -eq "PvtSingleStat")
{ Write-Host "Public Ip Will be created"
SubnetMatch $Subnet1
Write-Host "Nic1: $PvtIPNic1"
}
If ($ConfigIPs -eq "PvtDualStat")
{ Write-Host "Public Ip Will be created"
SubnetMatch $Subnet1
SubnetMatch $Subnet2
Write-Host "Nic1: $PvtIPNic1"
Write-Host "Nic2: $PvtIPNic2"
}
if($AzExtConfig) {
Write-Host "Extension selected for deployment: $AzExtConfig "
}
if($AddAvailabilitySet) {
Write-Host "Availability Set to 'True'"
Write-Host "Availability Set Name:  '$AvailSetName'"
Write-Host "                                                               "
Write-Host "--------------------------------------------------------------" -ForegroundColor Cyan
Write-Host "                                                               "
}
else
{
Write-Host "Availability Set to 'False'" -ForegroundColor White
Write-Host "--------------------------------------------------------------" -ForegroundColor Cyan
Write-Host "                                                               "
}
}

Function WriteResults {
Write-Host "                                                               "
Write-Host "--------------------------------------------------------------" -ForegroundColor Cyan
Write-Host "                                                               "
Write-Host "Completed Deployment of:"  -ForegroundColor Cyan
Write-Host "VM Name: $VMName " -ForegroundColor White
Write-Host "Resource Group Name: $ResourceGroupName"
Write-Host "Server Type: $vmMarketImage"
Write-Host "VNET Resource Group Name: $vNetResourceGroupName" -ForegroundColor White
Write-Host "VNET Name: $VNetName" -ForegroundColor White
Write-Host "Storage Account Name:  $StorageName"

$vm = Get-AzureRmvm -ResourceGroupName $ResourceGroupName -Name $VMName
$storage = $vm.StorageProfile
$disk = $storage.OsDisk
$Name = $disk.Name
$uri = $disk.Vhd
$avset = $vm.AvailabilitySetReference
$extension = $vm.Extensions
$extcount = $extension.Count
$statuscode = $vm.StatusCode
$availsetid = $avset.Id
$name = $vm.Name
$nicids = $vm.NetworkInterfaceIDs
$nicprofile = $vm.NetworkProfile
$nicprofiles = $nicprofile.NetworkInterfaces
$niccount = $nicprofiles.Count
$osprofile = $vm.OSProfile
$localadmin = $osprofile.AdminUsername
$provstate = $vm.ProvisioningState
$datad = $vm.DataDiskNames
$datadiskcount = $datad.Count

Write-Host "Server Name:"$name
Write-Host "Local admin:" $localadmin
Write-Host "Installed Azure Extensions Count" $extcount
Write-Host "Data Disk Count:" $datadiskcount
Write-Host "Provisioning State:" $provstate
Write-Host "Status Code:" $statuscode
Write-Host "Network Adapter Count:" $niccount
Write-Host "Availability Set:"$availsetid

SelectNicDescrtipt

if($AddAvailabilitySet) {
Write-Host "Availability Set Configured"
Write-Host "Availability Set Name:  '$AvailSetName'"
$time = " Completed Time " + (Get-Date -UFormat "%d-%m-%Y %H:%M:%S")
Write-Host -------------- $time ------------- -ForegroundColor Cyan
Write-Host "                                                               "
}
else
{
$time = " Completed Time " + (Get-Date -UFormat "%d-%m-%Y %H:%M:%S")
Write-Host -------------- $time ------------- -ForegroundColor Cyan
Write-Host "                                                               "
}
}

Function EndState {
Write-Host "                                                               "
Write-Host "Private Network Interfaces for $ResourceGroupName"
$vms = get-azurermvm -ResourceGroupName $ResourceGroupName
$nics = get-azurermnetworkinterface -ResourceGroupName $ResourceGroupName | where VirtualMachine -NE $null #skip Nics with no VM
foreach($nic in $nics)
{
	$vm = $vms | where-object -Property Id -EQ $nic.VirtualMachine.id
	$prv =  $nic.IpConfigurations | select-object -ExpandProperty PrivateIpAddress
	$alloc =  $nic.IpConfigurations | select-object -ExpandProperty PrivateIpAllocationMethod
	Write-Output "$($vm.Name) : $prv , $alloc" | Format-Table
}

$pubip = Get-AzureRmPublicIpAddress -Name $InterfaceName1 -ResourceGroupName $ResourceGroupName -ErrorAction SilentlyContinue
$dns = Get-AzureRmPublicIpAddress -ExpandResource IPConfiguration -Name $InterfaceName1 -ResourceGroupName $ResourceGroupName -ErrorAction SilentlyContinue | select-object -ExpandProperty DNSSettings | select-object -ExpandProperty FQDN
if($pubip)
{
Write-Host "Public Network Interfaces for $ResourceGroupName"
Get-AzureRmPublicIpAddress -ResourceGroupName $ResourceGroupName| ft "Name","IpAddress" -Wrap
Get-AzureRmPublicIpAddress -ResourceGroupName $ResourceGroupName | select-object -ExpandProperty DNSSettings | FT FQDN -Wrap
}
ResultsRollup
Write-Host "                                                               "
}

Function ResultsRollup {
Write-Host "Storage Accounts for $ResourceGroupName" -NoNewLine
Get-AzurermStorageAccount -ResourceGroupName $ResourceGroupName -WarningAction SilentlyContinue | ft StorageAccountName,Location,ResourceGroupname -Wrap

Write-Host "Availability Sets for $ResourceGroupName"
Get-AzurermAvailabilitySet -ResourceGroupName $ResourceGroupName -WarningAction SilentlyContinue | ft Name,ResourceGroupName -Wrap
}

Function ProvisionResGrp
{
	Param(
		[string]$ResourceGroupName
	)
New-AzureRmResourceGroup -Name $resourceGroupName -Location $Location –Confirm:$false -WarningAction SilentlyContinue -Force | Out-Null
}

Function CreateStorage {
Write-Host "Starting Storage Creation.."
$Global:StorageAccount = New-AzureRmStorageAccount -ResourceGroupName $ResourceGroupName -Name $StorageName.ToLower() -Type $StorageType -Location $Location -ErrorAction Stop -WarningAction SilentlyContinue
Write-Host "Completed Storage Creation" -ForegroundColor White
$LogOut = "Storage Configuration completed: $StorageName"
Log-Command -Description $LogOut -LogFile $LogOutFile
} # Creates Storage

Function StorageNameCheck
{
$checkname = Get-AzureRmStorageAccountNameAvailability -Name $StorageName | ft NameAvailable -HideTableHeaders
if($checkname -eq "True") {
CheckOrphns
}
else
{Write-Host "Storage Account Name in use, please choose a different name for your storage account"
Start-Sleep 5
exit
}
}

Function ImageConfig {
switch -Wildcard ($vmMarketImage)
	{
		"*pfsense*" {
			CreateStorage
			AvailSet
			ConfigNet  #Sets network connection info
			MakeImagePlanInfo_Pfsense # Begins Image Creation
			ConfigSet # Adds Network Interfaces
			AddDiskImage # Completes Image Creation
			Provvms
}
		"*free*" {
			CreateStorage
			AvailSet
			ConfigNet  #Sets network connection info
			MakeImageNoPlanInfo_FreeBsd  # Begins Image Creation
			ConfigSet # Adds Network Interfaces
			AddDiskImage # Completes Image Creation
			Provvms
}
		"*red72*" {
			CreateStorage
			AvailSet
			ConfigNet  #Sets network connection info
			MakeImageNoPlanInfo_RedHat72  # Begins Image Creation
			ConfigSet # Adds Network Interfaces
			AddDiskImage # Completes Image Creation
			Provvms
}
		"*red67*" {
			CreateStorage
			AvailSet
			ConfigNet  #Sets network connection info
			MakeImageNoPlanInfo_RedHat67  # Begins Image Creation
			ConfigSet # Adds Network Interfaces
			AddDiskImage # Completes Image Creation
			Provvms
}
		"*w2k12*" {
			CreateStorage
			AvailSet
			ConfigNet  #Sets network connection info
			MakeImageNoPlanInfo_w2k12  # Begins Image Creation
			ConfigSet # Adds Network Interfaces
			AddDiskImage # Completes Image Creation
			Provvms
}
		"*sql2016*" {
			CreateStorage
			AvailSet
			ConfigNet  #Sets network connection info
			MakeImageNoPlanInfo_sql2k16  # Begins Image Creation
			ConfigSet # Adds Network Interfaces
			AddDiskImage # Completes Image Creation
			Provvms
}
		"*check*" {
			CreateStorage
			AvailSet
			ConfigNet  #Sets network connection info
			MakeImagePlanInfo_Checkpoint  # Begins Image Creation
			ConfigSet # Adds Network Interfaces
			AddDiskImage # Completes Image Creation
			Provvms
}
		"*cent*" {
			CreateStorage
			AvailSet
			ConfigNet  #Sets network connection info
			MakeImageNoPlanInfo_CentOs  # Begins Image Creation
			ConfigSet # Adds Network Interfaces
			AddDiskImage # Completes Image Creation
			Provvms
}
		"*Suse*" {
			CreateStorage
			AvailSet
			ConfigNet  #Sets network connection info
			MakeImageNoPlanInfo_Suse  # Begins Image Creation
			ConfigSet # Adds Network Interfaces
			AddDiskImage # Completes Image Creation
			Provvms
}
		"*w2k8*" {
			CreateStorage
			AvailSet
			ConfigNet  #Sets network connection info
			MakeImageNoPlanInfo_w2k8  # Begins Image Creation
			ConfigSet # Adds Network Interfaces
			AddDiskImage # Completes Image Creation
			Provvms
}
		"*w2k16*" {
			CreateStorage
			AvailSet
			ConfigNet  #Sets network connection info
			MakeImageNoPlanInfo_w2k16  # Begins Image Creation
			ConfigSet # Adds Network Interfaces
			AddDiskImage # Completes Image Creation
			Provvms
}
		"*chef*" {
			CreateStorage
			AvailSet
			ConfigNet  #Sets network connection info
			MakeImagePlanInfo_Chef  # Begins Image Creation
			ConfigSet # Adds Network Interfaces
			AddDiskImage # Completes Image Creation
			Provvms
}
		"*lamp*" {
			CreateStorage
			AvailSet
			ConfigNet  #Sets network connection info
			MakeImagePlanInfo_Bitnami_Lamp # Begins Image Creation
			ConfigSet # Adds Network Interfaces
			AddDiskImage # Completes Image Creation
			Provvms
}
		"*mongodb*" {
			CreateStorage
			AvailSet
			ConfigNet  #Sets network connection info
			MakeImagePlanInfo_Bitnami_mongodb # Begins Image Creation
			ConfigSet # Adds Network Interfaces
			AddDiskImage # Completes Image Creation
			Provvms
}
		"*mysql*" {
			CreateStorage
			AvailSet
			ConfigNet  #Sets network connection info
			MakeImagePlanInfo_Bitnami_mysql # Begins Image Creation
			ConfigSet # Adds Network Interfaces
			AddDiskImage # Completes Image Creation
			Provvms
}
		"*elastics*" {
			CreateStorage
			AvailSet
			ConfigNet  #Sets network connection info
			MakeImagePlanInfo_Bitnami_elastic # Begins Image Creation
			ConfigSet # Adds Network Interfaces
			AddDiskImage # Completes Image Creation
			Provvms
}
		"*nodejs*" {
			CreateStorage
			AvailSet
			ConfigNet  #Sets network connection info
			MakeImagePlanInfo_Bitnami_nodejs # Begins Image Creation
			ConfigSet # Adds Network Interfaces
			AddDiskImage # Completes Image Creation
			Provvms
}
		"*nginxstack*" {
			CreateStorage
			AvailSet
			ConfigNet  #Sets network connection info
			MakeImagePlanInfo_Bitnami_nginxstack # Begins Image Creation
			ConfigSet # Adds Network Interfaces
			AddDiskImage # Completes Image Creation
			Provvms
}
		"*postgressql*" {
			CreateStorage
			AvailSet
			ConfigNet  #Sets network connection info
			MakeImagePlanInfo_Bitnami_postgresql # Begins Image Creation
			ConfigSet # Adds Network Interfaces
			AddDiskImage # Completes Image Creation
			Provvms
}
		"*oracle-linux*" {
			CreateStorage
			AvailSet
			ConfigNet  #Sets network connection info
			MakeImagePlanInfo_Oracle_linux # Begins Image Creation
			ConfigSet # Adds Network Interfaces
			AddDiskImage # Completes Image Creation
			Provvms
}
		"*web-logic*" {
			CreateStorage
			AvailSet
			ConfigNet  #Sets network connection info
			MakeImagePlanInfo_Oracle_weblogic # Begins Image Creation
			ConfigSet # Adds Network Interfaces
			AddDiskImage # Completes Image Creation
			Provvms
}
		"*entdb-oracle*" {
			CreateStorage
			AvailSet
			ConfigNet  #Sets network connection info
			MakeImagePlanInfo_Oracle_EntDB  # Begins Image Creation
			ConfigSet # Adds Network Interfaces
			AddDiskImage # Completes Image Creation
			Provvms
}
		"*stddb-oracle*" {
			CreateStorage
			AvailSet
			ConfigNet  #Sets network connection info
			MakeImagePlanInfo_Oracle_StdDB # Begins Image Creation
			ConfigSet # Adds Network Interfaces
			AddDiskImage # Completes Image Creation
			Provvms
}
		"*puppet*" {
			CreateStorage
			AvailSet
			ConfigNet  #Sets network connection info
			MakeImagePlanInfo_puppet_puppetent # Begins Image Creation
			ConfigSet # Adds Network Interfaces
			AddDiskImage # Completes Image Creation
			Provvms
}
		"*splunk*" {
			CreateStorage
			AvailSet
			ConfigNet  #Sets network connection info
			MakeImagePlanInfo_splunk # Begins Image Creation
			ConfigSet # Adds Network Interfaces
			AddDiskImage # Completes Image Creation
			Provvms
}
		"*share2013*" {
			CreateStorage
			AvailSet
			ConfigNet  #Sets network connection info
			MakeImageNoPlanInfo_SharePoint2k13 # Begins Image Creation
			ConfigSet # Adds Network Interfaces
			AddDiskImage # Completes Image Creation
			Provvms
}
		"*share2016*" {
			CreateStorage
			AvailSet
			ConfigNet  #Sets network connection info
			MakeImageNoPlanInfo_SharePoint2k16 # Begins Image Creation
			ConfigSet # Adds Network Interfaces
			AddDiskImage # Completes Image Creation
			Provvms
}
		"*serverr*" {
			CreateStorage
			AvailSet
			ConfigNet  #Sets network connection info
			MakeImagePlanInfo_Microsoft_Serverr # Begins Image Creation
			ConfigSet # Adds Network Interfaces
			AddDiskImage # Completes Image Creation
			Provvms
}
		"*ubuntu*" {
			CreateStorage
			AvailSet
			ConfigNet  #Sets network connection info
			MakeImageNoPlanInfo_Ubuntu # Begins Image Creation
			ConfigSet # Adds Network Interfaces
			AddDiskImage # Completes Image Creation
			Provvms
}
		"*f5bigip*" {
			CreateStorage
			AvailSet
			ConfigNet  #Sets network connection info
			MakeImagePlanInfo_f5_bigip_good_byol # Begins Image Creation
			ConfigSet # Adds Network Interfaces
			AddDiskImage # Completes Image Creation
			Provvms
}
		"*f5appfire*" {
			CreateStorage
			AvailSet
			ConfigNet  #Sets network connection info
			MakeImagePlanInfo_f5_webappfire_byol # Begins Image Creation
			ConfigSet # Adds Network Interfaces
			AddDiskImage # Completes Image Creation
			Provvms
}
		"*barrahourngfw*" {
			CreateStorage
			AvailSet
			ConfigNet  #Sets network connection info
			MakeImagePlanInfo_Barracuda_ng_firewall_hourly # Begins Image Creation
			ConfigSet # Adds Network Interfaces
			AddDiskImage # Completes Image Creation
			Provvms
}
		"*barrabyolngfw*" {
			CreateStorage
			AvailSet
			ConfigNet  #Sets network connection info
			MakeImagePlanInfo_Barracuda_ng_firewall_byol # Begins Image Creation
			ConfigSet # Adds Network Interfaces
			AddDiskImage # Completes Image Creation
			Provvms
}
		"*barrahourspam*" {
			CreateStorage
			AvailSet
			ConfigNet  #Sets network connection info
			MakeImagePlanInfo_Barracuda_spam_firewall_hourly # Begins Image Creation
			ConfigSet # Adds Network Interfaces
			AddDiskImage # Completes Image Creation
			Provvms
}
		"*barrabyolspam*" {
			CreateStorage
			AvailSet
			ConfigNet  #Sets network connection info
			MakeImagePlanInfo_Barracuda_spam_firewall_byol # Begins Image Creation
			ConfigSet # Adds Network Interfaces
			AddDiskImage # Completes Image Creation
			Provvms
}
		"*sap*" {
			CreateStorage
			AvailSet
			ConfigNet  #Sets network connection info
			MakeImagePlanInfo_SAP_ase # Begins Image Creation
			ConfigSet # Adds Network Interfaces
			AddDiskImage # Completes Image Creation
			Provvms
}
		"*solarwinds*" {
			CreateStorage
			AvailSet
			ConfigNet  #Sets network connection info
			MakeImagePlanInfo_SolarWinds # Begins Image Creation
			ConfigSet # Adds Network Interfaces
			AddDiskImage # Completes Image Creation
			Provvms
}
		"*hadoop*" {
			CreateStorage
			AvailSet
			ConfigNet  #Sets network connection info
			MakeImagePlanInfo_Bitnami_hadoop # Begins Image Creation
			ConfigSet # Adds Network Interfaces
			AddDiskImage # Completes Image Creation
			Provvms
}
		"*tomcat*" {
			CreateStorage
			AvailSet
			ConfigNet  #Sets network connection info
			MakeImagePlanInfo_Bitnami_tomcat # Begins Image Creation
			ConfigSet # Adds Network Interfaces
			AddDiskImage # Completes Image Creation
			Provvms
}
		"*redis*" {
			CreateStorage
			AvailSet
			ConfigNet  #Sets network connection info
			MakeImagePlanInfo_Bitnami_redis # Begins Image Creation
			ConfigSet # Adds Network Interfaces
			AddDiskImage # Completes Image Creation
			Provvms
}
		"*neos*" {
			CreateStorage
			AvailSet
			ConfigNet  #Sets network connection info
			MakeImagePlanInfo_Bitnami_neos # Begins Image Creation
			ConfigSet # Adds Network Interfaces
			AddDiskImage # Completes Image Creation
			Provvms
}
		"*gitlab*" {
			CreateStorage
			AvailSet
			ConfigNet  #Sets network connection info
			MakeImagePlanInfo_Bitnami_gitlab # Begins Image Creation
			ConfigSet # Adds Network Interfaces
			AddDiskImage # Completes Image Creation
			Provvms
}
		"*jruby*" {
			CreateStorage
			AvailSet
			ConfigNet  #Sets network connection info
			MakeImagePlanInfo_Bitnami_jrubystack # Begins Image Creation
			ConfigSet # Adds Network Interfaces
			AddDiskImage # Completes Image Creation
			Provvms
}
		"*jenkins*" {
			CreateStorage
			AvailSet
			ConfigNet  #Sets network connection info
			MakeImagePlanInfo_Bitnami_jenkins # Begins Image Creation
			ConfigSet # Adds Network Interfaces
			AddDiskImage # Completes Image Creation
			Provvms
}
		default{"An unsupported image was referenced"}
	}
}

Function InstallExt {
switch ($AzExtConfig)
	{
		"access" {
Write-Host "VM Access Agent VM Image Preparation in Process"
Set-AzureRmVMAccessExtension -ResourceGroupName $ResourceGroupName -VMName $VMName -Name "VMAccess" -ExtensionType "VMAccessAgent" -Publisher "Microsoft.Compute" -typeHandlerVersion "2.0" -Location $Location -Verbose
Get-AzureRmVMExtension -ResourceGroupName $ResourceGroupName -VMName $VMName -Name "VMAccess"
}
		"msav" {
Write-Host "MSAV Agent VM Image Preparation in Process"
Set-AzureRmVMExtension  -ResourceGroupName $ResourceGroupName -VMName $VMName -Name "MSAVExtension" -ExtensionType "IaaSAntimalware" -Publisher "Microsoft.Azure.Security" -typeHandlerVersion 1.4 -Location $Location
Get-AzureRmVMExtension -ResourceGroupName $ResourceGroupName -VMName $VMName -Name "MSAVExtension" -Status
}
		"custScript" {
Write-Host "Updating server with custom script"
Set-AzureRmVMCustomScriptExtension -Name "CustScript" -ResourceGroupName $ResourceGroupName -Run "CustScript.ps1" -VMName $VMName -FileUri $StorageName -Location $Location -TypeHandlerVersion "1.1"
Get-AzureRmVMCustomScriptExtension -ResourceGroupName $ResourceGroupName -Name "CustScript"
}
		"diag" {
Write-Host "Adding Azure Enhanced Diagnostics"
Set-AzureRmVMAEMExtension -ResourceGroupName $ResourceGroupName -VMName $VMName -WADStorageAccountName $StorageName -InformationAction SilentlyContinue -WarningAction SilentlyContinue | Out-Null
Get-AzureRmVMAEMExtension -ResourceGroupName $ResourceGroupName -VMName $VMName | Out-Null
}
		"domjoin" {
Write-Host "Domain Join active"
Set-AzureRmVMADDomainExtension -DomainName $DomName -ResourceGroupName $ResourceGroupName -VMName $VMName -Location $Location -Name DomJoin -WarningAction SilentlyContinue
Get-AzureRmVMADDomainExtension -ResourceGroupName $ResourceGroupName -VMName $VMName
		}
		"linuxOsPatch" {
Write-Host "Adding Azure OS Patching Linux"
Set-AzureRmVMExtension -VMName $VMName -ResourceGroupName $ResourceGroupName -Location $Location -Name "OSPatch" -ExtensionType "OSPatchingForLinux" -Publisher "Microsoft.OSTCExtensions" -typeHandlerVersion "2.0" -InformationAction SilentlyContinue -ForceRerun -Verbose
Get-AzureRmVMExtension -ResourceGroupName $ResourceGroupName -VMName $VMName -Name "OSPatch"
		}
		"linuxbackup" {
Write-Host "Adding Linux VMBackup"
Set-AzureRmVMBackupExtension -VMName $VMName -ResourceGroupName $ResourceGroupName -Location $Location -Name "VMBackup" -Tag "OSBackup" -WarningAction SilentlyContinue
Get-AzureRmVMBackupExtension -ResourceGroupName $ResourceGroupName -VMName $VMName -Name "VMBackup"
		}
		"chefAgent" {
Write-Host "Adding Chef Agent"
Set-AzureRmVMExtension -ResourceGroupName $ResourceGroupName -VMName $VMName -Name "ChefStrap" -ExtensionType "ChefClient" -Publisher "Chef.Bootstrap.WindowsAzure" -typeHandlerVersion "1210.12" -Location $Location -Verbose -ProtectedSettingString -SettingString
Get-AzureRmVMExtension -ResourceGroupName $ResourceGroupName -VMName $VMName -Name "ChefStrap"
		}
		"WinBootStChef" {
Write-Host "Bootstrapping Chef Agent"
knife bootstrap windows winrm $BootIp --winrm-user $localadmin --winrm-password $locpassword --node-name $VMName --Install-as-service
		}
		"linBootStChef" {
Write-Host "Bootstrapping Chef Agent"
knife bootstrap $BootIp --node-name $VMName --ssh-user localadmin --ssh-password $locpassword --sudo --use-sudo-password --verbose --yes
		}
		default{"An unsupported Extension command was used"
break
}
	}
} # Deploys Azure Extensions

Function OrphanChk {
$extvm = Get-AzureRmVm -Name $VMName -ResourceGroupName $ResourceGroupName -ErrorAction SilentlyContinue
$nic1 = Get-AzureRmNetworkInterface -Name $InterfaceName1 -ResourceGroupName $ResourceGroupName -ErrorAction SilentlyContinue
$nic2 = Get-AzureRmNetworkInterface -Name $InterfaceName2 -ResourceGroupName $ResourceGroupName -ErrorAction SilentlyContinue
$pubip =  Get-AzureRmPublicIpAddress -Name $InterfaceName1 -ResourceGroupName $ResourceGroupName -ErrorAction SilentlyContinue

if($extvm)
{ Write-Host "Host VM Found, please use a different VMName for Provisioning or manually delete the existing VM" -ForegroundColor Red
 Start-sleep 10
 exit   }
else {if($nic1)
{ Write-Host "Nic1 already Exists, removing orphan" -ForegroundColor DarkYellow
Remove-AzureRmNetworkInterface -Name $InterfaceName1 -ResourceGroupName $ResourceGroupName -Force -Confirm:$False
 }
	 if($pubip)
{ Write-Host "PublicIp already Exists, removing orphan" -ForegroundColor DarkYellow
				  Remove-AzureRmPublicIpAddress -Name $InterfaceName1 -ResourceGroupName $ResourceGroupName -Force -Confirm:$False
}
	 if($nic2)
{ Write-Host "Nic2 already Exists, removing orphan" -ForegroundColor DarkYellow
				  Remove-AzureRmNetworkInterface -Name $InterfaceName2 -ResourceGroupName $ResourceGroupName -Force -Confirm:$False
 }
 else {Write-Host "No Orphans Found, proceeding with deployment.." -ForegroundColor Green}
 }
# Write-Host "No Orphans Found" -ForegroundColor Green
} # Verifies no left over components will prohibit deployment of the new VM, cleans up any if the exist.

# Fuctions
Function AzureVersion{
$name='Azure'
if(Get-Module -ListAvailable |
	Where-Object { $_.name -eq $name })
{
$ver = (Get-Module -ListAvailable | Where-Object{ $_.Name -eq $name }) |
	select version -ExpandProperty version
	Write-Host "current Azure PowerShell Version:" $ver
$currentver = $ver
	if($currentver-le '1.6.0'){
	Write-Host "expected version 1.6.0 found $ver" -ForegroundColor DarkRed
	exit
	}
}
else
{
	Write-Host “The Azure PowerShell module is not installed.”
	exit
}
}
Function StorageNameCheck
{
$checkname =  Get-AzureRmStorageAccountNameAvailability -Name $StorageName | Select-Object -ExpandProperty NameAvailable
if($checkname -ne 'True') {
Write-Host "Storage Account Name in use, please choose a different name for your storage account"
Start-Sleep 5
exit
}
}

##--------------------------- Begin Script Execution -------------------------------------------------------##

Write-Output "Steps will be tracked on the log file : [ $LogOutFile ]"

chknull # Verifies required fields have data
OrphanChk # Verifies no left overs
VerifyNet # Verifies Subnet and static IP Address will work as defined
VerifyProfile # Attempts to use json file for auth, falls back on Add-AzureRmAccount
StorageNameCheck # Verifies Storage Account Name does not exist
AzureVersion # Verifies Azure client Powershell Version

$LogOut = "Completed Pre Execution Verification Checks"
Log-Command -Description $LogOut -LogFile $LogOutFile

try {
	[Microsoft.Azure.Common.Authentication.AzureSession]::ClientFactory.AddUserAgent("VSAzureTools-$UI$($host.name)".replace(" ","_"), "2.9")
} catch { }

try {
Get-AzureRmResourceGroup -Location $Location -ErrorAction Stop | Out-Null
}
catch {
	Write-Host -foregroundcolor Yellow `
	"User has not authenticated, use Add-AzureRmAccount or $($_.Exception.Message)"; `
	continue
}
 # Check if Orphans exist.

 $resourceProviders = @("microsoft.compute","microsoft.network","microsoft.storage");
 if($resourceProviders.length) {
	Write-Host "Registering resource providers"
	foreach($resourceProvider in $resourceProviders) {
		RegisterRP($resourceProvider);
	}
 } # Get Resource Providers

$resourcegroups = @($ResourceGroupName,$vNetResourceGroupName);
if($resourcegroups.length) {
	foreach($resourcegroup in $resourcegroups) {
		ProvisionResGrp($resourcegroup);
	}
	} # Create Resource Groups

$LogOut = "Resource Groups $ResourceGroupName and $vNetResourceGroupName"
Log-Command -Description $LogOut -LogFile $LogOutFile

WriteConfig

if($AddVnet){ProvisionNet} # Creates VNET

if($NSGEnabled){CreateNSG}

ImageConfig # Configure Image

$Description = "Completed Image Creation"
Log-Command -Description $Description -LogFile $LogOutFile

if($NSGEnabled){NSGEnabled} #Adds NSG to NIC

if($AzExtConfig) {InstallExt} #Installs Azure Extensions

EndState

if($AddVPN) {
CreateVPN
ConnectVPN
} #Creates VPN