@"
===============================================================================
                    SCRIPT
Title:         CRIAR HOSTPOOL AVD
Description:   CRIAR HOSTPOOL AVD
Usage:         .\CRIAR_HOSTPOOL.ps1
version:       V1.0
Date_create:   23/01/2024
Date_modified: 23/01/2024
Links: https://askaresh.com/2022/12/13/azure-virtual-desktop-powershell-create-a-host-pool-application-group-and-workspace-for-remoteapp-aka-published-applications/
===============================================================================

"@

# Variaveis
$LogTime = Get-Date -Format "dd-MM-yyyy_hh-mm-ss"
$LogFile  = "<informar caminho>\remover_vms_" + $Time + ".log"
$token_azure = $null
$REStoken_azure = $null

# Connect to the Azure Subcription
Connect-AzAccount

# Get existing context
$currentAzContext = Get-AzContext

# Your subscription. This command gets your current subscription
$subscriptionID = $currentAzContext.Subscription.Id

# Existing Resource Group to deploy the Host Pool
$rgName = "AZ104-RG"

# Geo Location to deploy the Host Pool
$location = "australiaeast"

# Host Pool name
$HPName = "RA-HP01"

# Host Pool Type Pooled|Personal
$HPType = "Pooled"

# Host Pool Load Balancing BreadthFirst|DepthFirst|Persistent
$HPLBType = "DepthFirst"

# Max number or users per session host
$Maxusers = "10"

# Preffered App group type Desktop|RailApplications
$AppGrpType = "RailApplications"

# ApplicationGroup Name
$AppGrpName = "$HPName-RAG"

# Workspace Name
$Wrkspace = "$HPName-WRK01"

# AAD Group used to assign the Application Group
# Copy the Object ID GUID from AAD Groups Blade
$AADGroupObjId = "dcc4b896-2f2d-49d9-9854-33768d8b65ba"

# Create the Host Pool with RemoteApp Configurations
try
{
    write-host "Create the Host Pool with Pooled RemoteApp Configurations"
    $DeployHPWRA = New-AzWvdHostPool -ResourceGroupName $rgName `
        -SubscriptionId $subscriptionID `
        -Name $HPName `
        -Location $location `
        -ValidationEnvironment:$true `
        -HostPoolType $HPType `
        -LoadBalancerType $HPLBType `
        -MaxSessionLimit $Maxusers `
        -PreferredAppGroupType $AppGrpType `
        -Tag:@{"Billing" = "IT"; "Department" = "IT"; "Location" = "AUS-East" } `
        -ErrorAction STOP
}
catch
{
    Write-Host $_.Exception.Message -ForegroundColor Yellow
}


# Create the Application Group for the Remote App Host Pool
try
{
    write-host "Create the Application Group for the Remote App Host Pool"
    $CreateAppGroupRA = New-AzWvdApplicationGroup -ResourceGroupName $rgName `
        -Name $AppGrpName `
        -Location $location `
        -HostPoolArmPath $DeployHPWRA.Id `
        -ApplicationGroupType 'RemoteApp' `
        -ErrorAction STOP
}
catch
{
    Write-Host $_.Exception.Message -ForegroundColor Yellow
}

# Create the Workspace for the RemoteApp Host Pool
try
{
    write-host "Create the Workspace for the RemoteApp Host Pool"
    $CreateWorkspaceRA = New-AzWvdWorkspace -ResourceGroupName $rgName `
        -Name $Wrkspace `
        -Location $location `
        -ApplicationGroupReference $CreateAppGroupRA.Id `
        -ErrorAction STOP
}
catch
{
    Write-Host $_.Exception.Message -ForegroundColor Yellow
}

# Assign the AAD group (Object ID)  to the Application Group
try
{
    write-host "Assigning the AAD Group to the Application Group"
    $AssignAADGrpAG = New-AzRoleAssignment -ObjectId $AADGroupObjId `
        -RoleDefinitionName "Desktop Virtualization User" `
        -ResourceName $CreateAppGroupRA.Name `
        -ResourceGroupName $rgName `
        -ResourceType 'Microsoft.DesktopVirtualization/applicationGroups' `
        -ErrorAction STOP
}
catch
{
    Write-Host $_.Exception.Message -ForegroundColor Yellow
}