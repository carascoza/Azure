@"
===============================================================================
                    SCRIPT
Title:         CRIAR keyvauly
Description:   CRIAR keyvauly
Usage:         .\keyvauly.ps1
version:       V1.0
Date_create:   30/01/2024
Date_modified: 30/01/2024
links: https://learn.microsoft.com/pt-br/azure/key-vault/certificates/quick-create-powershell
===============================================================================

"@

#variaveis
$LogTime = Get-Date -Format "dd-MM-yyyy;hh:mm:ss"
$Time = Get-Date -Format "MM-dd-yyyy"
$LogFile  = "<caminho\criar_hostpool_>" + $Time + ".log"
$LogFile_error  = "<caminho\Logs\error_>" + $Time + ".log"
$ExportFilePath = "<caminho>"
$location = '<location>'
$resourceGroupName= '<resource_group>'

# Conectar na azure
az login



$deployKeyVault = az keyvault create --location $location --resource-group $resourceGroupName --name vmjoiner-KeyVault

$keyvault = $deployKeyVault | ConvertFrom-Json
$deploySecretPass = az keyvault secret set --name vmjoinerPassword --vault-name $keyvault.name --value '<Password>'
$deploySecretPass_helpdesk = az keyvault secret set --name vmhelpdeskPassword --vault-name $keyvault.name --value '<Password>'