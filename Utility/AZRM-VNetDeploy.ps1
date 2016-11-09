<#
.SYNOPSIS
Written By John Lewis
email: jonos@live.com
Ver 1.4

This script is intended to provide a standard deployment process for Azure RM Networking Stack Components
The script will create the log directory if they do not exist in the runtime directory, Log.
This script deploys Azure RM Networking Components via Azure PowerShell.

.DESCRIPTION
Deploys VNets, NSGs, Peer to Peer VNETs and Internal/External Load Balancers

.PARAMETER ActionType

.PARAMETER vnetrg

.PARAMETER vnet2rg

.PARAMETER AddVnet

.PARAMETER VNetName

.PARAMETER VNetName2

.PARAMETER VnetPeering

.PARAMETER CreateNSG

.PARAMETER CreateExtLoadBalancer

.PARAMETER CreateIntLoadBalancer

.PARAMETER AddLB

.PARAMETER LBType

.PARAMETER IntLBName

.PARAMETER ExtLBName

.PARAMETER LBSubnet

.PARAMETER LBPvtIp

.PARAMETER RemoveObject

.PARAMETER Location

.PARAMETER SubscriptionID

.PARAMETER TenantID

.PARAMETER GenerateName

.PARAMETER NSGName

.PARAMETER AddVPN

.PARAMETER LocalNetPip

.PARAMETER LocalAddPrefix

.PARAMETER AddRange

.PARAMETER SubnetAddPrefix1

.PARAMETER SubnetNameAddPrefix1

.PARAMETER SubnetAddPrefix2

.PARAMETER SubnetNameAddPrefix2

.PARAMETER SubnetAddPrefix3

.PARAMETER SubnetNameAddPrefix3

.PARAMETER SubnetAddPrefix4

.PARAMETER SubnetNameAddPrefix4

.PARAMETER SubnetAddPrefix5

.PARAMETER SubnetNameAddPrefix5

.PARAMETER SubnetAddPrefix6

.PARAMETER SubnetNameAddPrefix6

.PARAMETER SubnetAddPrefix7

.PARAMETER SubnetNameAddPrefix7

.PARAMETER SubnetAddPrefix8

.PARAMETER SubnetNameAddPrefix8

.PARAMETER Profile

.PARAMETER BatchAddNSG

.PARAMETER BatchAddVnet

.PARAMETER BatchUpdateNSG

.PARAMETER BatchCreateExtLB

.PARAMETER BatchCreateIntLB

.PARAMETER BatchAddLB

.PARAMETER csvimport

.PARAMETER csvfile

.EXAMPLE
\.AZRM-VnetDeploy.ps1 -csvimport -csvfile C:\temp\iaasdeployment.csv
.EXAMPLE
\.AZRM-VnetDeploy.ps1 -ActionType Create -vnetrg ResGroup -addvnet -vnet VNET
.EXAMPLE
\.AZRM-VnetDeploy.ps1 -ActionType Create -vnetrg ResGroup -vnet VNET -creatensg -nsgname nsg
.EXAMPLE
\.AZRM-VnetDeploy.ps1 -ActionType Create -vnetrg ResGroup -vnet VNET -createintloadbalancer -intlbname intlb -lbsubnet 4 -LBPvtIP 10.20.4.10
.EXAMPLE
\.AZRM-VnetDeploy.ps1 -ActionType Create -vnetrg ResGroup -vnet VNET -createextloadbalancer -extlbname extlb
.EXAMPLE

.LINK

#>

[CmdletBinding(DefaultParameterSetName = 'default')]
Param(
[Parameter(Mandatory=$False,ValueFromPipelinebyPropertyName=$true)]
[ValidateNotNullorEmpty()]
[ValidateSet("remove","create","update")]
[Alias("action")]
[string]
$ActionType = 'create',
[Parameter(Mandatory=$False,ValueFromPipelinebyPropertyName=$true)]
[ValidateNotNullorEmpty()]
[string]
$vnetrg = '',
[Parameter(Mandatory=$False,ValueFromPipelinebyPropertyName=$true)]
[ValidateNotNullorEmpty()]
[string]
$vnet2rg = '',
[Parameter(Mandatory=$False,ValueFromPipelinebyPropertyName=$true)]
[switch]
$AddVnet,
[Parameter(Mandatory=$False,ValueFromPipelinebyPropertyName=$true)]
[Alias("vnet")]
[string]
$VNetName = '',
[Parameter(Mandatory=$False,ValueFromPipelinebyPropertyName=$true)]
[Alias("vnet2")]
[string]
$VNetName2 = 'vnet2',
[Parameter(Mandatory=$False,ValueFromPipelinebyPropertyName=$true)]
[Alias("addpeer")]
[switch]
$VnetPeering,
[Parameter(Mandatory=$False,ValueFromPipelinebyPropertyName=$true)]
[Alias("nsg")]
[switch]
$CreateNSG,
[Parameter(Mandatory=$False,ValueFromPipelinebyPropertyName=$true)]
[Alias("extlb")]
[switch]
$CreateExtLoadBalancer,
[Parameter(Mandatory=$False,ValueFromPipelinebyPropertyName=$true)]
[Alias("intlb")]
[switch]
$CreateIntLoadBalancer,
[Parameter(Mandatory=$False,ValueFromPipelinebyPropertyName=$true)]
[Alias("addloadb")]
[switch]
$AddLB,
[Parameter(Mandatory=$False,ValueFromPipelinebyPropertyName=$true)]
[ValidateSet("external","internal")]
[string]
$LBType = 'external',
[Parameter(Mandatory=$False,ValueFromPipelinebyPropertyName=$true)]
[string]
$IntLBName = 'intlb',
[Parameter(Mandatory=$False,ValueFromPipelinebyPropertyName=$true)]
[string]
$ExtLBName = 'extlb',
[Parameter(Mandatory=$False,ValueFromPipelinebyPropertyName=$true)]
[int]
$LBSubnet = '3',
[Parameter(Mandatory=$False,ValueFromPipelinebyPropertyName=$true)]
$LBPvtIp = '10.120.4.10',
[Parameter(Mandatory=$False,ValueFromPipelinebyPropertyName=$true)]
[ValidateSet("vnet","vnetrg","nsg")]
[string]
$RemoveObject = '',
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
[Parameter(Mandatory=$False,ValueFromPipelinebyPropertyName=$true)]
[ValidateNotNullorEmpty()]
[string]
$NSGName = '',
[Parameter(Mandatory=$False,ValueFromPipelinebyPropertyName=$true)]
[string]
$AddVPN = $False,
[Parameter(Mandatory=$False,ValueFromPipelinebyPropertyName=$true)]
[ipaddress]
$LocalNetPip = "207.21.2.1",
[Parameter(Mandatory=$False,ValueFromPipelinebyPropertyName=$true)]
[string]
$LocalAddPrefix = "10.0.0.0/24",
[Parameter(Mandatory=$False,ValueFromPipelinebyPropertyName=$true)]
[string]
$AddRange = '10.20.0.0/21',
[Parameter(Mandatory=$False,ValueFromPipelinebyPropertyName=$true)]
[string]
$SubnetAddPrefix1 = "10.20.0.0/24",
[Parameter(Mandatory=$False,ValueFromPipelinebyPropertyName=$true)]
[string]
$SubnetNameAddPrefix1 = "gatewaysubnet",
[Parameter(Mandatory=$False,ValueFromPipelinebyPropertyName=$true)]
[string]
$SubnetAddPrefix2 = "10.20.1.0/25",
[Parameter(Mandatory=$False,ValueFromPipelinebyPropertyName=$true)]
[string]
$SubnetNameAddPrefix2 = 'perimeter',
[Parameter(Mandatory=$False,ValueFromPipelinebyPropertyName=$true)]
[string]
$SubnetAddPrefix3 = "10.20.2.0/24",
[Parameter(Mandatory=$False,ValueFromPipelinebyPropertyName=$true)]
[string]
$SubnetNameAddPrefix3 = "data",
[Parameter(Mandatory=$False,ValueFromPipelinebyPropertyName=$true)]
[string]
$SubnetAddPrefix4 = "10.20.3.0/24",
[Parameter(Mandatory=$False,ValueFromPipelinebyPropertyName=$true)]
[string]
$SubnetNameAddPrefix4 = "monitor",
[Parameter(Mandatory=$False,ValueFromPipelinebyPropertyName=$true)]
[string]
$SubnetAddPrefix5 = "10.20.4.0/24",
[Parameter(Mandatory=$False,ValueFromPipelinebyPropertyName=$true)]
[string]
$SubnetNameAddPrefix5 = "reporting",
[Parameter(Mandatory=$False,ValueFromPipelinebyPropertyName=$true)]
[string]
$SubnetAddPrefix6 = "10.20.5.0/24",
[Parameter(Mandatory=$False,ValueFromPipelinebyPropertyName=$true)]
[string]
$SubnetNameAddPrefix6 = "analytics",
[Parameter(Mandatory=$False,ValueFromPipelinebyPropertyName=$true)]
[string]
$SubnetAddPrefix7 = "10.20.6.0/24",
[Parameter(Mandatory=$False,ValueFromPipelinebyPropertyName=$true)]
[string]
$SubnetNameAddPrefix7 = "management",
[Parameter(Mandatory=$False,ValueFromPipelinebyPropertyName=$true)]
[string]
$SubnetAddPrefix8 = "10.20.7.0/24",
[Parameter(Mandatory=$False,ValueFromPipelinebyPropertyName=$true)]
[string]
$SubnetNameAddPrefix8 = "deployment",
[Parameter(Mandatory=$False,ValueFromPipelinebyPropertyName=$true)]
[string]
$Profile = "profile",
[Parameter(Mandatory=$False,ValueFromPipelinebyPropertyName=$true)]
[string]
$BatchAddNSG = 'False',
[Parameter(Mandatory=$False,ValueFromPipelinebyPropertyName=$true)]
[string]
$BatchAddVnet = 'False',
[Parameter(Mandatory=$False,ValueFromPipelinebyPropertyName=$true)]
[string]
$BatchUpdateNSG = 'False',
[Parameter(Mandatory=$False,ValueFromPipelinebyPropertyName=$true)]
[string]
$BatchCreateExtLB = 'False',
[Parameter(Mandatory=$False,ValueFromPipelinebyPropertyName=$true)]
[string]
$BatchCreateIntLB = 'False',
[Parameter(Mandatory=$False,ValueFromPipelinebyPropertyName=$true)]
[string]
$BatchAddLB = 'False',
[Parameter(Mandatory=$False,ValueFromPipelinebyPropertyName=$true)]
[switch]
$csvimport,
[Parameter(Mandatory=$False,ValueFromPipelinebyPropertyName=$true)]
[string]
$csvfile = -join $workfolder + "\azrm-vnetdeploy.csv"
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
Function Log-Command ([string]$Description, [string]$logFile, [string]$VNetName){
$Output = $LogOut+'. '
Write-Host $Output -ForegroundColor white
((Get-Date -UFormat "[%d-%m-%Y %H:%M:%S] ") + $Output) | Out-File -FilePath $LogOutFile -Append -Force
}
#endregion

#region Use CSV
Function csv-run {
param(
[string] $csvin = $csvfile
)
try {
	$GetPath = test-path -Path $csvin
	if(!$csvin)
	{exit}
	else {
	Write-Host $GetPath "File Exists"
		import-csv -Path $csvin -Delimiter ',' | ForEach-Object{.\AZRM-VnetDeploy.ps1 -ActionType $_.ActionType -vNetrg $_.vnetrg -VNetName $_.VNetName -BatchAddVnet $_.BatchAddVnet -BatchCreateIntLB $_.BatchCreateIntLB -BatchCreateExtLB $_.BatchCreateExtLB -BatchAddLB $_.BatchAddLB -LBSubnet $_.LBSubnet -LBPvtIp $_.LBPvtIp -IntLBName $_.IntLBName -ExtLBName $_.ExtLBName -LBType $_.LBType -BatchAddNSG $_.BatchAddNSG -BatchUpdateNSG $_.BatchUpdateNSG -NSGName $_.NSGName }
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
#endregion

Function Verify-LBSubnet {
if($CreateIntLoadBalancer -or $BatchCreateIntLB -eq 'True')
			{
			[int]$subnet = $LBSubnet
			$ip = $LBPvtIp
			$array = $ip.Split(".")
			[int]$subnetint = $array[2]
			[int]$subnetcalc = ($subnetint)
				if($subnetcalc -ne $subnet){
					$script:LBSubnet = $subnetcalc
					Write-Host "Updating LB Subnet to correct subnet"
					Write-Host "LBSubnet: $script:LBSubnet"
			}
			else
			{
			Write-Host "correct subnet"
			$script:LBSubnet = $LBSubnet
			}
	}
}

Function Create-VnetPeering {
	param(
[string]$vnetName_1 = $VNetName,
[string]$vnetName_2 = $VNetName2,
[string]$vnetrg = $vnetrg,
[string]$peer1 = 'peer1',
[string]$peer2 = 'peer2'
	)

	Try
	{
if($VnetPeering)
{
Register-AzureRmProviderFeature -FeatureName AllowVnetPeering -ProviderNamespace Microsoft.Network -Confirm:$false -WarningAction SilentlyContinue | Out-Null
Register-AzureRmResourceProvider -ProviderNamespace Microsoft.Network -Confirm:$false -WarningAction SilentlyContinue | Out-Null

# Get vnet properties
$vnet1 = Get-AzureRmVirtualNetwork -ResourceGroupName $vnetrg -Name $vnetName_1 -WarningAction SilentlyContinue -ErrorAction Stop
$vnet2 = Get-AzureRmVirtualNetwork -ResourceGroupName $vnetrg -Name $vnetName_2 -WarningAction SilentlyContinue -ErrorAction Stop

# Create link between vnets
Add-AzureRmVirtualNetworkPeering -name $peer1 -VirtualNetwork $vnet1 -RemoteVirtualNetworkId $vnet2.id
Add-AzureRmVirtualNetworkPeering -name $peer2 -VirtualNetwork $vnet2 -RemoteVirtualNetworkId $vnet1.id

$LogOut = "Completed Network Peering Configuration of $VNetName and $VnetName2"
Log-Command -Description $LogOut -LogFile $LogOutFile
	}
}
	Catch
	{
	Write-Host -foregroundcolor Yellow `
	"Exception Encountered"; `
	$ErrorMessage = $_.Exception.Message
	$LogOut  = 'Error '+$ErrorMessage
	Log-Command -Description $LogOut -LogFile $LogOutFile
	break
	}
}

Function Check-Vnet {
$vnetexists = Get-AzureRmVirtualNetwork -Name $VNetName -ResourceGroupName $vnetrg -ErrorAction SilentlyContinue -WarningAction SilentlyContinue
if(!$vnetexists)
	{Create-Vnet}
	else
		{Write-Host "Proceeding with VNET $VnetName"}
}

#region Check Values of runtime params
function Check-NullValues {
if(!$vnetrg) {
Write-Host "Please Enter VNET Resource Group Name"
exit
}
	elseif(!$VNetName) {
	Write-Host "Please Enter VNetName"
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
if($RemoveObject -eq 'vnetrg' -and !$vnetrg) {
	Write-Host "Please Enter -rg RG Name"
	exit
	}
	}

function Check-NSGName {
if($CreateNSG -and !$NSGName) {
Write-Host "Please Enter NSG Name -nsgname"
exit
 }
}

function Check-ConfigureLB {
if($AddLB -and !$LBName) {
Write-Host "Please Enter LB Name"
exit
 }
}

function Check-CreateLB {
if($CreateExtLoadBalancer -and !$ExtLBName) {
Write-Host "Please Enter External LB Name"
exit
 }
}

function Check-CreateIntLB {
if($CreateIntLoadBalancer -and !$IntLBName) {
Write-Host "Please Enter Internal LB Name"
exit
 }
	elseif($CreateIntLoadBalancer -and !$LBPvtIp)
			{
		Write-Host "Please Enter Internal LB Pvt IP"
		exit
		 }
		elseif($CreateIntLoadBalancer -and !$LBSubnet)
				{
			Write-Host "Please Enter Internal LB Subnet"
			exit
			 }
}
#endregion

#region Create VPN
Function Create-VPN {
	Try
	{
		Write-Host "VPN Creation can take up to 45 minutes!"
		New-AzureRmLocalNetworkGateway -Name LocalSite -ResourceGroupName $vnetrg -Location $Location -GatewayIpAddress $LocalNetPip -AddressPrefix $LocalAddPrefix -ErrorAction Stop -WarningAction SilentlyContinue | Out-Null
		Write-Host "Completed Local Network GW Creation"
			$vpnpip= New-AzureRmPublicIpAddress -Name vpnpip -ResourceGroupName $vnetrg -Location $Location -AllocationMethod Dynamic -ErrorAction Stop -WarningAction SilentlyContinue
			$vnet = Get-AzureRmVirtualNetwork -Name $VNetName -ResourceGroupName $vnetrg -ErrorAction Stop -WarningAction SilentlyContinue
			$subnet = Get-AzureRmVirtualNetworkSubnetConfig -Name 'GatewaySubnet' -VirtualNetwork $vnet -WarningAction SilentlyContinue
			$vpnipconfig = New-AzureRmVirtualNetworkGatewayIpConfig -Name vpnipconfig1 -SubnetId $subnet.Id -PublicIpAddressId $vpnpip.Id -WarningAction SilentlyContinue
		New-AzureRmVirtualNetworkGateway -Name vnetvpn1 -ResourceGroupName $vnetrg -Location $Location -IpConfigurations $vpnipconfig -GatewayType Vpn -VpnType RouteBased -GatewaySku Standard -ErrorAction Stop -WarningAction SilentlyContinue | Out-Null
		Write-Host "Completed VNET Network GW Creation"
		Get-AzureRmPublicIpAddress -Name vpnpip -ResourceGroupName $vnetrg -WarningAction SilentlyContinue
		Write-Host "Configure Local Device with Azure VNET vpn Public IP"
	}
	Catch
	{
	Write-Host -foregroundcolor Yellow `
	"Exception Encountered"; `
	$ErrorMessage = $_.Exception.Message
	$LogOut  = 'Error '+$ErrorMessage
			Log-Command -Description $LogOut -LogFile $LogOutFile
		break
	}
}
#endregion

#region Connect VPN
Function Connect-VPN {
[PSObject]$gateway1 = Get-AzureRmVirtualNetworkGateway -Name vnetvpn1 -ResourceGroupName $vnetrg -WarningAction SilentlyContinue
[PSObject]$local = Get-AzureRmLocalNetworkGateway -Name LocalSite -ResourceGroupName $vnetrg -WarningAction SilentlyContinue
New-AzureRmVirtualNetworkGatewayConnection -ConnectionType IPSEC  -Name sitetosite -ResourceGroupName $vnetrg -Location $Location -VirtualNetworkGateway1 $gateway1 -LocalNetworkGateway2 $local -SharedKey '4321avfe' -Verbose -Force -RoutingWeight 10 -WarningAction SilentlyContinue  -ErrorAction Stop | Out-Null
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
#endregion

#region Create VNET
Function Create-Vnet {
param(
[Parameter(Mandatory=$False,ValueFromPipelinebyPropertyName=$true)]
[string]$VNETName = $VNetName,
[Parameter(Mandatory=$False,ValueFromPipelinebyPropertyName=$true)]
[string]$vnetrg = $vnetrg,
[Parameter(Mandatory=$False,ValueFromPipelinebyPropertyName=$true)]
[string]$AddRange = $AddRange,
[Parameter(Mandatory=$False,ValueFromPipelinebyPropertyName=$true)]
[string]$Location = $Location,
[Parameter(Mandatory=$False,ValueFromPipelinebyPropertyName=$true)]
[string]$SubnetAddPrefix1 = $SubnetAddPrefix1,
[Parameter(Mandatory=$False,ValueFromPipelinebyPropertyName=$true)]
[string]$SubnetNameAddPrefix1 = $SubnetNameAddPrefix1,
[Parameter(Mandatory=$False,ValueFromPipelinebyPropertyName=$true)]
[string]$SubnetAddPrefix2 = $SubnetAddPrefix2,
[Parameter(Mandatory=$False,ValueFromPipelinebyPropertyName=$true)]
[string]$SubnetNameAddPrefix2 = $SubnetNameAddPrefix2,
[Parameter(Mandatory=$False,ValueFromPipelinebyPropertyName=$true)]
[string]$SubnetAddPrefix3 = $SubnetAddPrefix3,
[Parameter(Mandatory=$False,ValueFromPipelinebyPropertyName=$true)]
[string]$SubnetNameAddPrefix3 = $SubnetNameAddPrefix3,
[Parameter(Mandatory=$False,ValueFromPipelinebyPropertyName=$true)]
[string]$SubnetAddPrefix4 = $SubnetAddPrefix4,
[Parameter(Mandatory=$False,ValueFromPipelinebyPropertyName=$true)]
[string]$SubnetNameAddPrefix4 = $SubnetNameAddPrefix4,
[Parameter(Mandatory=$False,ValueFromPipelinebyPropertyName=$true)]
[string]$SubnetAddPrefix5 = $SubnetAddPrefix5,
[Parameter(Mandatory=$False,ValueFromPipelinebyPropertyName=$true)]
[string]$SubnetNameAddPrefix5 = $SubnetNameAddPrefix5,
[Parameter(Mandatory=$False,ValueFromPipelinebyPropertyName=$true)]
[string]$SubnetAddPrefix6 = $SubnetAddPrefix6,
[Parameter(Mandatory=$False,ValueFromPipelinebyPropertyName=$true)]
[string]$SubnetNameAddPrefix6 = $SubnetNameAddPrefix6,
[Parameter(Mandatory=$False,ValueFromPipelinebyPropertyName=$true)]
[string]$SubnetAddPrefix7 = $SubnetAddPrefix7,
[Parameter(Mandatory=$False,ValueFromPipelinebyPropertyName=$true)]
[string]$SubnetNameAddPrefix7 = $SubnetNameAddPrefix7,
[Parameter(Mandatory=$False,ValueFromPipelinebyPropertyName=$true)]
[string]$SubnetAddPrefix8 = $SubnetAddPrefix8,
[Parameter(Mandatory=$False,ValueFromPipelinebyPropertyName=$true)]
[string]$SubnetNameAddPrefix8 = $SubnetNameAddPrefix8
)
Write-ConfigVNet
	Write-Host "Network Preparation in Process.."
	$subnet1 = New-AzureRmVirtualNetworkSubnetConfig -AddressPrefix $SubnetAddPrefix1 -Name $SubnetNameAddPrefix1
	$subnet2 = New-AzureRmVirtualNetworkSubnetConfig -AddressPrefix $SubnetAddPrefix2 -Name $SubnetNameAddPrefix2
	$subnet3 = New-AzureRmVirtualNetworkSubnetConfig -AddressPrefix $SubnetAddPrefix3 -Name $SubnetNameAddPrefix3
	$subnet4 = New-AzureRmVirtualNetworkSubnetConfig -AddressPrefix $SubnetAddPrefix4 -Name $SubnetNameAddPrefix4
	$subnet5 = New-AzureRmVirtualNetworkSubnetConfig -AddressPrefix $SubnetAddPrefix5 -Name $SubnetNameAddPrefix5
	$subnet6 = New-AzureRmVirtualNetworkSubnetConfig -AddressPrefix $SubnetAddPrefix6 -Name $SubnetNameAddPrefix6
	$subnet7 = New-AzureRmVirtualNetworkSubnetConfig -AddressPrefix $SubnetAddPrefix7 -Name $SubnetNameAddPrefix7
	$subnet8 = New-AzureRmVirtualNetworkSubnetConfig -AddressPrefix $SubnetAddPrefix8 -Name $SubnetNameAddPrefix8
	Try
	{
	New-AzureRmVirtualNetwork -Location $Location -Name $VNetName -ResourceGroupName $vnetrg -AddressPrefix $AddRange -Subnet $subnet1,$subnet2,$subnet3,$subnet4,$subnet5,$subnet6,$subnet7,$subnet8 –Confirm:$false -WarningAction SilentlyContinue -Force | Out-Null
	Get-AzureRmVirtualNetwork -Name $VNetName -ResourceGroupName $vnetrg | Get-AzureRmVirtualNetworkSubnetConfig -WarningAction SilentlyContinue | Out-Null
	Write-Host "Network Preparation completed" -ForegroundColor White
	$LogOut = "Completed Network Configuration of $VNetName"
	Log-Command -Description $LogOut -LogFile $LogOutFile
	}
	Catch
	{
	Write-Host -foregroundcolor Yellow `
	"$($_.Exception.Message)"; `
	$LogOut = "$($_.Exception.Message)"
	Log-Command -Description $LogOut -LogFile $LogOutFile
	break
	}
}
#endregion

Function Create-LB
{
	param(
		[Parameter(Mandatory=$False,ValueFromPipelinebyPropertyName=$true)]
		[string]
		$LBName = $ExtLBName,
		[Parameter(Mandatory=$False,ValueFromPipelinebyPropertyName=$true)]
		[string]
		$Location = $Location,
		[Parameter(Mandatory=$False,ValueFromPipelinebyPropertyName=$true)]
		[string]
		$vnetrg = $vnetrg,
		[Parameter(Mandatory=$False,ValueFromPipelinebyPropertyName=$true)]
		[string]
		$frtpool = 'frontend',
		[Parameter(Mandatory=$False,ValueFromPipelinebyPropertyName=$true)]
		[string]
		$backpool = 'backend'
	)

	Try
	{
	$script:VNet = Get-AzureRMVirtualNetwork -Name $VNetName -ResourceGroupName $vnetrg | Set-AzureRmVirtualNetwork
	Write-Host "Creating Public Ip, Pools, Probe and Inbound NAT Rules"
		$lbpublicip = New-AzureRmPublicIpAddress -Name 'lbip' -ResourceGroupName $vnetrg -Location $Location -AllocationMethod Dynamic -WarningAction SilentlyContinue
		$frtend = New-AzureRmLoadBalancerFrontendIpConfig -Name $frtpool -PublicIpAddress $lbpublicip -WarningAction SilentlyContinue
		$backendpool = New-AzureRmLoadBalancerBackendAddressPoolConfig -Name $backpool  -WarningAction SilentlyContinue
		$probecfg = New-AzureRmLoadBalancerProbeConfig -Name 'probecfg' -Protocol Http -Port 80 -IntervalInSeconds 30 -ProbeCount 2 -RequestPath 'healthcheck.aspx' -WarningAction SilentlyContinue
		$inboundnat1 = New-AzureRmLoadBalancerInboundNatRuleConfig -Name 'inboundnat1' -FrontendIpConfiguration $frtend -Protocol Tcp -FrontendPort 443 -BackendPort 443 -IdleTimeoutInMinutes 15 -EnableFloatingIP -WarningAction SilentlyContinue
		$inboundnat2 = New-AzureRmLoadBalancerInboundNatRuleConfig -Name 'inboundnat2' -FrontendIpConfiguration $frtend -Protocol Tcp -FrontendPort 3389 -BackendPort 3389 -IdleTimeoutInMinutes 15 -EnableFloatingIP -WarningAction SilentlyContinue
		$lbrule = New-AzureRmLoadBalancerRuleConfig -Name 'lbrules' -FrontendIpConfiguration $frtend -BackendAddressPool $backendpool -Probe $probecfg -Protocol Tcp -FrontendPort '80' -BackendPort '80' -IdleTimeoutInMinutes '20' -EnableFloatingIP -LoadDistribution SourceIP -WarningAction SilentlyContinue
		$lb = New-AzureRmLoadBalancer -Location $Location -Name $LBName -ResourceGroupName $vnetrg -FrontendIpConfiguration $frtend -BackendAddressPool $backendpool -Probe $probecfg -InboundNatRule $inboundnat1,$inboundnat2 -LoadBalancingRule $lbrule -WarningAction SilentlyContinue -ErrorAction Stop -Force -Confirm:$false
		Get-AzureRmLoadBalancer -Name $LBName -ResourceGroupName $vnetrg -WarningAction SilentlyContinue | Out-Null
			$LogOut = "Completed LB Configuration of $LBName"
			Log-Command -Description $LogOut -LogFile $LogOutFile
	}
	Catch
	{
	Write-Host -foregroundcolor Yellow `
	"Exception Encountered"; `
	$ErrorMessage = $_.Exception.Message
	$LogOut  = 'Error '+$ErrorMessage
	Log-Command -Description $LogOut -LogFile $LogOutFile
	break
	}
}

Function Create-IntLB
{
	param(
		[Parameter(Mandatory=$False,ValueFromPipelinebyPropertyName=$true)]
		[string]$LBName = $IntLBName,
		[Parameter(Mandatory=$False,ValueFromPipelinebyPropertyName=$true)]
		[string]$Location = $Location,
		[Parameter(Mandatory=$False,ValueFromPipelinebyPropertyName=$true)]
		[string]$vnetrg = $vnetrg,
		[Parameter(Mandatory=$False,ValueFromPipelinebyPropertyName=$true)]
		[ipaddress]$PvtIP = $LBPvtIp,
		[Parameter(Mandatory=$False,ValueFromPipelinebyPropertyName=$true)]
		[int]$subnet = $script:LBSubnet,
		[Parameter(Mandatory=$False,ValueFromPipelinebyPropertyName=$true)]
		[string]$frtpool = 'frontend',
		[Parameter(Mandatory=$False,ValueFromPipelinebyPropertyName=$true)]
		[string]$backpool = 'backend'
	)

	Try
	{
	$script:VNet = Get-AzureRMVirtualNetwork -Name $VNetName -ResourceGroupName $vnetrg | Set-AzureRmVirtualNetwork
	Write-Host "Creating Pools, Probe and Inbound NAT Rules"
		$frontendIP = New-AzureRmLoadBalancerFrontendIpConfig -Name $frtpool -PrivateIpAddress $PvtIP -SubnetId $vnet.subnets[$subnet].Id -WarningAction SilentlyContinue
		$backendpool = New-AzureRmLoadBalancerBackendAddressPoolConfig -Name $backpool  -WarningAction SilentlyContinue
		$probecfg = New-AzureRmLoadBalancerProbeConfig -Name 'probecfg' -Protocol Http -Port 80 -IntervalInSeconds 30 -ProbeCount 2 -RequestPath 'healthcheck.aspx' -WarningAction SilentlyContinue
		$inboundnat1 = New-AzureRmLoadBalancerInboundNatRuleConfig -Name 'inboundnat1' -FrontendIpConfiguration $frontendIP -Protocol Tcp -FrontendPort 3391 -BackendPort 3389 -IdleTimeoutInMinutes 15 -EnableFloatingIP -WarningAction SilentlyContinue
		$inboundnat2 = New-AzureRmLoadBalancerInboundNatRuleConfig -Name 'inboundnat2' -FrontendIpConfiguration $frontendIP -Protocol Tcp -FrontendPort 3389 -BackendPort 3389 -IdleTimeoutInMinutes 15 -EnableFloatingIP -WarningAction SilentlyContinue
		$lbrule = New-AzureRmLoadBalancerRuleConfig -Name 'lbrules' -FrontendIpConfiguration $frontendIP -BackendAddressPool $backendpool -Probe $probecfg -Protocol Tcp -FrontendPort '80' -BackendPort '80' -IdleTimeoutInMinutes '20' -EnableFloatingIP -LoadDistribution SourceIP -WarningAction SilentlyContinue
		$lb = New-AzureRmLoadBalancer -Location $Location -Name $LBName -ResourceGroupName $vnetrg -FrontendIpConfiguration $frontendIP -BackendAddressPool $backendpool -Probe $probecfg -InboundNatRule $inboundnat1,$inboundnat2 -LoadBalancingRule $lbrule -WarningAction SilentlyContinue -ErrorAction Stop -Force -Confirm:$false
		Get-AzureRmLoadBalancer -Name $LBName -ResourceGroupName $vnetrg -WarningAction SilentlyContinue -ErrorAction Stop | Out-Null
			$LogOut = "Completed LB Configuration of $LBName"
			Log-Command -Description $LogOut -LogFile $LogOutFile
	}
	Catch
	{
	Write-Host -foregroundcolor Yellow `
	"Exception Encountered"; `
	$ErrorMessage = $_.Exception.Message
	$LogOut  = 'Error '+$ErrorMessage
	Log-Command -Description $LogOut -LogFile $LogOutFile
	break
	}
}

#region Create NSG
Function Create-NSG {
param(
[string]$NSGName = $NSGName,
[string]$Location = $Location,
[string]$vnetrg = $vnetrg
)
	Try
	{
			Write-Host "Network Security Group Preparation in Process.."
		$httprule = New-AzureRmNetworkSecurityRuleConfig -Name "FrontEnd_HTTP" -Description "HTTP Exception for Web frontends" -Protocol Tcp -SourcePortRange "80" -DestinationPortRange "80" -SourceAddressPrefix "*" -DestinationAddressPrefix "10.120.0.0/21" -Access Allow -Direction Inbound -Priority 200
		$httpsrule = New-AzureRmNetworkSecurityRuleConfig -Name "FrontEnd_HTTPS" -Description "HTTPS Exception for Web frontends" -Protocol Tcp -SourcePortRange "443" -DestinationPortRange "443" -SourceAddressPrefix "*" -DestinationAddressPrefix "10.120.0.0/21" -Access Allow -Direction Inbound -Priority 201
		$sshrule = New-AzureRmNetworkSecurityRuleConfig -Name "FrontEnd_SSH" -Description "SSH Exception for Web frontends" -Protocol Tcp -SourcePortRange "22" -DestinationPortRange "22" -SourceAddressPrefix "*" -DestinationAddressPrefix "10.120.0.0/21" -Access Allow -Direction Inbound ` -Priority 203
		$rdprule = New-AzureRmNetworkSecurityRuleConfig -Name "FrontEnd_RDP" -Description "RDP Exception for frontends" -Protocol Tcp -SourcePortRange "3389" -DestinationPortRange "3389" -SourceAddressPrefix "*" -DestinationAddressPrefix "10.120.0.0/21" -Access Allow -Direction Inbound ` -Priority 204
		$nsg = New-AzureRmNetworkSecurityGroup -ResourceGroupName $vnetrg -Location $Location -Name $NSGName -SecurityRules $httprule,$httpsrule,$sshrule,$rdprule –Confirm:$false -WarningAction SilentlyContinue -Force | Out-Null
		Get-AzureRmNetworkSecurityGroup -Name $NSGName -ResourceGroupName $vnetrg -WarningAction SilentlyContinue | Out-Null
		Write-Host "Network Security Group configuration completed" -ForegroundColor White
		$secrules = Get-AzureRmNetworkSecurityGroup -Name $NSGName -ResourceGroupName $vnetrg -ExpandResource NetworkInterfaces | Get-AzureRmNetworkSecurityRuleConfig | Ft Name,Description,Direction,SourcePortRange,DestinationPortRange,DestinationPortRange,SourceAddressPrefix,Access
		$defsecrules = Get-AzureRmNetworkSecurityGroup -Name $NSGName -ResourceGroupName $vnetrg -ExpandResource NetworkInterfaces | Get-AzureRmNetworkSecurityRuleConfig -DefaultRules | Ft Name,Description,Direction,SourcePortRange,DestinationPortRange,DestinationAddressPrefix,SourceAddressPrefix,Access
		$LogOut = "Security Rules added for $NSGName"
		Log-Command -Description $LogOut -LogFile $LogOutFile
		$LogOut = "Completed NSG Configuration of $NSGName"
		Log-Command -Description $LogOut -LogFile $LogOutFile
	}
	Catch
	{
	Write-Host -foregroundcolor Yellow `
	"Exception Encountered"; `
	$ErrorMessage = $_.Exception.Message
	$LogOut  = 'Error '+$ErrorMessage
	Log-Command -Description $LogOut -LogFile $LogOutFile
	break
	}
}
#endregion

#region Match Subnet
Function Subnet-Match {
	Param(
		[INT]$Subnet
	)
switch ($Subnet)
{
0 {Write-Host "Deploying to Subnet $SubnetAddPrefix1"}
1 {Write-Host "Deploying to Subnet $SubnetAddPrefix2"}
2 {Write-Host "Deploying to Subnet $SubnetAddPrefix3"}
3 {Write-Host "Deploying to Subnet $SubnetAddPrefix4"}
4 {Write-Host "Deploying to Subnet $SubnetAddPrefix5"}
5 {Write-Host "Deploying to Subnet $SubnetAddPrefix6"}
6 {Write-Host "Deploying to Subnet $SubnetAddPrefix7"}
7 {Write-Host "Deploying to Subnet $SubnetAddPrefix8"}
8 {Write-Host "Deploying to Subnet $SubnetAddPrefix9"}
default {No Subnet Found}
}
}
#endregion

#region Show Network Config
Function Write-ConfigVnet {
Write-Host "                                                               "
$time = " Start Time " + (Get-Date -UFormat "%d-%m-%Y %H:%M:%S")
Write-Host VNET CONFIGURATION - $time --------- -ForegroundColor Cyan
Write-Host "                                                               "
Write-Host "Action Type:" $ActionType
Write-Host "Geo Location: $Location"
Write-Host "VNET Name: $vNetName"
Write-Host "VNET Resource Group Name: $vnetrg"
Write-Host "Address Range:  $AddRange"
if($CreateNSG -or $BatchAddNSG -eq 'True')
{
Write-Host "NSG Name: $NSGName"
}
if($CreateExtLoadBalancer)
	{
Write-Host "Creating External Load Balancer"
Write-Host "LB Name: '$LBName'"
	}
if($CreateIntLoadBalancer)
	{
Write-Host "Creating Internal Load Balancer"
Write-Host "LB Name:'$LBName'"
	}

Write-Host "                                                               "
}

#endregion

#region Provision Resource Group
Function Provision-RG
{
	Param(
		[string]$vnetrg
	)
New-AzureRmResourceGroup -Name $vnetrg -Location $Location –Confirm:$false -WarningAction SilentlyContinue -Force | Out-Null
}
#endregion

Function Remove-azRg
{
Param(
		[Parameter(Mandatory=$False,ValueFromPipelinebyPropertyName=$true,Position=0)]
		[string]
		$vnetrg = $vnetrg
)
		Write-Host "Removing RG "
		Get-AzureRmResourceGroup -Name $vnetrg | Remove-AzureRmResourceGroup -Verbose -Force -Confirm:$False
}
#endregion

#region Remove NSG
Function Remove-azNSG
{
Param(
		[Parameter(Mandatory=$False,ValueFromPipelinebyPropertyName=$true,Position=1)]
		[string]
		$vnetrg = $vnetrg,
		[Parameter(Mandatory=$False,ValueFromPipelinebyPropertyName=$true,Position=0)]
		[string]
		$NSGName = $NSGName
)
		Write-Host "Removing NSG"
		Remove-AzureRmNetworkSecurityGroup -Name $NSGName -ResourceGroupName $vnetrg -WarningAction SilentlyContinue -ErrorAction Stop -Force -Confirm:$False | Format-Table
		$LogOut = "Removed $NSGName"
		Log-Command -Description $LogOut -LogFile $LogOutFile
}
#endregion

#region Remove VNET
Function Remove-azVNET
{
Param(
		[Parameter(Mandatory=$False,ValueFromPipelinebyPropertyName=$true,Position=1)]
		[string]
		$vnetrg = $vnetrg,
		[Parameter(Mandatory=$False,ValueFromPipelinebyPropertyName=$true,Position=0)]
		[string]
		$VNETName = $VNETName
)
		Write-Host "Removing VNET"
		Remove-AzureRmVirtualNetwork -Name $VNETName -ResourceGroupName $vnetrg -Confirm:$False -Force
		$LogOut = "Removed $VNETName"
		Log-Command -Description $LogOut -LogFile $LogOutFile
}
#endregion

Function Create-ResourceGroup {
				$resourcegroups = @($vnetrg);
				if($resourcegroups.length) {
					foreach($resourcegroup in $resourcegroups) {
						Provision-RG($resourcegroup);
					}
				}
}
#region Remove Component
Function Remove-Component {
	param(
		[string]$RemoveObject = $RemoveObject
	)

switch ($RemoveObject)
	{
		"vnetrg" {
		Remove-azRg
		exit
}
		"nsg" {
		Remove-azNSG
		exit
}
		"vnet" {
		Remove-azVNET
		exit
}
		default{"An unsupported uninstall Extension command was used"}
	}
	exit
}
#endregion

#region Action Type
Function Action-Type {
	param(
		$ActionType = $ActionType
	)

	Try
	{
	switch ($ActionType)
		{
			"create" {
					Check-NullValues
					Check-NSGName # Verifies required fields have data
					Write-Output "Steps will be tracked in the log file : [ $LogOutFile ]"
					Create-ResourceGroup
					if($AddVnet -or $BatchAddVnet -eq 'True')
							{
							Create-Vnet
							} # Creates VNET
					Check-Vnet
					if($CreateNSG -or $BatchAddNSG -eq 'True')
							{
							Create-NSG
							} # Creates NSG and Security Groups
					if($CreateExtLoadBalancer -or $BatchCreateExtLB -eq 'True')
							{
							Check-CreateLB
							Create-LB
							}
					if($CreateIntLoadBalancer -or $BatchCreateIntLB -eq 'True')
							{
							Verify-LBSubnet
							Check-CreateIntLB
							Create-IntLB
							}

					if($AddVPN -eq 'True')
							{
							Create-VPN
							Connect-VPN
							} #Creates VPN
					if($VNETPeering)
							{
Create-VnetPeering
							} #Creates Peering
	}
			"update" {
				if($VNETPeering)
							{
Vnet-Peering
							} #Creates Peering
	}
			"remove" {
					Check-RemoveAction
					if($RemoveObject)
						{
						Check-RemoveObject
						Remove-Component
						}
		}
			default{"An unsupported uninstall Extension command was used"}
		}
	}
	Catch
	{
	Write-Host -foregroundcolor Yellow `
	"Exception Encountered"; `
	$ErrorMessage = $_.Exception.Message
	$LogOut  = 'Error '+$ErrorMessage
	Log-Command -Description $LogOut -LogFile $LogOutFile
	break
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
$LogOutFile = $logdir+$vnetname+'-'+$date+'.log'
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

if($csvimport) { csv-run }

Action-Type