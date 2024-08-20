@"
===============================================================================
                    SUPORTE-VDI
Title:         CORRIGIR MMUTABLEID
Description:   CORRIGIR MMUTABLEID
Usage:         .\corrigir_mmutableId.ps1
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

### ATENÇÃO! ESSE SCRIPT PRECISA DO ACESSO DE GLOBAL ADMIN ###
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

#Declara o código funcional - Só alimentar essa variável
$funcional = "<codigo_user>"

#Declara os usuários local e na Azure
$userlocal = Get-ADUser $funcional -Properties whenCreated, ObjectGUID , mS-DS-ConsistencyGuid, msExchMasterAccountSid
$userazure = Get-AzureADUser -ObjectId $userlocal.UserPrincipalName | Select-Object ObjectId, UserPrincipalName, ImmutableID

#Coleta o ObjectID on-premises
$string = $userlocal.ObjectGUID

#Converte para o valor criptografado 
$immutableId = [Convert]::ToBase64String([guid]::New("$string").ToByteArray())
Write-Host $immutableId

#Verifica se os valores estão corretos
if ($userazure.ImmutableId -eq $immutableId) {
    Write-Host "Usuário com o ImmutableID correto"
}
else {
    # Atualize o usuário com o novo ImmutableID
    Set-AzureADUser -ObjectId $userazure.ObjectId -ImmutableId $null
    Set-AzureADUser -ObjectId $userazure.ObjectId -ImmutableId $immutableId
    # Verifique se a atualização foi bem-sucedida

    $userUpdated = Get-AzureADUser -ObjectId $userlocal.UserPrincipalName
    if ($userUpdated.ImmutableId -eq $immutableId) {
        Write-Host "O ImmutableID foi atualizado com sucesso."
        #Escreve arquivo de log
        Add-Content -Path $logFilePath -Value "Funcional: $($funcional)"
        Add-Content -Path $logFilePath -Value "UserPrincipalName: $($userazure.UserPrincipalName)"
        Add-Content -Path $logFilePath -Value "ObjectId: $($userazure.ObjectId)"
        Add-Content -Path $logFilePath -Value "ImmutableID Antigo: $($userazure.ImmutableID)"
        Add-Content -Path $logFilePath -Value "ImmutableID Novo: $($userUpdated.ImmutableId)"
    }
    else {
        Write-Host "A atualização do ImmutableID falhou."
    }
}
