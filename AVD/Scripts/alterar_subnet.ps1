@"

===============================================================================
                    SUPORTE-VDI
Title:         RELATORIO_AVD
Description:   RELATORIO ESTAÇÕES VIRTUAIS AVD
Usage:         .\alterar_subnet.ps1
version:       V2.0
Date_create:   17/10/2023
Date_modified: 10/08/2024
===============================================================================

"@

#variaveis
$LogTime = Get-Date -Format "dd-MM-yyyy_hh-mm-ss"
$Time = Get-Date -Format "MM-dd-yyyy"
$LogFile = "<caminho>\AVD\Vnet_subnet\alterar_subnet_" + $Time + ".log"
$ExportFilePath = "<caminho>\AVD\Vnet_subnet\"
$subnet_vms = $ExportFilePath + "subnet_vms.csv"
$vms_Csv = Import-Csv $subnet_vms -Delimiter ';' 
$vnet_avd = "<vnet>"
$vnet_resource = "<resource_group>"
$subnet = "<subnet>"

#Inicio Codigo

#Cria arquivo log
"Titulo;Data;Hora" | Out-File $LogFile -Append -Force
"Inicio;" + $LogTime | Out-File $LogFile -Append -Force

Try { 
    #conectar na azure tenant Bradesco
    "Conctar na azure;" + $LogTime | Out-File $LogFile -Append -Force
    Disconnect-AzAccount
    Connect-AzAccount
    Set-AzContext -Subscription $subscriptionId
}
Catch {
    $ErrorMessage = $_.Exception.Message
    "Error Concetar na azure;" + $ErrorMessage | Out-File $LogFile -Append -Force
    Write-Host -BackgroundColor red -ForegroundColor Black -Object $ErrorMessage
    exit
}

foreach ($vms in $vms_Csv) {
    Try { 
        #Cria arquivo log
        "Inicio: " + $LogTime | Out-File $LogFile -Append -Force
        $vms.nic = $vms.nic + "-nic"
        ##Alterar subnet
        $nic = Get-AzNetworkInterface -ResourceGroupName $vms.resource -Name $vms.nic
        $vnet = Get-AzVirtualNetwork -Name $vnet_avd -ResourceGroupName $vnet_resource
        $subnet2 = Get-AzVirtualNetworkSubnetConfig -Name $subnet -VirtualNetwork $vnet
        $nic.IpConfigurations[0].Subnet.Id = $subnet2.Id
        $nic | Set-AzNetworkInterface
    }
    Catch {
        $ErrorMessage = $_.Exception.Message
        $vms + ";" + $ErrorMessage | Out-File $LogFile  -Append -Force
    }
}

#Variavel data formatada.
$LogTime2 = Get-Date -Format "MM-dd-yyyy_hh-mm-ss"
"Termino: " + $LogTime2 | Out-File $LogFile -Append -Force
