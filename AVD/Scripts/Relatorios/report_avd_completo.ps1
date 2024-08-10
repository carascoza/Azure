@"
===============================================================================
                    SUPORTE-VDI
Title:         RELATORIO_AVD
Description:   RELATORIO ESTAÇÕES VIRTUAIS AVD
Usage:         .\relatorio_avd_completo.ps1
version:       V3.0
Date_create:   18/09/2023
Date_modified: 13/03/2024
===============================================================================
"@

#variaveis
$LogTime = Get-Date -Format "dd-MM-yyyy;hh:mm:ss"
$Time = Get-Date -Format "MM-dd-yyyy"
$timePasta = Get-Date -format "yyyy"
#arquivos logs
$LogFile  = "<caminho>\logs\avd_" + $Time + ".log"
$ExportFilePath ="<caminho>"
#Listar pastas e arquivos dos logs para mover em historico ano
$Get_Report_csv = Get-Item -Path $ExportFilePath
$Get_drivers =  Get-ChildItem -Path "<caminho>"
#arquivos csv 
$LogFile  = "<caminho>\logs\avd_" + $Time + ".log"
$ExportFilePath ="<caminho>"
$avd_hostpool = $ExportFilePath + "report_avd_hostpool.csv"
$avd_aplication_group = $ExportFilePath + "report_avd_aplication_group.csv"
$avd_vms = $ExportFilePath + "report_avd.csv"
$avd_vms_size = $ExportFilePath + "report_avd_size.csv"
$users_session_avd = $ExportFilePath + "users_session_avd.csv"
$report_avd_vm_create = $ExportFilePath + "report_avd_vm_create.csv"
$report_avd_client = $ExportFilePath + "report_avd_client.csv"
$session_ativa = $ExportFilePath + "session_ativa_avd.csv"
$session_users_30d = $ExportFilePath + "session_users_30d_avd.csv"
$report_subnets_avd = $ExportFilePath + "report_subnets_avd_.csv"
$report_grupos_avd = $ExportFilePath + "report_grupos_avd.csv"
$report_avd_total_vms = $ExportFilePath + "report_avd_total_vms.csv"

#Cria arquivo log
"Titulo;Data;Hora" | Out-File $LogFile -Append -Force
"Inicio;" + $LogTime | Out-File $LogFile -Append -Force

Try
{ 

#conectar na azure tenant nome_empresa
"Conctar na azure;" + $LogTime | Out-File $LogFile -Append -Force
Connect-AzAccount
Set-AzContext -Subscription "<id_subscription>"
}

Catch{

$ErrorMessage = $_.Exception.Message
    "Error Concetar na azure;" +$ErrorMessage | Out-File $LogFile -Append -Force
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

###########################################################################################################################################################################################

#listar e mover arquivos relatorios

Write-Host -BackgroundColor yellow -ForegroundColor Black -Object "Movendo arquivos antigos para pasta $timePasta ... " 
  cd "<id_subscription>"

  #Arquivo report_avd_hostpool.csv copy
   if($Get_drivers.Name -eq "report_avd_hostpool.csv"){

   $Arquivo_Report_avd= $Get_drivers | Where-Object {$_.Name -eq "report_avd_hostpool.csv" }  | Select Name, @{Name="LastWriteTime"; Expression={$_.LastWriteTime.ToString("dd-MM-yyyy")}}
  
  $Data_arquivo1= "report_avd_hostpool_" + $Arquivo_Report_avd.LastWriteTime + ".csv"
  $Destino_copy = ".\" + $timePasta + "\" + $Data_arquivo1 

  Copy-Item -Path "report_avd_hostpool.csv" -Destination $Destino_copy -Force

  Remove-Item report_avd_hostpool.csv
  Write-Host -BackgroundColor Green -ForegroundColor Black -Object "Arquivo movido " 
}
else {
Write-Host -BackgroundColor Red -ForegroundColor Black -Object "Arquivo: report_avd_hostpool não encontrado "
}

###########################################################################################################################################################################################

#Mover arquivo report_avd_aplication_group.csv

Write-Host -BackgroundColor yellow -ForegroundColor Black -Object "Movendo arquivos antigos para pasta $timePasta ... " 
  cd "<id_subscription>"

  #Arquivo report_avd_hostpool.csv copy
   if($Get_drivers.Name -eq "report_avd_aplication_group.csv"){

   $Arquivo_Report_avd= $Get_drivers | Where-Object {$_.Name -eq "report_avd_aplication_group.csv" }  | Select Name, @{Name="LastWriteTime"; Expression={$_.LastWriteTime.ToString("dd-MM-yyyy")}}
  
  $Data_arquivo1= "report_avd_aplication_group_" + $Arquivo_Report_avd.LastWriteTime + ".csv"
  $Destino_copy = ".\" + $timePasta + "\" + $Data_arquivo1 

  Copy-Item -Path "report_avd_aplication_group.csv" -Destination $Destino_copy -Force

  Remove-Item report_avd_aplication_group.csv
  Write-Host -BackgroundColor Green -ForegroundColor Black -Object "Arquivo movido " 
}
else {
Write-Host -BackgroundColor Red -ForegroundColor Black -Object "Arquivo: report_avd_aplication_group não encontrado "
}

###########################################################################################################################################################################################

  #Arquivo report_avd.csv copy
   if($Get_drivers.Name -eq "report_avd.csv"){

   $Arquivo_Report_avd= $Get_drivers | Where-Object {$_.Name -eq "report_avd.csv" }  | Select Name, @{Name="LastWriteTime"; Expression={$_.LastWriteTime.ToString("dd-MM-yyyy")}}
  
  $Data_arquivo1= "report_avd_" + $Arquivo_Report_avd.LastWriteTime + ".csv"
  #$Destino_copy = ".\2019\$Data_arquivo1" 
  $Destino_copy = ".\" + $timePasta + "\" + $Data_arquivo1 

  Copy-Item -Path "report_avd.csv" -Destination $Destino_copy -Force

  Remove-Item report_avd.csv
  Write-Host -BackgroundColor Green -ForegroundColor Black -Object "Arquivo movido " 
}
else {
Write-Host -BackgroundColor Red -ForegroundColor Black -Object "Arquivo: report_avd.csv não encontrado "
}

###########################################################################################################################################################################################

  #Arquivo users_session_avd.csv copy
   if($Get_drivers.Name -eq "users_session_avd.csv"){

   $Arquivo_Report_avd= $Get_drivers | Where-Object {$_.Name -eq "users_session_avd.csv" }  | Select Name, @{Name="LastWriteTime"; Expression={$_.LastWriteTime.ToString("dd-MM-yyyy")}}
  
  $Data_arquivo1= "users_session_avd_" + $Arquivo_Report_avd.LastWriteTime + ".csv"
  #$Destino_copy = ".\2019\$Data_arquivo1" 
  $Destino_copy = ".\" + $timePasta + "\" + $Data_arquivo1 

  Copy-Item -Path "users_session_avd.csv" -Destination $Destino_copy -Force

  Remove-Item users_session_avd.csv
  Write-Host -BackgroundColor Green -ForegroundColor Black -Object "Arquivo movido " 
}
else {
Write-Host -BackgroundColor Red -ForegroundColor Black -Object "Arquivo: users_session_avd.csv não encontrado "
}

###########################################################################################################################################################################################

  #Arquivo report_avd_vm_create.csv copy
   if($Get_drivers.Name -eq "report_avd_vm_create.csv"){

   $Arquivo_Report_avd= $Get_drivers | Where-Object {$_.Name -eq "report_avd_vm_create.csv" }  | Select Name, @{Name="LastWriteTime"; Expression={$_.LastWriteTime.ToString("dd-MM-yyyy")}}
  
  $Data_arquivo1= "report_avd_vm_create_" + $Arquivo_Report_avd.LastWriteTime + ".csv"
  #$Destino_copy = ".\2019\$Data_arquivo1" 
  $Destino_copy = ".\" + $timePasta + "\" + $Data_arquivo1 

  Copy-Item -Path "report_avd_vm_create.csv" -Destination $Destino_copy -Force

  Remove-Item report_avd_vm_create.csv
  Write-Host -BackgroundColor Green -ForegroundColor Black -Object "Arquivo movido "
}
else {
Write-Host -BackgroundColor Red -ForegroundColor Black -Object "Arquivo: report_avd_vm_create.csv não encontrado "
}

###########################################################################################################################################################################################

  #Arquivo report_avd_client.csv copy
   if($Get_drivers.Name -eq "report_avd_client.csv"){

   $Arquivo_Report_avd= $Get_drivers | Where-Object {$_.Name -eq "report_avd_client.csv" }  | Select Name, @{Name="LastWriteTime"; Expression={$_.LastWriteTime.ToString("dd-MM-yyyy")}}
  
  $Data_arquivo1= "report_avd_client_" + $Arquivo_Report_avd.LastWriteTime + ".csv"
  #$Destino_copy = ".\2019\$Data_arquivo1" 
  $Destino_copy = ".\" + $timePasta + "\" + $Data_arquivo1 

  Copy-Item -Path "report_avd_client.csv" -Destination $Destino_copy -Force

  Remove-Item report_avd_client.csv
  Write-Host -BackgroundColor Green -ForegroundColor Black -Object "Arquivo movido "
}
else {
Write-Host -BackgroundColor Red -ForegroundColor Black -Object "Arquivo: report_avd_client.csv não encontrado "
}

###########################################################################################################################################################################################

  #Arquivo session_ativa_avd.csv copy
   if($Get_drivers.Name -eq "session_ativa_avd.csv"){

   $Arquivo_Report_avd= $Get_drivers | Where-Object {$_.Name -eq "session_ativa_avd.csv" }  | Select Name, @{Name="LastWriteTime"; Expression={$_.LastWriteTime.ToString("dd-MM-yyyy")}}
  
  $Data_arquivo1= "session_ativa_avd_" + $Arquivo_Report_avd.LastWriteTime + ".csv"
  #$Destino_copy = ".\2019\$Data_arquivo1" 
  $Destino_copy = ".\" + $timePasta + "\" + $Data_arquivo1 

  Copy-Item -Path "session_ativa_avd.csv" -Destination $Destino_copy -Force

  Remove-Item session_ativa_avd.csv
  Write-Host -BackgroundColor Green -ForegroundColor Black -Object "Arquivo movido "
}
else {
Write-Host -BackgroundColor Red -ForegroundColor Black -Object "Arquivo: session_ativa_avd.csv não encontrado "
}

###########################################################################################################################################################################################

 #Arquivo report_subnets_avd_.csv copy
   if($Get_drivers.Name -eq "report_subnets_avd_.csv"){

   $Arquivo_Report_avd= $Get_drivers | Where-Object {$_.Name -eq "report_subnets_avd_.csv" }  | Select Name, @{Name="LastWriteTime"; Expression={$_.LastWriteTime.ToString("dd-MM-yyyy")}}
  
  $Data_arquivo1= "report_subnets_avd_" + $Arquivo_Report_avd.LastWriteTime + ".csv"
  #$Destino_copy = ".\2019\$Data_arquivo1" 
  $Destino_copy = ".\" + $timePasta + "\" + $Data_arquivo1 

  Copy-Item -Path "report_subnets_avd_.csv" -Destination $Destino_copy -Force

  Remove-Item report_subnets_avd_.csv
  Write-Host -BackgroundColor Green -ForegroundColor Black -Object "Arquivo movido "
}
else {
Write-Host -BackgroundColor Red -ForegroundColor Black -Object "Arquivo: report_subnets_avd_.csv não encontrado "
}

###########################################################################################################################################################################################

  #Arquivo report_avd_total_vms.csv copy
  if($Get_drivers.Name -eq "report_avd_total_vms.csv"){

    $Arquivo_Report_avd= $Get_drivers | Where-Object {$_.Name -eq "report_avd_total_vms.csv" }  | Select Name, @{Name="LastWriteTime"; Expression={$_.LastWriteTime.ToString("dd-MM-yyyy")}}
   
   $Data_arquivo1= "report_avd_total_vms_" + $Arquivo_Report_avd.LastWriteTime + ".csv"
   #$Destino_copy = ".\2019\$Data_arquivo1" 
   $Destino_copy = ".\" + $timePasta + "\" + $Data_arquivo1 
 
   Copy-Item -Path "report_avd_total_vms.csv" -Destination $Destino_copy -Force

   Remove-Item report_subnets_avd_.csv
   Write-Host -BackgroundColor Green -ForegroundColor Black -Object "Arquivo movido "
}
else {
Write-Host -BackgroundColor Red -ForegroundColor Black -Object "Arquivo: report_subnets_avd_.csv não encontrado "
}

 ###########################################################################################################################################################################################


  #Arquivo session_users_30d_avd.csv copy
  if($Get_drivers.Name -eq "session_users_30d_avd.csv"){

    $Arquivo_Report_avd= $Get_drivers | Where-Object {$_.Name -eq "session_users_30d_avd.csv" }  | Select Name, @{Name="LastWriteTime"; Expression={$_.LastWriteTime.ToString("dd-MM-yyyy")}}
   
   $Data_arquivo1= "session_users_30d_avd_" + $Arquivo_Report_avd.LastWriteTime + ".csv"
   #$Destino_copy = ".\2019\$Data_arquivo1" 
   $Destino_copy = ".\" + $timePasta + "\" + $Data_arquivo1 
 
   Copy-Item -Path "session_users_30d_avd.csv" -Destination $Destino_copy -Force

   Remove-Item session_users_30d_avd.csv
   Write-Host -BackgroundColor Green -ForegroundColor Black -Object "Arquivo movido "
}
else {
Write-Host -BackgroundColor Red -ForegroundColor Black -Object "Arquivo: session_users_30d_avd.csv não encontrado "
}

 ###########################################################################################################################################################################################

##Listar hostpool

Write-Host -BackgroundColor yellow -ForegroundColor Black -Object "Gerando relatorio hostpool AVD... " 

Get-AzResource -ResourceType "Microsoft.DesktopVirtualization/hostpools" | Select-Object -Property ResourceName, ResourceGroupName, ResourceType | Export-Csv -Path $avd_hostpool -NoTypeInformation

Write-Host -BackgroundColor Green -ForegroundColor Black -Object "Relatorio hostpool gerado " 

#listar aplication groups AVD

Write-Host -BackgroundColor yellow -ForegroundColor Black -Object "Gerando relatorio Aplication Groups AVD... " 

Get-AzResource -ResourceType "Microsoft.DesktopVirtualization/applicationgroups" | Select-Object -Property ResourceName, ResourceGroupName, ResourceType | Export-Csv -Path $avd_aplication_group -NoTypeInformation

Write-Host -BackgroundColor Green -ForegroundColor Black -Object "Relatorio Aplication Groups AVD gerado " 


##listar vms forma 1
Write-Host -BackgroundColor yellow -ForegroundColor Black -Object "Gerando relatorio vms... " 
 
Get-AzResource -ResourceType "Microsoft.Compute/virtualMachines" | Select-Object -Property ResourceName, ResourceGroupName, Type | Export-Csv -Path $avd_vms -NoTypeInformation

Write-Host -BackgroundColor Green -ForegroundColor Black -Object "Relatorio vms gerado " 
##listar vms size 

Get-AzVM -Location "brazilsouth" Select-Object -Property ResourceGroupName, Name, Location, VmSize,OsType, NIC, ProvisioningState | Export-Csv -Path $avd_vms_size -NoTypeInformation

#Listar user logados

Write-Host -BackgroundColor yellow -ForegroundColor Black -Object "Gerando relatorio user logados... " 

$Query_connected = 'WVDConnections | where State contains "Connected"'

$Workspace = Get-AzOperationalInsightsWorkspace 
 
$ResultList_connected  = Invoke-AzOperationalInsightsQuery -WorkspaceId $Workspace.CustomerId -Query $Query_connected  -ErrorAction Stop | select -ExpandProperty Results

$ResultList_connected  | Export-Csv -Path $users_session_avd -NoTypeInformatio

Write-Host -BackgroundColor Green -ForegroundColor Black -Object "Relatorio user logados gerado " 

#Listar estações criadas

Write-Host -BackgroundColor yellow -ForegroundColor Black -Object "Gerando relatorio estações criadas... " 

$Query_vmscreate = 'WVDHostRegistrations 
| where TimeGenerated > ago(30d)'

$Workspace = Get-AzOperationalInsightsWorkspace 
 
$ResultList_vmscreate = Invoke-AzOperationalInsightsQuery -WorkspaceId $Workspace.CustomerId -Query $Query_vmscreate -ErrorAction Stop | select -ExpandProperty Results

$ResultList_vmscreate | Export-Csv -Path $report_avd_vm_create -NoTypeInformatio

Write-Host -BackgroundColor Green -ForegroundColor Black -Object "Relatorio estações criadas gerado 30 dias..." 

#lista user logados 30 dias

Write-Host -BackgroundColor yellow -ForegroundColor Black -Object "Gerando relatorio user logados 30 dias..." 

$Query_client = 'WVDConnections 
| where State contains "Connected" 
| where TimeGenerated > ago(30d)'

$Workspace = Get-AzOperationalInsightsWorkspace 
 
$ResultList_client = Invoke-AzOperationalInsightsQuery -WorkspaceId $Workspace.CustomerId -Query $Query_client  -ErrorAction Stop | select -ExpandProperty Results

$ResultList_vmscreate | Export-Csv -Path $report_avd_client -NoTypeInformatio

Write-Host -BackgroundColor Green -ForegroundColor Black -Object "Relatorio user logados 30 dias gerado " 

#Sessões Ativas por HostPools

Write-Host -BackgroundColor yellow -ForegroundColor Black -Object "Gerando relatorio Sessões Ativas por HostPools... " 

$Query_session_ativa= 'let GranularityInterval = 30m;
WVDAgentHealthStatus
| summarize PeakSessionsByHost=max(toint(ActiveSessions)) by SessionHostName, bin(TimeGenerated, 30s), _ResourceId
| summarize SessionsByHostPool=sum(PeakSessionsByHost) by TimeGenerated, _ResourceId
| summarize max(SessionsByHostPool) by bin(TimeGenerated, GranularityInterval), _ResourceId
| render timechart'

$Workspace = Get-AzOperationalInsightsWorkspace 
 
$ResultList_session_ativa  = Invoke-AzOperationalInsightsQuery -WorkspaceId $Workspace.CustomerId -Query $Query_session_ativa  -ErrorAction Stop | select -ExpandProperty Results

$ResultList_session_ativa | Export-Csv -Path $session_ativa -NoTypeInformatio

Write-Host -BackgroundColor Green -ForegroundColor Black -Object "Relatorio Sessões Ativas por HostPools gerado " 


#Tempo de sessão usuários 30 dias 

Write-Host -BackgroundColor yellow -ForegroundColor Black -Object "Gerando relatorio Tempo de sessão usuários 30 dias... " 

$Query_session_users= 'WVDConnections 
| where State == "Connected"
| where TimeGenerated > ago(30d)  
| project CorrelationId , UserName, ConnectionType , StartTime=TimeGenerated, SessionHostName, _ResourceId
| join kind=inner
(
    WVDConnections  
    | where State == "Completed"  
    | project EndTime=TimeGenerated, CorrelationId
) on CorrelationId  
| project Duration = StartTime, EndTime - StartTime, ConnectionType, UserName, SessionHostName, _ResourceId
| sort by Duration desc'

$Workspace = Get-AzOperationalInsightsWorkspace 
 
$ResultList_session_users  = Invoke-AzOperationalInsightsQuery -WorkspaceId $Workspace.CustomerId -Query $Query_session_users -ErrorAction Stop | select -ExpandProperty Results

$ResultList_session_users | Export-Csv -Path $session_users_30d -NoTypeInformatio

Write-Host -BackgroundColor Green -ForegroundColor Black -Object "Relatorio Tempo de sessão usuários 30 dias gerado "


##Listar subnets

Write-Host -BackgroundColor yellow -ForegroundColor Black -Object "Gerando relatorio Listar subnets... " 


$vn = Get-AzVirtualNetwork -Name vnetprvdibrazilsouth

$vn.Subnets | Select Name, AddressPrefix | Export-Csv -Delimiter ";" -Path $report_subnets_avd -NoTypeInformation

Write-Host -BackgroundColor Green -ForegroundColor Black -Object "Relatorio Listar subnets gerado " 

#gerar Grupos AVD
Get-AzRoleAssignment -RoleDefinitionName "Desktop Virtualization User" | Export-Csv -Path $report_grupos_avd -NoTypeInformation


Write-Host -BackgroundColor yellow -ForegroundColor Black -Object "Gerando Todas as estações do AVD... " 

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

#Listar Informações de usuário agente e tempo de comunicação
$session_pro+= @($sessionHost.value.properties | Select-Object -Property allowNewSession,assignedUser,sessions,status,agentVersion,resourceId,lastHeartBeat,statusTimestamp,lastUpdateTime)
#$session_pro+=$sessionHost.value.properties | Select-Object -Property assignedUser,allowNewSession,sessions,status,agentVersion,resourceId,lastHeartBeat,statusTimestamp,lastUpdateTime

}

$session_pro | Export-Csv -Path $report_avd_total_vms -NoTypeInformation

Write-Host -BackgroundColor Green -ForegroundColor Black -Object "Relatorio todas estações AVD " 

#Variavel data formatada.
$LogTime2 = Get-Date -Format  "dd-MM-yyyy;hh:mm:ss"
"Termino;" + $LogTime2 | Out-File $LogFile -Append -Force

Write-Host -BackgroundColor Green -ForegroundColor Black -Object "Inicio Relatorio $LogTime, Termino relatorio $LogTime2 " 

Pause
