@"
===============================================================================
                    SCRIPT
Title:         CRIAR HOSTPOOL AVD
Description:   CRIAR HOSTPOOL AVD
Usage:         .\CRIAR_HOSTPOOL.ps1
version:       V1.0
Date_create:   23/01/2024
Date_modified: 24/01/2024
links: https://learn.microsoft.com/pt-br/azure/virtual-desktop/deploy-azure-virtual-desktop?tabs=powershell
Links: https://learn.microsoft.com/pt-br/powershell/module/az.desktopvirtualization/new-azwvdapplicationgroup?view=azps-11.2.0
Links: https://askaresh.com/2022/12/13/azure-virtual-desktop-powershell-create-a-host-pool-application-group-and-workspace-for-remoteapp-aka-published-applications/
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
$Name_Aplication = $Name_hostpool + "-DAG"


# Conectar azure
Connect-AzAccount


# Select the target subscription for the current session
Select-AzSubscription -SubscriptionId $SubscriptionId 

# Criar resource Group
New-AzResourceGroup -Name $Name_resource -Location $Name_Location


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
New-AzWvdWorkspace -ResourceGroupName $Name_resource `
                        -Name $Name_hostpool `
                        -Location $Name_Location `
                        -FriendlyName $Name_hostpool `
                        -ApplicationGroupReference $null `
                        -Description 'Description'



# Criar um grupo de aplicativos
$hostPoolArmPath = (Get-AzWvdHostPool -Name $Name_hostpool -ResourceGroupName $Name_resource).Id

$parameters = @{
    Name = $Name_Aplication
    ResourceGroupName = $Name_resource
    ApplicationGroupType = 'Desktop'
    HostPoolArmPath = $hostPoolArmPath
    Location = $Name_Location
}

New-AzWvdApplicationGroup @parameters


# Update Propriedades Hostpool
$properties="drivestoredirect:s:;audiomode:i:0;videoplaybackmode:i:1;redirectclipboard:i:1;redirectprinters:i:1;devicestoredirect:s:*;redirectcomports:i:0;redirectsmartcards:i:1;usbdevicestoredirect:s:;enablecredsspsupport:i:1;redirectwebauthn:i:1;autoreconnectionenabled:i:1;audiocapturemode:i:1;camerastoredirect:s:*;"
Update-AzWvdHostPool -ResourceGroupName $Name_resource -Name $Name_hostpool -CustomRdpProperty $properties


# Adicionar um grupo de aplicativos a um workspace
#$appGroupPath = (Get-AzWvdApplicationGroup -Name $Name_hostpool -ResourceGroupName $Name_resource).Id
#Update-AzWvdWorkspace -Name $Name_hostpool -ResourceGroupName $Name_resource -ApplicationGroupReference $appGroupPath


# Get the object ID of the user group you want to assign to the application group
$userGroupId = (Get-AzADGroup -DisplayName $NameGroup).Id

# Assign the AAD group (Object ID)  to the Application Group
try
{
    write-host "Assigning the AAD Group to the Application Group"
    $AssignAADGrpAG = New-AzRoleAssignment -ObjectId $userGroupId `
        -RoleDefinitionName "Desktop Virtualization User" `
        -ResourceName $Name_Aplication `
        -ResourceGroupName $Name_resource `
        -ResourceType 'Microsoft.DesktopVirtualization/applicationGroups' `
        -ErrorAction STOP
}
catch
{
    Write-Host $_.Exception.Message -ForegroundColor Yellow
}


#remover Role
#Remove-AzRoleAssignment -SignInName $userGroupId `
#-RoleDefinitionName "Desktop Virtualization User" 