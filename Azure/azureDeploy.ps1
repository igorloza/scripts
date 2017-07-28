<#

.SYNOPSIS
	This script Deploys Azure Link ARM templates (link or not) to Azure. It uploads link files to Azure storage blob for use

.DESCRIPTION
	ARM Link templates are copied to temporary azure blob store, used to deploy and then deleted after deployment
	
    This script assumes the following:
    1. You are logged into AzureRM
    2. You are in the subscription you wish to deploy in
    3. The account you are logged in has read/contribute access to Subscription
    4. The account you are logged in has read/contribute access to the key vault

    Recommended link file standard: <object>.link.json, <object>.parameter.link.json
    EG: sqlserver.link.json, sqlserver.parameter.link.json

.PARAMETER ResourceGroupName
	Name of the resource group where the provided arm template is going to deploy
.PARAMETER ResourceGroupLocation
	(optional) Region where the arm template is going to be deployed (australiasoutheast or australiaeast).
    By Default it is set to: "australiasoutheast"
.PARAMETER StorageAccountName
	(optional) Name of the storage account where the temporary link templates will be stored
    By Default set to: "devopsbuild"
.PARAMETER KeyVaultName
	(optional) Name of the Azure KeyVault where the storage account secret to run the script is stored. The name value pair of StorageAccountName:StorageKey should be stored as a secret.
    By Default set to: "managementkeyvault"
.PARAMETER WorkingPath
	(Optional) Name of the main directory where all the .json files are currently stored. Please include trailing slash.
    By Defualt set to: Current working directory (Get-Location)
.PARAMETER BuildPath
	(Optional) Name of the temporary directory where the build templates get created in. Please include trailing slash. Caution, this directory gets blown away after the build.
    By Default set to: "C:\builddir\"
.PARAMETER ArmTemplate
	(Optional) Azure main template for your deployment, filename only, must be in WorkingPath.
    By Default set to: "azuredeploy.main.json" 
.PARAMETER ParameterFile
	(Optional) Azure paramenter file for the main template for your deployment, filename only, must be in WorkingPath.
    By Default set to: "azuredeploy.main.parameters.json"

.NOTES 
    Author         :  Igor Loza - igor@loza.net.au, rogiloza@gmail.com
    Team           :  DevOps

.EXAMPLE
    .\azureDeploy.ps1 -ResourceGroupName 'rg-deployment-test'

.EXAMPLE
    .\azureDeploy.ps1 -ResourceGroupName 'rg-deployment-test' -KeyVaultName "managementkeyvault" -StorageAccountName "devopsbuild" -WorkingPath "C:\mydir\mydeployment\" -BuildPath "C:\builddir\" -ArmTemplate "azuredeploy.main.json" -ParameterFile "azuredeploy.main.parameters.json"

#> 


[CmdletBinding()]
param(	
	[Parameter(Mandatory=$true)]
	[ValidateNotNullOrEmpty()]
    [String]
	$ResourceGroupName,

	[Parameter(Mandatory=$false)]
	[ValidateSet("australiasoutheast", "australiaeast")]
    [String]
	$ResourceGroupLocation,
	
	[Parameter(Mandatory=$false)]
	[ValidateNotNullOrEmpty()]
    [String]
	$KeyVaultName,

	[Parameter(Mandatory=$false)]
	[ValidateNotNullOrEmpty()]
    [String]
	$StorageAccountName,

	[Parameter(Mandatory=$false)]
	[ValidateNotNullOrEmpty()]
    [String]
	$WorkingPath,

	[Parameter(Mandatory=$false)]
	[ValidateNotNullOrEmpty()]
    [String]
    $BuildPath,

    [Parameter(Mandatory=$false)]
	[ValidateNotNullOrEmpty()]
    [String]
    $ArmTemplate,
    	
    [Parameter(Mandatory=$false)]
	[ValidateNotNullOrEmpty()]
    [String]
    $ParameterFile

	
)

# Requires PowerShell 5.0
Set-StrictMode -Version 5.0

# Import Modules
Import-Module Azure

#################################################################
#    DEFINE BUILD FUNCTIONS                                     #
#    Any function requried to build infrastructure              #
#################################################################
Function Get-SecretsFromKeyVault ($key){
	$storKey = Get-AzureKeyVaultSecret -VaultName $KeyVaultName -Name $key
	return $storKey.SecretValueText
}


#################################################################
#    DECLARE VARIABLES AND DEFAULTS                             #
#    All the items that need to be declared outside of params   #
#################################################################

# Set Defaults
$defaultStorageAccountName = "agldevopsbuild";
[string]$defaultWorkingPath = Get-Location;
$defaultWorkingPath = $defaultWorkingPath + "\";
$defaultBuildPath = "C:\builddir\";
$defaultArmTemplate = "azuredeploy.main.json";
$defaultParameterFile = "azuredeploy.main.parameters.json";
$defaultKeyVaultName = "managementkeyvault";
$defaultResourceGroupLocation = "australiasoutheast";

# Set Defaults
$ResourceGroupLocation = if ($ResourceGroupLocation) {$ResourceGroupLocation} else {$defaultResourceGroupLocation}
$KeyVaultName = if ($KeyVaultName) {$KeyVaultName} else {$defaultKeyVaultName};
$StorageAccountName = if ($StorageAccountName) {$StorageAccounName} else {$defaultStorageAccountName}
$WorkingPath= if ($WorkingPath) {$WorkingPath} else {$defaultWorkingPath}
$BuildPath = if ($BuildPath) {$BuildPath} else {$defaultBuildPath}
$ArmTemplate = if ($ArmTemplate) {$ArmTemplate} else {$defaultArmTemplate}
$ParameterFile = if ($ParameterFile) {$ParameterFile} else {$defaultParameterFile}
$StorageAccountKey = Get-SecretsFromKeyVault $StorageAccountName

$ArmTemplateFile = $WorkingPath + $ArmTemplate 
$ArmParameterFile = $WorkingPath + $ParameterFile 
$BuildFile = $BuildPath + $ArmTemplate
$BuildParameterFile = $BuildPath + $ParameterFile

#################################################################
#    PRE-BUILD DATA MANIPULATION                                #
#    Get the build ready for deployment(s)                      #
#################################################################

# Create Build Directory if it doesn't exist
if(-Not (Test-Path $BuildPath)) {
    New-Item -ItemType directory -Path $BuildPath
}


#CREATE a unique CONTAINER on the storage account
[string]$myTimestamp = Get-Date -UFormat "%y%m%d%H%M%S"
$ctx = New-AzureStorageContext -StorageAccountName $StorageAccountName -StorageAccountKey $StorageAccountKey
$ContainerName = "buildfiles-" + $myTimestamp
New-AzureStorageContainer -Name $ContainerName -Context $ctx -Permission Blob

#Update location of files with blob
$OnlinePath = "https://" + $StorageAccountName + ".blob.core.windows.net/" + $ContainerName
(Get-Content $ArmTemplateFile).replace('<<placeholder>>', $OnlinePath) | Set-Content $BuildFile -Force
(Get-Content $ArmParameterFile) | Set-Content $BuildParameterFile

# Upload all the files to temporary blob container
cd $WorkingPath
$Files = Get-ChildItem -Filter *.link*
foreach($File in $Files) {
    Set-AzureStorageBlobContent -File $File.Name -Container $ContainerName -Context $ctx
}


#################################################################
#    BUILD LINK DEPLOYMENT                                      #
#                                                               #
#################################################################
## TEST LINK TEMPALTES
New-AzureRmResourceGroup -Name $ResourceGroupName -Location $ResourceGroupLocation -Verbose -Force -ErrorAction Stop 
Test-AzureRmResourceGroupDeployment -ResourceGroupName $resourceGroupName -TemplateFile $BuildFile -TemplateParameterFile $BuildParameterFile -ErrorAction Stop
## DEPLOY LINK TEMPLATES
New-AzureRmResourceGroupDeployment -Name $ContainerName -ResourceGroupName $resourceGroupName -TemplateFile $BuildFile -TemplateParameterFile $BuildParameterFile -ErrorAction Stop
#New-AzureRmResourceGroup -Name $ResourceGroupName -Location $ResourceGroupLocation -Verbose -Force -ErrorAction Stop 

#################################################################
#    PERFORM CLEANUP HERE                                       #
#                                                               #
#################################################################

# Cleanup Tasks - remove container
Remove-Item -Path $BuildPath -recurse
Remove-AzureStorageContainer -Name $ContainerName -Context $ctx -Force
