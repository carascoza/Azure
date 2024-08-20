@"
===============================================================================
                    SUPORTE-VDI
Title:         LISTAR USERS ENTRA ID
Description:   LISTAR USERS ENTRA ID
Usage:         .\listar_users_entra_ID.ps1
version:       V1.0
Date_create:   13/08/2024
Date_modified: 14/08/2024
===============================================================================
"@
###########################################################################################################################################################################################
#variaveis
$LogTime = Get-Date -Format "dd-MM-yyyy;hh:mm:ss"
$Time = Get-Date -Format "MM-dd-yyyy"
#arquivos logs
$LogFile = "<caminho>\Entra_ID\listar_users" + $Time + ".log"
$ExportFilePath = "<caminho>\Entra_ID\"
$ReportList_Users = $ExportFilePath + "list_users_entra_id.csv"

# Import the AzureAD module
Import-Module AzureAD

###########################################################################################################################################################################################
#Cria arquivo log
Write-Host "Iniciando Script Listar Users Entra ID... " 
Write-Host "" 
"Titulo;Data;Hora" | Out-File $LogFile -Append -Force
"Inicio;" + $LogTime | Out-File $LogFile -Append -Force

Try { 
    #conectar na azure tenant Bradesco
    Write-Host "Conectando na AzureAD... " 
    Write-Host "" 
    "Conctar na azure;" + $LogTime | Out-File $LogFile -Append -Force
    # Connect to Azure AD
    Connect-AzureAD
    Write-Host -BackgroundColor Green -ForegroundColor Black -Object "Conectado na AzureAD "
    Write-Host "" 
}
Catch {
    $ErrorMessage = $_.Exception.Message
    "Error Concetar na azureAD;" + $ErrorMessage | Out-File $LogFile -Append -Force
    Write-Host -BackgroundColor red -ForegroundColor Black -Object $ErrorMessage
    Write-Host "" 
    exit
}

# Get all users and select the required properties
Write-Host "Listando Users Entra ID... Aguarde..... " 
Write-Host "" 
$users = Get-AzureADUser -All $true | Where-Object { $_.UserType -eq "Member" } | Select-Object ObjectId, UserPrincipalName, Mail, DisplayName, AccountEnabled, Department, ImmutableId, JobTitle, LastDirSyncTime, UserType, @{Name = "ExtensionPropertyString"; Expression = { ($_.ExtensionProperty
            | ConvertTo-Json -Compress) }
}
Write-Host "Exportando Users Entra ID para arquivo csv ($ReportList_Users)... Aguarde..... "
#Write-Host "" 
$users | Export-Csv -Path $ReportList_Users -NoTypeInformation

#Variavel data formatada.
$LogTime2 = Get-Date -Format  "dd-MM-yyyy;hh:mm:ss"
"Termino;" + $LogTime2 | Out-File $LogFile -Append -Force

#Concluido Reporte
Write-Host -BackgroundColor Green -ForegroundColor Black -Object "Inicio Relatorio $LogTime, Termino relatorio $LogTime2 "
 
