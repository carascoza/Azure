@"
==========================================================================================================
                                        Suporte AVD
Title:
Description:
Name:
Version:
Date_create:
Date_modified:
==========================================================================================================

"@


# Variaveis
$logTime = ""
$ExportFilePath = "C:\Users\caras\Documents\Cloud\Azure\AVD\"
$avd_hostpool = $ExportFilePath + "report_avd_hostpool.csv"
$avd_vms = $ExportFilePath + "report_avd_vm.csv"

# Conectar azure
Connect-AzAccount


# Select the target subscription for the current session
Select-AzSubscription -SubscriptionId $SubscriptionId 


##Listar hostpool

Get-AzResource -ResourceType "Microsoft.DesktopVirtualization/hostpools" | Select-Object -Property ResourceName, Name, ResourceGroupName, ResourceType | Export-Csv -Path $avd_hostpool -NoTypeInformation


#listar sessões AVD

#Get-AzResource -ResourceType "Microsoft.DesktopVirtualization/hostpools/sessionhosts/usersessions/*" | Export-Csv -Path c:\temp\report_avd_session.csv -NoTypeInformation


##listar vms forma 1

Get-AzResource -ResourceType "Microsoft.Compute/virtualMachines" | Select-Object -Property ResourceName, ResourceGroupName, Type | Export-Csv -Path $avd_vms -NoTypeInformation

