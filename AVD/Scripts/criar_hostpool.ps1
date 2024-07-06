@"
===============================================================================
                    SCRIPT
Title:         CRIAR HOSTPOOL AVD
Description:   CRIAR HOSTPOOL AVD
Usage:         .\CRIAR_HOSTPOOL.ps1
version:       V2.0
Date_create:   23/01/2024
Date_modified: 13/03/2024
links: https://learn.microsoft.com/pt-br/azure/virtual-desktop/deploy-azure-virtual-desktop?tabs=powershell
Links: https://learn.microsoft.com/pt-br/powershell/module/az.desktopvirtualization/new-azwvdapplicationgroup?view=azps-11.2.0
Links: https://askaresh.com/2022/12/13/azure-virtual-desktop-powershell-create-a-host-pool-application-group-and-workspace-for-remoteapp-aka-published-applications/
===============================================================================

"@

#variaveis
$LogTime = Get-Date -Format "dd-MM-yyyy;hh:mm:ss"
$Time = Get-Date -Format "MM-dd-yyyy"
$LogFile = "<caminho>\criar_hostpool_" + $Time + ".log"
$LogFile_error = "<caminho>\Logs\error_" + $Time + ".log"
$File_TemplateFile = "<caminho>\ARM-Templates\"
$vmNumberOfInstances = $null
$NameDeploy = "AVDDeployment_" + $hostpoolName

#######################################################################################################################################
# Alterar 
# Nome Hostpool Alterar

$Name_hostpool = '<Hostpool>'

# Tipo 'Pooled' (Multisession), Tipo 'Personal'' (dedicado), ""Alterar se necessario Padr�o Personal""
$Name_HostPoolType = 'Personal'

# Tipo 'BreadthFirst' ou 'DepthFirst' (Multisession), Tipo 'Persistent' (dedicado), ""Alterar se necessario Padr�o Persistent""
$Name_LoadBalancerType = 'Persistent'

# Grupo do AD que deve ter acesso Alterar para grupo da solicita��o
$NameGroup = '<name_group>'

# Template do Hostpool 
$Template_spec_hostpool = "<Name_template>"

# Prefix de criação da estação (Nome usado como base no hostpool)
$vmNamePrefix = "<name_vm>"

# Quantidade de estações a serem criadas
$vmNumberOfInstances = 1

# Tag centro de custo
$tags_avd_centro_de_custo = "<tag>"

# tag Sigla avd
$tags_avd_sigla_avd = "<tag>"

# tag projeto avd
$tags_avd_projeto_avd = "<tag>"

# Tag avd empresa
$tags_avd_empresa_avd = "<tag>"

$tags_departamento = "<tag>"


#######################################################################################################################################
#Nao Alterar

# Nome Resource Group Alterar
$Name_resource = $Name_hostpool

# Nome Localiza��o N�o Alterar
$Name_Location = 'eastus'

# Nome Aplication N�o Alterar
$Name_Aplication = $Name_hostpool + "-DAG"

# Propriedades Hostpool N�o Alterar
$properties = "drivestoredirect:s:;audiomode:i:0;videoplaybackmode:i:1;redirectclipboard:i:0;redirectprinters:i:0;devicestoredirect:s:*;redirectcomports:i:0;redirectsmartcards:i:0;usbdevicestoredirect:s:;enablecredsspsupport:i:1;redirectwebauthn:i:1;autoreconnection enabled:i:0;audiocapturemode:i:1;camerastoredirect:s:*"

# valor inicial
$vmInitialNumber = 0

# template hostpool nome
$File_TemplateFile = $File_TemplateFile + $Template_spec_hostpool + ".json"

# Tags Alterar as tags "departamento", "centro_de_custo", ("empresa" = nome_empresa ou nome_empresa)
$tags_avd = @{
    "ambiente"            = "<tag>"; `
        "departamento"    = $tags_departamento; `
        "empresa"         = "<tag>"; `
        "gerenciamento"   = "portal_azure"; `
        "centro_de_custo" = $tags_avd_centro_de_custo; `
        "sigla_avd"       = $tags_avd_sigla_avd; `
        "projeto_avd"     = $tags_avd_projeto_avd; `
        "empresa_avd"     = $tags_avd_empresa_avd; 
}

$administratorAccountPassword = "<senha_adm_join>"
$vmAdministratorAccountPassword = "<senha_adm_local>"

#######################################################################################################################################

cls
Write-Host -Object "

============================= Script SUPORTE-VDI =============================

Dados da Cria��o da Esta��o Virtual do HostPool

"  
Write-Host -Object "Nome HostPool: $Name_hostpool "
Write-Host -Object "Tipo do hostpool : $Name_HostPoolType "
Write-Host -Object "Tipo do Balanceamento hostpool : $Name_LoadBalancerType "
Write-Host -Object "Template Base: $Template_spec_hostpool "
Write-Host -Object "Nomenclatura vms: $vmNamePrefix  "
Write-Host -Object "Total Estacoes a serem criadas : $vmNumberOfInstances "
Write-Host -Object "Grupo de acesso : $NameGroup "
Write-Host -Object "
==============================================================================

"
Pause

#Cria arquivo log
"Titulo;Data;Hora" | Out-File $LogFile -Append -Force
"Inicio;" + $LogTime | Out-File $LogFile -Append -Force

Try { 


    #conectar na azure tenant nome_empresa
    "Conctar na azure;" + $LogTime | Out-File $LogFile -Append -Force
    Connect-AzAccount
    #Set-AzContext -Subscription $subscriptionId

}

Catch {

    $ErrorMessage = $_.Exception.Message
    "Error Concetar na azure;" + $ErrorMessage | Out-File $LogFile -Append -Force
    Write-Host -BackgroundColor red -ForegroundColor Black -Object $ErrorMessage
    exit
}


Try { 

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

Catch {

    $ErrorMessage = $_.Exception.Message
    "Error manter conectado na azure;" + $ErrorMessage | Out-File $LogFile -Append -Force
    Write-Host -BackgroundColor red -ForegroundColor Black -Object $ErrorMessage
    exit
}


try {
    Write-Host -BackgroundColor yellow -ForegroundColor Black -Object "Criando Resource Group: $Name_resource da Azure... "
    #Criar resource Group
    New-AzResourceGroup -Name $Name_resource -Location $Name_Location -Tag $tags_avd
    #Log
    "Criar resource Group;$Name_resource;" + $LogTime | Out-File $LogFile -Append -Force

}
catch {
    $ErrorMessage = $_.Exception.Message
    "Error_Criar resource Group;$Name_resource;" + $LogTime | Out-File $LogFile_error -Append -Force
    Write-Host -BackgroundColor red -ForegroundColor Black -Object $ErrorMessage
}
#######################################################################################################################################

try {
    Write-Host -BackgroundColor yellow -ForegroundColor Black -Object "Criando HostPool: $Name_hostpool da Azure... "
    # Criar um pool de host
    $parameters = @{
        Name                          = $Name_hostpool
        ResourceGroupName             = $Name_resource
        HostPoolType                  = $Name_HostPoolType
        LoadBalancerType              = $Name_LoadBalancerType
        PreferredAppGroupType         = 'Desktop'
        PersonalDesktopAssignmentType = 'Automatic'
        Location                      = $Name_Location
        Tag                           = $tags_avd
    }

    New-AzWvdHostPool @parameters
    #Log
    "Criar um pool de host;$Name_resource;" + $LogTime | Out-File $LogFile -Append -Force
}
catch {
    Write-Host $_.Exception.Message -ForegroundColor Yellow
}
#######################################################################################################################################
try {
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
catch {
    Write-Host $_.Exception.Message -ForegroundColor Yellow
}
#######################################################################################################################################
try {

    Write-Host -BackgroundColor yellow -ForegroundColor Black -Object "Criando Grupo de aplicativos: $Name_Aplication da Azure... "
    # Criar um grupo de aplicativos
    $hostPoolArmPath = (Get-AzWvdHostPool -Name $Name_hostpool -ResourceGroupName $Name_resource).Id

    $parameters = @{
        Name                 = $Name_Aplication
        ResourceGroupName    = $Name_resource
        ApplicationGroupType = 'Desktop'
        HostPoolArmPath      = $hostPoolArmPath
        Location             = $Name_Location
    }

    New-AzWvdApplicationGroup @parameters

    #Log
    "Criar um grupo de aplicativos;$Name_resource;" + $LogTime | Out-File $LogFile -Append -Force

}
catch {
    Write-Host $_.Exception.Message -ForegroundColor Yellow
}

#######################################################################################################################################

try {

    Write-Host -BackgroundColor yellow -ForegroundColor Black -Object "Adicionar grupo de aplicativos desktop: $Name_Aplication da Azure... "
    # Criar um grupo de aplicativos

    # Listar grupo de aplicativos Desktop workspace
    $appGroupPath = (Get-AzWvdApplicationGroup -Name $Name_Aplication -ResourceGroupName $Name_resource).Id

    # Adicionar grupo de aplicativo Desktop ao workspace
    Update-AzWvdWorkspace -Name $Name_hostpool -ResourceGroupName $Name_resource -ApplicationGroupReference $appGroupPath


    #Log
    "Adicionar grupo de aplicativos desktop;$Name_resource;" + $LogTime | Out-File $LogFile -Append -Force

}
catch {
    Write-Host $_.Exception.Message -ForegroundColor Yellow
}

try {
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
catch {
    Write-Host $_.Exception.Message -ForegroundColor Yellow
}


#######################################################################################################################################
try {

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
catch {
    Write-Host $_.Exception.Message -ForegroundColor Yellow
}

#######################################################################################################################################
try {
    Write-Host -BackgroundColor yellow -ForegroundColor Black -Object "Gerar Token no Hostpool: $Name_hostpool da Azure... "
    # Gerar token do Hostpool
    $parameters = @{
        HostPoolName      = $Name_hostpool
        ResourceGroupName = $Name_resource
        ExpirationTime    = $((Get-Date).ToUniversalTime().AddHours(24).ToString('yyyy-MM-ddTHH:mm:ss.fffffffZ'))
    }

    New-AzWvdRegistrationInfo @parameters
}
catch {
    Write-Host $_.Exception.Message -ForegroundColor Yellow
}
#Log
"Gerar token do Hostpool;$Name_resource;" + $LogTime | Out-File $LogFile -Append -Force


#Consultar token HostPool
$hostpoolToken = Get-AzWvdRegistrationInfo -HostPoolName $Name_hostpool -ResourceGroupName $Name_resource

$Secure_String_Token = ConvertTo-SecureString $hostpoolToken.Token -AsPlainText -Force

# Formato de hora token
$ExpirationTime = $((get-date).ToUniversalTime().AddDays(1).ToString('yyyy-MM-ddTHH:mm:ss.fffffffZ'))
#Write-Host "$("##vso[task.setvariable variable=ExpirationTime]")$($ExpirationTime)"

#Log
#"Gerar token do Hostpool;$Name_resource;" + $LogTime | Out-File $LogFile -Append -Force

$params = @{
    hostpoolName                   = $Name_hostpool
    vmResourceGroup                = $Name_resource
    vmNamePrefix                   = $vmNamePrefix
    vmInitialNumber                = $vmInitialNumber 
    vmNumberOfInstances            = $vmNumberOfInstances
    administratorAccountPassword   = $administratorAccountPassword
    vmAdministratorAccountPassword = $vmAdministratorAccountPassword
    hostpoolToken                  = $hostpoolToken.Token

}

New-AzResourceGroupDeployment `
    -Name $NameDeploy `
    -ResourceGroupName $Name_resource `
    -TemplateFile $File_TemplateFile `
    -TemplateParameterObject $params -Verbose
