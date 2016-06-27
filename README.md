.SYNOPSIS 
This script provides the following functionality for deploying IaaS environments in Azure. The script will deploy VNET in addition to numerour Market Place VMs or make use of an existing VNET.
Market Images supported: Redhat 6.7, PFSense 2.5, Windows 2008 R2, Windows 2012 R2, Ubuntu 14.04, CentOs 7.2, SUSE, SQL 2016 (on W2K12R2), R Server on Windows and Chef Server v12

.PARAMETERS
VMName is a required parameter at runtime. All other parameters are optional at runtime.

To deploy a VM to an existing VNET set the $NewVnet parameter to false. ** Update the $VNETResourceGroupName variable before running the script.
To deploy a new VNET with multiple subnets set the $NewVnet flag to true. ** The New VNET Will be deployed to $vNetResourceGroupName.
To deploy a specific market image enter one of the following names for $vmmMarketImage: Redhat PFSecure W2k12r2 w2k8r2 centos ubuntu chef SUSE SQL RSERVER

The Public IP Address of the VM will be shown when the script completes and can be used access the server.

.EXAMPLES
Deployment runtime positional parameters examples:
.\Azure_infra_arm_automater.ps1myserver RedHat myresgroup myvnet -NewVNET True -NSGEnabled True
.\Azure_infra_arm_automater.ps1myserver2 RedHat myresgroup myvnet
.\Azure_infra_arm_automater.ps1myserver3 Suse myresgroup myvnet
.\Azure_infra_arm_automater.ps1myserver4 w2k12 myresgroup myvnet
.\Azure_infra_arm_automater.ps1myserver5 rserver myresgroup myvnet
.\Azure_infra_arm_automater.ps1myserver5 sql myresgroup myvnet

Runtime named parameters examples:
Deploy SQL Server to existing VNET in existing resource group: .\Azure_infra_arm_automater.ps1-VName sqlserver1 -VMMarketImage SQL
Deploy PFSense Server to a existing VNET in existing resource group: .\Azure_infra_arm_automater.ps1-VName pfserver1 -VMMarketImage Pfsense
Deploy PFSense Server to a new VNET in new resource group with a Network Security Group attached: .\Azure_infra_arm_automater.ps1-VName pfserver1 -VMMarketImage Pfsense -NewVNET True -VNETName NewVNET -ResourceGroupName INFRA_RG -NSGEnabled True 
Deploy Windows 2012 R2 Server to a new VNET in new resource group: .\Azure_infra_arm_automater.ps1-VName winserver1 -VMMarketImage w2k12r2 