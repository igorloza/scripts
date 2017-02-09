# Azure Scripts

This repo should be used for anything Azure Related

## Folders
1. sampleLinkTemplates
This folder contains a sample project requried for private Link Template deployment. Please see azureDeploy.ps1 below for more details.

## Scripts

### rbacPermissionScript.ps1
This script allows you to assign/manage user roles in a particular subscrption.
1. Requirements
  * Subscription Name
  * A list of User names (Complete, eg: Igor Loza, Alex Loza)
  * A list of roles you wish to apply/remove
2. Steps
  * Log into Azure
    ```PowerShell
    Login-AzureRmAccount
    ```
  * Provision RBAC access
    ```PowerShell
    .\rbacPermissionScript.ps1 -subscriptionName 'MySbuscriptionName' -roleList @(Classic Virtual Machine Contributor','Virtual Machine Contributor') -userList @('Igor Loza', 'Alex Loza')
    ```
  * Remove RBAC Access
    ```PowerShell
    .\rbacPermissionScript.ps1 -subscriptionName 'MySbuscriptionName' -roleList @(Classic Virtual Machine Contributor','Virtual Machine Contributor') -userList @('Igor Loza', 'Alex Loza') -action Remove
    ```
3. Script Help
    ```PowerShell
    Get-Help .\rbacPermissionScript.ps1
    Get-Help .\azureDeploy.ps1 -examples
    Get-Help .\azureDeploy.ps1 -detailed
    Get-Help .\azureDeploy.ps1 -full
    ```

### azureDeploy.ps1
This script allows the wielder to deploy link templates that are private and confidential by nature to Azure. 

When deploying an ARM template, the creator has two choices to make;
1. Create a single ARM template for deployment with 'n' number of resources or
2. Deploy multiple individual ARM templates through the deployments resource type
	```json
		"type": "Microsoft.Resources/deployments",
	```
The benefits of using linked templates (or deployements) is that it gives you the capability of deploying an entire environment or a logical grouping of resources at the same time OR the ability to deploy each of the objects separately. To do this, the link templates need to reference publically available json templates which of course in an enterprise create a security flaw. To work around such a security flaw, this script has been created to allow you to deploy these templates withouth being exposed.

It works by:
1. Creating a tempoary storage account in Azure/Container
2. Copying your link templates to that particular destination
3. Updating your main json template to reference the location of the newly uploaded destination (creating a copy in a temp folder)
4. Running the deployment
5. Deleting the Container in Azure hosting these temporary files
6. Deleting local temporary folder

This offcourse does not eliminate the exposure, but does limit it to the smallest deployment window required for Azure to view and use these files.

NOTE: This is not an alternative to using azure key vault for storing secrets.
