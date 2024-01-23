@"
===============================================================================
                    SCRIPT
Title:         REPORT VMS AVD
Description:   REPORT VMS AVD
Usage:         .\reporte_avd.ps1
version:       V1.0
Date_create:   17/01/2024
Date_modified: 17/01/2024
===============================================================================

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


##listar vms forma 1

$total_vms = Get-AzResource -ResourceType "Microsoft.Compute/virtualMachines" | Select-Object -Property ResourceName, ResourceGroupName, Type


foreach ($vms in $total_vms){

#propriedades hardware vms
$vmConfig = Get-AzVM -ResourceGroupName $vms.ResourceGroupName -Name $vms.ResourceName

#vm name
$vms.ResourceName

# tipo de hardware
$vmConfig.HardwareProfile

#nome disco
$vmConfig.StorageProfile.OsDisk.Name 

#imagem referencia
$vmConfig.StorageProfile.ImageReference

}