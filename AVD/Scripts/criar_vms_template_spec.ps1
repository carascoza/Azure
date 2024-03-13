@"
===============================================================================
                    SCRIPT
Title:         CRIAR VMS TEMPLATE SPEC
Description:   CRIAR VMS TEMPLATE SPEC
Usage:         .\criar_vms_template_spec.ps1
version:       V2.0
Date_create:   02/02/2024
Date_modified: 13/03/2024
links: https://github.com/Azure/RDS-Templates/tree/master/wvd-templates/Create%20and%20provision%20WVD%20host%20pool

===============================================================================
"@

#variaveis
$LogTime = Get-Date -Format "dd-MM-yyyy;hh:mm:ss"
$Time = Get-Date -Format "MM-dd-yyyy"
$LogFile  = "<caminho>\Logs\criar_vms_template_spec_" + $Time + ".log"
$subscriptionId = "<name_subscription>"
$administratorAccountPassword = ConvertTo-SecureString "<senha_adm_join>" -AsPlainText -Force
$vmAdministratorAccountPassword = ConvertTo-SecureString "<senha_adm_local>" -AsPlainText -Force 
$vmNumberOfInstances = $null
$valorinicial = $null
$valorinicialTotal = $null
$hostpoolName = $null
$listar_pool = $null
$hostpool_Namevalor = $null
$vmNumberOfInstances_Namevalor = $null
$hostpoolToken = $null
$Secure_String_Token = $null
$hostpoolResourceGroup = $null
$sessionHost = $null

#######################################################################################################################################

#Não Alterar
$resource_template = "<resource_group_templates>"
# Vers�o do Template (alterar se necessario nova vers�o)
$Template_Version = "1.0"

#######################################################################################################################################

#Inicio Codigo

#Cria arquivo log
"Titulo;Data;Hora" | Out-File $LogFile -Append -Force
"Inicio;" + $LogTime | Out-File $LogFile -Append -Force

Try
{ 
#conectar na azure tenant nome_empresa
"Conctar na azure;" + $LogTime | Out-File $LogFile -Append -Force
Disconnect-AzAccount
Connect-AzAccount
#Set-AzContext -Subscription $subscriptionId
#Login na azure modulo az
#az login
}

Catch{

$ErrorMessage = $_.Exception.Message
    "Error Concetar na azure;" +$ErrorMessage | Out-File $LogFile -Append -Force
   Write-Host -BackgroundColor red -ForegroundColor Black -Object $ErrorMessage
   exit
}

cls

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

while ($hostpool_Namevalor -eq $null ){
$hostpoolName  = Read-Host "

============================= Script SUPORTE-VDI =============================

Digite o Hostpool

Valor: 
==============================================================================
"  
$listar_pool = Get-AzResource -ResourceType Microsoft.DesktopVirtualization/hostpools | Where-Object {$_.Name -eq $hostpoolName}
if ($hostpoolName -eq $listar_pool.Name){
$hostpool_Namevalor = 1
cls
Write-Host -BackgroundColor Green -ForegroundColor Black -Object "Hostpool: $hostpoolName existe "

}else {
Write-Host -BackgroundColor yellow -ForegroundColor Black -Object "Hostpool: $hostpoolName n�o existe "
$hostpoolName = $null
$hostpool_Namevalor = $null
}

}

while ($vmNumberOfInstances_Namevalor -eq $null ){
$vmNumberOfInstances  = Read-Host "

============================= Script SUPORTE-VDI =============================

Digite a quantidade de vms a serem criadas

Valor: 
==============================================================================
"  
if ($vmNumberOfInstances -eq $null){

}else {
$vmNumberOfInstances_Namevalor = 1
}

}


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


# Listar HostPools
$hostpoolResourceGroup = (Get-AzResource -ResourceType "Microsoft.DesktopVirtualization/hostpools" | Where-Object {$_.ResourceGroupName -eq $hostpoolName}).ResourceGroupName 

$Tag_hostpool = Get-AzResource -ResourceType "Microsoft.DesktopVirtualization/hostpools" | Where-Object {$_.ResourceGroupName -eq $hostpoolName}

# Nome Template Spec
$Template_spec_hostpool = $Tag_hostpool.Tags.template_avd

#Consultar token HostPool
$hostpoolToken = Get-AzWvdRegistrationInfo -HostPoolName $hostpoolName -ResourceGroupName $hostpoolResourceGroup

# Consultar propriedades HostPool
$Get_hostpool = Get-AzWvdHostPool -Name $hostpoolName -ResourceGroupName $hostpoolResourceGroup
# Converter para json extrar propriedades do HostPool namePrefix
$Out_namePrefix = $Get_hostpool.VMTemplate | Out-String | ConvertFrom-Json

# ResourceGroup VMs
$vmResourceGroup = $hostpoolResourceGroup

# Listar Versões do template Spec
  $id = (Get-AzTemplateSpec -Name $Template_spec_hostpool -ResourceGroupName $resource_template -Version $Template_Version).Versions.Id

# Validar Token HostPool
if ($hostpoolToken.Token -eq $null ){

#######################################################################################################################################
try
{
Write-Host -BackgroundColor yellow -ForegroundColor Black -Object "Gerar Token no Hostpool: $Name_hostpool da Azure... "
# Gerar token do Hostpool
$parameters = @{
    HostPoolName = $hostpoolName
    ResourceGroupName = $hostpoolResourceGroup
    ExpirationTime = $((Get-Date).ToUniversalTime().AddHours(24).ToString('yyyy-MM-ddTHH:mm:ss.fffffffZ'))
}

New-AzWvdRegistrationInfo @parameters

#Consultar token HostPool
$hostpoolToken = Get-AzWvdRegistrationInfo -HostPoolName $hostpoolName -ResourceGroupName $hostpoolResourceGroup

$Secure_String_Token = ConvertTo-SecureString $hostpoolToken.Token -AsPlainText -Force


}
catch
{
    Write-Host $_.Exception.Message -ForegroundColor Yellow
}

}
else{

$Secure_String_Token = ConvertTo-SecureString $hostpoolToken.Token -AsPlainText -Force

}

# Verificar valor inicial da esta��o virtual do HostPool
$SessionHostUrl = https://management.azure.com/subscriptions/{0}/resourceGroups/{1}/providers/Microsoft.DesktopVirtualization/hostPools/{2}/sessionHosts?api-version=2022-02-10-preview -f $subscriptionId, $hostpoolResourceGroup, $hostpoolName
$parameters = @{
    uri     = $SessionHostUrl
    Method  = "GET"
    Headers = $token
}
$sessionHost = Invoke-RestMethod @parameters



if ($sessionHost.value.name -eq $null) {

$valorinicialTotal = 0
$NameVM = "N�o existe Esta��o"

}else {

    # String de vms
    $valorinicial = $sessionHost.value.name| ForEach { $_.Substring($_.LastIndexOf('-') + 1)}
    $valorinicial1 = $valorinicial | ConvertFrom-String -Delimiter "nome_empresa.com.br" 
    $valorinicialTotal= ($valorinicial1.p1 | Measure-Object -Maximum).Maximum
    $valorinicialTotal = $valorinicialTotal + 1
    $NameVM = $Out_namePrefix.namePrefix + "-" + ($valorinicialTotal - 1)

}

cls
Write-Host -Object "

============================= Script SUPORTE-VDI =============================

Dados da Cria��o da Esta��o Virtual do HostPool

"  
Write-Host -Object "Nome HostPool: $hostpoolName "
Write-Host -Object "Template Base: $Template_spec_hostpool "
Write-Host -Object "Nome da ultima Esta��o: $NameVM  "
Write-Host -Object "Numero inicial : $valorinicialTotal "
Write-Host -Object "Total Esta��es a serem criadas : $vmNumberOfInstances "
Write-Host -Object "
==============================================================================

"
Pause


try
{
$caminho_url_deploy = https://portal.azure.com/#@banconome_empresa.onmicrosoft.com/resource/subscriptions/3a5617ad-b0be-4fca-a661-14e72e92ce2e/resourceGroups/ + $hostpoolName + "/deployments"

Write-Host -Object "

============================= Script SUPORTE-VDI =============================

Para acompanhar o Deploy acesse a URL abaixo: 
OBS: No caso de erro no powershell o Deploy Continua na Azure
"
Write-Host -BackgroundColor Green -ForegroundColor Black -Object $caminho_url_deploy 
Write-Host -Object "
==============================================================================

"

# Deploy do template Spec com paramentos
  New-AzResourceGroupDeployment `
    -ResourceGroupName $hostpoolResourceGroup `
    -TemplateSpecId $id `
    -hostpoolToken $Secure_String_Token `
    -hostpoolName $hostpoolName `
    -hostpoolResourceGroup $hostpoolResourceGroup `
    -vmResourceGroup $vmResourceGroup `
    -vmNamePrefix $Out_namePrefix.namePrefix `
    -administratorAccountPassword $administratorAccountPassword `
    -vmAdministratorAccountPassword $vmAdministratorAccountPassword `
    -vmInitialNumber $valorinicialTotal `
    -vmNumberOfInstances $vmNumberOfInstances

}
catch
{
    Write-Host $_.Exception.Message -ForegroundColor Yellow
}

# Final Codigo    
