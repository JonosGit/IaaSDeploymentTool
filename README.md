Deployment Instructions for Azure IaaS Deployment Tool

By default this script will deploy a new VNET with 7 subnets. It will then provision a PfSecure dual homed VPN to the edge subnet.

This script also supports deploying the following images ad-hoc Windows 2012 R2, Windows 2008 R2, Ubuntu, Redhat, Suse, Chef and Centos Store images on demand by changing one value in the script.

Prior to running this script make sure the environment variables have been configured for Subscription ID, TenantID, ResourceGroup and VNETName
Update the vmcount variable to increment the Deployed VM, i.e. 001 will result in a VM Deployed named AIP001.
To specify the local adminsitrator and Password Update the locadmin and locpassword
The Public IP Address of the VM will be shown when the script completes and can be used access the server.

By default a new VNET and dual homed PFSense Server are deployed to a new or existing Resource Group in Azure.
To deploy a VM to an existing VNET set the $NewVnet parameter to false. ** Update the $VNETResourceGroupName variable before running the script.
To deploy a new VNET with multiple subnets set the $NewVnet flag to true. ** The New VNET Will be deployed to $vNetResourceGroupName.

To deploy a specific market image enter one of the following names for $vmmMarketImage: Redhat PFSecure W2k12r2 w2k8r2 centos ubuntu chef SUSE (default is pfsense)

Note, these scripts require Azure Powershell 1.0.
