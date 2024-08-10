@"
===============================================================================
                    SUPORTE-VDI
Title:         REMOVER VMS AZURE
Description:   REMOVER VMS AZURE
Usage:         .\remover_vms.ps1
version:       V4.0
Date_create:   26/12/2023
Date_modified: 09/08/2024
===============================================================================
"@

#variaveis
$LogTime = Get-Date -Format "dd-MM-yyyy;hh:mm:ss"
$Time = Get-Date -Format "MM-dd-yyyy"
$LogFile = "/home/marco/remover_vms_" + $Time + ".log"
$LogFile_error = "/home/marco/error_" + $Time + ".log"
$ExportFilePath = "/home/marco/"
$remove_vms = $ExportFilePath + "remover_vms.csv"
$vms_Csv = Import-Csv $remove_vms -Delimiter ';'
$subscriptionId = "<informar>"
$array_vms = $vms_Csv.vms
$total_array = $array_vms.Count
$val = 1

#Cria arquivo log
"Titulo;Data;Hora" | Out-File $LogFile -Append -Force
"Inicio;" + $LogTime | Out-File $LogFile -Append -Force

Try { 
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
}
Catch {
    $ErrorMessage = $_.Exception.Message
    "Error manter conectado na azure;" + $ErrorMessage | Out-File $LogFile -Append -Force
    Write-Host -BackgroundColor red -ForegroundColor Black -Object $ErrorMessage
    exit
}
Clear-Host

Write-Host -BackgroundColor yellow -ForegroundColor Black -Object " ############## Lista de vms a serem removidas ############## "
#Inicio Reporte
Write-Host -BackgroundColor Green -ForegroundColor Black -Object "Inicio Relatorio $LogTime"
$vms_Csv
Start-Sleep 15
Write-Host -BackgroundColor yellow -ForegroundColor Black -Object " ############################################################ "
Write-Host -Object "  "
Write-Host -BackgroundColor yellow -ForegroundColor Black -Object " Arquivo de log de erros no caminho: $LogFile_error "
Write-Host -BackgroundColor yellow -ForegroundColor Black -Object " total de vms: $total_array"
Write-Host -BackgroundColor yellow -ForegroundColor Black -Object " ############################################################ "

foreach ($vms in $vms_Csv) {
    Write-Host -BackgroundColor yellow -ForegroundColor Black -Object " total numero: $val de total: $total_array"
    Try { 
        $vms_vm = $vms.vms
        $vms_resource = $vms.resourcegroup
        Write-Host -BackgroundColor yellow -ForegroundColor Black -Object "  "
        Write-Host -BackgroundColor yellow -ForegroundColor Black -Object " ############################################################ "
        Write-Host -BackgroundColor yellow -ForegroundColor Black -Object "Removendo estacao: $vms_vm da azrue... "
        Write-Host -BackgroundColor yellow -ForegroundColor Black -Object " ############################################################ "
        "Update vm: $vms_vm da azrue;" + $LogTime | Out-File $LogFile -Append -Force
        $avd_vm = $null
        $avd_vm = Get-AzVM -ResourceGroupName $vms.resourcegroup -Name $vms_vm
        $avd_vm.Name

        if ($avd_vm.Name -eq $vms_vm) {
            # Update remover disco e rede da estacao virtual em um comando 
            "Update remover disco e rede da estacao virtual em um comando: $vms_vm da azrue;" + $LogTime | Out-File $LogFile -Append -Force
            $vmConfig = Get-AzVM -ResourceGroupName $vms.resourcegroup -Name $vms_vm
            $vmConfig.StorageProfile.OsDisk.DeleteOption = 'Delete' 
            $vmConfig.StorageProfile.DataDisks | ForEach-Object { $_.DeleteOption = 'Delete' }
            $vmConfig.NetworkProfile.NetworkInterfaces | ForEach-Object { $_.DeleteOption = 'Delete' }
            $vmConfig | Update-AzVM 
        }
    }
    Catch {
        $ErrorMessage = $_.Exception.Message
        "Error remover estacao azure;" + $vms.vms + ";" + $ErrorMessage | Out-File $LogFile -Append -Force
        Write-Host -BackgroundColor red -ForegroundColor Black -Object $ErrorMessage
    }
    #####################################################################
    Try { 
        Write-Host -BackgroundColor yellow -ForegroundColor Black -Object "Removendo estacao: $vms_vm da azrue... "
        "Removendo estacao: $vms_vm da azrue;" + $LogTime | Out-File $LogFile -Append -Force
        $avd_vm = $null
        $avd_vm = Get-AzVM -ResourceGroupName $vms.resourcegroup -Name $vms_vm
        $avd_vm.Name
        if ($avd_vm.Name -eq $vms_vm) {
        }
        # Remover vm da azure (link: https://learn.microsoft.com/en-us/azure/virtual-machines/delete?tabs=powershell2%2Cpowershell3%2Cpowershell4%2Cpowershell5)
        Remove-AzVm `
        -ResourceGroupName $vms.resourcegroup `
        -Name $vms_vm  `
        -Force 
        Write-Host -BackgroundColor green -ForegroundColor Black -Object "Estacao: $vms_vm removida da azure... "
        "Estacao: $vms_vm removida da azure;" + $LogTime | Out-File $LogFile -Append -Force
        "Error_remover_azure;$vms_vm;" + $LogTime | Out-File $LogFile_error -Append -Force
    }
    Catch {
        $ErrorMessage = $_.Exception.Message
        "Error remover estacao azure;" + $vms.vms + ";" + $ErrorMessage | Out-File $LogFile -Append -Force
        Write-Host -BackgroundColor red -ForegroundColor Black -Object $ErrorMessage
    }
    Try {
        Write-Host -BackgroundColor yellow -ForegroundColor Black -Object "Removendo estacao: $vms_vm do HostPool... "
        "Removendo estacao: $vms_vm do HostPool;" + $LogTime | Out-File $LogFile -Append -Force
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
        #remove vm HostPool
        $vm_hostpool = $vms_vm + ".corp.bradesco.com.br"
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
    Catch {
        $ErrorMessage = $_.Exception.Message
        "Error remover estacao HostPool;" + $vms.vms + ";" + $ErrorMessage | Out-File $LogFile -Append -Force
        Write-Host -BackgroundColor red -ForegroundColor Black -Object $ErrorMessage
    }
    $val++
}

#Variavel data formatada.
$LogTime2 = Get-Date -Format  "dd-MM-yyyy;hh:mm:ss"
"Termino;" + $LogTime2 | Out-File $LogFile -Append -Force

#Concluido Reporte
Write-Host -BackgroundColor Green -ForegroundColor Black -Object "Inicio Relatorio $LogTime, Termino relatorio $LogTime2 "
