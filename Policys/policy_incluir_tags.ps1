@"
===============================================================================
                    SCRIPT
Title:         policy_incluir_tags
Description:   policy_incluir_tags
Usage:         .\policy_incluir_tags.ps1
version:       V1.0
Date_create:   28/11/2024
Date_modified: 28/11/2024
links: https://learn.microsoft.com/pt-br/azure/virtual-desktop/deploy-azure-virtual-desktop?tabs=powershell
Links: https://learn.microsoft.com/pt-br/powershell/module/az.desktopvirtualization/new-azwvdapplicationgroup?view=azps-11.2.0
Links: https://askaresh.com/2022/12/13/azure-virtual-desktop-powershell-create-a-host-pool-application-group-and-workspace-for-remoteapp-aka-published-applications/
===============================================================================

"@

#variaveis
$LogTime = Get-Date -Format "dd-MM-yyyy;hh:mm:ss"
$Time = Get-Date -Format "MM-dd-yyyy"
$LogFile = "<caminho>\policy_tags_" + $Time + ".log"
$subscriptionId = "sua_assinatura"
$policyName = "apply-default-tags"
$policyDisplayName = "Apply Default Tags"
$policyDescription = "Applies default tags to all newly created resources."

#Cria arquivo log
"Titulo;Data;Hora" | Out-File $LogFile -Append -Force
"Inicio;" + $LogTime | Out-File $LogFile -Append -Force

Try { 


    #conectar na azure tenant nome_empresa
    "Conctar na azure;" + $LogTime | Out-File $LogFile -Append -Force
    Connect-AzAccount
    Set-AzContext -SubscriptionId $subscriptionId

}

Catch {

    $ErrorMessage = $_.Exception.Message
    "Error Concetar na azure;" + $ErrorMessage | Out-File $LogFile -Append -Force
    Write-Host -BackgroundColor red -ForegroundColor Black -Object $ErrorMessage
    exit
}

# Definir a política JSON corretamente
$policyRule = @{
  "if" = @{
    "field" = "type"
    "equals" = "Microsoft.Resources/subscriptions/resourceGroups"
  }
  "then" = @{
    "effect" = "modify"
    "details" = @{
      "roleDefinitionIds" = @(
        "/providers/Microsoft.Authorization/roleDefinitions/{roleDefinitionId}"
      )
      "operations" = @(
        @{
          "operation" = "add"
          "field" = "tags.local"
          "value" = "East US 2"
        }
        @{
          "operation" = "add"
          "field" = "tags.owner"
          "value" = "name"
        }
        @{
          "operation" = "add"
          "field" = "tags.ambiente"
          "value" = "prd"
        }
      )
    }
  }
}

# Converter o objeto hash para JSON
$policyJson = $policyRule | ConvertTo-Json -Depth 10

# Criar a definição da política
$policyDefinition = New-AzPolicyDefinition -Name $policyName -DisplayName $policyDisplayName -Description $policyDescription -Policy $policyJson

# Atribuir a política à assinatura
New-AzPolicyAssignment -Name $policyName -PolicyDefinition $policyDefinition -Scope "/subscriptions/$subscriptionId"