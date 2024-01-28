@"
===============================================================================
                    SCRIPT
Title:         CRIAR HOSTPOOL AVD
Description:   CRIAR HOSTPOOL AVD
Usage:         .\CRIAR_HOSTPOOL.ps1
version:       V1.0
Date_create:   23/01/2024
Date_modified: 25/01/2024
links: https://learn.microsoft.com/pt-br/azure/virtual-desktop/deploy-azure-virtual-desktop?tabs=powershell
Links: https://learn.microsoft.com/pt-br/powershell/module/az.desktopvirtualization/new-azwvdapplicationgroup?view=azps-11.2.0
Links: https://askaresh.com/2022/12/13/azure-virtual-desktop-powershell-create-a-host-pool-application-group-and-workspace-for-remoteapp-aka-published-applications/
===============================================================================

"@

#variaveis
$LogTime = Get-Date -Format "dd-MM-yyyy;hh:mm:ss"
$Time = Get-Date -Format "MM-dd-yyyy"
$LogFile  = "<caminho\criar_hostpool_>" + $Time + ".log"
$LogFile_error  = "<caminho\Logs\error_>" + $Time + ".log"
$ExportFilePath = "<caminho>"
$token_azure = $null
$REStoken_azure = $null



#######################################################################################################################################
# Alterar 
# Nome Hostpool Alterar
$Name_hostpool = "<Nome>"

# Nome Resource Group Alterar
$Name_resource = "<Nome>"

# Tipo 'Pooled' (Multisession), Tipo 'Personal'' (dedicado), ""Alterar se necessario Padrão Personal""
$Name_HostPoolType = 'Personal'

# Tipo 'BreadthFirst' ou 'DepthFirst' (Multisession), Tipo 'Persistent' (dedicado), ""Alterar se necessario Padrão Persistent""
$Name_LoadBalancerType = 'Persistent'

#Grupo do AD que deve ter acesso Alterar para grupo da solicitação
$NameGroup = "<Nome_Grupo>"

# Tags Alterar as tags
$tags_avd = @{"ambiente" = "pr"; "departamento" = "ti"}

#######################################################################################################################################
#Não Alterar

# Nome Localização Não Alterar
$Name_Location = 'eastus2'

# Nome Aplication Não Alterar
$Name_Aplication = $Name_hostpool + "-DAG"

# Propriedades Hostpool Não Alterar
$properties="drivestoredirect:s:;audiomode:i:0;videoplaybackmode:i:1;redirectclipboard:i:0;redirectprinters:i:0;devicestoredirect:s:*;redirectcomports:i:0;redirectsmartcards:i:0;usbdevicestoredirect:s:;enablecredsspsupport:i:1;redirectwebauthn:i:1;autoreconnection enabled:i:0;audiocapturemode:i:1;camerastoredirect:s:*"

#######################################################################################################################################

#Cria arquivo log
"Titulo;Data;Hora" | Out-File $LogFile -Append -Force
"Inicio;" + $LogTime | Out-File $LogFile -Append -Force


#Verificar token azure
while ($token_azure  -eq $null ){
$REStoken_azure  = Read-Host "

============================= Script SUPORTE-VDI =============================

Digite 1 para validar Token azure 
Digite 2 para executar se ja validou o token azure

Valor: 
==============================================================================
"  

if ($REStoken_azure -eq "1" ){
$token_azure = "1"


Try
{ 


#conectar na azure tenant Bradesco
"Conctar na azure;" + $LogTime | Out-File $LogFile -Append -Force
Connect-AzAccount
#Set-AzContext -Subscription $subscriptionId

}

Catch{

$ErrorMessage = $_.Exception.Message
    "Error Concetar na azure;" +$ErrorMessage | Out-File $LogFile -Append -Force
   Write-Host -BackgroundColor red -ForegroundColor Black -Object $ErrorMessage
   exit
}


}
if ($REStoken_azure -eq "2" ){
$token_azure = "2"

Try
{ 

# mantem token da azure
function GetAuthToken($resource) {
    $context = [Microsoft.Azure.Commands.Common.Authentication.Abstractions.AzureRmProfileProvider]::Instance.Profile.DefaultContext
    $Token = [Microsoft.Azure.Commands.Common.Authentication.AzureSession]::Instance.AuthenticationFactory.Authenticate($context.Account, $context.Environment, $context.Tenant.Id.ToString(), $null, [Microsoft.Azure.Commands.Common.Authentication.ShowDialog]::Never, $null, $resource).AccessToken
    $authHeader = @{
        'Content-Type' = 'application/json'
        Authorization  = 'Bearer ' + $Token
    }
    return $authHeader
}
$token = GetAuthToken -resource https://management.azure.com
#Log
"Mantem token da azure;" + $LogTime | Out-File $LogFile -Append -Force
}

Catch{

$ErrorMessage = $_.Exception.Message
    "Error manter conectado na azure;" +$ErrorMessage | Out-File $LogFile -Append -Force
   Write-Host -BackgroundColor red -ForegroundColor Black -Object $ErrorMessage
   exit
}

}

if ($REStoken_azure -ne "1" -and $REStoken_azure -ne "2" ){
$token_azure = $null
cls
}
}

try
{
Write-Host -BackgroundColor yellow -ForegroundColor Black -Object "Criando Resource Group: $Name_resource da Azure... "
#Criar resource Group
New-AzResourceGroup -Name $Name_resource -Location $Name_Location -Tag $tags_avd
#Log
"Criar resource Group;$Name_resource;" + $LogTime | Out-File $LogFile -Append -Force

}
catch
{
    $ErrorMessage = $_.Exception.Message
    "Error_Criar resource Group;$Name_resource;" + $LogTime | Out-File $LogFile_error -Append -Force
   Write-Host -BackgroundColor red -ForegroundColor Black -Object $ErrorMessage
}
#######################################################################################################################################

try
{
Write-Host -BackgroundColor yellow -ForegroundColor Black -Object "Criando HostPool: $Name_hostpool da Azure... "
# Criar um pool de host
$parameters = @{
    Name = $Name_hostpool
    ResourceGroupName = $Name_resource
    HostPoolType = $Name_HostPoolType
    LoadBalancerType = $Name_LoadBalancerType
    PreferredAppGroupType = 'Desktop'
    PersonalDesktopAssignmentType = 'Automatic'
    Location = $Name_Location
    tag = $tags_avd
}

New-AzWvdHostPool @parameters
#Log
"Criar um pool de host;$Name_resource;" + $LogTime | Out-File $LogFile -Append -Force
}
catch
{
    Write-Host $_.Exception.Message -ForegroundColor Yellow
}
#######################################################################################################################################
try
{
Write-Host -BackgroundColor yellow -ForegroundColor Black -Object "Criando Workspace: $Name_hostpool da Azure... "
# Criar um workspace
New-AzWvdWorkspace -ResourceGroupName $Name_resource `
                        -Name $Name_hostpool `
                        -Location $Name_Location `
                        -FriendlyName $Name_hostpool `
                        -ApplicationGroupReference $null `
                        -Description 'Description'

#Log
"Criar um workspace;$Name_resource;" + $LogTime | Out-File $LogFile -Append -Force

}
catch
{
    Write-Host $_.Exception.Message -ForegroundColor Yellow
}
#######################################################################################################################################
try
{

Write-Host -BackgroundColor yellow -ForegroundColor Black -Object "Criando Grupo de aplicativos: $Name_Aplication da Azure... "
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

#Log
"Criar um grupo de aplicativos;$Name_resource;" + $LogTime | Out-File $LogFile -Append -Force

}
catch
{
    Write-Host $_.Exception.Message -ForegroundColor Yellow
}

#######################################################################################################################################
try
{
Write-Host -BackgroundColor yellow -ForegroundColor Black -Object "Update Propriedades Hostpool: $Name_hostpool da Azure... "
# Update Propriedades Hostpool
Update-AzWvdHostPool -ResourceGroupName $Name_resource -Name $Name_hostpool -CustomRdpProperty $properties

#Log
"Update Propriedades Hostpool;$Name_resource;" + $LogTime | Out-File $LogFile -Append -Force

Write-Host -BackgroundColor yellow -ForegroundColor Black -Object "Habilitar iniciar VM no Hostpool: $Name_hostpool da Azure... "
# Habilitar iniciar VM
Update-AzWvdHostPool -ResourceGroupName $Name_resource -Name $Name_hostpool -StartVMOnConnect:$true

#Log
"Habilitar iniciar VM;$Name_resource;" + $LogTime | Out-File $LogFile -Append -Force

# Adicionar um grupo de aplicativos a um workspace
#$appGroupPath = (Get-AzWvdApplicationGroup -Name $Name_hostpool -ResourceGroupName $Name_resource).Id
#Update-AzWvdWorkspace -Name $Name_hostpool -ResourceGroupName $Name_resource -ApplicationGroupReference $appGroupPath

}
catch
{
    Write-Host $_.Exception.Message -ForegroundColor Yellow
}


#######################################################################################################################################
try
{

Write-Host -BackgroundColor yellow -ForegroundColor Black -Object "Incluido Grupo: $NameGroup no Hostpool: $Name_hostpool da Azure... "
# Get the object ID of the user group you want to assign to the application group
$userGroupId = (Get-AzADGroup -DisplayName $NameGroup).Id

# Assign the AAD group (Object ID)  to the Application Group

    write-host "Assigning the AAD Group to the Application Group"
    $AssignAADGrpAG = New-AzRoleAssignment -ObjectId $userGroupId `
        -RoleDefinitionName "Desktop Virtualization User" `
        -ResourceName $Name_Aplication `
        -ResourceGroupName $Name_resource `
        -ResourceType 'Microsoft.DesktopVirtualization/applicationGroups' `
        -ErrorAction STOP
#Log
"Adicionar grupo ;$NameGroup;" + $LogTime | Out-File $LogFile -Append -Force

}
catch
{
    Write-Host $_.Exception.Message -ForegroundColor Yellow
}

#######################################################################################################################################
try
{
Write-Host -BackgroundColor yellow -ForegroundColor Black -Object "Gerar Token no Hostpool: $Name_hostpool da Azure... "
# Gerar token do Hostpool
$parameters = @{
    HostPoolName = $Name_hostpool
    ResourceGroupName = $Name_resource
    ExpirationTime = $((Get-Date).ToUniversalTime().AddHours(24).ToString('yyyy-MM-ddTHH:mm:ss.fffffffZ'))
}

New-AzWvdRegistrationInfo @parameters

#Log
"Gerar token do Hostpool;$Name_resource;" + $LogTime | Out-File $LogFile -Append -Force

}
catch
{
    Write-Host $_.Exception.Message -ForegroundColor Yellow
}
#remover Role
#Remove-AzRoleAssignment -SignInName $userGroupId `
#-RoleDefinitionName "Desktop Virtualization User"  
