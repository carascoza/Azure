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
#$ExportFilePath = "<caminho>"
#$avd_hostpool = $ExportFilePath + "report_avd_hostpool.csv"
#$avd_vms = $ExportFilePath + "report_avd_vm.csv"
$Name_hostpool = 'avd_teste'
$Name_resource = 'avd_teste'
$Name_Location = 'eastus2'

# Conectar azure
Connect-AzAccount


# Select the target subscription for the current session
Select-AzSubscription -SubscriptionId $SubscriptionId 


New-AzResourceGroup -Name $Name_resource -Location $Name_Location

$parameters = @{
    Name = $Name_hostpool
    ResourceGroupName = $Name_resource
    HostPoolType = 'Personal'
    LoadBalancerType = 'Persistent'
    PreferredAppGroupType = 'Desktop'
    PersonalDesktopAssignmentType = 'Automatic'
    Location = $Name_Location
}

New-AzWvdHostPool @parameters