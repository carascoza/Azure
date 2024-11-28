@"
===============================================================================
                    SCRIPT
Title:         policy_incluir_tags
Description:   policy_incluir_tags
Usage:         .\policy_incluir_tags.ps1
version:       V1.0
Date_create:   28/11/2024
Date_modified: 28/11/2024
links: https://learn.microsoft.com/pt-pt/azure/governance/policy/samples/pattern-tags
===============================================================================

"@

#variaveis
$LogTime = Get-Date -Format "dd-MM-yyyy;hh:mm:ss"
$Time = Get-Date -Format "MM-dd-yyyy"
$LogFile = "<caminho>\policy_tags_" + $Time + ".log"
$subscriptionId = "sua_assinatura"
$resourceGroupName = "seu_grupo_de_recursos"
$identityName = "seu_nome_de_identidade"
$policyName = "apply-default-tags"
$policyDisplayName = "Apply Default Tags"
$policyDescription = "Applies default tags to all newly created resources in East US 2."
$roleDefinitionId = "b24988ac-6180-42a0-ab88-20f7382dd24c" # ID da função "Contributor"

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


# Criar uma nova identidade gerida (se não existir)
if (-not (Get-AzUserAssignedIdentity -ResourceGroupName $resourceGroupName -Name $identityName -ErrorAction SilentlyContinue)) {
    $identity = New-AzUserAssignedIdentity -ResourceGroupName $resourceGroupName -Name $identityName
} else {
    $identity = Get-AzUserAssignedIdentity -ResourceGroupName $resourceGroupName -Name $identityName
}

# Definir a política JSON corretamente
$policyRule = @{
  "if" = @{
    "allOf" = @(
      @{
        "field" = "type"
        "equals" = "Microsoft.Resources/subscriptions/resourceGroups"
      },
      @{
        "field" = "location"
        "equals" = "eastus2"
      }
    )
  }
  "then" = @{
    "effect" = "modify"
    "details" = @{
      "roleDefinitionIds" = @(
        "/providers/Microsoft.Authorization/roleDefinitions/$roleDefinitionId"
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
          "value" = "carascoza"
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

# Atribuir a política à assinatura com a identidade gerida
New-AzPolicyAssignment -Name $policyName -PolicyDefinition $policyDefinition -Scope "/subscriptions/$subscriptionId" -Identity $identity

Write-Output "Política de tags padrão criada e atribuída com sucesso!"