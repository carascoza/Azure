@"
===============================================================================
                    SCRIPT
Title:         COST SUBSCRIPTIONS
Description:   COST SUBSCRIPTIONS
Usage:         .\cost_subscriptions.ps1
version:       V1.0
Date_create:   07/09/2024
Date_modified: 07/09/2024
links: https://learn.microsoft.com/en-us/azure/cost-management-billing/costs/manage-automation
===============================================================================

"@

# Autenticarse en Azure
Connect-AzAccount

# Obtener los detalles de uso y costos
$startDate = (Get-Date).AddMonths(-1).ToString("yyyy-MM-dd")
$endDate = (Get-Date).ToString("yyyy-MM-dd")
$usageDetails = Get-AzConsumptionUsageDetail -StartDate $startDate -EndDate $endDate

# Mostrar los detalles
$usageDetails
$usageDetails | Select-Object -Property UsageStart, UsageEnd, InstanceName, MeterCategory, Cost
