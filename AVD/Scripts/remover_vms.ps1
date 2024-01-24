
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
$LogFile  = "C:\Users\caras\Documents\Cloud\Azure\AVD\remover_vms_" + $Time + ".log"
$ExportFilePath ="C:\Users\caras\Documents\Cloud\Azure\AVD\"
$remove_vms = $ExportFilePath + "remover_vms.csv"
$vms_Csv = Import-Csv $remove_vms -Delimiter ';'
$subscript = "b3e78373-d280-4a8b-acd9-90118435ea62"
$TenantID = "7fee076f-d820-4777-85a7-10a11153d96e"

#conectar na azure tenant Bradesco
Import-Module Az.Avd
Connect-Avd -TenantID $TenantID -Subscription $subscript
Connect-AzAccount
Set-AzContext -Subscription $subscript

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
$vm_hostpool = $vms_vm + ".mac-lab01.ml"
Remove-AvdSessionHost -HostpoolName $vms_resource -ResourceGroupName $vms_resource -Name $vm_hostpool

}

Catch{

$ErrorMessage = $_.Exception.Message
    $vms.vms + ";" +$ErrorMessage | Out-File $LogFile -Append -Force
    Write-Host -BackgroundColor red -ForegroundColor Black -Object $ErrorMessage
}

#Variavel data formatada.
$LogTime2 = Get-Date -Format "MM-dd-yyyy_hh-mm-ss"
"Termino: " + $LogTime2 | Out-File $LogFile -Append -Force 
