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
$Name_hostpool = 'avd_teste2'
$Name_resource = 'avd_teste2'
$Name_Location = 'eastus2'
# Tipo 'BreadthFirst' ou 'DepthFirst' (Multisession), Tipo 'Personal' (dedicado)
$Name_HostPoolType = 'Personal'
# Tipo 'Pooled' (Multisession), Tipo 'Persistent'' (dedicado)
$Name_LoadBalancerType = 'Persistent'
$NameGroup = 'GRP_AZURE_AVD'


# Conectar azure
Connect-AzAccount


# Select the target subscription for the current session
Select-AzSubscription -SubscriptionId $SubscriptionId 

# Criar resource Group
#New-AzResourceGroup -Name $Name_resource -Location $Name_Location


# Criar um pool de host
$parameters = @{
    Name = $Name_hostpool
    ResourceGroupName = $Name_resource
    HostPoolType = $Name_HostPoolType
    LoadBalancerType = $Name_LoadBalancerType
    PreferredAppGroupType = 'Desktop'
    PersonalDesktopAssignmentType = 'Automatic'
    Location = $Name_Location
}

New-AzWvdHostPool @parameters


# Criar um workspace
New-AzWvdWorkspace -Name $Name_hostpool -ResourceGroupName $Name_resource


# Criar um grupo de aplicativos
$parameters = @{
    Name = $Name_hostpool
    ResourceGroupName = $Name_resource
    ApplicationGroupType = 'Desktop'
    HostPoolArmPath = $hostPoolArmPath
    Location = $Name_Location
}

New-AzWvdApplicationGroup @parameters


# Adicionar um grupo de aplicativos a um workspace
$appGroupPath = (Get-AzWvdApplicationGroup -Name $Name_hostpool -ResourceGroupName $Name_resource).Id
Update-AzWvdWorkspace -Name $Name_hostpool -ResourceGroupName $Name_resource -ApplicationGroupReference $appGroupPath


# Get the object ID of the user group you want to assign to the application group
$userGroupId = (Get-AzADGroup -DisplayName $NameGroup).Id

# Assign users to the application group
$parameters = @{
    ObjectId = $userGroupId
    ResourceName = $Name_hostpool
    ResourceGroupName = $Name_resource
    RoleDefinitionName = 'Desktop Virtualization User'
    ResourceType = 'Microsoft.DesktopVirtualization/applicationGroups'
}

New-AzRoleAssignment @parameters