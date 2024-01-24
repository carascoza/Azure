@"
===============================================================================
                    SCRIPT
Title:         REMOVER VMS AZURE
Description:   REMOVER VMS AZURE
Usage:         .\remover_vms.ps1
version:       V2.0
Date_create:   26/12/2023
Date_modified: 27/12/2023
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
$LogFile  = "CAMINHO\remover_vms_" + $Time + ".log"
$ExportFilePath ="CAMINHO\"
$remove_vms = $ExportFilePath + "remover_vms.csv"
$vms_Csv = Import-Csv $remove_vms -Delimiter ';'


#conectar na azure tenant Bradesco
Connect-AzAccount
Set-AzContext -Subscription ""

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

Catch{

$ErrorMessage = $_.Exception.Message
    $vms.vms + ";" +$ErrorMessage | Out-File $LogFile -Append -Force
    Write-Host -BackgroundColor red -ForegroundColor Black -Object $ErrorMessage
}
}


Try
{ 
# Remover Vm HostPool link: https://rozemuller.com/move-avd-session-hosts-to-a-new-host-pool-with-rest-api/
Remove-AvdSessionHost -HostpoolName $hostpoolname -ResourceGroupName $ResourceGroupName -Name $SessionHostName

}

Catch{

$ErrorMessage = $_.Exception.Message
    $vms.vms + ";" +$ErrorMessage | Out-File $LogFile -Append -Force
    Write-Host -BackgroundColor red -ForegroundColor Black -Object $ErrorMessage
}

#Variavel data formatada.
$LogTime2 = Get-Date -Format "MM-dd-yyyy_hh-mm-ss"
"Termino: " + $LogTime2 | Out-File $LogFile -Append -Force 
