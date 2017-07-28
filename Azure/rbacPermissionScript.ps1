<#

.SYNOPSIS
	This script updates Azure access of a list of users in a subscription to a specific list of roles.

.DESCRIPTION
	ARM Link templates are copied to temporary azure blob store, used to deploy and then deleted after deployment
	
    This script assumes the following:
    1. You are logged into AzureRM
	2. You have Owner/Co-admin rights for the subscription you are modifying
	
	Please also have a clear understanding of all the roles you need access to. Please consult https://docs.microsoft.com/en-us/azure/active-directory/role-based-access-built-in-roles
	
	For more informaiton on how to do this manually, please refer to: https://docs.microsoft.com/en-us/azure/active-directory/role-based-access-control-configure


.PARAMETER subscriptionName
	Name of the subscirption where you would like to update access
.PARAMETER roleList
	An array of roles you would like to assign to the user(s)
.PARAMETER userList
	A list of users that you would like to assin the role(s)
.PARAMETER action
	(Optional) The action required - Add or Remove. If left blank, default action is Add
.PARAMETER searchBy
	(Optional) The key to search for the user - Email or Name. If left blank, default search by is Name

.NOTES 
    Author         :  Igor Loza - igor@loza.net.au, rogiloza@gmail.com
    Role           :  DevOps

.EXAMPLE
    .\rbacPermissionScript.ps1 -subscriptionName 'MySbuscriptionName' -roleList @('Contributor') -userList @('Igor Loza')
	
	.\rbacPermissionScript.ps1 -subscriptionName 'MySbuscriptionName' -roleList @('Classic Virtual Machine Contributor','Virtual Machine Contributor') -userList @('Igor Loza','FirstName2 Surname2')
	
	.\rbacPermissionScript.ps1 -subscriptionName 'MySbuscriptionName' -roleList @('Classic Virtual Machine Contributor','Virtual Machine Contributor') -userList @('A137161@agl.com.au') -searchBy Email

    .\rbacPermissionScript.ps1 -subscriptionName 'MySbuscriptionName' -roleList @('Classic Virtual Machine Contributor','Virtual Machine Contributor') -userList @('Igor Loza') -action Remove
	

#> 

# Log in to Azure PowerShell
# This scirpt assumes you have already run this command: 
# Login-AzureRmAccount

#Set the 3 required variables subscriptionName, roleList, userList
#$subscriptionId = 'subscriptions/da90b945-2d6b-4ff4-a0e4-bf541cf8265f'
#$subscriptionName = 'Digital-Channels-DST'
[CmdletBinding()]
param(	

	[Parameter(Mandatory=$true)]
	[ValidateNotNullOrEmpty()]
    [String]
	$subscriptionName,	
		
	[Parameter(Mandatory=$true)]
	[ValidateNotNullOrEmpty()]
    [String[]]
	$roleList,	
	
	[Parameter(Mandatory=$true)]
	[ValidateNotNullOrEmpty()]
    [String[]]
	$userList,
	
	[Parameter(Mandatory=$false)]
	[ValidateSet("Add", "Remove")]
    [String]
	$action,
	
	[Parameter(Mandatory=$false)]
	[ValidateSet("Name", "Email")]
    [String]
	$searchBy
)

# Example roleList
# $roleList = @('Classic Virtual Machine Contributor','Virtual Machine Contributor')

# Example userList (if searchBy is blank or Name)
# $userList = @('FirstName1 Surnmae1','FirstName2 Surname2');

# Example userList (if searchBy Email)
# $userList = @('A137161@agl.com.au');

# Change context to the required subscription and assign subscriptionId
$context = Set-AzureRmContext -SubscriptionName $subscriptionName
$subscriptionId = 'subscriptions/' + $context.Subscription.SubscriptionId

foreach($user in $userList) {
	if($searchBy -eq "Email")
	{
		$userObject = Get-AzureRmADUser -Mail $user
	}
	else 
	{
		$userObject = Get-AzureRmADUser -SearchString $user
		Write-Host $userObject
	}
    foreach($uniqueUser in $userObject) {
        foreach ($role in $roleList) {
			If($action -eq "Remove") {
				Remove-AzureRmRoleAssignment -ObjectId $uniqueUser.id -RoleDefinitionName $role
				Write-Host "Removing " $uniqueUser.DisplayName " from role: " $role -NoNewLine
			}
			Else {
				New-AzureRmRoleAssignment -ObjectId $uniqueUser.id -RoleDefinitionName $role -Scope $subscriptionId
				Write-Host "assigning" $uniqueUser.DisplayName " role: " $role -NoNewLine
			}
        }
    }
}



