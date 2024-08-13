@"
==========================================================================================================
                                        Suporte AVD
Title:
Description:
Name:S
Version:
Date_create:
Date_modified:
==========================================================================================================

"@
#variaveis
$LogTime = Get-Date -Format "dd-MM-yyyy;hh:mm:ss"
$Time = Get-Date -Format "MM-dd-yyyy"
$LogFile = "<caminho>\criar_hostpool_" + $Time + ".log"
$LogFile_error = "<caminho>\Logs\error_" + $Time + ".log"

# Permitir executar scripts no perfil do usuario (execution policy)
Set-ExecutionPolicy -ExecutionPolicy Unrestricted -Scope CurrentUser

# copiar .ps1
.\CopyToPSPath.ps1 

# Importar Modulo AzFilesHybrid
Import-Module -Name AzFilesHybrid

Try { 
    #conectar na azure tenant nome_empresa
    "Conctar na azure;" + $LogTime | Out-File $LogFile -Append -Force
    Connect-AzAccount
    #Set-AzContext -Subscription $subscriptionId
}
Catch {
    $ErrorMessage = $_.Exception.Message
    "Error Concetar na azure;" + $ErrorMessage | Out-File $LogFile -Append -Force
    Write-Host -BackgroundColor red -ForegroundColor Black -Object $ErrorMessage
    exit
}

# Definir parametros
# Link https://learn.microsoft.com/windows/win32/adschema/a-samaccountname para mais informacoes.
$SubscriptionId = "digitar"
$ResourceGroupName = "digitar"
$StorageAccountName = "digitar"

# Digitar OU name directory.
$OuDistinguishedName = "digitar"

# Tipo de Criptografia.
$EncryptionType = " 'RC4' , 'AES256' "

# Selecionar subscrição de usuário
Select-AzSubscription -SubscriptionId $SubscriptionId 

#Comando para registrar conta de storage no dominio.
Join-AzStorageAccount `
    -ResourceGroupName $ResourceGroupName `
    -StorageAccountName $StorageAccountName `
    -DomainAccountType ComputerAccount `
    -OrganizationalUnitDistinguishedName $OuDistinguishedName `
    -EncryptionType $EncryptionType

Debug-AzStorageAccountAuth -StorageAccountName $StorageAccountName -ResourceGroupName $ResourceGroupName -Verbose