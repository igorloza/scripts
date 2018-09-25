# Login-AzureRMAccount
# Set-AzureRmContext -subscriptionName Business-Analytics-Development
#$vm = Get-AzureRmVm

#Write-Host ("Server Name`tBusiness Owner`tTechnical Owner`tSchedule Exemption`tSchedule Type`tCustom Schedule`n");
$export = "Server Name`tProject`tBusiness Owner`tTechnical Owner`tSchedule Exemption`tSchedule Type`tCustom Schedule`n";
for ($i = 0; $i -lt $vm.count; $i++) {
    $scheduleType = "null";
    $customSchedule = "null";
    $technicalOwner = "null";
    $businessOwner = "null";
    $schedExemption = "null";
    $project = "null";
    $vm[$i].tags.Keys | ForEach-Object { 
        if( $_ -eq "scheduleType") { $scheduleType =  $vm[$i].tags.Item($_) }
        if( $_ -eq "customSchedule") { $customSchedule =  $vm[$i].tags.Item($_) }
        if( $_ -eq "technicalOwner") { $technicalOwner =  $vm[$i].tags.Item($_) }
        if( $_ -eq "businessOwner") { $businessOwner =  $vm[$i].tags.Item($_) }
        if( $_ -eq "schedExemption") { $schedExemption =  $vm[$i].tags.Item($_) }
        if( $_ -eq "project") { $project =  $vm[$i].tags.Item($_) }
    }
    #Write-Host ($vm[$i].Name + "`t" +  $businessOwner + "`t" +  $technicalOwner + "`t" + $scheduleType + "`t" + $customSchedule);
    $export += $vm[$i].Name + "`t" + $project + "`t" +  $businessOwner + "`t" +  $technicalOwner + "`t" + $schedExemption + "`t" + $scheduleType + "`t" + $customSchedule + "`n"
}
$export > Business-Analytics-Development-VMs.csv