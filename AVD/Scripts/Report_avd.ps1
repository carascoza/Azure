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