<#
.SYNOPSIS
Written By John Lewis
email: jonos@live.com
Ver 10.2

This script provides the following functionality for deploying IaaS environments in Azure. The script will deploy VNET in addition to numerous Market Place VMs or make use of an existing VNETs.
The script supports dual homed servers (PFSense/Checkpoint/FreeBSD/F5/Barracuda)
The script supports deploying Availability Sets as well as adding new servers to existing Availability Sets through the -AvailabilitySet and -AvailSetName switches.
The script supports deploying Azure Extensions through the -AddExtensions switch Example -AddExtensions -extname winaccess.
This script supports Load Balanced configurations for both internal and external load balancers.

The script will create three directories if they do not exist in the runtime directory, Log, Scripts, DSC.

v10.2 updates - Added -preview option to allow preview of operations. Added ASR Backup Extension Option -extname addvmbackupvault
v10.1 updates - Added Public DNS option for External LB Public IP
v10 updates - Azure PowerShell 4.0.x updates
v9.1 updates - Extensive updates to LB Creation Process as well as NSG Creation.
v9.0 updates - Updated -csvimport process to include managed disks, ssh and storage rg. Made updates to Availability Sets to handle managed disks. Updates for all extensions, chef extension now available for Linux and Windows.
v8.9 updates - Added Storage Resource Group param -storagerg
v8.8.1 updates - Fixed issue for -userexiststorage when used with unmanaged disks
v8.8 updates - Added -useexiststorage flag to provide override for deploying VM to existing storage account. Added custom script for linux extension to -addextension deployment options.
v8.7 updates - Added Ubuntu16 and PfSense 3.2.2.1 Images
v8.6 updates - Add managed Disk Functionality, -vmstrtype 'managed' to deploy the VM with managed disk
v8.5 updates - changed info provided for existing VNET deployments, updated -addssh to switch, added $sshPublicKey which is a text file that contains the Public SSH key which is used by the addssh switch.
v8.4 updates - added -addssh and -sshpublickey options for Linux image deployment
v8.3 updates - Updated with Centos68, Centos72 as available images.
v8.2 updates - Added Data Drives to VM Deployment by default
v8.1 updates - Additional removal functions moved to AZRM-RemoveResource.ps1, final release 2016.
v8.0 updates - Added - override switch to use Add-AzureRmAccount instead of Profile file
v7.9 updates - Vnet Peering added under -vnetpeering switch
v7.8 updates - deploy LB from csv functionality added
v7.7 updates - added internal load balancer creation option -CreateIntLoadBalancer
v7.6 updates - Now able to deploy new Azure RM external load balancers as well as add/update VM NICs to provision to LB Back End Pool -createextloadbalancer
v7.5 updates - Added ability to create storage share in table storage and upload files to the share -UploadSharedFiles. The shares can be mapped via NET USE commands
v7.4 updates - fixes for Debian image deployment
v7.3 udates - added support for Chef Compliance and Tig Backup Services
v7.2 updates - added support for Cisco, Citrix, Nessus and Debian

.DESCRIPTION
Deploys 55 different Market Images on a new or existing VNET. Supports post deployment configuration through Azure Extensions.
Market Images supported: Redhat 6.7 and 7.2, PFSense 2.5, Windows 2008 R2, Windows 2012 R2, Ubuntu 14.04, CentOs 7.2, SUSE, SQL 2016 (on W2K12R2), R Server on Windows, Windows 2016 (Preview), Checkpoint Firewall, FreeBsd, Puppet, Splunk, Bitnami Lamp, Bitnami PostGresSql, Bitnami nodejs, Bitnami Elastics, Bitnami MySql, SharePoint 2013/2016, Barracuda NG, Barracuda SPAM, F5 BigIP, F5 App Firewall, Bitnami JRuby, Bitnami Neos, Bitnami TomCat, Bitnami redis, Bitnami hadoop, Incredibuild, VS 2015, Dev15 Preview, Tableau, MS NAV, TFS, Ads Data Science Server, Biztalk 2013/2016, HortonWorks, Cloudera, DataStax

.PARAMETER vmstrtype
Sets the type of storage to use for the VM
.PARAMETER vmMarketImage
Sets the type of image to be deloyed.
.PARAMETER VMName
Sets the name of the VM to deploy
.PARAMETER rg
The name of the resource group to deploy too.
.PARAMETER vnetrg
The name of the resource group the Vnet is deployed too.
.PARAMETER storerg
The name of the storage account resource group to deploy too.
.PARAMETER AddVnet
Adds a mew Vnet.
.PARAMETER BatchAddVnet
Adds a new Vnet based on CSV field.
.PARAMETER VNetName
Name of new or existing vnet to deploy too.
.PARAMETER ConfigIPs
Type of network configuration to use for the VM NIC
.PARAMETER CreateNSG
Adds a mew NSG to the vnet resource group.
.PARAMETER BatchAddNSG
Adds a new NSG based on csv field.
.PARAMETER RemoveObject
Selects type of object to remove.
.PARAMETER VMSize
Selects size of VM to deploy.
.PARAMETER locadmin
User account name used in creating local administrator account.
.PARAMETER locpassword
Password used for local administrator account
.PARAMETER Location
Azure Region to deploy too.
.PARAMETER GenerateName
Generates random name for Availability set if no name specified.
.PARAMETER StorageName
Generates name based on VMName if no name specified
.PARAMETER StorageType
Type of Storage Used for VM
.PARAMETER InterfaceName1
Name of Network Interface One (generated if not specified)
.PARAMETER InterfaceName2
Name of Network Interface Two (generated if not specified)
.PARAMETER NSGName
Name of new of existing NSG
.PARAMETER Subnet1
Subnet to use for NIC1
.PARAMETER Subnet2
Subnet to use for Nic2
.PARAMETER AddAvailabilitySet
Create and Add Availability Set
.PARAMETER BatchAddAvSet
Create and Add Availability Set based on Csv input
.PARAMETER AvailSetName
Availability Set Name
.PARAMETER DNLabel
Domain Name Label to use for FQDN
.PARAMETER AddFQDN
Adds Fully Qualified Domain Namne to Public IP
.PARAMETER BatchAddFQDN
Based on csv input adds FQDN to public Ip
.PARAMETER PvtIPNic1
Private Ip Address Nic1
.PARAMETER PvtIPNic2
Private Ip Address Nic2
.PARAMETER AddVPN
Creates and Adds a Site to site VPN
.PARAMETER LocalNetPip
Local Network PIP for Site to Site VPN
.PARAMETER LocalAddPrefix
Local Network Address Range
.PARAMETER AddRange
vNET Address Range
.PARAMETER SubnetAddPrefix1
VNET Subnet1
.PARAMETER SubnetNameAddPrefix1
VNET Subnet1 Name
.PARAMETER SubnetAddPrefix2
VNET Subnet2
.PARAMETER SubnetNameAddPrefix2
VNET Subnet2 Name
.PARAMETER SubnetAddPrefix3
VNET Subnet3
.PARAMETER SubnetNameAddPrefix3
VNET Subnet3 Name
.PARAMETER SubnetAddPrefix4
VNET Subnet4
.PARAMETER SubnetNameAddPrefix4
VNET Subnet4 Name
.PARAMETER SubnetAddPrefix5
VNET Subnet5
.PARAMETER SubnetNameAddPrefix5
VNET Subnet5 Name
.PARAMETER SubnetAddPrefix6
VNET Subnet6
.PARAMETER SubnetNameAddPrefix6
VNET Subnet6 Name
.PARAMETER Azautoacct
Azure Automation Account (Extension Deloyemnt)
.PARAMETER Profile
Name of local json file to store profile in
.PARAMETER LBType
Load Balancer Type
.PARAMETER IntLBName
Load Balancer Name
.PARAMETER ExtLBName
Load Balancer Name
.PARAMETER LBSubnet
Internal Local Balancer Subnet
.PARAMETER LBPvtIp
Internal Local Balancer IP
.PARAMETER AddLB
Adds Load Balancer to VM NIC
.PARAMETER CreateIntLoadBalancer
Creates a new Internal Load Balancer
.PARAMETER CreateExtLoadBalancer
Creates a new external Load Balancer
.PARAMETER extname
Configures Extension Type to Remove or Deploy
.PARAMETER AddExtension
Adds Extension
.PARAMETER BatchAddExtension
Based on csv adds extension
.PARAMETER RemoveExtension
Removes Extension
.PARAMETER CustomScriptUpload
Name of custom script to upload and deploy
.PARAMETER dscname
Name of DSC to deploy
.PARAMETER scriptname
Name of custom script to execute
.PARAMETER containername
Name of container to create in storage for custom scripts
.PARAMETER sharename
Name of Storage Share to Create
.PARAMETER sharedirectory
Name of storage share directory to create
.PARAMETER customextname
Name of script to execute
.PARAMETER scriptfolder
Name of local script folder to upload
.PARAMETER csvimport
Imports runtime parameters based on CSV
.PARAMETER csvfile
csvfile to reference
.PARAMETER addssh
leverages SSH key to deploy Linux SKU
.PARAMETER publicsshkey
Public SSH Key String
.PARAMETER vmstrtype
Allows user to specify 'managed' (for managed disk) or unmanaged (for blob storage)
.PARAMETER usexiststorage
Allows user specify an existing storage account for VM deployment

.PARAMETER help

.EXAMPLE
\.AZRM-VMDeploy.ps1 -csvimport -csvfile C:\temp\iaasdeployment.csv
.EXAMPLE
\.AZRM-VMDeploy.ps1 -vmstrtype managed -vm pf001 -image pfsense -rg ResGroup1 -vnetrg ResGroup2 -addvnet -vnet VNET -sub1 3 -sub2 4 -ConfigIPs DualPvtNoPub -Nic1 10.120.2.7 -Nic2 10.120.3.7
.EXAMPLE
\.AZRM-VMDeploy.ps1 -vm red76 -image red67 -vmstrtype managed -rg ResGroup1 -vnetrg ResGroup2 -vnet VNET -sub1 7 -ConfigIPs SinglePvtNoPub -Nic1 10.120.6.124 -Ext linuxchefagent -addssh
.EXAMPLE
\.AZRM-VMDeploy.ps1 -vm win006 -image w2k12 -vmstrtype managed -rg ResGroup1 -vnetrg ResGroup2 -storerg storagerg -vnet VNET -sub1 2 -ConfigIPs Single -CreateNSG -NSGName NSG
.EXAMPLE
\.AZRM-VMDeploy.ps1 -vm win008 -image w2k16 -vmstrtype managed -rg ResGroup1 -vnetrg ResGroup2 -vnet VNET -sub1 5 -ConfigIPs PvtSingleStat -Nic1 10.120.4.169 -AddFQDN -fqdn mydns1
.EXAMPLE
\.AZRM-VMDeploy.ps1 -vm ubu004 -image ubuntu -vmstrtype managed -RG ResGroup1 -vnetrg ResGroup2 -VNet VNET -ConfigIPs Single -AddLB -LBType external -LBSubnet 2 -CreateLoadBalancer -LBName mylb -AddAvailabilitySet -AvailSetName myavsetname
.EXAMPLE
\.AZRM-VMDeploy.ps1 -vm ubu004 -image ubuntu -vmstrtype managed -RG ResGroup1 -vnetrg ResGroup2 -VNet VNET -ConfigIPs Single -AddLB -LBType internal -LBPvtIP 172.10.4.15 -CreateLoadBalancer -LBName mylb -AddAvailabilitySet -AvailSetName myavsetname
.EXAMPLE
\.AZRM-VMDeploy.ps1 -vm ubu001 -image ubuntu -vmstrtype managed -RG ResGroup1 -vnetrg ResGroup2 -VNet VNET -sub1 6 -ConfigIPs PvtSingleStat -Nic1 10.120.5.169 -AddFQDN fqdn mydns2 -addssh

.EXAMPLE
.\AZRM-VMDeploy.ps1 -ActionType update -UploadSharedFiles -StorageName test001str -rg resx
.NOTES
-ConfigIps  <Configuration>
			PvtSingleStat & PvtDualStat – Deploys the server with a Public IP and the private IP(s) specified by the user.
			NoPubSingle & NoPubDual - Deploys the server without Public IP using automatically generated private IP(s).
			Single & Dual – Deploys the default configuration of a Public IP and automatically generated private IP(s).
			StatPvtNoPubDual & StatPvtNoPubSingle – Deploys the server without a Public IP using the private IP(s) specified by the user.
-VMMarketImage <Image ShortName>

			Windows 2012 R2 – w2k12
			Windows 2008 R2 – w2k8
			Windows Ent 2016 – w2k16
			Windows Nano 2016 – nano
			SharePoint 2016 - Share2016
			SharePoint 2013 - share2013
			Biztalk 2013 Ent - biztalk2013
			Biztalk 2016 preview - biztalk2016
			TFS 2013 - tfs
			Visual Studio 2015 Ent on W2k12 r2 - vs2015
			Dev15 - Preview - dev15
			SQL Server 2016 (on Windows 2012 host) – sql2016
			PFSense 2.5 – pfsense
			Free BSD – free
			Suse – suse
			CentOs 7.2 – centos
			Ubuntu 14.04 – ubuntu14
			Ubuntu 16.04 – ubuntu16
			Redhat 6.7 – Red67
			Redhat 7.2 – Red72
			CheckPoint AppFirewall – check
			Chef Server v12 - 100 Client - chef-server
			Chef Compliance - 100 Client - chef-compliance
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
			Puppet Enterprise - puppet
			F5 BIG IP - f5bigip
			F5 Application Firewall - f5appfire
			Barracuda NG Firewall (hourly) - barrahourngfw
			Barracuda NG Firewall (BYOL) - barrabyolngfw
			Barracuda spam Firewall (hourly) - barrahourspam
			Barracuda spam Firewall (byol) - barrabyolspam
			Server R - serverr
			Hortonworks DataPlatform - horton-dp
			Incredibuild - Incredibuild
			Microsoft Ads - Data Science Standard Server - ads-datascience
			Microsoft Ads - Data Science Linux Server - ads-linuxdatascience
			Cloudera - cloudera
			DataStax - datastax
			Cloud-connector - cloud-conn
			Tableau Desktop - tableau
			metavistech O365 Suite - O365-suite
			Splunk - splunk
			Tenable Nessus BYOL - Nessus
			Debian 8 - debian
			Cloudbee Jenkins Ops Center - jenk-opcenter
			Cisco waas 750 - cisco750
			Citrix Netscaler - netscaler
			Tig Backup as a Service (Windows) - tig-windows
			Tig Backup as a Service (Linux) - tig-linux

-extname <Extension Type>
			winaccess – Adds Azure Access Extension – Added by default during VM creation
			msav – Adds Azure Antivirus Extension
			customscript – Adds Custom Script for Execution (Requires Table Storage Configuration first)
			linuxcustscript – Adds Custom Script for Execution (Requires Table Storage Configuration first)
			linuxpushdsc - Deploys DSC Configuration to Linux Azure VM
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
			addvmbackupvault - Add VM to ASR Backup Vault
.LINK
https://github.com/JonosGit/IaaSDeploymentTool

#>

[CmdletBinding(DefaultParameterSetName = 'default')]
Param(
[Parameter(Mandatory=$False,ValueFromPipelinebyPropertyName=$true,Position=0)]
[ValidateNotNullorEmpty()]
[Alias("storage")]
[ValidateSet("unmanaged","managed")]
[string]
$vmstrtype = 'unmanaged',
[Parameter(Mandatory=$False,ValueFromPipelinebyPropertyName=$true,Position=1)]
[ValidateNotNullorEmpty()]
[ValidateSet("w2k12","w2k8","w2k16","nano","sql2016","sql2014","biztalk2013","tfs","biztalk2016","vs2015","dev15","jenk-opcenter","chef-compliance","incredibuild","debian","puppet","msnav2016","red67","red72","suse","free","ubuntu14","ubuntu16","centos68","centos72","chef-server","check","pfsense","lamp","jenkins","nodejs","elastics","postgressql","splunk","horton-dp","serverr","horton-hdp","f5bigip","f5appfire","barrahourngfw","barrabyolngfw","barrahourspam","barrabyolspam","mysql","share2013","share2016","mongodb","nginxstack","hadoop","neos","tomcat","redis","gitlab","jruby","tableau","cloudera","datastax","O365-suite","ads-linuxdatascience","ads-datascience","cloud-conn","cisco750","CoreOS","CoreContainers")]
[Alias("image")]
[string]
$vmMarketImage = 'w2k12',
[Parameter(Mandatory=$False,ValueFromPipelinebyPropertyName=$true,Position=2)]
[ValidateNotNullorEmpty()]
[Alias("vm")]
[string]
$VMName = '',
[Parameter(Mandatory=$False,ValueFromPipelinebyPropertyName=$true,Position=3)]
[ValidateNotNullorEmpty()]
[string]
$rg = '',
[Parameter(Mandatory=$False,ValueFromPipelinebyPropertyName=$true)]
[ValidateSet("Single","Dual","NoPubDual","PvtDualStat","StatPvtNoPubSingle","PvtSingleStat","StatPvtNoPubDual","NoPubSingle")]
[ValidateNotNullorEmpty()]
[string]
$ConfigIPs = 'Single',
[Parameter(Mandatory=$False,ValueFromPipelinebyPropertyName=$true)]
[switch]
$AddVnet = $true,
[Parameter(Mandatory=$False,ValueFromPipelinebyPropertyName=$true,Position=4)]
[ValidateNotNullorEmpty()]
[Alias("vnet")]
[string]
$VNetName = '',
[Parameter(Mandatory=$False,ValueFromPipelinebyPropertyName=$true)]
[ValidateNotNullorEmpty()]
[string]
$vnetrg = $rg,
[Parameter(Mandatory=$False,ValueFromPipelinebyPropertyName=$true)]
[ValidateNotNullorEmpty()]
[string]
$storerg = $rg,
[Parameter(Mandatory=$False,ValueFromPipelinebyPropertyName=$true)]
[Alias("useazrmlogin")]
[switch]
$usermlogin,
[Parameter(Mandatory=$False,ValueFromPipelinebyPropertyName=$true)]
[ValidateNotNullorEmpty()]
[string]
$vnet2rg = '',
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
[Alias("lb")]
[switch]
$CreateLoadBalancer,
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
$LBName = '',
[Parameter(Mandatory=$False,ValueFromPipelinebyPropertyName=$true)]
[int]
$LBSubnet = '3',
[Parameter(Mandatory=$False,ValueFromPipelinebyPropertyName=$true)]
$LBPvtIp = '172.10.5.10',
[Parameter(Mandatory=$False,ValueFromPipelinebyPropertyName=$true)]
[ValidateNotNullorEmpty()]
[ValidateSet("Standard_A3","Standard_A4","Standard_A2")]
[string]
$VMSize = 'Standard_A3',
[Parameter(Mandatory=$False,ValueFromPipelinebyPropertyName=$true)]
[ValidateNotNullorEmpty()]
[string]
$locadmin = 'locadmin',
[Parameter(Mandatory=$false,ValueFromPipelinebyPropertyName=$true)]
[ValidateNotNullorEmpty()]
[string]
$locpassword = 'P@ssW0rd!',
[Parameter(Mandatory=$False,ValueFromPipelinebyPropertyName=$true)]
[ValidateNotNullorEmpty()]
[string]
$Location = 'westUs',
[Parameter(Mandatory=$False,ValueFromPipelinebyPropertyName=$true)]
[string]
$SubscriptionID = '',
[Parameter(Mandatory=$False,ValueFromPipelinebyPropertyName=$true)]
[string]
$TenantID = '',
[Parameter(Mandatory=$False)]
[string]
$GenerateName = -join ((65..90) + (97..122) | Get-Random -Count 6 | % {[char]$_}) + "rmp",
[Parameter(Mandatory=$False)]
[string]
$StorageName = $VMName + 'str',
[Parameter(Mandatory=$False)]
[string]
$mngdiskname = $VMName + 'OS',
[Parameter(Mandatory=$False,ValueFromPipelinebyPropertyName=$true)]
[ValidateSet("Standard_LRS","Standard_GRS","Premium_GRS")]
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
[Parameter(Mandatory=$False,ValueFromPipelinebyPropertyName=$true)]
[ValidateNotNullorEmpty()]
[string]
$NSGName = '',
[Parameter(Mandatory=$False,ValueFromPipelinebyPropertyName=$true)]
[ValidateRange(0,8)]
[Alias("sub1")]
[Int]
$Subnet1 = 2,
[Parameter(Mandatory=$False,ValueFromPipelinebyPropertyName=$true)]
[ValidateRange(0,8)]
[ValidateNotNullorEmpty()]
[Alias("sub2")]
[int]
$Subnet2 = 6,
[Parameter(Mandatory=$False,ValueFromPipelinebyPropertyName=$true)]
[Alias("avset")]
[switch]
$AddAvailabilitySet,
[Parameter(Mandatory=$False)]
[string]
$AvailSetName = $GenerateName,
[Parameter(Mandatory=$False,ValueFromPipelinebyPropertyName=$true)]
[Alias("fqdn")]
[string]
$DNLabel = 'mytesr1',
[Parameter(Mandatory=$False,ValueFromPipelinebyPropertyName=$true)]
[switch]
$AddFQDN,
[Parameter(Mandatory=$False,ValueFromPipelinebyPropertyName=$true)]
[ValidateNotNullorEmpty()]
[Alias("nic1")]
$PvtIPNic1 = '172.10.4.7',
[Parameter(Mandatory=$False,ValueFromPipelinebyPropertyName=$true)]
[ValidateNotNullorEmpty()]
[Alias("nic2")]
$PvtIPNic2 = '172.10.5.7',
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
$AddRange = '172.10.0.0/21',
[Parameter(Mandatory=$False,ValueFromPipelinebyPropertyName=$true)]
[string]
$SubnetAddPrefix1 = "172.10.0.0/24",
[Parameter(Mandatory=$False,ValueFromPipelinebyPropertyName=$true)]
[string]
$SubnetNameAddPrefix1 = "gatewaysubnet",
[Parameter(Mandatory=$False,ValueFromPipelinebyPropertyName=$true)]
[string]
$SubnetAddPrefix2 = "172.10.1.0/24",
[Parameter(Mandatory=$False,ValueFromPipelinebyPropertyName=$true)]
[string]
$SubnetNameAddPrefix2 = 'perimeter',
[Parameter(Mandatory=$False,ValueFromPipelinebyPropertyName=$true)]
[string]
$SubnetAddPrefix3 = "172.10.2.0/24",
[Parameter(Mandatory=$False,ValueFromPipelinebyPropertyName=$true)]
[string]
$SubnetNameAddPrefix3 = "web",
[Parameter(Mandatory=$False,ValueFromPipelinebyPropertyName=$true)]
[string]
$SubnetAddPrefix4 = "172.10.3.0/24",
[Parameter(Mandatory=$False,ValueFromPipelinebyPropertyName=$true)]
[string]
$SubnetNameAddPrefix4 = "application",
[Parameter(Mandatory=$False,ValueFromPipelinebyPropertyName=$true)]
[string]
$SubnetAddPrefix5 =  "172.10.4.0/24",
[Parameter(Mandatory=$False,ValueFromPipelinebyPropertyName=$true)]
[string]
$SubnetNameAddPrefix5 = "platform",
[Parameter(Mandatory=$False,ValueFromPipelinebyPropertyName=$true)]
[string]
$SubnetAddPrefix6 = "172.10.5.0/24",
[Parameter(Mandatory=$False,ValueFromPipelinebyPropertyName=$true)]
[string]
$SubnetNameAddPrefix6 = "monitoring",
[Parameter(Mandatory=$False,ValueFromPipelinebyPropertyName=$true)]
[string]
$Azautoacct = "Auto",
[Parameter(Mandatory=$False,ValueFromPipelinebyPropertyName=$true)]
[string]
$Profile = "profile",
[Parameter(Mandatory=$False,ValueFromPipelinebyPropertyName=$true)]
[ValidateSet("diag","msav","bginfo","winaccess","linaccess","linuxbackup","linuxospatch","linuxchefagent","windowschefagent","eset","customscript","linuxcustomscript","opsinsightLinux","opsinsightWin","WinPuppet","domjoin","RegisterAzDSC","winpushdsc","linuxpushdsc","addvmbackupvault")]
[Alias("ext")]
[string]
$extname = 'RegisterAzDSC',
[Parameter(Mandatory=$False,ValueFromPipelinebyPropertyName=$true)]
[Alias("addext")]
[switch]
$AddExtension,
[Parameter(Mandatory=$False,ValueFromPipelinebyPropertyName=$true)]
[Alias("uploadshare")]
[switch]
$UploadSharedFiles,
[Parameter(Mandatory=$False,ValueFromPipelinebyPropertyName=$true)]
[ValidateSet("True","False")]
[Alias("upload")]
[string]
$CustomScriptUpload = 'True',
[Parameter(Mandatory=$False,ValueFromPipelinebyPropertyName=$true)]
[Alias("addvmnsg")]
[switch]
$AddNSG,
[Parameter(Mandatory=$False,ValueFromPipelinebyPropertyName=$true)]
[Alias("dscfilename")]
[string]
$WinDSCConfig = 'WindowsUpdate',
[Parameter(Mandatory=$False,ValueFromPipelinebyPropertyName=$true)]
[Alias("configname")]
[string]
$ConfigurationName = '',
[Parameter(Mandatory=$False,ValueFromPipelinebyPropertyName=$true)]
[Alias("AzautoResGrp")]
[string]
$azautomrg = 'OMS',
[Parameter(Mandatory=$False,ValueFromPipelinebyPropertyName=$true)]
[Alias("customscriptname")]
[string]
$scriptname = 'installbase.sh',
[Parameter(Mandatory=$False,ValueFromPipelinebyPropertyName=$true)]
[string]
$dsccontainername = 'dscforlinux',
[Parameter(Mandatory=$False,ValueFromPipelinebyPropertyName=$true)]
[string]
$LinDSCConfig= 'localhost.mof',
[Parameter(Mandatory=$False,ValueFromPipelinebyPropertyName=$true)]
[Alias("customscriptname2")]
[string]
$scriptname2 = 'installchef.sh',
[Parameter(Mandatory=$False,ValueFromPipelinebyPropertyName=$true)]
[string]
$containername = 'scripts',
[Parameter(Mandatory=$False,ValueFromPipelinebyPropertyName=$true)]
[string]
$sharename = 'software',
[Parameter(Mandatory=$False,ValueFromPipelinebyPropertyName=$true)]
[string]
$sharedirectory = 'apps',
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
$localsoftwarefolder = "$scriptfolder\software",
[Parameter(Mandatory=$False,ValueFromPipelinebyPropertyName=$true)]
[switch]
$csvimport,
[Parameter(Mandatory=$False,ValueFromPipelinebyPropertyName=$true)]
[switch]
$addlbfqdn,
[Parameter(Mandatory=$False,ValueFromPipelinebyPropertyName=$true)]
[string]
$csvfile = -join $workfolder + "\test-vmdeploy-ha.csv",
[Parameter(Mandatory=$False,ValueFromPipelinebyPropertyName=$true)]
[Alias("h")]
[Alias("?")]
[switch]
$help,
[Parameter(Mandatory=$False,ValueFromPipelinebyPropertyName=$true)]
[string]
$BatchAddShare = 'False',
[Parameter(Mandatory=$False,ValueFromPipelinebyPropertyName=$true)]
[Alias("oobaddext")]
[switch]
$UpdateExtension,
[Parameter(Mandatory=$False,ValueFromPipelinebyPropertyName=$true)]
[string]
$BatchAddExtension = 'False',
[Parameter(Mandatory=$False,ValueFromPipelinebyPropertyName=$true)]
[string]
$BatchAddFQDN,
[Parameter(Mandatory=$False,ValueFromPipelinebyPropertyName=$true)]
[string]
$batchaddlbfqdn,
[Parameter(Mandatory=$False,ValueFromPipelinebyPropertyName=$true)]
[string]
$lbfqdn = 'rmpstgvip',
[Parameter(Mandatory=$False,ValueFromPipelinebyPropertyName=$true)]
[string]
$BatchAddNSG = 'False',
[Parameter(Mandatory=$False,ValueFromPipelinebyPropertyName=$true)]
[string]
$BatchCreateNSG = 'False',
[Parameter(Mandatory=$False,ValueFromPipelinebyPropertyName=$true)]
[string]
$BatchAddVnet = 'False',
[Parameter(Mandatory=$False,ValueFromPipelinebyPropertyName=$true)]
[string]
$BatchAddAvSet = 'False',
[Parameter(Mandatory=$False,ValueFromPipelinebyPropertyName=$true)]
[string]
$BatchUpdateNSG = 'False',
[Parameter(Mandatory=$False,ValueFromPipelinebyPropertyName=$true)]
[string]
$BatchCreateLB = 'False',
[Parameter(Mandatory=$False,ValueFromPipelinebyPropertyName=$true)]
[string]
$BatchAddLB = 'False',
[Parameter(Mandatory=$False,ValueFromPipelinebyPropertyName=$true)]
[ValidateSet("vm","vnet","rg","nsg","storage","availabilityset","extension","loadbalancer")]
[string]
$RemoveObject = '',
[Parameter(Mandatory=$False,ValueFromPipelinebyPropertyName=$true)]
[string]
$remscriptpath =  '.\AZRM-RemoveResource.ps1',
[Parameter(Mandatory=$False,ValueFromPipelinebyPropertyName=$true)]
[string]
$extscriptpath = '.\Azrm-ExtDeploy.ps1',
[Parameter(Mandatory=$False,ValueFromPipelinebyPropertyName=$true)]
[string]
$vnetscriptpath = '.\AzRm-VNETDeploy.ps1',
[Parameter(Mandatory=$False,ValueFromPipelinebyPropertyName=$true)]
[switch]
$addssh,
[Parameter(Mandatory=$False,ValueFromPipelinebyPropertyName=$true)]
[string]
$batchaddssh = 'False',
[Parameter(Mandatory=$False,ValueFromPipelinebyPropertyName=$true)]
[string]
$batchaddmngdatadisk = 'False',
[Parameter(Mandatory=$False,ValueFromPipelinebyPropertyName=$true)]
[string]
$mngdiskdatatype = 'StandardLRS',
[Parameter(Mandatory=$False,ValueFromPipelinebyPropertyName=$true)]
[string]
$mngdiskOStype = 'StandardLRS',
[Parameter(Mandatory=$False,ValueFromPipelinebyPropertyName=$true)]
[int]
$mngdiskOSsize = '128',
[Parameter(Mandatory=$False,ValueFromPipelinebyPropertyName=$true)]
[int]
$mngdiskdatasize = '128',
[Parameter(Mandatory=$False,ValueFromPipelinebyPropertyName=$true)]
[string]
$mngdiskdataostype = 'windows',
[Parameter(Mandatory=$False,ValueFromPipelinebyPropertyName=$true)]
[string]
$mngdiskdatacreateopt = 'Empty',
[Parameter(Mandatory=$False,ValueFromPipelinebyPropertyName=$true)]
[string]
$mngdiskdataname = $VMName + '_datadisk',
[Parameter(Mandatory=$False,ValueFromPipelinebyPropertyName=$true)]
[switch]
$addmngdatadisk,
[Parameter(Mandatory=$False,ValueFromPipelinebyPropertyName=$true)]
[switch]
$summaryinfo,
[Parameter(Mandatory=$False,ValueFromPipelinebyPropertyName=$false)]
[string]
$DiskOSType = 'Linux',
[Parameter(Mandatory=$False,ValueFromPipelinebyPropertyName=$true)]
[switch]
$useexiststorage,
[Parameter(Mandatory=$False,ValueFromPipelinebyPropertyName=$true)]
[switch]
$preview,
[Parameter(Mandatory=$False,ValueFromPipelinebyPropertyName=$true)]
[string]
$batchuseexistingstorage = 'False',
[Parameter(Mandatory=$False,ValueFromPipelinebyPropertyName=$true)]
[string]
$chefvalidationpem = "",
[Parameter(Mandatory=$False,ValueFromPipelinebyPropertyName=$true)]
[string]
$chefclientrb =  "",
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
$vaultname = 'rmpbackup',
[Parameter(Mandatory=$False,ValueFromPipelinebyPropertyName=$true)]
[string]
$vaultrg = 'rmp-vault',
[Parameter(Mandatory=$False,ValueFromPipelinebyPropertyName=$true)]
[string]
$policyname = 'rmppolicy',
[Parameter(Mandatory=$False)]
[ValidateNotNullorEmpty()]
[ValidateSet("create")]
[Alias("action")]
[string]
$ActionType = 'create'
)

$sshPublicKey = Get-Content '.\Pspub.txt'

$SecureLocPassword = new-object -typename system.security.securestring
$SecureLocPassword = Convertto-SecureString $locpassword –asplaintext -Force
$Credential1 = New-Object -typename System.Management.Automation.PSCredential -argumentlist $locadmin,$SecureLocPassword

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
  Add-AzureRmAccount
  Save-AzureRmContext -Path $ProfileFile -Force
  Write-Host "Saved Profile to $ProfileFile"
  exit
  }
}
#endregion

Function Login-AddAzureRmProfile
{
Add-AzureRmAccount -WarningAction SilentlyContinue
}

#region User Help
Function Help-User {
Write-Host "Don't know where to start? Here are some examples:"
Write-Host "                                                       "
Write-Host "Deploy PFSense"
Write-Host "azurerm_vmdeploy.ps1 -ActionType Create -vm pf001 -image pfsense -rg ResGroup1 -vnetrg ResGroup2 -vnet VNET -ConfigIPs DualPvtNoPub -Nic1 10.120.2.7 -Nic2 10.120.3.7"
Write-Host "Deploy RedHat"
Write-Host "azurerm_vmdeploy.ps1 -ActionType Create -vm red76 -image red67 -rg ResGroup1 -vnetrg ResGroup2 -vnet VNET -ConfigIPs SinglePvtNoPub -Nic1 10.120.6.124 -Ext linuxbackup"
Write-Host "Deploy Windows 2012"
Write-Host "azurerm_vmdeploy.ps1  -ActionType Create -vm win006 -image w2k12 -rg ResGroup1 -vnetrg ResGroup2 -vnet VNET -ConfigIPs Single -AvSet -CreateNSG -NSGName NSG"
Write-Host "Deploy Windows 2016"
Write-Host "azurerm_vmdeploy.ps1 -ActionType Create -vm win008 -image w2k16 -rg ResGroup1 -vnetrg ResGroup2 -vnet VNET -ConfigIPs PvtSingleStat -Nic1 10.120.4.169"
Write-Host "Deploy Ubuntu"
Write-Host "azurerm_vmdeploy.ps1 -ActionType Create -vm ubu001 -image ubuntu -RG ResGroup1 -vnetrg ResGroup2 -VNet VNET -ConfigIPs PvtSingleStat -Nic1 10.120.5.169 -AddFQDN fqdn mydns2"
Write-Host "Remove VM:"
Write-Host "azurerm_vmdeploy.ps1 -ActionType Remove -vm ubu001 -RG ResGroup1 -RemoveObject VM"
Write-Host "Remove RG:"
Write-Host "azurerm_vmdeploy.ps1 -ActionType Remove -RG ResGroup1 -RemoveObject rg"
Write-Host "                                                       "
Write-Host "Required command switches"

Write-Host "              -actiontype - type of action to perform"
Write-Host "              -vmname - Name of VM to create"
Write-Host "              -configips - configures network interfaces"
Write-Host "              -VMMarketImage - Image type to deploy"
Write-Host "              -rg - Resource Group"
Write-Host "              -vnetrg - VNET Resource Group"
Write-Host "              -vnetname - VNET Name"
Write-Host "                                                       "
Write-Host "Important command switches"
Write-Host "             -addvnet - adds new VNET"
Write-Host "             -CreateNSG - adds new NSG/Configures VM to use existing NSG"
Write-Host "             -addavailabilityset - adds new Availability Set"
Write-Host "             -addfqdn - adds FQDN to Public IP address of VM"
Write-Host "             -addextension - adds VM extension"
Write-Host "                                                       "
}
#endregion

#region Create Log
Function Log-Command
([string]$Description, [string]$logFile, [string]$VMName)
{
$Output = $LogOut+'. '
Write-Host $Output -ForegroundColor white
((Get-Date -UFormat "[%d-%m-%Y %H:%M:%S] ") + $Output) | Out-File -FilePath $LogOutFile -Append -Force
}
#endregion

#region Use CSV
Function csv-run {
param(
[string] $csvin = $csvfile,
[bool] $BatchAddVnet)
try {
	$GetPath = test-path -Path $csvin
	if(!$GetPath)
	{ exit }
	else {
	Write-Host "Located $csvin. CSV import starting..."
		import-csv -Path $csvin -Delimiter ',' | ForEach-Object{.\AZRM-VMDeploy.ps1 -ActionType $_.ActionType -VMName $_.VMName -vmMarketImage $_.Image -rg $_.rg -vNetrg $_.vnetrg -VNetName $_.VNetName -ConfigIPs $_.ConfigIPs -subnet1 $_.Subnet1 -subnet2 $_.Subnet2 -PvtIPNic1 $_.PvtIPNic1 -PvtIPNic2 $_.PvtIPNic2 -DNLabel $_.DNLabel -BatchAddVnet $_.BatchAddVnet -BatchCreateLB $_.BatchCreateLB -BatchAddLB $_.BatchAddLB -LBSubnet $_.LBSubnet -LBPvtIp $_.LBPvtIp -LBName $_.LBName -LBType $_.LBType -BatchAddNSG $_.BatchAddNSG -BatchCreateNSG $_.BatchCreateNSG -NSGName $_.NSGName -extname $_.extname -BatchAddExtension $_.BatchAddExtension -BatchAddAvSet $_.BatchAddAvSet -AvailSetName $_.AvailSetName -BatchAddFqdn $_.BatchAddFqdn -CustomScriptUpload $_.CustomScriptUpload -scriptname $_.scriptname -containername $_.containername -scriptfolder $_.scriptfolder -customextname $_.customextname -batchAddShare $_.BatchAddShare -sharedirectory $_.sharedirectory -sharename $_.sharename -localsoftwarefolder $_.localsoftwarefolder -ConfigurationName $_.ConfigurationName -vmstrtype $_.vmstrtype -storerg $_.storerg -Batchaddmngdatadisk $_.Batchadddatadisk -Batchaddssh $_.Batchaddssh -linuxpatchtype $_.linuxpatchtype -batchuseexistingstorage $_.batchuseexistingstorage -batchaddlbfqdn $_.batchaddlbfqdn -lbfqdn $_.lbfqdn -WinDSCConfig $_.WinDSCConfig -LinDSCConfig $_.LinDSCConfig }
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

Function Lb-type {
if(!$LBName)
{
if($LBType -eq 'external' -or $BatchAddLB -eq 'external'){$LBName = $LBName
Write-Host "Setting LBName to $LBName"
}
	elseif($LBType -eq 'internal' -or $BatchAddLB -eq 'internal'){$LBName = $LBName
	Write-Host "Setting LBName to $LBName"
	}
}
}
#region Verify IP
Function Verify-PvtIp {
		if($PvtIPNic1)
			{
			[int]$subnet = $Subnet1
			$ip = $PvtIPNic1
			$array = $ip.Split(".")
			[int]$subnetint0 = $array[3]
			[int]$subnetint = $array[2]
			[int]$subnetcalc = ($subnetint)
				if($subnetcalc -ne $subnet){
					$script:Subnet1 = $subnetcalc
					Write-Host "Updating Subnet1 to correct subnet"
					Write-Host "Subnet1: $script:Subnet1"
				}
			else
			{
			Write-Host "correct subnet"
			$script:Subnet1 = $Subnet1
			}
	}
}

Function Verify-PvtIp2 {
if($PvtIPNic2)
			{
			[int]$subnet = $Subnet2
			$ip = $PvtIPNic2
			$array = $ip.Split(".")
			[int]$subnetint = $array[2]
			[int]$subnetcalc = ($subnetint)
				if($subnetcalc -ne $subnet){
					$script:Subnet2 = $subnetcalc
					Write-Host "Updating Subnet2 to correct subnet"
					Write-Host "Subnet1: $script:Subnet2"
			}
			else
			{
			Write-Host "Correct subnet verified"
			$script:Subnet2 = $Subnet2
			}
	}
}

Function Verify-LBSubnet {
if($CreateLoadBalancer -or $BatchCreateLB -eq 'True' -and $LBType -eq 'internal')
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
			Write-Host "Correct subnet verified"
			$script:LBSubnet = $LBSubnet
			}
	}
}

Function Verify-NIC {
	If ($ConfigIPs -eq "StatPvtNoPubSingle")
	{
		Write-Host "Subnet IP Validation" -ForegroundColor White
		Verify-PvtIp
	}
	If ($ConfigIPs -eq "StatPvtNoPubDual")
	{
		Write-Host "Subnet IP Validation" -ForegroundColor White
		Verify-PvtIp
		Verify-PvtIp2
	}
	If ($ConfigIPs -eq "Single")
	{
		Write-Host "Dynamic IP - Skipping Subnet IP Validation"
		if($Subnet1 -le 0)
		{$subnet1 = 1}
		$script:Subnet1 = $Subnet1
	}
	If ($ConfigIPs -eq "NoPubSingle")
	{
		Write-Host "Dynamic IP - Skipping Subnet IP Validation"
		if($Subnet1 -le 0)
		{$subnet1 = 1}
		$script:Subnet1 = $Subnet1
	}
	If ($ConfigIPs -eq "NoPubDual")
	{
		Write-Host "Dynamic IP - Skipping Subnet IP Validation"
		if($Subnet1 -le 0){$subnet1 = 0}
		if($Subnet2 -le 0){$subnet2 = 1}
		$script:Subnet1 = $Subnet1
		$script:Subnet2 = $Subnet2
	}

	If ($ConfigIPs -eq "Dual")
	{
		Write-Host "Dynamic IP - Skipping Subnet IP Validation"
		if($Subnet1 -le 0){$subnet1 = 0}
		if($Subnet2 -le 0){$subnet2 = 1}
		$script:Subnet1 = $Subnet1
		$script:Subnet2 = $Subnet2
	}
	If ($ConfigIPs -eq "PvtSingleStat")
	{
		Write-Host "Subnet IP Validation"
		Verify-PvtIp
	}
	If ($ConfigIPs -eq "PvtDualStat")
	{
		Write-Host "Subnet IP Validation"
		Verify-PvtIp
		Verify-PvtIp2
	}
}
#endregion

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

Function Create-VnetPeering {
	param(
[string]$vnetName_1 = $VNetName,
[string]$vnetName_2 = $VNetName2,
[string]$vnetrg = $vnetrg
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
Add-AzureRmVirtualNetworkPeering -name peer1 -VirtualNetwork $vnet1 -RemoteVirtualNetworkId $vnet2.id
Add-AzureRmVirtualNetworkPeering -name peer2 -VirtualNetwork $vnet2 -RemoteVirtualNetworkId $vnet1.id

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

Function Vnet-Peering {
	param(
[string]$vnetName_1 = $VNetName,
[string]$vnetName_2 = $VNetName2,
[string]$vnetrg = $vnetrg,
[string]$peer1 = 'peer1',
[string]$peer2 = 'peer2'
	)
# Enable vnet peering
Register-AzureRmProviderFeature -FeatureName AllowVnetPeering -ProviderNamespace Microsoft.Network -Confirm:$false -WarningAction SilentlyContinue
Register-AzureRmResourceProvider -ProviderNamespace Microsoft.Network -Confirm:$false -WarningAction SilentlyContinue

# Get vnet properties
$vnet1 = Get-AzureRmVirtualNetwork -ResourceGroupName $vnetrg -Name $vnetName_1 -WarningAction SilentlyContinue -ErrorAction Stop | Out-Null
$vnet2 = Get-AzureRmVirtualNetwork -ResourceGroupName $vnetrg -Name $vnetName_2 -WarningAction SilentlyContinue -ErrorAction Stop | Out-Null

# Create link between vnets
Add-AzureRmVirtualNetworkPeering -name $peer1 -VirtualNetwork $vnet1 -RemoteVirtualNetworkId $vnet2.id -WarningAction SilentlyContinue -ErrorAction Stop | Out-Null
Add-AzureRmVirtualNetworkPeering -name $peer2 -VirtualNetwork $vnet2 -RemoteVirtualNetworkId $vnet1.id -WarningAction SilentlyContinue -ErrorAction Stop | Out-Null

$LogOut = "Completed Network Peering Configuration of $VNetName and $VnetName2"
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

Function Verify-SubnetIndex {
	param(
	[Parameter(Mandatory=$False,ValueFromPipelinebyPropertyName=$true,Position=0)]
	[int]$Subnet,
	[Parameter(Mandatory=$False,ValueFromPipelinebyPropertyName=$true)]
	[string]$vnetrg = $vnetrg,
	[Parameter(Mandatory=$False,ValueFromPipelinebyPropertyName=$true)]
	[string]$rg = $rg
	)

$myvnet = Get-AzureRMVirtualNetwork -Name $VNetName -ResourceGroupName $vnetrg | Set-AzureRmVirtualNetwork
$subcnt = $myvnet.Subnets.Count
$retsubnet = $myvnet.Subnets[$Subnet]
$name = $retsubnet.Name
$pre = $retsubnet.AddressPrefix

Write-Host "VNET Subnet Name: $name "
Write-Host "VNET Subnet Prefix: $pre"
}

Function Check-Vnet {
$vnetexists = Get-AzureRmVirtualNetwork -Name $VNetName -ResourceGroupName $vnetrg -ErrorAction SilentlyContinue -WarningAction SilentlyContinue
if(!$vnetexists)
	{Create-Vnet}
	else
		{ $existvnet = Get-AzureRmVirtualNetwork -Name $VNetName -ResourceGroupName $vnetrg

			$addspace = $existvnet.AddressSpace | Select-Object -ExpandProperty AddressPrefixes
			$namespace = $existvnet.Name
			$existvnet = Get-AzureRmVirtualNetwork -Name $VNetName -ResourceGroupName $vnetrg
			$addsubnet = Get-AzureRmVirtualNetworkSubnetConfig -VirtualNetwork $existvnet

			$sub = $addsubnet.AddressPrefix
			$subname = $addsubnet.Name
			$nsg = $addsubnet.NetworkSecurityGroup
			$subnet = Get-AzureRmVirtualNetworkSubnetConfig -VirtualNetwork $existvnet | ft Name,AddressPrefix -AutoSize -Wrap -HideTableHeaders
			Write-Host "                                                               "
			Write-Host "VNET CONFIGURATION - Existing VNET" -ForegroundColor Cyan
			Write-Host "                                                               "
			Write-Host "Active VNET: $VnetName in resource group $vnetrg"
			Write-Host "Address Space: $addspace "
			Write-Host "Subnet Ranges: $sub "
			Write-Host "Subnet Names: $subname "
		}
}

Function Check-VnetPreview {
$vnetexists = Get-AzureRmVirtualNetwork -Name $VNetName -ResourceGroupName $vnetrg -ErrorAction SilentlyContinue -WarningAction SilentlyContinue
if(!$vnetexists)
	{ Write-ConfigVnetPreview }
	else
		{ $existvnet = Get-AzureRmVirtualNetwork -Name $VNetName -ResourceGroupName $vnetrg

			$addspace = $existvnet.AddressSpace | Select-Object -ExpandProperty AddressPrefixes
			$namespace = $existvnet.Name
			$existvnet = Get-AzureRmVirtualNetwork -Name $VNetName -ResourceGroupName $vnetrg
			$addsubnet = Get-AzureRmVirtualNetworkSubnetConfig -VirtualNetwork $existvnet

			$sub = $addsubnet.AddressPrefix
			$subname = $addsubnet.Name
			$nsg = $addsubnet.NetworkSecurityGroup
			$subnet = Get-AzureRmVirtualNetworkSubnetConfig -VirtualNetwork $existvnet | ft Name,AddressPrefix -AutoSize -Wrap -HideTableHeaders
			Write-Host "                                                               "
			Write-Host "PREVIEW VNET CONFIGURATION - Existing VNET" -ForegroundColor Cyan
			Write-Host "                                                               "
			Write-Host "Active VNET: $VnetName in resource group $vnetrg"
			Write-Host "Address Space: $addspace "
			Write-Host "Subnet Ranges: $sub "
			Write-Host "Subnet Names: $subname "
		}
}

Function Check-NSG-NoMsg {
$nsgexists = Get-AzureRmNetworkSecurityGroup -ResourceGroupName $vnetrg -Name $NSGName
if(!$nsgexists)
	{ break }
	else
		{
			$existnsg = Get-AzureRmNetworkSecurityGroup -Name $NSGName -ResourceGroupName $vnetrg | Set-AzureRmNetworkSecurityGroup
			Write-Host "VM NSG: $NSGName "
			 }
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
}

Function Check-NSG-Msg {
$nsgexists = Get-AzureRmNetworkSecurityGroup -ResourceGroupName $vnetrg -Name $NSGName
if(!$nsgexists)
	{ break }
	else
		{
			$existnsg = Get-AzureRmNetworkSecurityGroup -Name $NSGName -ResourceGroupName $vnetrg | Set-AzureRmNetworkSecurityGroup
			$defrules = $existnsg.DefaultSecurityRules | ft Name,DestinationPortRange,SourcePortRange,Description,Access,Direction,Priority,Protocol
			$defrules | Format-Table
			$secrules = Get-AzureRmNetworkSecurityGroup -Name $NSGName -ResourceGroupName $vnetrg | Get-AzureRmNetworkSecurityRuleConfig | Ft Name,Description,Direction,SourcePortRange,DestinationPortRange,DestinationPortRange,SourceAddressPrefix,Access | Format-Table | Out-Null
			$defsecrules = Get-AzureRmNetworkSecurityGroup -Name $NSGName -ResourceGroupName $vnetrg | Get-AzureRmNetworkSecurityRuleConfig -DefaultRules | Format-Table
			 }
}

Function Check-Vnet-NoMsg {
$vnetexists = Get-AzureRmVirtualNetwork -Name $VNetName -ResourceGroupName $vnetrg -ErrorAction SilentlyContinue -WarningAction SilentlyContinue
if(!$vnetexists)
	{Create-Vnet}
	else
		{ $existvnet = Get-AzureRmVirtualNetwork -Name $VNetName -ResourceGroupName $vnetrg
			Write-Host "starting vm deployment to $VnetName"
			 }
}

#region Check Values of runtime params
function Check-NullValues {
if(!$rg) {
Write-Host "Please Enter Resource Group Name -rg"  -ForegroundColor Red
exit
}
	elseif(!$VMName) {
	Write-Host "Please Enter -vmName" -ForegroundColor Red
	exit
	}
				elseif(!$Location) {
				Write-Host "Please Enter -Location" -ForegroundColor Red
				exit
				}
						elseif(!$VNetName) {
						Write-Host "Please Enter -vnetname" -ForegroundColor Red
						exit
				}
							elseif(!$vmstrtype) {
						Write-Host "Please Enter -vmstrtype" -ForegroundColor Red
						exit
				}
}

function Check-linuxos-NullValues {
if($extname -eq 'linuxospatch' -and !$linuxpatchtype) {
Write-Host "Please select -linuxpatchtype"
exit
}
	elseif($extname -eq 'linuxospatch' -and $linuxpatchtype -eq 'oneoff') {
	Write-Host "Deploying Linux OS Patch - One Off"
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
	Write-Host "Please Enter -rg RG Name"
	exit
	}
	elseif($RemoveExtension -and !$VMName) {
	Write-Host "Please Enter -vmname VM Name"
	exit
	}
}

function Check-AvailabilitySet {
if($AddAvailabilitySet -and !$AvailSetName) {
Write-Host "Please Enter AvailabilitySet Name -availset"
exit
 }
}
function Check-LBAvSet {
if($AddLB -and !$AvailSetName) {
Write-Host "Please Enter AvailabilitySet Name -availset"
exit
 }
}

function Check-FQDN {
if($AddFQDN -and !$DNLabel) {
Write-Host "Please Enter Public FQDN -fqdn"
exit
 }
}

function Check-NSGName {
if($CreateNSG -and !$NSGName) {
Write-Host "Please Enter NSG Name -nsgname"
exit
 }
}

function Check-Extension {
if($AddExtension -and !$extname) {
Write-Host "Please Enter Extension Name"
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
if($CreateLoadBalancer -and !$LBType) {
Write-Host "Please Enter Internal LB Type"
exit
 }
	elseif($CreateLoadBalancer -and !$AddAvailabilitySet)
			{
		Write-Host "Availability Set Required for LB -addavailabilityset"
		exit
		 }
		elseif($CreateLoadBalancer -and !$AvailSetName)
				{
		Write-Host "Availability Set Required for LB -availsetname"
			exit
			 }
}

function Check-CreateIntLB {
if($CreateLoadBalancer -and !$LBType) {
Write-Host "Please Enter Internal LB Type"
exit
 }
	elseif($CreateLoadBalancer -and !$LBPvtIp)
			{
		Write-Host "Please Enter Internal LB Pvt IP"
		exit
		 }
		elseif($CreateLoadBalancer -and !$LBSubnet)
				{
			Write-Host "Please Enter Internal LB Subnet"
			exit
			 }
}
#endregion
#region Show DNS
Function Configure-PubIpDNS {
	param(
	[string]$vnetrg = $vnetrg,
	[string]$Location = $Location,
	[string]$rg = $rg,
	[string]$InterfaceName1 = $InterfaceName1,
	[string]$DNLabel = $DNLabel
	)

	Try
	{
if($AddFQDN -or $BatchAddFQDN -eq 'True')
{
	$script:PIp = New-AzureRmPublicIpAddress -Name $InterfaceName1 -ResourceGroupName $rg -Location $Location -AllocationMethod "Dynamic" -DomainNameLabel $DNLabel.ToLower() –Confirm:$false -WarningAction SilentlyContinue  -ErrorAction Stop
	$LogOut = "Completed Public DNS record creation $DNLabel.$Location.cloudapp.azure.com"
	Log-Command -Description $LogOut -LogFile $LogOutFile
	}
	else
	{
	$script:PIp = New-AzureRmPublicIpAddress -Name $InterfaceName1 -ResourceGroupName $rg -Location $Location -AllocationMethod "Dynamic" –Confirm:$false -WarningAction SilentlyContinue  -ErrorAction Stop
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
#endregion

#region Configure Public DNS
Function Configure-PubDNS {
if($AddFQDN -or $BatchAddFQDN -eq 'True')
{
Write-Host "Creating FQDN: " $DNLabel.$Location.cloudapp.azure.com
}
else
{
Write-Host "No DNS Name Specified"
}
}
#endregion

Function Check-VMstrtype {
	Write-Host "$vmstrtype selected"
if($vmstrtype -eq 'unmanaged')
		{ Check-StorageName }
	elseif($vmstrtype -eq 'managed')
		{ Check-StorageName }
	 }

#region Check Storage
Function Check-StorageName
{
	param(
		[Parameter(Mandatory=$False,ValueFromPipelinebyPropertyName=$true)]
		[string]$StorageName  = $StorageName
	)
$extvm = Get-AzureRmVm -Name $VMName -ResourceGroupName $storerg -ErrorAction SilentlyContinue -WarningAction SilentlyContinue
	if($extvm) {
		Write-Host "Host VM Exists, verification failed" $VMName
		exit
	}
	if($useexiststorage)
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

#region Check Storage
Function Check-StorageNameNotExists
{
	param(
		[Parameter(Mandatory=$False,ValueFromPipelinebyPropertyName=$true)]
		[string]$StorageName  = $StorageName
	)

	$checkname =  Get-AzureRmStorageAccountNameAvailability -Name $StorageName | Select-Object -ExpandProperty NameAvailable
if($checkname -ne 'True') {
	Write-Host "Storage Account Name in use, using existing storage..."
	Start-Sleep 5
	$script:StorageNameVerified = $StorageName.ToLower()
	Write-Host "Storage Name Check Completed for:" $StorageNameVerified }
	else
		{
		$script:StorageNameVerified = $StorageName.ToLower()
		Write-Host "Storage Name Check Completed for:" $StorageNameVerified
		}
}
#endregion

#region Configure NICs
Function Configure-Nics {
	param(
	[Parameter(Mandatory=$False,ValueFromPipelinebyPropertyName=$true)]
	[string]$vnetrg = $vnetrg,
	[Parameter(Mandatory=$False,ValueFromPipelinebyPropertyName=$true)]
	[string]$Location = $Location,
	[Parameter(Mandatory=$False,ValueFromPipelinebyPropertyName=$true)]
	[string]$rg = $rg,
	[Parameter(Mandatory=$False,ValueFromPipelinebyPropertyName=$true)]
	[string]$InterfaceName1 = $InterfaceName1,
	[Parameter(Mandatory=$False,ValueFromPipelinebyPropertyName=$true)]
	[string]$InterfaceName2 = $InterfaceName2,
	[Parameter(Mandatory=$False,ValueFromPipelinebyPropertyName=$true)]
	[int]$Subnet1 = $script:Subnet1,
	[Parameter(Mandatory=$False,ValueFromPipelinebyPropertyName=$true)]
	[int]$Subnet2 = $script:Subnet2,
	[Parameter(Mandatory=$False,ValueFromPipelinebyPropertyName=$true)]
	[ipaddress]$PvtIPNic1 = $PvtIPNic1,
	[Parameter(Mandatory=$False,ValueFromPipelinebyPropertyName=$true)]
	[ipaddress]$PvtIPNic2 = $PvtIPNic2,
	[Parameter(Mandatory=$False,ValueFromPipelinebyPropertyName=$true)]
	[string]$ConfigIps = $ConfigIps
	)

	Try
	{
switch ($ConfigIPs)
	{
		"PvtDualStat" {
			Write-Host "Configuring dual static NICs (with Public IP)..."
			Configure-PubIpDNS
			$script:VNet = Get-AzureRMVirtualNetwork -Name $VNetName -ResourceGroupName $vnetrg | Set-AzureRmVirtualNetwork
			$script:Interface1 = New-AzureRmNetworkInterface -Name $InterfaceName1 -ResourceGroupName $rg -Location $Location -SubnetId $VNet.Subnets[$Subnet1].Id -PublicIpAddressId $PIp.Id -PrivateIpAddress $PvtIPNic1 –Confirm:$false -WarningAction SilentlyContinue  -ErrorAction Stop
			$script:Interface2 = New-AzureRmNetworkInterface -Name $InterfaceName2 -ResourceGroupName $rg -Location $Location -SubnetId $VNet.Subnets[$Subnet2].Id -PrivateIpAddress $PvtIPNic2 –Confirm:$false -WarningAction SilentlyContinue  -ErrorAction Stop

			$LogOut = "Completed configuration of dual static NICs: $VMName"
			Log-Command -Description $LogOut -LogFile $LogOutFile
}
		"PvtSingleStat" {
			Write-Host "Configuring single static NIC (with Public IP)..."
			Configure-PubIpDNS
			$script:VNet = Get-AzureRMVirtualNetwork -Name $VNetName -ResourceGroupName $vnetrg | Set-AzureRmVirtualNetwork
			$script:Interface1 = New-AzureRmNetworkInterface -Name $InterfaceName1 -ResourceGroupName $rg -Location $Location -SubnetId $VNet.Subnets[$Subnet1].Id -PublicIpAddressId $PIp.Id -PrivateIpAddress $PvtIPNic1 –Confirm:$false -WarningAction SilentlyContinue  -ErrorAction Stop
			$LogOut = "Completed configuration of single static NIC: $VMName"
			Log-Command -Description $LogOut -LogFile $LogOutFile
}
		"StatPvtNoPubDual" {
			Write-Host "Configuring dual static NICs (without Public IP)..."
			$script:VNet = Get-AzureRMVirtualNetwork -Name $VNetName -ResourceGroupName $vnetrg | Set-AzureRmVirtualNetwork
			$script:Interface1 = New-AzureRmNetworkInterface -Name $InterfaceName1 -ResourceGroupName $rg -Location $Location -SubnetId $VNet.Subnets[$Subnet1].Id -PrivateIpAddress $PvtIPNic1 –Confirm:$false -WarningAction SilentlyContinue  -ErrorAction Stop
			$script:Interface2 = New-AzureRmNetworkInterface -Name $InterfaceName2 -ResourceGroupName $rg -Location $Location -SubnetId $VNet.Subnets[$Subnet2].Id -PrivateIpAddress $PvtIPNic2 –Confirm:$false -WarningAction SilentlyContinue  -ErrorAction Stop
			$LogOut = "Completed configuration of dual static NICs: $VMName"
			Log-Command -Description $LogOut -LogFile $LogOutFile
}
		"StatPvtNoPubSingle" {
			Write-Host "Configuring single static NIC (without Public IP)..."
			$script:VNet = Get-AzureRMVirtualNetwork -Name $VNetName -ResourceGroupName $vnetrg | Set-AzureRmVirtualNetwork
			$script:Interface1 = New-AzureRmNetworkInterface -Name $InterfaceName1 -ResourceGroupName $rg -Location $Location -SubnetId $VNet.Subnets[$Subnet1].Id -PrivateIpAddress $PvtIPNic1 –Confirm:$false -WarningAction SilentlyContinue  -ErrorAction Stop
			$LogOut = "Completed configuration of single static NIC: $VMName"
			Log-Command -Description $LogOut -LogFile $LogOutFile
}
		"Single" {
			Write-Host "Configuring single NIC (with Public IP)..."
			Configure-PubIpDNS
			$script:VNet = Get-AzureRMVirtualNetwork -Name $VNetName -ResourceGroupName $vnetrg | Set-AzureRmVirtualNetwork
			$script:Interface1 = New-AzureRmNetworkInterface -Name $InterfaceName1 -ResourceGroupName $rg -Location $Location -SubnetId $VNet.Subnets[$Subnet1].Id -PublicIpAddressId $PIp.Id –Confirm:$false -WarningAction SilentlyContinue  -ErrorAction Stop -EnableIPForwarding
			$LogOut = "Completed configuration of single NIC: $VMName"
			Log-Command -Description $LogOut -LogFile $LogOutFile
}
		"Dual" {
			Write-Host "Configuring dual NICs (with Public IP)..."
			Configure-PubIpDNS
			$script:VNet = Get-AzureRMVirtualNetwork -Name $VNetName -ResourceGroupName $vnetrg | Set-AzureRmVirtualNetwork
			$script:Interface1 = New-AzureRmNetworkInterface -Name $InterfaceName1 -ResourceGroupName $rg -Location $Location -SubnetId $VNet.Subnets[$Subnet1].Id -PublicIpAddressId $PIp.Id –Confirm:$false -WarningAction SilentlyContinue  -ErrorAction Stop -EnableIPForwarding
			$script:Interface2 = New-AzureRmNetworkInterface -Name $InterfaceName2 -ResourceGroupName $rg -Location $Location -SubnetId $VNet.Subnets[$Subnet2].Id –Confirm:$false -WarningAction SilentlyContinue  -ErrorAction Stop
			$LogOut = "Completed configuration of dual NICs: $VMName"
			Log-Command -Description $LogOut -LogFile $LogOutFile
}
		"NoPubSingle" {
			Write-Host "Configuring single NIC (without Public IP)..."
			$script:VNet = Get-AzureRMVirtualNetwork -Name $VNetName -ResourceGroupName $vnetrg | Set-AzureRmVirtualNetwork
			$script:Interface1 = New-AzureRmNetworkInterface -Name $InterfaceName1 -ResourceGroupName $rg -Location $Location -SubnetId $VNet.Subnets[$Subnet1].Id –Confirm:$false -WarningAction SilentlyContinue  -ErrorAction Stop
			$LogOut = "Completed configuration of single NIC: $VMName"
			Log-Command -Description $LogOut -LogFile $LogOutFile
}
		"NoPubDual" {
			Write-Host "Configuring dual NICs (without Public IP)..."
			$script:VNet = Get-AzureRMVirtualNetwork -Name $VNetName -ResourceGroupName $vnetrg | Set-AzureRmVirtualNetwork
			$script:Interface1 = New-AzureRmNetworkInterface -Name $InterfaceName1 -ResourceGroupName $rg -Location $Location -SubnetId $VNet.Subnets[$Subnet1].Id –Confirm:$false -WarningAction SilentlyContinue  -ErrorAction Stop
			$script:Interface2 = New-AzureRmNetworkInterface -Name $InterfaceName2 -ResourceGroupName $rg -Location $Location -SubnetId $VNet.Subnets[$Subnet2].Id –Confirm:$false -WarningAction SilentlyContinue  -ErrorAction Stop
			$LogOut = "Completed configuration of dual NICs: $VMName"
			Log-Command -Description $LogOut -LogFile $LogOutFile
}
		"LoadBalancedDual" {
			Write-Host "Configuring load balanced dual NICs (without Public IP)..."
			$script:VNet = Get-AzureRMVirtualNetwork -Name $VNetName -ResourceGroupName $vnetrg | Set-AzureRmVirtualNetwork
			$script:besubnet =	Get-AzureRmVirtualNetworkSubnetConfig -Name $LBName -VirtualNetwork $script:VNet -WarningAction SilentlyContinue
			$script:Interface1 = New-AzureRmNetworkInterface -Name $InterfaceName1 -ResourceGroupName $rg -Location $Location -SubnetId $VNet.Subnets[$Subnet1].Id -PrivateIpAddress $PvtIPNic1 -LoadBalancerBackendAddressPool $lb.BackendAddressPools[0] -LoadBalancerInboundNatRule $lb.InboundNatRules[0]
			$script:Interface2 = New-AzureRmNetworkInterface -Name $InterfaceName2 -ResourceGroupName $rg -Location $Location -SubnetId $VNet.Subnets[$Subnet2].Id -PrivateIpAddress $PvtIPNic2 -LoadBalancerBackendAddressPool $lb.BackendAddressPools[0] -LoadBalancerInboundNatRule $lb.InboundNatRules[0] –Confirm:$false -WarningAction SilentlyContinue  -ErrorAction Stop
			$LogOut = "Completed configuration of load balanced dual NICs: $VMName"
			Log-Command -Description $LogOut -LogFile $LogOutFile
}
		"LoadBalancedSingle" {
			Write-Host "Configuring load balkanced single NIC (without Public IP)..."
			$script:VNet = Get-AzureRMVirtualNetwork -Name $VNetName -ResourceGroupName $vnetrg | Set-AzureRmVirtualNetwork
			$besubnet =	Get-AzureRmVirtualNetworkSubnetConfig -Name $LBName -VirtualNetwork $script:VNet -WarningAction SilentlyContinue
			$script:Interface1 = New-AzureRmNetworkInterface -Name $InterfaceName1 -ResourceGroupName $rg -Location $Location -Subnet $besubnet -PrivateIpAddress $PvtIPNic1 -LoadBalancerBackendAddressPool $lb.BackendAddressPools[0] -LoadBalancerInboundNatRule $lb.InboundNatRules[0]
			$LogOut = "Completed configuration of load balanced single NIC: $VMName"
			Log-Command -Description $LogOut -LogFile $LogOutFile
}
		default{"Nothing matched entry criteria"}
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
#endregion

#region Add Dual Nics
Function Add-NICs {
	Write-Host "Adding 2 Network Interface(s) $InterfaceName1 $InterfaceName2" -ForegroundColor White
	$script:VirtualMachine = Add-AzureRmVMNetworkInterface -VM $VirtualMachine -Id $script:Interface1.Id -Primary -WarningAction SilentlyContinue -ErrorAction Stop
	$script:VirtualMachine = Add-AzureRmVMNetworkInterface -VM $VirtualMachine -Id $script:Interface2.Id -WarningAction SilentlyContinue
	$LogOut = "Completed adding NICs $InterfaceName1 $InterfaceName2"
	Log-Command -Description $LogOut -LogFile $LogOutFile
}
#endregion

#region Add Single Nic
Function Add-NIC {
	Write-Host "Adding Network Interface $InterfaceName1" -ForegroundColor White
	$script:VirtualMachine = Add-AzureRmVMNetworkInterface -VM $VirtualMachine -Id $script:Interface1.Id -Primary -WarningAction SilentlyContinue  -ErrorAction Stop
	$LogOut = "Completed adding NIC $InterfaceName1"
	Log-Command -Description $LogOut -LogFile $LogOutFile
}
#endregion

#region Configure Single/Dual Homed
Function Set-NicConfiguration {
switch  ($ConfigIPs)
	{
		"PvtDualStat" {
Add-NICs
}
		"PvtSingleStat" {
Add-NIC
}
		"StatPvtNoPubDual" {
Add-NICs
}
		"StatPvtNoPubSingle" {
Add-NIC
}
		"Single" {
Add-NIC
}
		"Dual" {
Add-NICs
}
		"NoPubSingle" {
Add-NIC
}
		"NoPubDual" {
Add-NICs
}
		default{"An unsupported network configuration was referenced"
		break
					}
}
}
#endregion

#region Enable NSG
Function Configure-NSG
{
	param(
		$NSGName = $NSGName,
		$rg = $rg,
		$vnetrg = $vnetrg,
		$VMName = $VMName
	)

	Try
	{
	$nic1 = Get-AzureRmNetworkInterface -Name $InterfaceName1 -ResourceGroupName $rg -ErrorAction SilentlyContinue
	$nic2 = Get-AzureRmNetworkInterface -Name $InterfaceName2 -ResourceGroupName $rg -ErrorAction SilentlyContinue
		if($nic1)
		{
			$nsg = Get-AzureRmNetworkSecurityGroup -ResourceGroupName $vnetrg -Name $NSGName
			$nic = Get-AzureRmNetworkInterface -ResourceGroupName $rg -Name $InterfaceName1
			$nic.NetworkSecurityGroup = $nsg
			Set-AzureRmNetworkInterface -NetworkInterface $nic | Out-Null
			$LogOut = "Completed NSG update. Added $InterfaceName1 to $NSGName"
			Log-Command -Description $LogOut -LogFile $LogOutFile
		}
			if($nic2)
			{
				$nsg = Get-AzureRmNetworkSecurityGroup -ResourceGroupName $vnetrg -Name $NSGName
				$nic = Get-AzureRmNetworkInterface -ResourceGroupName $rg -Name $InterfaceName2
				$nic.NetworkSecurityGroup = $nsg
				Set-AzureRmNetworkInterface -NetworkInterface $nic | Out-Null
				$LogOut = "Completed NSG update. Added $InterfaceName2 to $NSGName"
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
#endregion

#region Configure LB Ext
Function Configure-extLB
{
	param(
		[string]$LBName = $LBName,
		[string]$frtendpool = 'frontend',
		[string]$backpool = 'backend'
	)

	Try

	{
	Lb-type
	$nic1 = Get-AzureRmNetworkInterface -Name $InterfaceName1 -ResourceGroupName $rg -ErrorAction SilentlyContinue
	$nic2 = Get-AzureRmNetworkInterface -Name $InterfaceName2 -ResourceGroupName $rg -ErrorAction SilentlyContinue

		if($nic1)
	{
				Write-Host "Configuring $InterfaceName1 for lb: $LBName"
		$lb = Get-AzureRmLoadBalancer -Name $LBName -ResourceGroupName $rg -WarningAction SilentlyContinue -ErrorAction Stop
		$backend = Get-AzureRmLoadBalancerBackendAddressPoolConfig -Name $backpool -LoadBalancer $lb -WarningAction SilentlyContinue
		$nic = $nic1
		$nic.IpConfigurations[0].LoadBalancerBackendAddressPools = $backend
		Set-AzureRmNetworkInterface -NetworkInterface $nic -WarningAction SilentlyContinue -ErrorAction Stop | Out-Null
		$LogOut = "Completed load balancer post deployment configuration. Added $InterfaceName1 to $LBName"
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
#endregion

#region Configure Internal LB
Function Configure-IntLB
{
	param(
		[string]$LBName = $LBName,
		[string]$frtendpool = 'frontend',
		[string]$backpool = 'backend'
	)

	Try
	{
	Lb-type
	$nic1 = Get-AzureRmNetworkInterface -Name $InterfaceName1 -ResourceGroupName $rg -ErrorAction SilentlyContinue
	$nic2 = Get-AzureRmNetworkInterface -Name $InterfaceName2 -ResourceGroupName $rg -ErrorAction SilentlyContinue

		if($nic1)
	{
				Write-Host "Configuring $InterfaceName1 for Load Balancer"
		$lb = Get-AzureRmLoadBalancer -Name $LBName -ResourceGroupName $rg -WarningAction SilentlyContinue -ErrorAction Stop
		$backend = Get-AzureRmLoadBalancerBackendAddressPoolConfig -Name $backpool -LoadBalancer $lb -WarningAction SilentlyContinue
		$nic = $nic1
		$nic.IpConfigurations[0].LoadBalancerBackendAddressPools = $backend
		Set-AzureRmNetworkInterface -NetworkInterface $nic -WarningAction SilentlyContinue -ErrorAction Stop | Out-Null
		$LogOut = "Completed Image Load Balancer Post Configuration. Added $InterfaceName1 to $LBName"
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
		Get-AzureRmPublicIpAddress -Name vpnpip -ResourceGroupName $rg -WarningAction SilentlyContinue
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

#region Nic Description
Function Select-NicDescrtipt {
if($ConfigIPs-EQ "Dual"){Write-Host "Dual Pvt IP & Public IP will be created" }
	elseif($ConfigIPs-EQ "Single"){Write-Host "Single Pvt IP & Public IP will be created" }
		elseif($ConfigIPs-EQ "PvtDualStat"){Write-Host "Dual Static Pvt IP & Public IP will be created" }
			elseif($ConfigIPs-EQ"PvtSingleStat"){Write-Host "Single Static Pvt IP & Public IP will be created" }
				elseif($ConfigIPs-EQ "SinglePvtNoPub"){Write-Host "Single Static Pvt IP & No Public IP" }
					elseif($ConfigIPs-EQ "StatPvtNoPubDual"){Write-Host "Dual Static Pvt IP & No Public IP"}
						elseif($ConfigIPs-EQ "StatPvtNoPubSingle"){Write-Host "Single Static Pvt IP & No Public IP"}
							elseif($ConfigIPs-EQ "NoPubDual"){Write-Host "Dual Pvt IP & No Public IP"}
								elseif($ConfigIPs-EQ "NoPubSingle"){Write-Host "Single Pvt IP & No Public IP"}
	else {
	Write-Host "No Network Config Found - Warning" -ForegroundColor Red
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
#endregion

#region Create Availability Set
Function Create-AvailabilitySet {
	param(
		[string]$rg = $rg,
		[string]$Location = $Location,
		[string]$AvailSetName = $AvailSetName
)
 try {
 If ($AddAvailabilitySet -or $BatchAddAvset -eq 'True')
 {
	Write-Host "Availability Set configuration in process.." -ForegroundColor White
	if($batchaddmngdatadisk -eq 'True')
	 {
		 New-AzureRmAvailabilitySet -ResourceGroupName $rg -Name $AvailSetName -Location $Location -WarningAction SilentlyContinue  -ErrorAction Stop -Sku 'Aligned' -PlatformUpdateDomainCount 3 -PlatformFaultDomainCount 3  | Out-Null
	$AddAvailabilitySet = (Get-AzureRmAvailabilitySet -ResourceGroupName $rg -Name $AvailSetName).Id
	$script:VirtualMachine = New-AzureRmVMConfig -VMName $VMName -VMSize $VMSize -AvailabilitySetID $AddAvailabilitySet -WarningAction SilentlyContinue
	$LogOut = "Completed Availability Set configuration $AvailSetName"
	Log-Command -Description $LogOut -LogFile $LogOutFile
	 }
	 elseif
	 ($addmngdatadisk)
	 {
	 New-AzureRmAvailabilitySet -ResourceGroupName $rg -Name $AvailSetName -Location $Location -WarningAction SilentlyContinue  -ErrorAction Stop -Sku 'Aligned' -PlatformUpdateDomainCount 3 -PlatformFaultDomainCount 3  | Out-Null
	$AddAvailabilitySet = (Get-AzureRmAvailabilitySet -ResourceGroupName $rg -Name $AvailSetName).Id
	$script:VirtualMachine = New-AzureRmVMConfig -VMName $VMName -VMSize $VMSize -AvailabilitySetID $AddAvailabilitySet -WarningAction SilentlyContinue
	$LogOut = "Completed Availability Set configuration $AvailSetName"
	Log-Command -Description $LogOut -LogFile $LogOutFile
	 }
	 elseif
	 ($vmstrtype -eq 'managed')
	 {
	 New-AzureRmAvailabilitySet -ResourceGroupName $rg -Name $AvailSetName -Location $Location -WarningAction SilentlyContinue  -ErrorAction Stop -Sku 'Aligned' -PlatformUpdateDomainCount 3 -PlatformFaultDomainCount 3 | Out-Null
	$AddAvailabilitySet = (Get-AzureRmAvailabilitySet -ResourceGroupName $rg -Name $AvailSetName).Id
	$script:VirtualMachine = New-AzureRmVMConfig -VMName $VMName -VMSize $VMSize -AvailabilitySetID $AddAvailabilitySet -WarningAction SilentlyContinue
	$LogOut = "Completed Availability Set configuration $AvailSetName"
	Log-Command -Description $LogOut -LogFile $LogOutFile
	 }
	 else
	 {	 New-AzureRmAvailabilitySet -ResourceGroupName $rg -Name $AvailSetName -Location $Location -WarningAction SilentlyContinue  -ErrorAction Stop | Out-Null
	$AddAvailabilitySet = (Get-AzureRmAvailabilitySet -ResourceGroupName $rg -Name $AvailSetName).Id
	$script:VirtualMachine = New-AzureRmVMConfig -VMName $VMName -VMSize $VMSize -AvailabilitySetID $AddAvailabilitySet -WarningAction SilentlyContinue
	Write-Host "Availability Set has been configured" -ForegroundColor White
	$LogOut = "Completed Availability Set configuration $AvailSetName"
	Log-Command -Description $LogOut -LogFile $LogOutFile }
}
else
{
	$script:VirtualMachine = New-AzureRmVMConfig -VMName $VMName -VMSize $VMSize -WarningAction SilentlyContinue -ErrorAction Stop
	$LogOut = "Skipped Availability Set Configuration"
	Log-Command -Description $LogOut -LogFile $LogOutFile
}
	}

catch {
	Write-Host -foregroundcolor Yellow `
	"Exception Encountered"; `
	$ErrorMessage = $_.Exception.Message
	$LogOut  = 'Error '+$ErrorMessage
	Log-Command -Description $LogOut -LogFile $LogOutFile
	break
}
 }
 #endregion

Function Add-SSHKey {
	param(
	[string]$sshkey = $sshPublicKey,
	[string]$sshcopypath = "/home/$locadmin/.ssh/authorized_keys",
	[string]$sshfilepath = '.\Pspub.txt'
	)

	Try
	{
	 $sshkeyexists = Test-Path -Path $sshfilepath
	 if($sshkeyexists)
	 { Add-AzureRmVMSshPublicKey -VM $VirtualMachine -KeyData $sshkey -Path $sshcopypath -ErrorAction Stop -WarningAction SilentlyContinue -InformationAction SilentlyContinue | Out-Null }
		 $LogOut = "Completed adding SSH Key"
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

#region Deploy VM
 function Provision-Vm {
	 param (
	[string]$rg = $rg,
	[string]$Location = $Location
	 )
	$ProvisionVMs = @($VirtualMachine);
try {
   foreach($provisionvm in $ProvisionVMs) {
	   if($addssh -or $batchaddssh -eq 'True')
	   { Add-SSHKey }
		New-AzureRmVM -ResourceGroupName $rg -Location $Location -VM $VirtualMachine -DisableBginfoExtension –Confirm:$false -WarningAction SilentlyContinue -ErrorAction Stop -InformationAction SilentlyContinue | Out-Null
		$LogOut = "Completed Creation of $VMName from $vmMarketImage"
		Log-Command -Description $LogOut -LogFile $LogOutFile
						}
	}
catch {
	Write-Host -foregroundcolor Yellow `
	"Exception Encountered"; `
	$ErrorMessage = $_.Exception.Message
	$LogOut  = 'Error '+$ErrorMessage
	Log-Command -Description $LogOut -LogFile $LogOutFile
	break
}
	 }
#endregion

Function Configure-Image-MngDisks {
	param(
	$mngstrtype = $mngdiskOStype,
	$mngdisksize = $mngdiskOSsize,
	$mngcreateoption = "FromImage"
	)

	Try
	{
		Write-Host "Completing managed disk image creation..." -ForegroundColor White
		$script:osDiskCaching = "ReadWrite"
		$script:OSDiskName = $VMName + "_OSDisk"
		$script:VirtualMachine = Set-AzureRmVMOSDisk -VM $script:VirtualMachine -DiskSizeInGB $mngdisksize -CreateOption $mngcreateoption -Caching $script:osDiskCaching -Name $script:OSDiskName -StorageAccountType $mngstrtype -WarningAction SilentlyContinue -InformationAction SilentlyContinue -ErrorAction Stop
		 $LogOut = "Completed managed disk creation $script:OSDiskName"
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

Function Create-MngDataDisks {
	param(
	$mngstrtype = $mngdiskdatatype,
	$mngdiskname = $mngdiskdataname,
	$mngdisksize = $mngdiskdatasize,
	$mngostype = $mngdiskdataostype,
	$mngdiskcreateopt = $mngdiskdatacreateopt
	)

	Try
	{
		$diskcfg = New-AzureRmDiskConfig -AccountType $mngstrtype -CreateOption $mngdiskcreateopt -DiskSizeGB $mngdisksize -Location $Location
		$dataDisk1 = New-AzureRmDisk -ResourceGroupName $rg -DiskName $mngdiskname -Disk $diskcfg;
		Write-Host "Completed managed data disk creation." -ForegroundColor White
		$vm = Get-AzureRmVM -Name $VMName -ResourceGroupName $rg -WarningAction SilentlyContinue -InformationAction SilentlyContinue -ErrorAction Stop

		$vm = Add-AzureRmVMDataDisk -VM $vm -Name $mngdiskdataname -CreateOption Attach -ManagedDiskId $dataDisk1.Id -Lun 1 -WarningAction SilentlyContinue -InformationAction SilentlyContinue -ErrorAction Stop

		Update-AzureRmVM -VM $vm -ResourceGroupName $rg -WarningAction SilentlyContinue -InformationAction SilentlyContinue -ErrorAction Stop
		$LogOut = "Completed managed disk attach $mngdiskname"
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

Function Configure-Image {
	Write-Host "Starting $vmstrtype disk configuration.."
if($vmstrtype -eq 'unmanaged')
		{ Configure-Image-Unmanaged }
	elseif($vmstrtype -eq 'managed')
		{ Configure-Image-MngDisks }
	 }

#region Configure Image
Function Configure-Image-Unmanaged {
	Try
	{
		Write-Host "Completing unmanaged storage image creation..." -ForegroundColor White
		$script:osDiskCaching = "ReadWrite"
		$script:createOption = "FromImage"
		$script:OSDiskName = $VMName + "OSDisk"
		$script:DataDiskName1 = $VMName + "Data1"
		$script:DataDiskName2 = $VMName + "Data2"

		$script:OSDiskUri = $StorageAccount.PrimaryEndpoints.Blob.ToString() + "vhds/" + $OSDiskName + ".vhd"
		$script:DataDiskUri1 = $StorageAccount.PrimaryEndpoints.Blob.ToString() + "vhds/" + $DataDiskName1 + ".vhd"
		$script:DataDiskUri2 = $StorageAccount.PrimaryEndpoints.Blob.ToString() + "vhds/" + $DataDiskName2 + ".vhd"

		$script:VirtualMachine = Add-AzureRmVMDataDisk -VM $VirtualMachine -Name 'Data1' -Caching ReadOnly -DiskSizeInGB '160' -Lun 0 -VhdUri $script:DataDiskUri1 -CreateOption Empty
		$script:VirtualMachine = Add-AzureRmVMDataDisk -VM $VirtualMachine -Name 'Data2' -Caching ReadOnly -DiskSizeInGB '160' -Lun 1 -VhdUri $script:DataDiskUri2 -CreateOption Empty

		$script:VirtualMachine = Set-AzureRmVMOSDisk -VM $VirtualMachine -Name $OSDiskName -VhdUri $OSDiskUri -CreateOption $script:createOption -Caching $osDiskCaching -WarningAction SilentlyContinue -InformationAction SilentlyContinue -ErrorAction Stop
		 $LogOut = "Completed unmanaged disk creation"
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

#region Image Lib
Function MakeImagePlanInfo_Bitnami_Lamp {
param(
	[string]$VMName = $VMName,
	[string]$Publisher = 'bitnami',
	[string]$offer = 'lampstack',
	[string]$Skus = '5-6',
	[string]$version = 'latest',
	[string]$Product = 'lampstack',
	[string]$name = '5-6'
)
	Write-Host "Image Creation in Process - Plan Info - LampStack" -ForegroundColor White
	Write-Host 'Publisher:'$Publisher 'Offer:'$offer 'Sku:'$Skus 'Version:'$version
	$script:VirtualMachine= Set-AzureRmVMPlan -VM $VirtualMachine -Name $name -Publisher $Publisher -Product $Product
	$script:VirtualMachine = Set-AzureRmVMOperatingSystem -VM $VirtualMachine -linux -ComputerName $VMName -Credential $Credential1
	$script:VirtualMachine = Set-AzureRmVMSourceImage -VM $VirtualMachine -PublisherName $Publisher -Offer $offer -Skus $Skus -Version $version
	$LogOut = "Completed image prep 'Publisher:'$Publisher 'Offer:'$offer 'Sku:'$Skus 'Version:'$version"
	Log-Command -Description $LogOut -LogFile $LogOutFile
	}
Function MakeImagePlanInfo_Bitnami_elastic {
param(
	[string]$VMName = $VMName,
	[string]$Publisher = 'bitnami',
	[string]$offer = 'elastic-search',
	[string]$Skus = '2-2',
	[string]$version = 'latest',
	[string]$Product = 'elastic-search',
	[string]$name = '2-2'
)
	Write-Host "Image Creation in Process - Plan Info - Elastic Search" -ForegroundColor White
	Write-Host 'Publisher:'$Publisher 'Offer:'$offer 'Sku:'$Skus 'Version:'$version
	$script:VirtualMachine= Set-AzureRmVMPlan -VM $VirtualMachine -Name $name -Publisher $Publisher -Product $Product
	$script:VirtualMachine = Set-AzureRmVMOperatingSystem -VM $VirtualMachine -linux -ComputerName $VMName -Credential $Credential1
	$script:VirtualMachine = Set-AzureRmVMSourceImage -VM $VirtualMachine -PublisherName $Publisher -Offer $offer -Skus $Skus -Version $version
}
Function MakeImagePlanInfo_Bitnami_jenkins {
param(
	[string]$VMName = $VMName,
	[string]$Publisher = 'bitnami',
	[string]$offer = 'jenkins',
	[string]$Skus = '1-650',
	[string]$version = 'latest',
	[string]$Product = 'jenkins',
	[string]$name = '1-650'
)
	Write-Host "Image Creation in Process - Plan Info - Jenkins" -ForegroundColor White
	Write-Host 'Publisher:'$Publisher 'Offer:'$offer 'Sku:'$Skus 'Version:'$version
	$script:VirtualMachine= Set-AzureRmVMPlan -VM $VirtualMachine -Name $name -Publisher $Publisher -Product $Product
	$script:VirtualMachine = Set-AzureRmVMOperatingSystem -VM $VirtualMachine -linux -ComputerName $VMName -Credential $Credential1
	$script:VirtualMachine = Set-AzureRmVMSourceImage -VM $VirtualMachine -PublisherName $Publisher -Offer $offer -Skus $Skus -Version $version
}

Function makeimage_withinfo_ti-ba-linuxbackupasaservice
{
param(
	[string]$VMName = $VMName,
	[string]$Publisher = 'tig',
	[string]$Offer = 'backup-as-a-service',
	[string]$Skus = 'linuxbackupasaservice',
	[string]$version =  'latest',
	[string]$Product = 'backup-as-a-service',
	[string]$name = 'linuxbackupasaservice'
)
Write-Host "Image Creation in Process - Plan Info - tig | linuxbackupasaservice"
$script:VirtualMachine = Set-AzureRmVMPlan -VM $VirtualMachine -Name $name -Publisher $Publisher -Product $Product
$script:VirtualMachine = Set-AzureRmVMOperatingSystem -VM $VirtualMachine -linux -ComputerName $VMName -Credential $Credential1
$script:VirtualMachine = Set-AzureRmVMSourceImage -VM $VirtualMachine -PublisherName $Publisher -Offer $offer -Skus $Skus -Version $version
$LogOut = "Completed image prep Publisher: tig Offer:backup-as-a-service Sku:linuxbackupasaservice Version:latest"
Log-Command -Description $LogOut -LogFile $LogOutFile
}

Function makeimage_withinfo_ti-ba-windowsbackupasaservice
{
param(
	[string]$VMName = $VMName,
	[string]$Publisher = 'tig',
	[string]$Offer = 'backup-as-a-service',
	[string]$Skus = 'windowsbackupasaservice',
	[string]$version =  'latest',
	[string]$Product = 'backup-as-a-service',
	[string]$name = 'windowsbackupasaservice'
)
Write-Host "Image Creation in Process - Plan Info - tig | windowsbackupasaservice"
$script:VirtualMachine = Set-AzureRmVMPlan -VM $VirtualMachine -Name $name -Publisher $Publisher -Product $Product
$script:VirtualMachine = Set-AzureRmVMOperatingSystem -VM $VirtualMachine -linux -ComputerName $VMName -Credential $Credential1
$script:VirtualMachine = Set-AzureRmVMSourceImage -VM $VirtualMachine -PublisherName $Publisher -Offer $offer -Skus $Skus -Version $version
$LogOut = "Completed image prep Publisher: tig Offer:backup-as-a-service Sku:windowsbackupasaservice Version:latest"
Log-Command -Description $LogOut -LogFile $LogOutFile
}

Function MakeImagePlanInfo_Microsoft_ServerR {
param(
	[string]$VMName = $VMName,
	[string]$Publisher = 'microsoft-r-products',
	[string]$offer = 'microsoft-r-server',
	[string]$Skus = 'msr80-win2012r2',
	[string]$version = 'latest',
	[string]$Product = 'microsoft-r-server',
	[string]$name = 'msr80-win2012r2'
)
	Write-Host "Image Creation in Process - Plan Info - Microsoft R Server" -ForegroundColor White
	Write-Host 'Publisher:'$Publisher 'Offer:'$offer 'Sku:'$Skus 'Version:'$version
	$script:VirtualMachine= Set-AzureRmVMPlan -VM $VirtualMachine -Name $name -Publisher $Publisher -Product $Product
	$script:VirtualMachine = Set-AzureRmVMOperatingSystem -VM $VirtualMachine -Windows -ComputerName $VMName -Credential $Credential1
	$script:VirtualMachine = Set-AzureRmVMSourceImage -VM $VirtualMachine -PublisherName $Publisher -Offer $offer -Skus $Skus -Version $version
}
Function MakeImagePlanInfo_Bitnami_tomcat {
param(
	[string]$VMName = $VMName,
	[string]$Publisher = 'bitnami',
	[string]$offer = 'tom-cat',
	[string]$Skus = '7-0',
	[string]$version = 'latest',
	[string]$Product = 'tom-cat',
	[string]$name = '7-0'
)
	Write-Host "Image Creation in Process - Plan Info - Tom-Cat" -ForegroundColor White
	Write-Host 'Publisher:'$Publisher 'Offer:'$offer 'Sku:'$Skus 'Version:'$version
	$script:VirtualMachine= Set-AzureRmVMPlan -VM $VirtualMachine -Name $name -Publisher $Publisher -Product $Product
	$script:VirtualMachine = Set-AzureRmVMOperatingSystem -VM $VirtualMachine -linux -ComputerName $VMName -Credential $Credential1
	$script:VirtualMachine = Set-AzureRmVMSourceImage -VM $VirtualMachine -PublisherName $Publisher -Offer $offer -Skus $Skus -Version $version
}

Function MakeImagePlanInfo_Bitnami_redis {
param(
	[string]$VMName = $VMName,
	[string]$Publisher = 'bitnami',
	[string]$offer = 'redis',
	[string]$Skus = '3-2',
	[string]$version = 'latest',
	[string]$Product = 'redis',
	[string]$name = '3-2'
)
	Write-Host "Image Creation in Process - Plan Info - Redis"
	Write-Host 'Publisher:'$Publisher 'Offer:'$offer 'Sku:'$Skus 'Version:'$version
	$script:VirtualMachine= Set-AzureRmVMPlan -VM $VirtualMachine -Name $name -Publisher $Publisher -Product $Product
	$script:VirtualMachine = Set-AzureRmVMOperatingSystem -VM $VirtualMachine -linux -ComputerName $VMName -Credential $Credential1
	$script:VirtualMachine = Set-AzureRmVMSourceImage -VM $VirtualMachine -PublisherName $Publisher -Offer $offer -Skus $Skus -Version $version
}
Function MakeImagePlanInfo_Bitnami_neos {
param(
	[string]$VMName = $VMName,
	[string]$Publisher = 'bitnami',
	[string]$offer = 'neos',
	[string]$Skus = '2-0',
	[string]$version = 'latest',
	[string]$Product = 'neos',
	[string]$name = '2-0'
	)
	Write-Host "Image Creation in Process - Plan Info - neos"
	Write-Host 'Publisher:'$Publisher 'Offer:'$offer 'Sku:'$Skus 'Version:'$version
	$script:VirtualMachine= Set-AzureRmVMPlan -VM $VirtualMachine -Name $name -Publisher $Publisher -Product $Product
	$script:VirtualMachine = Set-AzureRmVMOperatingSystem -VM $VirtualMachine -linux -ComputerName $VMName -Credential $Credential1
	$script:VirtualMachine = Set-AzureRmVMSourceImage -VM $VirtualMachine -PublisherName $Publisher -Offer $offer -Skus $Skus -Version $version
}
Function MakeImagePlanInfo_Bitnami_hadoop {
param(
	[string]$VMName = $VMName,
	[string]$Publisher = 'bitnami',
	[string]$offer = 'hadoop',
	[string]$Skus = '2-7',
	[string]$version = 'latest',
	[string]$Product = 'hadoop',
	[string]$name = '2-7'
)
	Write-Host "Image Creation in Process - Plan Info - hadoop"
	Write-Host 'Publisher:'$Publisher 'Offer:'$offer 'Sku:'$Skus 'Version:'$version
	$script:VirtualMachine= Set-AzureRmVMPlan -VM $VirtualMachine -Name $name -Publisher $Publisher -Product $Product
	$script:VirtualMachine = Set-AzureRmVMOperatingSystem -VM $VirtualMachine -linux -ComputerName $VMName -Credential $Credential1
	$script:VirtualMachine = Set-AzureRmVMSourceImage -VM $VirtualMachine -PublisherName $Publisher -Offer $offer -Skus $Skus -Version $version
}
Function MakeImagePlanInfo_Bitnami_gitlab {
param(
	[string]$VMName = $VMName,
	[string]$Publisher = 'bitnami',
	[string]$offer = 'gitlab',
	[string]$Skus = '8-5',
	[string]$version = 'latest',
	[string]$Product = 'gitlab',
	[string]$name = '8-5'
)
	Write-Host "Image Creation in Process - Plan Info - gitlab"
	Write-Host 'Publisher:'$Publisher 'Offer:'$offer 'Sku:'$Skus 'Version:'$version
	$script:VirtualMachine= Set-AzureRmVMPlan -VM $VirtualMachine -Name $name -Publisher $Publisher -Product $Product
	$script:VirtualMachine = Set-AzureRmVMOperatingSystem -VM $VirtualMachine -linux -ComputerName $VMName -Credential $Credential1
	$script:VirtualMachine = Set-AzureRmVMSourceImage -VM $VirtualMachine -PublisherName $Publisher -Offer $offer -Skus $Skus -Version $version
}
Function MakeImagePlanInfo_Bitnami_jrubystack {
param(
	[string]$VMName = $VMName,
	[string]$Publisher = 'bitnami',
	[string]$offer = 'jrubystack',
	[string]$Skus = '9-0',
	[string]$version = 'latest',
	[string]$Product = 'jrubystack',
	[string]$name = '9-0'
)
	Write-Host "Image Creation in Process - Plan Info - jrubystack"
	Write-Host 'Publisher:'$Publisher 'Offer:'$offer 'Sku:'$Skus 'Version:'$version
	$script:VirtualMachine= Set-AzureRmVMPlan -VM $VirtualMachine -Name $name -Publisher $Publisher -Product $Product
	$script:VirtualMachine = Set-AzureRmVMOperatingSystem -VM $VirtualMachine -linux -ComputerName $VMName -Credential $Credential1
	$script:VirtualMachine = Set-AzureRmVMSourceImage -VM $VirtualMachine -PublisherName $Publisher -Offer $offer -Skus $Skus -Version $version
}

Function MakeImagePlanInfo_Bitnami_mongodb {
param(
	[string]$VMName = $VMName,
	[string]$Publisher = 'bitnami',
	[string]$offer = 'mongodb',
	[string]$Skus = '3-2',
	[string]$version = 'latest',
	[string]$Product = 'mongodb',
	[string]$name = '3-2'
)
	Write-Host "Image Creation in Process - Plan Info - MongoDb" -ForegroundColor White
	Write-Host 'Publisher:'$Publisher 'Offer:'$offer 'Sku:'$Skus 'Version:'$version
	$script:VirtualMachine= Set-AzureRmVMPlan -VM $VirtualMachine -Name $name -Publisher $Publisher -Product $Product
	$script:VirtualMachine = Set-AzureRmVMOperatingSystem -VM $VirtualMachine -linux -ComputerName $VMName -Credential $Credential1
	$script:VirtualMachine = Set-AzureRmVMSourceImage -VM $VirtualMachine -PublisherName $Publisher -Offer $offer -Skus $Skus -Version $version
}
Function MakeImagePlanInfo_Bitnami_mysql {
param(
	[string]$VMName = $VMName,
	[string]$Publisher = 'bitnami',
	[string]$offer = 'mysql',
	[string]$Skus = '5-6',
	[string]$version = 'latest',
	[string]$Product = 'mysql',
	[string]$name = '5-6'
)
	Write-Host "Image Creation in Process - Plan Info - MySql" -ForegroundColor White
	Write-Host 'Publisher:'$Publisher 'Offer:'$offer 'Sku:'$Skus 'Version:'$version
	$script:VirtualMachine= Set-AzureRmVMPlan -VM $VirtualMachine -Name $name -Publisher $Publisher -Product $Product
	$script:VirtualMachine = Set-AzureRmVMOperatingSystem -VM $VirtualMachine -linux -ComputerName $VMName -Credential $Credential1
	$script:VirtualMachine = Set-AzureRmVMSourceImage -VM $VirtualMachine -PublisherName $Publisher -Offer $offer -Skus $Skus -Version $version
	$LogOut = "Completed image prep 'Publisher:'$Publisher 'Offer:'$offer 'Sku:'$Skus 'Version:'$version"
	Log-Command -Description $LogOut -LogFile $LogOutFile
}
Function MakeImagePlanInfo_Bitnami_nginxstack {
param(
	[string]$VMName = $VMName,
	[string]$Publisher = 'bitnami',
	[string]$offer = 'nginxstack',
	[string]$Skus = '1-9',
	[string]$version = 'latest',
	[string]$Product = 'nginxstack',
	[string]$name = '1-9'
)
	Write-Host "Image Creation in Process - Plan Info - Nginxstack" -ForegroundColor White
	Write-Host 'Publisher:'$Publisher 'Offer:'$offer 'Sku:'$Skus 'Version:'$version
	$script:VirtualMachine= Set-AzureRmVMPlan -VM $VirtualMachine -Name $name -Publisher $Publisher -Product $Product
	$script:VirtualMachine = Set-AzureRmVMOperatingSystem -VM $VirtualMachine -linux -ComputerName $VMName -Credential $Credential1
	$script:VirtualMachine = Set-AzureRmVMSourceImage -VM $VirtualMachine -PublisherName $Publisher -Offer $offer -Skus $Skus -Version $version
	$LogOut = "Completed image prep 'Publisher:'$Publisher 'Offer:'$offer 'Sku:'$Skus 'Version:'$version"
	Log-Command -Description $LogOut -LogFile $LogOutFile
}
Function MakeImagePlanInfo_Bitnami_nodejs {
param(
	[string]$VMName = $VMName,
	[string]$Publisher = 'bitnami',
	[string]$offer = 'nodejs',
	[string]$Skus = '4-3',
	[string]$version = 'latest',
	[string]$Product = 'nodejs',
	[string]$name = '4-3'
)
	Write-Host "Image Creation in Process - Plan Info - Nodejs" -ForegroundColor White
	Write-Host 'Publisher:'$Publisher 'Offer:'$offer 'Sku:'$Skus 'Version:'$version
	$script:VirtualMachine= Set-AzureRmVMPlan -VM $VirtualMachine -Name $name -Publisher $Publisher -Product $Product
	$script:VirtualMachine = Set-AzureRmVMOperatingSystem -VM $VirtualMachine -linux -ComputerName $VMName -Credential $Credential1
	$script:VirtualMachine = Set-AzureRmVMSourceImage -VM $VirtualMachine -PublisherName $Publisher -Offer $offer -Skus $Skus -Version $version
	$LogOut = "Completed image prep 'Publisher:'$Publisher 'Offer:'$offer 'Sku:'$Skus 'Version:'$version"
	Log-Command -Description $LogOut -LogFile $LogOutFile
}
Function MakeImagePlanInfo_Bitnami_postgresql {
param(
	[string]$VMName = $VMName,
	[string]$Publisher = 'bitnami',
	[string]$offer = 'postgresql',
	[string]$Skus = '9-5',
	[string]$version = 'latest',
	[string]$Product = 'postgresql',
	[string]$name = '9-5'
)
	Write-Host "Image Creation in Process - Plan Info - postgresql" -ForegroundColor White
	Write-Host 'Publisher:'$Publisher 'Offer:'$offer 'Sku:'$Skus 'Version:'$version
	$script:VirtualMachine= Set-AzureRmVMPlan -VM $VirtualMachine -Name $name -Publisher $Publisher -Product $Product
	$script:VirtualMachine = Set-AzureRmVMOperatingSystem -VM $VirtualMachine -linux -ComputerName $VMName -Credential $Credential1
	$script:VirtualMachine = Set-AzureRmVMSourceImage -VM $VirtualMachine -PublisherName $Publisher -Offer $offer -Skus $Skus -Version $version
	$LogOut = "Completed image prep 'Publisher:'$Publisher 'Offer:'$offer 'Sku:'$Skus 'Version:'$version"
	Log-Command -Description $LogOut -LogFile $LogOutFile
}

Function MakeImagePlanInfo_puppet_puppetent {
param(
	[string]$VMName = $VMName,
	[string]$Publisher = 'puppet',
	[string]$offer = 'puppet-Enterprise',
	[string]$Skus = '2016-1',
	[string]$version = 'latest',
	[string]$Product = '2016-1',
	[string]$name = 'puppet-Enterprise'
	)
Write-Host "Image Creation in Process - Plan Info - puppet | 2016-1"
$script:VirtualMachine = Set-AzureRmVMPlan -VM $VirtualMachine -Name 2016-1 -Publisher puppet -Product puppet-enterprise
$script:VirtualMachine = Set-AzureRmVMOperatingSystem -VM $VirtualMachine -linux -ComputerName $VMName -Credential $Credential1
$script:VirtualMachine = Set-AzureRmVMSourceImage -VM $VirtualMachine -PublisherName puppet -Offer puppet-enterprise -Skus 2016-1 -Version latest
$LogOut = "Completed image prep Publisher:$Publisher Offer:$offer Sku:$Skus Version:$version"
Log-Command -Description $LogOut -LogFile $LogOutFile
}

Function MakeImagePlanInfo_Barracuda_ng_firewall_hourly {
param(
	[string]$VMName = $VMName,
	[string]$Publisher = 'Barracudanetworks',
	[string]$offer = 'barracuda-ng-firewall',
	[string]$Skus = 'hourly',
	[string]$version = 'latest',
	[string]$Product = 'barracuda-ng-firewall',
	[string]$name = 'hourly'
)
	Try
	{
		Write-Host "Image Creation in Process - Plan Info - Barracuda Firewall " -ForegroundColor White
		Write-Host 'Publisher:'$Publisher 'Offer:'$offer 'Sku:'$Skus 'Version:'$version
		$script:VirtualMachine= Set-AzureRmVMPlan -VM $VirtualMachine -Name $name -Publisher $Publisher -Product $Product
		$script:VirtualMachine = Set-AzureRmVMOperatingSystem -VM $VirtualMachine -linux -ComputerName $VMName -Credential $Credential1
		$script:VirtualMachine = Set-AzureRmVMSourceImage -VM $VirtualMachine -PublisherName $Publisher -Offer $offer -Skus $Skus -Version $version
		$LogOut = "Completed image prep 'Publisher:'$Publisher 'Offer:'$offer 'Sku:'$Skus 'Version:'$version"
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

Function MakeImagePlanInfo_Barracuda_ng_firewall_byol {
param(
	[string]$VMName = $VMName,
	[string]$Publisher = 'Barracudanetworks',
	[string]$offer = 'barracuda-ng-firewall',
	[string]$Skus = 'byol',
	[string]$version = 'latest',
	[string]$Product = 'barracuda-ng-firewall',
	[string]$name = 'byol'
)
Write-Host "Image Creation in Process - Plan Info - Barracuda NG Firewall " -ForegroundColor White
Write-Host 'Publisher:'$Publisher 'Offer:'$offer 'Sku:'$Skus 'Version:'$version
$script:VirtualMachine= Set-AzureRmVMPlan -VM $VirtualMachine -Name $name -Publisher $Publisher -Product $Product
$script:VirtualMachine = Set-AzureRmVMOperatingSystem -VM $VirtualMachine -linux -ComputerName $VMName -Credential $Credential1
$script:VirtualMachine = Set-AzureRmVMSourceImage -VM $VirtualMachine -PublisherName $Publisher -Offer $offer -Skus $Skus -Version $version
$LogOut = "Completed image prep 'Publisher:'$Publisher 'Offer:'$offer 'Sku:'$Skus 'Version:'$version"
Log-Command -Description $LogOut -LogFile $LogOutFile
}

Function MakeImagePlanInfo_Barracuda_spam_firewall_byol {
param(
	[string]$VMName = $VMName,
	[string]$Publisher = 'Barracudanetworks',
	[string]$offer = 'barracuda-spam-firewall',
	[string]$Skus = 'byol',
	[string]$version = 'latest',
	[string]$Product = 'barracuda-spam-firewall',
	[string]$name = 'byol'
)
Write-Host "Image Creation in Process - Plan Info - Barracuda SPAM Firewall " -ForegroundColor White
Write-Host 'Publisher:'$Publisher 'Offer:'$offer 'Sku:'$Skus 'Version:'$version
$script:VirtualMachine= Set-AzureRmVMPlan -VM $VirtualMachine -Name $name -Publisher $Publisher -Product $Product
$script:VirtualMachine = Set-AzureRmVMOperatingSystem -VM $VirtualMachine -linux -ComputerName $VMName -Credential $Credential1
$script:VirtualMachine = Set-AzureRmVMSourceImage -VM $VirtualMachine -PublisherName $Publisher -Offer $offer -Skus $Skus -Version $version
$LogOut = "Completed image prep 'Publisher:'$Publisher 'Offer:'$offer 'Sku:'$Skus 'Version:'$version"
Log-Command -Description $LogOut -LogFile $LogOutFile
}

Function MakeImagePlanInfo_cloudera
{
param(
	[string]$VMName = $VMName,
	[string]$Publisher = 'cloudera',
	[string]$Offer = 'cloudera-centos-os',
	[string]$Skus = '7_2',
	[string]$version =  'latest',
	[string]$Product = 'cloudera-centos-os',
	[string]$name = '7_2'
)
Write-Host "Image Creation in Process - Plan Info - cloudera | 7_2"
$script:VirtualMachine = Set-AzureRmVMPlan -VM $VirtualMachine -Name $name -Publisher $Publisher -Product $Product
$script:VirtualMachine = Set-AzureRmVMOperatingSystem -VM $VirtualMachine -linux -ComputerName $VMName -Credential $Credential1
$script:VirtualMachine = Set-AzureRmVMSourceImage -VM $VirtualMachine -PublisherName $Publisher -Offer $offer -Skus $Skus -Version $version
$LogOut = "Completed image prep Publisher: cloudera Offer:cloudera-centos-os Sku:7_2 Version:latest"
Log-Command -Description $LogOut -LogFile $LogOutFile
}

Function MakeImagePlanInfo_datastax {
param(
	[string]$VMName = $VMName,
	[string]$Publisher = 'datastax',
	[string]$offer = 'datastax-enterprise',
	[string]$Skus = 'datastaxenterprise',
	[string]$version = 'latest',
	[string]$Product = 'datastax-enterprise',
	[string]$name = 'datastaxenterprise'
)
Write-Host "Image Creation in Process - Plan Info - datastax" -ForegroundColor White
Write-Host 'Publisher:'$Publisher 'Offer:'$offer 'Sku:'$Skus 'Version:'$version
$script:VirtualMachine= Set-AzureRmVMPlan -VM $VirtualMachine -Name $name -Publisher $Publisher -Product $Product
$script:VirtualMachine = Set-AzureRmVMOperatingSystem -VM $VirtualMachine -linux -ComputerName $VMName -Credential $Credential1
$script:VirtualMachine = Set-AzureRmVMSourceImage -VM $VirtualMachine -PublisherName $Publisher -Offer $offer -Skus $Skus -Version $version
$LogOut = "Completed image prep 'Publisher:'$Publisher 'Offer:'$offer 'Sku:'$Skus 'Version:'$version"
Log-Command -Description $LogOut -LogFile $LogOutFile
}

Function makeimage_withinfo_cl-je-jenkins-operations-center
{
param(
	[string]$VMName = $VMName,
	[string]$Publisher = 'cloudbees',
	[string]$Offer = 'jenkins-operations-center',
	[string]$Skus = 'jenkins-operations-center',
	[string]$version =  'latest',
	[string]$Product = 'jenkins-operations-center',
	[string]$name = 'jenkins-operations-center'
)
Write-Host "Image Creation in Process - Plan Info - cloudbees | jenkins-operations-center"
$script:VirtualMachine = Set-AzureRmVMPlan -VM $VirtualMachine -Name $name -Publisher $Publisher -Product $Product
$script:VirtualMachine = Set-AzureRmVMOperatingSystem -VM $VirtualMachine -linux -ComputerName $VMName -Credential $Credential1
$script:VirtualMachine = Set-AzureRmVMSourceImage -VM $VirtualMachine -PublisherName $Publisher -Offer $offer -Skus $Skus -Version $version
$LogOut = "Completed image prep Publisher: cloudbees Offer:jenkins-operations-center Sku:jenkins-operations-center Version:latest"
Log-Command -Description $LogOut -LogFile $LogOutFile
}

Function makeimage_withinfo_ci-ne-netscalervpx
{
param(
	[string]$VMName = $VMName,
	[string]$Publisher = 'citrix',
	[string]$Offer = 'netscaler-vpx',
	[string]$Skus = 'netscalervpx',
	[string]$version =  'latest',
	[string]$Product = 'netscaler-vpx',
	[string]$name = 'netscalervpx'
)
Write-Host "Image Creation in Process - Plan Info - citrix | netscalervpx"
$script:VirtualMachine = Set-AzureRmVMPlan -VM $VirtualMachine -Name $name -Publisher $Publisher -Product $Product
$script:VirtualMachine = Set-AzureRmVMOperatingSystem -VM $VirtualMachine -linux -ComputerName $VMName -Credential $Credential1
$script:VirtualMachine = Set-AzureRmVMSourceImage -VM $VirtualMachine -PublisherName $Publisher -Offer $offer -Skus $Skus -Version $version
$LogOut = "Completed image prep Publisher: citrix Offer:netscaler-vpx Sku:netscalervpx Version:latest"
Log-Command -Description $LogOut -LogFile $LogOutFile
}

Function makeimage_withinfo_ci-vw-vwaas-azure-750
{
param(
	[string]$VMName = $VMName,
	[string]$Publisher = 'cisco',
	[string]$Offer = 'vwaas-azure',
	[string]$Skus = 'vwaas-azure-750',
	[string]$version =  'latest',
	[string]$Product = 'vwaas-azure',
	[string]$name = 'vwaas-azure-750'
)
Write-Host "Image Creation in Process - Plan Info - cisco | vwaas-azure-750"
$script:VirtualMachine = Set-AzureRmVMPlan -VM $VirtualMachine -Name $name -Publisher $Publisher -Product $Product
$script:VirtualMachine = Set-AzureRmVMOperatingSystem -VM $VirtualMachine -linux -ComputerName $VMName -Credential $Credential1
$script:VirtualMachine = Set-AzureRmVMSourceImage -VM $VirtualMachine -PublisherName $Publisher -Offer $offer -Skus $Skus -Version $version
$LogOut = "Completed image prep Publisher: cisco Offer:vwaas-azure Sku:vwaas-azure-750 Version:latest"
Log-Command -Description $LogOut -LogFile $LogOutFile
}
Function MakeImagePlanInfo_cloudconnector {
param(
	[string]$VMName = $VMName,
	[string]$Publisher = 'elfiqnetworks',
	[string]$offer = 'cloud-connector',
	[string]$Skus = 'cloud-connector-azure',
	[string]$version = 'latest',
	[string]$Product = 'cloud-connector',
	[string]$name = 'cloud-connector-azure'
)
Write-Host "Image Creation in Process - Plan Info - cloud connector" -ForegroundColor White
Write-Host 'Publisher:'$Publisher 'Offer:'$offer 'Sku:'$Skus 'Version:'$version
$script:VirtualMachine= Set-AzureRmVMPlan -VM $VirtualMachine -Name $name -Publisher $Publisher -Product $Product
$script:VirtualMachine = Set-AzureRmVMOperatingSystem -VM $VirtualMachine -linux -ComputerName $VMName -Credential $Credential1
$script:VirtualMachine = Set-AzureRmVMSourceImage -VM $VirtualMachine -PublisherName $Publisher -Offer $offer -Skus $Skus -Version $version
$LogOut = "Completed image prep 'Publisher:'$Publisher 'Offer:'$offer 'Sku:'$Skus 'Version:'$version"
Log-Command -Description $LogOut -LogFile $LogOutFile
}

Function makeimage_withinfo_ch-ch-azure_marketplace_100
{
param(
	[string]$VMName = $VMName,
	[string]$Publisher = 'chef-software',
	[string]$Offer = 'chef-compliance',
	[string]$Skus = 'azure_marketplace_100',
	[string]$version =  'latest',
	[string]$Product = 'chef-compliance',
	[string]$name = 'azure_marketplace_100'
)
Write-Host "Image Creation in Process - Plan Info - chef-software | azure_marketplace_100"
$script:VirtualMachine = Set-AzureRmVMPlan -VM $VirtualMachine -Name $name -Publisher $Publisher -Product $Product
$script:VirtualMachine = Set-AzureRmVMOperatingSystem -VM $VirtualMachine -linux -ComputerName $VMName -Credential $Credential1
$script:VirtualMachine = Set-AzureRmVMSourceImage -VM $VirtualMachine -PublisherName $Publisher -Offer $offer -Skus $Skus -Version $version
$LogOut = "Completed image prep Publisher: chef-software Offer:chef-compliance Sku:azure_marketplace_100 Version:latest"
Log-Command -Description $LogOut -LogFile $LogOutFile
}

Function makeimage_withinfo_te-te-serv-nes-byol-azure
{
param(
	[string]$VMName = $VMName,
	[string]$Publisher = 'tenable',
	[string]$Offer = 'tenable-nessus-byol',
	[string]$Skus = 'serv-nes-byol-azure',
	[string]$version =  'latest',
	[string]$Product = 'tenable-nessus-byol',
	[string]$name = 'serv-nes-byol-azure'
)
Write-Host "Image Creation in Process - Plan Info - tenable | serv-nes-byol-azure"
$script:VirtualMachine = Set-AzureRmVMPlan -VM $VirtualMachine -Name $name -Publisher $Publisher -Product $Product
$script:VirtualMachine = Set-AzureRmVMOperatingSystem -VM $VirtualMachine -linux -ComputerName $VMName -Credential $Credential1
$script:VirtualMachine = Set-AzureRmVMSourceImage -VM $VirtualMachine -PublisherName $Publisher -Offer $offer -Skus $Skus -Version $version
$LogOut = "Completed image prep Publisher: tenable Offer:tenable-nessus-byol Sku:serv-nes-byol-azure Version:latest"
Log-Command -Description $LogOut -LogFile $LogOutFile
}

Function MakeImagePlanInfo_chefbyol {
param(
	[string]$VMName = $VMName,
	[string]$Publisher = 'chef-software',
	[string]$offer = 'chef-server',
	[string]$Skus = 'chefbyol',
	[string]$version = 'latest',
	[string]$Product = 'chef-server',
	[string]$name = 'chefbyol'
)
Write-Host "Image Creation in Process - Plan Info - Chef BYOL" -ForegroundColor White
Write-Host 'Publisher:'$Publisher 'Offer:'$offer 'Sku:'$Skus 'Version:'$version
$script:VirtualMachine= Set-AzureRmVMPlan -VM $VirtualMachine -Name $name -Publisher $Publisher -Product $Product
$script:VirtualMachine = Set-AzureRmVMOperatingSystem -VM $VirtualMachine -linux -ComputerName $VMName -Credential $Credential1
$script:VirtualMachine = Set-AzureRmVMSourceImage -VM $VirtualMachine -PublisherName $Publisher -Offer $offer -Skus $Skus -Version $version
$LogOut = "Completed image prep 'Publisher:'$Publisher 'Offer:'$offer 'Sku:'$Skus 'Version:'$version"
Log-Command -Description $LogOut -LogFile $LogOutFile
}
Function MakeImagePlanInfo_Barracuda_spam_firewall_hourly {
param(
	[string]$VMName = $VMName,
	[string]$Publisher = 'Barracudanetworks',
	[string]$offer = 'barracuda-spam-firewall',
	[string]$Skus = 'hourly',
	[string]$version = 'latest',
	[string]$Product = 'barracuda-spam-firewall',
	[string]$name = 'hourly'
)
Write-Host "Image Creation in Process - Plan Info - Barracuda SPAM Firewall " -ForegroundColor White
Write-Host 'Publisher:'$Publisher 'Offer:'$offer 'Sku:'$Skus 'Version:'$version
$script:VirtualMachine= Set-AzureRmVMPlan -VM $VirtualMachine -Name $name -Publisher $Publisher -Product $Product
$script:VirtualMachine = Set-AzureRmVMOperatingSystem -VM $VirtualMachine -linux -ComputerName $VMName -Credential $Credential1
$script:VirtualMachine = Set-AzureRmVMSourceImage -VM $VirtualMachine -PublisherName $Publisher -Offer $offer -Skus $Skus -Version $version
$LogOut = "Completed image prep 'Publisher:'$Publisher 'Offer:'$offer 'Sku:'$Skus 'Version:'$version"
Log-Command -Description $LogOut -LogFile $LogOutFile
}
Function makeimage_withinfo_cr-De-8
{
param(
	[string]$VMName = $VMName,
	[string]$Publisher = 'credativ',
	[string]$Offer = 'Debian',
	[string]$Skus = '8',
	[string]$version =  'latest',
	[string]$Product = 'Debian',
	[string]$name = '8'
)
Write-Host "Image Creation in Process - Plan Info - credativ | 8"
$script:VirtualMachine = Set-AzureRmVMOperatingSystem -VM $VirtualMachine -linux -ComputerName $VMName -Credential $Credential1
$script:VirtualMachine = Set-AzureRmVMSourceImage -VM $VirtualMachine -PublisherName $Publisher -Offer $offer -Skus $Skus -Version $version
$LogOut = "Completed image prep Publisher: credativ Offer:Debian Sku:8 Version:latest"
Log-Command -Description $LogOut -LogFile $LogOutFile
}

Function MakeImagePlanInfo_f5_bigip_good_byol {
param(
	[string]$VMName = $VMName,
	[string]$Publisher = 'F5-networks',
	[string]$offer = 'f5-big-ip',
	[string]$Skus = 'f5-bigip-virtual-edition-good-byol',
	[string]$version = 'latest',
	[string]$Product = 'f5-big-ip',
	[string]$name = 'f5-bigip-virtual-edition-good-byol'
)
Write-Host "Image Creation in Process - Plan Info - F5 BIG IP - BYOL" -ForegroundColor White
Write-Host 'Publisher:'$Publisher 'Offer:'$offer 'Sku:'$Skus 'Version:'$version
$script:VirtualMachine= Set-AzureRmVMPlan -VM $VirtualMachine -Name $name -Publisher $Publisher -Product $Product
$script:VirtualMachine = Set-AzureRmVMOperatingSystem -VM $VirtualMachine -linux -ComputerName $VMName -Credential $Credential1
$script:VirtualMachine = Set-AzureRmVMSourceImage -VM $VirtualMachine -PublisherName $Publisher -Offer $offer -Skus $Skus -Version $version
$LogOut = "Completed image prep 'Publisher:'$Publisher 'Offer:'$offer 'Sku:'$Skus 'Version:'$version"
Log-Command -Description $LogOut -LogFile $LogOutFile
}

Function MakeImagePlanInfo_f5_webappfire_byol
{
param(
	[string]$VMName = $VMName,
	[string]$Publisher = 'f5-networks',
	[string]$Offer = 'f5-web-application-firewall',
	[string]$Skus = 'f5-waf-solution-byol',
	[string]$version =  'latest',
	[string]$Product = 'f5-web-application-firewall',
	[string]$name = 'f5-waf-solution-byol'
)
Write-Host "Image Creation in Process - Plan Info - f5-networks | f5-waf-solution-byol"
$script:VirtualMachine = Set-AzureRmVMPlan -VM $VirtualMachine -Name $name -Publisher $Publisher -Product $Product
$script:VirtualMachine = Set-AzureRmVMOperatingSystem -VM $VirtualMachine -linux -ComputerName $VMName -Credential $Credential1
$script:VirtualMachine = Set-AzureRmVMSourceImage -VM $VirtualMachine -PublisherName $Publisher -Offer $offer -Skus $Skus -Version $version
$LogOut = "Completed image prep Publisher: f5-networks Offer:f5-web-application-firewall Sku:f5-waf-solution-byol Version:latest"
Log-Command -Description $LogOut -LogFile $LogOutFile
}

Function MakeImagePlanInfo_Pfsense {
param(
	[string]$VMName = $VMName,
	[string]$Publisher = 'netgate',
	[string]$offer = 'pfsense-fw-vpn-router-community_support',
	[string]$Skus = 'pfsense-azure-234-cs',
	[string]$version = 'latest',
	[string]$Product = 'pfsense-fw-vpn-router-community_support',
	[string]$name = 'pfsense-azure-234-cs'
)
Write-Host "Image Creation in Process - Plan Info - Pfsense" -ForegroundColor White
Write-Host 'Publisher:'$Publisher 'Offer:'$offer 'Sku:'$Skus 'Version:'$version
$script:VirtualMachine= Set-AzureRmVMPlan -VM $VirtualMachine -Name $name -Publisher $Publisher -Product $Product
$script:VirtualMachine = Set-AzureRmVMOperatingSystem -VM $VirtualMachine -linux -ComputerName $VMName -Credential $Credential1
$script:VirtualMachine = Set-AzureRmVMSourceImage -VM $VirtualMachine -PublisherName $Publisher -Offer $offer -Skus $Skus -Version $version
$LogOut = "Completed image prep 'Publisher:'$Publisher 'Offer:'$offer 'Sku:'$Skus 'Version:'$version"
Log-Command -Description $LogOut -LogFile $LogOutFile
}

Function MakeImagePlanInfo_Checkpoint {
param(
	[string]$VMName = $VMName,
	[string]$Publisher = 'checkpoint',
	[string]$offer = 'check-point-r77-10',
	[string]$Skus = 'sg-ngtp',
	[string]$version = 'latest',
	[string]$Product = 'check-point-r77-10',
	[string]$name = 'sg-ngtp'
)
Write-Host "Image Creation in Process - Plan Info - Checkpoint" -ForegroundColor White
Write-Host 'Publisher:'$Publisher 'Offer:'$offer 'Sku:'$Skus 'Version:'$version
$script:VirtualMachine = Set-AzureRmVMPlan -VM $VirtualMachine -Name $name -Publisher $Publisher -Product $Product
$script:VirtualMachine = Set-AzureRmVMOperatingSystem -VM $VirtualMachine -linux -ComputerName $VMName -Credential $Credential1
$script:VirtualMachine = Set-AzureRmVMSourceImage -VM $VirtualMachine -PublisherName $Publisher -Offer $offer -Skus $Skus -Version $version
$LogOut = "Completed image prep 'Publisher:'$Publisher 'Offer:'$offer 'Sku:'$Skus 'Version:'$version"
Log-Command -Description $LogOut -LogFile $LogOutFile
}

Function MakeImageNoPlanInfo_RedHat67 {
param(
	[string]$VMName = $VMName,
	[string]$Publisher = "Redhat",
	[string]$offer = "rhel",
	[string]$Skus = "6.7",
	[string]$version = "latest"
)
Write-Host "Image Creation in Process - No Plan Info - RedHat 6.7" -ForegroundColor White
Write-Host 'Publisher:'$Publisher 'Offer:'$offer 'Sku:'$Skus 'Version:'$version
	if($addssh)
	{ $script:VirtualMachine = Set-AzureRmVMOperatingSystem -VM $VirtualMachine -linux -ComputerName $VMName -Credential $Credential1 -DisablePasswordAuthentication }
	elseif($batchaddssh -eq 'True')
		{ $script:VirtualMachine = Set-AzureRmVMOperatingSystem -VM $VirtualMachine -linux -ComputerName $VMName -Credential $Credential1 -DisablePasswordAuthentication }
	else
		{ $script:VirtualMachine = Set-AzureRmVMOperatingSystem -VM $VirtualMachine -linux -ComputerName $VMName -Credential $Credential1 }
$script:VirtualMachine = Set-AzureRmVMSourceImage -VM $VirtualMachine -PublisherName $Publisher -Offer $offer -Skus $Skus -Version $version
$LogOut = "Completed image prep 'Publisher:'$Publisher 'Offer:'$offer 'Sku:'$Skus 'Version:'$version"
Log-Command -Description $LogOut -LogFile $LogOutFile
}

Function MakeImageNoPlanInfo_RedHat72 {
param(
	[string]$VMName = $VMName,
	[string]$Publisher = "Redhat",
	[string]$offer = "rhel",
	[string]$Skus = "7.2",
	[string]$version = "latest"
)
Write-Host "Image Creation in Process - No Plan Info - Redhat 7.2" -ForegroundColor White
Write-Host 'Publisher:'$Publisher 'Offer:'$offer 'Sku:'$Skus 'Version:'$version
	   if($addssh -or $batchaddssh -eq 'True')
	{ $script:VirtualMachine = Set-AzureRmVMOperatingSystem -VM $VirtualMachine -linux -ComputerName $VMName -Credential $Credential1 -DisablePasswordAuthentication }
	else
		{ $script:VirtualMachine = Set-AzureRmVMOperatingSystem -VM $VirtualMachine -linux -ComputerName $VMName -Credential $Credential1 }
$script:VirtualMachine = Set-AzureRmVMSourceImage -VM $VirtualMachine -PublisherName $Publisher -Offer $offer -Skus $Skus -Version $version
$LogOut = "Completed image prep 'Publisher:'$Publisher 'Offer:'$offer 'Sku:'$Skus 'Version:'$version"
Log-Command -Description $LogOut -LogFile $LogOutFile
}

Function MakeImageNoPlanInfo_FreeBsd {
param(
	[string]$VMName = $VMName,
	[string]$Publisher = "MicrosoftOSTC",
	[string]$offer = "FreeBSD",
	[string]$Skus = "10.3",
	[string]$version = "latest"
)
Write-Host "Image Creation in Process - No Plan Info - FreeBsd" -ForegroundColor White
Write-Host 'Publisher:'$Publisher 'Offer:'$offer 'Sku:'$Skus 'Version:'$version
	   if($addssh -or $batchaddssh -eq 'True')
	{ $script:VirtualMachine = Set-AzureRmVMOperatingSystem -VM $VirtualMachine -linux -ComputerName $VMName -Credential $Credential1 -DisablePasswordAuthentication }
	else
		{ $script:VirtualMachine = Set-AzureRmVMOperatingSystem -VM $VirtualMachine -linux -ComputerName $VMName -Credential $Credential1 }
$script:VirtualMachine = Set-AzureRmVMSourceImage -VM $VirtualMachine -PublisherName $Publisher -Offer $offer -Skus $Skus -Version $version
$LogOut = "Completed image prep 'Publisher:'$Publisher 'Offer:'$offer 'Sku:'$Skus 'Version:'$version"
Log-Command -Description $LogOut -LogFile $LogOutFile
}

Function MakeImageNoPlanInfo_CoreOS_CoreOS {
param(
	[string]$VMName = $VMName,
	[string]$Publisher = "CoreOS",
	[string]$offer = "CoreOS",
	[string]$Skus = "Stable",
	[string]$version = "latest"

)
Write-Host "Image Creation in Process - No Plan Info - CoreOs Stable" -ForegroundColor White
Write-Host 'Publisher:'$Publisher 'Offer:'$offer 'Sku:'$Skus 'Version:'$version
$script:VirtualMachine = Set-AzureRmVMOperatingSystem -VM $VirtualMachine -linux -ComputerName $VMName -Credential $Credential1
$script:VirtualMachine = Set-AzureRmVMSourceImage -VM $VirtualMachine -PublisherName $Publisher -Offer $offer -Skus $Skus -Version $version
$LogOut = "Completed image prep 'Publisher:'$Publisher 'Offer:'$offer 'Sku:'$Skus 'Version:'$version"
Log-Command -Description $LogOut -LogFile $LogOutFile
}

Function MakeImageNoPlanInfo_CoreOS_ContainerLinux {
param(
	[string]$VMName = $VMName,
	[string]$Publisher = "CoreOS",
	[string]$offer = "Container-Linux",
	[string]$Skus = "Stable",
	[string]$version = "latest"

)
Write-Host "Image Creation in Process - No Plan Info - CoreOs ContainerLinux Stable" -ForegroundColor White
Write-Host 'Publisher:'$Publisher 'Offer:'$offer 'Sku:'$Skus 'Version:'$version
$script:VirtualMachine = Set-AzureRmVMOperatingSystem -VM $VirtualMachine -linux -ComputerName $VMName -Credential $Credential1
$script:VirtualMachine = Set-AzureRmVMSourceImage -VM $VirtualMachine -PublisherName $Publisher -Offer $offer -Skus $Skus -Version $version
$LogOut = "Completed image prep 'Publisher:'$Publisher 'Offer:'$offer 'Sku:'$Skus 'Version:'$version"
Log-Command -Description $LogOut -LogFile $LogOutFile
}

Function MakeImageNoPlanInfo_CentOs72 {
param(
	[string]$VMName = $VMName,
	[string]$Publisher = "OpenLogic",
	[string]$offer = "Centos",
	[string]$Skus = "7.2",
	[string]$version = "latest"

)
Write-Host "Image Creation in Process - No Plan Info - CentOs 7.2" -ForegroundColor White
Write-Host 'Publisher:'$Publisher 'Offer:'$offer 'Sku:'$Skus 'Version:'$version
	   if($addssh -or $batchaddssh -eq 'True')
	{ $script:VirtualMachine = Set-AzureRmVMOperatingSystem -VM $VirtualMachine -linux -ComputerName $VMName -Credential $Credential1 -DisablePasswordAuthentication}
	else
		{ $script:VirtualMachine = Set-AzureRmVMOperatingSystem -VM $VirtualMachine -linux -ComputerName $VMName -Credential $Credential1 }
$script:VirtualMachine = Set-AzureRmVMSourceImage -VM $VirtualMachine -PublisherName $Publisher -Offer $offer -Skus $Skus -Version $version
$LogOut = "Completed image prep 'Publisher:'$Publisher 'Offer:'$offer 'Sku:'$Skus 'Version:'$version"
Log-Command -Description $LogOut -LogFile $LogOutFile
}

Function MakeImageNoPlanInfo_CentOs68 {
param(
	[string]$VMName = $VMName,
	[string]$Publisher = "OpenLogic",
	[string]$offer = "Centos",
	[string]$Skus = "6.8",
	[string]$version = "latest"

)
Write-Host "Image Creation in Process - No Plan Info - CentOs 6.8" -ForegroundColor White
Write-Host 'Publisher:'$Publisher 'Offer:'$offer 'Sku:'$Skus 'Version:'$version
	   if($addssh -or $batchaddssh -eq 'True')
	{ $script:VirtualMachine = Set-AzureRmVMOperatingSystem -VM $VirtualMachine -linux -ComputerName $VMName -Credential $Credential1 -DisablePasswordAuthentication }
	else
	{ $script:VirtualMachine = Set-AzureRmVMOperatingSystem -VM $VirtualMachine -linux -ComputerName $VMName -Credential $Credential1 }
$script:VirtualMachine = Set-AzureRmVMSourceImage -VM $VirtualMachine -PublisherName $Publisher -Offer $offer -Skus $Skus -Version $version
$LogOut = "Completed image prep 'Publisher:'$Publisher 'Offer:'$offer 'Sku:'$Skus 'Version:'$version"
Log-Command -Description $LogOut -LogFile $LogOutFile
}

Function MakeImageNoPlanInfo_Suse {
param(
	[string]$VMName = $VMName,
	[string]$Publisher = "Suse",
	[string]$offer = "openSUSE-Leap",
	[string]$Skus = "42.2",
	[string]$version = "latest"
)
Write-Host "Image Creation in Process - No Plan Info - SUSE" -ForegroundColor White
	   if($addssh -or $batchaddssh -eq 'True')
	{ $script:VirtualMachine = Set-AzureRmVMOperatingSystem -VM $VirtualMachine -linux -ComputerName $VMName -Credential $Credential1 -DisablePasswordAuthentication }
	else
		{ $script:VirtualMachine = Set-AzureRmVMOperatingSystem -VM $VirtualMachine -linux -ComputerName $VMName -Credential $Credential1 }
$script:VirtualMachine = Set-AzureRmVMSourceImage -VM $VirtualMachine -PublisherName $Publisher -Offer $offer -Skus $Skus -Version $version
$LogOut = "Completed image prep 'Publisher:'$Publisher 'Offer:'$offer 'Sku:'$Skus 'Version:'$version"
Log-Command -Description $LogOut -LogFile $LogOutFile
}

Function MakeImagePlanInfo_tableau {
param(
	[string]$VMName = $VMName,
	[string]$Publisher = 'tableau',
	[string]$offer = 'tableau-server',
	[string]$Skus = 'bring-your-own-license',
	[string]$version = 'latest',
	[string]$Product = 'tableau-server',
	[string]$name = 'bring-your-own-license'
)
Write-Host "Image Creation in Process - Plan Info - Tableau" -ForegroundColor White
Write-Host 'Publisher:'$Publisher 'Offer:'$offer 'Sku:'$Skus 'Version:'$version
$script:VirtualMachine= Set-AzureRmVMPlan -VM $VirtualMachine -Name $name -Publisher $Publisher -Product $Product
$script:VirtualMachine = Set-AzureRmVMOperatingSystem -VM $VirtualMachine -windows -ComputerName $VMName -Credential $Credential1
$script:VirtualMachine = Set-AzureRmVMSourceImage -VM $VirtualMachine -PublisherName $Publisher -Offer $offer -Skus $Skus -Version $version
$LogOut = "Completed image prep 'Publisher:'$Publisher 'Offer:'$offer 'Sku:'$Skus 'Version:'$version"
Log-Command -Description $LogOut -LogFile $LogOutFile
}

Function MakeImagePlanInfo_RevAnalytics_win {
param(
	[string]$VMName = $VMName,
	[string]$Publisher = 'revolution-analytics',
	[string]$offer = 'revolution-r-enterprise',
	[string]$Skus = 'rre74-win2012r2',
	[string]$version = 'latest',
	[string]$Product = 'revolution-r-enterprise',
	[string]$name = 'rre74-win2012r2'
)
Write-Host "Image Creation in Process - Plan Info - Revo Analytics" -ForegroundColor White
Write-Host 'Publisher:'$Publisher 'Offer:'$offer 'Sku:'$Skus 'Version:'$version
$script:VirtualMachine= Set-AzureRmVMPlan -VM $VirtualMachine -Name $name -Publisher $Publisher -Product $Product
$script:VirtualMachine = Set-AzureRmVMOperatingSystem -VM $VirtualMachine -windows -ComputerName $VMName -Credential $Credential1
$script:VirtualMachine = Set-AzureRmVMSourceImage -VM $VirtualMachine -PublisherName $Publisher -Offer $offer -Skus $Skus -Version $version
$LogOut = "Completed image prep 'Publisher:'$Publisher 'Offer:'$offer 'Sku:'$Skus 'Version:'$version"
Log-Command -Description $LogOut -LogFile $LogOutFile
}

Function MakeImagePlanInfo_RevAnalytics_cent {
param(
	[string]$VMName = $VMName,
	[string]$Publisher = 'revolution-analytics',
	[string]$offer = 'revolution-r-enterprise',
	[string]$Skus = 'rre74-centos65',
	[string]$version = 'latest',
	[string]$Product = 'revolution-r-enterprise',
	[string]$name = 'rre74-centos65'
)
Write-Host "Image Creation in Process - Plan Info - Revo Analytics" -ForegroundColor White
Write-Host 'Publisher:'$Publisher 'Offer:'$offer 'Sku:'$Skus 'Version:'$version
$script:VirtualMachine= Set-AzureRmVMPlan -VM $VirtualMachine -Name $name -Publisher $Publisher -Product $Product
$script:VirtualMachine = Set-AzureRmVMOperatingSystem -VM $VirtualMachine -windows -ComputerName $VMName -Credential $Credential1
$script:VirtualMachine = Set-AzureRmVMSourceImage -VM $VirtualMachine -PublisherName $Publisher -Offer $offer -Skus $Skus -Version $version
$LogOut = "Completed image prep 'Publisher:'$Publisher 'Offer:'$offer 'Sku:'$Skus 'Version:'$version"
Log-Command -Description $LogOut -LogFile $LogOutFile
}

Function MakeImagenoPlanInfo_ads_datascience {
param(
	[string]$VMName = $VMName,
	[string]$Publisher = 'microsoft-ads',
	[string]$offer = 'linux-data-science-vm',
	[string]$Skus = 'linuxdsvm',
	[string]$version = 'latest',
	[string]$Product = 'linux-data-science-vm',
	[string]$name = 'linuxdsvm'
)
Write-Host "Image Creation in Process - No Plan Info - Ads Data Science" -ForegroundColor White
Write-Host 'Publisher:'$Publisher 'Offer:'$offer 'Sku:'$Skus 'Version:'$version
$script:VirtualMachine= Set-AzureRmVMPlan -VM $VirtualMachine -Name $name -Publisher $Publisher -Product $Product
$script:VirtualMachine = Set-AzureRmVMOperatingSystem -VM $VirtualMachine -linux -ComputerName $VMName -Credential $Credential1
$script:VirtualMachine = Set-AzureRmVMSourceImage -VM $VirtualMachine -PublisherName $Publisher -Offer $offer -Skus $Skus -Version $version
$LogOut = "Completed image prep 'Publisher:'$Publisher 'Offer:'$offer 'Sku:'$Skus 'Version:'$version"
Log-Command -Description $LogOut -LogFile $LogOutFile
}

Function MakeImagenoPlanInfo_ads_stddatascience {
param(
	[string]$VMName = $VMName,
	[string]$Publisher = 'microsoft-ads',
	[string]$offer = 'standard-data-science-vm',
	[string]$Skus = 'standard-data-science-vm',
	[string]$version = 'latest',
	[string]$Product = 'standard-data-science-vm',
	[string]$name = 'standard-data-science-vm'
)
Write-Host "Image Creation in Process - No Plan Info - Ads Data Science Standard" -ForegroundColor White
Write-Host 'Publisher:'$Publisher 'Offer:'$offer 'Sku:'$Skus 'Version:'$version
$script:VirtualMachine= Set-AzureRmVMPlan -VM $VirtualMachine -Name $name -Publisher $Publisher -Product $Product
$script:VirtualMachine = Set-AzureRmVMOperatingSystem -VM $VirtualMachine -linux -ComputerName $VMName -Credential $Credential1
$script:VirtualMachine = Set-AzureRmVMSourceImage -VM $VirtualMachine -PublisherName $Publisher -Offer $offer -Skus $Skus -Version $version
$LogOut = "Completed image prep 'Publisher:'$Publisher 'Offer:'$offer 'Sku:'$Skus 'Version:'$version"
Log-Command -Description $LogOut -LogFile $LogOutFile
}

Function MakeImageNoPlanInfo_Ubuntu14 {
param(
	[string]$VMName = $VMName,
	[string]$Publisher = "Canonical",
	[string]$offer = "UbuntuServer",
	[string]$Skus = "14.04.4-LTS",
	[string]$version = "latest"
)
Write-Host "Image Creation in Process - No Plan Info - Ubuntu 14.04" -ForegroundColor White
Write-Host 'Publisher:'$Publisher 'Offer:'$offer 'Sku:'$Skus 'Version:'$version
$script:VirtualMachine = Set-AzureRmVMOperatingSystem -VM $VirtualMachine -linux -ComputerName $VMName -Credential $Credential1
$script:VirtualMachine = Set-AzureRmVMSourceImage -VM $VirtualMachine -PublisherName $Publisher -Offer $offer -Skus $Skus -Version $version
$LogOut = "Completed image prep 'Publisher:'$Publisher 'Offer:'$offer 'Sku:'$Skus 'Version:'$version"
Log-Command -Description $LogOut -LogFile $LogOutFile
}

Function MakeImageNoPlanInfo_Ubuntu16 {
param(
	[string]$VMName = $VMName,
	[string]$Publisher = "Canonical",
	[string]$offer = "UbuntuServer",
	[string]$Skus = "16.04.0-LTS",
	[string]$version = "latest"
)
Write-Host "Image Creation in Process - No Plan Info - Ubuntu 16.04" -ForegroundColor White
Write-Host 'Publisher:'$Publisher 'Offer:'$offer 'Sku:'$Skus 'Version:'$version
$script:VirtualMachine = Set-AzureRmVMOperatingSystem -VM $VirtualMachine -linux -ComputerName $VMName -Credential $Credential1
$script:VirtualMachine = Set-AzureRmVMSourceImage -VM $VirtualMachine -PublisherName $Publisher -Offer $offer -Skus $Skus -Version $version
$LogOut = "Completed image prep 'Publisher:'$Publisher 'Offer:'$offer 'Sku:'$Skus 'Version:'$version"
Log-Command -Description $LogOut -LogFile $LogOutFile
}

Function MakeImagePlanInfo_Chef {
param(
	[string]$VMName = $VMName,
	[string]$Publisher = 'chef-software',
	[string]$offer = 'chef-server',
	[string]$Skus = 'azure_marketplace_25',
	[string]$version = 'latest',
	[string]$Product = 'chef-server',
	[string]$name = 'azure_marketplace_25'
)
Write-Host "Image Creation in Process - Plan Info - Chef" -ForegroundColor White
Write-Host 'Publisher:'$Publisher 'Offer:'$offer 'Sku:'$Skus 'Version:'$version
$script:VirtualMachine = Set-AzureRmVMPlan -VM $VirtualMachine -Name $name -Publisher $Publisher -Product $Product
$script:VirtualMachine = Set-AzureRmVMOperatingSystem -VM $VirtualMachine -linux -ComputerName $VMName -Credential $Credential1
$script:VirtualMachine = Set-AzureRmVMSourceImage -VM $VirtualMachine -PublisherName $Publisher -Offer $offer -Skus $Skus -Version $version
$LogOut = "Completed image prep 'Publisher:'$Publisher 'Offer:'$offer 'Sku:'$Skus 'Version:'$version"
Log-Command -Description $LogOut -LogFile $LogOutFile
}

Function MakeImageNoPlanInfo_w2k12 {
param(
	[string]$VMName = $VMName,
	[string]$Publisher = "MicrosoftWindowsServer",
	[string]$offer = "WindowsServer",
	[string]$Skus = "2012-R2-Datacenter",
	[string]$version = "latest"
)
Write-Host "Image Creation in Process - No Plan Info - W2k12 server" -ForegroundColor White
Write-Host 'Publisher:'$Publisher 'Offer:'$offer 'Sku:'$Skus 'Version:'$version
$script:VirtualMachine = Set-AzureRmVMOperatingSystem -VM $VirtualMachine -Windows -ComputerName $VMName -Credential $Credential1 -ProvisionVMAgent -EnableAutoUpdate -WinRMHttp -Verbose
$script:VirtualMachine = Set-AzureRmVMSourceImage -VM $VirtualMachine -PublisherName $Publisher -Offer $offer -Skus $Skus -Version $version
$LogOut = "Completed image prep 'Publisher:'$Publisher 'Offer:'$offer 'Sku:'$Skus 'Version:'$version"
Log-Command -Description $LogOut -LogFile $LogOutFile
}

Function MakeImageNoPlanInfo_w2k8 {
param(
	[string]$VMName = $VMName,
	[string]$Publisher = "MicrosoftWindowsServer",
	[string]$offer = "WindowsServer",
	[string]$Skus = "2008-R2-SP1",
	[string]$version = "latest"
)
Write-Host "Image Creation in Process - No Plan Info - W2k8 server" -ForegroundColor White
Write-Host 'Publisher:'$Publisher 'Offer:'$offer 'Sku:'$Skus 'Version:'$version
$script:VirtualMachine = Set-AzureRmVMOperatingSystem -VM $VirtualMachine -Windows -ComputerName $VMName -Credential $Credential1 -ProvisionVMAgent -EnableAutoUpdate -WinRMHttp -Verbose
$script:VirtualMachine = Set-AzureRmVMSourceImage -VM $VirtualMachine -PublisherName $Publisher -Offer $offer -Skus $Skus -Version $version
$LogOut = "Completed image prep 'Publisher:'$Publisher 'Offer:'$offer 'Sku:'$Skus 'Version:'$version"
Log-Command -Description $LogOut -LogFile $LogOutFile
}

Function MakeImageNoPlanInfo_SharePoint2k13 {
param(
	[string]$VMName = $VMName,
	[string]$Publisher = "MicrosoftSharePoint",
	[string]$offer = "MicrosoftSharePointServer",
	[string]$Skus = "2013",
	[string]$version = "latest"
)
Write-Host "Image Creation in Process - No Plan Info - SharePoint 2013 server" -ForegroundColor White
Write-Host 'Publisher:'$Publisher 'Offer:'$offer 'Sku:'$Skus 'Version:'$version
$script:VirtualMachine = Set-AzureRmVMOperatingSystem -VM $VirtualMachine -Windows -ComputerName $VMName -Credential $Credential1 -ProvisionVMAgent -EnableAutoUpdate -WinRMHttp -Verbose
$script:VirtualMachine = Set-AzureRmVMSourceImage -VM $VirtualMachine -PublisherName $Publisher -Offer $offer -Skus $Skus -Version $version
$LogOut = "Completed image prep 'Publisher:'$Publisher 'Offer:'$offer 'Sku:'$Skus 'Version:'$version"
Log-Command -Description $LogOut -LogFile $LogOutFile
}

Function MakeImageNoPlanInfo_MSNAV2016 {
param(
	[string]$VMName = $VMName,
	[string]$Publisher = "MicrosoftDynamicsNAV",
	[string]$offer = "DynamicsNAV",
	[string]$Skus = "2016",
	[string]$version = "latest"
)
Write-Host "Image Creation in Process - No Plan Info - MS Nav 2016" -ForegroundColor White
Write-Host 'Publisher:'$Publisher 'Offer:'$offer 'Sku:'$Skus 'Version:'$version
$script:VirtualMachine = Set-AzureRmVMOperatingSystem -VM $VirtualMachine -Windows -ComputerName $VMName -Credential $Credential1 -ProvisionVMAgent -EnableAutoUpdate -WinRMHttp -Verbose
$script:VirtualMachine = Set-AzureRmVMSourceImage -VM $VirtualMachine -PublisherName $Publisher -Offer $offer -Skus $Skus -Version $version
$LogOut = "Completed image prep 'Publisher:'$Publisher 'Offer:'$offer 'Sku:'$Skus 'Version:'$version"
Log-Command -Description $LogOut -LogFile $LogOutFile
}

Function MakeImageNoPlanInfo_SharePoint2k16 {
param(
	[string]$VMName = $VMName,
	[string]$Publisher = "MicrosoftSharePoint",
	[string]$offer = "MicrosoftSharePointServer",
	[string]$Skus = "2016",
	[string]$version = "latest"
)
Write-Host "Image Creation in Process - No Plan Info - SharePoint 2016 server" -ForegroundColor White
Write-Host 'Publisher:'$Publisher 'Offer:'$offer 'Sku:'$Skus 'Version:'$version
$script:VirtualMachine = Set-AzureRmVMOperatingSystem -VM $VirtualMachine -Windows -ComputerName $VMName -Credential $Credential1 -ProvisionVMAgent -EnableAutoUpdate -WinRMHttp -Verbose
$script:VirtualMachine = Set-AzureRmVMSourceImage -VM $VirtualMachine -PublisherName $Publisher -Offer $offer -Skus $Skus -Version $version
$LogOut = "Completed image prep 'Publisher:'$Publisher 'Offer:'$offer 'Sku:'$Skus 'Version:'$version"
Log-Command -Description $LogOut -LogFile $LogOutFile
}
Function makeimage_withinfo_sp-sp-splunk-on-ubuntu-14-04-lts
{
param(
	[string]$VMName = $VMName,
	[string]$Publisher = 'splunk',
	[string]$Offer = 'splunk-enterprise-base-image',
	[string]$Skus = 'splunk-on-ubuntu-14-04-lts',
	[string]$version =  'latest',
	[string]$Product = 'splunk-enterprise-base-image',
	[string]$name = 'splunk-on-ubuntu-14-04-lts'
)
Write-Host "Image Creation in Process - Plan Info - splunk | splunk-on-ubuntu-14-04-lts"
$script:VirtualMachine = Set-AzureRmVMPlan -VM $VirtualMachine -Name $name -Publisher $Publisher -Product $Product
$script:VirtualMachine = Set-AzureRmVMOperatingSystem -VM $VirtualMachine -linux -ComputerName $VMName -Credential $Credential1
$script:VirtualMachine = Set-AzureRmVMSourceImage -VM $VirtualMachine -PublisherName $Publisher -Offer $offer -Skus $Skus -Version $version
$LogOut = "Completed image prep Publisher: splunk Offer:splunk-enterprise-base-image Sku:splunk-on-ubuntu-14-04-lts Version:latest"
Log-Command -Description $LogOut -LogFile $LogOutFile
}

Function MakeImageNoPlanInfo_w2k16 {
param(
	[string]$VMName = $VMName,
	[string]$Publisher = "MicrosoftWindowsServer",
	[string]$offer = "WindowsServer",
	[string]$Skus = "2016-Datacenter",
	[string]$version = "latest"
)
Write-Host "Image Creation in Process - No Plan Info - W2k16 server" -ForegroundColor White
Write-Host 'Publisher:'$Publisher 'Offer:'$offer 'Sku:'$Skus 'Version:'$version
$script:VirtualMachine = Set-AzureRmVMOperatingSystem -VM $VirtualMachine -Windows -ComputerName $VMName -Credential $Credential1 -ProvisionVMAgent -EnableAutoUpdate -WinRMHttp -Verbose
$script:VirtualMachine = Set-AzureRmVMSourceImage -VM $VirtualMachine -PublisherName $Publisher -Offer $offer -Skus $Skus -Version $version
$LogOut = "Completed image prep 'Publisher:'$Publisher 'Offer:'$offer 'Sku:'$Skus 'Version:'$version"
Log-Command -Description $LogOut -LogFile $LogOutFile
}
Function MakeImageNoPlanInfo_w2k16Nano {
param(
	[string]$VMName = $VMName,
	[string]$Publisher = "MicrosoftWindowsServer",
	[string]$offer = "WindowsServer",
	[string]$Skus = "2016-Nano-Server",
	[string]$version = "latest"
)
Write-Host "Image Creation in Process - No Plan Info - W2k16 Nano server" -ForegroundColor White
Write-Host 'Publisher:'$Publisher 'Offer:'$offer 'Sku:'$Skus 'Version:'$version
$script:VirtualMachine = Set-AzureRmVMOperatingSystem -VM $VirtualMachine -Windows -ComputerName $VMName -Credential $Credential1 -ProvisionVMAgent -EnableAutoUpdate -WinRMHttp -Verbose
$script:VirtualMachine = Set-AzureRmVMSourceImage -VM $VirtualMachine -PublisherName $Publisher -Offer $offer -Skus $Skus -Version $version
$LogOut = "Completed image prep 'Publisher:'$Publisher 'Offer:'$offer 'Sku:'$Skus 'Version:'$version"
Log-Command -Description $LogOut -LogFile $LogOutFile
}
Function MakeImageNoPlanInfo_TeamFoundationServer {
param(
	[string]$VMName = $VMName,
	[string]$Publisher = 'MicrosoftVisualStudio',
	[string]$offer = 'TeamFoundationServer',
	[string]$Skus = 'Team-Foundation-Server-2013-Update4-WS2012R2',
	[string]$version = 'latest',
	[string]$Product = 'Team-Foundation-Server-2013-Update4-WS2012R2',
	[string]$name = 'TeamFoundationServer'
)
Write-Host "Image Creation in Process - No Plan Info - TeamFoundationServer" -ForegroundColor White
Write-Host 'Publisher:'$Publisher 'Offer:'$offer 'Sku:'$Skus 'Version:'$version
$script:VirtualMachine = Set-AzureRmVMOperatingSystem -VM $VirtualMachine -Windows -ComputerName $VMName -Credential $Credential1 -ProvisionVMAgent -EnableAutoUpdate -WinRMHttp -Verbose
$script:VirtualMachine = Set-AzureRmVMSourceImage -VM $VirtualMachine -PublisherName $Publisher -Offer $offer -Skus $Skus -Version $version
$LogOut = "Completed image prep 'Publisher:'$Publisher 'Offer:'$offer 'Sku:'$Skus 'Version:'$version"
Log-Command -Description $LogOut -LogFile $LogOutFile
}
Function MakeImageNoPlanInfo_Biztalk-Enterprise {
param(
	[string]$VMName = $VMName,
	[string]$Publisher = 'MicrosoftBizTalkServer',
	[string]$offer = 'BizTalk-Server',
	[string]$Skus = '2013-R2-Enterprise',
	[string]$version = 'latest'
)
Write-Host "Image Creation in Process - No Plan Info - MicrosoftBizTalkServer" -ForegroundColor White
Write-Host 'Publisher:'$Publisher 'Offer:'$offer 'Sku:'$Skus 'Version:'$version
$script:VirtualMachine = Set-AzureRmVMOperatingSystem -VM $VirtualMachine -Windows -ComputerName $VMName -Credential $Credential1 -ProvisionVMAgent -EnableAutoUpdate -WinRMHttp -Verbose
$script:VirtualMachine = Set-AzureRmVMSourceImage -VM $VirtualMachine -PublisherName $Publisher -Offer $offer -Skus $Skus -Version $version
$LogOut = "Completed image prep 'Publisher:'$Publisher 'Offer:'$offer 'Sku:'$Skus 'Version:'$version"
Log-Command -Description $LogOut -LogFile $LogOutFile
}
Function MakeImageNoPlanInfo_Biztalk2016-PreRelease {
param(
	[string]$VMName = $VMName,
	[string]$Publisher = 'MicrosoftBizTalkServer',
	[string]$offer = 'BizTalk-Server',
	[string]$Skus = '2016-PreRelease',
	[string]$version = 'latest'
)
Write-Host "Image Creation in Process - No Plan Info - MicrosoftBizTalkServer2016" -ForegroundColor White
Write-Host 'Publisher:'$Publisher 'Offer:'$offer 'Sku:'$Skus 'Version:'$version
$script:VirtualMachine = Set-AzureRmVMOperatingSystem -VM $VirtualMachine -Windows -ComputerName $VMName -Credential $Credential1 -ProvisionVMAgent -EnableAutoUpdate -WinRMHttp -Verbose
$script:VirtualMachine = Set-AzureRmVMSourceImage -VM $VirtualMachine -PublisherName $Publisher -Offer $offer -Skus $Skus -Version $version
$LogOut = "Completed image prep 'Publisher:'$Publisher 'Offer:'$offer 'Sku:'$Skus 'Version:'$version"
Log-Command -Description $LogOut -LogFile $LogOutFile
}

Function MakeImagePlanInfo_metavistech {
param(
	[string]$VMName = $VMName,
	[string]$Publisher = 'metavistech',
	[string]$offer = 'metavis-office365-suite',
	[string]$Skus = 'mv-office365-ste-azure-1',
	[string]$version = 'latest',
	[string]$Product = 'metavis-office365-suite',
	[string]$name = 'mv-office365-ste-azure-1'
)
Write-Host "Image Creation in Process - Plan Info - metavistech" -ForegroundColor White
Write-Host 'Publisher:'$Publisher 'Offer:'$offer 'Sku:'$Skus 'Version:'$version
$script:VirtualMachine= Set-AzureRmVMPlan -VM $VirtualMachine -Name $name -Publisher $Publisher -Product $Product
$script:VirtualMachine = Set-AzureRmVMOperatingSystem -VM $VirtualMachine -linux -ComputerName $VMName -Credential $Credential1
$script:VirtualMachine = Set-AzureRmVMSourceImage -VM $VirtualMachine -PublisherName $Publisher -Offer $offer -Skus $Skus -Version $version
$LogOut = "Completed image prep 'Publisher:'$Publisher 'Offer:'$offer 'Sku:'$Skus 'Version:'$version"
Log-Command -Description $LogOut -LogFile $LogOutFile
}

Function MakeImageNoPlanInfo_sql2k16 {
param(
	[string]$VMName = $VMName,
	[string]$Publisher = "MicrosoftSQLServer",
	[string]$offer = "SQL2016-WS2012R2",
	[string]$Skus = "Enterprise",
	[string]$version = "latest"
)
Write-Host "Image Creation in Process - No Plan Info - SQL 2016" -ForegroundColor White
Write-Host $Publisher $offer $Skus $version
$script:VirtualMachine = Set-AzureRmVMOperatingSystem -VM $VirtualMachine -Windows -ComputerName $VMName -Credential $Credential1 -ProvisionVMAgent -EnableAutoUpdate -WinRMHttp -Verbose
$script:VirtualMachine = Set-AzureRmVMSourceImage -VM $VirtualMachine -PublisherName $Publisher -Offer $offer -Skus $Skus -Version $version
$LogOut = "Completed image prep 'Publisher:'$Publisher 'Offer:'$offer 'Sku:'$Skus 'Version:'$version"
Log-Command -Description $LogOut -LogFile $LogOutFile
}

Function MakeImageNoPlanInfo_sql2k14 {
param(
	[string]$VMName = $VMName,
	[string]$Publisher = "MicrosoftSQLServer",
	[string]$offer = "SQL2014-WS2012R2",
	[string]$Skus = "Enterprise",
	[string]$version = "latest"
)
Write-Host "Image Creation in Process - No Plan Info - SQL 2014" -ForegroundColor White
Write-Host $Publisher $offer $Skus $version
$script:VirtualMachine = Set-AzureRmVMOperatingSystem -VM $VirtualMachine -Windows -ComputerName $VMName -Credential $Credential1 -ProvisionVMAgent -EnableAutoUpdate -WinRMHttp -Verbose
$script:VirtualMachine = Set-AzureRmVMSourceImage -VM $VirtualMachine -PublisherName $Publisher -Offer $offer -Skus $Skus -Version $version
$LogOut = "Completed image prep 'Publisher:'$Publisher 'Offer:'$offer 'Sku:'$Skus 'Version:'$version"
Log-Command -Description $LogOut -LogFile $LogOutFile
}

Function MakeImagePlanInfo_incredibuild {
param(
	[string]$VMName = $VMName,
	[string]$Publisher = 'incredibuild',
	[string]$offer = 'incredibuild',
	[string]$Skus = 'incredibuild',
	[string]$version = 'latest',
	[string]$Product = 'incredibuild',
	[string]$name = 'incredibuild'
)
Write-Host "Image Creation in Process - Plan Info - incredibuild" -ForegroundColor White
Write-Host 'Publisher:'$Publisher 'Offer:'$offer 'Sku:'$Skus 'Version:'$version
$script:VirtualMachine= Set-AzureRmVMPlan -VM $VirtualMachine -Name $name -Publisher $Publisher -Product $Product
$script:VirtualMachine = Set-AzureRmVMOperatingSystem -VM $VirtualMachine -linux -ComputerName $VMName -Credential $Credential1
$script:VirtualMachine = Set-AzureRmVMSourceImage -VM $VirtualMachine -PublisherName $Publisher -Offer $offer -Skus $Skus -Version $version
$LogOut = "Completed image prep 'Publisher:'$Publisher 'Offer:'$offer 'Sku:'$Skus 'Version:'$version"
Log-Command -Description $LogOut -LogFile $LogOutFile
}

Function MakeImagePlanInfo_hortonwowk_dp {
param(
	[string]$VMName = $VMName,
	[string]$Publisher = 'hortonworks',
	[string]$offer = 'hortonworks-data-platform-240',
	[string]$Skus = 'hdp-240-ambari-221',
	[string]$version = 'latest',
	[string]$Product = 'hortonworks-data-platform-240',
	[string]$name = 'hdp-240-ambari-221'
)
Write-Host "Image Creation in Process - Plan Info - HortonWorks" -ForegroundColor White
Write-Host 'Publisher:'$Publisher 'Offer:'$offer 'Sku:'$Skus 'Version:'$version
$script:VirtualMachine= Set-AzureRmVMPlan -VM $VirtualMachine -Name $name -Publisher $Publisher -Product $Product
$script:VirtualMachine = Set-AzureRmVMOperatingSystem -VM $VirtualMachine -linux -ComputerName $VMName -Credential $Credential1
$script:VirtualMachine = Set-AzureRmVMSourceImage -VM $VirtualMachine -PublisherName $Publisher -Offer $offer -Skus $Skus -Version $version
$LogOut = "Completed image prep 'Publisher:'$Publisher 'Offer:'$offer 'Sku:'$Skus 'Version:'$version"
Log-Command -Description $LogOut -LogFile $LogOutFile
}
Function MakeImagePlanInfo_hortonwowk_hdp {
param(
	[string]$VMName = $VMName,
	[string]$Publisher = 'hortonworks',
	[string]$offer = 'hdpimage',
	[string]$Skus = 'hdpimage',
	[string]$version = 'latest',
	[string]$Product = 'hdpimage',
	[string]$name = 'hdpimage'
)
Write-Host "Image Creation in Process - Plan Info - HortonWorks" -ForegroundColor White
Write-Host 'Publisher:'$Publisher 'Offer:'$offer 'Sku:'$Skus 'Version:'$version
$script:VirtualMachine= Set-AzureRmVMPlan -VM $VirtualMachine -Name $name -Publisher $Publisher -Product $Product
$script:VirtualMachine = Set-AzureRmVMOperatingSystem -VM $VirtualMachine -linux -ComputerName $VMName -Credential $Credential1
$script:VirtualMachine = Set-AzureRmVMSourceImage -VM $VirtualMachine -PublisherName $Publisher -Offer $offer -Skus $Skus -Version $version
$LogOut = "Completed image prep 'Publisher:'$Publisher 'Offer:'$offer 'Sku:'$Skus 'Version:'$version"
Log-Command -Description $LogOut -LogFile $LogOutFile
}

Function MakeImagenoPlanInfo_w2012r2vs2015 {
param(
	[string]$VMName = $VMName,
	[string]$Publisher = 'MicrosoftVisualStudio',
	[string]$offer = 'VisualStudio',
	[string]$Skus = 'VS-2015-Ent-AzureSDK-2.9-WS2012R2',
	[string]$version = 'latest'
)
Write-Host "Image Creation in Process - No Plan Info - MicrosoftVisualStudio" -ForegroundColor White
Write-Host 'Publisher:'$Publisher 'Offer:'$offer 'Sku:'$Skus 'Version:'$version
$script:VirtualMachine = Set-AzureRmVMOperatingSystem -VM $VirtualMachine -Windows -ComputerName $VMName -Credential $Credential1 -ProvisionVMAgent -EnableAutoUpdate -WinRMHttp -Verbose
$script:VirtualMachine = Set-AzureRmVMSourceImage -VM $VirtualMachine -PublisherName $Publisher -Offer $offer -Skus $Skus -Version $version
$LogOut = "Completed image prep 'Publisher:'$Publisher 'Offer:'$offer 'Sku:'$Skus 'Version:'$version"
Log-Command -Description $LogOut -LogFile $LogOutFile
}

Function MakeImagenoPlanInfo_w2012r2dev15 {
param(
	[string]$VMName = $VMName,
	[string]$Publisher = 'MicrosoftVisualStudio',
	[string]$offer = 'VisualStudio',
	[string]$Skus = 'VS-Dev15-Preview3-Ent-AzureSDK-291-WS2012R2',
	[string]$version = 'latest'
)
Write-Host "Image Creation in Process - No Plan Info - Dev15 Preview" -ForegroundColor White
Write-Host 'Publisher:'$Publisher 'Offer:'$offer 'Sku:'$Skus 'Version:'$version
$script:VirtualMachine = Set-AzureRmVMOperatingSystem -VM $VirtualMachine -Windows -ComputerName $VMName -Credential $Credential1 -ProvisionVMAgent -EnableAutoUpdate -WinRMHttp -Verbose
$script:VirtualMachine = Set-AzureRmVMSourceImage -VM $VirtualMachine -PublisherName $Publisher -Offer $offer -Skus $Skus -Version $version
$LogOut = "Completed image prep 'Publisher:'$Publisher 'Offer:'$offer 'Sku:'$Skus 'Version:'$version"
Log-Command -Description $LogOut -LogFile $LogOutFile
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
[string]$SubnetNameAddPrefix6 = $SubnetNameAddPrefix6
)

Write-ConfigVNet
	Write-Host "Network Preparation in Process.."
	$subnet1 = New-AzureRmVirtualNetworkSubnetConfig -AddressPrefix $SubnetAddPrefix1 -Name $SubnetNameAddPrefix1
	$subnet2 = New-AzureRmVirtualNetworkSubnetConfig -AddressPrefix $SubnetAddPrefix2 -Name $SubnetNameAddPrefix2
	$subnet3 = New-AzureRmVirtualNetworkSubnetConfig -AddressPrefix $SubnetAddPrefix3 -Name $SubnetNameAddPrefix3
	$subnet4 = New-AzureRmVirtualNetworkSubnetConfig -AddressPrefix $SubnetAddPrefix4 -Name $SubnetNameAddPrefix4
	$subnet5 = New-AzureRmVirtualNetworkSubnetConfig -AddressPrefix $SubnetAddPrefix5 -Name $SubnetNameAddPrefix5
	$subnet6 = New-AzureRmVirtualNetworkSubnetConfig -AddressPrefix $SubnetAddPrefix6 -Name $SubnetNameAddPrefix6
	Try
	{
	New-AzureRmVirtualNetwork -Location $Location -Name $VNetName -ResourceGroupName $vnetrg -AddressPrefix $AddRange -Subnet $subnet1,$subnet2,$subnet3,$subnet4,$subnet5 –Confirm:$false -WarningAction SilentlyContinue -Force | Out-Null
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

Function Create-ExtLBIp
{
param(
)
		$script:lbpublicip = New-AzureRmPublicIpAddress -Name 'lbip' -ResourceGroupName $vnetrg -Location $Location -AllocationMethod Dynamic -WarningAction SilentlyContinue -Force -Confirm:$False
}

Function Create-ExtLBIpwDNS
{
param(
$lbfqdn = $lbfqdn
)
		$script:lbpublicip = New-AzureRmPublicIpAddress -Name 'lbip' -ResourceGroupName $vnetrg -Location $Location -AllocationMethod Dynamic -WarningAction SilentlyContinue -Force -Confirm:$False -DomainNameLabel $lbfqdn
		$LogOut = "Completed Public DNS record creation $lbfqdn.$Location.cloudapp.azure.com"
		Log-Command -Description $LogOut -LogFile $LogOutFile
}

Function Create-LB
{
	param(
		[Parameter(Mandatory=$False,ValueFromPipelinebyPropertyName=$true)]
		[string]
		$LBName = $LBName,
		[Parameter(Mandatory=$False,ValueFromPipelinebyPropertyName=$true)]
		[string]
		$Location = $Location,
		[Parameter(Mandatory=$False,ValueFromPipelinebyPropertyName=$true)]
		[string]
		$rg = $vnetrg,
		[Parameter(Mandatory=$False,ValueFromPipelinebyPropertyName=$true)]
		[string]
		$frtpool = 'frontend',
		[Parameter(Mandatory=$False,ValueFromPipelinebyPropertyName=$true)]
		[string]
		$backpool = 'backend'
	)

	Try
	{
	Lb-type
	$script:VNet = Get-AzureRMVirtualNetwork -Name $VNetName -ResourceGroupName $vnetrg | Set-AzureRmVirtualNetwork
	Write-Host "Creating Public Ip, Pools, Probe and Inbound NAT Rules"

	if($addlbfqdn -or $batchaddlbfqdn -eq 'True')
		{Create-ExtLBIpwDNS}
		else
		{Create-ExtLBIp}

		$frtend = New-AzureRmLoadBalancerFrontendIpConfig -Name $frtpool -PublicIpAddress $script:lbpublicip -WarningAction SilentlyContinue
		$backendpool = New-AzureRmLoadBalancerBackendAddressPoolConfig -Name $backpool  -WarningAction SilentlyContinue
		$probecfg = New-AzureRmLoadBalancerProbeConfig -Name 'probecfg' -Protocol Tcp -Port 443 -IntervalInSeconds 30 -ProbeCount 2 -WarningAction SilentlyContinue
		$inboundnat1 = New-AzureRmLoadBalancerInboundNatRuleConfig -Name 'inboundnat1' -FrontendIpConfiguration $frtend -Protocol Tcp -FrontendPort 443 -BackendPort 443 -IdleTimeoutInMinutes 15 -EnableFloatingIP -WarningAction SilentlyContinue
		$inboundnat2 = New-AzureRmLoadBalancerInboundNatRuleConfig -Name 'inboundnat2' -FrontendIpConfiguration $frtend -Protocol Tcp -FrontendPort 3389 -BackendPort 3389 -IdleTimeoutInMinutes 15 -EnableFloatingIP -WarningAction SilentlyContinue
		$inboundnat3 = New-AzureRmLoadBalancerInboundNatRuleConfig -Name 'inboundnat3' -FrontendIpConfiguration $frtend -Protocol Tcp -FrontendPort 3391 -BackendPort 3389 -IdleTimeoutInMinutes 15 -EnableFloatingIP -WarningAction SilentlyContinue
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
		[string]$LBName = $LBName,
		[Parameter(Mandatory=$False,ValueFromPipelinebyPropertyName=$true)]
		[string]$Location = $Location,
		[Parameter(Mandatory=$False,ValueFromPipelinebyPropertyName=$true)]
		[string]$rg = $vnetrg,
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
	Lb-type
	$script:VNet = Get-AzureRMVirtualNetwork -Name $VNetName -ResourceGroupName $vnetrg | Set-AzureRmVirtualNetwork
	Write-Host "Creating Pools, Probe and Inbound NAT Rules"
		$frontendIP = New-AzureRmLoadBalancerFrontendIpConfig -Name $frtpool -PrivateIpAddress $PvtIP -SubnetId $vnet.subnets[$subnet].Id -WarningAction SilentlyContinue
		$backendpool = New-AzureRmLoadBalancerBackendAddressPoolConfig -Name $backpool  -WarningAction SilentlyContinue
		$probecfg = New-AzureRmLoadBalancerProbeConfig -Name 'probecfg' -Protocol Tcp -Port 1433 -IntervalInSeconds 30 -ProbeCount 2 -WarningAction SilentlyContinue
		$inboundnat1 = New-AzureRmLoadBalancerInboundNatRuleConfig -Name 'inboundnat1' -FrontendIpConfiguration $frontendIP -Protocol Tcp -FrontendPort 3391 -BackendPort 3389 -IdleTimeoutInMinutes 15 -EnableFloatingIP -WarningAction SilentlyContinue
		$inboundnat2 = New-AzureRmLoadBalancerInboundNatRuleConfig -Name 'inboundnat2' -FrontendIpConfiguration $frontendIP -Protocol Tcp -FrontendPort 3389 -BackendPort 3389 -IdleTimeoutInMinutes 15 -EnableFloatingIP -WarningAction SilentlyContinue
		$inboundnat3 = New-AzureRmLoadBalancerInboundNatRuleConfig -Name 'inboundnat3' -FrontendIpConfiguration $frontendIP -Protocol Tcp -FrontendPort 1433 -BackendPort 1433 -IdleTimeoutInMinutes 15 -EnableFloatingIP -WarningAction SilentlyContinue
		$inboundnat4 = New-AzureRmLoadBalancerInboundNatRuleConfig -Name 'inboundnat4' -FrontendIpConfiguration $frontendIP -Protocol Tcp -FrontendPort 1434 -BackendPort 1433 -IdleTimeoutInMinutes 15 -EnableFloatingIP -WarningAction SilentlyContinue
		$lbrule = New-AzureRmLoadBalancerRuleConfig -Name 'lbrules' -FrontendIpConfiguration $frontendIP -BackendAddressPool $backendpool -Probe $probecfg -Protocol Tcp -FrontendPort '80' -BackendPort '80' -IdleTimeoutInMinutes '20' -EnableFloatingIP -LoadDistribution SourceIP -WarningAction SilentlyContinue
		$lb = New-AzureRmLoadBalancer -Location $Location -Name $LBName -ResourceGroupName $vnetrg -FrontendIpConfiguration $frontendIP -BackendAddressPool $backendpool -Probe $probecfg -InboundNatRule $inboundnat1,$inboundnat2,$inboundnat3,$inboundnat4 -LoadBalancingRule $lbrule -WarningAction SilentlyContinue -ErrorAction Stop -Force -Confirm:$false
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

Function Get-Preview {
Check-StorageName
Check-NSGName # Verifies required fields have data
Check-AvailabilitySet # Verifies required fields have data
Check-FQDN # Verifies required fields have data
Check-NullValues # Verifies required fields have data
Check-Orphans # Verifies no left overs
Verify-NIC
Check-VnetPreview

Write-ConfigVMPreview
Write-PreviewResults
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
		$httprule = New-AzureRmNetworkSecurityRuleConfig -Name "FrontEnd_HTTP" -Description "HTTP Exception for Web frontends" -Protocol Tcp -SourcePortRange "80" -DestinationPortRange "80" -SourceAddressPrefix "*" -DestinationAddressPrefix "172.10.0.0/21" -Access Allow -Direction Inbound -Priority 200
		$httpsrule = New-AzureRmNetworkSecurityRuleConfig -Name "FrontEnd_HTTPS" -Description "HTTPS Exception for Web frontends" -Protocol Tcp -SourcePortRange "443" -DestinationPortRange "443" -SourceAddressPrefix "*" -DestinationAddressPrefix "172.10.0.0/21" -Access Allow -Direction Inbound -Priority 201
		$sshrule = New-AzureRmNetworkSecurityRuleConfig -Name "FrontEnd_SSH" -Description "SSH Exception for Web frontends" -Protocol Tcp -SourcePortRange "22" -DestinationPortRange "22" -SourceAddressPrefix "*" -DestinationAddressPrefix "172.10.0.0/21" -Access Allow -Direction Inbound ` -Priority 203
		$rdprule = New-AzureRmNetworkSecurityRuleConfig -Name "FrontEnd_RDP" -Description "RDP Exception for frontends" -Protocol Tcp -SourcePortRange "3389" -DestinationPortRange "3389" -SourceAddressPrefix "*" -DestinationAddressPrefix "172.10.0.0/21" -Access Allow -Direction Inbound ` -Priority 204
		$nsg = New-AzureRmNetworkSecurityGroup -ResourceGroupName $vnetrg -Location $Location -Name $NSGName -SecurityRules $httprule,$httpsrule,$sshrule,$rdprule –Confirm:$false -WarningAction SilentlyContinue -Force | Out-Null
		Get-AzureRmNetworkSecurityGroup -Name $NSGName -ResourceGroupName $vnetrg -WarningAction SilentlyContinue | Out-Null
		Write-Host "Network Security Group configuration completed" -ForegroundColor White
		$secrules = Get-AzureRmNetworkSecurityGroup -Name $NSGName -ResourceGroupName $vnetrg -ExpandResource NetworkInterfaces | Get-AzureRmNetworkSecurityRuleConfig | Ft Name,Description,Direction,SourcePortRange,DestinationPortRange,DestinationPortRange,SourceAddressPrefix,Access
			$LogOut = "Security Rules added for $NSGName"
			Log-Command -Description $LogOut -LogFile $LogOutFile

		$defsecrules = Get-AzureRmNetworkSecurityGroup -Name $NSGName -ResourceGroupName $vnetrg -ExpandResource NetworkInterfaces | Get-AzureRmNetworkSecurityRuleConfig -DefaultRules | Ft Name,Description,Direction,SourcePortRange,DestinationPortRange,DestinationAddressPrefix,SourceAddressPrefix,Access
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

Function Subnet-Match {
	Param(
		[Parameter(Mandatory=$False,ValueFromPipelinebyPropertyName=$true,Position=0)]
		[INT]$Subnet,
		[Parameter(Mandatory=$False,ValueFromPipelinebyPropertyName=$true,Position=1)]
		[string]$interfacename = $InterfaceName1
	)
$myvnet = Get-AzureRMVirtualNetwork -Name $VNetName -ResourceGroupName $vnetrg | Set-AzureRmVirtualNetwork
$subcnt = $myvnet.Subnets.Count
$retsubnet = $myvnet.Subnets[$Subnet]
$name = $retsubnet.Name
$pre = $retsubnet.AddressPrefix

Write-Host "VM Deployment Subnet Name: $name "
Write-Host "VM Deployment Subnet Prefix: $pre"
}
#endregion

Function HostNic-Summary {
Write-Host "VM Deployment VNET RG: $vnetrg"
Write-Host "VM Deployment VNET: $vNetName"
If ($ConfigIPs -eq "StatPvtNoPubSingle")
{
Write-Host "VM Static IP - Nic1: $PvtIPNic1"
Subnet-Match $Subnet1
}
If ($ConfigIPs -eq "StatPvtNoPubDual")
{
Write-Host "VM Static IP - Nic1: $PvtIPNic1"
Write-Host "VM Static IP - Nic2: $PvtIPNic2"
Subnet-Match $Subnet1
Subnet-Match $Subnet2
}
If ($ConfigIPs -eq "Single")
{
Subnet-Match $Subnet1
}
If ($ConfigIPs -eq "NoPubSingle")
{
Subnet-Match $Subnet1
}
If ($ConfigIPs -eq "Dual")
{
Subnet-Match $Subnet1
Subnet-Match $Subnet2
}
If ($ConfigIPs -eq "PvtSingleStat")
{
Subnet-Match $Subnet1
Write-Host "VM Static IP - Nic1: $PvtIPNic1"
}
If ($ConfigIPs -eq "PvtDualStat")
{
Subnet-Match $Subnet1
Subnet-Match $Subnet2
Write-Host "VM Static IP - Nic1: $PvtIPNic1"
Write-Host "VM Static IP - Nic2: $PvtIPNic2"
}
}

Function Host-Summary {
Write-Host "Action Type:" $ActionType
Write-Host "VM Name: $VMName " -ForegroundColor White
Write-Host "VM Resource Group: $rg"
Write-Host "Server Type: $vmMarketImage"
Write-Host "Geo Location: $Location"
Write-Host "Storage Resource Group: $storerg"
Write-Host "Storage Account Name: $script:StorageNameVerified"
Write-Host "Storage Account Type: $StorageType"

	if($addextension -or $BatchAddExtension -eq 'True')
		{
		Write-Host "Extension selected for deployment: $extname "
		if($extname -eq 'winpushdsc')
			{
			Write-Host "Push DSC Config File: $WinDSCConfig"
			}
			elseif($extname -eq 'linpushdsc')
			{
			Write-Host "Push DSC Config File: $LinDSCConfig"
			}
				elseif($extname -eq 'linuxcustomscript')
					{
					Write-Host "Linux Custom Script File: $scriptname"
					}
					elseif($extname -eq 'customscript')
							{
					Write-Host "Custom Script File: $scriptname"
							}
		}

Write-Host "Disk Storage Type: $vmstrtype" -ForegroundColor White
Write-Host "VM Size: $VMSize"
Write-Host "VM Deployment VNET Subnet ID: $script:Subnet1"
}

#region Show VM Configuration
Function Write-ConfigVM {
param(
$Subnet1 = $script:Subnet1,
$Subnet2 = $script:Subnet2
)

Write-Host "                                                               "
$time = " Start Time " + (Get-Date -UFormat "%d-%m-%Y %H:%M:%S")
Write-Host VM CONFIGURATION - $time -ForegroundColor Cyan
Write-Host "                                                               "
Host-Summary
HostNic-Summary

if($addssh -or $batchaddssh -eq 'True')
	   {
Write-Host "Adding Public SSH Key to $VMName"
	   }

if($AddLB)
	{
Write-Host "Adding $VMName $InterfaceName1 to Load Balancer $LBName"
	}
Select-NicDescrtipt

if($UploadSharedFiles -or $BatchAddShare -eq 'True')
	{
Write-Host "Create storage share to 'True'"
Write-Host "Share Name:  '$ShareName'"
	}
if($AddAvailabilitySet -or $BatchAddAvset -eq 'True') {
Write-Host "Add VM to Availability Set 'True'"
Write-Host "Availability Set Name:  '$AvailSetName'"
Write-Host "                                                               "
}
else
{
Write-Host "Add VM to Availability Set 'False'" -ForegroundColor White
Write-Host "                                                               "
}
}
#endregion

Function Write-ConfigVMPreview {
param(
$Subnet1 = $script:Subnet1,
$Subnet2 = $script:Subnet2
)

Write-Host "                                                               "
$time = " Start Time " + (Get-Date -UFormat "%d-%m-%Y %H:%M:%S")
Write-Host PREVIEW VM CONFIGURATION -ForegroundColor Cyan
Write-Host "                                                               "
Host-Summary
HostNic-Summary

if($addssh -or $batchaddssh -eq 'True')
	   {
Write-Host "Adding Public SSH Key to $VMName"
	   }

if($AddLB)
	{
Write-Host "Adding $VMName $InterfaceName1 to Load Balancer $LBName"
	}
Select-NicDescrtipt

if($AddExtension -or $BatchAddExtension -eq 'True') {
Write-Host "Extension selected for deployment: $extname "
}
	else
	{
Write-Host "No Extension selected for deployment "
	}
if($UploadSharedFiles -or $BatchAddShare -eq 'True')
	{
Write-Host "Create storage share to 'True'"
Write-Host "Share Name:  '$ShareName'"
	}
if($AddAvailabilitySet -or $BatchAddAvset -eq 'True') {
Write-Host "Add VM to Availability Set 'True'"
Write-Host "Availability Set Name:  '$AvailSetName'"
Write-Host "                                                               "
}
else
{
Write-Host "Add VM to Availability Set 'False'" -ForegroundColor White
Write-Host "                                                               "
}
}

Function Write-ConfigVnetPreview {
Write-Host "                                                               "
$time = " Start Time " + (Get-Date -UFormat "%d-%m-%Y %H:%M:%S")
Write-Host PREVIEW VNET CONFIGURATION - $time -ForegroundColor Cyan
Write-Host "                                                               "
Write-Host "Geo Location: $Location"
Write-Host "VNET Name: $vNetName"
Write-Host "VNET Resource Group Name: $vnetrg"

Write-Host "Address Range:  $AddRange"

if($CreateNSG -or $BatchCreateNSG -eq 'True')
{
Write-Host "Creating NSG Name: $NSGName"
}
if($CreateLoadBalancer -or $BatchCreateLB -eq 'True')
	{
Write-Host "Creating Load Balancer $LBName"
}
}

#region Show Network Config
Function Write-ConfigVnet {
Write-Host "                                                               "
$time = " Start Time " + (Get-Date -UFormat "%d-%m-%Y %H:%M:%S")
Write-Host VNET CONFIGURATION - $time -ForegroundColor Cyan
Write-Host "                                                               "
Write-Host "Action Type:" $ActionType
Write-Host "Geo Location: $Location"
Write-Host "VNET Name: $vNetName"
Write-Host "VNET Resource Group Name: $vnetrg"

Write-Host "Address Range:  $AddRange"

if($CreateNSG -or $BatchCreateNSG -eq 'True')
{
Write-Host "Creating NSG Name: $NSGName"
}
if($CreateLoadBalancer -or $BatchCreateLB -eq 'True')
	{
Write-Host "Creating Load Balancer $LBName"
}

Write-Host "                                                               "
}

#endregion

Function Write-PreviewResults {
param(
$Subnet1 = $script:Subnet1,
$Subnet2 = $script:Subnet2
)

Write-Host "Completed Preview Deployment"  -ForegroundColor White
Write-Host "Action Type: $ActionType | VM Name: $VMName | Server Type: $vmMarketImage"

if($AddExtension -or $BatchAddExtension -eq 'True'){
Write-Host "Extension deployed: $extname "
}
if($UploadSharedFiles -or $BatchAddShare -eq 'True')
	{
Write-Host "Create storage share to 'True'"
Write-Host "Share Name:  '$ShareName'"
	}

if($CreateLoadBalancer -or $BatchCreateLB -eq 'True' -and $LBType -eq 'external')
	{
Write-Host "Completed creation of external load balancer: $LBName"
	}
if($CreateLoadBalancer -or $BatchCreateLB -eq 'True' -and $LBType -eq 'internal')
	{
Write-Host "Completed creation of internal load balancer: $LBName"
	}
if($AddLB)
	{
Write-Host "Completed adding $VMName to load balancer: $LBName"
	}

if($AddAvailabilitySet -or $BatchAddAvset -eq 'True') {
Write-Host "Availability Set Configured"
Write-Host "Availability Set Name: '$AvailSetName'"
Write-Host "                                                               "
}
else
{
Write-Host "                                                               "
}
}

#region Show Final Report
Function Write-Results {
param(
$Subnet1 = $script:Subnet1,
$Subnet2 = $script:Subnet2
)

Write-Host "Completed Deployment"  -ForegroundColor White
Write-Host "Action Type: $ActionType | VM Name: $VMName | Server Type: $vmMarketImage"
Check-VMExtension
Write-Host "                                                               "

if($AddExtension -or $BatchAddExtension -eq 'True'){
Write-Host "Extension deployed: $extname "
}
if($UploadSharedFiles -or $BatchAddShare -eq 'True')
	{
Write-Host "Create storage share to 'True'"
Write-Host "Share Name:  '$ShareName'"
	}

if($CreateLoadBalancer -or $BatchCreateLB -eq 'True' -and $LBType -eq 'external')
	{
Write-Host "Completed creation of external load balancer: $LBName"
	}
if($CreateLoadBalancer -or $BatchCreateLB -eq 'True' -and $LBType -eq 'internal')
	{
Write-Host "Completed creation of internal load balancer: $LBName"
	}
if($AddLB)
	{
Write-Host "Completed adding $VMName to load balancer: $LBName"
	}

if($AddAvailabilitySet -or $BatchAddAvset -eq 'True') {
Write-Host "Availability Set Configured"
Write-Host "Availability Set Name: '$AvailSetName'"
$time = " Completed Time " + (Get-Date -UFormat "%d-%m-%Y %H:%M:%S")
Write-Host VM CONFIGURATION - $time -ForegroundColor Cyan
Write-Host "                                                               "
}
else
{
$time = " Completed Time " + (Get-Date -UFormat "%d-%m-%Y %H:%M:%S")
Write-Host VM CONFIGURATION - $time -ForegroundColor Cyan
Write-Host "                                                               "
}
Write-FinalState
}
#endregion

#region Show Completed State
Function Write-FinalState {
Write-Host "                                                               "
Write-Host "Private Network Interfaces for $rg"
$vms = get-azurermvm -ResourceGroupName $rg -WarningAction SilentlyContinue
$nics = get-azurermnetworkinterface -ResourceGroupName $rg -WarningAction SilentlyContinue | where VirtualMachine -NE $null #skip Nics with no VM
foreach($nic in $nics)
{
	$vm = $vms | where-object -Property Id -EQ $nic.VirtualMachine.id
	$prv =  $nic.IpConfigurations | select-object -ExpandProperty PrivateIpAddress
	$alloc =  $nic.IpConfigurations | select-object -ExpandProperty PrivateIpAllocationMethod
	Write-Output "$($vm.Name) : $prv , $alloc" | Format-Table
}

$pubip = Get-AzureRmPublicIpAddress -Name $InterfaceName1 -ResourceGroupName $rg -ErrorAction SilentlyContinue -WarningAction SilentlyContinue
$dns = Get-AzureRmPublicIpAddress -ExpandResource IPConfiguration -Name $InterfaceName1 -ResourceGroupName $rg -ErrorAction SilentlyContinue | select-object -ExpandProperty DNSSettings -WarningAction SilentlyContinue | select-object -ExpandProperty FQDN

Write-Host "                                 "
Write-Host "Public Network Interfaces for $rg" -NoNewline
Get-AzureRmPublicIpAddress -ResourceGroupName $rg | ft "Name","IpAddress" -Wrap
Get-AzureRmPublicIpAddress -ResourceGroupName $rg | select-object -ExpandProperty DNSSettings | FT FQDN -Wrap

Results-Rollup
}
#endregion

Function Check-VMExtension {
	param(
	$rg = $rg,
	$VMName = $VMName
	)
$vm =  Get-AzureRmVM -ResourceGroupName $rg -Name $VMName -InformationAction SilentlyContinue -WarningAction SilentlyContinue -ErrorAction Stop
$exttype = $vm.Extensions | Select-Object -ExpandProperty VirtualMachineExtensionType
$extname = $vm.Extensions | Select-Object -ExpandProperty Name
Write-Output "VM Extensions on $VMName $exttype" | Format-Table
}

#region Show Results
Function Results-Rollup {
Write-Host "                                                               "
$chkmatch = $rg -match $storerg
if($chkmatch -eq 'True')
	{
Write-Host "Storage Accounts for $rg" -NoNewLine
Get-AzurermStorageAccount -ResourceGroupName $rg -WarningAction SilentlyContinue | ft StorageAccountName,Location,ResourceGroupname -Wrap
	}
	else
	{
	Write-Host "Storage Accounts for $storerg" -NoNewLine
	Get-AzurermStorageAccount -ResourceGroupName $storerg -WarningAction SilentlyContinue | ft StorageAccountName,Location,ResourceGroupname -Wrap
	}

Write-Host "Managed Disks for $rg" -NoNewLine
Get-AzureRmDisk -ResourceGroupName $rg | ft Name,AccountType,DiskSizeGB,OsType -Wrap

if($AddAvailabilitySet -or $BatchAddAvset -eq 'True'){
Write-Host "Availability Sets for $rg"
Get-AzurermAvailabilitySet -ResourceGroupName $rg -WarningAction SilentlyContinue | ft Name,ResourceGroupName -Wrap
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

#region Get information
Function Get-azinfo  {
	param(
		[Parameter(Mandatory=$False,ValueFromPipelinebyPropertyName=$true)]
		[ValidateSet("network","vm","summary","extension")]
		[string]
		$infoset = $infoset,
		[Parameter(Mandatory=$False,ValueFromPipelinebyPropertyName=$true,Position=0)]
		[string]
		$rg = $rg
	)
validate-profile
}

#region Create Storage
Function Create-Storage {
		param(
		[string]$StorageName = $script:StorageNameVerified,
		[string]$rg = $rg,
		[string]$StorageType = $StorageType,
		[string]$Location = $Location
		)
		if(!$useexiststorage)
		{ Write-Host "Starting Storage Creation..."
		$script:StorageAccount = New-AzureRmStorageAccount -ResourceGroupName $storerg -Name $StorageName.ToLower() -Type $StorageType -Location $Location -ErrorAction Stop -WarningAction SilentlyContinue
		Write-Host "Completed Storage Creation" -ForegroundColor White
		$LogOut = "Storage Configuration completed: $StorageName"
		Log-Command -Description $LogOut -LogFile $LogOutFile
			}
		else {
			$script:StorageAccount = Get-AzureRmStorageAccount -ResourceGroupName $storerg -Name $StorageName.ToLower() -ErrorAction Stop -WarningAction SilentlyContinue
			Write-Host "Skipped storage creation, using $StorageName"}
		} # Creates Storage
#endregion

#region Configures Storage
Function Configure-ExistingStorage {
		param(
		[string]$StorageName = $script:StorageNameVerified,
		[string]$rg = $rg,
		[string]$StorageType = $StorageType,
		[string]$Location = $Location
		)
		if(!$useexiststorage)
		{ Write-Host "Existing Storage account in use .."
		$script:StorageAccount = Get-AzureRmStorageAccount -ResourceGroupName $storerg -Name $StorageName.ToLower() -Location $Location -ErrorAction Stop -WarningAction SilentlyContinue
		Write-Host "Completed Storage Configuration" -ForegroundColor White
		$LogOut = "Storage Configuration completed: $StorageName"
		Log-Command -Description $LogOut -LogFile $LogOutFile
			}
		else {Write-Host "Skipped storage creation, using $StorageName"}
		} # Creates Storage
#endregion

#region Create VM
Function Create-VM {
	param(
	[string]$VMName = $VMName,
	[ValidateSet("w2k12","w2k8","w2k16","nano","sql2016","sql2014","biztalk2013","tfs","biztalk2016","vs2015","dev15","incredibuild","msnav2016","red67","red72","suse","free","ubuntu14","ubuntu16","centos72","centos68","chef-server","check","pfsense","lamp","jenkins","nodejs","elastics","postgressql","splunk","horton-dp","serverr","horton-hdp","f5bigip","f5appfire","barrahourngfw","barrabyolngfw","barrahourspam","barrabyolspam","mysql","share2013","share2016","mongodb","nginxstack","hadoop","neos","tomcat","redis","gitlab","jruby","tableau","cloudera","datastax","O365-suite","ads-linuxdatascience","ads-datascience","cloud-conn","CoreOs","CoreContainers")]
	[string]
	$vmMarketImage = $vmMarketImage,
	[string]
	[ValidateSet("Single","Dual","NoPubDual","PvtDualStat","StatPvtNoPubSingle","PvtSingleStat","StatPvtNoPubDual","NoPubSingle")]
	$ConfigIps = $ConfigIps,
	[string]
	$StorageName = 	$StorageName,
	[string]
	$rg = $rg,
	[switch]
	$CreateNSG = $CreateNSG,
	[string]
	$NSGName = $NSGName,
	[string]
	$vnetrg = $vnetrg,
	[string]
	$StorageType = $StorageType,
	[string]
	$Location = $Location,
	[switch]
	$AddAvailabilitySet = $AddAvailabilitySet,
	[string]
	$VNETName = $VNetName,
	[string]
	$InterfaceName1 = $VMName + "_nic1",
	[string]
	$InterfaceName2 = $VMName + "_nic2",
	[int]
	$Subnet1 = $Subnet1,
	[int]
	$Subnet2 = $Subnet2,
	[ipaddress]
	$PvtIPNic1 = $PvtIPNic1,
	[ipaddress]
	$PvtIPNic2 = $PvtIPNic2,
	[string]
	$DNLabel = $DNLabel,
	[switch]
	$AddFQDN = $AddFQDN
	)
	switch -Wildcard ($vmMarketImage)
		{
		"*pfsense*" {
			Write-ConfigVM
			Create-Storage
			Create-AvailabilitySet
			Configure-Nics  #Sets network connection info
			MakeImagePlanInfo_Pfsense # Begins Image Creation
			Set-NicConfiguration # Adds Network Interfaces
			Configure-Image # Completes Image Creation
			Provision-Vm
}
		"*free*" {
			Write-ConfigVM
			Create-Storage
			Create-AvailabilitySet
			Configure-Nics  #Sets network connection info
			MakeImageNoPlanInfo_FreeBsd  # Begins Image Creation
			Set-NicConfiguration # Adds Network Interfaces
			Configure-Image # Completes Image Creation
			Provision-Vm
}
		"*red72*" {
			Write-ConfigVM
			Create-Storage
			Create-AvailabilitySet
			Configure-Nics  #Sets network connection info
			MakeImageNoPlanInfo_RedHat72  # Begins Image Creation
			Set-NicConfiguration # Adds Network Interfaces
			Configure-Image # Completes Image Creation
			Provision-Vm
}
		"*red67*" {
			Write-ConfigVM
			Create-Storage
			Create-AvailabilitySet
			Configure-Nics  #Sets network connection info
			MakeImageNoPlanInfo_RedHat67  # Begins Image Creation
			Set-NicConfiguration # Adds Network Interfaces
			Configure-Image # Completes Image Creation
			Provision-Vm
}
		"*w2k12*" {
			Write-ConfigVM

			Create-Storage

			Create-AvailabilitySet
			Configure-Nics  #Sets network connection info
			MakeImageNoPlanInfo_w2k12  # Begins Image Creation
			Set-NicConfiguration # Adds Network Interfaces
			Configure-Image # Completes Image Creation
			Provision-Vm
}
		"*MSNav2016*" {
			Write-ConfigVM
			Create-Storage
			Create-AvailabilitySet
			Configure-Nics  #Sets network connection info
			MakeImageNoPlanInfo_MSNAV2016  # Begins Image Creation
			Set-NicConfiguration # Adds Network Interfaces
			Configure-Image # Completes Image Creation
			Provision-Vm
}
		"*sql2016*" {
			Write-ConfigVM
			Create-Storage
			Create-AvailabilitySet
			Configure-Nics  #Sets network connection info
			MakeImageNoPlanInfo_sql2k16  # Begins Image Creation
			Set-NicConfiguration # Adds Network Interfaces
			Configure-Image # Completes Image Creation
			Provision-Vm
}
		"*sql2014*" {
			Write-ConfigVM
			Create-Storage
			Create-AvailabilitySet
			Configure-Nics  #Sets network connection info
			MakeImageNoPlanInfo_sql2k14  # Begins Image Creation
			Set-NicConfiguration # Adds Network Interfaces
			Configure-Image # Completes Image Creation
			Provision-Vm
}
		"*check*" {
			Write-ConfigVM
			Create-Storage
			Create-AvailabilitySet
			Configure-Nics  #Sets network connection info
			MakeImagePlanInfo_Checkpoint  # Begins Image Creation
			Set-NicConfiguration # Adds Network Interfaces
			Configure-Image # Completes Image Creation
			Provision-Vm
}
		"*cloudera*" {
			Write-ConfigVM
			Create-Storage
			Create-AvailabilitySet
			Configure-Nics  #Sets network connection info
			MakeImagePlanInfo_cloudera # Begins Image Creation
			Set-NicConfiguration # Adds Network Interfaces
			Configure-Image # Completes Image Creation
			Provision-Vm
}
		"*datastax*" {
			Write-ConfigVM
			Create-Storage
			Create-AvailabilitySet
			Configure-Nics  #Sets network connection info
			MakeImagePlanInfo_datastax # Begins Image Creation
			Set-NicConfiguration # Adds Network Interfaces
			Configure-Image # Completes Image Creation
			Provision-Vm
}
		"*centos68" {
			Write-ConfigVM
			Create-Storage
			Create-AvailabilitySet
			Configure-Nics  #Sets network connection info
			MakeImageNoPlanInfo_CentOs68  # Begins Image Creation
			Set-NicConfiguration # Adds Network Interfaces
			Configure-Image # Completes Image Creation
			Provision-Vm
}
		"*centos72" {
			Write-ConfigVM
			Create-Storage
			Create-AvailabilitySet
			Configure-Nics  #Sets network connection info
			MakeImageNoPlanInfo_CentOs72  # Begins Image Creation
			Set-NicConfiguration # Adds Network Interfaces
			Configure-Image # Completes Image Creation
			Provision-Vm
}
		"*CoreOS" {
			Write-ConfigVM
			Create-Storage
			Create-AvailabilitySet
			Configure-Nics  #Sets network connection info
			MakeImageNoPlanInfo_CoreOS_CoreOS  # Begins Image Creation
			Set-NicConfiguration # Adds Network Interfaces
			Configure-Image # Completes Image Creation
			Provision-Vm
}
		"*CoreContainers" {
			Write-ConfigVM
			Create-Storage
			Create-AvailabilitySet
			Configure-Nics  #Sets network connection info
			MakeImageNoPlanInfo_CoreOS_ContainerLinux  # Begins Image Creation
			Set-NicConfiguration # Adds Network Interfaces
			Configure-Image # Completes Image Creation
			Provision-Vm
}

		"*Suse*" {
			Write-ConfigVM
			Create-Storage
			Create-AvailabilitySet
			Configure-Nics  #Sets network connection info
			MakeImageNoPlanInfo_Suse  # Begins Image Creation
			Set-NicConfiguration # Adds Network Interfaces
			Configure-Image # Completes Image Creation
			Provision-Vm
}
		"*w2k8*" {
			Write-ConfigVM
			Create-Storage
			Create-AvailabilitySet
			Configure-Nics  #Sets network connection info
			MakeImageNoPlanInfo_w2k8  # Begins Image Creation
			Set-NicConfiguration # Adds Network Interfaces
			Configure-Image # Completes Image Creation
			Provision-Vm
}
		"*w2k16*" {
			Write-ConfigVM
			Create-Storage
			Create-AvailabilitySet
			Configure-Nics  #Sets network connection info
			MakeImageNoPlanInfo_w2k16  # Begins Image Creation
			Set-NicConfiguration # Adds Network Interfaces
			Configure-Image # Completes Image Creation
			Provision-Vm
}
		"*nano" {
			Write-ConfigVM
			Create-Storage
			Create-AvailabilitySet
			Configure-Nics  #Sets network connection info
			MakeImageNoPlanInfo_w2k16Nano  # Begins Image Creation
			Set-NicConfiguration # Adds Network Interfaces
			Configure-Image # Completes Image Creation
			Provision-Vm
}
		"*chef-server*" {
			Write-ConfigVM
			Create-Storage
			Create-AvailabilitySet
			Configure-Nics  #Sets network connection info
			MakeImagePlanInfo_Chef  # Begins Image Creation
			Set-NicConfiguration # Adds Network Interfaces
			Configure-Image # Completes Image Creation
			Provision-Vm
}
		"*ads-datascience*" {
			Write-ConfigVM
			Create-Storage
			Create-AvailabilitySet
			Configure-Nics  #Sets network connection info
			MakeImagenoPlanInfo_ads_stddatascience # Begins Image Creation
			Set-NicConfiguration # Adds Network Interfaces
			Configure-Image # Completes Image Creation
			Provision-Vm
}
		"*ads-linuxdatascience*" {
			Write-ConfigVM
			Create-Storage
			Create-AvailabilitySet
			Configure-Nics  #Sets network connection info
			MakeImagenoPlanInfo_ads_datascience # Begins Image Creation
			Set-NicConfiguration # Adds Network Interfaces
			Configure-Image # Completes Image Creation
			Provision-Vm
}
		"*tableau*" {
			Write-ConfigVM
			Create-Storage
			Create-AvailabilitySet
			Configure-Nics  #Sets network connection info
			MakeImagePlanInfo_tableau # Begins Image Creation
			Set-NicConfiguration # Adds Network Interfaces
			Configure-Image # Completes Image Creation
			Provision-Vm
}
		"*RevoAn-Lin*" {
			Write-ConfigVM
			Create-Storage
			Create-AvailabilitySet
			Configure-Nics  #Sets network connection info
			MakeImagePlanInfo_RevAnalytics_cent # Begins Image Creation
			Set-NicConfiguration # Adds Network Interfaces
			Configure-Image # Completes Image Creation
			Provision-Vm
}
		"*RevoAn-Win*" {
			Write-ConfigVM
			Create-Storage
			Create-AvailabilitySet
			Configure-Nics  #Sets network connection info
			MakeImagePlanInfo_RevAnalytics_win # Begins Image Creation
			Set-NicConfiguration # Adds Network Interfaces
			Configure-Image # Completes Image Creation
			Provision-Vm
}
		"*lamp*" {
			Write-ConfigVM
			Create-Storage
			Create-AvailabilitySet
			Configure-Nics  #Sets network connection info
			MakeImagePlanInfo_Bitnami_Lamp # Begins Image Creation
			Set-NicConfiguration # Adds Network Interfaces
			Configure-Image # Completes Image Creation
			Provision-Vm
}
		"*mongodb*" {
			Write-ConfigVM
			Create-Storage
			Create-AvailabilitySet
			Configure-Nics  #Sets network connection info
			MakeImagePlanInfo_Bitnami_mongodb # Begins Image Creation
			Set-NicConfiguration # Adds Network Interfaces
			Configure-Image # Completes Image Creation
			Provision-Vm
}
		"*mysql*" {
			Write-ConfigVM
			Create-Storage
			Create-AvailabilitySet
			Configure-Nics  #Sets network connection info
			MakeImagePlanInfo_Bitnami_mysql # Begins Image Creation
			Set-NicConfiguration # Adds Network Interfaces
			Configure-Image # Completes Image Creation
			Provision-Vm
}
		"*elastics*" {
			Write-ConfigVM
			Create-Storage
			Create-AvailabilitySet
			Configure-Nics  #Sets network connection info
			MakeImagePlanInfo_Bitnami_elastic # Begins Image Creation
			Set-NicConfiguration # Adds Network Interfaces
			Configure-Image # Completes Image Creation
			Provision-Vm
}
		"*nodejs*" {
			Write-ConfigVM
			Create-Storage
			Create-AvailabilitySet
			Configure-Nics  #Sets network connection info
			MakeImagePlanInfo_Bitnami_nodejs # Begins Image Creation
			Set-NicConfiguration # Adds Network Interfaces
			Configure-Image # Completes Image Creation
			Provision-Vm
}
		"*nginxstack*" {
			Write-ConfigVM
			Create-Storage
			Create-AvailabilitySet
			Configure-Nics  #Sets network connection info
			MakeImagePlanInfo_Bitnami_nginxstack # Begins Image Creation
			Set-NicConfiguration # Adds Network Interfaces
			Configure-Image # Completes Image Creation
			Provision-Vm
}
		"*postgressql*" {
			Write-ConfigVM
			Create-Storage
			Create-AvailabilitySet
			Configure-Nics  #Sets network connection info
			MakeImagePlanInfo_Bitnami_postgresql # Begins Image Creation
			Set-NicConfiguration # Adds Network Interfaces
			Configure-Image # Completes Image Creation
			Provision-Vm
}
		"*incredibuild*" {
			Write-ConfigVM
			Create-Storage
			Create-AvailabilitySet
			Configure-Nics  #Sets network connection info
			MakeImagePlanInfo_incredibuild # Begins Image Creation
			Set-NicConfiguration # Adds Network Interfaces
			Configure-Image # Completes Image Creation
			Provision-Vm
}
		"*horton-dp*" {
			Write-ConfigVM
			Create-Storage
			Create-AvailabilitySet
			Configure-Nics  #Sets network connection info
			MakeImagePlanInfo_hortonwowk_dp  # Begins Image Creation
			Set-NicConfiguration # Adds Network Interfaces
			Configure-Image # Completes Image Creation
			Provision-Vm
}
		"*horton-hdp*" {
			Write-ConfigVM
			Create-Storage
			Create-AvailabilitySet
			Configure-Nics  #Sets network connection info
			MakeImagePlanInfo_hortonwowk_hdp # Begins Image Creation
			Set-NicConfiguration # Adds Network Interfaces
			Configure-Image # Completes Image Creation
			Provision-Vm
}
		"*puppet*" {
			Write-ConfigVM
			Create-Storage
			Create-AvailabilitySet
			Configure-Nics  #Sets network connection info
			MakeImagePlanInfo_puppet_puppetent # Begins Image Creation
			Set-NicConfiguration # Adds Network Interfaces
			Configure-Image # Completes Image Creation
			Provision-Vm
}

		"*share2013*" {
			Write-ConfigVM
			Create-Storage
			Create-AvailabilitySet
			Configure-Nics  #Sets network connection info
			MakeImageNoPlanInfo_SharePoint2k13 # Begins Image Creation
			Set-NicConfiguration # Adds Network Interfaces
			Configure-Image # Completes Image Creation
			Provision-Vm
}
		"*tfs*" {
			Write-ConfigVM
			Create-Storage
			Create-AvailabilitySet
			Configure-Nics  #Sets network connection info
			MakeImageNoPlanInfo_TeamFoundationServer # Begins Image Creation
			Set-NicConfiguration # Adds Network Interfaces
			Configure-Image # Completes Image Creation
			Provision-Vm
}
		"*VS2015*" {
			Write-ConfigVM
			Create-Storage
			Create-AvailabilitySet
			Configure-Nics  #Sets network connection info
			MakeImagenoPlanInfo_w2012r2vs2015 # Begins Image Creation
			Set-NicConfiguration # Adds Network Interfaces
			Configure-Image # Completes Image Creation
			Provision-Vm
}
		"*DEV15*" {
			Write-ConfigVM
			Create-Storage
			Create-AvailabilitySet
			Configure-Nics  #Sets network connection info
			MakeImagenoPlanInfo_w2012r2dev15 # Begins Image Creation
			Set-NicConfiguration # Adds Network Interfaces
			Configure-Image # Completes Image Creation
			Provision-Vm
}
		"*biztalk2013*" {
			Write-ConfigVM
			Create-Storage
			Create-AvailabilitySet
			Configure-Nics  #Sets network connection info
			MakeImageNoPlanInfo_Biztalk-Enterprise # Begins Image Creation
			Set-NicConfiguration # Adds Network Interfaces
			Configure-Image # Completes Image Creation
			Provision-Vm
}
		"*biztalk2016*" {
			Write-ConfigVM
			Create-Storage
			Create-AvailabilitySet
			Configure-Nics  #Sets network connection info
			MakeImageNoPlanInfo_Biztalk2016-PreRelease # Begins Image Creation
			Set-NicConfiguration # Adds Network Interfaces
			Configure-Image # Completes Image Creation
			Provision-Vm
}
		"*share2016*" {
			Write-ConfigVM
			Create-Storage
			Create-AvailabilitySet
			Configure-Nics  #Sets network connection info
			MakeImageNoPlanInfo_SharePoint2k16 # Begins Image Creation
			Set-NicConfiguration # Adds Network Interfaces
			Configure-Image # Completes Image Creation
			Provision-Vm
}
		"*serverr*" {
			Write-ConfigVM
			Create-Storage
			Create-AvailabilitySet
			Configure-Nics  #Sets network connection info
			MakeImagePlanInfo_Microsoft_Serverr # Begins Image Creation
			Set-NicConfiguration # Adds Network Interfaces
			Configure-Image # Completes Image Creation
			Provision-Vm
}
		"*ubuntu14*" {
			Write-ConfigVM
			Create-Storage
			Create-AvailabilitySet
			Configure-Nics  #Sets network connection info
			MakeImageNoPlanInfo_Ubuntu14 # Begins Image Creation
			Set-NicConfiguration # Adds Network Interfaces
			Configure-Image # Completes Image Creation
			Provision-Vm
}
		"*ubuntu16*" {
			Write-ConfigVM
			Create-Storage
			Create-AvailabilitySet
			Configure-Nics  #Sets network connection info
			MakeImageNoPlanInfo_Ubuntu16 # Begins Image Creation
			Set-NicConfiguration # Adds Network Interfaces
			Configure-Image # Completes Image Creation
			Provision-Vm
}
		"*nessus*" {
			Write-ConfigVM
			Create-Storage
			Create-AvailabilitySet
			Configure-Nics  #Sets network connection info
			makeimage_withinfo_te-te-serv-nes-byol-azure0 # Begins Image Creation
			Set-NicConfiguration # Adds Network Interfaces
			Configure-Image # Completes Image Creation
			Provision-Vm
}
		"*netscaler*" {
			Write-ConfigVM
			Create-Storage
			Create-AvailabilitySet
			Configure-Nics  #Sets network connection info
			makeimage_withinfo_ci-ne-netscalervpx # Begins Image Creation
			Set-NicConfiguration # Adds Network Interfaces
			Configure-Image # Completes Image Creation
			Provision-Vm
}
		"*debian*" {
			Write-ConfigVM
			Create-Storage
			Create-AvailabilitySet
			Configure-Nics  #Sets network connection info
			makeimage_withinfo_cr-De-8 # Begins Image Creation
			Set-NicConfiguration # Adds Network Interfaces
			Configure-Image # Completes Image Creation
			Provision-Vm
}
		"*f5bigip*" {
			Write-ConfigVM
			Create-Storage
			Create-AvailabilitySet
			Configure-Nics  #Sets network connection info
			MakeImagePlanInfo_f5_bigip_good_byol # Begins Image Creation
			Set-NicConfiguration # Adds Network Interfaces
			Configure-Image # Completes Image Creation
			Provision-Vm
}
		"*f5appfire*" {
			Write-ConfigVM
			Create-Storage
			Create-AvailabilitySet
			Configure-Nics  #Sets network connection info
			MakeImagePlanInfo_f5_webappfire_byol # Begins Image Creation
			Set-NicConfiguration # Adds Network Interfaces
			Configure-Image # Completes Image Creation
			Provision-Vm
}
		"*barrahourngfw*" {
			Write-ConfigVM
			Create-Storage
			Create-AvailabilitySet
			Configure-Nics  #Sets network connection info
			MakeImagePlanInfo_Barracuda_ng_firewall_hourly # Begins Image Creation
			Set-NicConfiguration # Adds Network Interfaces
			Configure-Image # Completes Image Creation
			Provision-Vm
}
		"*barrabyolngfw*" {
			Write-ConfigVM
			Create-Storage
			Create-AvailabilitySet
			Configure-Nics  #Sets network connection info
			MakeImagePlanInfo_Barracuda_ng_firewall_byol # Begins Image Creation
			Set-NicConfiguration # Adds Network Interfaces
			Configure-Image # Completes Image Creation
			Provision-Vm
}
		"*barrahourspam*" {
			Write-ConfigVM
			Create-Storage
			Create-AvailabilitySet
			Configure-Nics  #Sets network connection info
			MakeImagePlanInfo_Barracuda_spam_firewall_hourly # Begins Image Creation
			Set-NicConfiguration # Adds Network Interfaces
			Configure-Image # Completes Image Creation
			Provision-Vm
}
		"*barrabyolspam*" {
			Write-ConfigVM
			Create-Storage
			Create-AvailabilitySet
			Configure-Nics  #Sets network connection info
			MakeImagePlanInfo_Barracuda_spam_firewall_byol # Begins Image Creation
			Set-NicConfiguration # Adds Network Interfaces
			Configure-Image # Completes Image Creation
			Provision-Vm
}
		"*O365-Suite*" {
			Write-ConfigVM
			Create-Storage
			Create-AvailabilitySet
			Configure-Nics  #Sets network connection info
			MakeImagePlanInfo_metavistech # Begins Image Creation
			Set-NicConfiguration # Adds Network Interfaces
			Configure-Image # Completes Image Creation
			Provision-Vm
}
		"*hadoop*" {
			Write-ConfigVM
			Create-Storage
			Create-AvailabilitySet
			Configure-Nics  #Sets network connection info
			MakeImagePlanInfo_Bitnami_hadoop # Begins Image Creation
			Set-NicConfiguration # Adds Network Interfaces
			Configure-Image # Completes Image Creation
			Provision-Vm
}
		"*tomcat*" {
			Write-ConfigVM
			Create-Storage
			Create-AvailabilitySet
			Configure-Nics  #Sets network connection info
			MakeImagePlanInfo_Bitnami_tomcat # Begins Image Creation
			Set-NicConfiguration # Adds Network Interfaces
			Configure-Image # Completes Image Creation
			Provision-Vm
}
		"*splunk*" {
			Write-ConfigVM
			Create-Storage
			Create-AvailabilitySet
			Configure-Nics  #Sets network connection info
			makeimage_withinfo_sp-sp-splunk-on-ubuntu-14-04-lts # Begins Image Creation
			Set-NicConfiguration # Adds Network Interfaces
			Configure-Image # Completes Image Creation
			Provision-Vm
}
		"*redis*" {
			Write-ConfigVM
			Create-Storage
			Create-AvailabilitySet
			Configure-Nics  #Sets network connection info
			MakeImagePlanInfo_Bitnami_redis # Begins Image Creation
			Set-NicConfiguration # Adds Network Interfaces
			Configure-Image # Completes Image Creation
			Provision-Vm
}
		"*neos*" {
			Write-ConfigVM
			Create-Storage
			Create-AvailabilitySet
			Configure-Nics  #Sets network connection info
			MakeImagePlanInfo_Bitnami_neos # Begins Image Creation
			Set-NicConfiguration # Adds Network Interfaces
			Configure-Image # Completes Image Creation
			Provision-Vm
}
		"*cisco750*" {
			Write-ConfigVM
			Create-Storage
			Create-AvailabilitySet
			Configure-Nics  #Sets network connection info
			makeimage_withinfo_ci-vw-vwaas-azure-750 # Begins Image Creation
			Set-NicConfiguration # Adds Network Interfaces
			Configure-Image # Completes Image Creation
			Provision-Vm
}
		"*jenk-opcenter" {
			Write-ConfigVM
			Create-Storage
			Create-AvailabilitySet
			Configure-Nics  #Sets network connection info
			makeimage_withinfo_cl-je-jenkins-operations-center # Begins Image Creation
			Set-NicConfiguration # Adds Network Interfaces
			Configure-Image # Completes Image Creation
			Provision-Vm
}
		"*jruby*" {
			Write-ConfigVM
			Create-Storage
			Create-AvailabilitySet
			Configure-Nics  #Sets network connection info
			MakeImagePlanInfo_Bitnami_jrubystack # Begins Image Creation
			Set-NicConfiguration # Adds Network Interfaces
			Configure-Image # Completes Image Creation
			Provision-Vm
}
		"*tig-windows*" {
			Write-ConfigVM
			Create-Storage
			Create-AvailabilitySet
			Configure-Nics  #Sets network connection info
			makeimage_withinfo_ti-ba-windowsbackupasaservice # Begins Image Creation
			Set-NicConfiguration # Adds Network Interfaces
			Configure-Image # Completes Image Creation
			Provision-Vm
}
		"*tig-linux*" {
			Write-ConfigVM
			Create-Storage
			Create-AvailabilitySet
			Configure-Nics  #Sets network connection info
			makeimage_withinfo_ti-ba-linuxbackupasaservice # Begins Image Creation
			Set-NicConfiguration # Adds Network Interfaces
			Configure-Image # Completes Image Creation
			Provision-Vm
}
		"*chef-compliance*" {
			Write-ConfigVM
			Create-Storage
			Create-AvailabilitySet
			Configure-Nics  #Sets network connection info
			makeimage_withinfo_ch-ch-azure_marketplace_100 # Begins Image Creation
			Set-NicConfiguration # Adds Network Interfaces
			Configure-Image # Completes Image Creation
			Provision-Vm
}
		"*jenkins*" {
			Write-ConfigVM
			Create-Storage
			Create-AvailabilitySet
			Configure-Nics  #Sets network connection info
			MakeImagePlanInfo_Bitnami_jenkins # Begins Image Creation
			Set-NicConfiguration # Adds Network Interfaces
			Configure-Image # Completes Image Creation
			Provision-Vm
}
		default{"An unsupported image was referenced"}
	}
}
#endregion

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
	{ Write-Host "No Compatble OS Found, please verify the extension is compatible with $VMName"
		break
	}
}
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
	Set-AzureRmVMDscExtension -ResourceGroupName $rg -VMName $VMName -ArchiveBlobName $ArchiveBlobName -ArchiveStorageAccountName $storageAccountName -ConfigurationName $ConfigurationName -Version 2.19 -Force -Location $Location -Confirm:$false -InformationAction SilentlyContinue -WarningAction SilentlyContinue -ErrorAction Stop
	$LogOut = "Added VM DSC to Storage Account $storageAccountName from file $ConfigurationPath"
	Log-Command -Description $LogOut -LogFile $LogOutFile
}

function AddVM-Vault {
param(
$vaultname = $vaultname,
$VMName = $VMName,
$containertype = "AzureVM",
$rg = $rg
)
Get-AzureRmRecoveryServicesVault -Name $vaultname | Set-AzureRmRecoveryServicesVaultContext
$script:pol = Get-AzureRmRecoveryServicesBackupProtectionPolicy -Name $policyname
Enable-AzureRmRecoveryServicesBackupProtection -Policy $script:pol -Name $VMName -ResourceGroupName $rg
$namedContainer = Get-AzureRmRecoveryServicesBackupContainer -ContainerType $containertype -Status "Registered" -FriendlyName $VMName
$item = Get-AzureRmRecoveryServicesBackupItem -Container $namedContainer -WorkloadType "AzureVM"
$job = Backup-AzureRmRecoveryServicesBackupItem -Item $item
$job

$LogOut = "Completed adding $VMName to $vaultname"
Log-Command -Description $LogOut -LogFile $LogOutFile
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

#region Upload Custom Script
Function Upload-CustomScript {
	param(
	$StorageName = $script:StorageNameVerified,
	$containerName = $containerName,
	$rg = $rg,
	$localFolder = $localFolder,
	$remscriptpath = -join $customscriptsdir + "\"
	)

		$Keys = Get-AzureRmStorageAccountKey -ResourceGroupName $rg -Name $StorageName;
		$StorageContext = New-AzureStorageContext -StorageAccountName $StorageName -StorageAccountKey $Keys[0].Value;
		New-AzureStorageContainer -Context $StorageContext -Name $containerName -WarningAction SilentlyContinue -ErrorAction SilentlyContinue;
		$storageAccountKey = Get-AzureRmStorageAccountKey -ResourceGroupName $rg -Name $StorageName;
		$blobContext = New-AzureStorageContext -StorageAccountName $StorageName -StorageAccountKey $Keys[0].Value;
		$files = Get-ChildItem $remscriptpath
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

Function Upload-CustomScriptDir {
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

Function Check-VaultExists {
$vaultexists = Get-AzureRmRecoveryServicesVault -Name $vaultname -ResourceGroupName $vaultrg -ErrorAction Stop -WarningAction SilentlyContinue -InformationAction SilentlyContinue
if(!$vaultexists)
	{
	Write-Host "Specified vault $vaultname does not exist!" -ForegroundColor Red
		break
	}
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

				$mofurl = -join "https://" + $StorageName + ".blob.core.windows.net/" + $dsccontainername + "/" + $LinDSCConfig
				$Keys = Get-AzureRmStorageAccountKey -ResourceGroupName $rg -Name $StorageName
				$Key1 = $Keys[0].Value
				$PublicSetting = "{`"FileUri`":`"$mofurl`" ,`"Mode`": `"Push`"}"
				$PrivateSetting = "{`"storageAccountName`":`"$StorageName`",`"storageAccountKey`":`"$Key1`"}"

				Write-Host "Applying Configuration at $mofurl"

				Set-AzureRmVMExtension -VMName $VMName -ResourceGroupName $rg -Location $Location -Name "DSCForLinux" -ExtensionType "DSCForLinux" -Publisher "Microsoft.OSTCExtensions" -typeHandlerVersion "2.3" -InformationAction SilentlyContinue -SettingString $PublicSetting -ProtectedSettingString $PrivateSetting -WarningAction SilentlyContinue -ErrorAction Stop -Confirm:$false | Out-Null

					$LogOut = "Applied $LinDSCConfig to $VMName from file $mofurl"
					Log-Command -Description $LogOut -LogFile $LogOutFile
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

function Install-Ext_File {
		param(
		[Parameter(Mandatory=$False,ValueFromPipelinebyPropertyName=$true)]
		[string]$extname = $extname,
		[Parameter(Mandatory=$False,ValueFromPipelinebyPropertyName=$true)]
		[string]$NSGName = $NSGName,
		[Parameter(Mandatory=$False,ValueFromPipelinebyPropertyName=$true)]
		[string]$Location = $Location,
		[Parameter(Mandatory=$False,ValueFromPipelinebyPropertyName=$true)]
		[string]$rg = $rg,
		[Parameter(Mandatory=$False,ValueFromPipelinebyPropertyName=$true)]
		[string]$StorageName = $script:StorageNameVerified,
		[Parameter(Mandatory=$False,ValueFromPipelinebyPropertyName=$true)]
		[string]$VMName = $VMName,
		[Parameter(Mandatory=$False,ValueFromPipelinebyPropertyName=$true)]
		[string]$containerNameScripts = 'scripts',
		[Parameter(Mandatory=$False,ValueFromPipelinebyPropertyName=$true)]
		[string]$DomName =  'aip.local',
		[Parameter(Mandatory=$False,ValueFromPipelinebyPropertyName=$true)]
		[string]$customextname = $customextname,
		[Parameter(Mandatory=$False,ValueFromPipelinebyPropertyName=$true)]
		[string]$localfolderscripts = $customscriptsdir
	)

	 .\AZRM-ExtDeploy.ps1 -extname $extname -VMName $VMName -rg $rg -StorageName $StorageName -CustomScriptUpload $CustomScriptUpload -DSCConfig $DSCConfig -Azautoacct $Azautoacct -localsoftwarefolder $localsoftwarefolder -scriptname $scriptname -customextname $customextname -containername $containername -scriptfolder $scriptfolder -localfolder $localfolder -sharedirectory $sharedirectory -sharename $sharename
}

#region Install Extension
Function Install-Ext {
	param(
		[Parameter(Mandatory=$False,ValueFromPipelinebyPropertyName=$true)]
		[string]$extname = $extname,
		[Parameter(Mandatory=$False,ValueFromPipelinebyPropertyName=$true)]
		[string]$Location = $Location,
		[Parameter(Mandatory=$False,ValueFromPipelinebyPropertyName=$true)]
		[string]$rg = $rg,
		[Parameter(Mandatory=$False,ValueFromPipelinebyPropertyName=$true)]
		[string]$StorageName = $script:StorageNameVerified,
		[Parameter(Mandatory=$False,ValueFromPipelinebyPropertyName=$true)]
		[string]$VMName = $VMName,
		[Parameter(Mandatory=$False,ValueFromPipelinebyPropertyName=$true)]
		[string]$containerNameScripts = 'scripts',
		[Parameter(Mandatory=$False,ValueFromPipelinebyPropertyName=$true)]
		[string]$DomName =  'aip.local',
		[Parameter(Mandatory=$False,ValueFromPipelinebyPropertyName=$true)]
		[string]$customextname = $customextname,
		[Parameter(Mandatory=$False,ValueFromPipelinebyPropertyName=$true)]
		[string]$localfolderscripts = $customscriptsdir,
		[Parameter(Mandatory=$False,ValueFromPipelinebyPropertyName=$true)]
		[string]$scriptname = $scriptname,
		[Parameter(Mandatory=$False,ValueFromPipelinebyPropertyName=$true)]
		[string]$scriptname2 = $scriptname2,
		[Parameter(Mandatory=$False,ValueFromPipelinebyPropertyName=$true)]
		[string]$ConfigurationName = $ConfigurationName,
		[Parameter(Mandatory=$False,ValueFromPipelinebyPropertyName=$true)]
		[string]$validationpem = $chefvalidationpem,
		[Parameter(Mandatory=$False,ValueFromPipelinebyPropertyName=$true)]
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
}

		"msav" {
				Write-Host "MSAV Agent VM Image Preparation in Process"
				Set-AzureRmVMExtension  -ResourceGroupName $rg -VMName $VMName -Name "MSAVExtension" -ExtensionType "IaaSAntimalware" -Publisher "Microsoft.Azure.Security" -typeHandlerVersion 1.4 -Location $Location  -ErrorAction Stop | Out-Null
				$LogOut = "MSAV Agent Deployed to $VMName"
				Log-Command -Description $LogOut -LogFile $LogOutFile
						Write-Results
}
		"customscript" {
				Verify-ScriptExists
				Verify-ExtWindows
				Write-Host "Updating: $VMName in the Resource Group: $rg with a custom script: $scriptname in Storage Account: $StorageName" -ForegroundColor Cyan
				if($CustomScriptUpload -eq 'True')
				{
				Test-Upload -localFolder $localfolderscripts
				Upload-CustomScript -StorageName $StorageName -rg $rg -containerName $containerNameScripts -localFolder $localfolderscripts
				}
				$scriptend = "https://$StorageName.blob.core.windows.net/$containerNameScripts/$scriptname"
				if(!$scriptend)
					{
					Upload-CustomScript -StorageName $StorageName -rg $rg -containerName $containerNameScripts -localFolder $localfolderscripts
					}
				Set-AzureRmVMCustomScriptExtension -Name $customextname -ContainerName $containerName -ResourceGroupName $rg -VMName $VMName -StorageAccountName $StorageName -FileName $scriptname -Location $Location -TypeHandlerVersion "1.8" -WarningAction SilentlyContinue  -ErrorAction Stop | Out-Null
				Get-AzureRmVMCustomScriptExtension -ResourceGroupName $rg -VMName $VMName -Name $customextname -Status | Out-Null
				$LogOut = "Custom $scriptname Deployed to $VMName"
				Log-Command -Description $LogOut -LogFile $LogOutFile
						Write-Results
}
		"linuxcustomscript" {
				Verify-ExtLinux
				Verify-ScriptExists
				$Keys = Get-AzureRmStorageAccountKey -ResourceGroupName $rg -Name $StorageName
				$Key1 = $Keys[0].Value

			$PublicSetting = "{`"fileUris`":[`"https://$StorageName.blob.core.windows.net/$containerNameScripts/$scriptname`"] ,`"commandToExecute`": `"sh $scriptname`"}"
				$PrivateSetting = "{`"storageAccountName`":`"$StorageName`",`"storageAccountKey`":`"$Key1`" }"

				Write-Host "Updating $VMName with $scriptname in Storage Account $StorageName" -ForegroundColor Cyan
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
}
		"domjoin" {
				erify-ExtWindows
				Write-Host "Domain Join active"
				Set-AzureRmVMADDomainExtension -DomainName $DomName -ResourceGroupName $rg -VMName $VMName -Location $Location -Name 'DomJoin' -WarningAction SilentlyContinue -Restart | Out-Null
				Get-AzureRmVMADDomainExtension -ResourceGroupName $rg  -VMName $VMName -Name 'DomJoin' | Out-Null
				 $LogOut = "Added VM Domain Join Extension for domain: $DomName "
				Log-Command -Description $LogOut -LogFile $LogOutFile
}
		"linuxospatch" {
				Verify-ExtLinux
				Check-linuxos-NullValues
				linuxos-Patching
						Write-Results
		}
		"addvmbackupvault" {
						Check-VaultExists
						AddVM-Vault
						Write-Results
		}
		"linuxbackup" {
				Verify-ExtLinux
				$PublicSetting = ConvertTo-Json -InputObject @{
				"commandStartTimeUTCTicks" = "635809046306353843";
				"commandToExecute" = "snapshot";
				}
				Write-Host "Adding Linux VMBackup to $VMName in the resource group $rg"
				Set-AzureRmVMExtension -VMName $VMName -ResourceGroupName $rg -Location $Location -Name "VMBackupForLinuxExtension" -ExtensionType "VMBackupForLinuxExtension" -Publisher "Microsoft.OSTCExtensions" -typeHandlerVersion "0.1" -InformationAction SilentlyContinue -Verbose -SettingString $PublicSetting
				 $LogOut = "Added VM Backup Extension"
				Log-Command -Description $LogOut -LogFile $LogOutFile
				Write-Results
		}

		"linuxchefagent" {
				Test-ChefFiles
				Write-Host "Adding Linux Chef Agent"
				$validationpem = $validationpem
				$clientrb = $clientrb
				Set-AzureRmVMChefExtension -ResourceGroupName $rg -VMName $VMName -TypeHandlerVersion "1210.12" -ValidationPem $validationpem -ClientRb $clientrb -Linux
				$LogOut = "Chef Agent Deployed to $VMName"
				Log-Command -Description $LogOut -LogFile $LogOutFile
						Write-Results
}
		"windowschefagent" {
				Test-ChefFiles
				Write-Host "Adding Windows Chef Agent"
				$validationpem = $validationpem
				$clientrb = $clientrb
				Set-AzureRmVMChefExtension -ResourceGroupName $rg -VMName $VMName -TypeHandlerVersion "1210.12" -ValidationPem $validationpem -ClientRb $clientrb -Windows
				$LogOut = "Chef Agent Deployed to $VMName"
				Log-Command -Description $LogOut -LogFile $LogOutFile
						Write-Results
}
		"opsinsightLinux" {
				Write-Host "Adding Linux Insight Agent"
				$PublicSetting = "{`"workspaceId`":`"$omswrkspaceid`",`"stopOnMultipleConnections`":`"$false`"}"
				$PrivateSetting = "{`"workspaceKey`":`"$omswrkspacekey`"}"

				Set-AzureRmVMExtension -VMName $VMName -ResourceGroupName $rg -Location $Location -Name "OperationalInsights" -ExtensionType "OmsAgentForLinux" -Publisher "Microsoft.EnterpriseCloud.Monitoring" -typeHandlerVersion "1.0" -InformationAction SilentlyContinue  -ErrorAction Stop -SettingString $PublicSetting -ProtectedSettingString $PrivateSetting | Out-Null
				Get-AzureRmVMExtension -ResourceGroupName $rg -VMName $VMName -Name "OperationalInsights" | Out-Null
				$LogOut = "Ops Insight Deployed to $VMName"
				Log-Command -Description $LogOut -LogFile $LogOutFile
						Write-Results
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
				Set-AzureRmVMExtension -VMName $VMName -ResourceGroupName $rg -Location $Location -Name "OperationalInsights" -ExtensionType "MicrosoftMonitoringAgent" -Publisher "Microsoft.EnterpriseCloud.Monitoring" -typeHandlerVersion "1.0" -InformationAction SilentlyContinue  -ErrorAction Stop  -Verbose  -SettingString $PublicSetting -ProtectedSettingString $PrivateSetting | Out-Null
				Get-AzureRmVMExtension -ResourceGroupName $rg -VMName $VMName -Name "OperationalInsights" | Out-Null
				$LogOut = "Widows Insight Deployed to $VMName"
				Log-Command -Description $LogOut -LogFile $LogOutFile
						Write-Results
}
		"ESET" {
				Verify-ExtWindows
				Write-Host "Setting File Security"
				Set-AzureRmVMExtension -VMName $VMName -ResourceGroupName $rg -Location $Location -Name "ESET" -ExtensionType "FileSecurity" -Publisher "ESET" -typeHandlerVersion "6.0" -InformationAction SilentlyContinue -Verbose  -ErrorAction Stop | Out-Null
				$LogOut = "ESET Deployed to $VMName"
				Log-Command -Description $LogOut -LogFile $LogOutFile
						Write-Results
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
		"RegisterAzDSC" {
				Write-Host "Registering with Azure Automation DSC"
				$ActionAfterReboot = 'ContinueConfiguration'
				$configmode = 'ApplyAndAutocorrect'
				$AutoAcctName = $Azautoacct
				$NodeName = $VMName
				$azautomrg = $azautomrg
				$ConfigurationName = $ConfigurationName
				Register-AzureRmAutomationDscNode -AutomationAccountName $AutoAcctName -AzureVMName $VMName -ActionAfterReboot $ActionAfterReboot -ConfigurationMode $configmode -RebootNodeIfNeeded $True -ResourceGroupName $azautomrg -NodeConfigurationName $ConfigurationName -AzureVMLocation $Location -AzureVMResourceGroup $rg -Verbose | Out-Null
				 $LogOut = "Registered with Azure Automation DSC"
				Log-Command -Description $LogOut -LogFile $LogOutFile
				Write-Results
}
		"WinPuppet" {
				Verify-ExtWindows
				Write-Host "Deploying Puppet Extension"
				Set-AzureRmVMExtension -VMName $VMName -ResourceGroupName $rg -Location $Location -Name "PuppetEnterpriseAgent" -ExtensionType "PuppetEnterpriseAgent" -Publisher "PuppetLabs" -typeHandlerVersion "3.2" -InformationAction SilentlyContinue -Verbose | Out-Null
				Get-AzureRmVMExtension -ResourceGroupName $rg -VMName $VMName -Name "PuppetEnterpriseAgent"
				 $LogOut = "Added Puppet Agent Extension"
				Log-Command -Description $LogOut -LogFile $LogOutFile
				Write-Results
}
		default{"An unsupported Extension command was used"}
	}
	exit
}
#endregion

#region Precheck Orphans
Function Check-Orphans {
	param(
	[Parameter(Mandatory=$False,ValueFromPipelinebyPropertyName=$true)]
	[string]
	$InterfaceName1 = $VMName + "_nic1",
	[Parameter(Mandatory=$False,ValueFromPipelinebyPropertyName=$true)]
	[string]
	$InterfaceName2 = $VMName + "_nic2",
	[Parameter(Mandatory=$False,ValueFromPipelinebyPropertyName=$true)]
	[string]
	$Location = $Location,
	[Parameter(Mandatory=$False,ValueFromPipelinebyPropertyName=$true)]
	[string]
	$rg = $rg,
	[Parameter(Mandatory=$False,ValueFromPipelinebyPropertyName=$true)]
	[string]
	$VMName = $VMName
	)
	$extvm = Get-AzureRmVm -Name $VMName -ResourceGroupName $rg -ErrorAction SilentlyContinue -WarningAction SilentlyContinue
	$nic1 = Get-AzureRmNetworkInterface -Name $InterfaceName1 -ResourceGroupName $rg -ErrorAction SilentlyContinue -WarningAction SilentlyContinue
	$nic2 = Get-AzureRmNetworkInterface -Name $InterfaceName2 -ResourceGroupName $rg -ErrorAction SilentlyContinue -WarningAction SilentlyContinue
	$pubip =  Get-AzureRmPublicIpAddress -Name $InterfaceName1 -ResourceGroupName $rg -ErrorAction SilentlyContinue -WarningAction SilentlyContinue

if($extvm)
{
	Write-Host "Host VM Found $VMName, please use a different VMName for provisioning" -ForegroundColor Yellow
	Start-sleep 5
	Exit
}
else {if($nic1)
{
	Write-Host "Removing orphan $InterfaceName1" -ForegroundColor White
	Remove-AzureRmNetworkInterface -Name $InterfaceName1 -ResourceGroupName $rg -Force -Confirm:$False -WarningAction SilentlyContinue
	$LogOut = "Removed $InterfaceName1 - Private Adapter"
	Log-Command -Description $LogOut -LogFile $LogOutFile
 }
	 if($pubip)
{
	Remove-AzureRmPublicIpAddress -Name $InterfaceName1 -ResourceGroupName $rg -Force -Confirm:$False  -WarningAction SilentlyContinue
	$LogOut = "Removed $InterfaceName1 - Public Ip"
	Log-Command -Description $LogOut -LogFile $LogOutFile
}
	 if($nic2)
{
	Write-Host "Removing orphan $InterfaceName2" -ForegroundColor White
	Remove-AzureRmNetworkInterface -Name $InterfaceName2 -ResourceGroupName $rg -Force -Confirm:$False -WarningAction SilentlyContinue
	$LogOut = "Removed $InterfaceName2 - Private Adapter"
	Log-Command -Description $LogOut -LogFile $LogOutFile
 }
 else {Write-Host "No orphans found." -ForegroundColor Green}
 }
} #
#endregion

Function Create-ResourceGroup {
				$resourcegroups = @($rg,$vnetrg,$storerg);
				if($resourcegroups.length) {
					foreach($resourcegroup in $resourcegroups) {
						Provision-RG($resourcegroup);
					}
				}
}

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
					Check-NSGName # Verifies required fields have data
					Check-AvailabilitySet # Verifies required fields have data
					Check-FQDN # Verifies required fields have data
					Check-NullValues # Verifies required fields have data
					Check-Orphans # Verifies no left overs
					Verify-NIC # Verifies required fields have data
					if(!$useexiststorage)
					{ Check-StorageName }
					else
						{ Check-StorageNameNotExists }
					 # Verifies Storage Account Name does not exist
					Write-Output "Steps will be tracked in the log file : [ $LogOutFile ]"
					Create-ResourceGroup
					if($AddVnet -or $BatchAddVnet -eq 'True')
							{
								Check-Vnet-NoMsg
							} # Creates VNET

					if($CreateNSG -or $BatchCreateNSG -eq 'True')
							{
								Create-NSG
							} # Creates NSG and Security Groups
					if($CreateLoadBalancer -or $BatchCreateLB -eq 'True' -and $LBType -eq 'external')
							{
							Check-CreateLB
							Create-LB
							}

					if($CreateLoadBalancer -or $BatchCreateLB -eq 'True' -and $LBType -eq 'internal')
							{
							Verify-LBSubnet
							Check-CreateIntLB
							Create-IntLB
							}

					Check-Vnet
					Create-VM # Configure Image

					if($addmngdatadisk -or $batchaddmngdatadisk -eq 'True')
							{
							Create-MngDataDisks
							}
					if($AddNSG -or $BatchAddNSG -eq 'True')
							{
								Configure-NSG
							} #Adds NSG to NIC

					if($AddLB -or $BatchAddLB -eq 'True') {
						if($LBType -eq 'internal'){Configure-IntLB}
							 elseif($LBType -eq 'external') {Configure-ExtLB}
								}
					if($UploadSharedFiles -or $BatchAddShare -eq 'True')
							{
								Upload-sharefiles
							}
					if($AddExtension -or $BatchAddExtension -eq 'True')
							{
								Eval-extdepends
								 Install-Ext
							}
							else
							{ Write-Results }

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
				if($UpdateExtension -or $AddExtension -or $BatchAddExtension -eq 'True')
						{
						Eval-extdepends
						Verify-StorageExists
						Install-Ext
						exit
						}
				if($AddNSG -or $BatchAddNSG -eq 'True')
						{
						Check-NSGName
						Configure-NSG
						}

				if($AddLB -or $BatchAddLB -eq 'True') {
						if($LBType -eq 'internal'){Configure-IntLB}
							 elseif($LBType -eq 'external') {Configure-ExtLB}
								}

				if($UploadSharedFiles -or $BatchAddShare -eq 'True')
						{
						Upload-sharefiles
						}
				if($VNETPeering)
							{
												Create-VnetPeering
							} #Creates Peering
	}
			"remove" {
			 Eval-remdepends
			.\AZRM-RemoveResource.ps1 -RemoveObject $RemoveObject -rg $rg -VMName $VMName -vnetrg $vnetrg -StorageName $StorageName -VNetName $VNetName -extname $extname
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

function convert-bool {
param($inputstring = $inputstring)
	if($inputstring -eq '1')
		{$script:output = $true }
			elseif($inputstring -eq 'True')
						{$script:output = $true }
				else
							{$script:output = $false }
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

#region Create Log Directory
Function Create-Dir {
$logdirexists = Test-Path -Path $logdir
	$direxists = Test-Path -Path $customscriptsdir
		$dscdirexists = Test-Path -Path $dscdir
				$localSoftwareFolderExists = Test-Path -Path $localSoftwareFolder
if(!$logdirexists)
	{
	New-Item -Path $logdir -ItemType Directory -Force | Out-Null
		Write-Host "Created directory" $logdir
	}
	elseif(!$direxists)
	{
	New-Item -Path $customscriptsdir -ItemType Directory -Force | Out-Null
	Write-Host "Created directory" $customscriptsdir
}
		elseif(!$dscdirexists)
{
		New-Item -Path $dscdir -ItemType Directory -Force | Out-Null
		Write-Host "Created directory" $dscdir
}
}
#endregion

Function Write-Summary {
param(
		[Parameter(Mandatory=$False,ValueFromPipelinebyPropertyName=$true,Position=1)]
		[string]
		$rg = $rg

)

 $diskreport = Get-AzureRmResource -ResourceType Microsoft.Compute/disks -ResourceGroupName $rg | ft name -Wrap -HideTableHeaders
 $strreport = Get-AzureRmResource -ResourceType Microsoft.Storage/StorageAccounts -ResourceGroupName $rg | ft name,sku -Wrap -HideTableHeaders
 $nicreport = Get-AzureRmResource -ResourceType  Microsoft.Network/networkInterfaces -ResourceGroupName $rg | ft Name -Wrap -HideTableHeaders
 $vmreport = Get-AzureRmResource -ResourceType  Microsoft.Compute/virtualMachines -ResourceGroupName $rg | ft Name -Wrap -HideTableHeaders
 $vmextreport = Get-AzureRmResource -ResourceType  Microsoft.Compute/virtualMachines/extensions -ResourceGroupName $rg |ft Name -HideTableHeaders
 $pubipreport = Get-AzureRmResource -ResourceType  Microsoft.Network/publicIPAddresses -ResourceGroupName $rg | ft Name -HideTableHeaders
 $vgatereport = Get-AzureRmResource -ResourceType  Microsoft.Network/virtualNetworkGateways -ResourceGroupName $rg | ft Name -HideTableHeaders
 $vnetreport = Get-AzureRmResource -ResourceType  Microsoft.Network/virtualNetworks -ResourceGroupName $rg | ft Name -HideTableHeaders

Write-Host "" -ForegroundColor Blue
Write-Host "Virtual Networks in $rg" -ForegroundColor Blue
Write-Host "---------------------------------------------" -ForegroundColor Blue
Write-Output $vnetreport
Write-Host "Virtual Machines in $rg" -ForegroundColor Blue
Write-Host "---------------------------------------------" -ForegroundColor Blue
Write-Output $vmreport
Write-Host "Virtual Machine Extensions in $rg" -ForegroundColor Blue
Write-Host "---------------------------------------------" -ForegroundColor Blue
Write-Output  $vmextreport
Write-Host "Network Interfaces in $rg" -ForegroundColor Blue
Write-Host "---------------------------------------------" -ForegroundColor Blue
Write-Output $nicreport
Write-Host "Public Ip Addresses in $rg" -ForegroundColor Blue
Write-Host "---------------------------------------------" -ForegroundColor Blue
Write-Output $pubipreport
Write-Host "Storage Accounts in $rg" -ForegroundColor Blue
Write-Host "---------------------------------------------" -ForegroundColor Blue
Write-Output $strreport
Write-Host "Managed Storage accounts in $rg" -ForegroundColor Blue
Write-Host "---------------------------------------------" -ForegroundColor Blue
Write-Output $diskreport
}

Function Get-Dependencies {
	param(
[Parameter(Mandatory=$False,ValueFromPipelinebyPropertyName=$true)]
[string]
$remscriptpath =  '.\AZRM-RemoveResource.ps1',
[Parameter(Mandatory=$False,ValueFromPipelinebyPropertyName=$true)]
[string]
$extscriptpath = '.\Azrm-ExtDeploy.ps1',
					$script:remenable = 'True',
				$script:extenable = 'True'
	)
$remscript = Test-Path -Path $remscriptpath
	$extscript = Test-Path -Path $extscriptpath

if(!$remscript)
	{
		Write-Host "Removal Functionality Disabled - File does not Exist" $remscriptpath
	 $script:remenable = 'False'
	}
	else
	{	 $script:remenable = 'True'}

	if(!$extscript)
	{
	Write-Host "Extension Functionality Disabled - File does not Exist" $extscriptpath
	$script:extenable = 'False'
}
	else
	{	 $script:extenable = 'True'}
}

Function Eval-remdepends
{
	param(
		$remenable = $script:remenable

	)

	if($remenable -eq 'True')
	{
	Write-Host "Removal Enabled"
	}
		else
	{ Write-Host "Removal functions Disabled"
	exit
	}
}

Function Eval-extdepends
{
	param(
		$extenable = $script:extenable
	)

	if($extenable -eq 'True')
	{
	}
	else
	{ Write-Host "Extensions Disabled"
	exit
	}
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
$customscriptsdir = $workfolder+'\'+'customscripts'+'\'
$dscdir = $workfolder+'\'+'dsc'+'\'
$LogOutFile = $logdir+$vmname+'-'+$date+'.log'
$ProfileFile = $workfolder+'\'+$profile+'.json'

Verify-AzureVersion # Verifies Azure client Powershell Version

if($help) {
Help-User
exit
}
if(!$usermlogin)
{
validate-profile
}
else
{
Login-AddAzureRmProfile
}

try {
Get-AzureRmResourceGroup -Location $Location -ErrorAction Stop | Out-Null
}
catch {
	Write-Host -foregroundcolor Yellow `
	"User has not authenticated, use Add-AzureRmAccount or $($_.Exception.Message)"; `
	Login-AddAzureRmProfile
}

Register-ResourceProviders

Create-Dir

if($csvimport) { csv-run }
Get-Dependencies

if($summaryinfo)
	{
Write-Summary
		exit
	}

if($preview)
{
Get-Preview
	exit
}

Action-Type