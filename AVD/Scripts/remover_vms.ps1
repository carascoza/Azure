@"
===============================================================================
                    SCRIPT
Title:         REMOVER VMS AZURE
Description:   REMOVER VMS AZURE
Usage:         .\remover_vms.ps1
version:       V2.0
Date_create:   26/12/2023
Date_modified: 24/01/2023
===============================================================================
"@

Write-Host -BackgroundColor yellow -ForegroundColor Black -Object "Necessario instalado  modulo do AD e Modulo do AZ no powershell!!!"

# Verifica e instalada modulo Az
#if (!(Get-Module -ListAvailable -Name Az.Accounts)) {
#  Install-Module -Name Az -Repository PSGallery -AllowClobber -Force -Scope CurrentUser  
#}


#variaveis
$LogTime = Get-Date -Format "dd-MM-yyyy_hh-mm-ss"
$Time = Get-Date -Format "MM-dd-yyyy"
$LogFile  = "<informar caminho>\remover_vms_" + $Time + ".log"
$ExportFilePath = "<informar caminho>"
$remove_vms = $ExportFilePath + "remover_vms.csv"
$vms_Csv = Import-Csv $remove_vms -Delimiter ';'
$subscript = "<informar>"
$TenantID = "<informar>"
$token_azure = $null
$REStoken_azure = $null

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
     

foreach ($vms in $vms_Csv){
Try
{ 

$vms_vm = $vms.vms
$vms_resource = $vms.resourcegroup
    
#Cria arquivo log
"Inicio: " + $LogTime | Out-File $LogFile -Append -Force

Write-Host -BackgroundColor yellow -ForegroundColor Black -Object "Removendo estacao: $vms_vm do AD onpremise... "

# Remover objeto do AD (link: https://learn.microsoft.com/en-us/powershell/module/activedirectory/remove-adcomputer?view=windowsserver2022-ps)

#verificar estacao no AD
$ad_vm = $null
$ad_vm = Get-ADComputer -Identity $vms_vm
$ad_vm.name

if($ad_vm.name -eq $vms_vm){
    Get-ADComputer -Identity $vms_vm | Remove-ADObject -Recursive -Confirm:$False
    Write-Host -BackgroundColor green -ForegroundColor Black -Object "Estacao: $vms_vm removida do AD onpremise... " 
 }

Write-Host -BackgroundColor yellow -ForegroundColor Black -Object "Removendo estacao: $vms_vm da azrue... "

}

Catch{

$ErrorMessage = $_.Exception.Message
    $vms.vms + ";" +$ErrorMessage | Out-File $LogFile -Append -Force
    Write-Host -BackgroundColor red -ForegroundColor Black -Object $ErrorMessage
}


$avd_vm = $null
$avd_vm = Get-AzVM -ResourceGroupName $ms_resource -Name $vms_vm
$avd_vm.Name


if($avd_vm.Name -eq $vms_vm){

# Update remover disco e rede da estacao virtual em um comando 
$vmConfig = Get-AzVM -ResourceGroupName $ms_resource -Name $vms_vm 
$vmConfig.StorageProfile.OsDisk.DeleteOption = 'Delete' 
$vmConfig.StorageProfile.DataDisks | ForEach-Object { $_.DeleteOption = 'Delete' } 
$vmConfig.NetworkProfile.NetworkInterfaces | ForEach-Object { $_.DeleteOption = 'Delete' } 
$vmConfig | Update-AzVM 

# Remover vm da azure (link: https://learn.microsoft.com/en-us/azure/virtual-machines/delete?tabs=powershell2%2Cpowershell3%2Cpowershell4%2Cpowershell5) 
Remove-AzVm `
    -ResourceGroupName $ms_resource `
    -Name $vms_vm `
    -Confirm:$False 
    Write-Host -BackgroundColor green -ForegroundColor Black -Object "Estacao: $vms_vm removida da azure... " 
 }


}


Try
{ 
# Remover Vm HostPool necessario modulo Install-Module -Name Az.Avd
#link: https://rozemuller.com/move-avd-session-hosts-to-a-new-host-pool-with-rest-api/

function GetAuthToken($resource) {
    $context = [Microsoft.Azure.Commands.Common.Authentication.Abstractions.AzureRmProfileProvider]::Instance.Profile.DefaultContext
    $Token = [Microsoft.Azure.Commands.Common.Authentication.AzureSession]::Instance.AuthenticationFactory.Authenticate($context.Account, $context.Environment, $context.Tenant.Id.ToString(), $null, [Microsoft.Azure.Commands.Common.Authentication.ShowDialog]::Never, $null, $resource).AccessToken
    $authHeader = @{
        'Content-Type' = 'application/json'
        Authorization  = 'Bearer ' + $Token
    }
    return $authHeader
}
$token = GetAuthToken -resource "https://management.azure.com"

$vm_hostpool = $vms_vm + "<informar dominio>"
$ResourceGroupName = $vms_resource
$hostpoolname = $vms_resource
$SessionHostName = $vm_hostpool

$SessionHostUrl = "https://management.azure.com/subscriptions/{0}/resourceGroups/{1}/providers/Microsoft.DesktopVirtualization/hostpools/{2}/sessionHosts/{3}?api-version=2021-03-09-preview" -f $subscriptionId, $ResourceGroupName, $HostpoolName, $SessionHostName
$parameters = @{
    uri     = $SessionHostUrl
    Method  = "DELETE"
    Headers = $token
}
$sessionHost = Invoke-RestMethod @parameters



}

Catch{

$ErrorMessage = $_.Exception.Message
    $vms.vms + ";" +$ErrorMessage | Out-File $LogFile -Append -Force
    Write-Host -BackgroundColor red -ForegroundColor Black -Object $ErrorMessage
}

#Variavel data formatada.
$LogTime2 = Get-Date -Format "MM-dd-yyyy_hh-mm-ss"
"Termino: " + $LogTime2 | Out-File $LogFile -Append -Force 