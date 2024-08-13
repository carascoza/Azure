@"
===============================================================================
                    SUPORTE-VDI
Title:         USER ASSIGN
Description:   USER ASSIGN
Usage:         .\user_assign.ps1
version:       V1.0
Date_create:   03/07/2024
Date_modified: 04/07/2024
learn.microsoft.com/en-us/azure/virtual-desktop/configure-host-pool-personal-desktop-assignment-type?tabs=powershell%2Cpowershell2
===============================================================================
"@

#variaveis
$LogTime = Get-Date -Format "dd-MM-yyyy;hh:mm:ss"
$Time = Get-Date -Format "MM-dd-yyyy"
$LogFile = "/home/marco/remover_vms_" + $Time + ".log"
$LogFile_error = "/home/marco/error_" + $Time + ".log"
$ExportFilePath = "/home/marco/"
$Path_users = $ExportFilePath + "users_avd_manual.csv"
$users_Csv = Import-Csv $Path_users -Delimiter ';'
#######################################################################################################################################

#Cria arquivo log
"Titulo;Data;Hora" | Out-File $LogFile -Append -Force
"Inicio;" + $LogTime | Out-File $LogFile -Append -Force

# Listar usuário e centro de custo
Try {
    foreach ($user_Csv in $users_Csv) {
        try {
            $tags_avd = @{
                "centro_de_custo" = $user_Csv.rotina;
            }
            #listar propriedade vm
            $vmtags = Get-AzVM -Name $user_Csv.vm
            $vm_id = $user_Csv.vm + "<.dominio>"
            #associar estação vm user
            Update-AzWvdSessionHost -HostPoolName $user_Csv.hostpool -Name $vm_id -ResourceGroupName $user_Csv.hostpool -AssignedUser $user_Csv.users
            #update tags centro de custo
            Update-AzTag -ResourceId $vmtags.Id -Tag $tags_avd -Operation Merge
        }
        catch {
            Write-Warning -Message "Erro ao gerar o Relatorio: $MsgGeral"
            $ErrorMessage = $_.Exception.Message
            Write-Host -BackgroundColor red -ForegroundColor Black -Object $ErrorMessage
        }
    }
}
Catch {
    $ErrorMessage = $_.Exception.Message
    "Error Listar usuarios;" + $ErrorMessage | Out-File $LogFile -Append -Force
    Write-Host -BackgroundColor red -ForegroundColor Black -Object $ErrorMessage
}
