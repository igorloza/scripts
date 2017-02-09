# Azure Scripts

This repo should be used for anything Azure Related

## Folders


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
