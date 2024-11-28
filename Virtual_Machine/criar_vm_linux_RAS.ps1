@"
===============================================================================
                    SCRIPT
Title:         criar_vm_linux_RAS
Description:   criar_vm_linux_RAS
Usage:         .\criar_vm_linux_RAS.ps1
version:       V1.0
Date_create:   28/11/2024
Date_modified: 28/11/2024
links: 
===============================================================================

"@

#variaveis
$LogTime = Get-Date -Format "dd-MM-yyyy;hh:mm:ss"
$Time = Get-Date -Format "MM-dd-yyyy"
$LogFile = "<caminho>\criar_vm_linux_RAS_" + $Time + ".log"
$subscription = "sua_assinatura"
$resourceGroupName = "seu_resource_group"
$resourceGroupNameVnet = "seu_resource_group-vnet"
$location = "EastUS2"
$vmName = "nome-server"
$imagePublisher = "Canonical"
$imageOffer = "UbuntuServer"
$imageSku = "18.04-LTS"
$vmSize = "Standard_B2s"
$publicIpName = $vmName + "-ip"
$openPorts = @("22")
$vnetName = "sua_vnet"
$subnetName = "sua-subnet"
$sshKeyName = "seu _ssh_key"

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

# Criar um novo grupo de recursos (caso não exista)
if (-not (Get-AzResourceGroup -Name $resourceGroupName -ErrorAction SilentlyContinue)) {
    New-AzResourceGroup -Name $resourceGroupName -Location $location
}

# Obter a sub-rede existente
$vnet = Get-AzVirtualNetwork -ResourceGroupName $resourceGroupNameVnet -Name $vnetName
$subnet = Get-AzVirtualNetworkSubnetConfig -VirtualNetwork $vnet -Name $subnetName

# Criar uma interface de rede
$nicName = $vmName + "-nic"
$publicIp = New-AzPublicIpAddress -ResourceGroupName $resourceGroupName -Name $publicIpName -Location $location -AllocationMethod Dynamic
$nic = New-AzNetworkInterface -Name $nicName -ResourceGroupName $resourceGroupName -Location $location -SubnetId $subnet.Id -PublicIpAddressId $publicIp.Id

# Criar a configuração da VM
$image = "${imagePublisher}:${imageOffer}:${imageSku}:latest"
$vmConfig = New-AzVMConfig -VMName $vmName -VMSize $vmSize |
    Set-AzVMOperatingSystem -Linux -ComputerName $vmName -Credential (Get-Credential) |
    Set-AzVMSourceImage -PublisherName $imagePublisher -Offer $imageOffer -Skus $imageSku -Version "latest" |
    Add-AzVMNetworkInterface -Id $nic.Id

# Criar a VM
New-AzVM -ResourceGroupName $resourceGroupName -Location $location -VM $vmConfig

# Configurar a VM para servir como servidor de roteamento
Invoke-AzVMRunCommand -ResourceGroupName $resourceGroupName -Name $vmName -CommandId 'RunShellScript' -ScriptString @"
sudo apt-get update
sudo apt-get install -y strongswan
sudo sysctl -w net.ipv4.ip_forward=1
sudo sh -c 'echo 1 > /proc/sys/net/ipv4/ip_forward'
sudo sh -c 'echo "net.ipv4.ip_forward = 1" >> /etc/sysctl.conf'
"@

# Criar um endereço IP público dinâmico com SKU Basic
$publicIpDynamic = New-AzPublicIpAddress -ResourceGroupName $resourceGroupName -Name $publicIpName  -Location $location -AllocationMethod Dynamic -Sku Basic

# Obter a VM
$vm = Get-AzVM -ResourceGroupName $resourceGroupName -Name $vmName

# Obter a interface de rede associada à VM
$nicId = $vm.NetworkProfile.NetworkInterfaces[0].Id
$nicName = $nicId.Split('/')[-1]
$nic = Get-AzNetworkInterface -ResourceGroupName $resourceGroupName -Name $nicName

# Associar o endereço IP dinâmico à interface de rede
$nic.IpConfigurations[0].PublicIpAddress = $publicIpDynamic
$nic | Set-AzNetworkInterface

# Exibir o endereço IP público dinâmico da VM
Get-AzPublicIpAddress -ResourceGroupName $resourceGroupName -Name $publicIpName  | Select-Object -ExpandProperty IpAddress
