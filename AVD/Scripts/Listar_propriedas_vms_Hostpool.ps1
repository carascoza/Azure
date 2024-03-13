@"
===============================================================================
                    SCRIPT
Title:         LISTAR PROPRIEDADES VMS HOSTPOOLS
Description:   LISTAR PROPRIEDADES VMS HOSTPOOLS
Usage:         .\Listar_propriedas_vms_Hostpool.ps1
version:       V1.0
Date_create:   02/02/2024
Date_modified: 13/03/2024
===============================================================================
"@

#variaveis
$LogTime = Get-Date -Format "dd-MM-yyyy;hh:mm:ss"
$Time = Get-Date -Format "MM-dd-yyyy"
$LogFile  = "<caminho>\Logs\criar_hostpool_" + $Time + ".log"
$session_pro = $null

Try
{ 


#conectar na azure tenant nome_empresa
"Conctar na azure;" + $LogTime | Out-File $LogFile -Append -Force
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


#Get API
$subscriptionId = "<id_subscription>"
$hostpoolName = Get-AzResource -ResourceType "Microsoft.DesktopVirtualization/hostpools"
#$hostpoolResourceGroup = (Get-AzResource -ResourceType "Microsoft.DesktopVirtualization/hostpools" | Where-Object {$_.ResourceGroupName -eq $hostpoolName}).ResourceGroupName 


foreach ($hostpool in  $hostpoolName){

$hostpool.Name
$hostpool.ResourceGroupName

#Listar Propriedades das estações hostpool

$SessionHostUrl = https://management.azure.com/subscriptions/{0}/resourceGroups/{1}/providers/Microsoft.DesktopVirtualization/hostPools/{2}/sessionHosts?api-version=2022-02-10-preview -f $subscriptionId, $hostpool.ResourceGroupName, $hostpool.Name 
$parameters = @{
    uri     = $SessionHostUrl
    Method  = "GET"
    Headers = $token
}
$sessionHost = Invoke-RestMethod @parameters

#Listar Pool e estação
#$sessionHost.value.name
#Listar Informações de usuário agente e tempo de comunicação



$session_pro+= @($sessionHost.value.properties | Select-Object -Property allowNewSession,assignedUser,sessions,status,agentVersion,resourceId,lastHeartBeat,statusTimestamp,lastUpdateTime)


}


$session_pro | Export-Csv -Path c:\temp\hostpools.csv -NoTypeInformation
