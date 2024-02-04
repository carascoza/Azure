@"
===============================================================================
                    SCRIPT
Title:         CRIAR VMS HOSTPOOL AVD
Description:   CRIAR VMS HOSTPOOL AVD
Usage:         .\criar_vm_host.ps1
version:       V1.0
Date_create:   31/01/2024
Date_modified: 31/01/2024
links: https://github.com/Azure/RDS-Templates/tree/master/wvd-templates/Create%20and%20provision%20WVD%20host%20pool

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
# Nome Hostpool
$hostpoolName = "AVD-EUS2-PRD-T"
# Resource group Hostpool
$hostpoolResourceGroup = "AVD-EUS2-PRD-T"
# Senha Join AD
$administratorAccountPassword = "<password>"
#Senha ADM Local
$vmAdministratorAccountPassword = "<password>"
# Regiao Resource Group
$location = "eastus2"
# Nome Vnet
$existingVnetName = "vnet-prd-US"
# Nome Subnet
$existingSubnetName ="vnet-prd-us"
# Resource Group Vnet
$virtualNetworkResourceGroupName = "vnet-prd"
# Tipo 'Pooled' (Multisession), Tipo 'Personal'' (dedicado), ""Alterar se necessario Padrão Personal""
$hostpoolType = "Personal"
# Tipo "Automatic" para associacao automatica ou "Direct" para associacao manual
$personalDesktopAssignmentType = "Automatic"
# Tipo 'BreadthFirst' ou 'DepthFirst' (Multisession), Tipo 'Persistent' (dedicado), ""Alterar se necessario Padrão Persistent""
$loadBalancerType = "BreadthFirst"
# Caminho OU
$ouPath = "OU=Personal,OU=AVD,OU=Computadores,DC=mac-lab01,DC=ml"
# Total de estacoes criadas (Valor deve conter a soma das ja existentes)
$vmNumberOfInstances = 1
# Nome do prefixo da vm no HostPool
$vmNamePrefix = "vmavd0"
# Size VM Padrao "Standard_B2s"
$vmSize = "Standard_B2s"
# Size Disco VM Padrao "StandardSSD_LRS"
$vmDiskType = "StandardSSD_LRS"

# Formato de hora token
$ExpirationTime = $((get-date).ToUniversalTime().AddDays(1).ToString('yyyy-MM-ddTHH:mm:ss.fffffffZ'))
#Write-Host "$("##vso[task.setvariable variable=ExpirationTime]")$($ExpirationTime)"

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


#conectar na azure tenant
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

# Consultar token HostPool
$hostpoolToken = Get-AzWvdRegistrationInfo -HostPoolName $hostpoolName -ResourceGroupName 
# Consultar propriedades HostPool
$Get_hostpool = Get-AzWvdHostPool -Name $hostpoolName -ResourceGroupName $hostpoolResourceGroup
#$Get_hostpool | Format-List *

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

Consultar token HostPool
$hostpoolToken = Get-AzWvdRegistrationInfo -HostPoolName $hostpoolName -ResourceGroupName $hostpoolResourceGroup

# Formato de hora token
$ExpirationTime = $((get-date).ToUniversalTime().AddDays(1).ToString('yyyy-MM-ddTHH:mm:ss.fffffffZ'))
#Write-Host "$("##vso[task.setvariable variable=ExpirationTime]")$($ExpirationTime)"

#Log
#"Gerar token do Hostpool;$Name_resource;" + $LogTime | Out-File $LogFile -Append -Force

}
catch
{
    Write-Host $_.Exception.Message -ForegroundColor Yellow
}

}
else{

}

$params = @{
   hostpoolName = $hostpoolName
   hostpoolType = $hostpoolType
   personalDesktopAssignmentType = $personalDesktopAssignmentType
   loadBalancerType = $loadBalancerType
   ouPath = $ouPath
   vmResourceGroup = $hostpoolResourceGroup
   vmNamePrefix = $vmNamePrefix
   vmNumberOfInstances = $vmNumberOfInstances
   vmSize = $vmSize
   vmDiskType = $vmDiskType
   administratorAccountPassword = $administratorAccountPassword
   vmAdministratorAccountPassword = $vmAdministratorAccountPassword
   existingVnetName = $existingVnetName
   existingSubnetName = $existingSubnetName
   virtualNetworkResourceGroupName = $virtualNetworkResourceGroupName
   tokenExpirationTime = $ExpirationTime
}

New-AzResourceGroupDeployment `
  -Name AVDDeployment `
  -location $location `
  -ResourceGroupName $hostpoolResourceGroup `
  -TemplateFile "C:\Users\caras\Documents\Cloud\Azure\AVD\template_hostpool\novo\template.json" `
  -TemplateParameterObject $params -Verbose 
 