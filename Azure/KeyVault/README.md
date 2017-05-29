# Azure KeyVault for AGL

This is a template file required for building a key vault of your own. There are some prerequisites for this as seen below. If you have any questions, please do not hesitate to contact Igor Loza or the DevOps team in Digital. 

Please note: this document references Azure PowerShell

## Prerequisites

Please have these values/items handy:
1. Ensure that PowerShell 5 is installed
2. Ensure Azure PowerShell is installed
3. Clone this repository, open PowerShell (I advise using ISE) and change your working repository to that of the folder you have just cloned.
4. Identify TenantID - AGL generally uses one tenant, the default for which is already set in the parameters file. In the case you wish to build under a different tenant, please update the tenantId
  * Simply log into azure with PowerShell and note down the tenantId
    
	```PowerShell
    Login-AzureRmAccount
    ```
	
5. Identify your objectId - the office 365 ID that can be used to identify an individual user or an AD group. In this example we are using my objectID. To identify your id or your group's id follow these steps
  * Identify through Azure classic portal AD Device
    * Log into https://manage.windowsazure.com
	* Select Active Directory on the left hand side
	* Select the required directory
	* Click **Users** or **Groups**
	* Select the required user
	* Under **Profile**, **Identity** find the field titled **OBJECT ID**
  * VIA Azure PowerShell
    ```PowerShell
    Login-AzureRmAccount
    Get-AzureRmADGroup
    Get-AzureRmADGroup -SearchString "<<TEAMNAME>>"
    Get-AzureRmADUser
    Get-AzureRmADUser -SearchString "<<FIRST LAST>>"
    ```

  * Contact DevOps for support
  
## Customise Your KeyVault
Update the **keyVault.parameters.json** file required for your build

1. tenantId - please specify the required tenantId, see [Prerequisites](#prerequisites) for more information

2. objectId - please specify the required access for this, see [Prerequisites](#prerequisites) for more information

3. keyVaultName - please specify the keyVault name. Alphanumeric characters and dashes

3. storageAccountName - please specify a storage account name. This can only be lowercase letters and numbers. 
  
## Build Your KeyVault
1. Open PowerShell and change working directory to the folder that this project was cloned to.

    ```PowerShell
    cd C:\Work\gitProjects\Azure\KeyVault
    ```
	
2. Log into Azure with PowerShell

    ```PowerShell
    Login-AzureRmAccount
    ```
3. Create a new resource group to build your key vault name. I would suggest the following naming convention: rg-<region>-<environment>-<application>-key

    ```PowerShell
    $resourceGroupName = "rg-aus-npd-devops-key"
    New-AzureRmResourceGroup -Name $resourceGroupName -Location "Australia Southeast"
    ```
	
4. Test this deployment. Ensure that it is valid (note: this is optional)

    ```PowerShell
    Test-AzureRmResourceGroupDeployment -ResourceGroupName $resourceGroupName -TemplateFile "keyVault.json" -TemplateParameterFile "keyVault.parameters.json"
    ```
	
5. Deploy your keyVault

    ```PowerShell
    New-AzureRmResourceGroupDeployment -ResourceGroupName $resourceGroupName -TemplateFile  "keyVault.json" -TemplateParameterFile "keyVault.parameters.json"
    ```
  
## Validate your build
Simply log into the [Azure Portal](https://portal.azure.com)  and validate the new build 