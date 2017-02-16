<#

.SYNOPSIS
	Please use this script if you need to resize your host OS disk
	

.DESCRIPTION
	This script udpates the OS disk by resizing it. It requires a shutdown and restart and you have to expand the disk through Disk Manager after the machine starts up.
	

    This script assumes the following:
    1. You are logged into AzureRM
	2. You have Contributor rights to the VM you are modifying
	
	This script is based off microsoft documentation: https://docs.microsoft.com/en-us/azure/virtual-machines/virtual-machines-windows-classic-detach-disk

.PARAMETER subscriptionName
	Name of the subscirption where you would like to update access
.PARAMETER rgName
	The name of the resource group your ARM vm resides in. EG: application-aus-rg
.PARAMETER vmName
	The Name of your VM. EG: application-vm1
.PARAMETER size
	The size (GB) you wish to resize too. Please note, you can only resize a VM OS disk to a bigger size.
	Only 2 options have are allowed, but feel free to update this based on your requirements. EG: 512

.NOTES 
    Author         :  Igor Loza - igor@loza.net.au, rogiloza@gmail.com
    Role           :  DevOps
	Other Tasks	   :  Please do not forget to udpate the OS Disk after booting through Disk Manager.

.EXAMPLE
    .\resizeOSDisk.ps1 -subscriptionName My-Subscription-Name -rgName application-aus-rg -vmName application-vm1 -size 512


#> 

[CmdletBinding()]
param(	

	[Parameter(Mandatory=$true)]
	[ValidateNotNullOrEmpty()]
    [String]
	$subscriptionName,	
		
	[Parameter(Mandatory=$true)]
	[ValidateNotNullOrEmpty()]
    [String]
	$rgName,	
	
	[Parameter(Mandatory=$true)]
	[ValidateNotNullOrEmpty()]
    [String]
	$vmName,
	
	[Parameter(Mandatory=$true)]
	[ValidateSet(512, 1023)]
    [int]
	$size	
)

#Ensure you are working in the right subscription
Set-AzureRmContext -SubscriptionName $subscriptionName

#Select your VM
$vm = Get-AzureRmVM -ResourceGroupName $rgName -Name $vmName

#Shut Down you VM
Stop-AzureRmVM -ResourceGroupName $rgName -Name $vmName

#Change OS Disk Size
$vm.StorageProfile.OSDisk.DiskSizeGB = $size

#Apply updates to your VM
Update-AzureRmVM -ResourceGroupName $rgName -VM $vm

#Restart your VM
Start-AzureRmVM -ResourceGroupName $rgName -Name $vmName