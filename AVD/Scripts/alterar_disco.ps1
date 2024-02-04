@"
===============================================================================
                    SCRIPT
Title:         ALTERAR DISCO VM AZURE
Description:   ALTERAR DISCO VM AZURE
Usage:         .\alterar_disco.ps1
version:       V1.0
Date_create:   17/01/2024
Date_modified: 17/01/2024
===============================================================================
link: https://learn.microsoft.com/pt-br/azure/virtual-machines/disks-convert-types?tabs=azure-powershell
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


#Cria arquivo log
"Titulo;Data;Hora" | Out-File $LogFile -Append -Force
"Inicio;" + $LogTime | Out-File $LogFile -Append -Force
 
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
 

##listar vms forma 1

$total_vms = Get-AzResource -ResourceType "Microsoft.Compute/virtualMachines" | Select-Object -Property ResourceName, ResourceGroupName, Type


foreach ($vms in $total_vms){

#propriedades hardware vms
$vmConfig = Get-AzVM -ResourceGroupName $vms.ResourceGroupName -Name $vms.ResourceName

#vm name
$vms.ResourceName

# tipo de hardware
$vmConfig.HardwareProfile.VmSize

#nome disco
$vmConfig.StorageProfile.OsDisk.Name 

$vmConfig.StorageProfile.OsDisk.DiskSizeGB

#imagem referencia
$vmConfig.StorageProfile.ImageReference

Try
{ 

$diskName = $vmConfig.StorageProfile.OsDisk.Name 
# resource group that contains the managed disk
$rgName = $vms.ResourceGroupName
# Choose between Standard_LRS, StandardSSD_LRS, StandardSSD_ZRS, Premium_ZRS, and Premium_LRS based on your scenario
$storageType = 'Standard_LRS'
# Premium capable size 
$size = $vmConfig.HardwareProfile.VmSize

$disk = Get-AzDisk -DiskName $diskName -ResourceGroupName $rgName

# Get parent VM resource
$vmResource = Get-AzResource -ResourceId $disk.ManagedBy

# Stop and deallocate the VM before changing the storage type
Stop-AzVM -ResourceGroupName $vms.ResourceGroupName -Name $vms.ResourceName -Force

$vm = Get-AzVM -ResourceGroupName $vms.ResourceGroupName -Name $vms.ResourceName

# Change the VM size to a size that supports Premium storage
# Skip this step if converting storage from Premium to Standard
$vm.HardwareProfile.VmSize = $size
Update-AzVM -VM $vm -ResourceGroupName $rgName

# Update the storage type
$disk.Sku = [Microsoft.Azure.Management.Compute.Models.DiskSku]::new($storageType)
$disk | Update-AzDisk

#Start-AzVM -ResourceGroupName $vm.ResourceGroupName -Name $vm.Name

}

Catch{

$ErrorMessage = $_.Exception.Message
    $vms.vms + ";" +$ErrorMessage | Out-File $LogFile -Append -Force
    Write-Host -BackgroundColor red -ForegroundColor Black -Object $ErrorMessage
}
}