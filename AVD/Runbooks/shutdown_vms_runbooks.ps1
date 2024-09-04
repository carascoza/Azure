
try { 
    "Logging in to Azure..." 
    Connect-AzAccount -Identity -AccountId c944d278-dd77-42b8-a145-7e88cd439767
} 
catch { 
    Write-Error -Message $_.Exception 
    throw $_.Exception 
} 

$resourceGroups = Get-AzResourceGroup

# Loop through each resource group and get the list of VMs
foreach ($rg in $resourceGroups) {
    Write-Output "Resource Group: $($rg.ResourceGroupName)"
    $vmList = Get-AzVM -ResourceGroupName $rg.ResourceGroupName
    # Loop through each VM and get its status
    foreach ($vm in $vmList) {
        $vmStatus = Get-AzVM -ResourceGroupName $rg.ResourceGroupName -Name $vm.Name -Status
        $vmName = $vm.Name
        $vmPowerState = $vmStatus.Statuses | Where-Object { $_.Code -like 'PowerState/*' } | Select-Object -ExpandProperty DisplayStatus
        Write-Output "VM Name: $vmName, Status: $vmPowerState"
        # Shutdown the VM if it is running
        if ($vmPowerState -eq "VM running") {
            Stop-AzVM -ResourceGroupName $rg.ResourceGroupName -Name $vmName -Force
            Write-Output "Shutting down VM: $vmName"
        }
    }
}