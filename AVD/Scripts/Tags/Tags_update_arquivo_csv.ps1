@"
===============================================================================
                    SUPORTE-VDI
Title:         UPDATE TAGS
Description:   UPDATE TAGS
Usage:         .\update_tags.ps1
version:       V2.0
Date_create:   08/02/2024
Date_modified: 10/08/2024
===============================================================================
"@

#variaveis
$LogTime = Get-Date -Format "dd-MM-yyyy_hh-mm-ss"
$Time = Get-Date -Format "MM-dd-yyyy"
$LogFile = "<camminho>\Azure\Tags\Logs\alterar_tags_csv_" + $Time + ".log"
$ExportFilePath = "<camminho>\Azure\Tags\"
$alterar_tags = $ExportFilePath + "alterar_tags.csv"
$tags_Csv = Import-Csv $alterar_tags -Delimiter ';' 

##################################################################################################################
# Alterar
$tags_avd = @{
    "ambiente"      = "pr";
    "empresa"       = "empresa"; 
    "gerenciamento" = "portal_azure";
}
##################################################################################################################

Write-Host -BackgroundColor Green -ForegroundColor Black -Object "Hostpools a serem alterados "
$tags_Csv
pause

Try { 
    #conectar na azure tenant 
    "Conctar na azure;" + $LogTime | Out-File $LogFile -Append -Force
    Connect-AzAccount
    Set-AzContext -Subscription $subscriptionId
}
Catch {
    $ErrorMessage = $_.Exception.Message
    "Error Concetar na azure;" + $ErrorMessage | Out-File $LogFile -Append -Force
    Write-Host -BackgroundColor red -ForegroundColor Black -Object $ErrorMessage
    exit
}

# mantem token da azure
function GetAuthToken($resource) {
    $context = [Microsoft.Azure.Commands.Common.Authentication.Abstractions.AzureRmProfileProvider]::Instance.Profile.DefaultContext
    $Token = [Microsoft.Azure.Commands.Common.Authentication.AzureSession]::Instance.AuthenticationFactory.Authenticate($context.Account, $context.Environment, $context.Tenant.Id.ToString(), $null, [Microsoft.Azure.Commands.Common.Authentication.ShowDialog]::Never,
        $null, $resource).AccessToken
    $authHeader = @{
        'Content-Type' = 'application/json'
        Authorization  = 'Bearer ' + $Token
    }
    return $authHeader
}
$token = GetAuthToken -resource https://management.azure.com
#Log
"Mantem token da azure;" + $LogTime | Out-File $LogFile -Append -Force

foreach ($alt_tag in $tags_Csv) {
    Try { 
        #Cria arquivo log
        "Inicio: " + $LogTime | Out-File $LogFile -Append -Force
        # Listar HostPools
        #$hostpoolResourceGroup = (Get-AzResource -ResourceType "Microsoft.DesktopVirtualization/hostpools" | Where-Object {$_.ResourceGroupName -eq $alt_tag.resource}).ResourceGroupName
        Write-Host -BackgroundColor Green -ForegroundColor Black -Object "Alterando tags nos Hostpools "
        $Tag_hostpool = Get-AzResource -ResourceType "Microsoft.DesktopVirtualization/hostpools" | Where-Object { $_.Name -eq $alt_tag.resource }
        $Tag_resource = Get-AzResourceGroup | Where-Object { $_.ResourceGroupName -eq $Tag_hostpool.ResourceGroupName }
        Update-AzTag -ResourceId $Tag_hostpool.ResourceId -Tag $tags_avd -Operation Merge
        Update-AzTag -ResourceId $Tag_resource.ResourceId -Tag $tags_avd -Operation Merge
        Write-Host -BackgroundColor Green -ForegroundColor Black -Object "tags alteradas "
    }
    Catch {
        $ErrorMessage = $_.Exception.Message
        $alt_tag + ";" + $ErrorMessage | Out-File $LogFile  -Append -Force
    }
}
