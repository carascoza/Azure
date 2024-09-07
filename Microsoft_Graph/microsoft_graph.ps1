
#Verificar se modulo "Microsoft.Graph" esta instalado
Get-InstalledModule | Where-Object {$_.Name -match "Microsoft.Graph"}

#Instalar modulo	
#Install-Module -Name "Microsoft.Graph"
#Install-Module Microsoft.Graph -Scope CurrentUser

#Connect to Microsoft Graph
Connect-MgGraph -Scopes "User.Read.All","Group.ReadWrite.All","Device.Read.All","DeviceManagementManagedDevices.Read.All"
 
 
#verificar permissoes
Find-MgGraphCommand -command Get-MgUser | Select -First 1 -ExpandProperty Permissions

#listar users
Get-MgUser

#listar devices
Get-MgDevice

#Properties to Retrieve
$Properties = @(
    'Id','DisplayName','UserPrincipalName','UserType', 'AccountEnabled', 'SignInActivity'   
)
 
#Get All users along with the properties
$AllUsers = Get-MgUser -All -Property $Properties
 
$SigninLogs = @()
ForEach ($User in $AllUsers)
{
    $SigninLogs += [PSCustomObject][ordered]@{
            LoginName       = $User.UserPrincipalName
            DisplayName     = $User.DisplayName
            UserType        = $User.UserType
            AccountEnabled  = $User.AccountEnabled
            LastSignIn      = $User.SignInActivity.LastSignInDateTime
    }
}
 
$SigninLogs


#Read more: https://www.sharepointdiary.com/2023/04/how-to-connect-to-microsoft-graph-api-from-powershell.html#ixzz8S2UazpwQ
#Read more: https://o365info.com/connect-microsoft-graph-powershell/
#Read more: https://learn.microsoft.com/en-us/powershell/microsoftgraph/get-started?view=graph-powershell-1.0
#Read more: https://learn.microsoft.com/pt-br/graph/api/device-list?view=graph-rest-1.0&tabs=powershell