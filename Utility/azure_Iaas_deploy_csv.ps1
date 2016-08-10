<#
.SYNOPSIS
This script supports the IaaS Deployment Script by providing the ability to deploy multiple servers in Azure using a CSV.
.DESCRIPTION
Requires the IaaS Deployment Script, provides CSV Import interop for deployment.
.PARAMETER csvin

.PARAMETER procscript

.PARAMETER profile

.PARAMETER TeeOut

.EXAMPLE
\.azdeploy-csv.ps1 -proscript "C:\Temp\azdeploy.ps1" -csvin "C:\Temp\newinfra.csv"

.NOTES

.LINK
https://github.com/JonosGit/IaaSDeploymentTool
#>

[CmdletBinding()]
Param(
 [Parameter(Mandatory=$True,ValueFromPipelinebyPropertyName=$true,Position=1)]
 [string]
 $csvin = ".\newinfra.csv", 

 [string]
 [Parameter(Mandatory=$True,ValueFromPipelinebyPropertyName=$true,Position=0)]
 $procscript = ".\azdeploy.ps1",
 
 [Parameter(Mandatory=$False,ValueFromPipelinebyPropertyName=$true)]
 [string]
 $TeeOut = ".\teelog.txt"
)
# Global
$ErrorActionPreference = "SilentlyContinue"
$date = Get-Date -UFormat "%Y-%m-%d-%H-%M"
$workfolder = Split-Path $script:MyInvocation.MyCommand.Path
Function VerifyProfile {
$ProfileFile = $profile
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

Function DeployCSV {
try {
$GetPath = test-path -Path $procscript
Write-Host $GetPath "File Exists"
$GetPath = test-path -Path $csvin
Write-Host $GetPath "File Exists"
}
catch {
	Write-Host -foregroundcolor Yellow `
	"$($_.Exception.Message)"; `
	break
}
	finally {
import-csv -Path $csvin -Delimiter ',' | ForEach-Object{.\azdeploy.ps1 -VMName $_.VMName -vmMarketImage $_.VMMarketImage -ResourceGroupName $_.ResourceGroupName -vNetResourceGroupName $_.vNetResourceGroupName -VNetName $_.VNetName -ConfigIPs $_.ConfigIPs -DepSub1 $_.DepSub1 -availabilityset $_.AvailabilitySet }
	}
}

VerifyProfile
DeployCSV