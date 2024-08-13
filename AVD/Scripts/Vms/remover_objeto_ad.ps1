@"
===============================================================================
                    SUPORTE-VDI
Title:         REMOVER OBJETO AD
Description:   REMOVER OBJETO AD
Usage:         .\remover_objeto_ad.ps1
version:       V3.0
Date_create:   26/12/2023
Date_modified: 17/06/2024
===============================================================================
"@

#variaveis
$LogTime = Get-Date -Format "dd-MM-yyyy;hh:mm:ss"
$Time = Get-Date -Format "MM-dd-yyyy"
$LogFile = "<caminho>\Azure\remover_vms_" + $Time + ".log"
$LogFile_error = "<caminho>\Azure\error_" + $Time + ".log"
$ExportFilePath = "<caminho>\Azure\remover_vms"
$remove_vms = $ExportFilePath + "remover_vms.csv"
$vms_Csv = Import-Csv $remove_vms -Delimiter ';'
$array_vms = $vms_Csv.vms
$total_array = $array_vms.Count
$val = 1

#Cria arquivo log
"Titulo;Data;Hora" | Out-File $LogFile -Append -Force
"Inicio;" + $LogTime | Out-File $LogFile -Append -Force

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
    Try { 
        Write-Host -BackgroundColor yellow -ForegroundColor Black -Object " total numero: $val de total: $total_array"
        $vms_vm = $vms.vms
        Write-Host -BackgroundColor yellow -ForegroundColor Black -Object "Removendo estacao: $vms_vm do AD onpremise... "
        "Removendo estacao: $vms_vm do AD onpremise;" + $LogTime | Out-File $LogFile -Append -Force
        # Remover objeto do AD (link: https://learn.microsoft.com/en-us/powershell/module/activedirectory/remove-adcomputer?view=windowsserver2022-ps)
        #verificar estacao no AD
        $ad_vm = $null
        $ad_vm = Get-ADComputer -Identity $vms_vm
        $ad_vm.name

        if ($ad_vm.name -eq $vms_vm) {
            Get-ADComputer -Identity $vms_vm | Remove-ADObject -Recursive -Confirm:$False
            Write-Host -BackgroundColor green -ForegroundColor Black -Object "Estacao: $vms_vm removida do AD onpremise... "
            "Estacao: $vms_vm removida do AD onpremise;" + $LogTime | Out-File $LogFile -Append -Force
        }
    }
    Catch {
        $ErrorMessage = $_.Exception.Message
        "Error remover estacao onpremise;" + $vms.vms + ";" + $ErrorMessage | Out-File $LogFile -Append -Force
        "Error_remover_AD;$vms_vm;" + $LogTime | Out-File $LogFile_error -Append -Force
        Write-Host -BackgroundColor red -ForegroundColor Black -Object $ErrorMessage
    }
    $val++
}

#Variavel data formatada.
$LogTime2 = Get-Date -Format  "dd-MM-yyyy;hh:mm:ss"
"Termino;" + $LogTime2 | Out-File $LogFile -Append -Force
