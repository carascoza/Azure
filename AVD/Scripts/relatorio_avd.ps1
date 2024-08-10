@"
===============================================================================
                    SUPORTE-VDI
Title:         RELATORIO_AVD
Description:   RELATORIO ESTAÇÕES VIRTUAIS AVD
Usage:         .\relatorio_avd.ps1
version:       V3.4
Date_create:   18/09/2023
Date_modified: 15/07/2024
===============================================================================
"@

###########################################################################################################################################################################################
#variaveis
$LogTime = Get-Date -Format "dd-MM-yyyy;hh:mm:ss"
$Time = Get-Date -Format "MM-dd-yyyy"
$timePasta = Get-Date -format "yyyy"

#arquivos logs
$LogFile = "<caminho>\Inventario_VDI\AVD\logs\avd_" + $Time + ".log"
$ExportFilePath = "<caminho>\Inventario_VDI\AVD\"

#Listar pastas e arquivos dos logs para mover em historico ano
$Get_Report_csv = Get-Item -Path $ExportFilePath
$Get_drivers = Get-ChildItem -Path "<caminho>\Inventario_VDI\AVD\"

#arquivos csv 
$avd_hostpool = $ExportFilePath + "report_avd_hostpool.csv"
$avd_aplication_group = $ExportFilePath + "report_avd_aplication_group.csv"
$avd_vms = $ExportFilePath + "report_avd.csv"
$avd_vms_size = $ExportFilePath + "report_avd_size.csv"
$users_session_avd = $ExportFilePath + "users_session_avd.csv"
$report_avd_vm_create = $ExportFilePath + "report_avd_vm_create.csv"
$report_avd_client = $ExportFilePath + "report_avd_client.csv"
$session_ativa = $ExportFilePath + "session_ativa_avd.csv"
$session_users_30d = $ExportFilePath + "session_users_30d_avd.csv"
$report_subnets_avd = $ExportFilePath + "report_subnets_avd.csv"
$report_grupos_avd = $ExportFilePath + "report_grupos_avd.csv"
$report_avd_total_vms = $ExportFilePath + "report_avd_total_vms.csv"
$report_ou_avd = $ExportFilePath + "report_ou_avd.csv"
$report_resourcestags_avd = $ExportFilePath + "report_resourcestags_avd.csv"
$report_vmstags_avd = $ExportFilePath + "report_vmstags_avd.csv"
$OU_AVD = 'OU=AVD,OU=Estacoes,OU=Corporativo,OU=Computadores,DC=<dominio>DC=<dominio>,DC=com,DC=br'
$Arquivos = @("report_avd_hostpool", "report_avd_aplication_group", "report_avd", "report_avd_size", "users_session_avd", "report_avd_vm_create", "report_avd_client", "session_ativa_avd", "session_users_30d_avd", "report_subnets_avd", "report_grupos_avd", "report_avd_total_vms",
    "report_ou_avd", "report_resourcestags_avd", "report_vmstags_avd")
$reportFilePath = "<caminho>\#AVD_VDI\"
$relatorio_avd = $reportFilePath + "Empresa_AVD.xlsm"
$reportvmstags = $null
$resourcestags = $null
$resultstags = $null
$reportvmstags = $null
$relatorioI = $null
$ValorRelatorio = $null

###########################################################################################################################################################################################

#Todas as Functions 

# Function (ListarPropResource) para listar Hostpools, vms e aplication groups AVD
function ListarPropResource {
    param (
        [Parameter(Mandatory = $true)]
        [string]$ResourceType,
        [Parameter(Mandatory = $true)]
        $Property,
        [Parameter(Mandatory = $true)]
        [string]$PathCsv,
        [Parameter(Mandatory = $true)]
        [string]$MsgGeral
    )
    PROCESS {
        try {
            Write-Host "´Gerando Relatorio de: $MsgGeral ....!´"
            Get-AzResource -ResourceType $ResourceType | Select-Object -Property $Property | Export-Csv -Path $PathCsv -NoTypeInformation
            Write-Host -BackgroundColor Green -ForegroundColor Black -Object "´Gerado Relatorio de: $MsgGeral ....!´"
            Write-Host "" 
        }
        catch {
            Write-Warning -Message "Erro ao gerar o Relatorio: $MsgGeral"
            Write-Host "" 
        }
    }
}

# Function (ListarInsightsWorkspace) para listar InsightsWorkspace
function ListarInsightsWorkspace {
    param (
        [Parameter(Mandatory = $true)]
        [string]$Query_connected,
        [Parameter(Mandatory = $true)]
        [string]$PathCsv,
        [Parameter(Mandatory = $true)]
        [string]$MsgGeral
    )
    PROCESS {
        try {
            Write-Host "´Gerando Relatorio de: $MsgGeral ....!´"
            $Workspace = Get-AzOperationalInsightsWorkspace 
            $ResultList_connected = Invoke-AzOperationalInsightsQuery -WorkspaceId $Workspace.CustomerId -Query $Query_connected  -ErrorAction Stop | Select-Object -ExpandProperty Results
            $ResultList_connected  | Export-Csv -Path $PathCsv -NoTypeInformatio
            Write-Host -BackgroundColor Green -ForegroundColor Black -Object "´Gerado Relatorio de: $MsgGeral ....!´"
            Write-Host "" 
        }
        catch {
            Write-Warning -Message "Erro ao gerar o Relatorio: $MsgGeral"
            Write-Host "" 
        }
    }
}

# Function (ListarTags) para listar tags centro de custo em ResourceGroups e Vms
function ListarTags {
    param (
        [Parameter(Mandatory = $true)]
        $GetAzResourceGroup,
        [Parameter(Mandatory = $true)]
        [string]$Type,
        [Parameter(Mandatory = $true)]
        [string]$Tag,
        [Parameter(Mandatory = $true)]
        [string]$PathCsv,
        [Parameter(Mandatory = $true)]
        [string]$MsgGeral
    )
    PROCESS {
        try {
            Write-Host "´Gerando Relatorio de: $MsgGeral ....!´"
            $resultstags = @()
            foreach ($resourcetag in $GetAzResourceGroup) {
                $tags = $resourcetag.Tags.GetEnumerator() | Where-Object { $_.Key -eq $Tag -and $_.Value -ne $null } | ForEach-Object {
                    New-Object PSObject -Property @{
                        "Nome da VM" = $resourcetag.$Type
                        "Tag Key"    = $_.Key
                        "Tag Value"  = $_.Value
                    }
                }
                $resultstags += $tags
            }
            $resultstags | Export-Csv -Path $PathCsv -NoTypeInformation -Encoding UTF8
            Write-Host -BackgroundColor Green -ForegroundColor Black -Object "´Gerado Relatorio de: $MsgGeral ....!´"
            Write-Host "" 
        }
        catch {
            Write-Warning -Message "Erro ao gerar o Relatorio: $MsgGeral"
            $ErrorMessage = $_.Exception.Message
            Write-Host -BackgroundColor red -ForegroundColor Black -Object $ErrorMessage
            Write-Host "" 
        }
    }
}

###########################################################################################################################################################################################
#Cria arquivo log
Write-Host "Iniciando Relatorio total de estações virtuais... " 
Write-Host "" 
"Titulo;Data;Hora" | Out-File $LogFile -Append -Force
"Inicio;" + $LogTime | Out-File $LogFile -Append -Force

Try { 
    #conectar na azure tenant Bradesco
    Write-Host "Conectando na Azure... " 
    Write-Host "" 
    "Conctar na azure;" + $LogTime | Out-File $LogFile -Append -Force
    Connect-AzAccount
    Set-AzContext -Subscription "<subscription>"
    Write-Host -BackgroundColor Green -ForegroundColor Black -Object "Conectado na Azure "
    Write-Host "" 
}
Catch {
    $ErrorMessage = $_.Exception.Message
    "Error Concetar na azure;" + $ErrorMessage | Out-File $LogFile -Append -Force
    Write-Host -BackgroundColor red -ForegroundColor Black -Object $ErrorMessage
    Write-Host "" 
    exit
}

###########################################################################################################################################################################################

#listar e mover arquivos relatorios
foreach ($Arquivo in $Arquivos) {
    Try { 
        $Arquivo_csv = $Arquivo + ".csv"
        Write-Host "Movendo arquivos antigos para pasta $timePasta ... " 
        Set-Location "<caminho>\Inventario_VDI\AVD"
        #Arquivo report_avd_hostpool.csv copy
        if ($Get_drivers.Name -eq $Arquivo_csv) {
            $Arquivo_Report_avd = $Get_drivers | Where-Object { $_.Name -eq $Arquivo_csv }  | Select-Object Name, @{Name = "LastWriteTime"; Expression = { $_.LastWriteTime.ToString("dd-MM-yyyy") } }
            $Data_arquivo1 = $Arquivo + "_" + $Arquivo_Report_avd.LastWriteTime + ".csv"
            $Destino_copy = ".\" + $timePasta + "\" + $Data_arquivo1 
            Copy-Item -Path $Arquivo_csv -Destination $Destino_copy -Force
            Remove-Item $Arquivo_csv
            Write-Host -BackgroundColor Green -ForegroundColor Black -Object "Arquivo $Arquivo_csv movido "
            Write-Host ""  
        }
        else {
            Write-Host -BackgroundColor Red -ForegroundColor Black -Object "Arquivo: $Arquivo_csv não encontrado "
            Write-Host "" 
        }
    }
    Catch {
        $ErrorMessage = $_.Exception.Message
        "Error copiar arquivos;" + $ErrorMessage | Out-File $LogFile -Append -Force
        Write-Host -BackgroundColor red -ForegroundColor Black -Object $ErrorMessage
        Write-Host "" 
        exit
    }
}

###########################################################################################################################################################################################
Write-Host  "###########################################################################################################################################################################################"
Write-Host  "Gerando Relatorio......"
Write-Host  "###########################################################################################################################################################################################"
Write-Host  ""

# Listar hostpool AVD $avd_hostpool
#Start-Job -ScriptBlock {ListarPropResource -ResourceType "Microsoft.DesktopVirtualization/hostpools" -Property "ResourceName" , "ResourceGroupName" , "ResourceType" -PathCsv $avd_hostpool -MsgGeral "Hostpool AVD: arquivo: $avd_hostpool"}
ListarPropResource -ResourceType "Microsoft.DesktopVirtualization/hostpools" -Property "ResourceName" , "ResourceGroupName" , "ResourceType" -PathCsv $avd_hostpool -MsgGeral "Hostpool AVD, arquivo: $avd_hostpool"

#listar aplication groups AVD $avd_aplication_group
#Start-Job -ScriptBlock {ListarPropResource -ResourceType "Microsoft.DesktopVirtualization/applicationgroups" -Property "ResourceName" , "ResourceGroupName" , "ResourceType" -PathCsv $avd_aplication_group -MsgGeral "Aplication Groups AVD"}
ListarPropResource -ResourceType "Microsoft.DesktopVirtualization/applicationgroups" -Property "ResourceName" , "ResourceGroupName" , "ResourceType" -PathCsv $avd_aplication_group -MsgGeral "Aplication Groups AVD, arquivo: $avd_aplication_group"

#listar vms forma 1 $avd_vms
#Start-Job -ScriptBlock {ListarPropResource -ResourceType "Microsoft.Compute/virtualMachines" -Property "ResourceName" , "ResourceGroupName" , "Type" -PathCsv $avd_vms -MsgGeral "Estações AVD"}
ListarPropResource -ResourceType "Microsoft.Compute/virtualMachines" -Property "ResourceName" , "ResourceGroupName" , "Type" -PathCsv $avd_vms -MsgGeral "Estações AVD, arquivo: $avd_vms"

#Listar user logados 90 dias
ListarInsightsWorkspace -Query_connected 'WVDConnections | where State contains "Connected"' -PathCsv $users_session_avd -MsgGeral "user logados 90 dias, arquivo: $users_session_avd"

#Listar estações criadas 30 dias
$Query_vmscreate = 'WVDHostRegistrations 
| where TimeGenerated > ago(30d)'

# chamar Function ListarInsightsWorkspace
ListarInsightsWorkspace -Query_connected $Query_vmscreate -PathCsv $report_avd_vm_create -MsgGeral "estações criadas 30 dias, arquivo: $report_avd_vm_create"

#lista user logados 35 dias
$Query_client = 'WVDConnections 
| where State contains "Connected" 
| where TimeGenerated > ago(35d)
| summarize arg_max(TimeGenerated, *) by UserName
| sort by TimeGenerated desc'

# chamar Function ListarInsightsWorkspace
ListarInsightsWorkspace -Query_connected $Query_client -PathCsv $report_avd_client -MsgGeral "user logados 35 dias, arquivo: $report_avd_client"

#Sessões Ativas por HostPools
$Query_session_ativa = 'let GranularityInterval = 30m;
WVDAgentHealthStatus
| summarize PeakSessionsByHost=max(toint(ActiveSessions)) by SessionHostName, bin(TimeGenerated, 30s), _ResourceId
| summarize SessionsByHostPool=sum(PeakSessionsByHost) by TimeGenerated, _ResourceId
| summarize max(SessionsByHostPool) by bin(TimeGenerated, GranularityInterval), _ResourceId'

# chamar Function ListarInsightsWorkspace
ListarInsightsWorkspace -Query_connected $Query_session_ativa -PathCsv $session_ativa -MsgGeral "Sessões Ativas por HostPools, arquivo: $session_ativa"

#Tempo de sessão usuários 30 dias 
$Query_session_users = 'WVDConnections 
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

# chamar Function ListarInsightsWorkspace
ListarInsightsWorkspace -Query_connected $Query_session_users -PathCsv $session_users_30d -MsgGeral "Tempo de sessão usuários 30 dias, arquivo: $session_users_30d"

##Listar subnets
Write-Host "Gerando relatorio Listar subnets... " 
$vn = Get-AzVirtualNetwork -Name vnetprvdibrazilsouth
$vn.Subnets | Select-Object Name, AddressPrefix | Export-Csv -Delimiter ";" -Path $report_subnets_avd -NoTypeInformation
Write-Host -BackgroundColor Green -ForegroundColor Black -Object "Relatorio Listar subnets gerado, arquivo: $report_subnets_avd"
Write-Host "" 

#gerar Grupos AVD
Write-Host "Gerando Grupos do AVD..." 
Get-AzRoleAssignment -RoleDefinitionName "Desktop Virtualization User" | Export-Csv -Path $report_grupos_avd -NoTypeInformation
Write-Host -BackgroundColor Green -ForegroundColor Black -Object "Relatorio Grupos gerado, arquivo: $report_grupos_avd"
Write-Host "" 

# Gerar Total estações
Write-Host "Gerando Todas as estações do Hostpool do AVD..." 

# mantem token da azure
function GetAuthToken($resource) {
    $context = [Microsoft.Azure.Commands.Common.Authentication.Abstractions.AzureRmProfileProvider]::Instance.Profile.DefaultContext
    $Token = [Microsoft.Azure.Commands.Common.Authentication.AzureSession]::Instance.AuthenticationFactory.Authenticate($context.Account, $context.Environment, $context.Tenant.Id.ToString(), $null, [Microsoft.Azure.Commands.Common.Authentication.ShowDialog]::Never,
        $null, $resource).AccessToken
    $authHeader = @{
        'Content-Type' = 'application/json'
        Authorization  = 'Bearer ' + $Token
    }
    return $authHeader
}
$token = GetAuthToken -resource "https://management.azure.com"

#Get API
$subscriptionId = "<subscription>"
$hostpoolName = Get-AzResource -ResourceType "Microsoft.DesktopVirtualization/hostpools"
#$hostpoolResourceGroup = (Get-AzResource -ResourceType "Microsoft.DesktopVirtualization/hostpools" | Where-Object {$_.ResourceGroupName -eq $hostpoolName}).ResourceGroupName
foreach ($hostpool in  $hostpoolName) {
    $hostpool.Name
    $hostpool.ResourceGroupName
    #Listar Propriedades das estações hostpool
    $SessionHostUrl = "https://management.azure.com/subscriptions/{0}/resourceGroups/{1}/providers/Microsoft.DesktopVirtualization/hostPools/{2}/sessionHosts?api-version=2022-02-10-preview" -f $subscriptionId, $hostpool.ResourceGroupName, $hostpool.Name
    $parameters = @{
        uri     = $SessionHostUrl
        Method  = "GET"
        Headers = $token
    }
    $sessionHost = Invoke-RestMethod @parameters
    #Listar Informações de usuário agente e tempo de comunicação
    $session_pro += @($sessionHost.value.properties | Select-Object -Property allowNewSession, assignedUser, sessions, status, agentVersion, resourceId, lastHeartBeat, statusTimestamp, lastUpdateTime)
    #$session_pro+=$sessionHost.value.properties | Select-Object -Property assignedUser,allowNewSession,sessions,status,agentVersion,resourceId,lastHeartBeat,statusTimestamp,lastUpdateTime
}
$session_pro | Export-Csv -Path $report_avd_total_vms -NoTypeInformation
Write-Host -BackgroundColor Green -ForegroundColor Black -Object "Relatorio Todas as estações do Hostpool do, arquivo: $report_avd_total_vms"
Write-Host "" 

# Listar Vms na OU AVD
Write-Host "Gerando Total VMs na OU AVD" 
$Computers = Get-ADComputer -Filter '*' -SearchBase $OU_AVD
$Computers | ForEach-Object {
    $_.DNSHostName
} | Out-File -Filepath $report_ou_avd
Write-Host -BackgroundColor Green -ForegroundColor Black -Object "Relatorio todas estações AVD, arquivo: $report_ou_avd"
 
# Listar Tags centro de custo ResurceGroups AVD $report_resourcestags_avd
$resourcestags = Get-AzResourceGroup
ListarTags -GetAzResourceGroup $resourcestags -Type "ResourceGroupName" -Tag "centro_de_custo" -PathCsv $report_resourcestags_avd -MsgGeral "tag centro de custo resource group, arquivo: $report_resourcestags_avd"

# Listar Tags centro de custo vms AVD $report_vmstags_avd
$reportvmstags = Get-AzVM | Where-Object { $_.ProvisioningState -eq "Succeeded" }
ListarTags -GetAzResourceGroup $reportvmstags -Type "Name" -Tag "centro_de_custo" -PathCsv $report_vmstags_avd -MsgGeral "tag centro de custo vms, arquivo: $report_vmstags_avd"

#Variavel data formatada.
$LogTime2 = Get-Date -Format  "dd-MM-yyyy;hh:mm:ss"
"Termino;" + $LogTime2 | Out-File $LogFile -Append -Force

#Concluido Reporte
Write-Host -BackgroundColor Green -ForegroundColor Black -Object "Inicio Relatorio $LogTime, Termino relatorio $LogTime2 "

#Verificar arquivo relatorio
while ($relatorioI -eq $null ) {
    $ValorRelatorio = Read-Host "
    ============================= Script SUPORTE-VDI =============================
    Digite 1 para abrir o relatorio excel ou 0 para sair sem abrir o relatorio
    Valor: 
    ==============================================================================

    "  
    if ($ValorRelatorio -eq 1) {
        Invoke-Item $relatorio_avd
        $relatorioI = 1
    }
    else {
        if ($ValorRelatorio -eq 0) {
            $relatorioI = 1
        }
        else {        
            $relatorioI = $null
            $ValorRelatorio = $null
        }
    }
}
