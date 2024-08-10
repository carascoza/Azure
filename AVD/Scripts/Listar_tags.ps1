@"
===============================================================================
                    SCRIPT
Title:         LISTAR TAGS
Description:   LISTAR TAGS
Usage:         .\Listar_tags.ps1
version:       V1.0
Date_create:   10/08/2024
Date_modified: 10/08/2024
===============================================================================

"@

#variaveis
$LogTime = Get-Date -Format "dd-MM-yyyy;hh:mm:ss"
$Time = Get-Date -Format "MM-dd-yyyy"

#arquivos logs
$LogFile = "<caminho>\AVD\tags\tags_" + $Time + ".log"
$ExportFilePath = "<caminho>\AVD\tags\"
$Lista_tags = $ExportFilePath + "lista_tags.csv"

Try
{ 
#conectar na azure tenant nome_empresa
"Conctar na azure;" + $LogTime | Out-File $LogFile -Append -Force
Connect-AzAccount
Set-AzContext -Subscription "<id_subscription>"
}
Catch{
$ErrorMessage = $_.Exception.Message
    "Error Concetar na azure;" +$ErrorMessage | Out-File $LogFile -Append -Force
   Write-Host -BackgroundColor red -ForegroundColor Black -Object $ErrorMessage
   exit
}

$vmstags = Get-AzVM | Where-Object { $_.ProvisioningState -eq "Succeeded"}

$results = @()
foreach ($vmtags in $vmstags) {
    $tagsvm = $vmtags.Tags.GetEnumerator() | Where-Object { $_.Key -eq "centro_de_custo" } | ForEach-Object {
        New-Object PSObject -Property @{
            "Nome da VM" = $resource.Name
            "Tag Key" = $_.Key
            "Tag Value" = $_.Value
        }
    }
    $results += $tagsvm
}
$results | Export-Csv -Path $Lista_tags -NoTypeInformation -Encoding UTF8
